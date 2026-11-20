import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/plus.dart';

final _t = DateTime.utc(2026, 11, 20, 9);

PlusCache _cache({
  bool plus = true,
  DateTime? until,
  Duration skew = Duration.zero,
  String? source = 'complimentary',
  String? status = 'active',
  bool willRenew = false,
}) => PlusCache(
  plus: plus,
  until: until ?? _t.add(const Duration(days: 30)),
  source: source,
  status: status,
  willRenew: willRenew,
  serverCheckedAt: _t.add(skew),
  deviceCheckedAt: _t,
  accountId: 'u1',
);

void main() {
  group('plusActive (AC-1)', () {
    test('no cache is free', () {
      expect(plusActive(null, _t), isFalse);
    });

    test('plus ahead, checked now is on', () {
      expect(plusActive(_cache(), _t), isTrue);
    });

    test('7 days + 1 min since the check is free', () {
      final c = _cache(until: _t.add(const Duration(days: 365)));
      expect(plusActive(c, _t.add(const Duration(days: 7))), isTrue);
      expect(
        plusActive(c, _t.add(const Duration(days: 7, minutes: 1))),
        isFalse,
      );
    });

    test('clock wound back 11 min before the check is free', () {
      expect(
        plusActive(_cache(), _t.subtract(const Duration(minutes: 9))),
        isTrue,
      );
      expect(
        plusActive(_cache(), _t.subtract(const Duration(minutes: 11))),
        isFalse,
      );
    });

    test('tablet 2 h slow: until 1 h ahead on the tablet is past on the '
        'server', () {
      final c = _cache(
        until: _t.add(const Duration(hours: 1)),
        skew: const Duration(hours: 2),
      );
      expect(plusActive(c, _t), isFalse);
      // The same until with no skew is on.
      expect(
        plusActive(_cache(until: _t.add(const Duration(hours: 1))), _t),
        isTrue,
      );
    });

    test('plus false is free', () {
      expect(plusActive(_cache(plus: false), _t), isFalse);
    });

    test('until reached is free', () {
      final c = _cache(until: _t.add(const Duration(hours: 1)));
      expect(plusActive(c, _t.add(const Duration(hours: 1))), isFalse);
    });
  });

  test('childLimit', () {
    expect(childLimit(false), 1);
    expect(childLimit(true), 4);
  });

  group('plusStatusLine (AC-6)', () {
    String line(PlusCache? c, [DateTime? now]) =>
        plusStatusLine(c, now ?? _t).status;

    test('free', () {
      expect(line(null), 'You are on the free plan.');
      expect(line(_cache(plus: false)), 'You are on the free plan.');
    });

    test('complimentary forever and dated', () {
      expect(
        line(_cache(until: DateTime.utc(2099, 12, 31, 23, 59))),
        'Plus, a gift from BrainBubblz',
      );
      expect(
        line(_cache(until: DateTime.utc(2027, 12, 31, 12))),
        'Plus until 31 Dec 2027',
      );
    });

    test('store renewing, ending, billing issue', () {
      final until = DateTime.utc(2027, 1, 5, 12);
      expect(
        line(_cache(source: 'google_play', willRenew: true, until: until)),
        'Plus, renews on 5 Jan 2027',
      );
      expect(
        line(_cache(source: 'google_play', status: 'cancelled', until: until)),
        'Plus, ends on 5 Jan 2027',
      );
      expect(
        line(
          _cache(source: 'app_store', status: 'billing_issue', until: until),
        ),
        'Plus: payment problem, check your store account',
      );
    });

    test('invitation; free after Plus ended (FEAT-36 AC-9)', () {
      expect(
        line(_cache(source: 'invite', until: DateTime.utc(2027, 11, 20, 12))),
        'Plus until 20 Nov 2027, from an invitation',
      );
      expect(
        line(
          PlusCache(
            plus: false,
            endedAt: DateTime.utc(2026, 10, 3, 12),
            serverCheckedAt: _t,
            deviceCheckedAt: _t,
            accountId: 'u1',
          ),
        ),
        'You are on the free plan. Plus ended on 3 Oct 2026.',
      );
    });

    test('offline grace says when it last checked', () {
      final c = _cache(until: DateTime.utc(2099, 12, 31));
      expect(plusStatusLine(c, _t).checked, isNull);
      expect(
        plusStatusLine(c, _t.add(const Duration(days: 3, hours: 1))).checked,
        'Last checked 3 days ago',
      );
    });
  });

  group('invitation codes (FEAT-36 IC-1)', () {
    test('normalise drops spaces, dashes and look-alikes', () {
      expect(normaliseInviteCode(' abcd-efgh '), 'ABCDEFGH');
      expect(normaliseInviteCode('AB0O-1IGH'), 'ABGH');
      expect(inviteCodeComplete('abcd efgh'), isTrue);
      expect(inviteCodeComplete('ABCD-EFG'), isFalse);
      expect(inviteCodeComplete('ABCD-EFG0'), isFalse);
      expect(inviteCodeComplete('ABCD-EFGHJ'), isFalse);
    });
  });
}
