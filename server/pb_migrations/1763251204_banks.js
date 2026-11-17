/// <reference path="../pb_data/types.d.ts" />
// FEAT-15 (D5): `banks.version` becomes a number, so "the latest bank" is
// `sort=-version` and the publish step can refuse a version that isn't
// higher (BNK-07). No bank was published before this, so dropping the text
// field loses nothing. Rules stay: anyone reads, only a superuser writes.
// Never edit these in the admin UI (NFR-15).
function swapVersion(app, field) {
  const banks = app.findCollectionByNameOrId("banks");
  banks.indexes = [];
  banks.fields.removeByName("version");
  app.save(banks);
  banks.fields.add(field);
  banks.indexes = ["CREATE UNIQUE INDEX idx_banks_version ON banks (version)"];
  app.save(banks);
}

migrate((app) => {
  swapVersion(app, new NumberField({ name: "version", required: true, onlyInt: true, min: 1 }));
}, (app) => {
  swapVersion(app, new TextField({ name: "version", required: true, max: 64 }));
});
