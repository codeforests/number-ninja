/// <reference path="../pb_data/types.d.ts" />
// FEAT-31: the weekly progress email (WEM-02, WEM-05, WEM-06). Cron
// `weekly_email` runs at minute 7 of every hour and sends each account whose
// local Monday 08:00 has passed (until Wednesday 08:00) the week before, once
// (WE-5). POST /api/nn/admin/weekly-email runs or previews it for a given time
// (WE-11). /api/nn/weekly-email/off is the one-click turn-off link (WE-10):
// GET only shows a button, POST turns the email off. Logic in lib/weekly.js;
// handlers run in their own VM, so each one requires it.
cronAdd("weekly_email", "7 * * * *", () => {
  const lib = require(`${__hooks}/lib/weekly.js`);
  lib.run($app, Date.now(), null);
});

// Body: {now?: ISO time, user?: id, preview?: bool}.
routerAdd("POST", "/api/nn/admin/weekly-email", (e) => {
  const lib = require(`${__hooks}/lib/weekly.js`);
  const body = e.requestInfo().body || {};
  const now = body.now ? Date.parse(String(body.now)) : Date.now();
  if (isNaN(now)) return e.json(400, { message: "now must be an ISO time" });
  const user = body.user ? String(body.user) : null;
  if (body.preview) {
    if (!user) return e.json(400, { message: "preview needs user" });
    try {
      return e.json(200, lib.preview(e.app, user, now));
    } catch (_) {
      return e.json(404, { message: "no such user" });
    }
  }
  return e.json(200, lib.run(e.app, now, user));
}, $apis.requireSuperuserAuth());

routerAdd("GET", "/api/nn/weekly-email/off", (e) => {
  const q = e.requestInfo().query || {};
  const lib = require(`${__hooks}/lib/weekly.js`);
  return e.html(200, lib.offPage(
    "Weekly progress email",
    "Stop the Monday summary of your children's practice? You can turn it on again in the app (Parent area → Account).",
    !!(q.u && q.t),
  ));
});

routerAdd("POST", "/api/nn/weekly-email/off", (e) => {
  const lib = require(`${__hooks}/lib/weekly.js`);
  const q = e.requestInfo().query || {};
  const ok = lib.turnOff(e.app, q.u, q.t);
  if (!ok) return e.html(400, lib.offPage("Weekly progress email", "This link is not valid any more.", false));
  return e.html(200, lib.offPage("Weekly emails are off", "You can turn them on again in the app (Parent area → Account).", false));
});
