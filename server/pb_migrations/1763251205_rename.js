/// <reference path="../pb_data/types.d.ts" />
// FEAT-16 (D16): the app is now BrainBubblz. config.pb.js copies appName
// into the email sender name on every start. The FEAT-12 settings migration
// has already run on the droplet, so the new name needs its own migration.
migrate((app) => {
  const settings = app.settings();
  settings.meta.appName = "BrainBubblz";
  app.save(settings);
}, (app) => {
  // Settings are not rolled back.
});
