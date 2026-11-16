/// <reference path="../pb_data/types.d.ts" />
// FEAT-12: collections, fields, indexes and API rules (04-architecture.md §2,
// NFR-13). Rules: "" = anyone, null = superuser only. Never edit the schema in
// the admin UI: add a migration here instead (NFR-15).
migrate((app) => {
  const users = app.findCollectionByNameOrId("users");
  users.listRule = "id = @request.auth.id";
  users.viewRule = "id = @request.auth.id";
  users.createRule = "";
  users.updateRule = "id = @request.auth.id";
  users.deleteRule = "id = @request.auth.id";
  users.passwordAuth.enabled = true;
  app.save(users);

  const ownChild = "child.owner = @request.auth.id";
  const createForOwnChild =
    '@request.auth.id != "" && @request.body.child.owner = @request.auth.id';
  const updateOwnChild =
    ownChild + " && (@request.body.child:isset = false || @request.body.child = child)";

  const children = new Collection({
    type: "base",
    name: "children",
    listRule: "owner = @request.auth.id",
    viewRule: "owner = @request.auth.id",
    createRule: '@request.auth.id != "" && @request.body.owner = @request.auth.id',
    updateRule:
      "owner = @request.auth.id && (@request.body.owner:isset = false || @request.body.owner = owner)",
    deleteRule: "owner = @request.auth.id",
    fields: [
      { type: "relation", name: "owner", required: true, collectionId: users.id, cascadeDelete: true, maxSelect: 1 },
      { type: "text", name: "nickname", max: 40 },
      { type: "number", name: "school_year", onlyInt: true },
      { type: "number", name: "start_level_school", onlyInt: true },
      { type: "number", name: "start_level_olympiad", onlyInt: true },
      { type: "json", name: "unlocked_topics", maxSize: 20000 },
      { type: "number", name: "daily_limit_min", onlyInt: true },
      { type: "bool", name: "sound_on" },
      { type: "json", name: "field_times", maxSize: 20000 },
      { type: "number", name: "reset_epoch", onlyInt: true },
      { type: "autodate", name: "created", onCreate: true, onUpdate: false },
      { type: "autodate", name: "updated", onCreate: true, onUpdate: true },
    ],
    indexes: ["CREATE INDEX idx_children_owner ON children (owner)"],
  });
  app.save(children);

  const childField = () => ({
    type: "relation", name: "child", required: true, collectionId: children.id, cascadeDelete: true, maxSelect: 1,
  });
  const stamps = () => [
    { type: "autodate", name: "created", onCreate: true, onUpdate: false },
    { type: "autodate", name: "updated", onCreate: true, onUpdate: true },
  ];
  const perChild = (name, fields, indexes, appendOnly) => new Collection({
    type: "base",
    name,
    listRule: ownChild,
    viewRule: ownChild,
    createRule: createForOwnChild,
    updateRule: appendOnly ? null : updateOwnChild,
    deleteRule: null,
    fields: [childField(), ...fields, ...stamps()],
    indexes: [`CREATE INDEX idx_${name}_child_updated ON ${name} (child, updated)`, ...indexes],
  });

  app.save(perChild("rounds", [
    { type: "text", name: "uuid", required: true, max: 64 },
    { type: "text", name: "topic_id", required: true, max: 64 },
    { type: "number", name: "level", onlyInt: true },
    { type: "select", name: "kind", required: true, maxSelect: 1, values: ["normal", "revision"] },
    { type: "date", name: "started_at" },
    { type: "date", name: "finished_at" },
    { type: "number", name: "score", onlyInt: true },
    { type: "number", name: "duration_ms", onlyInt: true },
    { type: "number", name: "stars", onlyInt: true },
    { type: "text", name: "device_id", max: 64 },
  ], ["CREATE UNIQUE INDEX idx_rounds_uuid ON rounds (uuid)"], false));

  app.save(perChild("attempts", [
    { type: "text", name: "uuid", required: true, max: 64 },
    { type: "text", name: "round_uuid", required: true, max: 64 },
    { type: "text", name: "question_id", required: true, max: 64 },
    { type: "text", name: "answer_given", max: 200 },
    { type: "bool", name: "correct" },
    { type: "number", name: "time_ms", onlyInt: true },
    { type: "date", name: "answered_at" },
  ], ["CREATE UNIQUE INDEX idx_attempts_uuid ON attempts (uuid)"], true));

  app.save(perChild("badges", [
    { type: "text", name: "badge_id", required: true, max: 64 },
    { type: "date", name: "earned_at" },
  ], ["CREATE UNIQUE INDEX idx_badges_child_badge ON badges (child, badge_id)"], false));

  app.save(perChild("daily_usage", [
    { type: "text", name: "day", required: true, pattern: "^\\d{4}-\\d{2}-\\d{2}$" },
    { type: "text", name: "device_id", required: true, max: 64 },
    { type: "number", name: "seconds_used", onlyInt: true },
    { type: "number", name: "extra_seconds_granted", onlyInt: true },
  ], ["CREATE UNIQUE INDEX idx_daily_usage_key ON daily_usage (child, day, device_id)"], false));

  app.save(new Collection({
    type: "base",
    name: "banks",
    listRule: "",
    viewRule: "",
    createRule: null,
    updateRule: null,
    deleteRule: null,
    fields: [
      { type: "text", name: "version", required: true, max: 64 },
      { type: "number", name: "format", onlyInt: true },
      { type: "number", name: "min_app_build", onlyInt: true },
      { type: "text", name: "sha256", max: 64 },
      { type: "file", name: "file", maxSelect: 1, maxSize: 20 * 1024 * 1024, mimeTypes: ["application/json"] },
      { type: "date", name: "published_at" },
      { type: "autodate", name: "created", onCreate: true, onUpdate: false },
      { type: "autodate", name: "updated", onCreate: true, onUpdate: true },
    ],
    indexes: ["CREATE UNIQUE INDEX idx_banks_version ON banks (version)"],
  }));
}, (app) => {
  for (const name of ["banks", "daily_usage", "badges", "attempts", "rounds", "children"]) {
    app.delete(app.findCollectionByNameOrId(name));
  }
});
