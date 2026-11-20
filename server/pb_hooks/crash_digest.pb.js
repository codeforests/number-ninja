/// <reference path="../pb_data/types.d.ts" />
// FEAT-24 (CRS-07, AD-12, AD-13): every day at 01:00 UTC (9 am Singapore)
// email CRASH_DIGEST_TO one line per crash signature seen in the last 24 h,
// then delete reports older than 90 days. No address set or no reports: no
// mail. CRASH_KEEP_DAYS is for the server tests only. Superusers can run it
// now with POST /api/crons/crash_digest. Handlers run in their own VM:
// everything they need is inside them.
cronAdd("crash_digest", "0 1 * * *", () => {
  const pbTime = (ms) => new Date(ms).toISOString().replace("T", " ");
  const esc = (s) =>
    String(s == null ? "" : s)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;");
  const now = Date.now();
  const to = ($os.getenv("CRASH_DIGEST_TO") || "").trim();

  if (to) {
    const rows = $app.findRecordsByFilter(
      "crash_reports",
      "created >= {:since}",
      "-created",
      1000,
      0,
      { since: pbTime(now - 24 * 3600 * 1000) },
    );
    const groups = {};
    for (const r of rows) {
      const sig = r.getString("signature");
      const g =
        groups[sig] ||
        (groups[sig] = {
          sig: sig,
          count: 0,
          versions: {},
          type: r.getString("error_type"),
          line: r.getString("message").split("\n")[0].slice(0, 200),
          screen: r.getString("screen"),
        });
      g.count += r.getInt("count");
      g.versions[r.getString("app_version")] = true;
    }
    const list = Object.keys(groups)
      .map((k) => groups[k])
      .sort((a, b) => b.count - a.count);
    if (list.length) {
      const total = list.reduce((n, g) => n + g.count, 0);
      const items = list
        .map(
          (g) =>
            "<li><b>" + g.count + " times</b> " + esc(g.type) + ": " + esc(g.line) +
            "<br>screen " + esc(g.screen || "-") + " · app " +
            esc(Object.keys(g.versions).join(", ")) + " · signature " +
            esc(g.sig.slice(0, 12)) + "</li>",
        )
        .join("");
      const meta = $app.settings().meta;
      $app.newMailClient().send(
        new MailerMessage({
          from: { address: meta.senderAddress, name: meta.senderName },
          to: [{ address: to }],
          subject: "BrainBubblz crash reports: " + total + " in the last 24 h",
          html:
            "<p>" + list.length + " kinds of error in the last 24 hours. " +
            "Details are in the admin under crash_reports.</p><ul>" + items + "</ul>",
        }),
      );
    }
  }

  const keepRaw = ($os.getenv("CRASH_KEEP_DAYS") || "").trim();
  const keepDays = keepRaw === "" ? 90 : Number(keepRaw);
  $app
    .db()
    .newQuery("DELETE FROM crash_reports WHERE created < {:cut}")
    .bind({ cut: pbTime(now - keepDays * 24 * 3600 * 1000) })
    .execute();
});
