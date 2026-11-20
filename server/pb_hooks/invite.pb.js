/// <reference path="../pb_data/types.d.ts" />
// FEAT-36: invitation codes. POST /api/nn/invite/redeem (INV-02, INV-03,
// IC-4) lets a signed-in, verified parent use a code; rate limited by the
// migration (IC-5). POST /api/nn/admin/invites (INV-05, IC-6) is for the
// superuser (tool/make_invites.dart). Logic lives in lib/invites.js.
routerAdd("POST", "/api/nn/invite/redeem", (e) => {
  if (!e.auth.verified()) {
    return e.json(403, { reason: "unverified", message: "Verify your email first." });
  }
  const lib = require(`${__hooks}/lib/invites.js`);
  const ent = require(`${__hooks}/lib/entitlements.js`);
  const body = e.requestInfo().body || {};
  const now = Date.now();
  const r = lib.redeem(e.app, e.auth.id, body.code, now);
  if (!r.ok) return e.json(400, { reason: r.reason, message: "The code can't be used." });
  return e.json(200, ent.activeEntitlement(e.app, e.auth.id, now));
}, $apis.requireAuth("users"));

// Body: {count, months?, max_uses?, redeem_by_days?, note?, send_to?}.
// send_to: an address, or "default" for INVITE_MAIL_TO (else
// CRASH_DIGEST_TO). When mailed, the codes are left out of the answer so
// they never reach a (public) CI log.
routerAdd("POST", "/api/nn/admin/invites", (e) => {
  const lib = require(`${__hooks}/lib/invites.js`);
  const body = e.requestInfo().body || {};
  const made = lib.makeCodes(e.app, body, Date.now());
  if (made.error) return e.json(400, { message: made.error });
  let to = String(body.send_to || "").trim();
  if (to === "default") {
    to = ($os.getenv("INVITE_MAIL_TO") || "").trim() || ($os.getenv("CRASH_DIGEST_TO") || "").trim();
  }
  const answer = {
    count: made.codes.length,
    months: made.months,
    max_uses: made.max_uses,
    redeem_by: made.redeem_by,
    note: made.note,
    emailed: false,
  };
  if (to) {
    lib.mailCodes(e.app, to, made);
    answer.emailed = true;
  } else {
    answer.codes = made.codes;
  }
  return e.json(200, answer);
}, $apis.requireSuperuserAuth());
