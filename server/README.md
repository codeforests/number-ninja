# Number Ninja server (FEAT-12)

PocketBase behind the droplet's existing nginx, set up only from this folder
(NFR-15). Never change collections or rules in the admin UI: add a migration
in `pb_migrations/` and redeploy.

| File | What it is |
|---|---|
| `VERSION` | Pinned PocketBase version and sha256 |
| `pb_migrations/` | Collections, API rules, indexes, settings (applied on deploy) |
| `pb_hooks/config.pb.js` | Applies email (SMTP) and Google sign-in settings from the environment on every start (FEAT-13) |
| `pb_public/` | `verify.html`, `reset.html`: the pages the account emails link to (FEAT-13) |
| `nginx/numberninja.conf.template` | The one nginx site this server adds |
| `numberninja-pb.service` | systemd unit, PocketBase on `127.0.0.1:8090` |
| `deploy.sh` | Copies this folder to the droplet and runs `install.sh` |
| `install.sh` | Runs on the droplet as root; idempotent (re-run = upgrade) |
| `restore.sh` | Restores a backup zip |
| `test/` | API rule and backup tests; `test/run.sh` (CI job `server`) |

The hostname lives only in the repo variable `SERVER_HOSTNAME`. Short term
`api.brainbubblz.audiodenoiser.com`; to move to `api.brainbubblz.com` later,
change the variable, add its A record, run the deploy and rebuild the APK.

## One-time setup (Ken, about 15 minutes)

The A record for `api.brainbubblz.audiodenoiser.com` is done. On your computer:

1. Make a deploy key (no passphrase):
   `ssh-keygen -t ed25519 -f numberninja_deploy -N "" -C numberninja-deploy`
2. On the droplet, as root, make a deploy user that can sudo without a password:
   ```sh
   adduser --disabled-password --gecos "" deploy
   echo 'deploy ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/deploy && chmod 0440 /etc/sudoers.d/deploy
   install -d -m 0700 -o deploy -g deploy /home/deploy/.ssh
   # paste the contents of numberninja_deploy.pub into:
   nano /home/deploy/.ssh/authorized_keys
   chown deploy:deploy /home/deploy/.ssh/authorized_keys && chmod 0600 /home/deploy/.ssh/authorized_keys
   ```
3. Get the droplet's host key line, from your computer: `ssh-keyscan -t ed25519 <droplet IP>`
4. In GitHub, the repo's Settings → Secrets and variables → Actions:
   - Secrets: `DEPLOY_HOST` (droplet IP), `DEPLOY_USER` (`deploy`), `DEPLOY_SSH_KEY`
     (the whole `numberninja_deploy` file), `DEPLOY_KNOWN_HOSTS` (the line from step 3),
     `PB_SUPERUSER_EMAIL`, `PB_SUPERUSER_PASSWORD` (a new, long password; at least 10
     characters), optionally `CERT_EMAIL` (Let's Encrypt notices; defaults to the
     superuser email).
   - Variable: `SERVER_HOSTNAME` = `api.brainbubblz.audiodenoiser.com`.

Ports 80 and 443 are already open for audiodenoiser.com, so the firewall needs nothing.

## Email and Google sign-in (FEAT-13, Ken, about 20 minutes)

Both are optional: without these secrets the server deploys and works, but
sign-up emails aren't sent and the app hides "Sign in with Google". Add them,
then run "Deploy server" again; nothing else changes.

**Email (Resend over HTTPS, the one in use).** DigitalOcean blocks the usual
mail ports (25, 465 and 587; Gmail SMTP can't work), so the server sends
through Resend's web API on port 443 (`pb_hooks/mail.pb.js`). It wins over the
SMTP settings below when both are set.

1. Sign up at resend.com and create an API key (sending access).
2. Domains → add `audiodenoiser.com` (or the domain you send from) and add the
   DNS records it shows. Until a domain is verified, Resend only sends from
   `onboarding@resend.dev` and only to your own account's email.
3. Repo secrets: `RESEND_API_KEY` = the key, `MAIL_SENDER_ADDRESS` = an address
   on the verified domain (e.g. `noreply@audiodenoiser.com`). Run "Deploy server";
   the log says `Email: on-resend`.

**Email (Brevo SMTP, the alternative, free plan, 300 emails/day).** This uses
Brevo's port 2525, which DigitalOcean doesn't block.

1. Sign up at brevo.com. Under Senders, domains & dedicated IPs → Senders, add the
   address the emails come from (e.g. your Gmail or `noreply@audiodenoiser.com`) and
   confirm it from its inbox. (Authenticating the domain with its DNS records is
   better for spam filters, but not required.)
2. Under SMTP & API → SMTP, create an SMTP key. Note the login shown there.
3. Repo secrets: `SMTP_HOST` = `smtp-relay.brevo.com`, `SMTP_PORT` = `2525`,
   `SMTP_USERNAME` = the SMTP login, `SMTP_PASSWORD` = the SMTP key,
   `MAIL_SENDER_ADDRESS` = the sender from step 1.

**Google sign-in.**

1. console.cloud.google.com → create a project (e.g. "BrainBubblz").
2. APIs & Services → OAuth consent screen: External, app name, your email as support
   and developer contact; scopes `email` and `profile` only. Publish it (or add your
   own Google account as a test user while it's in testing).
3. APIs & Services → Credentials → Create credentials → OAuth client ID →
   **Web application** (not Android). Authorized redirect URI:
   `https://api.brainbubblz.audiodenoiser.com/signin/google` (use the
   `SERVER_HOSTNAME` value; add the new one if the hostname changes). That nginx
   page hands the result back to the app. PocketBase's own
   `/api/oauth2-redirect` isn't used: it needs the app's realtime connection to
   stay open while the parent is in the browser, and some networks cut quiet
   connections after about a minute.
4. Repo secrets: `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`.

The deploy log prints `Email: on|off, Google sign-in: on|off`. The secrets end up
in `/etc/default/numberninja-pb` on the droplet (root only, mode 600).

## Deploy

GitHub → Actions → "Deploy server" → Run workflow. It:

- installs `certbot` if missing, creates the `numberninja` user and `/opt/numberninja`;
- downloads the pinned PocketBase and checks its sha256;
- adds `/etc/nginx/sites-available/numberninja.conf` (and its `sites-enabled` link) and
  nothing else in nginx. It runs `nginx -t` before every reload; if the test fails it
  undoes its own change, so audiodenoiser.com keeps working;
- on the first run, gets a Let's Encrypt certificate (webroot, renewed by certbot's timer,
  which reloads nginx);
- applies the migrations, sets the superuser, restarts PocketBase, and checks that
  `https://$SERVER_HOSTNAME/api/health` is 200, `/_/` is the Google sign-in result page and the admin UI's files under `/_/` are 404.

## Publishing a bank (FEAT-15)

The generator is the only source of questions (D11). To ship new or changed questions:

1. Change the templates in `tool/bank/`, bump `bankVersion` in `tool/bank/bank.dart`, run `dart run tool/generate_bank.dart` and merge the PR. Never delete a question id: list it in `tool/bank/retired.dart` instead (BNK-10).
2. Actions → **Publish bank** → Run workflow on `main` (tick *dry run* first if you like). It refuses a bank that fails the validator, differs from the committed `assets/questions/bank.json`, isn't a higher version than the latest published one, or drops an id of the latest published bank or of the newest release's bundled bank.
3. Tablets pick it up at their next launch or resume (at most once a day; "Check now" in the parent area forces it) and switch before the next round.

A bank that needs a newer app (new topic, visual kind or question format) also bumps `format` and `bankFormatSupported` in the same release; older apps then ignore it (BNK-11). A published bank can be deleted in the admin UI; the apps keep whatever they already downloaded.

## Admin UI (through an SSH tunnel only)

`ssh -L 8090:127.0.0.1:8090 deploy@<droplet IP>`, then open `http://localhost:8090/_/`
and sign in with the superuser email and password.

## Backups and restore

PocketBase makes a backup every day at 03:00 Singapore time and keeps 14
(`/opt/numberninja/pb_data/backups/`). To restore one on the droplet:

```sh
sudo ls /opt/numberninja/pb_data/backups/
sudo bash /path/to/repo/server/restore.sh /opt/numberninja/pb_data/backups/<name>.zip
```

It stops PocketBase, keeps the current data as `pb_data.before-restore-<time>`,
restores the zip, starts PocketBase and checks health. (Copy `restore.sh` to the
droplet first, or use the copy a deploy leaves at `/opt/numberninja/restore.sh`.)

## Local and CI tests

`server/test/run.sh` starts the pinned PocketBase (`scripts/server-local.sh`),
runs the API rule tests and a backup, restores the backup into a second
PocketBase with `restore.sh` and checks it.
