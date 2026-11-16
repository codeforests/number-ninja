/// <reference path="../pb_data/types.d.ts" />
// FEAT-14: progress sync. `children.reset_at` (set by the reset route in
// pb_hooks/reset.pb.js) and the batch API the app pushes with (100 requests
// per batch). Each request in a batch counts against the rate limits, so the
// create limit goes up for the synced collections (a first sync sends
// ~20,000 records, NFR-16) while sign-ups keep the old 20 per 5 s. Never edit
// these in the admin UI (NFR-15).
migrate((app) => {
  const children = app.findCollectionByNameOrId("children");
  children.fields.add(new DateField({ name: "reset_at" }));
  app.save(children);

  const settings = app.settings();
  settings.batch.enabled = true;
  settings.batch.maxRequests = 100;
  settings.batch.timeout = 10;
  settings.batch.maxBodySize = 8 * 1024 * 1024;

  const rules = [];
  for (const r of settings.rateLimits.rules) {
    if (["users:create", "*:create", "/api/batch"].includes(r.label)) continue;
    rules.push({ label: r.label, audience: r.audience, duration: r.duration, maxRequests: r.maxRequests });
  }
  rules.push({ label: "users:create", audience: "", duration: 5, maxRequests: 20 });
  rules.push({ label: "*:create", audience: "@auth", duration: 5, maxRequests: 5000 });
  rules.push({ label: "*:create", audience: "@guest", duration: 5, maxRequests: 20 });
  rules.push({ label: "/api/batch", audience: "@auth", duration: 1, maxRequests: 10 });
  settings.rateLimits.rules = rules;
  app.save(settings);
}, (app) => {
  const children = app.findCollectionByNameOrId("children");
  children.fields.removeByName("reset_at");
  app.save(children);

  const settings = app.settings();
  settings.batch.enabled = false;
  app.save(settings);
});
