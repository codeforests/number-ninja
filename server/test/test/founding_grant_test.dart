// FEAT-29 AC-7 (ENT-06, AD-10): accounts that exist when the entitlements
// migration runs get Plus with no end; later accounts start free.
// server/test/run.sh runs this twice on one data dir: PB_FOUNDING_PHASE=seed
// against a PocketBase migrated only up to 1763251207, then
// PB_FOUNDING_PHASE=check after the restart applies 1763251208.
import 'dart:io';

import 'package:number_ninja_server_test/fixtures.dart';
import 'package:test/test.dart';

final phase = Platform.environment['PB_FOUNDING_PHASE'];
const founders = ['founder-1@test.local', 'founder-2@test.local'];

void main() {
  test('seed: accounts before the migration', () async {
    final su = await superuser();
    expect(
      await statusOf(() => su.collection('entitlements').getList()),
      404,
      reason: 'the entitlements migration has not run yet',
    );
    for (final email in founders) {
      await su
          .collection('users')
          .create(
            body: {
              'email': email,
              'password': 'parent-password-1',
              'passwordConfirm': 'parent-password-1',
              'verified': true,
            },
          );
    }
  }, skip: phase == 'seed' ? false : 'PB_FOUNDING_PHASE is not seed');

  test('check: founders have one FOREVER grant; a new account none', () async {
    final su = await superuser();
    for (final email in founders) {
      final u = await su
          .collection('users')
          .getFirstListItem('email = "$email"');
      final rs = await su
          .collection('entitlements')
          .getFullList(filter: 'user = "${u.id}"');
      expect(rs, hasLength(1));
      final r = rs.single;
      expect(r.getStringValue('source'), 'complimentary');
      expect(r.getStringValue('status'), 'active');
      expect(r.getStringValue('expires_at'), startsWith('2099-12-31 23:59:59'));
      expect(r.getStringValue('note'), 'founding family (FEAT-29)');
    }
    final later = await Parent.signUp('later');
    expect(
      await su
          .collection('entitlements')
          .getFullList(filter: 'user = "${later.id}"'),
      isEmpty,
    );
  }, skip: phase == 'check' ? false : 'PB_FOUNDING_PHASE is not check');
}
