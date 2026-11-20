# FEAT-20: steps only Ken can do

Do 1–4 before merging the PR (any order), 5–7 after. Each step says where.

## 1. DigitalOcean → Networking → Domains → brainbubblz.com

- **A record** `api` → the droplet's IP (the same IP as `api.brainbubblz.audiodenoiser.com`). Keep the old `api.brainbubblz` A record under audiodenoiser.com: the installed app (old app id) still uses it.
- Check from your computer: `nslookup api.brainbubblz.com` shows the droplet's IP.

## 2. Resend → Domains → Add domain `brainbubblz.com`

Resend then shows 3 or 4 records; add each at DigitalOcean (step 1's page) exactly as shown, host names without `.brainbubblz.com` and TXT values without quotes. They look like this (copy the real values from Resend; the DKIM key is yours alone, the region part may differ):

| Type | Host | Value | Priority |
|---|---|---|---|
| TXT | `resend._domainkey` | `p=MIGfMA0G…` (DKIM key) | |
| MX | `send` | `feedback-smtp.us-east-1.amazonses.com` | 10 |
| TXT | `send` | `v=spf1 include:amazonses.com ~all` | |
| TXT (optional, helps inboxes) | `_dmarc` | `v=DMARC1; p=none;` | |

Then press **Verify DNS records** in Resend and wait for "Verified" (minutes, sometimes an hour). The same API key works; nothing changes in `RESEND_API_KEY`.

## 3. Google Cloud console → APIs & Services (the BrainBubblz project)

- **Credentials** → the existing **Web application** OAuth client → Authorized redirect URIs → **add** `https://api.brainbubblz.com/signin/google`. Keep `https://api.brainbubblz.audiodenoiser.com/signin/google` until the old app is gone. Save.
- **OAuth consent screen** (Branding) → Authorized domains → add `brainbubblz.com`. If Google asks you to prove you own it, it links to Search Console, which gives a TXT record to add at DigitalOcean.
- No Android OAuth client is needed: sign-in runs in a browser tab through the server, so Google never sees the app id or the signing key.

## 4. GitHub → repo Settings → Secrets and variables → Actions

- Variable `SERVER_HOSTNAME` → `api.brainbubblz.com`
- New variable `SERVER_LEGACY_HOSTNAME` → `api.brainbubblz.audiodenoiser.com`
- Secret `MAIL_SENDER_ADDRESS` → `noreply@brainbubblz.com` (only once Resend says Verified, or emails stop)

## 5. After the merge: Actions → Deploy server → Run workflow

The log ends with "Legacy host … answers too" and "Deployed: https://api.brainbubblz.com/…". If certbot fails, an A record isn't pointing at the droplet yet; the old site is put back, so the installed app keeps working. If it fails on `daemon-reload`, check `df -h /run` on the droplet first.

## 6. Release APK v2.1.0 (Claude runs it on your go)

## 7. Switch the tablet to the new app

The new app id is a separate app (both icons say BrainBubblz), so data comes back through sync:

1. In the **old** app: parent area → Account, make sure you're signed in and it sync status shows a recent sync.
2. Install `brainbubblz-v2.1.0.apk`, set the PIN (it never leaves a device), sign in with the same account; her profile, progress, badges and settings come back.
3. When they're all there, uninstall the old one: Settings → Apps → the BrainBubblz showing version 2.0.1 → Uninstall.
4. Try "Forgot password" once: the email should come from noreply@brainbubblz.com with a link on api.brainbubblz.com. Try Google sign-in once too.

Later, when no device runs the old app: delete `SERVER_LEGACY_HOSTNAME`, run Deploy server, then on the droplet `sudo certbot delete --cert-name api.brainbubblz.audiodenoiser.com`, and remove the old redirect URI and A record.
