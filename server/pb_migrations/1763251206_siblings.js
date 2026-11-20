/// <reference path="../pb_data/types.d.ts" />
// FEAT-25: siblings. Each child already is its own `children` record (one
// owner, many children; deleting one cascades to her records). This adds
// the built-in avatar id (AD-7); `field_times` (json) carries its change
// time like the other fields. Never edit these in the admin UI (NFR-15).
migrate((app) => {
  const children = app.findCollectionByNameOrId("children");
  children.fields.add(new TextField({ name: "avatar", max: 20 }));
  app.save(children);
}, (app) => {
  const children = app.findCollectionByNameOrId("children");
  children.fields.removeByName("avatar");
  app.save(children);
});
