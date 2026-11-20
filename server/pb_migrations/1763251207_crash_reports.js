/// <reference path="../pb_data/types.d.ts" />
// FEAT-24: crash reports (CRS-04, CRS-06, AD-4, AD-10). Anyone may create a
// report (the app sends them signed out or without its token); nobody but a
// superuser lists, views, updates or deletes them. Field limits match the
// app's caps, so an oversized post is refused. Creates are limited to 10
// per 60 s per IP. Never edit these in the admin UI (NFR-15).
migrate((app) => {
  const text = (name, max, required) => ({ type: "text", name, max, required: !!required });
  const reports = new Collection({
    type: "base",
    name: "crash_reports",
    listRule: null,
    viewRule: null,
    createRule: "",
    updateRule: null,
    deleteRule: null,
    fields: [
      text("signature", 64, true),
      text("app_version", 128, true),
      { type: "number", name: "bank_version", onlyInt: true, min: 0 },
      text("os", 128),
      text("device", 128),
      text("screen", 128),
      text("error_type", 128, true),
      text("message", 1000),
      text("stack", 8000),
      { type: "number", name: "count", required: true, onlyInt: true, min: 1, max: 100000 },
      { type: "date", name: "first_at" },
      { type: "date", name: "last_at" },
      { type: "autodate", name: "created", onCreate: true, onUpdate: false },
    ],
    indexes: [
      "CREATE INDEX idx_crash_reports_signature ON crash_reports (signature)",
      "CREATE INDEX idx_crash_reports_created ON crash_reports (created)",
    ],
  });
  app.save(reports);

  const settings = app.settings();
  settings.rateLimits.rules = settings.rateLimits.rules
    .filter((r) => r.label !== "crash_reports:create")
    .map((r) => ({ label: r.label, audience: r.audience, duration: r.duration, maxRequests: r.maxRequests }));
  settings.rateLimits.rules.push({ label: "crash_reports:create", audience: "", duration: 60, maxRequests: 10 });
  app.save(settings);
}, (app) => {
  app.delete(app.findCollectionByNameOrId("crash_reports"));
  const settings = app.settings();
  settings.rateLimits.rules = settings.rateLimits.rules
    .filter((r) => r.label !== "crash_reports:create")
    .map((r) => ({ label: r.label, audience: r.audience, duration: r.duration, maxRequests: r.maxRequests }));
  app.save(settings);
});
