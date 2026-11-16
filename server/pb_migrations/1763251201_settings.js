/// <reference path="../pb_data/types.d.ts" />
// FEAT-12: app settings (NFR-15, ADR-08). The hostname comes from the
// SERVER_HOSTNAME environment variable, never from the repo.
migrate((app) => {
  const settings = app.settings();
  const host = $os.getenv("SERVER_HOSTNAME");
  settings.meta.appName = "Number Ninja";
  settings.meta.appURL = host ? "https://" + host : "http://127.0.0.1:8090";
  settings.backups.cron = "0 19 * * *"; // 19:00 UTC = 03:00 SGT
  settings.backups.cronMaxKeep = 14;
  settings.rateLimits.enabled = true;
  settings.batch.enabled = false;
  settings.logs.maxDays = 7;
  app.save(settings);
}, (app) => {
  // Settings are not rolled back.
});
