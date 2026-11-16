// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinSaltMeta = const VerificationMeta(
    'pinSalt',
  );
  @override
  late final GeneratedColumn<String> pinSalt = GeneratedColumn<String>(
    'pin_salt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyLimitMinMeta = const VerificationMeta(
    'dailyLimitMin',
  );
  @override
  late final GeneratedColumn<int> dailyLimitMin = GeneratedColumn<int>(
    'daily_limit_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _bankVersionMeta = const VerificationMeta(
    'bankVersion',
  );
  @override
  late final GeneratedColumn<int> bankVersion = GeneratedColumn<int>(
    'bank_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _soundOnMeta = const VerificationMeta(
    'soundOn',
  );
  @override
  late final GeneratedColumn<bool> soundOn = GeneratedColumn<bool>(
    'sound_on',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sound_on" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _profilePendingMeta = const VerificationMeta(
    'profilePending',
  );
  @override
  late final GeneratedColumn<bool> profilePending = GeneratedColumn<bool>(
    'profile_pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("profile_pending" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pinHash,
    pinSalt,
    dailyLimitMin,
    bankVersion,
    soundOn,
    profilePending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    }
    if (data.containsKey('pin_salt')) {
      context.handle(
        _pinSaltMeta,
        pinSalt.isAcceptableOrUnknown(data['pin_salt']!, _pinSaltMeta),
      );
    }
    if (data.containsKey('daily_limit_min')) {
      context.handle(
        _dailyLimitMinMeta,
        dailyLimitMin.isAcceptableOrUnknown(
          data['daily_limit_min']!,
          _dailyLimitMinMeta,
        ),
      );
    }
    if (data.containsKey('bank_version')) {
      context.handle(
        _bankVersionMeta,
        bankVersion.isAcceptableOrUnknown(
          data['bank_version']!,
          _bankVersionMeta,
        ),
      );
    }
    if (data.containsKey('sound_on')) {
      context.handle(
        _soundOnMeta,
        soundOn.isAcceptableOrUnknown(data['sound_on']!, _soundOnMeta),
      );
    }
    if (data.containsKey('profile_pending')) {
      context.handle(
        _profilePendingMeta,
        profilePending.isAcceptableOrUnknown(
          data['profile_pending']!,
          _profilePendingMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      ),
      pinSalt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_salt'],
      ),
      dailyLimitMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_limit_min'],
      )!,
      bankVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bank_version'],
      )!,
      soundOn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sound_on'],
      )!,
      profilePending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}profile_pending'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final String? pinHash;
  final String? pinSalt;
  final int dailyLimitMin;
  final int bankVersion;
  final bool soundOn;

  /// Ask for the child profile before play (PRO-02). True on a new install,
  /// false on one updated from v3; saving the profile clears it.
  final bool profilePending;
  const AppSetting({
    required this.id,
    this.pinHash,
    this.pinSalt,
    required this.dailyLimitMin,
    required this.bankVersion,
    required this.soundOn,
    required this.profilePending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || pinHash != null) {
      map['pin_hash'] = Variable<String>(pinHash);
    }
    if (!nullToAbsent || pinSalt != null) {
      map['pin_salt'] = Variable<String>(pinSalt);
    }
    map['daily_limit_min'] = Variable<int>(dailyLimitMin);
    map['bank_version'] = Variable<int>(bankVersion);
    map['sound_on'] = Variable<bool>(soundOn);
    map['profile_pending'] = Variable<bool>(profilePending);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      pinHash: pinHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pinHash),
      pinSalt: pinSalt == null && nullToAbsent
          ? const Value.absent()
          : Value(pinSalt),
      dailyLimitMin: Value(dailyLimitMin),
      bankVersion: Value(bankVersion),
      soundOn: Value(soundOn),
      profilePending: Value(profilePending),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      pinHash: serializer.fromJson<String?>(json['pinHash']),
      pinSalt: serializer.fromJson<String?>(json['pinSalt']),
      dailyLimitMin: serializer.fromJson<int>(json['dailyLimitMin']),
      bankVersion: serializer.fromJson<int>(json['bankVersion']),
      soundOn: serializer.fromJson<bool>(json['soundOn']),
      profilePending: serializer.fromJson<bool>(json['profilePending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pinHash': serializer.toJson<String?>(pinHash),
      'pinSalt': serializer.toJson<String?>(pinSalt),
      'dailyLimitMin': serializer.toJson<int>(dailyLimitMin),
      'bankVersion': serializer.toJson<int>(bankVersion),
      'soundOn': serializer.toJson<bool>(soundOn),
      'profilePending': serializer.toJson<bool>(profilePending),
    };
  }

  AppSetting copyWith({
    int? id,
    Value<String?> pinHash = const Value.absent(),
    Value<String?> pinSalt = const Value.absent(),
    int? dailyLimitMin,
    int? bankVersion,
    bool? soundOn,
    bool? profilePending,
  }) => AppSetting(
    id: id ?? this.id,
    pinHash: pinHash.present ? pinHash.value : this.pinHash,
    pinSalt: pinSalt.present ? pinSalt.value : this.pinSalt,
    dailyLimitMin: dailyLimitMin ?? this.dailyLimitMin,
    bankVersion: bankVersion ?? this.bankVersion,
    soundOn: soundOn ?? this.soundOn,
    profilePending: profilePending ?? this.profilePending,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      pinSalt: data.pinSalt.present ? data.pinSalt.value : this.pinSalt,
      dailyLimitMin: data.dailyLimitMin.present
          ? data.dailyLimitMin.value
          : this.dailyLimitMin,
      bankVersion: data.bankVersion.present
          ? data.bankVersion.value
          : this.bankVersion,
      soundOn: data.soundOn.present ? data.soundOn.value : this.soundOn,
      profilePending: data.profilePending.present
          ? data.profilePending.value
          : this.profilePending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('pinHash: $pinHash, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('dailyLimitMin: $dailyLimitMin, ')
          ..write('bankVersion: $bankVersion, ')
          ..write('soundOn: $soundOn, ')
          ..write('profilePending: $profilePending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pinHash,
    pinSalt,
    dailyLimitMin,
    bankVersion,
    soundOn,
    profilePending,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.pinHash == this.pinHash &&
          other.pinSalt == this.pinSalt &&
          other.dailyLimitMin == this.dailyLimitMin &&
          other.bankVersion == this.bankVersion &&
          other.soundOn == this.soundOn &&
          other.profilePending == this.profilePending);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<String?> pinHash;
  final Value<String?> pinSalt;
  final Value<int> dailyLimitMin;
  final Value<int> bankVersion;
  final Value<bool> soundOn;
  final Value<bool> profilePending;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.pinSalt = const Value.absent(),
    this.dailyLimitMin = const Value.absent(),
    this.bankVersion = const Value.absent(),
    this.soundOn = const Value.absent(),
    this.profilePending = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.pinSalt = const Value.absent(),
    this.dailyLimitMin = const Value.absent(),
    this.bankVersion = const Value.absent(),
    this.soundOn = const Value.absent(),
    this.profilePending = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<String>? pinHash,
    Expression<String>? pinSalt,
    Expression<int>? dailyLimitMin,
    Expression<int>? bankVersion,
    Expression<bool>? soundOn,
    Expression<bool>? profilePending,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pinHash != null) 'pin_hash': pinHash,
      if (pinSalt != null) 'pin_salt': pinSalt,
      if (dailyLimitMin != null) 'daily_limit_min': dailyLimitMin,
      if (bankVersion != null) 'bank_version': bankVersion,
      if (soundOn != null) 'sound_on': soundOn,
      if (profilePending != null) 'profile_pending': profilePending,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<String?>? pinHash,
    Value<String?>? pinSalt,
    Value<int>? dailyLimitMin,
    Value<int>? bankVersion,
    Value<bool>? soundOn,
    Value<bool>? profilePending,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      pinHash: pinHash ?? this.pinHash,
      pinSalt: pinSalt ?? this.pinSalt,
      dailyLimitMin: dailyLimitMin ?? this.dailyLimitMin,
      bankVersion: bankVersion ?? this.bankVersion,
      soundOn: soundOn ?? this.soundOn,
      profilePending: profilePending ?? this.profilePending,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (pinSalt.present) {
      map['pin_salt'] = Variable<String>(pinSalt.value);
    }
    if (dailyLimitMin.present) {
      map['daily_limit_min'] = Variable<int>(dailyLimitMin.value);
    }
    if (bankVersion.present) {
      map['bank_version'] = Variable<int>(bankVersion.value);
    }
    if (soundOn.present) {
      map['sound_on'] = Variable<bool>(soundOn.value);
    }
    if (profilePending.present) {
      map['profile_pending'] = Variable<bool>(profilePending.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('pinHash: $pinHash, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('dailyLimitMin: $dailyLimitMin, ')
          ..write('bankVersion: $bankVersion, ')
          ..write('soundOn: $soundOn, ')
          ..write('profilePending: $profilePending')
          ..write(')'))
        .toString();
  }
}

class $PlaySessionsTable extends PlaySessions
    with TableInfo<$PlaySessionsTable, PlaySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaySessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, startedAt, endedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'play_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaySession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaySession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
    );
  }

  @override
  $PlaySessionsTable createAlias(String alias) {
    return $PlaySessionsTable(attachedDatabase, alias);
  }
}

class PlaySession extends DataClass implements Insertable<PlaySession> {
  final int id;
  final DateTime startedAt;
  final DateTime? endedAt;
  const PlaySession({required this.id, required this.startedAt, this.endedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    return map;
  }

  PlaySessionsCompanion toCompanion(bool nullToAbsent) {
    return PlaySessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
    );
  }

  factory PlaySession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaySession(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
    };
  }

  PlaySession copyWith({
    int? id,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
  }) => PlaySession(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
  );
  PlaySession copyWithCompanion(PlaySessionsCompanion data) {
    return PlaySession(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaySession(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, startedAt, endedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaySession &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt);
}

class PlaySessionsCompanion extends UpdateCompanion<PlaySession> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  const PlaySessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
  });
  PlaySessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
  }) : startedAt = Value(startedAt);
  static Insertable<PlaySession> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
    });
  }

  PlaySessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
  }) {
    return PlaySessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaySessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }
}

class $RoundsTable extends Rounds with TableInfo<$RoundsTable, Round> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoundsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES play_sessions (id)',
    ),
  );
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _starsMeta = const VerificationMeta('stars');
  @override
  late final GeneratedColumn<int> stars = GeneratedColumn<int>(
    'stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('normal'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    topicId,
    level,
    startedAt,
    score,
    durationMs,
    stars,
    finishedAt,
    kind,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rounds';
  @override
  VerificationContext validateIntegrity(
    Insertable<Round> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('stars')) {
      context.handle(
        _starsMeta,
        stars.isAcceptableOrUnknown(data['stars']!, _starsMeta),
      );
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Round map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Round(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      stars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stars'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
    );
  }

  @override
  $RoundsTable createAlias(String alias) {
    return $RoundsTable(attachedDatabase, alias);
  }
}

class Round extends DataClass implements Insertable<Round> {
  final int id;
  final int sessionId;
  final String topicId;
  final int level;
  final DateTime startedAt;
  final int score;
  final int durationMs;
  final int stars;

  /// Null until the last answer is saved; a quit round stays null (schema v2).
  final DateTime? finishedAt;

  /// `normal` or `revision` (schema v6, REV-04). A revision round never
  /// counts for levels, best stars or the topic lock.
  final String kind;
  const Round({
    required this.id,
    required this.sessionId,
    required this.topicId,
    required this.level,
    required this.startedAt,
    required this.score,
    required this.durationMs,
    required this.stars,
    this.finishedAt,
    required this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['topic_id'] = Variable<String>(topicId);
    map['level'] = Variable<int>(level);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['score'] = Variable<int>(score);
    map['duration_ms'] = Variable<int>(durationMs);
    map['stars'] = Variable<int>(stars);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['kind'] = Variable<String>(kind);
    return map;
  }

  RoundsCompanion toCompanion(bool nullToAbsent) {
    return RoundsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      topicId: Value(topicId),
      level: Value(level),
      startedAt: Value(startedAt),
      score: Value(score),
      durationMs: Value(durationMs),
      stars: Value(stars),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      kind: Value(kind),
    );
  }

  factory Round.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Round(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      topicId: serializer.fromJson<String>(json['topicId']),
      level: serializer.fromJson<int>(json['level']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      score: serializer.fromJson<int>(json['score']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      stars: serializer.fromJson<int>(json['stars']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      kind: serializer.fromJson<String>(json['kind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'topicId': serializer.toJson<String>(topicId),
      'level': serializer.toJson<int>(level),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'score': serializer.toJson<int>(score),
      'durationMs': serializer.toJson<int>(durationMs),
      'stars': serializer.toJson<int>(stars),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'kind': serializer.toJson<String>(kind),
    };
  }

  Round copyWith({
    int? id,
    int? sessionId,
    String? topicId,
    int? level,
    DateTime? startedAt,
    int? score,
    int? durationMs,
    int? stars,
    Value<DateTime?> finishedAt = const Value.absent(),
    String? kind,
  }) => Round(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    topicId: topicId ?? this.topicId,
    level: level ?? this.level,
    startedAt: startedAt ?? this.startedAt,
    score: score ?? this.score,
    durationMs: durationMs ?? this.durationMs,
    stars: stars ?? this.stars,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    kind: kind ?? this.kind,
  );
  Round copyWithCompanion(RoundsCompanion data) {
    return Round(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      level: data.level.present ? data.level.value : this.level,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      score: data.score.present ? data.score.value : this.score,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      stars: data.stars.present ? data.stars.value : this.stars,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Round(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('topicId: $topicId, ')
          ..write('level: $level, ')
          ..write('startedAt: $startedAt, ')
          ..write('score: $score, ')
          ..write('durationMs: $durationMs, ')
          ..write('stars: $stars, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    topicId,
    level,
    startedAt,
    score,
    durationMs,
    stars,
    finishedAt,
    kind,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Round &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.topicId == this.topicId &&
          other.level == this.level &&
          other.startedAt == this.startedAt &&
          other.score == this.score &&
          other.durationMs == this.durationMs &&
          other.stars == this.stars &&
          other.finishedAt == this.finishedAt &&
          other.kind == this.kind);
}

class RoundsCompanion extends UpdateCompanion<Round> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> topicId;
  final Value<int> level;
  final Value<DateTime> startedAt;
  final Value<int> score;
  final Value<int> durationMs;
  final Value<int> stars;
  final Value<DateTime?> finishedAt;
  final Value<String> kind;
  const RoundsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.topicId = const Value.absent(),
    this.level = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.score = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.stars = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.kind = const Value.absent(),
  });
  RoundsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String topicId,
    this.level = const Value.absent(),
    required DateTime startedAt,
    this.score = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.stars = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.kind = const Value.absent(),
  }) : sessionId = Value(sessionId),
       topicId = Value(topicId),
       startedAt = Value(startedAt);
  static Insertable<Round> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? topicId,
    Expression<int>? level,
    Expression<DateTime>? startedAt,
    Expression<int>? score,
    Expression<int>? durationMs,
    Expression<int>? stars,
    Expression<DateTime>? finishedAt,
    Expression<String>? kind,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (topicId != null) 'topic_id': topicId,
      if (level != null) 'level': level,
      if (startedAt != null) 'started_at': startedAt,
      if (score != null) 'score': score,
      if (durationMs != null) 'duration_ms': durationMs,
      if (stars != null) 'stars': stars,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (kind != null) 'kind': kind,
    });
  }

  RoundsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? topicId,
    Value<int>? level,
    Value<DateTime>? startedAt,
    Value<int>? score,
    Value<int>? durationMs,
    Value<int>? stars,
    Value<DateTime?>? finishedAt,
    Value<String>? kind,
  }) {
    return RoundsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      topicId: topicId ?? this.topicId,
      level: level ?? this.level,
      startedAt: startedAt ?? this.startedAt,
      score: score ?? this.score,
      durationMs: durationMs ?? this.durationMs,
      stars: stars ?? this.stars,
      finishedAt: finishedAt ?? this.finishedAt,
      kind: kind ?? this.kind,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (stars.present) {
      map['stars'] = Variable<int>(stars.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoundsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('topicId: $topicId, ')
          ..write('level: $level, ')
          ..write('startedAt: $startedAt, ')
          ..write('score: $score, ')
          ..write('durationMs: $durationMs, ')
          ..write('stars: $stars, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }
}

class $AttemptsTable extends Attempts with TableInfo<$AttemptsTable, Attempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _roundIdMeta = const VerificationMeta(
    'roundId',
  );
  @override
  late final GeneratedColumn<int> roundId = GeneratedColumn<int>(
    'round_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rounds (id)',
    ),
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answerGivenMeta = const VerificationMeta(
    'answerGiven',
  );
  @override
  late final GeneratedColumn<String> answerGiven = GeneratedColumn<String>(
    'answer_given',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctMeta = const VerificationMeta(
    'correct',
  );
  @override
  late final GeneratedColumn<bool> correct = GeneratedColumn<bool>(
    'correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _timeMsMeta = const VerificationMeta('timeMs');
  @override
  late final GeneratedColumn<int> timeMs = GeneratedColumn<int>(
    'time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
    'answered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    roundId,
    questionId,
    answerGiven,
    correct,
    timeMs,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('round_id')) {
      context.handle(
        _roundIdMeta,
        roundId.isAcceptableOrUnknown(data['round_id']!, _roundIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roundIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('answer_given')) {
      context.handle(
        _answerGivenMeta,
        answerGiven.isAcceptableOrUnknown(
          data['answer_given']!,
          _answerGivenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_answerGivenMeta);
    }
    if (data.containsKey('correct')) {
      context.handle(
        _correctMeta,
        correct.isAcceptableOrUnknown(data['correct']!, _correctMeta),
      );
    } else if (isInserting) {
      context.missing(_correctMeta);
    }
    if (data.containsKey('time_ms')) {
      context.handle(
        _timeMsMeta,
        timeMs.isAcceptableOrUnknown(data['time_ms']!, _timeMsMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMsMeta);
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      roundId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      answerGiven: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer_given'],
      )!,
      correct: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}correct'],
      )!,
      timeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_ms'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at'],
      )!,
    );
  }

  @override
  $AttemptsTable createAlias(String alias) {
    return $AttemptsTable(attachedDatabase, alias);
  }
}

class Attempt extends DataClass implements Insertable<Attempt> {
  final int id;
  final int roundId;
  final String questionId;
  final String answerGiven;
  final bool correct;
  final int timeMs;
  final DateTime answeredAt;
  const Attempt({
    required this.id,
    required this.roundId,
    required this.questionId,
    required this.answerGiven,
    required this.correct,
    required this.timeMs,
    required this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['round_id'] = Variable<int>(roundId);
    map['question_id'] = Variable<String>(questionId);
    map['answer_given'] = Variable<String>(answerGiven);
    map['correct'] = Variable<bool>(correct);
    map['time_ms'] = Variable<int>(timeMs);
    map['answered_at'] = Variable<DateTime>(answeredAt);
    return map;
  }

  AttemptsCompanion toCompanion(bool nullToAbsent) {
    return AttemptsCompanion(
      id: Value(id),
      roundId: Value(roundId),
      questionId: Value(questionId),
      answerGiven: Value(answerGiven),
      correct: Value(correct),
      timeMs: Value(timeMs),
      answeredAt: Value(answeredAt),
    );
  }

  factory Attempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attempt(
      id: serializer.fromJson<int>(json['id']),
      roundId: serializer.fromJson<int>(json['roundId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      answerGiven: serializer.fromJson<String>(json['answerGiven']),
      correct: serializer.fromJson<bool>(json['correct']),
      timeMs: serializer.fromJson<int>(json['timeMs']),
      answeredAt: serializer.fromJson<DateTime>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'roundId': serializer.toJson<int>(roundId),
      'questionId': serializer.toJson<String>(questionId),
      'answerGiven': serializer.toJson<String>(answerGiven),
      'correct': serializer.toJson<bool>(correct),
      'timeMs': serializer.toJson<int>(timeMs),
      'answeredAt': serializer.toJson<DateTime>(answeredAt),
    };
  }

  Attempt copyWith({
    int? id,
    int? roundId,
    String? questionId,
    String? answerGiven,
    bool? correct,
    int? timeMs,
    DateTime? answeredAt,
  }) => Attempt(
    id: id ?? this.id,
    roundId: roundId ?? this.roundId,
    questionId: questionId ?? this.questionId,
    answerGiven: answerGiven ?? this.answerGiven,
    correct: correct ?? this.correct,
    timeMs: timeMs ?? this.timeMs,
    answeredAt: answeredAt ?? this.answeredAt,
  );
  Attempt copyWithCompanion(AttemptsCompanion data) {
    return Attempt(
      id: data.id.present ? data.id.value : this.id,
      roundId: data.roundId.present ? data.roundId.value : this.roundId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      answerGiven: data.answerGiven.present
          ? data.answerGiven.value
          : this.answerGiven,
      correct: data.correct.present ? data.correct.value : this.correct,
      timeMs: data.timeMs.present ? data.timeMs.value : this.timeMs,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attempt(')
          ..write('id: $id, ')
          ..write('roundId: $roundId, ')
          ..write('questionId: $questionId, ')
          ..write('answerGiven: $answerGiven, ')
          ..write('correct: $correct, ')
          ..write('timeMs: $timeMs, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    roundId,
    questionId,
    answerGiven,
    correct,
    timeMs,
    answeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attempt &&
          other.id == this.id &&
          other.roundId == this.roundId &&
          other.questionId == this.questionId &&
          other.answerGiven == this.answerGiven &&
          other.correct == this.correct &&
          other.timeMs == this.timeMs &&
          other.answeredAt == this.answeredAt);
}

class AttemptsCompanion extends UpdateCompanion<Attempt> {
  final Value<int> id;
  final Value<int> roundId;
  final Value<String> questionId;
  final Value<String> answerGiven;
  final Value<bool> correct;
  final Value<int> timeMs;
  final Value<DateTime> answeredAt;
  const AttemptsCompanion({
    this.id = const Value.absent(),
    this.roundId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.answerGiven = const Value.absent(),
    this.correct = const Value.absent(),
    this.timeMs = const Value.absent(),
    this.answeredAt = const Value.absent(),
  });
  AttemptsCompanion.insert({
    this.id = const Value.absent(),
    required int roundId,
    required String questionId,
    required String answerGiven,
    required bool correct,
    required int timeMs,
    required DateTime answeredAt,
  }) : roundId = Value(roundId),
       questionId = Value(questionId),
       answerGiven = Value(answerGiven),
       correct = Value(correct),
       timeMs = Value(timeMs),
       answeredAt = Value(answeredAt);
  static Insertable<Attempt> custom({
    Expression<int>? id,
    Expression<int>? roundId,
    Expression<String>? questionId,
    Expression<String>? answerGiven,
    Expression<bool>? correct,
    Expression<int>? timeMs,
    Expression<DateTime>? answeredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roundId != null) 'round_id': roundId,
      if (questionId != null) 'question_id': questionId,
      if (answerGiven != null) 'answer_given': answerGiven,
      if (correct != null) 'correct': correct,
      if (timeMs != null) 'time_ms': timeMs,
      if (answeredAt != null) 'answered_at': answeredAt,
    });
  }

  AttemptsCompanion copyWith({
    Value<int>? id,
    Value<int>? roundId,
    Value<String>? questionId,
    Value<String>? answerGiven,
    Value<bool>? correct,
    Value<int>? timeMs,
    Value<DateTime>? answeredAt,
  }) {
    return AttemptsCompanion(
      id: id ?? this.id,
      roundId: roundId ?? this.roundId,
      questionId: questionId ?? this.questionId,
      answerGiven: answerGiven ?? this.answerGiven,
      correct: correct ?? this.correct,
      timeMs: timeMs ?? this.timeMs,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (roundId.present) {
      map['round_id'] = Variable<int>(roundId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (answerGiven.present) {
      map['answer_given'] = Variable<String>(answerGiven.value);
    }
    if (correct.present) {
      map['correct'] = Variable<bool>(correct.value);
    }
    if (timeMs.present) {
      map['time_ms'] = Variable<int>(timeMs.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptsCompanion(')
          ..write('id: $id, ')
          ..write('roundId: $roundId, ')
          ..write('questionId: $questionId, ')
          ..write('answerGiven: $answerGiven, ')
          ..write('correct: $correct, ')
          ..write('timeMs: $timeMs, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }
}

class $DailyUsageTable extends DailyUsage
    with TableInfo<$DailyUsageTable, DailyUsageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyUsageTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secondsUsedMeta = const VerificationMeta(
    'secondsUsed',
  );
  @override
  late final GeneratedColumn<int> secondsUsed = GeneratedColumn<int>(
    'seconds_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _extraSecondsGrantedMeta =
      const VerificationMeta('extraSecondsGranted');
  @override
  late final GeneratedColumn<int> extraSecondsGranted = GeneratedColumn<int>(
    'extra_seconds_granted',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [day, secondsUsed, extraSecondsGranted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_usage';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyUsageData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('seconds_used')) {
      context.handle(
        _secondsUsedMeta,
        secondsUsed.isAcceptableOrUnknown(
          data['seconds_used']!,
          _secondsUsedMeta,
        ),
      );
    }
    if (data.containsKey('extra_seconds_granted')) {
      context.handle(
        _extraSecondsGrantedMeta,
        extraSecondsGranted.isAcceptableOrUnknown(
          data['extra_seconds_granted']!,
          _extraSecondsGrantedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  DailyUsageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyUsageData(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      secondsUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seconds_used'],
      )!,
      extraSecondsGranted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}extra_seconds_granted'],
      )!,
    );
  }

  @override
  $DailyUsageTable createAlias(String alias) {
    return $DailyUsageTable(attachedDatabase, alias);
  }
}

class DailyUsageData extends DataClass implements Insertable<DailyUsageData> {
  final String day;
  final int secondsUsed;
  final int extraSecondsGranted;
  const DailyUsageData({
    required this.day,
    required this.secondsUsed,
    required this.extraSecondsGranted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['seconds_used'] = Variable<int>(secondsUsed);
    map['extra_seconds_granted'] = Variable<int>(extraSecondsGranted);
    return map;
  }

  DailyUsageCompanion toCompanion(bool nullToAbsent) {
    return DailyUsageCompanion(
      day: Value(day),
      secondsUsed: Value(secondsUsed),
      extraSecondsGranted: Value(extraSecondsGranted),
    );
  }

  factory DailyUsageData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyUsageData(
      day: serializer.fromJson<String>(json['day']),
      secondsUsed: serializer.fromJson<int>(json['secondsUsed']),
      extraSecondsGranted: serializer.fromJson<int>(
        json['extraSecondsGranted'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'secondsUsed': serializer.toJson<int>(secondsUsed),
      'extraSecondsGranted': serializer.toJson<int>(extraSecondsGranted),
    };
  }

  DailyUsageData copyWith({
    String? day,
    int? secondsUsed,
    int? extraSecondsGranted,
  }) => DailyUsageData(
    day: day ?? this.day,
    secondsUsed: secondsUsed ?? this.secondsUsed,
    extraSecondsGranted: extraSecondsGranted ?? this.extraSecondsGranted,
  );
  DailyUsageData copyWithCompanion(DailyUsageCompanion data) {
    return DailyUsageData(
      day: data.day.present ? data.day.value : this.day,
      secondsUsed: data.secondsUsed.present
          ? data.secondsUsed.value
          : this.secondsUsed,
      extraSecondsGranted: data.extraSecondsGranted.present
          ? data.extraSecondsGranted.value
          : this.extraSecondsGranted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyUsageData(')
          ..write('day: $day, ')
          ..write('secondsUsed: $secondsUsed, ')
          ..write('extraSecondsGranted: $extraSecondsGranted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, secondsUsed, extraSecondsGranted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyUsageData &&
          other.day == this.day &&
          other.secondsUsed == this.secondsUsed &&
          other.extraSecondsGranted == this.extraSecondsGranted);
}

class DailyUsageCompanion extends UpdateCompanion<DailyUsageData> {
  final Value<String> day;
  final Value<int> secondsUsed;
  final Value<int> extraSecondsGranted;
  final Value<int> rowid;
  const DailyUsageCompanion({
    this.day = const Value.absent(),
    this.secondsUsed = const Value.absent(),
    this.extraSecondsGranted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyUsageCompanion.insert({
    required String day,
    this.secondsUsed = const Value.absent(),
    this.extraSecondsGranted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : day = Value(day);
  static Insertable<DailyUsageData> custom({
    Expression<String>? day,
    Expression<int>? secondsUsed,
    Expression<int>? extraSecondsGranted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (secondsUsed != null) 'seconds_used': secondsUsed,
      if (extraSecondsGranted != null)
        'extra_seconds_granted': extraSecondsGranted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyUsageCompanion copyWith({
    Value<String>? day,
    Value<int>? secondsUsed,
    Value<int>? extraSecondsGranted,
    Value<int>? rowid,
  }) {
    return DailyUsageCompanion(
      day: day ?? this.day,
      secondsUsed: secondsUsed ?? this.secondsUsed,
      extraSecondsGranted: extraSecondsGranted ?? this.extraSecondsGranted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (secondsUsed.present) {
      map['seconds_used'] = Variable<int>(secondsUsed.value);
    }
    if (extraSecondsGranted.present) {
      map['extra_seconds_granted'] = Variable<int>(extraSecondsGranted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyUsageCompanion(')
          ..write('day: $day, ')
          ..write('secondsUsed: $secondsUsed, ')
          ..write('extraSecondsGranted: $extraSecondsGranted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BadgesEarnedTable extends BadgesEarned
    with TableInfo<$BadgesEarnedTable, BadgesEarnedData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BadgesEarnedTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _badgeIdMeta = const VerificationMeta(
    'badgeId',
  );
  @override
  late final GeneratedColumn<String> badgeId = GeneratedColumn<String>(
    'badge_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _earnedAtMeta = const VerificationMeta(
    'earnedAt',
  );
  @override
  late final GeneratedColumn<DateTime> earnedAt = GeneratedColumn<DateTime>(
    'earned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [badgeId, earnedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'badges_earned';
  @override
  VerificationContext validateIntegrity(
    Insertable<BadgesEarnedData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('badge_id')) {
      context.handle(
        _badgeIdMeta,
        badgeId.isAcceptableOrUnknown(data['badge_id']!, _badgeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_badgeIdMeta);
    }
    if (data.containsKey('earned_at')) {
      context.handle(
        _earnedAtMeta,
        earnedAt.isAcceptableOrUnknown(data['earned_at']!, _earnedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_earnedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {badgeId};
  @override
  BadgesEarnedData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BadgesEarnedData(
      badgeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}badge_id'],
      )!,
      earnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}earned_at'],
      )!,
    );
  }

  @override
  $BadgesEarnedTable createAlias(String alias) {
    return $BadgesEarnedTable(attachedDatabase, alias);
  }
}

class BadgesEarnedData extends DataClass
    implements Insertable<BadgesEarnedData> {
  final String badgeId;
  final DateTime earnedAt;
  const BadgesEarnedData({required this.badgeId, required this.earnedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['badge_id'] = Variable<String>(badgeId);
    map['earned_at'] = Variable<DateTime>(earnedAt);
    return map;
  }

  BadgesEarnedCompanion toCompanion(bool nullToAbsent) {
    return BadgesEarnedCompanion(
      badgeId: Value(badgeId),
      earnedAt: Value(earnedAt),
    );
  }

  factory BadgesEarnedData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BadgesEarnedData(
      badgeId: serializer.fromJson<String>(json['badgeId']),
      earnedAt: serializer.fromJson<DateTime>(json['earnedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'badgeId': serializer.toJson<String>(badgeId),
      'earnedAt': serializer.toJson<DateTime>(earnedAt),
    };
  }

  BadgesEarnedData copyWith({String? badgeId, DateTime? earnedAt}) =>
      BadgesEarnedData(
        badgeId: badgeId ?? this.badgeId,
        earnedAt: earnedAt ?? this.earnedAt,
      );
  BadgesEarnedData copyWithCompanion(BadgesEarnedCompanion data) {
    return BadgesEarnedData(
      badgeId: data.badgeId.present ? data.badgeId.value : this.badgeId,
      earnedAt: data.earnedAt.present ? data.earnedAt.value : this.earnedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BadgesEarnedData(')
          ..write('badgeId: $badgeId, ')
          ..write('earnedAt: $earnedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(badgeId, earnedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BadgesEarnedData &&
          other.badgeId == this.badgeId &&
          other.earnedAt == this.earnedAt);
}

class BadgesEarnedCompanion extends UpdateCompanion<BadgesEarnedData> {
  final Value<String> badgeId;
  final Value<DateTime> earnedAt;
  final Value<int> rowid;
  const BadgesEarnedCompanion({
    this.badgeId = const Value.absent(),
    this.earnedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BadgesEarnedCompanion.insert({
    required String badgeId,
    required DateTime earnedAt,
    this.rowid = const Value.absent(),
  }) : badgeId = Value(badgeId),
       earnedAt = Value(earnedAt);
  static Insertable<BadgesEarnedData> custom({
    Expression<String>? badgeId,
    Expression<DateTime>? earnedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (badgeId != null) 'badge_id': badgeId,
      if (earnedAt != null) 'earned_at': earnedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BadgesEarnedCompanion copyWith({
    Value<String>? badgeId,
    Value<DateTime>? earnedAt,
    Value<int>? rowid,
  }) {
    return BadgesEarnedCompanion(
      badgeId: badgeId ?? this.badgeId,
      earnedAt: earnedAt ?? this.earnedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (badgeId.present) {
      map['badge_id'] = Variable<String>(badgeId.value);
    }
    if (earnedAt.present) {
      map['earned_at'] = Variable<DateTime>(earnedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BadgesEarnedCompanion(')
          ..write('badgeId: $badgeId, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PinLockoutTable extends PinLockout
    with TableInfo<$PinLockoutTable, PinLockoutData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PinLockoutTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _failedCountMeta = const VerificationMeta(
    'failedCount',
  );
  @override
  late final GeneratedColumn<int> failedCount = GeneratedColumn<int>(
    'failed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lockedUntilMeta = const VerificationMeta(
    'lockedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> lockedUntil = GeneratedColumn<DateTime>(
    'locked_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, failedCount, lockedUntil];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pin_lockout';
  @override
  VerificationContext validateIntegrity(
    Insertable<PinLockoutData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('failed_count')) {
      context.handle(
        _failedCountMeta,
        failedCount.isAcceptableOrUnknown(
          data['failed_count']!,
          _failedCountMeta,
        ),
      );
    }
    if (data.containsKey('locked_until')) {
      context.handle(
        _lockedUntilMeta,
        lockedUntil.isAcceptableOrUnknown(
          data['locked_until']!,
          _lockedUntilMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PinLockoutData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PinLockoutData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      failedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_count'],
      )!,
      lockedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}locked_until'],
      ),
    );
  }

  @override
  $PinLockoutTable createAlias(String alias) {
    return $PinLockoutTable(attachedDatabase, alias);
  }
}

class PinLockoutData extends DataClass implements Insertable<PinLockoutData> {
  final int id;
  final int failedCount;
  final DateTime? lockedUntil;
  const PinLockoutData({
    required this.id,
    required this.failedCount,
    this.lockedUntil,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['failed_count'] = Variable<int>(failedCount);
    if (!nullToAbsent || lockedUntil != null) {
      map['locked_until'] = Variable<DateTime>(lockedUntil);
    }
    return map;
  }

  PinLockoutCompanion toCompanion(bool nullToAbsent) {
    return PinLockoutCompanion(
      id: Value(id),
      failedCount: Value(failedCount),
      lockedUntil: lockedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(lockedUntil),
    );
  }

  factory PinLockoutData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PinLockoutData(
      id: serializer.fromJson<int>(json['id']),
      failedCount: serializer.fromJson<int>(json['failedCount']),
      lockedUntil: serializer.fromJson<DateTime?>(json['lockedUntil']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'failedCount': serializer.toJson<int>(failedCount),
      'lockedUntil': serializer.toJson<DateTime?>(lockedUntil),
    };
  }

  PinLockoutData copyWith({
    int? id,
    int? failedCount,
    Value<DateTime?> lockedUntil = const Value.absent(),
  }) => PinLockoutData(
    id: id ?? this.id,
    failedCount: failedCount ?? this.failedCount,
    lockedUntil: lockedUntil.present ? lockedUntil.value : this.lockedUntil,
  );
  PinLockoutData copyWithCompanion(PinLockoutCompanion data) {
    return PinLockoutData(
      id: data.id.present ? data.id.value : this.id,
      failedCount: data.failedCount.present
          ? data.failedCount.value
          : this.failedCount,
      lockedUntil: data.lockedUntil.present
          ? data.lockedUntil.value
          : this.lockedUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PinLockoutData(')
          ..write('id: $id, ')
          ..write('failedCount: $failedCount, ')
          ..write('lockedUntil: $lockedUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, failedCount, lockedUntil);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PinLockoutData &&
          other.id == this.id &&
          other.failedCount == this.failedCount &&
          other.lockedUntil == this.lockedUntil);
}

class PinLockoutCompanion extends UpdateCompanion<PinLockoutData> {
  final Value<int> id;
  final Value<int> failedCount;
  final Value<DateTime?> lockedUntil;
  const PinLockoutCompanion({
    this.id = const Value.absent(),
    this.failedCount = const Value.absent(),
    this.lockedUntil = const Value.absent(),
  });
  PinLockoutCompanion.insert({
    this.id = const Value.absent(),
    this.failedCount = const Value.absent(),
    this.lockedUntil = const Value.absent(),
  });
  static Insertable<PinLockoutData> custom({
    Expression<int>? id,
    Expression<int>? failedCount,
    Expression<DateTime>? lockedUntil,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (failedCount != null) 'failed_count': failedCount,
      if (lockedUntil != null) 'locked_until': lockedUntil,
    });
  }

  PinLockoutCompanion copyWith({
    Value<int>? id,
    Value<int>? failedCount,
    Value<DateTime?>? lockedUntil,
  }) {
    return PinLockoutCompanion(
      id: id ?? this.id,
      failedCount: failedCount ?? this.failedCount,
      lockedUntil: lockedUntil ?? this.lockedUntil,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (failedCount.present) {
      map['failed_count'] = Variable<int>(failedCount.value);
    }
    if (lockedUntil.present) {
      map['locked_until'] = Variable<DateTime>(lockedUntil.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PinLockoutCompanion(')
          ..write('id: $id, ')
          ..write('failedCount: $failedCount, ')
          ..write('lockedUntil: $lockedUntil')
          ..write(')'))
        .toString();
  }
}

class $ChildProfilesTable extends ChildProfiles
    with TableInfo<$ChildProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChildProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolYearMeta = const VerificationMeta(
    'schoolYear',
  );
  @override
  late final GeneratedColumn<int> schoolYear = GeneratedColumn<int>(
    'school_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolStartLevelMeta = const VerificationMeta(
    'schoolStartLevel',
  );
  @override
  late final GeneratedColumn<int> schoolStartLevel = GeneratedColumn<int>(
    'school_start_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _olympiadStartLevelMeta =
      const VerificationMeta('olympiadStartLevel');
  @override
  late final GeneratedColumn<int> olympiadStartLevel = GeneratedColumn<int>(
    'olympiad_start_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nickname,
    schoolYear,
    schoolStartLevel,
    olympiadStartLevel,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'child_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('school_year')) {
      context.handle(
        _schoolYearMeta,
        schoolYear.isAcceptableOrUnknown(data['school_year']!, _schoolYearMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolYearMeta);
    }
    if (data.containsKey('school_start_level')) {
      context.handle(
        _schoolStartLevelMeta,
        schoolStartLevel.isAcceptableOrUnknown(
          data['school_start_level']!,
          _schoolStartLevelMeta,
        ),
      );
    }
    if (data.containsKey('olympiad_start_level')) {
      context.handle(
        _olympiadStartLevelMeta,
        olympiadStartLevel.isAcceptableOrUnknown(
          data['olympiad_start_level']!,
          _olympiadStartLevelMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      schoolYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}school_year'],
      )!,
      schoolStartLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}school_start_level'],
      ),
      olympiadStartLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}olympiad_start_level'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ChildProfilesTable createAlias(String alias) {
    return $ChildProfilesTable(attachedDatabase, alias);
  }
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final int id;
  final String nickname;
  final int schoolYear;
  final int? schoolStartLevel;
  final int? olympiadStartLevel;
  final DateTime updatedAt;
  const ProfileRow({
    required this.id,
    required this.nickname,
    required this.schoolYear,
    this.schoolStartLevel,
    this.olympiadStartLevel,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nickname'] = Variable<String>(nickname);
    map['school_year'] = Variable<int>(schoolYear);
    if (!nullToAbsent || schoolStartLevel != null) {
      map['school_start_level'] = Variable<int>(schoolStartLevel);
    }
    if (!nullToAbsent || olympiadStartLevel != null) {
      map['olympiad_start_level'] = Variable<int>(olympiadStartLevel);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChildProfilesCompanion toCompanion(bool nullToAbsent) {
    return ChildProfilesCompanion(
      id: Value(id),
      nickname: Value(nickname),
      schoolYear: Value(schoolYear),
      schoolStartLevel: schoolStartLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(schoolStartLevel),
      olympiadStartLevel: olympiadStartLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(olympiadStartLevel),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      id: serializer.fromJson<int>(json['id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      schoolYear: serializer.fromJson<int>(json['schoolYear']),
      schoolStartLevel: serializer.fromJson<int?>(json['schoolStartLevel']),
      olympiadStartLevel: serializer.fromJson<int?>(json['olympiadStartLevel']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nickname': serializer.toJson<String>(nickname),
      'schoolYear': serializer.toJson<int>(schoolYear),
      'schoolStartLevel': serializer.toJson<int?>(schoolStartLevel),
      'olympiadStartLevel': serializer.toJson<int?>(olympiadStartLevel),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProfileRow copyWith({
    int? id,
    String? nickname,
    int? schoolYear,
    Value<int?> schoolStartLevel = const Value.absent(),
    Value<int?> olympiadStartLevel = const Value.absent(),
    DateTime? updatedAt,
  }) => ProfileRow(
    id: id ?? this.id,
    nickname: nickname ?? this.nickname,
    schoolYear: schoolYear ?? this.schoolYear,
    schoolStartLevel: schoolStartLevel.present
        ? schoolStartLevel.value
        : this.schoolStartLevel,
    olympiadStartLevel: olympiadStartLevel.present
        ? olympiadStartLevel.value
        : this.olympiadStartLevel,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProfileRow copyWithCompanion(ChildProfilesCompanion data) {
    return ProfileRow(
      id: data.id.present ? data.id.value : this.id,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      schoolYear: data.schoolYear.present
          ? data.schoolYear.value
          : this.schoolYear,
      schoolStartLevel: data.schoolStartLevel.present
          ? data.schoolStartLevel.value
          : this.schoolStartLevel,
      olympiadStartLevel: data.olympiadStartLevel.present
          ? data.olympiadStartLevel.value
          : this.olympiadStartLevel,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('schoolYear: $schoolYear, ')
          ..write('schoolStartLevel: $schoolStartLevel, ')
          ..write('olympiadStartLevel: $olympiadStartLevel, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nickname,
    schoolYear,
    schoolStartLevel,
    olympiadStartLevel,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.id == this.id &&
          other.nickname == this.nickname &&
          other.schoolYear == this.schoolYear &&
          other.schoolStartLevel == this.schoolStartLevel &&
          other.olympiadStartLevel == this.olympiadStartLevel &&
          other.updatedAt == this.updatedAt);
}

class ChildProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<int> id;
  final Value<String> nickname;
  final Value<int> schoolYear;
  final Value<int?> schoolStartLevel;
  final Value<int?> olympiadStartLevel;
  final Value<DateTime> updatedAt;
  const ChildProfilesCompanion({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.schoolYear = const Value.absent(),
    this.schoolStartLevel = const Value.absent(),
    this.olympiadStartLevel = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ChildProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String nickname,
    required int schoolYear,
    this.schoolStartLevel = const Value.absent(),
    this.olympiadStartLevel = const Value.absent(),
    required DateTime updatedAt,
  }) : nickname = Value(nickname),
       schoolYear = Value(schoolYear),
       updatedAt = Value(updatedAt);
  static Insertable<ProfileRow> custom({
    Expression<int>? id,
    Expression<String>? nickname,
    Expression<int>? schoolYear,
    Expression<int>? schoolStartLevel,
    Expression<int>? olympiadStartLevel,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (schoolYear != null) 'school_year': schoolYear,
      if (schoolStartLevel != null) 'school_start_level': schoolStartLevel,
      if (olympiadStartLevel != null)
        'olympiad_start_level': olympiadStartLevel,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ChildProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? nickname,
    Value<int>? schoolYear,
    Value<int?>? schoolStartLevel,
    Value<int?>? olympiadStartLevel,
    Value<DateTime>? updatedAt,
  }) {
    return ChildProfilesCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      schoolYear: schoolYear ?? this.schoolYear,
      schoolStartLevel: schoolStartLevel ?? this.schoolStartLevel,
      olympiadStartLevel: olympiadStartLevel ?? this.olympiadStartLevel,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (schoolYear.present) {
      map['school_year'] = Variable<int>(schoolYear.value);
    }
    if (schoolStartLevel.present) {
      map['school_start_level'] = Variable<int>(schoolStartLevel.value);
    }
    if (olympiadStartLevel.present) {
      map['olympiad_start_level'] = Variable<int>(olympiadStartLevel.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChildProfilesCompanion(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('schoolYear: $schoolYear, ')
          ..write('schoolStartLevel: $schoolStartLevel, ')
          ..write('olympiadStartLevel: $olympiadStartLevel, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TopicUnlocksTable extends TopicUnlocks
    with TableInfo<$TopicUnlocksTable, TopicUnlock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TopicUnlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [topicId, openedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'topic_unlocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TopicUnlock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_openedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {topicId};
  @override
  TopicUnlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TopicUnlock(
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_id'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      )!,
    );
  }

  @override
  $TopicUnlocksTable createAlias(String alias) {
    return $TopicUnlocksTable(attachedDatabase, alias);
  }
}

class TopicUnlock extends DataClass implements Insertable<TopicUnlock> {
  final String topicId;
  final DateTime openedAt;
  const TopicUnlock({required this.topicId, required this.openedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['topic_id'] = Variable<String>(topicId);
    map['opened_at'] = Variable<DateTime>(openedAt);
    return map;
  }

  TopicUnlocksCompanion toCompanion(bool nullToAbsent) {
    return TopicUnlocksCompanion(
      topicId: Value(topicId),
      openedAt: Value(openedAt),
    );
  }

  factory TopicUnlock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TopicUnlock(
      topicId: serializer.fromJson<String>(json['topicId']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'topicId': serializer.toJson<String>(topicId),
      'openedAt': serializer.toJson<DateTime>(openedAt),
    };
  }

  TopicUnlock copyWith({String? topicId, DateTime? openedAt}) => TopicUnlock(
    topicId: topicId ?? this.topicId,
    openedAt: openedAt ?? this.openedAt,
  );
  TopicUnlock copyWithCompanion(TopicUnlocksCompanion data) {
    return TopicUnlock(
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TopicUnlock(')
          ..write('topicId: $topicId, ')
          ..write('openedAt: $openedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(topicId, openedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TopicUnlock &&
          other.topicId == this.topicId &&
          other.openedAt == this.openedAt);
}

class TopicUnlocksCompanion extends UpdateCompanion<TopicUnlock> {
  final Value<String> topicId;
  final Value<DateTime> openedAt;
  final Value<int> rowid;
  const TopicUnlocksCompanion({
    this.topicId = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TopicUnlocksCompanion.insert({
    required String topicId,
    required DateTime openedAt,
    this.rowid = const Value.absent(),
  }) : topicId = Value(topicId),
       openedAt = Value(openedAt);
  static Insertable<TopicUnlock> custom({
    Expression<String>? topicId,
    Expression<DateTime>? openedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (topicId != null) 'topic_id': topicId,
      if (openedAt != null) 'opened_at': openedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TopicUnlocksCompanion copyWith({
    Value<String>? topicId,
    Value<DateTime>? openedAt,
    Value<int>? rowid,
  }) {
    return TopicUnlocksCompanion(
      topicId: topicId ?? this.topicId,
      openedAt: openedAt ?? this.openedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TopicUnlocksCompanion(')
          ..write('topicId: $topicId, ')
          ..write('openedAt: $openedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $PlaySessionsTable playSessions = $PlaySessionsTable(this);
  late final $RoundsTable rounds = $RoundsTable(this);
  late final $AttemptsTable attempts = $AttemptsTable(this);
  late final $DailyUsageTable dailyUsage = $DailyUsageTable(this);
  late final $BadgesEarnedTable badgesEarned = $BadgesEarnedTable(this);
  late final $PinLockoutTable pinLockout = $PinLockoutTable(this);
  late final $ChildProfilesTable childProfiles = $ChildProfilesTable(this);
  late final $TopicUnlocksTable topicUnlocks = $TopicUnlocksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettings,
    playSessions,
    rounds,
    attempts,
    dailyUsage,
    badgesEarned,
    pinLockout,
    childProfiles,
    topicUnlocks,
  ];
}

typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String?> pinHash,
      Value<String?> pinSalt,
      Value<int> dailyLimitMin,
      Value<int> bankVersion,
      Value<bool> soundOn,
      Value<bool> profilePending,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String?> pinHash,
      Value<String?> pinSalt,
      Value<int> dailyLimitMin,
      Value<int> bankVersion,
      Value<bool> soundOn,
      Value<bool> profilePending,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinSalt => $composableBuilder(
    column: $table.pinSalt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyLimitMin => $composableBuilder(
    column: $table.dailyLimitMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bankVersion => $composableBuilder(
    column: $table.bankVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get soundOn => $composableBuilder(
    column: $table.soundOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get profilePending => $composableBuilder(
    column: $table.profilePending,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinSalt => $composableBuilder(
    column: $table.pinSalt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyLimitMin => $composableBuilder(
    column: $table.dailyLimitMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bankVersion => $composableBuilder(
    column: $table.bankVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get soundOn => $composableBuilder(
    column: $table.soundOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get profilePending => $composableBuilder(
    column: $table.profilePending,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<String> get pinSalt =>
      $composableBuilder(column: $table.pinSalt, builder: (column) => column);

  GeneratedColumn<int> get dailyLimitMin => $composableBuilder(
    column: $table.dailyLimitMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bankVersion => $composableBuilder(
    column: $table.bankVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get soundOn =>
      $composableBuilder(column: $table.soundOn, builder: (column) => column);

  GeneratedColumn<bool> get profilePending => $composableBuilder(
    column: $table.profilePending,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<String?> pinSalt = const Value.absent(),
                Value<int> dailyLimitMin = const Value.absent(),
                Value<int> bankVersion = const Value.absent(),
                Value<bool> soundOn = const Value.absent(),
                Value<bool> profilePending = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                pinHash: pinHash,
                pinSalt: pinSalt,
                dailyLimitMin: dailyLimitMin,
                bankVersion: bankVersion,
                soundOn: soundOn,
                profilePending: profilePending,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<String?> pinSalt = const Value.absent(),
                Value<int> dailyLimitMin = const Value.absent(),
                Value<int> bankVersion = const Value.absent(),
                Value<bool> soundOn = const Value.absent(),
                Value<bool> profilePending = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                pinHash: pinHash,
                pinSalt: pinSalt,
                dailyLimitMin: dailyLimitMin,
                bankVersion: bankVersion,
                soundOn: soundOn,
                profilePending: profilePending,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$PlaySessionsTableCreateCompanionBuilder =
    PlaySessionsCompanion Function({
      Value<int> id,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
    });
typedef $$PlaySessionsTableUpdateCompanionBuilder =
    PlaySessionsCompanion Function({
      Value<int> id,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
    });

final class $$PlaySessionsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaySessionsTable, PlaySession> {
  $$PlaySessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoundsTable, List<Round>> _roundsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.rounds,
    aliasName: 'play_sessions__id__rounds__session_id',
  );

  $$RoundsTableProcessedTableManager get roundsRefs {
    final manager = $$RoundsTableTableManager(
      $_db,
      $_db.rounds,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_roundsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaySessionsTable> {
  $$PlaySessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> roundsRefs(
    Expression<bool> Function($$RoundsTableFilterComposer f) f,
  ) {
    final $$RoundsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableFilterComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaySessionsTable> {
  $$PlaySessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaySessionsTable> {
  $$PlaySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  Expression<T> roundsRefs<T extends Object>(
    Expression<T> Function($$RoundsTableAnnotationComposer a) f,
  ) {
    final $$RoundsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableAnnotationComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaySessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaySessionsTable,
          PlaySession,
          $$PlaySessionsTableFilterComposer,
          $$PlaySessionsTableOrderingComposer,
          $$PlaySessionsTableAnnotationComposer,
          $$PlaySessionsTableCreateCompanionBuilder,
          $$PlaySessionsTableUpdateCompanionBuilder,
          (PlaySession, $$PlaySessionsTableReferences),
          PlaySession,
          PrefetchHooks Function({bool roundsRefs})
        > {
  $$PlaySessionsTableTableManager(_$AppDatabase db, $PlaySessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
              }) => PlaySessionsCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
              }) => PlaySessionsCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaySessionsTable, PlaySession>(table),
                  $$PlaySessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({roundsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (roundsRefs) db.rounds],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (roundsRefs)
                    await $_getPrefetchedDataByColumns<
                      PlaySession,
                      $PlaySessionsTable,
                      Round,
                      $RoundsTable
                    >(
                      currentTable: table,
                      referencedTable: $$PlaySessionsTableReferences
                          ._roundsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlaySessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).roundsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'session_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlaySessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaySessionsTable,
      PlaySession,
      $$PlaySessionsTableFilterComposer,
      $$PlaySessionsTableOrderingComposer,
      $$PlaySessionsTableAnnotationComposer,
      $$PlaySessionsTableCreateCompanionBuilder,
      $$PlaySessionsTableUpdateCompanionBuilder,
      (PlaySession, $$PlaySessionsTableReferences),
      PlaySession,
      PrefetchHooks Function({bool roundsRefs})
    >;
typedef $$RoundsTableCreateCompanionBuilder = RoundsCompanion Function({
  Value<int> id,
  required int sessionId,
  required String topicId,
  Value<int> level,
  required DateTime startedAt,
  Value<int> score,
  Value<int> durationMs,
  Value<int> stars,
  Value<DateTime?> finishedAt,
  Value<String> kind,
});
typedef $$RoundsTableUpdateCompanionBuilder = RoundsCompanion Function({
  Value<int> id,
  Value<int> sessionId,
  Value<String> topicId,
  Value<int> level,
  Value<DateTime> startedAt,
  Value<int> score,
  Value<int> durationMs,
  Value<int> stars,
  Value<DateTime?> finishedAt,
  Value<String> kind,
});

final class $$RoundsTableReferences
    extends BaseReferences<_$AppDatabase, $RoundsTable, Round> {
  $$RoundsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlaySessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.playSessions.createAlias('rounds__session_id__play_sessions__id');

  $$PlaySessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$PlaySessionsTableTableManager(
      $_db,
      $_db.playSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AttemptsTable, List<Attempt>> _attemptsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.attempts,
    aliasName: 'rounds__id__attempts__round_id',
  );

  $$AttemptsTableProcessedTableManager get attemptsRefs {
    final manager = $$AttemptsTableTableManager(
      $_db,
      $_db.attempts,
    ).filter((f) => f.roundId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attemptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoundsTableFilterComposer
    extends Composer<_$AppDatabase, $RoundsTable> {
  $$RoundsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaySessionsTableFilterComposer get sessionId {
    final $$PlaySessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.playSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaySessionsTableFilterComposer(
            $db: $db,
            $table: $db.playSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> attemptsRefs(
    Expression<bool> Function($$AttemptsTableFilterComposer f) f,
  ) {
    final $$AttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.roundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableFilterComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoundsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoundsTable> {
  $$RoundsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaySessionsTableOrderingComposer get sessionId {
    final $$PlaySessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.playSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaySessionsTableOrderingComposer(
            $db: $db,
            $table: $db.playSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoundsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoundsTable> {
  $$RoundsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stars =>
      $composableBuilder(column: $table.stars, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  $$PlaySessionsTableAnnotationComposer get sessionId {
    final $$PlaySessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.playSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaySessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.playSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> attemptsRefs<T extends Object>(
    Expression<T> Function($$AttemptsTableAnnotationComposer a) f,
  ) {
    final $$AttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.roundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoundsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoundsTable,
          Round,
          $$RoundsTableFilterComposer,
          $$RoundsTableOrderingComposer,
          $$RoundsTableAnnotationComposer,
          $$RoundsTableCreateCompanionBuilder,
          $$RoundsTableUpdateCompanionBuilder,
          (Round, $$RoundsTableReferences),
          Round,
          PrefetchHooks Function({bool sessionId, bool attemptsRefs})
        > {
  $$RoundsTableTableManager(_$AppDatabase db, $RoundsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoundsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoundsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoundsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> topicId = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> stars = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<String> kind = const Value.absent(),
              }) => RoundsCompanion(
                id: id,
                sessionId: sessionId,
                topicId: topicId,
                level: level,
                startedAt: startedAt,
                score: score,
                durationMs: durationMs,
                stars: stars,
                finishedAt: finishedAt,
                kind: kind,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String topicId,
                Value<int> level = const Value.absent(),
                required DateTime startedAt,
                Value<int> score = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> stars = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<String> kind = const Value.absent(),
              }) => RoundsCompanion.insert(
                id: id,
                sessionId: sessionId,
                topicId: topicId,
                level: level,
                startedAt: startedAt,
                score: score,
                durationMs: durationMs,
                stars: stars,
                finishedAt: finishedAt,
                kind: kind,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoundsTable, Round>(table),
                  $$RoundsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, attemptsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (attemptsRefs) db.attempts],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$RoundsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$RoundsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (attemptsRefs)
                    await $_getPrefetchedDataByColumns<
                      Round,
                      $RoundsTable,
                      Attempt,
                      $AttemptsTable
                    >(
                      currentTable: table,
                      referencedTable: $$RoundsTableReferences
                          ._attemptsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RoundsTableReferences(db, table, p0).attemptsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'round_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoundsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoundsTable,
      Round,
      $$RoundsTableFilterComposer,
      $$RoundsTableOrderingComposer,
      $$RoundsTableAnnotationComposer,
      $$RoundsTableCreateCompanionBuilder,
      $$RoundsTableUpdateCompanionBuilder,
      (Round, $$RoundsTableReferences),
      Round,
      PrefetchHooks Function({bool sessionId, bool attemptsRefs})
    >;
typedef $$AttemptsTableCreateCompanionBuilder = AttemptsCompanion Function({
  Value<int> id,
  required int roundId,
  required String questionId,
  required String answerGiven,
  required bool correct,
  required int timeMs,
  required DateTime answeredAt,
});
typedef $$AttemptsTableUpdateCompanionBuilder = AttemptsCompanion Function({
  Value<int> id,
  Value<int> roundId,
  Value<String> questionId,
  Value<String> answerGiven,
  Value<bool> correct,
  Value<int> timeMs,
  Value<DateTime> answeredAt,
});

final class $$AttemptsTableReferences
    extends BaseReferences<_$AppDatabase, $AttemptsTable, Attempt> {
  $$AttemptsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoundsTable _roundIdTable(_$AppDatabase db) =>
      db.rounds.createAlias('attempts__round_id__rounds__id');

  $$RoundsTableProcessedTableManager get roundId {
    final $_column = $_itemColumn<int>('round_id')!;

    final manager = $$RoundsTableTableManager(
      $_db,
      $_db.rounds,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roundIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answerGiven => $composableBuilder(
    column: $table.answerGiven,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeMs => $composableBuilder(
    column: $table.timeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RoundsTableFilterComposer get roundId {
    final $$RoundsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableFilterComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answerGiven => $composableBuilder(
    column: $table.answerGiven,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeMs => $composableBuilder(
    column: $table.timeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoundsTableOrderingComposer get roundId {
    final $$RoundsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableOrderingComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get answerGiven => $composableBuilder(
    column: $table.answerGiven,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<int> get timeMs =>
      $composableBuilder(column: $table.timeMs, builder: (column) => column);

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );

  $$RoundsTableAnnotationComposer get roundId {
    final $$RoundsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableAnnotationComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttemptsTable,
          Attempt,
          $$AttemptsTableFilterComposer,
          $$AttemptsTableOrderingComposer,
          $$AttemptsTableAnnotationComposer,
          $$AttemptsTableCreateCompanionBuilder,
          $$AttemptsTableUpdateCompanionBuilder,
          (Attempt, $$AttemptsTableReferences),
          Attempt,
          PrefetchHooks Function({bool roundId})
        > {
  $$AttemptsTableTableManager(_$AppDatabase db, $AttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> roundId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> answerGiven = const Value.absent(),
                Value<bool> correct = const Value.absent(),
                Value<int> timeMs = const Value.absent(),
                Value<DateTime> answeredAt = const Value.absent(),
              }) => AttemptsCompanion(
                id: id,
                roundId: roundId,
                questionId: questionId,
                answerGiven: answerGiven,
                correct: correct,
                timeMs: timeMs,
                answeredAt: answeredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int roundId,
                required String questionId,
                required String answerGiven,
                required bool correct,
                required int timeMs,
                required DateTime answeredAt,
              }) => AttemptsCompanion.insert(
                id: id,
                roundId: roundId,
                questionId: questionId,
                answerGiven: answerGiven,
                correct: correct,
                timeMs: timeMs,
                answeredAt: answeredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttemptsTable, Attempt>(table),
                  $$AttemptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({roundId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (roundId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.roundId,
                        referencedTable: $$AttemptsTableReferences
                            ._roundIdTable(db),
                        referencedColumn: $$AttemptsTableReferences
                            ._roundIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttemptsTable,
      Attempt,
      $$AttemptsTableFilterComposer,
      $$AttemptsTableOrderingComposer,
      $$AttemptsTableAnnotationComposer,
      $$AttemptsTableCreateCompanionBuilder,
      $$AttemptsTableUpdateCompanionBuilder,
      (Attempt, $$AttemptsTableReferences),
      Attempt,
      PrefetchHooks Function({bool roundId})
    >;
typedef $$DailyUsageTableCreateCompanionBuilder = DailyUsageCompanion Function({
  required String day,
  Value<int> secondsUsed,
  Value<int> extraSecondsGranted,
  Value<int> rowid,
});
typedef $$DailyUsageTableUpdateCompanionBuilder = DailyUsageCompanion Function({
  Value<String> day,
  Value<int> secondsUsed,
  Value<int> extraSecondsGranted,
  Value<int> rowid,
});

class $$DailyUsageTableFilterComposer
    extends Composer<_$AppDatabase, $DailyUsageTable> {
  $$DailyUsageTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get secondsUsed => $composableBuilder(
    column: $table.secondsUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get extraSecondsGranted => $composableBuilder(
    column: $table.extraSecondsGranted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyUsageTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyUsageTable> {
  $$DailyUsageTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get secondsUsed => $composableBuilder(
    column: $table.secondsUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get extraSecondsGranted => $composableBuilder(
    column: $table.extraSecondsGranted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyUsageTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyUsageTable> {
  $$DailyUsageTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get secondsUsed => $composableBuilder(
    column: $table.secondsUsed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get extraSecondsGranted => $composableBuilder(
    column: $table.extraSecondsGranted,
    builder: (column) => column,
  );
}

class $$DailyUsageTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyUsageTable,
          DailyUsageData,
          $$DailyUsageTableFilterComposer,
          $$DailyUsageTableOrderingComposer,
          $$DailyUsageTableAnnotationComposer,
          $$DailyUsageTableCreateCompanionBuilder,
          $$DailyUsageTableUpdateCompanionBuilder,
          (
            DailyUsageData,
            BaseReferences<_$AppDatabase, $DailyUsageTable, DailyUsageData>,
          ),
          DailyUsageData,
          PrefetchHooks Function()
        > {
  $$DailyUsageTableTableManager(_$AppDatabase db, $DailyUsageTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyUsageTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyUsageTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyUsageTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<int> secondsUsed = const Value.absent(),
                Value<int> extraSecondsGranted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyUsageCompanion(
                day: day,
                secondsUsed: secondsUsed,
                extraSecondsGranted: extraSecondsGranted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String day,
                Value<int> secondsUsed = const Value.absent(),
                Value<int> extraSecondsGranted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyUsageCompanion.insert(
                day: day,
                secondsUsed: secondsUsed,
                extraSecondsGranted: extraSecondsGranted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyUsageTable, DailyUsageData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DailyUsageTable,
                    DailyUsageData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyUsageTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyUsageTable,
      DailyUsageData,
      $$DailyUsageTableFilterComposer,
      $$DailyUsageTableOrderingComposer,
      $$DailyUsageTableAnnotationComposer,
      $$DailyUsageTableCreateCompanionBuilder,
      $$DailyUsageTableUpdateCompanionBuilder,
      (
        DailyUsageData,
        BaseReferences<_$AppDatabase, $DailyUsageTable, DailyUsageData>,
      ),
      DailyUsageData,
      PrefetchHooks Function()
    >;
typedef $$BadgesEarnedTableCreateCompanionBuilder =
    BadgesEarnedCompanion Function({
      required String badgeId,
      required DateTime earnedAt,
      Value<int> rowid,
    });
typedef $$BadgesEarnedTableUpdateCompanionBuilder =
    BadgesEarnedCompanion Function({
      Value<String> badgeId,
      Value<DateTime> earnedAt,
      Value<int> rowid,
    });

class $$BadgesEarnedTableFilterComposer
    extends Composer<_$AppDatabase, $BadgesEarnedTable> {
  $$BadgesEarnedTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get badgeId => $composableBuilder(
    column: $table.badgeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get earnedAt => $composableBuilder(
    column: $table.earnedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BadgesEarnedTableOrderingComposer
    extends Composer<_$AppDatabase, $BadgesEarnedTable> {
  $$BadgesEarnedTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get badgeId => $composableBuilder(
    column: $table.badgeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get earnedAt => $composableBuilder(
    column: $table.earnedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BadgesEarnedTableAnnotationComposer
    extends Composer<_$AppDatabase, $BadgesEarnedTable> {
  $$BadgesEarnedTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get badgeId =>
      $composableBuilder(column: $table.badgeId, builder: (column) => column);

  GeneratedColumn<DateTime> get earnedAt =>
      $composableBuilder(column: $table.earnedAt, builder: (column) => column);
}

class $$BadgesEarnedTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BadgesEarnedTable,
          BadgesEarnedData,
          $$BadgesEarnedTableFilterComposer,
          $$BadgesEarnedTableOrderingComposer,
          $$BadgesEarnedTableAnnotationComposer,
          $$BadgesEarnedTableCreateCompanionBuilder,
          $$BadgesEarnedTableUpdateCompanionBuilder,
          (
            BadgesEarnedData,
            BaseReferences<_$AppDatabase, $BadgesEarnedTable, BadgesEarnedData>,
          ),
          BadgesEarnedData,
          PrefetchHooks Function()
        > {
  $$BadgesEarnedTableTableManager(_$AppDatabase db, $BadgesEarnedTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BadgesEarnedTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BadgesEarnedTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BadgesEarnedTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> badgeId = const Value.absent(),
                Value<DateTime> earnedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BadgesEarnedCompanion(
                badgeId: badgeId,
                earnedAt: earnedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String badgeId,
                required DateTime earnedAt,
                Value<int> rowid = const Value.absent(),
              }) => BadgesEarnedCompanion.insert(
                badgeId: badgeId,
                earnedAt: earnedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BadgesEarnedTable, BadgesEarnedData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BadgesEarnedTable,
                    BadgesEarnedData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BadgesEarnedTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BadgesEarnedTable,
      BadgesEarnedData,
      $$BadgesEarnedTableFilterComposer,
      $$BadgesEarnedTableOrderingComposer,
      $$BadgesEarnedTableAnnotationComposer,
      $$BadgesEarnedTableCreateCompanionBuilder,
      $$BadgesEarnedTableUpdateCompanionBuilder,
      (
        BadgesEarnedData,
        BaseReferences<_$AppDatabase, $BadgesEarnedTable, BadgesEarnedData>,
      ),
      BadgesEarnedData,
      PrefetchHooks Function()
    >;
typedef $$PinLockoutTableCreateCompanionBuilder = PinLockoutCompanion Function({
  Value<int> id,
  Value<int> failedCount,
  Value<DateTime?> lockedUntil,
});
typedef $$PinLockoutTableUpdateCompanionBuilder = PinLockoutCompanion Function({
  Value<int> id,
  Value<int> failedCount,
  Value<DateTime?> lockedUntil,
});

class $$PinLockoutTableFilterComposer
    extends Composer<_$AppDatabase, $PinLockoutTable> {
  $$PinLockoutTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PinLockoutTableOrderingComposer
    extends Composer<_$AppDatabase, $PinLockoutTable> {
  $$PinLockoutTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PinLockoutTableAnnotationComposer
    extends Composer<_$AppDatabase, $PinLockoutTable> {
  $$PinLockoutTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => column,
  );
}

class $$PinLockoutTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PinLockoutTable,
          PinLockoutData,
          $$PinLockoutTableFilterComposer,
          $$PinLockoutTableOrderingComposer,
          $$PinLockoutTableAnnotationComposer,
          $$PinLockoutTableCreateCompanionBuilder,
          $$PinLockoutTableUpdateCompanionBuilder,
          (
            PinLockoutData,
            BaseReferences<_$AppDatabase, $PinLockoutTable, PinLockoutData>,
          ),
          PinLockoutData,
          PrefetchHooks Function()
        > {
  $$PinLockoutTableTableManager(_$AppDatabase db, $PinLockoutTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PinLockoutTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PinLockoutTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PinLockoutTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> failedCount = const Value.absent(),
                Value<DateTime?> lockedUntil = const Value.absent(),
              }) => PinLockoutCompanion(
                id: id,
                failedCount: failedCount,
                lockedUntil: lockedUntil,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> failedCount = const Value.absent(),
                Value<DateTime?> lockedUntil = const Value.absent(),
              }) => PinLockoutCompanion.insert(
                id: id,
                failedCount: failedCount,
                lockedUntil: lockedUntil,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PinLockoutTable, PinLockoutData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PinLockoutTable,
                    PinLockoutData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PinLockoutTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PinLockoutTable,
      PinLockoutData,
      $$PinLockoutTableFilterComposer,
      $$PinLockoutTableOrderingComposer,
      $$PinLockoutTableAnnotationComposer,
      $$PinLockoutTableCreateCompanionBuilder,
      $$PinLockoutTableUpdateCompanionBuilder,
      (
        PinLockoutData,
        BaseReferences<_$AppDatabase, $PinLockoutTable, PinLockoutData>,
      ),
      PinLockoutData,
      PrefetchHooks Function()
    >;
typedef $$ChildProfilesTableCreateCompanionBuilder =
    ChildProfilesCompanion Function({
      Value<int> id,
      required String nickname,
      required int schoolYear,
      Value<int?> schoolStartLevel,
      Value<int?> olympiadStartLevel,
      required DateTime updatedAt,
    });
typedef $$ChildProfilesTableUpdateCompanionBuilder =
    ChildProfilesCompanion Function({
      Value<int> id,
      Value<String> nickname,
      Value<int> schoolYear,
      Value<int?> schoolStartLevel,
      Value<int?> olympiadStartLevel,
      Value<DateTime> updatedAt,
    });

class $$ChildProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ChildProfilesTable> {
  $$ChildProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schoolYear => $composableBuilder(
    column: $table.schoolYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schoolStartLevel => $composableBuilder(
    column: $table.schoolStartLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get olympiadStartLevel => $composableBuilder(
    column: $table.olympiadStartLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChildProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChildProfilesTable> {
  $$ChildProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schoolYear => $composableBuilder(
    column: $table.schoolYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schoolStartLevel => $composableBuilder(
    column: $table.schoolStartLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get olympiadStartLevel => $composableBuilder(
    column: $table.olympiadStartLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChildProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChildProfilesTable> {
  $$ChildProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<int> get schoolYear => $composableBuilder(
    column: $table.schoolYear,
    builder: (column) => column,
  );

  GeneratedColumn<int> get schoolStartLevel => $composableBuilder(
    column: $table.schoolStartLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get olympiadStartLevel => $composableBuilder(
    column: $table.olympiadStartLevel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ChildProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChildProfilesTable,
          ProfileRow,
          $$ChildProfilesTableFilterComposer,
          $$ChildProfilesTableOrderingComposer,
          $$ChildProfilesTableAnnotationComposer,
          $$ChildProfilesTableCreateCompanionBuilder,
          $$ChildProfilesTableUpdateCompanionBuilder,
          (
            ProfileRow,
            BaseReferences<_$AppDatabase, $ChildProfilesTable, ProfileRow>,
          ),
          ProfileRow,
          PrefetchHooks Function()
        > {
  $$ChildProfilesTableTableManager(_$AppDatabase db, $ChildProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChildProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChildProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChildProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<int> schoolYear = const Value.absent(),
                Value<int?> schoolStartLevel = const Value.absent(),
                Value<int?> olympiadStartLevel = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ChildProfilesCompanion(
                id: id,
                nickname: nickname,
                schoolYear: schoolYear,
                schoolStartLevel: schoolStartLevel,
                olympiadStartLevel: olympiadStartLevel,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nickname,
                required int schoolYear,
                Value<int?> schoolStartLevel = const Value.absent(),
                Value<int?> olympiadStartLevel = const Value.absent(),
                required DateTime updatedAt,
              }) => ChildProfilesCompanion.insert(
                id: id,
                nickname: nickname,
                schoolYear: schoolYear,
                schoolStartLevel: schoolStartLevel,
                olympiadStartLevel: olympiadStartLevel,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChildProfilesTable, ProfileRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ChildProfilesTable,
                    ProfileRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChildProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChildProfilesTable,
      ProfileRow,
      $$ChildProfilesTableFilterComposer,
      $$ChildProfilesTableOrderingComposer,
      $$ChildProfilesTableAnnotationComposer,
      $$ChildProfilesTableCreateCompanionBuilder,
      $$ChildProfilesTableUpdateCompanionBuilder,
      (
        ProfileRow,
        BaseReferences<_$AppDatabase, $ChildProfilesTable, ProfileRow>,
      ),
      ProfileRow,
      PrefetchHooks Function()
    >;
typedef $$TopicUnlocksTableCreateCompanionBuilder =
    TopicUnlocksCompanion Function({
      required String topicId,
      required DateTime openedAt,
      Value<int> rowid,
    });
typedef $$TopicUnlocksTableUpdateCompanionBuilder =
    TopicUnlocksCompanion Function({
      Value<String> topicId,
      Value<DateTime> openedAt,
      Value<int> rowid,
    });

class $$TopicUnlocksTableFilterComposer
    extends Composer<_$AppDatabase, $TopicUnlocksTable> {
  $$TopicUnlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TopicUnlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $TopicUnlocksTable> {
  $$TopicUnlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TopicUnlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TopicUnlocksTable> {
  $$TopicUnlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);
}

class $$TopicUnlocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TopicUnlocksTable,
          TopicUnlock,
          $$TopicUnlocksTableFilterComposer,
          $$TopicUnlocksTableOrderingComposer,
          $$TopicUnlocksTableAnnotationComposer,
          $$TopicUnlocksTableCreateCompanionBuilder,
          $$TopicUnlocksTableUpdateCompanionBuilder,
          (
            TopicUnlock,
            BaseReferences<_$AppDatabase, $TopicUnlocksTable, TopicUnlock>,
          ),
          TopicUnlock,
          PrefetchHooks Function()
        > {
  $$TopicUnlocksTableTableManager(_$AppDatabase db, $TopicUnlocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TopicUnlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TopicUnlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TopicUnlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> topicId = const Value.absent(),
                Value<DateTime> openedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TopicUnlocksCompanion(
                topicId: topicId,
                openedAt: openedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String topicId,
                required DateTime openedAt,
                Value<int> rowid = const Value.absent(),
              }) => TopicUnlocksCompanion.insert(
                topicId: topicId,
                openedAt: openedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TopicUnlocksTable, TopicUnlock>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TopicUnlocksTable,
                    TopicUnlock
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TopicUnlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TopicUnlocksTable,
      TopicUnlock,
      $$TopicUnlocksTableFilterComposer,
      $$TopicUnlocksTableOrderingComposer,
      $$TopicUnlocksTableAnnotationComposer,
      $$TopicUnlocksTableCreateCompanionBuilder,
      $$TopicUnlocksTableUpdateCompanionBuilder,
      (
        TopicUnlock,
        BaseReferences<_$AppDatabase, $TopicUnlocksTable, TopicUnlock>,
      ),
      TopicUnlock,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$PlaySessionsTableTableManager get playSessions =>
      $$PlaySessionsTableTableManager(_db, _db.playSessions);
  $$RoundsTableTableManager get rounds =>
      $$RoundsTableTableManager(_db, _db.rounds);
  $$AttemptsTableTableManager get attempts =>
      $$AttemptsTableTableManager(_db, _db.attempts);
  $$DailyUsageTableTableManager get dailyUsage =>
      $$DailyUsageTableTableManager(_db, _db.dailyUsage);
  $$BadgesEarnedTableTableManager get badgesEarned =>
      $$BadgesEarnedTableTableManager(_db, _db.badgesEarned);
  $$PinLockoutTableTableManager get pinLockout =>
      $$PinLockoutTableTableManager(_db, _db.pinLockout);
  $$ChildProfilesTableTableManager get childProfiles =>
      $$ChildProfilesTableTableManager(_db, _db.childProfiles);
  $$TopicUnlocksTableTableManager get topicUnlocks =>
      $$TopicUnlocksTableTableManager(_db, _db.topicUnlocks);
}
