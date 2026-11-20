import 'report.dart' show reportDate;

/// BrainBubblz Plus on the device (FEAT-30, PLS-01..08, ADR-10).

/// Offline grace after the last good server check (PD-4).
const plusGrace = Duration(days: 7);

/// How far the clock may go back before the last check (PD-4).
const plusClockBack = Duration(minutes: 10);

/// Children a family can have on free and with Plus (PD-7).
int childLimit(bool plus) => plus ? 4 : 1;

/// The cached answer of `GET /api/nn/entitlement` (PD-3, FEAT-29 AD-5).
class PlusCache {
  const PlusCache({
    required this.plus,
    required this.serverCheckedAt,
    required this.deviceCheckedAt,
    required this.accountId,
    this.until,
    this.source,
    this.status,
    this.willRenew = false,
    this.endedAt,
  });

  final bool plus;
  final DateTime? until;

  /// `complimentary`, `google_play`, `app_store` or null.
  final String? source;

  /// `active`, `cancelled`, `billing_issue`, ... or null.
  final String? status;
  final bool willRenew;
  final DateTime? endedAt;

  /// The server's `checked_at`.
  final DateTime serverCheckedAt;

  /// The device clock when that answer arrived.
  final DateTime deviceCheckedAt;
  final String accountId;

  /// The server's clock minus the device's at the check.
  Duration get skew => serverCheckedAt.difference(deviceCheckedAt);

  /// A FOREVER grant (FEAT-29: `2099-12-31`).
  bool get forever => until != null && until!.year >= 2099;
}

/// Whether Plus is on at [now] (PD-4). The clock is a parameter (NFR-08).
bool plusActive(PlusCache? cache, DateTime now) {
  if (cache == null || !cache.plus || cache.until == null) return false;
  if (now.isBefore(cache.deviceCheckedAt.subtract(plusClockBack))) {
    return false;
  }
  if (now.difference(cache.deviceCheckedAt) > plusGrace) return false;
  return now.add(cache.skew).isBefore(cache.until!);
}

/// The features that need Plus (PD-1). Everything else is free.
enum PlusFeature { revision, pdfReport, dayView, trends, bankUpdates, siblings }

/// Whether [feature] is open. Every feature in [PlusFeature] needs Plus; a
/// later split change is a line here.
bool plusFeature(PlusFeature feature, bool active) => active;

/// SCR-20's status line and, when the last check is a day or more old, a
/// "last checked" line (PD-9).
({String status, String? checked}) plusStatusLine(
  PlusCache? cache,
  DateTime now,
) {
  if (!plusActive(cache, now)) {
    return (status: 'You are on the free plan.', checked: _checked(cache, now));
  }
  final c = cache!;
  final date = reportDate(c.until!.toLocal());
  final String status;
  if (c.source == 'complimentary') {
    status = c.forever ? 'Plus, a gift from BrainBubblz' : 'Plus until $date';
  } else if (c.status == 'billing_issue') {
    status = 'Plus: payment problem, check your store account';
  } else if (c.willRenew) {
    status = 'Plus, renews on $date';
  } else {
    status = 'Plus, ends on $date';
  }
  return (status: status, checked: _checked(c, now));
}

String? _checked(PlusCache? cache, DateTime now) {
  if (cache == null) return null;
  final days = now.difference(cache.deviceCheckedAt).inDays;
  if (days < 1) return null;
  return days == 1 ? 'Last checked 1 day ago' : 'Last checked $days days ago';
}
