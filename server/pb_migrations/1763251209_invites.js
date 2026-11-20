/// <reference path="../pb_data/types.d.ts" />
// FEAT-36: invitation codes (INV-01, INV-04; design IC-2, IC-3, IC-5).
// `invite_codes` are made by Ken (POST /api/nn/admin/invites,
// tool/make_invites.dart); `invite_redemptions` record which family used
// which code. Both are superuser only: parents redeem through
// POST /api/nn/invite/redeem (invite.pb.js), which writes the family's
// `invite` entitlement (FEAT-29). Codes are plain text on purpose (IC-2).
const LIMIT = "/api/nn/invite/";

function setRateLimit(app, add) {
  const settings = app.settings();
  settings.rateLimits.rules = settings.rateLimits.rules
    .filter((r) => r.label !== LIMIT)
    .map((r) => ({ label: r.label, audience: r.audience, duration: r.duration, maxRequests: r.maxRequests }));
  if (add) settings.rateLimits.rules.push({ label: LIMIT, audience: "", duration: 60, maxRequests: 5 });
  app.save(settings);
}

migrate((app) => {
  const users = app.findCollectionByNameOrId("users");
  const closed = { listRule: null, viewRule: null, createRule: null, updateRule: null, deleteRule: null };
  const codes = new Collection(Object.assign({
    type: "base",
    name: "invite_codes",
    fields: [
      { type: "text", name: "code", required: true, min: 8, max: 8, pattern: "^[A-HJ-NP-Z2-9]{8}$" },
      { type: "number", name: "months", required: true, min: 1, max: 24, onlyInt: true },
      { type: "number", name: "max_uses", required: true, min: 1, max: 100, onlyInt: true },
      { type: "number", name: "uses", min: 0, onlyInt: true },
      { type: "date", name: "redeem_by", required: true },
      { type: "text", name: "note", max: 200 },
      { type: "bool", name: "revoked" },
      { type: "autodate", name: "created", onCreate: true, onUpdate: false },
      { type: "autodate", name: "updated", onCreate: true, onUpdate: true },
    ],
    indexes: ["CREATE UNIQUE INDEX idx_invite_codes_code ON invite_codes (code)"],
  }, closed));
  app.save(codes);

  const redemptions = new Collection(Object.assign({
    type: "base",
    name: "invite_redemptions",
    fields: [
      { type: "relation", name: "code", required: true, collectionId: codes.id, cascadeDelete: true, maxSelect: 1 },
      { type: "relation", name: "user", required: true, collectionId: users.id, cascadeDelete: true, maxSelect: 1 },
      { type: "date", name: "plus_until", required: true },
      { type: "autodate", name: "created", onCreate: true, onUpdate: false },
    ],
    indexes: ["CREATE UNIQUE INDEX idx_invite_redemptions_code_user ON invite_redemptions (code, user)"],
  }, closed));
  app.save(redemptions);

  setRateLimit(app, true);
}, (app) => {
  setRateLimit(app, false);
  app.delete(app.findCollectionByNameOrId("invite_redemptions"));
  app.delete(app.findCollectionByNameOrId("invite_codes"));
});
