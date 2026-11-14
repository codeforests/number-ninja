import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/pin_repository.dart';
import 'package:number_ninja/domain/pin.dart';

void main() {
  late AppDatabase db;
  late DateTime now;
  PinRepository repo() =>
      PinRepository(db, clock: () => now, hasher: PinHasher(iterations: 10));

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2027, 1, 5, 9);
  });
  tearDown(() => db.close());

  Future<void> failTimes(PinRepository r, int n) async {
    for (var i = 0; i < n; i++) {
      await r.verify('0000');
    }
  }

  test(
    'no PIN on a fresh database; setPin stores only a salted hash',
    () async {
      final r = repo();
      expect(await r.hasPin(), isFalse);
      await r.setPin('2468');
      expect(await r.hasPin(), isTrue);
      final s = await db.select(db.appSettings).getSingle();
      expect(s.pinHash, isNot(contains('2468')));
      expect(s.pinSalt, isNotNull);
    },
  );

  test('rejects a PIN that is not 4 digits', () async {
    expect(() => repo().setPin('123'), throwsArgumentError);
  });

  test('right PIN is ok, wrong PIN reports attempts left', () async {
    final r = repo();
    await r.setPin('2468');
    expect(await r.verify('2468'), isA<PinOk>());
    final wrong = await r.verify('1111');
    expect(wrong, isA<PinWrong>());
    expect((wrong as PinWrong).attemptsLeft, 4);
  });

  test('five wrong PINs lock entry for 60 s, even for the right PIN', () async {
    final r = repo();
    await r.setPin('2468');
    await failTimes(r, 4);
    final fifth = await r.verify('0000');
    expect(fifth, isA<PinLocked>());
    expect((fifth as PinLocked).until, now.add(const Duration(seconds: 60)));
    now = now.add(const Duration(seconds: 30));
    expect(await r.verify('2468'), isA<PinLocked>());
    expect(await r.lockedUntil(), isNotNull);
  });

  test(
    'lockout survives a new repository on the same database (restart)',
    () async {
      await repo().setPin('2468');
      await failTimes(repo(), 5);
      expect(await repo().verify('2468'), isA<PinLocked>());
    },
  );

  test('after 60 s the right PIN works again', () async {
    final r = repo();
    await r.setPin('2468');
    await failTimes(r, 5);
    now = now.add(const Duration(seconds: 60));
    expect(await r.lockedUntil(), isNull);
    expect(await r.verify('2468'), isA<PinOk>());
  });

  test('a right PIN resets the failure count', () async {
    final r = repo();
    await r.setPin('2468');
    await failTimes(r, 3);
    await r.verify('2468');
    final wrong = await r.verify('0000') as PinWrong;
    expect(wrong.attemptsLeft, 4);
  });

  test('changePin needs the current PIN', () async {
    final r = repo();
    await r.setPin('2468');
    expect(await r.changePin('1111', '1357'), isA<PinWrong>());
    expect(await r.verify('2468'), isA<PinOk>());
    expect(await r.changePin('2468', '1357'), isA<PinOk>());
    expect(await r.verify('1357'), isA<PinOk>());
    expect(await r.verify('2468'), isA<PinWrong>());
  });
}
