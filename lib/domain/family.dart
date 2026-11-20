/// Siblings on one tablet (FEAT-25, FAM-01..07).
library;

/// Most children a family keeps on one tablet (AD-1).
const maxChildren = 4;

/// Built-in avatar ids (AD-7), in the order new children get them. Icons
/// and colours for each are in `lib/ui/avatars.dart`.
const avatarIds = [
  'fox',
  'owl',
  'cat',
  'bear',
  'bunny',
  'frog',
  'panda',
  'tiger',
];

/// One child of the family, as lists and pickers show her.
class FamilyChild {
  const FamilyChild({
    required this.id,
    required this.nickname,
    required this.schoolYear,
    required this.avatar,
  });

  final int id;

  /// Empty until the parent fills in her profile (AD-2).
  final String nickname;
  final int schoolYear;
  final String avatar;

  @override
  bool operator ==(Object other) =>
      other is FamilyChild &&
      other.id == id &&
      other.nickname == nickname &&
      other.schoolYear == schoolYear &&
      other.avatar == avatar;

  @override
  int get hashCode => Object.hash(id, nickname, schoolYear, avatar);

  @override
  String toString() => 'FamilyChild($id, $nickname, P$schoolYear, $avatar)';
}

/// The name shown for the child at [index] (0-based) of the family: her
/// nickname, or "Player N" while it is empty (AD-2).
String displayName(String nickname, int index) =>
    nickname.trim().isEmpty ? 'Player ${index + 1}' : nickname.trim();

/// The first avatar no child in [taken] uses, or the first one when all are.
String nextAvatar(Iterable<String> taken) {
  final used = taken.toSet();
  return avatarIds.firstWhere(
    (a) => !used.contains(a),
    orElse: () => avatarIds.first,
  );
}
