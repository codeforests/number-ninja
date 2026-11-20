// FEAT-29: shared entitlement logic for entitlement.pb.js (design AD-1,
// AD-5, AD-7, AD-8). Loaded with require() inside each handler (PocketBase
// JSVM handlers don't see top-level code of other files).
const FOREVER = "2099-12-31 23:59:59.000Z";
const STORES = { PLAY_STORE: "google_play", APP_STORE: "app_store" };
const ACTIVE = [
  "INITIAL_PURCHASE", "RENEWAL", "UNCANCELLATION", "PRODUCT_CHANGE",
  "NON_RENEWING_PURCHASE", "SUBSCRIPTION_EXTENDED", "TEMPORARY_ENTITLEMENT_GRANT",
];
const HANDLED = ACTIVE.concat([
  "CANCELLATION", "BILLING_ISSUE", "SUBSCRIPTION_PAUSED", "EXPIRATION", "TRANSFER",
]);

/** PocketBase date string ("2026-11-20 13:00:00.000Z") → epoch ms (0 if empty). */
function ms(s) {
  if (!s) return 0;
  const t = Date.parse(String(s).replace(" ", "T"));
  return isNaN(t) ? 0 : t;
}

/** Epoch ms → PocketBase date string. */
function pbDate(m) {
  return new Date(m).toISOString().replace("T", " ");
}

function records(app, userId) {
  return app.findRecordsByFilter("entitlements", "user = {:u}", "-expires_at", 0, 0, { u: userId });
}

/**
 * The app's view of an account's Plus (AD-5): the active record with the
 * latest expiry, else `plus: false` and when Plus last ended.
 */
function activeEntitlement(app, userId, nowMs) {
  const all = records(app, userId);
  const checked = pbDate(nowMs);
  for (const r of all) {
    if (ms(r.getString("expires_at")) > nowMs) {
      const source = r.getString("source");
      const status = r.getString("status");
      return {
        plus: true,
        until: r.getString("expires_at"),
        source: source,
        status: status,
        will_renew: (source === "google_play" || source === "app_store") && status === "active",
        ended_at: null,
        checked_at: checked,
      };
    }
  }
  return {
    plus: false,
    until: null,
    source: null,
    status: null,
    will_renew: false,
    ended_at: all.length ? all[0].getString("expires_at") : null,
    checked_at: checked,
  };
}

function isUser(app, id) {
  if (!id || typeof id !== "string") return false;
  try {
    app.findRecordById("users", id);
    return true;
  } catch (_) {
    return false;
  }
}

function findRecord(app, userId, source) {
  try {
    return app.findFirstRecordByFilter("entitlements", "user = {:u} && source = {:s}", { u: userId, s: source });
  } catch (_) {
    return null;
  }
}

function newRecord(app, userId, source) {
  const r = new Record(app.findCollectionByNameOrId("entitlements"));
  r.set("user", userId);
  r.set("plan", "plus");
  r.set("source", source);
  return r;
}

/** True when this event was already applied to [r] or is older (AD-8). */
function stale(r, eventId, eventMs) {
  if (!r) return false;
  if (eventId && r.getString("last_event_id") === eventId) return true;
  const last = ms(r.getString("last_event_at"));
  return last > 0 && eventMs > 0 && eventMs < last;
}

function stamp(r, ev, eventMs) {
  if (ev.product_id) r.set("product_id", String(ev.product_id).slice(0, 64));
  if (ev.environment) r.set("environment", String(ev.environment).slice(0, 64));
  r.set("last_event_id", String(ev.id || "").slice(0, 128));
  if (eventMs > 0) r.set("last_event_at", pbDate(eventMs));
}

/**
 * Applies one RevenueCat webhook body (AD-7, AD-8) in a transaction.
 * Returns the JSON to answer; always 200 (a non-200 makes RevenueCat retry).
 */
function applyEvent(app, body, nowMs) {
  const ev = body && body.event;
  if (!ev || typeof ev !== "object") return { ignored: "no event" };
  const type = String(ev.type || "");
  if (HANDLED.indexOf(type) < 0) return { ignored: "event type" };
  const source = STORES[ev.store];
  if (!source) return { ignored: "store" };
  const ids = ev.entitlement_ids;
  if (Array.isArray(ids) && ids.length > 0 && ids.indexOf("plus") < 0) {
    return { ignored: "entitlement" };
  }
  const eventMs = Number(ev.event_timestamp_ms) || 0;
  const expMs = ev.expiration_at_ms == null ? null : Number(ev.expiration_at_ms);

  if (type === "TRANSFER") {
    const from = (ev.transferred_from || []).filter((id) => isUser(app, id));
    const to = (ev.transferred_to || []).find((id) => isUser(app, id));
    if (!to) return { ignored: "unknown user" };
    let moved = 0;
    app.runInTransaction((tx) => {
      for (const id of from) {
        const old = findRecord(tx, id, source);
        if (!old || stale(old, ev.id, eventMs)) continue;
        let target = findRecord(tx, to, source);
        if (stale(target, ev.id, eventMs)) continue;
        if (!target) target = newRecord(tx, to, source);
        for (const f of ["status", "expires_at", "product_id", "environment"]) {
          target.set(f, old.getString(f));
        }
        stamp(target, ev, eventMs);
        tx.save(target);
        old.set("status", "expired");
        if (ms(old.getString("expires_at")) > nowMs) old.set("expires_at", pbDate(nowMs));
        stamp(old, ev, eventMs);
        tx.save(old);
        moved++;
      }
    });
    return { applied: type, moved: moved };
  }

  const candidates = [ev.app_user_id, ev.original_app_user_id].concat(ev.aliases || []);
  const userId = candidates.find((id) => isUser(app, id));
  if (!userId) return { ignored: "unknown user" };

  let result = { applied: type };
  app.runInTransaction((tx) => {
    let r = findRecord(tx, userId, source);
    if (stale(r, ev.id, eventMs)) {
      result = { ignored: "already applied or older" };
      return;
    }
    const existing = r ? r.getString("expires_at") : "";
    if (!r) r = newRecord(tx, userId, source);
    const keep = existing || pbDate(expMs != null ? expMs : nowMs);
    if (ACTIVE.indexOf(type) >= 0) {
      r.set("status", "active");
      r.set("expires_at", expMs == null ? FOREVER : pbDate(expMs));
    } else if (type === "CANCELLATION") {
      r.set("status", ev.cancel_reason === "CUSTOMER_SUPPORT" ? "refunded" : "cancelled");
      r.set("expires_at", expMs == null ? keep : pbDate(expMs));
    } else if (type === "BILLING_ISSUE") {
      r.set("status", "billing_issue");
      const grace = ev.grace_period_expiration_at_ms;
      r.set("expires_at", grace == null ? keep : pbDate(Number(grace)));
    } else if (type === "SUBSCRIPTION_PAUSED") {
      r.set("status", "paused");
      r.set("expires_at", keep);
    } else if (type === "EXPIRATION") {
      r.set("status", "expired");
      r.set("expires_at", pbDate(Math.min(expMs == null ? nowMs : expMs, nowMs)));
    }
    stamp(r, ev, eventMs);
    tx.save(r);
  });
  return result;
}

module.exports = { FOREVER, ms, pbDate, activeEntitlement, applyEvent };
