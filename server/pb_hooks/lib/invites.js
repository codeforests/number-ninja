// FEAT-36: invitation code logic for invite.pb.js (design IC-1, IC-4, IC-6).
// Loaded with require() inside each handler (JSVM rule). Reuses the FEAT-29
// entitlement helpers: an invitation is the account's `invite` entitlement.
const ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
const DAY = 24 * 3600 * 1000;

/** Upper-cases and drops every character outside ALPHABET (IC-1). */
function normalise(raw) {
  return String(raw == null ? "" : raw)
    .toUpperCase()
    .split("")
    .filter((c) => ALPHABET.indexOf(c) >= 0)
    .join("");
}

/** "ABCDEFGH" → "ABCD-EFGH". */
function pretty(code) {
  return code.slice(0, 4) + "-" + code.slice(4);
}

/** Calendar months in UTC, the day clamped to the month's end (IC-4). */
function addMonths(fromMs, months) {
  const d = new Date(fromMs);
  const y = d.getUTCFullYear();
  const m = d.getUTCMonth() + months;
  const last = new Date(Date.UTC(y, m + 1, 0)).getUTCDate();
  return Date.UTC(y, m, Math.min(d.getUTCDate(), last),
    d.getUTCHours(), d.getUTCMinutes(), d.getUTCSeconds(), d.getUTCMilliseconds());
}

function first(app, collection, filter, params) {
  try {
    return app.findFirstRecordByFilter(collection, filter, params);
  } catch (_) {
    return null;
  }
}

/**
 * Redeems [raw] for [userId] in one transaction (IC-4). Returns
 * `{reason}` on a failure (nothing written) or `{ok: true}`.
 */
function redeem(app, userId, raw, nowMs) {
  const ent = require(`${__hooks}/lib/entitlements.js`);
  const code = normalise(raw);
  if (code.length !== 8) return { reason: "not_found" };
  let result = { reason: "not_found" };
  app.runInTransaction((tx) => {
    const c = first(tx, "invite_codes", "code = {:c}", { c: code });
    if (!c || c.getBool("revoked")) return;
    if (ent.ms(c.getString("redeem_by")) <= nowMs) { result = { reason: "expired" }; return; }
    if (c.getInt("uses") >= c.getInt("max_uses")) { result = { reason: "used_up" }; return; }
    if (first(tx, "invite_redemptions", "code = {:c} && user = {:u}", { c: c.id, u: userId })) {
      result = { reason: "already_used" };
      return;
    }
    const others = tx.findRecordsByFilter("entitlements", "user = {:u} && source != 'invite'", "", 0, 0, { u: userId });
    if (others.some((r) => ent.ms(r.getString("expires_at")) > nowMs)) {
      result = { reason: "already_plus" };
      return;
    }
    let r = first(tx, "entitlements", "user = {:u} && source = 'invite'", { u: userId });
    if (!r) {
      r = new Record(tx.findCollectionByNameOrId("entitlements"));
      r.set("user", userId);
      r.set("plan", "plus");
      r.set("source", "invite");
    }
    const from = Math.max(nowMs, r.getString("expires_at") ? ent.ms(r.getString("expires_at")) : 0);
    const until = ent.pbDate(addMonths(from, c.getInt("months")));
    r.set("status", "active");
    r.set("expires_at", until);
    r.set("note", ("invite " + code + ": " + c.getString("note")).slice(0, 200));
    tx.save(r);

    c.set("uses", c.getInt("uses") + 1);
    tx.save(c);
    const red = new Record(tx.findCollectionByNameOrId("invite_redemptions"));
    red.set("code", c.id);
    red.set("user", userId);
    red.set("plus_until", until);
    tx.save(red);
    result = { ok: true };
  });
  return result;
}

function intIn(v, lo, hi, dflt) {
  if (v == null || v === "") return dflt;
  const n = Number(v);
  return Number.isInteger(n) && n >= lo && n <= hi ? n : null;
}

/**
 * Makes codes (IC-6). [opts] is the admin request body. Returns
 * `{error}` for bad input, else `{codes, months, max_uses, redeem_by, note}`.
 */
function makeCodes(app, opts, nowMs) {
  const ent = require(`${__hooks}/lib/entitlements.js`);
  const o = opts || {};
  const count = intIn(o.count, 1, 100, null);
  const months = intIn(o.months, 1, 24, 12);
  const maxUses = intIn(o.max_uses, 1, 100, 5);
  const days = intIn(o.redeem_by_days, 1, 3650, 365);
  const note = String(o.note == null ? "" : o.note);
  if (count == null) return { error: "count must be 1 to 100" };
  if (months == null) return { error: "months must be 1 to 24" };
  if (maxUses == null) return { error: "max_uses must be 1 to 100" };
  if (days == null) return { error: "redeem_by_days must be 1 to 3650" };
  if (note.length > 200) return { error: "note is at most 200 characters" };
  const redeemBy = ent.pbDate(nowMs + days * DAY);
  const collection = app.findCollectionByNameOrId("invite_codes");
  const codes = [];
  app.runInTransaction((tx) => {
    for (let i = 0; i < count; i++) {
      let code = "";
      for (let tries = 0; tries < 10; tries++) {
        code = $security.randomStringWithAlphabet(8, ALPHABET);
        if (codes.indexOf(code) < 0 && !first(tx, "invite_codes", "code = {:c}", { c: code })) break;
        code = "";
      }
      if (!code) throw new Error("could not make a unique code");
      const r = new Record(collection);
      r.set("code", code);
      r.set("months", months);
      r.set("max_uses", maxUses);
      r.set("uses", 0);
      r.set("redeem_by", redeemBy);
      r.set("note", note);
      r.set("revoked", false);
      tx.save(r);
      codes.push(code);
    }
  });
  return { codes: codes, months: months, max_uses: maxUses, redeem_by: redeemBy, note: note };
}

/** Emails a batch to [to] through the normal mail path (FEAT-13, Resend). */
function mailCodes(app, to, made) {
  const esc = (s) => String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  const meta = app.settings().meta;
  const day = made.redeem_by.slice(0, 10);
  const lines = made.codes.map(pretty);
  app.newMailClient().send(new MailerMessage({
    from: { address: meta.senderAddress, name: meta.senderName },
    to: [{ address: to }],
    subject: "BrainBubblz invitation codes: " + lines.length + (made.note ? " (" + made.note + ")" : ""),
    html:
      "<p>" + lines.length + " invitation codes" + (made.note ? " for <b>" + esc(made.note) + "</b>" : "") +
      ". Each gives a family " + made.months + " months of Plus, can be used by " + made.max_uses +
      " families and can be redeemed until " + day + " (UTC).</p>" +
      "<p>Parents sign in, open Parent area → BrainBubblz Plus → Have an invitation code?</p>" +
      "<pre style=\"font-size:18px\">" + lines.join("\n") + "</pre>",
    text: lines.join("\n"),
  }));
}

module.exports = { ALPHABET, normalise, pretty, addMonths, redeem, makeCodes, mailCodes };
