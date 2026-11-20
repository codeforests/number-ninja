/// <reference path="../pb_data/types.d.ts" />
// FEAT-29: GET /api/nn/entitlement (ENT-03, AD-5) tells a signed-in parent
// whether they have Plus; POST /api/nn/billing/revenuecat (ENT-04, AD-6..8)
// takes RevenueCat webhook events. The webhook is off (503) until
// BILLING_WEBHOOK_SECRET is set (FEAT-35); the Authorization header must
// equal it exactly. Logic lives in lib/entitlements.js.
routerAdd("GET", "/api/nn/entitlement", (e) => {
  const lib = require(`${__hooks}/lib/entitlements.js`);
  return e.json(200, lib.activeEntitlement(e.app, e.auth.id, Date.now()));
}, $apis.requireAuth("users"));

routerAdd("POST", "/api/nn/billing/revenuecat", (e) => {
  const secret = $os.getenv("BILLING_WEBHOOK_SECRET");
  if (!secret) {
    return e.json(503, { message: "Billing webhook is not configured." });
  }
  if (e.request.header.get("Authorization") !== secret) {
    throw new UnauthorizedError("Wrong webhook secret.");
  }
  const lib = require(`${__hooks}/lib/entitlements.js`);
  return e.json(200, lib.applyEvent(e.app, e.requestInfo().body, Date.now()));
});
