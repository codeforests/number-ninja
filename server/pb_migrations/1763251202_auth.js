/// <reference path="../pb_data/types.d.ts" />
// FEAT-13: parent accounts (ACC-01..07). Secrets (SMTP, Google) are not
// here: pb_hooks/config.pb.js applies them from the environment on start.
const verifyBody = `<p>Hello,</p>
<p>Tap the link to confirm your email for {APP_NAME}:</p>
<p><a href="{APP_URL}/verify.html?token={TOKEN}">{APP_URL}/verify.html?token={TOKEN}</a></p>
<p>Then go back to the app and sign in. If you didn't create an account, ignore this email.</p>`;

const resetBody = `<p>Hello,</p>
<p>Tap the link to choose a new password for {APP_NAME}:</p>
<p><a href="{APP_URL}/reset.html?token={TOKEN}">{APP_URL}/reset.html?token={TOKEN}</a></p>
<p>If you didn't ask for this, ignore this email; your password stays the same.</p>`;

migrate((app) => {
  const users = app.findCollectionByNameOrId("users");
  users.fields.getByName("password").min = 8;
  users.authToken.duration = 30 * 24 * 60 * 60;
  users.passwordAuth.enabled = true;
  users.passwordAuth.identityFields = ["email"];
  users.oauth2.enabled = true;
  users.otp.enabled = false;
  users.mfa.enabled = false;
  users.authAlert.enabled = true;
  users.verificationTemplate.subject = "{APP_NAME}: confirm your email";
  users.verificationTemplate.body = verifyBody;
  users.resetPasswordTemplate.subject = "{APP_NAME}: reset your password";
  users.resetPasswordTemplate.body = resetBody;
  app.save(users);

  // An unverified account can't hold child data.
  const children = app.findCollectionByNameOrId("children");
  children.createRule =
    '@request.auth.id != "" && @request.auth.verified = true && @request.body.owner = @request.auth.id';
  app.save(children);
}, (app) => {
  const children = app.findCollectionByNameOrId("children");
  children.createRule = '@request.auth.id != "" && @request.body.owner = @request.auth.id';
  app.save(children);
});
