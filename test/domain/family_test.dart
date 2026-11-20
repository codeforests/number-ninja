import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/family.dart';

void main() {
  test('an empty nickname shows as Player N (FEAT-25 AD-2)', () {
    expect(displayName('', 0), 'Player 1');
    expect(displayName('  ', 2), 'Player 3');
    expect(displayName(' Mia ', 0), 'Mia');
  });

  test('new children get the first unused avatar (AD-7)', () {
    expect(nextAvatar([]), avatarIds.first);
    expect(nextAvatar(['fox', 'cat']), 'owl');
    expect(nextAvatar(avatarIds), avatarIds.first);
    expect(avatarIds.toSet(), hasLength(avatarIds.length));
    expect(avatarIds.length, greaterThanOrEqualTo(maxChildren));
  });

  group('matchChildren (AD-9)', () {
    test('same nickname, trimmed and ignoring case', () {
      expect(
        matchChildren(
          [(1, 'mia '), (2, 'Leo')],
          [('r1', 'Leo'), ('r2', 'Mia')],
        ),
        {1: 'r2', 2: 'r1'},
      );
    });

    test('one and one with different nicknames merge', () {
      expect(matchChildren([(1, 'Mimi')], [('r1', 'Mia')]), {1: 'r1'});
      expect(matchChildren([(1, '')], [('r1', 'Mia')]), {1: 'r1'});
    });

    test('no merge by count once a nickname matched or with more children', () {
      expect(
        matchChildren([(1, 'Mia'), (2, 'Ana')], [('r1', 'Mia'), ('r2', 'Leo')]),
        {1: 'r1'},
      );
      expect(matchChildren([(1, 'Ana'), (2, 'Bo')], [('r1', 'Leo')]), isEmpty);
      expect(
        matchChildren([(1, 'Ana')], [('r1', 'Leo'), ('r2', 'Mia')]),
        isEmpty,
      );
      expect(matchChildren([], [('r1', 'Leo')]), isEmpty);
      expect(matchChildren([(1, 'Leo')], []), isEmpty);
    });

    test('a child with no nickname yet takes the first child left', () {
      expect(matchChildren([(1, '')], [('r1', 'Mia'), ('r2', 'Leo')]), {
        1: 'r1',
      });
      expect(
        matchChildren([(1, ''), (2, 'Leo')], [('r1', 'Mia'), ('r2', 'Leo')]),
        {1: 'r1', 2: 'r2'},
      );
    });

    test('each server child matches once', () {
      expect(matchChildren([(1, 'Leo'), (2, 'leo')], [('r1', 'Leo')]), {
        1: 'r1',
      });
    });
  });
}
