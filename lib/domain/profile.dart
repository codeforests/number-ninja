/// The child profile and the start-level rule (PRO-01, PRO-03, D13).
library;

import 'progress.dart';
import 'topics.dart';

/// School years a profile can hold: P1 to P6.
const schoolYears = [1, 2, 3, 4, 5, 6];

/// Longest nickname, in characters after trimming.
const maxNicknameLength = 20;

/// What the parent tells the app about the child. A nickname only, never a
/// real name or birth date (D13).
class ChildProfile {
  const ChildProfile({
    required this.nickname,
    required this.schoolYear,
    this.schoolStartLevel,
    this.olympiadStartLevel,
    this.avatar = defaultAvatar,
  });

  /// Built-in avatar id (FEAT-25 AD-7).
  static const defaultAvatar = 'fox';

  final String nickname;

  /// 1 = P1 … 6 = P6.
  final int schoolYear;

  /// Starting level for P1/P2 topics, or null for automatic.
  final int? schoolStartLevel;

  /// Starting level for Olympiad topics, or null for automatic.
  final int? olympiadStartLevel;

  /// Avatar id from `lib/ui/avatars.dart` (FEAT-25 AD-7).
  final String avatar;

  ChildProfile copyWith({String? avatar}) => ChildProfile(
    nickname: nickname,
    schoolYear: schoolYear,
    schoolStartLevel: schoolStartLevel,
    olympiadStartLevel: olympiadStartLevel,
    avatar: avatar ?? this.avatar,
  );

  @override
  bool operator ==(Object other) =>
      other is ChildProfile &&
      other.nickname == nickname &&
      other.schoolYear == schoolYear &&
      other.schoolStartLevel == schoolStartLevel &&
      other.olympiadStartLevel == olympiadStartLevel &&
      other.avatar == avatar;

  @override
  int get hashCode => Object.hash(
    nickname,
    schoolYear,
    schoolStartLevel,
    olympiadStartLevel,
    avatar,
  );

  @override
  String toString() =>
      'ChildProfile($nickname, P$schoolYear, '
      'school: $schoolStartLevel, olympiad: $olympiadStartLevel)';
}

/// Why [raw] can't be a nickname, or null when it can (1–20 characters
/// after trimming).
String? nicknameError(String raw) {
  final n = raw.trim();
  if (n.isEmpty) return 'Type a nickname.';
  if (n.characters > maxNicknameLength) {
    return 'At most $maxNicknameLength characters.';
  }
  return null;
}

extension on String {
  int get characters => runes.length;
}

/// The school year a topic belongs to, or null for Olympiad topics.
int? topicYear(Topic t) => switch (t.track) {
  Track.p1 => 1,
  Track.p2 => 2,
  Track.olympiad => null,
};

/// The level a topic with no finished round starts at (PRO-03): the track's
/// override if set, else worked out from her school year and the topic's.
int startLevel(ChildProfile? p, Topic? t) {
  if (p == null || t == null) return minLevel;
  final year = topicYear(t);
  final override = year == null ? p.olympiadStartLevel : p.schoolStartLevel;
  if (override != null) return override.clamp(minLevel, maxLevel);
  final level = year == null ? p.schoolYear - 1 : 1 + p.schoolYear - year;
  return level.clamp(minLevel, maxLevel);
}
