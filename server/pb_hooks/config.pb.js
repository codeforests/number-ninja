/// <reference path="../pb_data/types.d.ts" />
// FEAT-13: server settings from the environment on every start, so secrets
// added later and a hostname change take effect on the next deploy (a
// migration runs only once). Missing values leave the feature off.
//   SERVER_HOSTNAME                     -> meta.appURL (links in emails)
//   SMTP_HOST SMTP_PORT SMTP_USERNAME SMTP_PASSWORD MAIL_SENDER_ADDRESS -> email
//   GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET -> Google sign-in on `users`
onBootstrap((e) => {
  e.next();

  const env = (key) => ($os.getenv(key) || "").trim();
  const app = e.app;

  const settings = app.settings();
  let changed = false;
  const set = (obj, key, value) => {
    if (obj[key] !== value) {
      obj[key] = value;
      changed = true;
    }
  };

  const host = env("SERVER_HOSTNAME");
  if (host) set(settings.meta, "appURL", "https://" + host);

  const smtpHost = env("SMTP_HOST");
  const sender = env("MAIL_SENDER_ADDRESS");
  const smtpOn = !!(smtpHost && sender);
  set(settings.smtp, "enabled", smtpOn);
  if (smtpOn) {
    const port = parseInt(env("SMTP_PORT") || "2525", 10);
    set(settings.smtp, "host", smtpHost);
    set(settings.smtp, "port", port);
    set(settings.smtp, "username", env("SMTP_USERNAME"));
    set(settings.smtp, "password", env("SMTP_PASSWORD"));
    // 2525/587 use STARTTLS; only 465 is TLS from the start.
    set(settings.smtp, "tls", port === 465);
    set(settings.meta, "senderAddress", sender);
    set(settings.meta, "senderName", settings.meta.appName);
  }
  if (changed) app.save(settings);

  const users = app.findCollectionByNameOrId("users");
  const id = env("GOOGLE_CLIENT_ID");
  const secret = env("GOOGLE_CLIENT_SECRET");
  const current = users.oauth2.providers.filter((p) => p.name === "google");
  const want = id && secret;
  const same = want
    ? current.length === 1 && current[0].clientId === id && current[0].clientSecret === secret
    : current.length === 0;
  if (!same) {
    const others = users.oauth2.providers.filter((p) => p.name !== "google");
    users.oauth2.providers = want
      ? others.concat([{ name: "google", clientId: id, clientSecret: secret }])
      : others;
    app.save(users);
  }

  console.log(
    "config: email " + (smtpOn ? "on" : "off") + ", google " + (want ? "on" : "off"),
  );
});
