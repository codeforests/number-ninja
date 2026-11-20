// FEAT-31: the weekly progress email (WEM-02..06; design WE-1, WE-3..WE-11).
// Loaded with require() inside each handler (JSVM rule). `run` is what the
// hourly cron and the admin route call; the clock is a parameter (NFR-08).
const DAY = 24 * 3600 * 1000;
const HOUR = 3600 * 1000;
const MAX_SENDS = 200;
const KEEP_DAYS = 180;
const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

const pbTime = (ms) => new Date(ms).toISOString().replace("T", " ");
const ms = (s) => (s ? Date.parse(String(s).replace(" ", "T")) : NaN);
const ymd = (localMs) => new Date(localMs).toISOString().slice(0, 10);
const esc = (s) =>
  String(s == null ? "" : s)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");

// WE-4/WE-5: the week before the family's current local Monday. Local times
// are UTC milliseconds shifted by the offset; *Ms fields are real UTC.
function weekBounds(nowMs, tzMin) {
  const shift = (tzMin || 0) * 60000;
  const local = nowMs + shift;
  const today = Math.floor(local / DAY) * DAY;
  const sinceMonday = (new Date(today).getUTCDay() + 6) % 7;
  const monday = today - sinceMonday * DAY;
  const start = monday - 7 * DAY;
  const intoWeek = local - monday;
  return {
    week: ymd(start),
    days: [0, 1, 2, 3, 4, 5, 6].map((i) => ymd(start + i * DAY)),
    startMs: start - shift,
    endMs: monday - shift,
    prevStartMs: start - 7 * DAY - shift,
    label: rangeLabel(start, monday - DAY),
    due: intoWeek >= 8 * HOUR && intoWeek < 2 * DAY + 8 * HOUR,
  };
}

function rangeLabel(a, b) {
  const da = new Date(a);
  const db = new Date(b);
  const left = da.getUTCMonth() === db.getUTCMonth() ? String(da.getUTCDate()) : da.getUTCDate() + " " + MONTHS[da.getUTCMonth()];
  return left + "–" + db.getUTCDate() + " " + MONTHS[db.getUTCMonth()];
}

function all(app, collection, filter, params) {
  return app.findRecordsByFilter(collection, filter, "", 0, 0, params);
}

function between(app, collection, field, childId, fromMs, toMs) {
  return all(app, collection, "child = {:c} && " + field + " >= {:a} && " + field + " < {:b}", {
    c: childId,
    a: pbTime(fromMs),
    b: pbTime(toMs),
  });
}

// WE-7: one child's week.
function childSummary(app, child, b) {
  const names = require(`${__hooks}/lib/names.js`);
  const id = child.id;
  const usage = all(app, "daily_usage", "child = {:c} && day >= {:a} && day <= {:b}", {
    c: id,
    a: b.days[0],
    b: b.days[6],
  });
  const perDay = {};
  let seconds = 0;
  for (const u of usage) {
    const s = u.getInt("seconds_used");
    seconds += s;
    perDay[u.getString("day")] = (perDay[u.getString("day")] || 0) + s;
  }
  const days = Object.keys(perDay).filter((d) => perDay[d] > 0).length;

  const rounds = between(app, "rounds", "finished_at", id, b.startMs, b.endMs);
  const revision = rounds.filter((r) => r.getString("kind") === "revision").length;

  const attempts = between(app, "attempts", "answered_at", id, b.startMs, b.endMs);
  const right = attempts.filter((a) => a.getBool("correct")).length;
  const prev = between(app, "attempts", "answered_at", id, b.prevStartMs, b.startMs);
  const prevRight = prev.filter((a) => a.getBool("correct")).length;

  const byTopic = {};
  for (const a of attempts) {
    const topic = a.getString("question_id").split(".").slice(0, 2).join(".");
    const t = byTopic[topic] || (byTopic[topic] = { n: 0, right: 0 });
    t.n += 1;
    if (a.getBool("correct")) t.right += 1;
  }
  const weak = Object.keys(byTopic)
    .map((k) => ({ id: k, n: byTopic[k].n, pct: Math.round((100 * byTopic[k].right) / byTopic[k].n) }))
    .filter((t) => t.n >= 5 && t.pct < 80)
    .sort((x, y) => x.pct - y.pct || y.n - x.n || (x.id < y.id ? -1 : 1))
    .slice(0, 3)
    .map((t) => ({ name: names.TOPICS[t.id] || t.id, pct: t.pct }));

  const badges = between(app, "badges", "earned_at", id, b.startMs, b.endMs)
    .map((r) => ({ at: r.getString("earned_at"), name: names.BADGES[r.getString("badge_id")] || r.getString("badge_id") }))
    .sort((x, y) => (x.at < y.at ? -1 : x.at > y.at ? 1 : 0))
    .map((x) => x.name);

  return {
    nickname: child.getString("nickname"),
    seconds: seconds,
    days: days,
    rounds: rounds.length,
    revision: revision,
    questions: attempts.length,
    pct: attempts.length ? Math.round((100 * right) / attempts.length) : null,
    prevPct: prev.length >= 10 ? Math.round((100 * prevRight) / prev.length) : null,
    weak: weak,
    badges: badges,
    idle: seconds === 0 && rounds.length === 0 && attempts.length === 0,
  };
}

function duration(seconds) {
  const min = Math.floor(seconds / 60);
  if (min < 1) return "less than a minute";
  const h = Math.floor(min / 60);
  const m = min % 60;
  if (!h) return m + " min";
  return m ? h + " h " + m + " min" : h + " h";
}

const plural = (n, one, many) => n + " " + (n === 1 ? one : many);

function childLines(s) {
  if (s.idle) return ["No practice this week."];
  const lines = [];
  lines.push("Practised " + duration(s.seconds) + (s.days ? " on " + plural(s.days, "day", "days") : ""));
  lines.push(plural(s.rounds, "round", "rounds") + (s.revision ? " (" + s.revision + " revision)" : ""));
  if (s.questions) {
    lines.push(
      plural(s.questions, "question", "questions") + ", " + s.pct + "% right" +
        (s.prevPct == null ? "" : " (" + s.prevPct + "% the week before)"),
    );
  }
  lines.push(
    s.weak.length
      ? "Topics to practise: " + s.weak.map((t) => t.name + " (" + t.pct + "%)").join(", ")
      : "No weak spots this week.",
  );
  if (s.badges.length) lines.push("New badges: " + s.badges.join(", "));
  return lines;
}

function turnOffUrl(app, user) {
  const base = String(app.settings().meta.appURL || "").replace(/\/+$/, "");
  return base + "/api/nn/weekly-email/off?u=" + encodeURIComponent(user.id) + "&t=" + encodeURIComponent(user.getString("email_token"));
}

// WE-10: the turn-off token, made the first time an email is built.
function ensureToken(app, user) {
  if (user.getString("email_token").length === 32) return;
  user.set("email_token", $security.randomString(32));
  app.save(user);
}

// WE-1/WE-9: one email for the family. `empty` when no child practised.
function buildEmail(app, user, b) {
  const kids = all(app, "children", "owner = {:u}", { u: user.id }).sort((x, y) =>
    x.getString("created") < y.getString("created") ? -1 : 1,
  );
  const sums = kids.map((k) => childSummary(app, k, b));
  const empty = sums.every((s) => s.idle);
  const who = sums.length === 1 ? sums[0].nickname + "'s week" : "your children's week";
  const subject = "BrainBubblz: " + who + " (" + b.label + ")";
  const url = turnOffUrl(app, user);
  const p = 'style="margin:0 0 12px"';
  const blocks = sums
    .map(
      (s) =>
        '<h2 style="font-size:18px;margin:20px 0 6px">' + esc(s.nickname) + "</h2>" +
        '<ul style="margin:0 0 12px;padding-left:20px">' +
        childLines(s).map((l) => "<li>" + esc(l) + "</li>").join("") +
        "</ul>",
    )
    .join("");
  const html =
    '<div style="font-family:Arial,Helvetica,sans-serif;font-size:15px;line-height:1.5;color:#222;max-width:560px">' +
    '<h1 style="font-size:20px;margin:0 0 4px">Practice this week</h1>' +
    "<p " + p + ">Monday to Sunday, " + esc(b.label) + ".</p>" +
    blocks +
    "<p " + p + ">Open the parent area in BrainBubblz for the day-by-day view.</p>" +
    '<p style="margin:24px 0 0;font-size:12px;color:#666">You get this email because the weekly progress email is on for this BrainBubblz account. ' +
    'Turn it off in the app (Parent area → Account) or <a href="' + esc(url) + '">turn off weekly emails</a>.</p>' +
    "</div>";
  return { subject: subject, html: html, url: url, children: sums.length, empty: empty };
}

function send(app, user, mail) {
  const meta = app.settings().meta;
  app.newMailClient().send(
    new MailerMessage({
      from: { address: meta.senderAddress, name: meta.senderName },
      to: [{ address: user.email() }],
      subject: mail.subject,
      html: mail.html,
      headers: {
        "List-Unsubscribe": "<" + mail.url + ">",
        "List-Unsubscribe-Post": "List-Unsubscribe=One-Click",
      },
    }),
  );
}

function logged(app, userId, week) {
  try {
    app.findFirstRecordByFilter("weekly_emails", "user = {:u} && week = {:w}", { u: userId, w: week });
    return true;
  } catch (_) {
    return false;
  }
}

function log(app, userId, week, status, children) {
  const col = app.findCollectionByNameOrId("weekly_emails");
  const r = new Record(col);
  r.set("user", userId);
  r.set("week", week);
  r.set("status", status);
  r.set("children", children);
  app.save(r);
}

// WE-3/WE-5/WE-11: send what is due at `nowMs`. `onlyUser` limits it to one
// account (admin route).
function run(app, nowMs, onlyUser) {
  const ent = require(`${__hooks}/lib/entitlements.js`);
  const out = { sent: 0, skipped: 0, failed: 0, notDue: 0 };
  const filter = "weekly_email = true && verified = true" + (onlyUser ? " && id = {:id}" : "");
  const users = all(app, "users", filter, { id: onlyUser || "" });
  for (const u of users) {
    const b = weekBounds(nowMs, u.getInt("weekly_email_tz"));
    if (!b.due || logged(app, u.id, b.week)) {
      out.notDue += 1;
      continue;
    }
    if (!ent.activeEntitlement(app, u.id, nowMs).plus) {
      out.notDue += 1;
      continue;
    }
    if (out.sent >= MAX_SENDS) break;
    try {
      ensureToken(app, u);
      const mail = buildEmail(app, u, b);
      if (mail.empty) {
        log(app, u.id, b.week, "skipped", mail.children);
        out.skipped += 1;
        continue;
      }
      send(app, u, mail);
      log(app, u.id, b.week, "sent", mail.children);
      out.sent += 1;
    } catch (err) {
      out.failed += 1;
      app.logger().error("weekly email failed", "user", u.id, "error", String(err));
    }
  }
  app
    .db()
    .newQuery("DELETE FROM weekly_emails WHERE created < {:cut}")
    .bind({ cut: pbTime(nowMs - KEEP_DAYS * DAY) })
    .execute();
  return out;
}

// WE-11: the email the account would get for the week before `nowMs`.
function preview(app, userId, nowMs) {
  const u = app.findRecordById("users", userId);
  ensureToken(app, u);
  const mail = buildEmail(app, u, weekBounds(nowMs, u.getInt("weekly_email_tz")));
  return { subject: mail.subject, html: mail.html, empty: mail.empty, children: mail.children };
}

function sameText(a, b) {
  a = String(a || "");
  b = String(b || "");
  let diff = a.length ^ b.length;
  for (let i = 0; i < Math.max(a.length, b.length); i++) diff |= (a.charCodeAt(i) || 0) ^ (b.charCodeAt(i) || 0);
  return diff === 0;
}

// WE-10: true when the token matches and the switch is now off.
function turnOff(app, userId, token) {
  if (!userId || !token || String(token).length !== 32) return false;
  let u;
  try {
    u = app.findRecordById("users", String(userId));
  } catch (_) {
    return false;
  }
  if (!sameText(u.getString("email_token"), token)) return false;
  if (u.getBool("weekly_email")) {
    u.set("weekly_email", false);
    app.save(u);
  }
  return true;
}

// WE-10: the small page behind the turn-off link.
function offPage(title, text, form) {
  return (
    '<!doctype html><html lang="en"><head><meta charset="utf-8">' +
    '<meta name="viewport" content="width=device-width, initial-scale=1"><title>BrainBubblz</title></head>' +
    '<body style="font-family:Arial,Helvetica,sans-serif;max-width:480px;margin:40px auto;padding:0 16px;line-height:1.5">' +
    "<h1 style=\"font-size:22px\">" + esc(title) + "</h1><p>" + esc(text) + "</p>" +
    (form
      ? '<form method="post"><button type="submit" style="font-size:18px;padding:10px 20px">Turn off weekly emails</button></form>'
      : "") +
    "</body></html>"
  );
}

module.exports = { offPage, weekBounds, childSummary, buildEmail, run, preview, turnOff, duration };
