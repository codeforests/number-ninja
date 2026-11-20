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

/// Links the children on this device that have no server record yet to the
/// account's children no device here is linked to (FEAT-25 AD-9, SYN-03).
/// [local] are (local id, nickname), [remote] (server id, nickname); the
/// result maps local id → server id. A nickname matches when equal after
/// trimming, ignoring case; if no nickname matched and each side has
/// exactly one child, they are the same child (a v2 family whose nickname
/// was typed differently on the second tablet). A child with no nickname
/// yet takes the account's first child left. The rest stay unmatched:
/// local ones are created on the server, remote ones added here.
Map<int, String> matchChildren(
  List<(int, String)> local,
  List<(String, String)> remote,
) {
  String key(String n) => n.trim().toLowerCase();
  final free = [...remote];
  final out = <int, String>{};
  for (final (id, name) in local) {
    if (key(name).isEmpty) continue;
    final i = free.indexWhere((r) => key(r.$2) == key(name));
    if (i >= 0) out[id] = free.removeAt(i).$1;
  }
  if (out.isEmpty && local.length == 1 && remote.length == 1) {
    out[local.single.$1] = remote.single.$1;
    return out;
  }
  // A child not filled in yet (a fresh tablet, AD-2) is the account's
  // first child left, so signing in doesn't add a blank sibling.
  for (final (id, name) in local) {
    if (key(name).isEmpty && free.isNotEmpty) out[id] = free.removeAt(0).$1;
  }
  return out;
}
