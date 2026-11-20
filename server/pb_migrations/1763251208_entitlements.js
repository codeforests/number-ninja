/// <reference path="../pb_data/types.d.ts" />
// FEAT-29: entitlements (ENT-01..06, BNK-13; design AD-1..AD-4, AD-6, AD-10).
// One record per parent account and source; Plus is active while any of the
// account's records has `expires_at` in the future (`status` is display
// only). Parents read their own records; only the server writes (superuser,
// hooks, tool/grant_plus.dart). The server bank needs active Plus, and its
// file is protected (a file token is needed). Every account that exists when
// this runs (Ken's family) gets Plus with no end. Never edit these in the
// admin UI (NFR-15).
const FOREVER = "2099-12-31 23:59:59.000Z";
const FOUNDING_NOTE = "founding family (FEAT-29)";
const PLUS_RULE =
  '@request.auth.collectionName = "users" && ' +
  "@collection.entitlements.user ?= @request.auth.id && " +
  "@collection.entitlements.expires_at ?> @now";

function setRateLimit(app, add) {
  const settings = app.settings();
  settings.rateLimits.rules = settings.rateLimits.rules
    .filter((r) => r.label !== "/api/nn/billing/")
    .map((r) => ({ label: r.label, audience: r.audience, duration: r.duration, maxRequests: r.maxRequests }));
  if (add) settings.rateLimits.rules.push({ label: "/api/nn/billing/", audience: "", duration: 60, maxRequests: 60 });
  app.save(settings);
}

function gateBanks(app, rule, protectedFile) {
  const banks = app.findCollectionByNameOrId("banks");
  banks.listRule = rule;
  banks.viewRule = rule;
  banks.fields.getByName("file").protected = protectedFile;
  app.save(banks);
}

migrate((app) => {
  const users = app.findCollectionByNameOrId("users");
  const text = (name, max) => ({ type: "text", name, max });
  const select = (name, values, required) => ({ type: "select", name, values, maxSelect: 1, required: !!required });
  const entitlements = new Collection({
    type: "base",
    name: "entitlements",
    listRule: "user = @request.auth.id",
    viewRule: "user = @request.auth.id",
    createRule: null,
    updateRule: null,
    deleteRule: null,
    fields: [
      { type: "relation", name: "user", required: true, collectionId: users.id, cascadeDelete: true, maxSelect: 1 },
      select("plan", ["plus"], true),
      select("source", ["complimentary", "invite", "google_play", "app_store"], true),
      select("status", ["active", "cancelled", "billing_issue", "paused", "expired", "refunded", "revoked"], true),
      { type: "date", name: "expires_at", required: true },
      text("note", 200),
      text("product_id", 64),
      text("environment", 64),
      text("last_event_id", 128),
      { type: "date", name: "last_event_at" },
      { type: "autodate", name: "created", onCreate: true, onUpdate: false },
      { type: "autodate", name: "updated", onCreate: true, onUpdate: true },
    ],
    indexes: [
      "CREATE UNIQUE INDEX idx_entitlements_user_source ON entitlements (user, source)",
      "CREATE INDEX idx_entitlements_expires ON entitlements (expires_at)",
    ],
  });
  app.save(entitlements);

  // AD-10: the founding grant.
  for (const u of app.findAllRecords("users")) {
    const r = new Record(entitlements);
    r.set("user", u.id);
    r.set("plan", "plus");
    r.set("source", "complimentary");
    r.set("status", "active");
    r.set("expires_at", FOREVER);
    r.set("note", FOUNDING_NOTE);
    app.save(r);
  }

  gateBanks(app, PLUS_RULE, true);
  setRateLimit(app, true);
}, (app) => {
  gateBanks(app, "", false);
  setRateLimit(app, false);
  app.delete(app.findCollectionByNameOrId("entitlements"));
});
