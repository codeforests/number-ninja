# Number Ninja server (FEAT-12)

PocketBase behind the droplet's existing nginx, set up only from this folder
(NFR-15). Never change collections or rules in the admin UI: add a migration
in `pb_migrations/` and redeploy.

| File | What it is |
|---|---|
| `VERSION` | Pinned PocketBase version and sha256 |
| `pb_migrations/` | Collections, API rules, indexes, settings (applied on deploy) |
| `pb_hooks/` | Server hooks (FEAT-13 adds the account ones) |
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
  `https://$SERVER_HOSTNAME/api/health` is 200 and `/_/` is 404.

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
