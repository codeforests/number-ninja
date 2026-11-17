/// <reference path="../pb_data/types.d.ts" />
// Email through Resend's HTTPS API when RESEND_API_KEY is set. DigitalOcean
// blocks outgoing SMTP (25, 465, 587) from the droplet, so the SMTP settings
// can't reach a mail server; HTTPS (443) is never blocked. Without the key,
// PocketBase sends over SMTP as before (config.pb.js). RESEND_API_URL is for
// the server tests only. Handlers run in their own VM: everything they need
// is inside them.
onMailerSend((e) => {
  const key = ($os.getenv("RESEND_API_KEY") || "").trim();
  if (!key) {
    e.next();
    return;
  }
  const url = ($os.getenv("RESEND_API_URL") || "").trim() || "https://api.resend.com/emails";
  const m = e.message;
  const named = (a) => (a.name ? a.name + " <" + a.address + ">" : a.address);
  const list = (as) => (as || []).map((a) => a.address);
  const body = {
    from: named(m.from),
    to: list(m.to),
    subject: m.subject,
    html: m.html,
  };
  if (m.text) body.text = m.text;
  if (m.cc && m.cc.length) body.cc = list(m.cc);
  if (m.bcc && m.bcc.length) body.bcc = list(m.bcc);

  const res = $http.send({
    url: url,
    method: "POST",
    headers: { "Content-Type": "application/json", Authorization: "Bearer " + key },
    body: JSON.stringify(body),
    timeout: 20,
  });
  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw new Error("Resend answered " + res.statusCode + ": " + toString(res.body));
  }
});
