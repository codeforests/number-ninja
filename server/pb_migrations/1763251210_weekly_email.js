/// <reference path="../pb_data/types.d.ts" />
// FEAT-31: weekly progress email (WEM-01, WEM-02, WEM-05; design WE-2, WE-6,
// WE-10). `users` gains the parent's switch and time zone (writable by the
// owner through the existing users.updateRule) and a hidden token for the
// one-click turn-off link. `weekly_emails` logs one row per account and week
// (superuser only), so a week is never sent twice. "POST " first in the rate
// limit label: a bare path prefix loses to the earlier "/api/" rule
// (code-map gotcha).
const LIMIT = "POST /api/nn/weekly-email/";

function setRateLimit(app, add) {
  const settings = app.settings();
  settings.rateLimits.rules = settings.rateLimits.rules
    .filter((r) => r.label !== LIMIT)
    .map((r) => ({ label: r.label, audience: r.audience, duration: r.duration, maxRequests: r.maxRequests }));
  if (add) settings.rateLimits.rules.push({ label: LIMIT, audience: "", duration: 60, maxRequests: 10 });
  app.save(settings);
}

migrate((app) => {
  const users = app.findCollectionByNameOrId("users");
  users.fields.add(new BoolField({ name: "weekly_email" }));
  users.fields.add(new NumberField({ name: "weekly_email_tz", min: -720, max: 840, onlyInt: true }));
  users.fields.add(new TextField({ name: "email_token", max: 32, hidden: true }));
  app.save(users);

  const log = new Collection({
    type: "base",
    name: "weekly_emails",
    listRule: null,
    viewRule: null,
    createRule: null,
    updateRule: null,
    deleteRule: null,
    fields: [
      { type: "relation", name: "user", required: true, collectionId: users.id, cascadeDelete: true, maxSelect: 1 },
      { type: "text", name: "week", required: true, pattern: "^\\d{4}-\\d{2}-\\d{2}$" },
      { type: "select", name: "status", required: true, maxSelect: 1, values: ["sent", "skipped"] },
      { type: "number", name: "children", min: 0, onlyInt: true },
      { type: "autodate", name: "created", onCreate: true, onUpdate: false },
    ],
    indexes: ["CREATE UNIQUE INDEX idx_weekly_emails_user_week ON weekly_emails (user, week)"],
  });
  app.save(log);

  setRateLimit(app, true);
}, (app) => {
  setRateLimit(app, false);
  app.delete(app.findCollectionByNameOrId("weekly_emails"));
  const users = app.findCollectionByNameOrId("users");
  for (const name of ["weekly_email", "weekly_email_tz", "email_token"]) users.fields.removeByName(name);
  app.save(users);
});
