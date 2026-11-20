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
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: _newId,
  );
  static const VerificationMeta _bankCheckedAtMeta = const VerificationMeta(
    'bankCheckedAt',
  );
  @override
  late final GeneratedColumn<DateTime> bankCheckedAt =
      GeneratedColumn<DateTime>(
        'bank_checked_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _bankCheckNoteMeta = const VerificationMeta(
    'bankCheckNote',
  );
  @override
  late final GeneratedColumn<String> bankCheckNote = GeneratedColumn<String>(
    'bank_check_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentChildIdMeta = const VerificationMeta(
    'currentChildId',
  );
  @override
  late final GeneratedColumn<int> currentChildId = GeneratedColumn<int>(
    'current_child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _switchNeedsPinMeta = const VerificationMeta(
    'switchNeedsPin',
  );
  @override
  late final GeneratedColumn<bool> switchNeedsPin = GeneratedColumn<bool>(
    'switch_needs_pin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("switch_needs_pin" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _setupStepMeta = const VerificationMeta(
    'setupStep',
  );
  @override
  late final GeneratedColumn<String> setupStep = GeneratedColumn<String>(
    'setup_step',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _crashReportsMeta = const VerificationMeta(
    'crashReports',
  );
  @override
  late final GeneratedColumn<bool> crashReports = GeneratedColumn<bool>(
    'crash_reports',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("crash_reports" IN (0, 1))',
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
    deviceId,
    bankCheckedAt,
    bankCheckNote,
    currentChildId,
    switchNeedsPin,
    setupStep,
    crashReports,
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
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('bank_checked_at')) {
      context.handle(
        _bankCheckedAtMeta,
        bankCheckedAt.isAcceptableOrUnknown(
          data['bank_checked_at']!,
          _bankCheckedAtMeta,
        ),
      );
    }
    if (data.containsKey('bank_check_note')) {
      context.handle(
        _bankCheckNoteMeta,
        bankCheckNote.isAcceptableOrUnknown(
          data['bank_check_note']!,
          _bankCheckNoteMeta,
        ),
      );
    }
    if (data.containsKey('current_child_id')) {
      context.handle(
        _currentChildIdMeta,
        currentChildId.isAcceptableOrUnknown(
          data['current_child_id']!,
          _currentChildIdMeta,
        ),
      );
    }
    if (data.containsKey('switch_needs_pin')) {
      context.handle(
        _switchNeedsPinMeta,
        switchNeedsPin.isAcceptableOrUnknown(
          data['switch_needs_pin']!,
          _switchNeedsPinMeta,
        ),
      );
    }
    if (data.containsKey('setup_step')) {
      context.handle(
        _setupStepMeta,
        setupStep.isAcceptableOrUnknown(data['setup_step']!, _setupStepMeta),
      );
    }
    if (data.containsKey('crash_reports')) {
      context.handle(
        _crashReportsMeta,
        crashReports.isAcceptableOrUnknown(
          data['crash_reports']!,
          _crashReportsMeta,
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
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      bankCheckedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}bank_checked_at'],
      ),
      bankCheckNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_check_note'],
      ),
      currentChildId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_child_id'],
      )!,
      switchNeedsPin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}switch_needs_pin'],
      )!,
      setupStep: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setup_step'],
      ),
      crashReports: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}crash_reports'],
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

  /// This install's id (schema v7, FEAT-14): keys its own `daily_usage` rows.
  final String deviceId;

  /// Last successful bank check (schema v8, FEAT-15 D7); null = never.
  final DateTime? bankCheckedAt;

  /// Outcome of the last bank check attempt, shown on SCR-11 (BNK-12).
  final String? bankCheckNote;

  /// The child playing now (schema v9, FEAT-25 AD-3); a `children.id`.
  final int currentChildId;

  /// "Ask for PIN to change child" (FEAT-25 AD-4); device-only, like the PIN.
  final bool switchNeedsPin;

  /// The first-run setup step to resume at (schema v10, FEAT-26 AD-1), a
  /// `SetupStep` name; null = setup finished. Fresh databases start at
  /// `welcome` (set in onCreate).
  final String? setupStep;

  /// "Send crash reports" (schema v11, FEAT-24 AD-2, AD-3); device-only.
  final bool crashReports;
  const AppSetting({
    required this.id,
    this.pinHash,
    this.pinSalt,
    required this.dailyLimitMin,
    required this.bankVersion,
    required this.soundOn,
    required this.profilePending,
    required this.deviceId,
    this.bankCheckedAt,
    this.bankCheckNote,
    required this.currentChildId,
    required this.switchNeedsPin,
    this.setupStep,
    required this.crashReports,
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
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || bankCheckedAt != null) {
      map['bank_checked_at'] = Variable<DateTime>(bankCheckedAt);
    }
    if (!nullToAbsent || bankCheckNote != null) {
      map['bank_check_note'] = Variable<String>(bankCheckNote);
    }
    map['current_child_id'] = Variable<int>(currentChildId);
    map['switch_needs_pin'] = Variable<bool>(switchNeedsPin);
    if (!nullToAbsent || setupStep != null) {
      map['setup_step'] = Variable<String>(setupStep);
    }
    map['crash_reports'] = Variable<bool>(crashReports);
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
      deviceId: Value(deviceId),
      bankCheckedAt: bankCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(bankCheckedAt),
      bankCheckNote: bankCheckNote == null && nullToAbsent
          ? const Value.absent()
          : Value(bankCheckNote),
      currentChildId: Value(currentChildId),
      switchNeedsPin: Value(switchNeedsPin),
      setupStep: setupStep == null && nullToAbsent
          ? const Value.absent()
          : Value(setupStep),
      crashReports: Value(crashReports),
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
      deviceId: serializer.fromJson<String>(json['deviceId']),
      bankCheckedAt: serializer.fromJson<DateTime?>(json['bankCheckedAt']),
      bankCheckNote: serializer.fromJson<String?>(json['bankCheckNote']),
      currentChildId: serializer.fromJson<int>(json['currentChildId']),
      switchNeedsPin: serializer.fromJson<bool>(json['switchNeedsPin']),
      setupStep: serializer.fromJson<String?>(json['setupStep']),
      crashReports: serializer.fromJson<bool>(json['crashReports']),
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
      'deviceId': serializer.toJson<String>(deviceId),
      'bankCheckedAt': serializer.toJson<DateTime?>(bankCheckedAt),
      'bankCheckNote': serializer.toJson<String?>(bankCheckNote),
      'currentChildId': serializer.toJson<int>(currentChildId),
      'switchNeedsPin': serializer.toJson<bool>(switchNeedsPin),
      'setupStep': serializer.toJson<String?>(setupStep),
      'crashReports': serializer.toJson<bool>(crashReports),
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
    String? deviceId,
    Value<DateTime?> bankCheckedAt = const Value.absent(),
    Value<String?> bankCheckNote = const Value.absent(),
    int? currentChildId,
    bool? switchNeedsPin,
    Value<String?> setupStep = const Value.absent(),
    bool? crashReports,
  }) => AppSetting(
    id: id ?? this.id,
    pinHash: pinHash.present ? pinHash.value : this.pinHash,
    pinSalt: pinSalt.present ? pinSalt.value : this.pinSalt,
    dailyLimitMin: dailyLimitMin ?? this.dailyLimitMin,
    bankVersion: bankVersion ?? this.bankVersion,
    soundOn: soundOn ?? this.soundOn,
    profilePending: profilePending ?? this.profilePending,
    deviceId: deviceId ?? this.deviceId,
    bankCheckedAt: bankCheckedAt.present
        ? bankCheckedAt.value
        : this.bankCheckedAt,
    bankCheckNote: bankCheckNote.present
        ? bankCheckNote.value
        : this.bankCheckNote,
    currentChildId: currentChildId ?? this.currentChildId,
    switchNeedsPin: switchNeedsPin ?? this.switchNeedsPin,
    setupStep: setupStep.present ? setupStep.value : this.setupStep,
    crashReports: crashReports ?? this.crashReports,
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
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      bankCheckedAt: data.bankCheckedAt.present
          ? data.bankCheckedAt.value
          : this.bankCheckedAt,
      bankCheckNote: data.bankCheckNote.present
          ? data.bankCheckNote.value
          : this.bankCheckNote,
      currentChildId: data.currentChildId.present
          ? data.currentChildId.value
          : this.currentChildId,
      switchNeedsPin: data.switchNeedsPin.present
          ? data.switchNeedsPin.value
          : this.switchNeedsPin,
      setupStep: data.setupStep.present ? data.setupStep.value : this.setupStep,
      crashReports: data.crashReports.present
          ? data.crashReports.value
          : this.crashReports,
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
          ..write('profilePending: $profilePending, ')
          ..write('deviceId: $deviceId, ')
          ..write('bankCheckedAt: $bankCheckedAt, ')
          ..write('bankCheckNote: $bankCheckNote, ')
          ..write('currentChildId: $currentChildId, ')
          ..write('switchNeedsPin: $switchNeedsPin, ')
          ..write('setupStep: $setupStep, ')
          ..write('crashReports: $crashReports')
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
    deviceId,
    bankCheckedAt,
    bankCheckNote,
    currentChildId,
    switchNeedsPin,
    setupStep,
    crashReports,
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
          other.profilePending == this.profilePending &&
          other.deviceId == this.deviceId &&
          other.bankCheckedAt == this.bankCheckedAt &&
          other.bankCheckNote == this.bankCheckNote &&
          other.currentChildId == this.currentChildId &&
          other.switchNeedsPin == this.switchNeedsPin &&
          other.setupStep == this.setupStep &&
          other.crashReports == this.crashReports);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<String?> pinHash;
  final Value<String?> pinSalt;
  final Value<int> dailyLimitMin;
  final Value<int> bankVersion;
  final Value<bool> soundOn;
  final Value<bool> profilePending;
  final Value<String> deviceId;
  final Value<DateTime?> bankCheckedAt;
  final Value<String?> bankCheckNote;
  final Value<int> currentChildId;
  final Value<bool> switchNeedsPin;
  final Value<String?> setupStep;
  final Value<bool> crashReports;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.pinSalt = const Value.absent(),
    this.dailyLimitMin = const Value.absent(),
    this.bankVersion = const Value.absent(),
    this.soundOn = const Value.absent(),
    this.profilePending = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.bankCheckedAt = const Value.absent(),
    this.bankCheckNote = const Value.absent(),
    this.currentChildId = const Value.absent(),
    this.switchNeedsPin = const Value.absent(),
    this.setupStep = const Value.absent(),
    this.crashReports = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.pinSalt = const Value.absent(),
    this.dailyLimitMin = const Value.absent(),
    this.bankVersion = const Value.absent(),
    this.soundOn = const Value.absent(),
    this.profilePending = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.bankCheckedAt = const Value.absent(),
    this.bankCheckNote = const Value.absent(),
    this.currentChildId = const Value.absent(),
    this.switchNeedsPin = const Value.absent(),
    this.setupStep = const Value.absent(),
    this.crashReports = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<String>? pinHash,
    Expression<String>? pinSalt,
    Expression<int>? dailyLimitMin,
    Expression<int>? bankVersion,
    Expression<bool>? soundOn,
    Expression<bool>? profilePending,
    Expression<String>? deviceId,
    Expression<DateTime>? bankCheckedAt,
    Expression<String>? bankCheckNote,
    Expression<int>? currentChildId,
    Expression<bool>? switchNeedsPin,
    Expression<String>? setupStep,
    Expression<bool>? crashReports,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pinHash != null) 'pin_hash': pinHash,
      if (pinSalt != null) 'pin_salt': pinSalt,
      if (dailyLimitMin != null) 'daily_limit_min': dailyLimitMin,
      if (bankVersion != null) 'bank_version': bankVersion,
      if (soundOn != null) 'sound_on': soundOn,
      if (profilePending != null) 'profile_pending': profilePending,
      if (deviceId != null) 'device_id': deviceId,
      if (bankCheckedAt != null) 'bank_checked_at': bankCheckedAt,
      if (bankCheckNote != null) 'bank_check_note': bankCheckNote,
      if (currentChildId != null) 'current_child_id': currentChildId,
      if (switchNeedsPin != null) 'switch_needs_pin': switchNeedsPin,
      if (setupStep != null) 'setup_step': setupStep,
      if (crashReports != null) 'crash_reports': crashReports,
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
    Value<String>? deviceId,
    Value<DateTime?>? bankCheckedAt,
    Value<String?>? bankCheckNote,
    Value<int>? currentChildId,
    Value<bool>? switchNeedsPin,
    Value<String?>? setupStep,
    Value<bool>? crashReports,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      pinHash: pinHash ?? this.pinHash,
      pinSalt: pinSalt ?? this.pinSalt,
      dailyLimitMin: dailyLimitMin ?? this.dailyLimitMin,
      bankVersion: bankVersion ?? this.bankVersion,
      soundOn: soundOn ?? this.soundOn,
      profilePending: profilePending ?? this.profilePending,
      deviceId: deviceId ?? this.deviceId,
      bankCheckedAt: bankCheckedAt ?? this.bankCheckedAt,
      bankCheckNote: bankCheckNote ?? this.bankCheckNote,
      currentChildId: currentChildId ?? this.currentChildId,
      switchNeedsPin: switchNeedsPin ?? this.switchNeedsPin,
      setupStep: setupStep ?? this.setupStep,
      crashReports: crashReports ?? this.crashReports,
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
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (bankCheckedAt.present) {
      map['bank_checked_at'] = Variable<DateTime>(bankCheckedAt.value);
    }
    if (bankCheckNote.present) {
      map['bank_check_note'] = Variable<String>(bankCheckNote.value);
    }
    if (currentChildId.present) {
      map['current_child_id'] = Variable<int>(currentChildId.value);
    }
    if (switchNeedsPin.present) {
      map['switch_needs_pin'] = Variable<bool>(switchNeedsPin.value);
    }
    if (setupStep.present) {
      map['setup_step'] = Variable<String>(setupStep.value);
    }
    if (crashReports.present) {
      map['crash_reports'] = Variable<bool>(crashReports.value);
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
          ..write('profilePending: $profilePending, ')
          ..write('deviceId: $deviceId, ')
          ..write('bankCheckedAt: $bankCheckedAt, ')
          ..write('bankCheckNote: $bankCheckNote, ')
          ..write('currentChildId: $currentChildId, ')
          ..write('switchNeedsPin: $switchNeedsPin, ')
          ..write('setupStep: $setupStep, ')
          ..write('crashReports: $crashReports')
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
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: _newId,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<int> dirty = GeneratedColumn<int>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    childId,
    topicId,
    level,
    startedAt,
    score,
    durationMs,
    stars,
    finishedAt,
    kind,
    uuid,
    dirty,
    remoteId,
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
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
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
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
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
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
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
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dirty'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
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

  /// The child who played it (schema v9, FEAT-25).
  final int childId;
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

  /// Sync id (schema v7, FEAT-14); [dirty] > 0 means not yet on the server,
  /// [remoteId] is the server record once known.
  final String uuid;
  final int dirty;
  final String? remoteId;
  const Round({
    required this.id,
    required this.sessionId,
    required this.childId,
    required this.topicId,
    required this.level,
    required this.startedAt,
    required this.score,
    required this.durationMs,
    required this.stars,
    this.finishedAt,
    required this.kind,
    required this.uuid,
    required this.dirty,
    this.remoteId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['child_id'] = Variable<int>(childId);
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
    map['uuid'] = Variable<String>(uuid);
    map['dirty'] = Variable<int>(dirty);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    return map;
  }

  RoundsCompanion toCompanion(bool nullToAbsent) {
    return RoundsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      childId: Value(childId),
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
      uuid: Value(uuid),
      dirty: Value(dirty),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
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
      childId: serializer.fromJson<int>(json['childId']),
      topicId: serializer.fromJson<String>(json['topicId']),
      level: serializer.fromJson<int>(json['level']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      score: serializer.fromJson<int>(json['score']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      stars: serializer.fromJson<int>(json['stars']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      kind: serializer.fromJson<String>(json['kind']),
      uuid: serializer.fromJson<String>(json['uuid']),
      dirty: serializer.fromJson<int>(json['dirty']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'childId': serializer.toJson<int>(childId),
      'topicId': serializer.toJson<String>(topicId),
      'level': serializer.toJson<int>(level),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'score': serializer.toJson<int>(score),
      'durationMs': serializer.toJson<int>(durationMs),
      'stars': serializer.toJson<int>(stars),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'kind': serializer.toJson<String>(kind),
      'uuid': serializer.toJson<String>(uuid),
      'dirty': serializer.toJson<int>(dirty),
      'remoteId': serializer.toJson<String?>(remoteId),
    };
  }

  Round copyWith({
    int? id,
    int? sessionId,
    int? childId,
    String? topicId,
    int? level,
    DateTime? startedAt,
    int? score,
    int? durationMs,
    int? stars,
    Value<DateTime?> finishedAt = const Value.absent(),
    String? kind,
    String? uuid,
    int? dirty,
    Value<String?> remoteId = const Value.absent(),
  }) => Round(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    childId: childId ?? this.childId,
    topicId: topicId ?? this.topicId,
    level: level ?? this.level,
    startedAt: startedAt ?? this.startedAt,
    score: score ?? this.score,
    durationMs: durationMs ?? this.durationMs,
    stars: stars ?? this.stars,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    kind: kind ?? this.kind,
    uuid: uuid ?? this.uuid,
    dirty: dirty ?? this.dirty,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
  );
  Round copyWithCompanion(RoundsCompanion data) {
    return Round(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      childId: data.childId.present ? data.childId.value : this.childId,
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
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Round(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('childId: $childId, ')
          ..write('topicId: $topicId, ')
          ..write('level: $level, ')
          ..write('startedAt: $startedAt, ')
          ..write('score: $score, ')
          ..write('durationMs: $durationMs, ')
          ..write('stars: $stars, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('kind: $kind, ')
          ..write('uuid: $uuid, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    childId,
    topicId,
    level,
    startedAt,
    score,
    durationMs,
    stars,
    finishedAt,
    kind,
    uuid,
    dirty,
    remoteId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Round &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.childId == this.childId &&
          other.topicId == this.topicId &&
          other.level == this.level &&
          other.startedAt == this.startedAt &&
          other.score == this.score &&
          other.durationMs == this.durationMs &&
          other.stars == this.stars &&
          other.finishedAt == this.finishedAt &&
          other.kind == this.kind &&
          other.uuid == this.uuid &&
          other.dirty == this.dirty &&
          other.remoteId == this.remoteId);
}

class RoundsCompanion extends UpdateCompanion<Round> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> childId;
  final Value<String> topicId;
  final Value<int> level;
  final Value<DateTime> startedAt;
  final Value<int> score;
  final Value<int> durationMs;
  final Value<int> stars;
  final Value<DateTime?> finishedAt;
  final Value<String> kind;
  final Value<String> uuid;
  final Value<int> dirty;
  final Value<String?> remoteId;
  const RoundsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.childId = const Value.absent(),
    this.topicId = const Value.absent(),
    this.level = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.score = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.stars = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.kind = const Value.absent(),
    this.uuid = const Value.absent(),
    this.dirty = const Value.absent(),
    this.remoteId = const Value.absent(),
  });
  RoundsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int childId,
    required String topicId,
    this.level = const Value.absent(),
    required DateTime startedAt,
    this.score = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.stars = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.kind = const Value.absent(),
    this.uuid = const Value.absent(),
    this.dirty = const Value.absent(),
    this.remoteId = const Value.absent(),
  }) : sessionId = Value(sessionId),
       childId = Value(childId),
       topicId = Value(topicId),
       startedAt = Value(startedAt);
  static Insertable<Round> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? childId,
    Expression<String>? topicId,
    Expression<int>? level,
    Expression<DateTime>? startedAt,
    Expression<int>? score,
    Expression<int>? durationMs,
    Expression<int>? stars,
    Expression<DateTime>? finishedAt,
    Expression<String>? kind,
    Expression<String>? uuid,
    Expression<int>? dirty,
    Expression<String>? remoteId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (childId != null) 'child_id': childId,
      if (topicId != null) 'topic_id': topicId,
      if (level != null) 'level': level,
      if (startedAt != null) 'started_at': startedAt,
      if (score != null) 'score': score,
      if (durationMs != null) 'duration_ms': durationMs,
      if (stars != null) 'stars': stars,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (kind != null) 'kind': kind,
      if (uuid != null) 'uuid': uuid,
      if (dirty != null) 'dirty': dirty,
      if (remoteId != null) 'remote_id': remoteId,
    });
  }

  RoundsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? childId,
    Value<String>? topicId,
    Value<int>? level,
    Value<DateTime>? startedAt,
    Value<int>? score,
    Value<int>? durationMs,
    Value<int>? stars,
    Value<DateTime?>? finishedAt,
    Value<String>? kind,
    Value<String>? uuid,
    Value<int>? dirty,
    Value<String?>? remoteId,
  }) {
    return RoundsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      childId: childId ?? this.childId,
      topicId: topicId ?? this.topicId,
      level: level ?? this.level,
      startedAt: startedAt ?? this.startedAt,
      score: score ?? this.score,
      durationMs: durationMs ?? this.durationMs,
      stars: stars ?? this.stars,
      finishedAt: finishedAt ?? this.finishedAt,
      kind: kind ?? this.kind,
      uuid: uuid ?? this.uuid,
      dirty: dirty ?? this.dirty,
      remoteId: remoteId ?? this.remoteId,
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
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
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
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<int>(dirty.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoundsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('childId: $childId, ')
          ..write('topicId: $topicId, ')
          ..write('level: $level, ')
          ..write('startedAt: $startedAt, ')
          ..write('score: $score, ')
          ..write('durationMs: $durationMs, ')
          ..write('stars: $stars, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('kind: $kind, ')
          ..write('uuid: $uuid, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
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
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: _newId,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<int> dirty = GeneratedColumn<int>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    roundId,
    childId,
    questionId,
    answerGiven,
    correct,
    timeMs,
    answeredAt,
    uuid,
    dirty,
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
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
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
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
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
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
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
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dirty'],
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

  /// Same as the round's (schema v9), so per-child queries need no join.
  final int childId;
  final String questionId;
  final String answerGiven;
  final bool correct;
  final int timeMs;
  final DateTime answeredAt;

  /// Sync id and unsent flag (schema v7, FEAT-14). Attempts never change.
  final String uuid;
  final int dirty;
  const Attempt({
    required this.id,
    required this.roundId,
    required this.childId,
    required this.questionId,
    required this.answerGiven,
    required this.correct,
    required this.timeMs,
    required this.answeredAt,
    required this.uuid,
    required this.dirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['round_id'] = Variable<int>(roundId);
    map['child_id'] = Variable<int>(childId);
    map['question_id'] = Variable<String>(questionId);
    map['answer_given'] = Variable<String>(answerGiven);
    map['correct'] = Variable<bool>(correct);
    map['time_ms'] = Variable<int>(timeMs);
    map['answered_at'] = Variable<DateTime>(answeredAt);
    map['uuid'] = Variable<String>(uuid);
    map['dirty'] = Variable<int>(dirty);
    return map;
  }

  AttemptsCompanion toCompanion(bool nullToAbsent) {
    return AttemptsCompanion(
      id: Value(id),
      roundId: Value(roundId),
      childId: Value(childId),
      questionId: Value(questionId),
      answerGiven: Value(answerGiven),
      correct: Value(correct),
      timeMs: Value(timeMs),
      answeredAt: Value(answeredAt),
      uuid: Value(uuid),
      dirty: Value(dirty),
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
      childId: serializer.fromJson<int>(json['childId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      answerGiven: serializer.fromJson<String>(json['answerGiven']),
      correct: serializer.fromJson<bool>(json['correct']),
      timeMs: serializer.fromJson<int>(json['timeMs']),
      answeredAt: serializer.fromJson<DateTime>(json['answeredAt']),
      uuid: serializer.fromJson<String>(json['uuid']),
      dirty: serializer.fromJson<int>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'roundId': serializer.toJson<int>(roundId),
      'childId': serializer.toJson<int>(childId),
      'questionId': serializer.toJson<String>(questionId),
      'answerGiven': serializer.toJson<String>(answerGiven),
      'correct': serializer.toJson<bool>(correct),
      'timeMs': serializer.toJson<int>(timeMs),
      'answeredAt': serializer.toJson<DateTime>(answeredAt),
      'uuid': serializer.toJson<String>(uuid),
      'dirty': serializer.toJson<int>(dirty),
    };
  }

  Attempt copyWith({
    int? id,
    int? roundId,
    int? childId,
    String? questionId,
    String? answerGiven,
    bool? correct,
    int? timeMs,
    DateTime? answeredAt,
    String? uuid,
    int? dirty,
  }) => Attempt(
    id: id ?? this.id,
    roundId: roundId ?? this.roundId,
    childId: childId ?? this.childId,
    questionId: questionId ?? this.questionId,
    answerGiven: answerGiven ?? this.answerGiven,
    correct: correct ?? this.correct,
    timeMs: timeMs ?? this.timeMs,
    answeredAt: answeredAt ?? this.answeredAt,
    uuid: uuid ?? this.uuid,
    dirty: dirty ?? this.dirty,
  );
  Attempt copyWithCompanion(AttemptsCompanion data) {
    return Attempt(
      id: data.id.present ? data.id.value : this.id,
      roundId: data.roundId.present ? data.roundId.value : this.roundId,
      childId: data.childId.present ? data.childId.value : this.childId,
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
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attempt(')
          ..write('id: $id, ')
          ..write('roundId: $roundId, ')
          ..write('childId: $childId, ')
          ..write('questionId: $questionId, ')
          ..write('answerGiven: $answerGiven, ')
          ..write('correct: $correct, ')
          ..write('timeMs: $timeMs, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('uuid: $uuid, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    roundId,
    childId,
    questionId,
    answerGiven,
    correct,
    timeMs,
    answeredAt,
    uuid,
    dirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attempt &&
          other.id == this.id &&
          other.roundId == this.roundId &&
          other.childId == this.childId &&
          other.questionId == this.questionId &&
          other.answerGiven == this.answerGiven &&
          other.correct == this.correct &&
          other.timeMs == this.timeMs &&
          other.answeredAt == this.answeredAt &&
          other.uuid == this.uuid &&
          other.dirty == this.dirty);
}

class AttemptsCompanion extends UpdateCompanion<Attempt> {
  final Value<int> id;
  final Value<int> roundId;
  final Value<int> childId;
  final Value<String> questionId;
  final Value<String> answerGiven;
  final Value<bool> correct;
  final Value<int> timeMs;
  final Value<DateTime> answeredAt;
  final Value<String> uuid;
  final Value<int> dirty;
  const AttemptsCompanion({
    this.id = const Value.absent(),
    this.roundId = const Value.absent(),
    this.childId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.answerGiven = const Value.absent(),
    this.correct = const Value.absent(),
    this.timeMs = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.uuid = const Value.absent(),
    this.dirty = const Value.absent(),
  });
  AttemptsCompanion.insert({
    this.id = const Value.absent(),
    required int roundId,
    required int childId,
    required String questionId,
    required String answerGiven,
    required bool correct,
    required int timeMs,
    required DateTime answeredAt,
    this.uuid = const Value.absent(),
    this.dirty = const Value.absent(),
  }) : roundId = Value(roundId),
       childId = Value(childId),
       questionId = Value(questionId),
       answerGiven = Value(answerGiven),
       correct = Value(correct),
       timeMs = Value(timeMs),
       answeredAt = Value(answeredAt);
  static Insertable<Attempt> custom({
    Expression<int>? id,
    Expression<int>? roundId,
    Expression<int>? childId,
    Expression<String>? questionId,
    Expression<String>? answerGiven,
    Expression<bool>? correct,
    Expression<int>? timeMs,
    Expression<DateTime>? answeredAt,
    Expression<String>? uuid,
    Expression<int>? dirty,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roundId != null) 'round_id': roundId,
      if (childId != null) 'child_id': childId,
      if (questionId != null) 'question_id': questionId,
      if (answerGiven != null) 'answer_given': answerGiven,
      if (correct != null) 'correct': correct,
      if (timeMs != null) 'time_ms': timeMs,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (uuid != null) 'uuid': uuid,
      if (dirty != null) 'dirty': dirty,
    });
  }

  AttemptsCompanion copyWith({
    Value<int>? id,
    Value<int>? roundId,
    Value<int>? childId,
    Value<String>? questionId,
    Value<String>? answerGiven,
    Value<bool>? correct,
    Value<int>? timeMs,
    Value<DateTime>? answeredAt,
    Value<String>? uuid,
    Value<int>? dirty,
  }) {
    return AttemptsCompanion(
      id: id ?? this.id,
      roundId: roundId ?? this.roundId,
      childId: childId ?? this.childId,
      questionId: questionId ?? this.questionId,
      answerGiven: answerGiven ?? this.answerGiven,
      correct: correct ?? this.correct,
      timeMs: timeMs ?? this.timeMs,
      answeredAt: answeredAt ?? this.answeredAt,
      uuid: uuid ?? this.uuid,
      dirty: dirty ?? this.dirty,
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
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
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
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<int>(dirty.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptsCompanion(')
          ..write('id: $id, ')
          ..write('roundId: $roundId, ')
          ..write('childId: $childId, ')
          ..write('questionId: $questionId, ')
          ..write('answerGiven: $answerGiven, ')
          ..write('correct: $correct, ')
          ..write('timeMs: $timeMs, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('uuid: $uuid, ')
          ..write('dirty: $dirty')
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
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
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
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<int> dirty = GeneratedColumn<int>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    childId,
    day,
    deviceId,
    secondsUsed,
    extraSecondsGranted,
    dirty,
    remoteId,
  ];
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
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
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
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {childId, day, deviceId};
  @override
  DailyUsageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyUsageData(
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      secondsUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seconds_used'],
      )!,
      extraSecondsGranted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}extra_seconds_granted'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dirty'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
    );
  }

  @override
  $DailyUsageTable createAlias(String alias) {
    return $DailyUsageTable(attachedDatabase, alias);
  }
}

class DailyUsageData extends DataClass implements Insertable<DailyUsageData> {
  final int childId;
  final String day;
  final String deviceId;
  final int secondsUsed;
  final int extraSecondsGranted;
  final int dirty;
  final String? remoteId;
  const DailyUsageData({
    required this.childId,
    required this.day,
    required this.deviceId,
    required this.secondsUsed,
    required this.extraSecondsGranted,
    required this.dirty,
    this.remoteId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['child_id'] = Variable<int>(childId);
    map['day'] = Variable<String>(day);
    map['device_id'] = Variable<String>(deviceId);
    map['seconds_used'] = Variable<int>(secondsUsed);
    map['extra_seconds_granted'] = Variable<int>(extraSecondsGranted);
    map['dirty'] = Variable<int>(dirty);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    return map;
  }

  DailyUsageCompanion toCompanion(bool nullToAbsent) {
    return DailyUsageCompanion(
      childId: Value(childId),
      day: Value(day),
      deviceId: Value(deviceId),
      secondsUsed: Value(secondsUsed),
      extraSecondsGranted: Value(extraSecondsGranted),
      dirty: Value(dirty),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
    );
  }

  factory DailyUsageData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyUsageData(
      childId: serializer.fromJson<int>(json['childId']),
      day: serializer.fromJson<String>(json['day']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      secondsUsed: serializer.fromJson<int>(json['secondsUsed']),
      extraSecondsGranted: serializer.fromJson<int>(
        json['extraSecondsGranted'],
      ),
      dirty: serializer.fromJson<int>(json['dirty']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'childId': serializer.toJson<int>(childId),
      'day': serializer.toJson<String>(day),
      'deviceId': serializer.toJson<String>(deviceId),
      'secondsUsed': serializer.toJson<int>(secondsUsed),
      'extraSecondsGranted': serializer.toJson<int>(extraSecondsGranted),
      'dirty': serializer.toJson<int>(dirty),
      'remoteId': serializer.toJson<String?>(remoteId),
    };
  }

  DailyUsageData copyWith({
    int? childId,
    String? day,
    String? deviceId,
    int? secondsUsed,
    int? extraSecondsGranted,
    int? dirty,
    Value<String?> remoteId = const Value.absent(),
  }) => DailyUsageData(
    childId: childId ?? this.childId,
    day: day ?? this.day,
    deviceId: deviceId ?? this.deviceId,
    secondsUsed: secondsUsed ?? this.secondsUsed,
    extraSecondsGranted: extraSecondsGranted ?? this.extraSecondsGranted,
    dirty: dirty ?? this.dirty,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
  );
  DailyUsageData copyWithCompanion(DailyUsageCompanion data) {
    return DailyUsageData(
      childId: data.childId.present ? data.childId.value : this.childId,
      day: data.day.present ? data.day.value : this.day,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      secondsUsed: data.secondsUsed.present
          ? data.secondsUsed.value
          : this.secondsUsed,
      extraSecondsGranted: data.extraSecondsGranted.present
          ? data.extraSecondsGranted.value
          : this.extraSecondsGranted,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyUsageData(')
          ..write('childId: $childId, ')
          ..write('day: $day, ')
          ..write('deviceId: $deviceId, ')
          ..write('secondsUsed: $secondsUsed, ')
          ..write('extraSecondsGranted: $extraSecondsGranted, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    childId,
    day,
    deviceId,
    secondsUsed,
    extraSecondsGranted,
    dirty,
    remoteId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyUsageData &&
          other.childId == this.childId &&
          other.day == this.day &&
          other.deviceId == this.deviceId &&
          other.secondsUsed == this.secondsUsed &&
          other.extraSecondsGranted == this.extraSecondsGranted &&
          other.dirty == this.dirty &&
          other.remoteId == this.remoteId);
}

class DailyUsageCompanion extends UpdateCompanion<DailyUsageData> {
  final Value<int> childId;
  final Value<String> day;
  final Value<String> deviceId;
  final Value<int> secondsUsed;
  final Value<int> extraSecondsGranted;
  final Value<int> dirty;
  final Value<String?> remoteId;
  final Value<int> rowid;
  const DailyUsageCompanion({
    this.childId = const Value.absent(),
    this.day = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.secondsUsed = const Value.absent(),
    this.extraSecondsGranted = const Value.absent(),
    this.dirty = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyUsageCompanion.insert({
    required int childId,
    required String day,
    required String deviceId,
    this.secondsUsed = const Value.absent(),
    this.extraSecondsGranted = const Value.absent(),
    this.dirty = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : childId = Value(childId),
       day = Value(day),
       deviceId = Value(deviceId);
  static Insertable<DailyUsageData> custom({
    Expression<int>? childId,
    Expression<String>? day,
    Expression<String>? deviceId,
    Expression<int>? secondsUsed,
    Expression<int>? extraSecondsGranted,
    Expression<int>? dirty,
    Expression<String>? remoteId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (childId != null) 'child_id': childId,
      if (day != null) 'day': day,
      if (deviceId != null) 'device_id': deviceId,
      if (secondsUsed != null) 'seconds_used': secondsUsed,
      if (extraSecondsGranted != null)
        'extra_seconds_granted': extraSecondsGranted,
      if (dirty != null) 'dirty': dirty,
      if (remoteId != null) 'remote_id': remoteId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyUsageCompanion copyWith({
    Value<int>? childId,
    Value<String>? day,
    Value<String>? deviceId,
    Value<int>? secondsUsed,
    Value<int>? extraSecondsGranted,
    Value<int>? dirty,
    Value<String?>? remoteId,
    Value<int>? rowid,
  }) {
    return DailyUsageCompanion(
      childId: childId ?? this.childId,
      day: day ?? this.day,
      deviceId: deviceId ?? this.deviceId,
      secondsUsed: secondsUsed ?? this.secondsUsed,
      extraSecondsGranted: extraSecondsGranted ?? this.extraSecondsGranted,
      dirty: dirty ?? this.dirty,
      remoteId: remoteId ?? this.remoteId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (secondsUsed.present) {
      map['seconds_used'] = Variable<int>(secondsUsed.value);
    }
    if (extraSecondsGranted.present) {
      map['extra_seconds_granted'] = Variable<int>(extraSecondsGranted.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<int>(dirty.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyUsageCompanion(')
          ..write('childId: $childId, ')
          ..write('day: $day, ')
          ..write('deviceId: $deviceId, ')
          ..write('secondsUsed: $secondsUsed, ')
          ..write('extraSecondsGranted: $extraSecondsGranted, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId, ')
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
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
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
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<int> dirty = GeneratedColumn<int>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    childId,
    badgeId,
    earnedAt,
    dirty,
    remoteId,
  ];
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
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
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
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {childId, badgeId};
  @override
  BadgesEarnedData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BadgesEarnedData(
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      badgeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}badge_id'],
      )!,
      earnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}earned_at'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dirty'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
    );
  }

  @override
  $BadgesEarnedTable createAlias(String alias) {
    return $BadgesEarnedTable(attachedDatabase, alias);
  }
}

class BadgesEarnedData extends DataClass
    implements Insertable<BadgesEarnedData> {
  final int childId;
  final String badgeId;
  final DateTime earnedAt;
  final int dirty;
  final String? remoteId;
  const BadgesEarnedData({
    required this.childId,
    required this.badgeId,
    required this.earnedAt,
    required this.dirty,
    this.remoteId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['child_id'] = Variable<int>(childId);
    map['badge_id'] = Variable<String>(badgeId);
    map['earned_at'] = Variable<DateTime>(earnedAt);
    map['dirty'] = Variable<int>(dirty);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    return map;
  }

  BadgesEarnedCompanion toCompanion(bool nullToAbsent) {
    return BadgesEarnedCompanion(
      childId: Value(childId),
      badgeId: Value(badgeId),
      earnedAt: Value(earnedAt),
      dirty: Value(dirty),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
    );
  }

  factory BadgesEarnedData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BadgesEarnedData(
      childId: serializer.fromJson<int>(json['childId']),
      badgeId: serializer.fromJson<String>(json['badgeId']),
      earnedAt: serializer.fromJson<DateTime>(json['earnedAt']),
      dirty: serializer.fromJson<int>(json['dirty']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'childId': serializer.toJson<int>(childId),
      'badgeId': serializer.toJson<String>(badgeId),
      'earnedAt': serializer.toJson<DateTime>(earnedAt),
      'dirty': serializer.toJson<int>(dirty),
      'remoteId': serializer.toJson<String?>(remoteId),
    };
  }

  BadgesEarnedData copyWith({
    int? childId,
    String? badgeId,
    DateTime? earnedAt,
    int? dirty,
    Value<String?> remoteId = const Value.absent(),
  }) => BadgesEarnedData(
    childId: childId ?? this.childId,
    badgeId: badgeId ?? this.badgeId,
    earnedAt: earnedAt ?? this.earnedAt,
    dirty: dirty ?? this.dirty,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
  );
  BadgesEarnedData copyWithCompanion(BadgesEarnedCompanion data) {
    return BadgesEarnedData(
      childId: data.childId.present ? data.childId.value : this.childId,
      badgeId: data.badgeId.present ? data.badgeId.value : this.badgeId,
      earnedAt: data.earnedAt.present ? data.earnedAt.value : this.earnedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BadgesEarnedData(')
          ..write('childId: $childId, ')
          ..write('badgeId: $badgeId, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(childId, badgeId, earnedAt, dirty, remoteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BadgesEarnedData &&
          other.childId == this.childId &&
          other.badgeId == this.badgeId &&
          other.earnedAt == this.earnedAt &&
          other.dirty == this.dirty &&
          other.remoteId == this.remoteId);
}

class BadgesEarnedCompanion extends UpdateCompanion<BadgesEarnedData> {
  final Value<int> childId;
  final Value<String> badgeId;
  final Value<DateTime> earnedAt;
  final Value<int> dirty;
  final Value<String?> remoteId;
  final Value<int> rowid;
  const BadgesEarnedCompanion({
    this.childId = const Value.absent(),
    this.badgeId = const Value.absent(),
    this.earnedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BadgesEarnedCompanion.insert({
    required int childId,
    required String badgeId,
    required DateTime earnedAt,
    this.dirty = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : childId = Value(childId),
       badgeId = Value(badgeId),
       earnedAt = Value(earnedAt);
  static Insertable<BadgesEarnedData> custom({
    Expression<int>? childId,
    Expression<String>? badgeId,
    Expression<DateTime>? earnedAt,
    Expression<int>? dirty,
    Expression<String>? remoteId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (childId != null) 'child_id': childId,
      if (badgeId != null) 'badge_id': badgeId,
      if (earnedAt != null) 'earned_at': earnedAt,
      if (dirty != null) 'dirty': dirty,
      if (remoteId != null) 'remote_id': remoteId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BadgesEarnedCompanion copyWith({
    Value<int>? childId,
    Value<String>? badgeId,
    Value<DateTime>? earnedAt,
    Value<int>? dirty,
    Value<String?>? remoteId,
    Value<int>? rowid,
  }) {
    return BadgesEarnedCompanion(
      childId: childId ?? this.childId,
      badgeId: badgeId ?? this.badgeId,
      earnedAt: earnedAt ?? this.earnedAt,
      dirty: dirty ?? this.dirty,
      remoteId: remoteId ?? this.remoteId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (badgeId.present) {
      map['badge_id'] = Variable<String>(badgeId.value);
    }
    if (earnedAt.present) {
      map['earned_at'] = Variable<DateTime>(earnedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<int>(dirty.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BadgesEarnedCompanion(')
          ..write('childId: $childId, ')
          ..write('badgeId: $badgeId, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId, ')
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

class $ChildrenTable extends Children with TableInfo<$ChildrenTable, ChildRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChildrenTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('fox'),
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resetEpochMeta = const VerificationMeta(
    'resetEpoch',
  );
  @override
  late final GeneratedColumn<int> resetEpoch = GeneratedColumn<int>(
    'reset_epoch',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pendingResetMeta = const VerificationMeta(
    'pendingReset',
  );
  @override
  late final GeneratedColumn<bool> pendingReset = GeneratedColumn<bool>(
    'pending_reset',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_reset" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pendingDeleteMeta = const VerificationMeta(
    'pendingDelete',
  );
  @override
  late final GeneratedColumn<bool> pendingDelete = GeneratedColumn<bool>(
    'pending_delete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_delete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nickname,
    schoolYear,
    schoolStartLevel,
    olympiadStartLevel,
    avatar,
    dailyLimitMin,
    soundOn,
    createdAt,
    updatedAt,
    remoteId,
    resetEpoch,
    pendingReset,
    pendingDelete,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'children';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChildRow> instance, {
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
    }
    if (data.containsKey('school_year')) {
      context.handle(
        _schoolYearMeta,
        schoolYear.isAcceptableOrUnknown(data['school_year']!, _schoolYearMeta),
      );
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
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
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
    if (data.containsKey('sound_on')) {
      context.handle(
        _soundOnMeta,
        soundOn.isAcceptableOrUnknown(data['sound_on']!, _soundOnMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('reset_epoch')) {
      context.handle(
        _resetEpochMeta,
        resetEpoch.isAcceptableOrUnknown(data['reset_epoch']!, _resetEpochMeta),
      );
    }
    if (data.containsKey('pending_reset')) {
      context.handle(
        _pendingResetMeta,
        pendingReset.isAcceptableOrUnknown(
          data['pending_reset']!,
          _pendingResetMeta,
        ),
      );
    }
    if (data.containsKey('pending_delete')) {
      context.handle(
        _pendingDeleteMeta,
        pendingDelete.isAcceptableOrUnknown(
          data['pending_delete']!,
          _pendingDeleteMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChildRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChildRow(
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
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      )!,
      dailyLimitMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_limit_min'],
      )!,
      soundOn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sound_on'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      resetEpoch: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reset_epoch'],
      )!,
      pendingReset: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_reset'],
      )!,
      pendingDelete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_delete'],
      )!,
    );
  }

  @override
  $ChildrenTable createAlias(String alias) {
    return $ChildrenTable(attachedDatabase, alias);
  }
}

class ChildRow extends DataClass implements Insertable<ChildRow> {
  final int id;
  final String nickname;
  final int schoolYear;
  final int? schoolStartLevel;
  final int? olympiadStartLevel;

  /// An avatar id from `lib/ui/avatars.dart` (AD-7).
  final String avatar;
  final int dailyLimitMin;
  final bool soundOn;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// The server `children` record once linked (AD-8).
  final String? remoteId;
  final int resetEpoch;
  final bool pendingReset;

  /// Removed here while offline: hidden everywhere until the next sync
  /// deletes the server record (AD-10).
  final bool pendingDelete;
  const ChildRow({
    required this.id,
    required this.nickname,
    required this.schoolYear,
    this.schoolStartLevel,
    this.olympiadStartLevel,
    required this.avatar,
    required this.dailyLimitMin,
    required this.soundOn,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    required this.resetEpoch,
    required this.pendingReset,
    required this.pendingDelete,
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
    map['avatar'] = Variable<String>(avatar);
    map['daily_limit_min'] = Variable<int>(dailyLimitMin);
    map['sound_on'] = Variable<bool>(soundOn);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['reset_epoch'] = Variable<int>(resetEpoch);
    map['pending_reset'] = Variable<bool>(pendingReset);
    map['pending_delete'] = Variable<bool>(pendingDelete);
    return map;
  }

  ChildrenCompanion toCompanion(bool nullToAbsent) {
    return ChildrenCompanion(
      id: Value(id),
      nickname: Value(nickname),
      schoolYear: Value(schoolYear),
      schoolStartLevel: schoolStartLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(schoolStartLevel),
      olympiadStartLevel: olympiadStartLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(olympiadStartLevel),
      avatar: Value(avatar),
      dailyLimitMin: Value(dailyLimitMin),
      soundOn: Value(soundOn),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      resetEpoch: Value(resetEpoch),
      pendingReset: Value(pendingReset),
      pendingDelete: Value(pendingDelete),
    );
  }

  factory ChildRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChildRow(
      id: serializer.fromJson<int>(json['id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      schoolYear: serializer.fromJson<int>(json['schoolYear']),
      schoolStartLevel: serializer.fromJson<int?>(json['schoolStartLevel']),
      olympiadStartLevel: serializer.fromJson<int?>(json['olympiadStartLevel']),
      avatar: serializer.fromJson<String>(json['avatar']),
      dailyLimitMin: serializer.fromJson<int>(json['dailyLimitMin']),
      soundOn: serializer.fromJson<bool>(json['soundOn']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      resetEpoch: serializer.fromJson<int>(json['resetEpoch']),
      pendingReset: serializer.fromJson<bool>(json['pendingReset']),
      pendingDelete: serializer.fromJson<bool>(json['pendingDelete']),
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
      'avatar': serializer.toJson<String>(avatar),
      'dailyLimitMin': serializer.toJson<int>(dailyLimitMin),
      'soundOn': serializer.toJson<bool>(soundOn),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'remoteId': serializer.toJson<String?>(remoteId),
      'resetEpoch': serializer.toJson<int>(resetEpoch),
      'pendingReset': serializer.toJson<bool>(pendingReset),
      'pendingDelete': serializer.toJson<bool>(pendingDelete),
    };
  }

  ChildRow copyWith({
    int? id,
    String? nickname,
    int? schoolYear,
    Value<int?> schoolStartLevel = const Value.absent(),
    Value<int?> olympiadStartLevel = const Value.absent(),
    String? avatar,
    int? dailyLimitMin,
    bool? soundOn,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> remoteId = const Value.absent(),
    int? resetEpoch,
    bool? pendingReset,
    bool? pendingDelete,
  }) => ChildRow(
    id: id ?? this.id,
    nickname: nickname ?? this.nickname,
    schoolYear: schoolYear ?? this.schoolYear,
    schoolStartLevel: schoolStartLevel.present
        ? schoolStartLevel.value
        : this.schoolStartLevel,
    olympiadStartLevel: olympiadStartLevel.present
        ? olympiadStartLevel.value
        : this.olympiadStartLevel,
    avatar: avatar ?? this.avatar,
    dailyLimitMin: dailyLimitMin ?? this.dailyLimitMin,
    soundOn: soundOn ?? this.soundOn,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    resetEpoch: resetEpoch ?? this.resetEpoch,
    pendingReset: pendingReset ?? this.pendingReset,
    pendingDelete: pendingDelete ?? this.pendingDelete,
  );
  ChildRow copyWithCompanion(ChildrenCompanion data) {
    return ChildRow(
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
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      dailyLimitMin: data.dailyLimitMin.present
          ? data.dailyLimitMin.value
          : this.dailyLimitMin,
      soundOn: data.soundOn.present ? data.soundOn.value : this.soundOn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      resetEpoch: data.resetEpoch.present
          ? data.resetEpoch.value
          : this.resetEpoch,
      pendingReset: data.pendingReset.present
          ? data.pendingReset.value
          : this.pendingReset,
      pendingDelete: data.pendingDelete.present
          ? data.pendingDelete.value
          : this.pendingDelete,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChildRow(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('schoolYear: $schoolYear, ')
          ..write('schoolStartLevel: $schoolStartLevel, ')
          ..write('olympiadStartLevel: $olympiadStartLevel, ')
          ..write('avatar: $avatar, ')
          ..write('dailyLimitMin: $dailyLimitMin, ')
          ..write('soundOn: $soundOn, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('resetEpoch: $resetEpoch, ')
          ..write('pendingReset: $pendingReset, ')
          ..write('pendingDelete: $pendingDelete')
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
    avatar,
    dailyLimitMin,
    soundOn,
    createdAt,
    updatedAt,
    remoteId,
    resetEpoch,
    pendingReset,
    pendingDelete,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChildRow &&
          other.id == this.id &&
          other.nickname == this.nickname &&
          other.schoolYear == this.schoolYear &&
          other.schoolStartLevel == this.schoolStartLevel &&
          other.olympiadStartLevel == this.olympiadStartLevel &&
          other.avatar == this.avatar &&
          other.dailyLimitMin == this.dailyLimitMin &&
          other.soundOn == this.soundOn &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.remoteId == this.remoteId &&
          other.resetEpoch == this.resetEpoch &&
          other.pendingReset == this.pendingReset &&
          other.pendingDelete == this.pendingDelete);
}

class ChildrenCompanion extends UpdateCompanion<ChildRow> {
  final Value<int> id;
  final Value<String> nickname;
  final Value<int> schoolYear;
  final Value<int?> schoolStartLevel;
  final Value<int?> olympiadStartLevel;
  final Value<String> avatar;
  final Value<int> dailyLimitMin;
  final Value<bool> soundOn;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> remoteId;
  final Value<int> resetEpoch;
  final Value<bool> pendingReset;
  final Value<bool> pendingDelete;
  const ChildrenCompanion({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.schoolYear = const Value.absent(),
    this.schoolStartLevel = const Value.absent(),
    this.olympiadStartLevel = const Value.absent(),
    this.avatar = const Value.absent(),
    this.dailyLimitMin = const Value.absent(),
    this.soundOn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.resetEpoch = const Value.absent(),
    this.pendingReset = const Value.absent(),
    this.pendingDelete = const Value.absent(),
  });
  ChildrenCompanion.insert({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.schoolYear = const Value.absent(),
    this.schoolStartLevel = const Value.absent(),
    this.olympiadStartLevel = const Value.absent(),
    this.avatar = const Value.absent(),
    this.dailyLimitMin = const Value.absent(),
    this.soundOn = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.remoteId = const Value.absent(),
    this.resetEpoch = const Value.absent(),
    this.pendingReset = const Value.absent(),
    this.pendingDelete = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ChildRow> custom({
    Expression<int>? id,
    Expression<String>? nickname,
    Expression<int>? schoolYear,
    Expression<int>? schoolStartLevel,
    Expression<int>? olympiadStartLevel,
    Expression<String>? avatar,
    Expression<int>? dailyLimitMin,
    Expression<bool>? soundOn,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? remoteId,
    Expression<int>? resetEpoch,
    Expression<bool>? pendingReset,
    Expression<bool>? pendingDelete,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (schoolYear != null) 'school_year': schoolYear,
      if (schoolStartLevel != null) 'school_start_level': schoolStartLevel,
      if (olympiadStartLevel != null)
        'olympiad_start_level': olympiadStartLevel,
      if (avatar != null) 'avatar': avatar,
      if (dailyLimitMin != null) 'daily_limit_min': dailyLimitMin,
      if (soundOn != null) 'sound_on': soundOn,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (remoteId != null) 'remote_id': remoteId,
      if (resetEpoch != null) 'reset_epoch': resetEpoch,
      if (pendingReset != null) 'pending_reset': pendingReset,
      if (pendingDelete != null) 'pending_delete': pendingDelete,
    });
  }

  ChildrenCompanion copyWith({
    Value<int>? id,
    Value<String>? nickname,
    Value<int>? schoolYear,
    Value<int?>? schoolStartLevel,
    Value<int?>? olympiadStartLevel,
    Value<String>? avatar,
    Value<int>? dailyLimitMin,
    Value<bool>? soundOn,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? remoteId,
    Value<int>? resetEpoch,
    Value<bool>? pendingReset,
    Value<bool>? pendingDelete,
  }) {
    return ChildrenCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      schoolYear: schoolYear ?? this.schoolYear,
      schoolStartLevel: schoolStartLevel ?? this.schoolStartLevel,
      olympiadStartLevel: olympiadStartLevel ?? this.olympiadStartLevel,
      avatar: avatar ?? this.avatar,
      dailyLimitMin: dailyLimitMin ?? this.dailyLimitMin,
      soundOn: soundOn ?? this.soundOn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      resetEpoch: resetEpoch ?? this.resetEpoch,
      pendingReset: pendingReset ?? this.pendingReset,
      pendingDelete: pendingDelete ?? this.pendingDelete,
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
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (dailyLimitMin.present) {
      map['daily_limit_min'] = Variable<int>(dailyLimitMin.value);
    }
    if (soundOn.present) {
      map['sound_on'] = Variable<bool>(soundOn.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (resetEpoch.present) {
      map['reset_epoch'] = Variable<int>(resetEpoch.value);
    }
    if (pendingReset.present) {
      map['pending_reset'] = Variable<bool>(pendingReset.value);
    }
    if (pendingDelete.present) {
      map['pending_delete'] = Variable<bool>(pendingDelete.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChildrenCompanion(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('schoolYear: $schoolYear, ')
          ..write('schoolStartLevel: $schoolStartLevel, ')
          ..write('olympiadStartLevel: $olympiadStartLevel, ')
          ..write('avatar: $avatar, ')
          ..write('dailyLimitMin: $dailyLimitMin, ')
          ..write('soundOn: $soundOn, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('resetEpoch: $resetEpoch, ')
          ..write('pendingReset: $pendingReset, ')
          ..write('pendingDelete: $pendingDelete')
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
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [childId, topicId, openedAt];
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
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
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
  Set<GeneratedColumn> get $primaryKey => {childId, topicId};
  @override
  TopicUnlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TopicUnlock(
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
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
  final int childId;
  final String topicId;
  final DateTime openedAt;
  const TopicUnlock({
    required this.childId,
    required this.topicId,
    required this.openedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['child_id'] = Variable<int>(childId);
    map['topic_id'] = Variable<String>(topicId);
    map['opened_at'] = Variable<DateTime>(openedAt);
    return map;
  }

  TopicUnlocksCompanion toCompanion(bool nullToAbsent) {
    return TopicUnlocksCompanion(
      childId: Value(childId),
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
      childId: serializer.fromJson<int>(json['childId']),
      topicId: serializer.fromJson<String>(json['topicId']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'childId': serializer.toJson<int>(childId),
      'topicId': serializer.toJson<String>(topicId),
      'openedAt': serializer.toJson<DateTime>(openedAt),
    };
  }

  TopicUnlock copyWith({int? childId, String? topicId, DateTime? openedAt}) =>
      TopicUnlock(
        childId: childId ?? this.childId,
        topicId: topicId ?? this.topicId,
        openedAt: openedAt ?? this.openedAt,
      );
  TopicUnlock copyWithCompanion(TopicUnlocksCompanion data) {
    return TopicUnlock(
      childId: data.childId.present ? data.childId.value : this.childId,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TopicUnlock(')
          ..write('childId: $childId, ')
          ..write('topicId: $topicId, ')
          ..write('openedAt: $openedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(childId, topicId, openedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TopicUnlock &&
          other.childId == this.childId &&
          other.topicId == this.topicId &&
          other.openedAt == this.openedAt);
}

class TopicUnlocksCompanion extends UpdateCompanion<TopicUnlock> {
  final Value<int> childId;
  final Value<String> topicId;
  final Value<DateTime> openedAt;
  final Value<int> rowid;
  const TopicUnlocksCompanion({
    this.childId = const Value.absent(),
    this.topicId = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TopicUnlocksCompanion.insert({
    required int childId,
    required String topicId,
    required DateTime openedAt,
    this.rowid = const Value.absent(),
  }) : childId = Value(childId),
       topicId = Value(topicId),
       openedAt = Value(openedAt);
  static Insertable<TopicUnlock> custom({
    Expression<int>? childId,
    Expression<String>? topicId,
    Expression<DateTime>? openedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (childId != null) 'child_id': childId,
      if (topicId != null) 'topic_id': topicId,
      if (openedAt != null) 'opened_at': openedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TopicUnlocksCompanion copyWith({
    Value<int>? childId,
    Value<String>? topicId,
    Value<DateTime>? openedAt,
    Value<int>? rowid,
  }) {
    return TopicUnlocksCompanion(
      childId: childId ?? this.childId,
      topicId: topicId ?? this.topicId,
      openedAt: openedAt ?? this.openedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
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
          ..write('childId: $childId, ')
          ..write('topicId: $topicId, ')
          ..write('openedAt: $openedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncFieldsTable extends SyncFields
    with TableInfo<$SyncFieldsTable, SyncField> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncFieldsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changedAtMeta = const VerificationMeta(
    'changedAt',
  );
  @override
  late final GeneratedColumn<DateTime> changedAt = GeneratedColumn<DateTime>(
    'changed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<int> dirty = GeneratedColumn<int>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [childId, field, changedAt, dirty];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_fields';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncField> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('changed_at')) {
      context.handle(
        _changedAtMeta,
        changedAt.isAcceptableOrUnknown(data['changed_at']!, _changedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_changedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {childId, field};
  @override
  SyncField map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncField(
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      changedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}changed_at'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dirty'],
      )!,
    );
  }

  @override
  $SyncFieldsTable createAlias(String alias) {
    return $SyncFieldsTable(attachedDatabase, alias);
  }
}

class SyncField extends DataClass implements Insertable<SyncField> {
  final int childId;
  final String field;
  final DateTime changedAt;
  final int dirty;
  const SyncField({
    required this.childId,
    required this.field,
    required this.changedAt,
    required this.dirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['child_id'] = Variable<int>(childId);
    map['field'] = Variable<String>(field);
    map['changed_at'] = Variable<DateTime>(changedAt);
    map['dirty'] = Variable<int>(dirty);
    return map;
  }

  SyncFieldsCompanion toCompanion(bool nullToAbsent) {
    return SyncFieldsCompanion(
      childId: Value(childId),
      field: Value(field),
      changedAt: Value(changedAt),
      dirty: Value(dirty),
    );
  }

  factory SyncField.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncField(
      childId: serializer.fromJson<int>(json['childId']),
      field: serializer.fromJson<String>(json['field']),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
      dirty: serializer.fromJson<int>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'childId': serializer.toJson<int>(childId),
      'field': serializer.toJson<String>(field),
      'changedAt': serializer.toJson<DateTime>(changedAt),
      'dirty': serializer.toJson<int>(dirty),
    };
  }

  SyncField copyWith({
    int? childId,
    String? field,
    DateTime? changedAt,
    int? dirty,
  }) => SyncField(
    childId: childId ?? this.childId,
    field: field ?? this.field,
    changedAt: changedAt ?? this.changedAt,
    dirty: dirty ?? this.dirty,
  );
  SyncField copyWithCompanion(SyncFieldsCompanion data) {
    return SyncField(
      childId: data.childId.present ? data.childId.value : this.childId,
      field: data.field.present ? data.field.value : this.field,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncField(')
          ..write('childId: $childId, ')
          ..write('field: $field, ')
          ..write('changedAt: $changedAt, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(childId, field, changedAt, dirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncField &&
          other.childId == this.childId &&
          other.field == this.field &&
          other.changedAt == this.changedAt &&
          other.dirty == this.dirty);
}

class SyncFieldsCompanion extends UpdateCompanion<SyncField> {
  final Value<int> childId;
  final Value<String> field;
  final Value<DateTime> changedAt;
  final Value<int> dirty;
  final Value<int> rowid;
  const SyncFieldsCompanion({
    this.childId = const Value.absent(),
    this.field = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncFieldsCompanion.insert({
    required int childId,
    required String field,
    required DateTime changedAt,
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : childId = Value(childId),
       field = Value(field),
       changedAt = Value(changedAt);
  static Insertable<SyncField> custom({
    Expression<int>? childId,
    Expression<String>? field,
    Expression<DateTime>? changedAt,
    Expression<int>? dirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (childId != null) 'child_id': childId,
      if (field != null) 'field': field,
      if (changedAt != null) 'changed_at': changedAt,
      if (dirty != null) 'dirty': dirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncFieldsCompanion copyWith({
    Value<int>? childId,
    Value<String>? field,
    Value<DateTime>? changedAt,
    Value<int>? dirty,
    Value<int>? rowid,
  }) {
    return SyncFieldsCompanion(
      childId: childId ?? this.childId,
      field: field ?? this.field,
      changedAt: changedAt ?? this.changedAt,
      dirty: dirty ?? this.dirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<DateTime>(changedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<int>(dirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncFieldsCompanion(')
          ..write('childId: $childId, ')
          ..write('field: $field, ')
          ..write('changedAt: $changedAt, ')
          ..write('dirty: $dirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resetEpochMeta = const VerificationMeta(
    'resetEpoch',
  );
  @override
  late final GeneratedColumn<int> resetEpoch = GeneratedColumn<int>(
    'reset_epoch',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pendingResetMeta = const VerificationMeta(
    'pendingReset',
  );
  @override
  late final GeneratedColumn<bool> pendingReset = GeneratedColumn<bool>(
    'pending_reset',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_reset" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _cursorsMeta = const VerificationMeta(
    'cursors',
  );
  @override
  late final GeneratedColumn<String> cursors = GeneratedColumn<String>(
    'cursors',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    childId,
    resetEpoch,
    pendingReset,
    cursors,
    lastSyncAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    }
    if (data.containsKey('reset_epoch')) {
      context.handle(
        _resetEpochMeta,
        resetEpoch.isAcceptableOrUnknown(data['reset_epoch']!, _resetEpochMeta),
      );
    }
    if (data.containsKey('pending_reset')) {
      context.handle(
        _pendingResetMeta,
        pendingReset.isAcceptableOrUnknown(
          data['pending_reset']!,
          _pendingResetMeta,
        ),
      );
    }
    if (data.containsKey('cursors')) {
      context.handle(
        _cursorsMeta,
        cursors.isAcceptableOrUnknown(data['cursors']!, _cursorsMeta),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      ),
      resetEpoch: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reset_epoch'],
      )!,
      pendingReset: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_reset'],
      )!,
      cursors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursors'],
      )!,
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final int id;
  final String? accountId;
  final String? childId;
  final int resetEpoch;
  final bool pendingReset;

  /// JSON map: collection name -> last `updated` seen.
  final String cursors;
  final DateTime? lastSyncAt;
  final String? lastError;
  const SyncStateData({
    required this.id,
    this.accountId,
    this.childId,
    required this.resetEpoch,
    required this.pendingReset,
    required this.cursors,
    this.lastSyncAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    if (!nullToAbsent || childId != null) {
      map['child_id'] = Variable<String>(childId);
    }
    map['reset_epoch'] = Variable<int>(resetEpoch);
    map['pending_reset'] = Variable<bool>(pendingReset);
    map['cursors'] = Variable<String>(cursors);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      id: Value(id),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      childId: childId == null && nullToAbsent
          ? const Value.absent()
          : Value(childId),
      resetEpoch: Value(resetEpoch),
      pendingReset: Value(pendingReset),
      cursors: Value(cursors),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      childId: serializer.fromJson<String?>(json['childId']),
      resetEpoch: serializer.fromJson<int>(json['resetEpoch']),
      pendingReset: serializer.fromJson<bool>(json['pendingReset']),
      cursors: serializer.fromJson<String>(json['cursors']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<String?>(accountId),
      'childId': serializer.toJson<String?>(childId),
      'resetEpoch': serializer.toJson<int>(resetEpoch),
      'pendingReset': serializer.toJson<bool>(pendingReset),
      'cursors': serializer.toJson<String>(cursors),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncStateData copyWith({
    int? id,
    Value<String?> accountId = const Value.absent(),
    Value<String?> childId = const Value.absent(),
    int? resetEpoch,
    bool? pendingReset,
    String? cursors,
    Value<DateTime?> lastSyncAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => SyncStateData(
    id: id ?? this.id,
    accountId: accountId.present ? accountId.value : this.accountId,
    childId: childId.present ? childId.value : this.childId,
    resetEpoch: resetEpoch ?? this.resetEpoch,
    pendingReset: pendingReset ?? this.pendingReset,
    cursors: cursors ?? this.cursors,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      childId: data.childId.present ? data.childId.value : this.childId,
      resetEpoch: data.resetEpoch.present
          ? data.resetEpoch.value
          : this.resetEpoch,
      pendingReset: data.pendingReset.present
          ? data.pendingReset.value
          : this.pendingReset,
      cursors: data.cursors.present ? data.cursors.value : this.cursors,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('childId: $childId, ')
          ..write('resetEpoch: $resetEpoch, ')
          ..write('pendingReset: $pendingReset, ')
          ..write('cursors: $cursors, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    childId,
    resetEpoch,
    pendingReset,
    cursors,
    lastSyncAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.childId == this.childId &&
          other.resetEpoch == this.resetEpoch &&
          other.pendingReset == this.pendingReset &&
          other.cursors == this.cursors &&
          other.lastSyncAt == this.lastSyncAt &&
          other.lastError == this.lastError);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<int> id;
  final Value<String?> accountId;
  final Value<String?> childId;
  final Value<int> resetEpoch;
  final Value<bool> pendingReset;
  final Value<String> cursors;
  final Value<DateTime?> lastSyncAt;
  final Value<String?> lastError;
  const SyncStateCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.childId = const Value.absent(),
    this.resetEpoch = const Value.absent(),
    this.pendingReset = const Value.absent(),
    this.cursors = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  SyncStateCompanion.insert({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.childId = const Value.absent(),
    this.resetEpoch = const Value.absent(),
    this.pendingReset = const Value.absent(),
    this.cursors = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  static Insertable<SyncStateData> custom({
    Expression<int>? id,
    Expression<String>? accountId,
    Expression<String>? childId,
    Expression<int>? resetEpoch,
    Expression<bool>? pendingReset,
    Expression<String>? cursors,
    Expression<DateTime>? lastSyncAt,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (childId != null) 'child_id': childId,
      if (resetEpoch != null) 'reset_epoch': resetEpoch,
      if (pendingReset != null) 'pending_reset': pendingReset,
      if (cursors != null) 'cursors': cursors,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (lastError != null) 'last_error': lastError,
    });
  }

  SyncStateCompanion copyWith({
    Value<int>? id,
    Value<String?>? accountId,
    Value<String?>? childId,
    Value<int>? resetEpoch,
    Value<bool>? pendingReset,
    Value<String>? cursors,
    Value<DateTime?>? lastSyncAt,
    Value<String?>? lastError,
  }) {
    return SyncStateCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      childId: childId ?? this.childId,
      resetEpoch: resetEpoch ?? this.resetEpoch,
      pendingReset: pendingReset ?? this.pendingReset,
      cursors: cursors ?? this.cursors,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (resetEpoch.present) {
      map['reset_epoch'] = Variable<int>(resetEpoch.value);
    }
    if (pendingReset.present) {
      map['pending_reset'] = Variable<bool>(pendingReset.value);
    }
    if (cursors.present) {
      map['cursors'] = Variable<String>(cursors.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('childId: $childId, ')
          ..write('resetEpoch: $resetEpoch, ')
          ..write('pendingReset: $pendingReset, ')
          ..write('cursors: $cursors, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $BankFilesTable extends BankFiles
    with TableInfo<$BankFilesTable, BankFileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BankFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<int> format = GeneratedColumn<int>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    version,
    format,
    sha256,
    path,
    downloadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bank_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<BankFileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {version};
  @override
  BankFileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BankFileRow(
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}format'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
    );
  }

  @override
  $BankFilesTable createAlias(String alias) {
    return $BankFilesTable(attachedDatabase, alias);
  }
}

class BankFileRow extends DataClass implements Insertable<BankFileRow> {
  final int version;
  final int format;
  final String sha256;

  /// File name under the banks directory.
  final String path;
  final DateTime downloadedAt;
  const BankFileRow({
    required this.version,
    required this.format,
    required this.sha256,
    required this.path,
    required this.downloadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['version'] = Variable<int>(version);
    map['format'] = Variable<int>(format);
    map['sha256'] = Variable<String>(sha256);
    map['path'] = Variable<String>(path);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    return map;
  }

  BankFilesCompanion toCompanion(bool nullToAbsent) {
    return BankFilesCompanion(
      version: Value(version),
      format: Value(format),
      sha256: Value(sha256),
      path: Value(path),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory BankFileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BankFileRow(
      version: serializer.fromJson<int>(json['version']),
      format: serializer.fromJson<int>(json['format']),
      sha256: serializer.fromJson<String>(json['sha256']),
      path: serializer.fromJson<String>(json['path']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'version': serializer.toJson<int>(version),
      'format': serializer.toJson<int>(format),
      'sha256': serializer.toJson<String>(sha256),
      'path': serializer.toJson<String>(path),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
    };
  }

  BankFileRow copyWith({
    int? version,
    int? format,
    String? sha256,
    String? path,
    DateTime? downloadedAt,
  }) => BankFileRow(
    version: version ?? this.version,
    format: format ?? this.format,
    sha256: sha256 ?? this.sha256,
    path: path ?? this.path,
    downloadedAt: downloadedAt ?? this.downloadedAt,
  );
  BankFileRow copyWithCompanion(BankFilesCompanion data) {
    return BankFileRow(
      version: data.version.present ? data.version.value : this.version,
      format: data.format.present ? data.format.value : this.format,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      path: data.path.present ? data.path.value : this.path,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BankFileRow(')
          ..write('version: $version, ')
          ..write('format: $format, ')
          ..write('sha256: $sha256, ')
          ..write('path: $path, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(version, format, sha256, path, downloadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BankFileRow &&
          other.version == this.version &&
          other.format == this.format &&
          other.sha256 == this.sha256 &&
          other.path == this.path &&
          other.downloadedAt == this.downloadedAt);
}

class BankFilesCompanion extends UpdateCompanion<BankFileRow> {
  final Value<int> version;
  final Value<int> format;
  final Value<String> sha256;
  final Value<String> path;
  final Value<DateTime> downloadedAt;
  const BankFilesCompanion({
    this.version = const Value.absent(),
    this.format = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.path = const Value.absent(),
    this.downloadedAt = const Value.absent(),
  });
  BankFilesCompanion.insert({
    this.version = const Value.absent(),
    required int format,
    required String sha256,
    required String path,
    required DateTime downloadedAt,
  }) : format = Value(format),
       sha256 = Value(sha256),
       path = Value(path),
       downloadedAt = Value(downloadedAt);
  static Insertable<BankFileRow> custom({
    Expression<int>? version,
    Expression<int>? format,
    Expression<String>? sha256,
    Expression<String>? path,
    Expression<DateTime>? downloadedAt,
  }) {
    return RawValuesInsertable({
      if (version != null) 'version': version,
      if (format != null) 'format': format,
      if (sha256 != null) 'sha256': sha256,
      if (path != null) 'path': path,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
    });
  }

  BankFilesCompanion copyWith({
    Value<int>? version,
    Value<int>? format,
    Value<String>? sha256,
    Value<String>? path,
    Value<DateTime>? downloadedAt,
  }) {
    return BankFilesCompanion(
      version: version ?? this.version,
      format: format ?? this.format,
      sha256: sha256 ?? this.sha256,
      path: path ?? this.path,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (format.present) {
      map['format'] = Variable<int>(format.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BankFilesCompanion(')
          ..write('version: $version, ')
          ..write('format: $format, ')
          ..write('sha256: $sha256, ')
          ..write('path: $path, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }
}

class $CrashReportsTable extends CrashReports
    with TableInfo<$CrashReportsTable, CrashReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CrashReportsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _signatureMeta = const VerificationMeta(
    'signature',
  );
  @override
  late final GeneratedColumn<String> signature = GeneratedColumn<String>(
    'signature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _osMeta = const VerificationMeta('os');
  @override
  late final GeneratedColumn<String> os = GeneratedColumn<String>(
    'os',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceMeta = const VerificationMeta('device');
  @override
  late final GeneratedColumn<String> device = GeneratedColumn<String>(
    'device',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _screenMeta = const VerificationMeta('screen');
  @override
  late final GeneratedColumn<String> screen = GeneratedColumn<String>(
    'screen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorTypeMeta = const VerificationMeta(
    'errorType',
  );
  @override
  late final GeneratedColumn<String> errorType = GeneratedColumn<String>(
    'error_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stackMeta = const VerificationMeta('stack');
  @override
  late final GeneratedColumn<String> stack = GeneratedColumn<String>(
    'stack',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _firstAtMeta = const VerificationMeta(
    'firstAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstAt = GeneratedColumn<DateTime>(
    'first_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAtMeta = const VerificationMeta('lastAt');
  @override
  late final GeneratedColumn<DateTime> lastAt = GeneratedColumn<DateTime>(
    'last_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
    'sent_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    signature,
    appVersion,
    bankVersion,
    os,
    device,
    screen,
    errorType,
    message,
    stack,
    count,
    firstAt,
    lastAt,
    sentAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crash_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<CrashReport> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('signature')) {
      context.handle(
        _signatureMeta,
        signature.isAcceptableOrUnknown(data['signature']!, _signatureMeta),
      );
    } else if (isInserting) {
      context.missing(_signatureMeta);
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_appVersionMeta);
    }
    if (data.containsKey('bank_version')) {
      context.handle(
        _bankVersionMeta,
        bankVersion.isAcceptableOrUnknown(
          data['bank_version']!,
          _bankVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bankVersionMeta);
    }
    if (data.containsKey('os')) {
      context.handle(_osMeta, os.isAcceptableOrUnknown(data['os']!, _osMeta));
    } else if (isInserting) {
      context.missing(_osMeta);
    }
    if (data.containsKey('device')) {
      context.handle(
        _deviceMeta,
        device.isAcceptableOrUnknown(data['device']!, _deviceMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceMeta);
    }
    if (data.containsKey('screen')) {
      context.handle(
        _screenMeta,
        screen.isAcceptableOrUnknown(data['screen']!, _screenMeta),
      );
    } else if (isInserting) {
      context.missing(_screenMeta);
    }
    if (data.containsKey('error_type')) {
      context.handle(
        _errorTypeMeta,
        errorType.isAcceptableOrUnknown(data['error_type']!, _errorTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_errorTypeMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('stack')) {
      context.handle(
        _stackMeta,
        stack.isAcceptableOrUnknown(data['stack']!, _stackMeta),
      );
    } else if (isInserting) {
      context.missing(_stackMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    if (data.containsKey('first_at')) {
      context.handle(
        _firstAtMeta,
        firstAt.isAcceptableOrUnknown(data['first_at']!, _firstAtMeta),
      );
    } else if (isInserting) {
      context.missing(_firstAtMeta);
    }
    if (data.containsKey('last_at')) {
      context.handle(
        _lastAtMeta,
        lastAt.isAcceptableOrUnknown(data['last_at']!, _lastAtMeta),
      );
    } else if (isInserting) {
      context.missing(_lastAtMeta);
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CrashReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CrashReport(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      signature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signature'],
      )!,
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      )!,
      bankVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bank_version'],
      )!,
      os: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}os'],
      )!,
      device: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device'],
      )!,
      screen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}screen'],
      )!,
      errorType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_type'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      stack: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stack'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      firstAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_at'],
      )!,
      lastAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_at'],
      )!,
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sent_at'],
      ),
    );
  }

  @override
  $CrashReportsTable createAlias(String alias) {
    return $CrashReportsTable(attachedDatabase, alias);
  }
}

class CrashReport extends DataClass implements Insertable<CrashReport> {
  final int id;
  final String signature;
  final String appVersion;
  final int bankVersion;
  final String os;
  final String device;
  final String screen;
  final String errorType;
  final String message;
  final String stack;
  final int count;
  final DateTime firstAt;
  final DateTime lastAt;
  final DateTime? sentAt;
  const CrashReport({
    required this.id,
    required this.signature,
    required this.appVersion,
    required this.bankVersion,
    required this.os,
    required this.device,
    required this.screen,
    required this.errorType,
    required this.message,
    required this.stack,
    required this.count,
    required this.firstAt,
    required this.lastAt,
    this.sentAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['signature'] = Variable<String>(signature);
    map['app_version'] = Variable<String>(appVersion);
    map['bank_version'] = Variable<int>(bankVersion);
    map['os'] = Variable<String>(os);
    map['device'] = Variable<String>(device);
    map['screen'] = Variable<String>(screen);
    map['error_type'] = Variable<String>(errorType);
    map['message'] = Variable<String>(message);
    map['stack'] = Variable<String>(stack);
    map['count'] = Variable<int>(count);
    map['first_at'] = Variable<DateTime>(firstAt);
    map['last_at'] = Variable<DateTime>(lastAt);
    if (!nullToAbsent || sentAt != null) {
      map['sent_at'] = Variable<DateTime>(sentAt);
    }
    return map;
  }

  CrashReportsCompanion toCompanion(bool nullToAbsent) {
    return CrashReportsCompanion(
      id: Value(id),
      signature: Value(signature),
      appVersion: Value(appVersion),
      bankVersion: Value(bankVersion),
      os: Value(os),
      device: Value(device),
      screen: Value(screen),
      errorType: Value(errorType),
      message: Value(message),
      stack: Value(stack),
      count: Value(count),
      firstAt: Value(firstAt),
      lastAt: Value(lastAt),
      sentAt: sentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(sentAt),
    );
  }

  factory CrashReport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CrashReport(
      id: serializer.fromJson<int>(json['id']),
      signature: serializer.fromJson<String>(json['signature']),
      appVersion: serializer.fromJson<String>(json['appVersion']),
      bankVersion: serializer.fromJson<int>(json['bankVersion']),
      os: serializer.fromJson<String>(json['os']),
      device: serializer.fromJson<String>(json['device']),
      screen: serializer.fromJson<String>(json['screen']),
      errorType: serializer.fromJson<String>(json['errorType']),
      message: serializer.fromJson<String>(json['message']),
      stack: serializer.fromJson<String>(json['stack']),
      count: serializer.fromJson<int>(json['count']),
      firstAt: serializer.fromJson<DateTime>(json['firstAt']),
      lastAt: serializer.fromJson<DateTime>(json['lastAt']),
      sentAt: serializer.fromJson<DateTime?>(json['sentAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'signature': serializer.toJson<String>(signature),
      'appVersion': serializer.toJson<String>(appVersion),
      'bankVersion': serializer.toJson<int>(bankVersion),
      'os': serializer.toJson<String>(os),
      'device': serializer.toJson<String>(device),
      'screen': serializer.toJson<String>(screen),
      'errorType': serializer.toJson<String>(errorType),
      'message': serializer.toJson<String>(message),
      'stack': serializer.toJson<String>(stack),
      'count': serializer.toJson<int>(count),
      'firstAt': serializer.toJson<DateTime>(firstAt),
      'lastAt': serializer.toJson<DateTime>(lastAt),
      'sentAt': serializer.toJson<DateTime?>(sentAt),
    };
  }

  CrashReport copyWith({
    int? id,
    String? signature,
    String? appVersion,
    int? bankVersion,
    String? os,
    String? device,
    String? screen,
    String? errorType,
    String? message,
    String? stack,
    int? count,
    DateTime? firstAt,
    DateTime? lastAt,
    Value<DateTime?> sentAt = const Value.absent(),
  }) => CrashReport(
    id: id ?? this.id,
    signature: signature ?? this.signature,
    appVersion: appVersion ?? this.appVersion,
    bankVersion: bankVersion ?? this.bankVersion,
    os: os ?? this.os,
    device: device ?? this.device,
    screen: screen ?? this.screen,
    errorType: errorType ?? this.errorType,
    message: message ?? this.message,
    stack: stack ?? this.stack,
    count: count ?? this.count,
    firstAt: firstAt ?? this.firstAt,
    lastAt: lastAt ?? this.lastAt,
    sentAt: sentAt.present ? sentAt.value : this.sentAt,
  );
  CrashReport copyWithCompanion(CrashReportsCompanion data) {
    return CrashReport(
      id: data.id.present ? data.id.value : this.id,
      signature: data.signature.present ? data.signature.value : this.signature,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
      bankVersion: data.bankVersion.present
          ? data.bankVersion.value
          : this.bankVersion,
      os: data.os.present ? data.os.value : this.os,
      device: data.device.present ? data.device.value : this.device,
      screen: data.screen.present ? data.screen.value : this.screen,
      errorType: data.errorType.present ? data.errorType.value : this.errorType,
      message: data.message.present ? data.message.value : this.message,
      stack: data.stack.present ? data.stack.value : this.stack,
      count: data.count.present ? data.count.value : this.count,
      firstAt: data.firstAt.present ? data.firstAt.value : this.firstAt,
      lastAt: data.lastAt.present ? data.lastAt.value : this.lastAt,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CrashReport(')
          ..write('id: $id, ')
          ..write('signature: $signature, ')
          ..write('appVersion: $appVersion, ')
          ..write('bankVersion: $bankVersion, ')
          ..write('os: $os, ')
          ..write('device: $device, ')
          ..write('screen: $screen, ')
          ..write('errorType: $errorType, ')
          ..write('message: $message, ')
          ..write('stack: $stack, ')
          ..write('count: $count, ')
          ..write('firstAt: $firstAt, ')
          ..write('lastAt: $lastAt, ')
          ..write('sentAt: $sentAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    signature,
    appVersion,
    bankVersion,
    os,
    device,
    screen,
    errorType,
    message,
    stack,
    count,
    firstAt,
    lastAt,
    sentAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CrashReport &&
          other.id == this.id &&
          other.signature == this.signature &&
          other.appVersion == this.appVersion &&
          other.bankVersion == this.bankVersion &&
          other.os == this.os &&
          other.device == this.device &&
          other.screen == this.screen &&
          other.errorType == this.errorType &&
          other.message == this.message &&
          other.stack == this.stack &&
          other.count == this.count &&
          other.firstAt == this.firstAt &&
          other.lastAt == this.lastAt &&
          other.sentAt == this.sentAt);
}

class CrashReportsCompanion extends UpdateCompanion<CrashReport> {
  final Value<int> id;
  final Value<String> signature;
  final Value<String> appVersion;
  final Value<int> bankVersion;
  final Value<String> os;
  final Value<String> device;
  final Value<String> screen;
  final Value<String> errorType;
  final Value<String> message;
  final Value<String> stack;
  final Value<int> count;
  final Value<DateTime> firstAt;
  final Value<DateTime> lastAt;
  final Value<DateTime?> sentAt;
  const CrashReportsCompanion({
    this.id = const Value.absent(),
    this.signature = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.bankVersion = const Value.absent(),
    this.os = const Value.absent(),
    this.device = const Value.absent(),
    this.screen = const Value.absent(),
    this.errorType = const Value.absent(),
    this.message = const Value.absent(),
    this.stack = const Value.absent(),
    this.count = const Value.absent(),
    this.firstAt = const Value.absent(),
    this.lastAt = const Value.absent(),
    this.sentAt = const Value.absent(),
  });
  CrashReportsCompanion.insert({
    this.id = const Value.absent(),
    required String signature,
    required String appVersion,
    required int bankVersion,
    required String os,
    required String device,
    required String screen,
    required String errorType,
    required String message,
    required String stack,
    this.count = const Value.absent(),
    required DateTime firstAt,
    required DateTime lastAt,
    this.sentAt = const Value.absent(),
  }) : signature = Value(signature),
       appVersion = Value(appVersion),
       bankVersion = Value(bankVersion),
       os = Value(os),
       device = Value(device),
       screen = Value(screen),
       errorType = Value(errorType),
       message = Value(message),
       stack = Value(stack),
       firstAt = Value(firstAt),
       lastAt = Value(lastAt);
  static Insertable<CrashReport> custom({
    Expression<int>? id,
    Expression<String>? signature,
    Expression<String>? appVersion,
    Expression<int>? bankVersion,
    Expression<String>? os,
    Expression<String>? device,
    Expression<String>? screen,
    Expression<String>? errorType,
    Expression<String>? message,
    Expression<String>? stack,
    Expression<int>? count,
    Expression<DateTime>? firstAt,
    Expression<DateTime>? lastAt,
    Expression<DateTime>? sentAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (signature != null) 'signature': signature,
      if (appVersion != null) 'app_version': appVersion,
      if (bankVersion != null) 'bank_version': bankVersion,
      if (os != null) 'os': os,
      if (device != null) 'device': device,
      if (screen != null) 'screen': screen,
      if (errorType != null) 'error_type': errorType,
      if (message != null) 'message': message,
      if (stack != null) 'stack': stack,
      if (count != null) 'count': count,
      if (firstAt != null) 'first_at': firstAt,
      if (lastAt != null) 'last_at': lastAt,
      if (sentAt != null) 'sent_at': sentAt,
    });
  }

  CrashReportsCompanion copyWith({
    Value<int>? id,
    Value<String>? signature,
    Value<String>? appVersion,
    Value<int>? bankVersion,
    Value<String>? os,
    Value<String>? device,
    Value<String>? screen,
    Value<String>? errorType,
    Value<String>? message,
    Value<String>? stack,
    Value<int>? count,
    Value<DateTime>? firstAt,
    Value<DateTime>? lastAt,
    Value<DateTime?>? sentAt,
  }) {
    return CrashReportsCompanion(
      id: id ?? this.id,
      signature: signature ?? this.signature,
      appVersion: appVersion ?? this.appVersion,
      bankVersion: bankVersion ?? this.bankVersion,
      os: os ?? this.os,
      device: device ?? this.device,
      screen: screen ?? this.screen,
      errorType: errorType ?? this.errorType,
      message: message ?? this.message,
      stack: stack ?? this.stack,
      count: count ?? this.count,
      firstAt: firstAt ?? this.firstAt,
      lastAt: lastAt ?? this.lastAt,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (signature.present) {
      map['signature'] = Variable<String>(signature.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (bankVersion.present) {
      map['bank_version'] = Variable<int>(bankVersion.value);
    }
    if (os.present) {
      map['os'] = Variable<String>(os.value);
    }
    if (device.present) {
      map['device'] = Variable<String>(device.value);
    }
    if (screen.present) {
      map['screen'] = Variable<String>(screen.value);
    }
    if (errorType.present) {
      map['error_type'] = Variable<String>(errorType.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (stack.present) {
      map['stack'] = Variable<String>(stack.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (firstAt.present) {
      map['first_at'] = Variable<DateTime>(firstAt.value);
    }
    if (lastAt.present) {
      map['last_at'] = Variable<DateTime>(lastAt.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CrashReportsCompanion(')
          ..write('id: $id, ')
          ..write('signature: $signature, ')
          ..write('appVersion: $appVersion, ')
          ..write('bankVersion: $bankVersion, ')
          ..write('os: $os, ')
          ..write('device: $device, ')
          ..write('screen: $screen, ')
          ..write('errorType: $errorType, ')
          ..write('message: $message, ')
          ..write('stack: $stack, ')
          ..write('count: $count, ')
          ..write('firstAt: $firstAt, ')
          ..write('lastAt: $lastAt, ')
          ..write('sentAt: $sentAt')
          ..write(')'))
        .toString();
  }
}

class $PlusStateTable extends PlusState
    with TableInfo<$PlusStateTable, PlusStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlusStateTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _plusMeta = const VerificationMeta('plus');
  @override
  late final GeneratedColumn<bool> plus = GeneratedColumn<bool>(
    'plus',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("plus" IN (0, 1))',
    ),
  );
  static const VerificationMeta _untilMeta = const VerificationMeta('until');
  @override
  late final GeneratedColumn<DateTime> until = GeneratedColumn<DateTime>(
    'until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _willRenewMeta = const VerificationMeta(
    'willRenew',
  );
  @override
  late final GeneratedColumn<bool> willRenew = GeneratedColumn<bool>(
    'will_renew',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("will_renew" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _serverCheckedAtMeta = const VerificationMeta(
    'serverCheckedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverCheckedAt =
      GeneratedColumn<DateTime>(
        'server_checked_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _deviceCheckedAtMeta = const VerificationMeta(
    'deviceCheckedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deviceCheckedAt =
      GeneratedColumn<DateTime>(
        'device_checked_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    plus,
    until,
    source,
    status,
    willRenew,
    endedAt,
    serverCheckedAt,
    deviceCheckedAt,
    accountId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plus_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlusStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plus')) {
      context.handle(
        _plusMeta,
        plus.isAcceptableOrUnknown(data['plus']!, _plusMeta),
      );
    } else if (isInserting) {
      context.missing(_plusMeta);
    }
    if (data.containsKey('until')) {
      context.handle(
        _untilMeta,
        until.isAcceptableOrUnknown(data['until']!, _untilMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('will_renew')) {
      context.handle(
        _willRenewMeta,
        willRenew.isAcceptableOrUnknown(data['will_renew']!, _willRenewMeta),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('server_checked_at')) {
      context.handle(
        _serverCheckedAtMeta,
        serverCheckedAt.isAcceptableOrUnknown(
          data['server_checked_at']!,
          _serverCheckedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverCheckedAtMeta);
    }
    if (data.containsKey('device_checked_at')) {
      context.handle(
        _deviceCheckedAtMeta,
        deviceCheckedAt.isAcceptableOrUnknown(
          data['device_checked_at']!,
          _deviceCheckedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deviceCheckedAtMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlusStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlusStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      plus: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}plus'],
      )!,
      until: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}until'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      willRenew: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}will_renew'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      serverCheckedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_checked_at'],
      )!,
      deviceCheckedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}device_checked_at'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
    );
  }

  @override
  $PlusStateTable createAlias(String alias) {
    return $PlusStateTable(attachedDatabase, alias);
  }
}

class PlusStateData extends DataClass implements Insertable<PlusStateData> {
  final int id;
  final bool plus;
  final DateTime? until;
  final String? source;
  final String? status;
  final bool willRenew;
  final DateTime? endedAt;
  final DateTime serverCheckedAt;
  final DateTime deviceCheckedAt;
  final String accountId;
  const PlusStateData({
    required this.id,
    required this.plus,
    this.until,
    this.source,
    this.status,
    required this.willRenew,
    this.endedAt,
    required this.serverCheckedAt,
    required this.deviceCheckedAt,
    required this.accountId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plus'] = Variable<bool>(plus);
    if (!nullToAbsent || until != null) {
      map['until'] = Variable<DateTime>(until);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    map['will_renew'] = Variable<bool>(willRenew);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['server_checked_at'] = Variable<DateTime>(serverCheckedAt);
    map['device_checked_at'] = Variable<DateTime>(deviceCheckedAt);
    map['account_id'] = Variable<String>(accountId);
    return map;
  }

  PlusStateCompanion toCompanion(bool nullToAbsent) {
    return PlusStateCompanion(
      id: Value(id),
      plus: Value(plus),
      until: until == null && nullToAbsent
          ? const Value.absent()
          : Value(until),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      willRenew: Value(willRenew),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      serverCheckedAt: Value(serverCheckedAt),
      deviceCheckedAt: Value(deviceCheckedAt),
      accountId: Value(accountId),
    );
  }

  factory PlusStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlusStateData(
      id: serializer.fromJson<int>(json['id']),
      plus: serializer.fromJson<bool>(json['plus']),
      until: serializer.fromJson<DateTime?>(json['until']),
      source: serializer.fromJson<String?>(json['source']),
      status: serializer.fromJson<String?>(json['status']),
      willRenew: serializer.fromJson<bool>(json['willRenew']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      serverCheckedAt: serializer.fromJson<DateTime>(json['serverCheckedAt']),
      deviceCheckedAt: serializer.fromJson<DateTime>(json['deviceCheckedAt']),
      accountId: serializer.fromJson<String>(json['accountId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'plus': serializer.toJson<bool>(plus),
      'until': serializer.toJson<DateTime?>(until),
      'source': serializer.toJson<String?>(source),
      'status': serializer.toJson<String?>(status),
      'willRenew': serializer.toJson<bool>(willRenew),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'serverCheckedAt': serializer.toJson<DateTime>(serverCheckedAt),
      'deviceCheckedAt': serializer.toJson<DateTime>(deviceCheckedAt),
      'accountId': serializer.toJson<String>(accountId),
    };
  }

  PlusStateData copyWith({
    int? id,
    bool? plus,
    Value<DateTime?> until = const Value.absent(),
    Value<String?> source = const Value.absent(),
    Value<String?> status = const Value.absent(),
    bool? willRenew,
    Value<DateTime?> endedAt = const Value.absent(),
    DateTime? serverCheckedAt,
    DateTime? deviceCheckedAt,
    String? accountId,
  }) => PlusStateData(
    id: id ?? this.id,
    plus: plus ?? this.plus,
    until: until.present ? until.value : this.until,
    source: source.present ? source.value : this.source,
    status: status.present ? status.value : this.status,
    willRenew: willRenew ?? this.willRenew,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    serverCheckedAt: serverCheckedAt ?? this.serverCheckedAt,
    deviceCheckedAt: deviceCheckedAt ?? this.deviceCheckedAt,
    accountId: accountId ?? this.accountId,
  );
  PlusStateData copyWithCompanion(PlusStateCompanion data) {
    return PlusStateData(
      id: data.id.present ? data.id.value : this.id,
      plus: data.plus.present ? data.plus.value : this.plus,
      until: data.until.present ? data.until.value : this.until,
      source: data.source.present ? data.source.value : this.source,
      status: data.status.present ? data.status.value : this.status,
      willRenew: data.willRenew.present ? data.willRenew.value : this.willRenew,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      serverCheckedAt: data.serverCheckedAt.present
          ? data.serverCheckedAt.value
          : this.serverCheckedAt,
      deviceCheckedAt: data.deviceCheckedAt.present
          ? data.deviceCheckedAt.value
          : this.deviceCheckedAt,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlusStateData(')
          ..write('id: $id, ')
          ..write('plus: $plus, ')
          ..write('until: $until, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('willRenew: $willRenew, ')
          ..write('endedAt: $endedAt, ')
          ..write('serverCheckedAt: $serverCheckedAt, ')
          ..write('deviceCheckedAt: $deviceCheckedAt, ')
          ..write('accountId: $accountId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    plus,
    until,
    source,
    status,
    willRenew,
    endedAt,
    serverCheckedAt,
    deviceCheckedAt,
    accountId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlusStateData &&
          other.id == this.id &&
          other.plus == this.plus &&
          other.until == this.until &&
          other.source == this.source &&
          other.status == this.status &&
          other.willRenew == this.willRenew &&
          other.endedAt == this.endedAt &&
          other.serverCheckedAt == this.serverCheckedAt &&
          other.deviceCheckedAt == this.deviceCheckedAt &&
          other.accountId == this.accountId);
}

class PlusStateCompanion extends UpdateCompanion<PlusStateData> {
  final Value<int> id;
  final Value<bool> plus;
  final Value<DateTime?> until;
  final Value<String?> source;
  final Value<String?> status;
  final Value<bool> willRenew;
  final Value<DateTime?> endedAt;
  final Value<DateTime> serverCheckedAt;
  final Value<DateTime> deviceCheckedAt;
  final Value<String> accountId;
  const PlusStateCompanion({
    this.id = const Value.absent(),
    this.plus = const Value.absent(),
    this.until = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.willRenew = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.serverCheckedAt = const Value.absent(),
    this.deviceCheckedAt = const Value.absent(),
    this.accountId = const Value.absent(),
  });
  PlusStateCompanion.insert({
    this.id = const Value.absent(),
    required bool plus,
    this.until = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.willRenew = const Value.absent(),
    this.endedAt = const Value.absent(),
    required DateTime serverCheckedAt,
    required DateTime deviceCheckedAt,
    required String accountId,
  }) : plus = Value(plus),
       serverCheckedAt = Value(serverCheckedAt),
       deviceCheckedAt = Value(deviceCheckedAt),
       accountId = Value(accountId);
  static Insertable<PlusStateData> custom({
    Expression<int>? id,
    Expression<bool>? plus,
    Expression<DateTime>? until,
    Expression<String>? source,
    Expression<String>? status,
    Expression<bool>? willRenew,
    Expression<DateTime>? endedAt,
    Expression<DateTime>? serverCheckedAt,
    Expression<DateTime>? deviceCheckedAt,
    Expression<String>? accountId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plus != null) 'plus': plus,
      if (until != null) 'until': until,
      if (source != null) 'source': source,
      if (status != null) 'status': status,
      if (willRenew != null) 'will_renew': willRenew,
      if (endedAt != null) 'ended_at': endedAt,
      if (serverCheckedAt != null) 'server_checked_at': serverCheckedAt,
      if (deviceCheckedAt != null) 'device_checked_at': deviceCheckedAt,
      if (accountId != null) 'account_id': accountId,
    });
  }

  PlusStateCompanion copyWith({
    Value<int>? id,
    Value<bool>? plus,
    Value<DateTime?>? until,
    Value<String?>? source,
    Value<String?>? status,
    Value<bool>? willRenew,
    Value<DateTime?>? endedAt,
    Value<DateTime>? serverCheckedAt,
    Value<DateTime>? deviceCheckedAt,
    Value<String>? accountId,
  }) {
    return PlusStateCompanion(
      id: id ?? this.id,
      plus: plus ?? this.plus,
      until: until ?? this.until,
      source: source ?? this.source,
      status: status ?? this.status,
      willRenew: willRenew ?? this.willRenew,
      endedAt: endedAt ?? this.endedAt,
      serverCheckedAt: serverCheckedAt ?? this.serverCheckedAt,
      deviceCheckedAt: deviceCheckedAt ?? this.deviceCheckedAt,
      accountId: accountId ?? this.accountId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (plus.present) {
      map['plus'] = Variable<bool>(plus.value);
    }
    if (until.present) {
      map['until'] = Variable<DateTime>(until.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (willRenew.present) {
      map['will_renew'] = Variable<bool>(willRenew.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (serverCheckedAt.present) {
      map['server_checked_at'] = Variable<DateTime>(serverCheckedAt.value);
    }
    if (deviceCheckedAt.present) {
      map['device_checked_at'] = Variable<DateTime>(deviceCheckedAt.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlusStateCompanion(')
          ..write('id: $id, ')
          ..write('plus: $plus, ')
          ..write('until: $until, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('willRenew: $willRenew, ')
          ..write('endedAt: $endedAt, ')
          ..write('serverCheckedAt: $serverCheckedAt, ')
          ..write('deviceCheckedAt: $deviceCheckedAt, ')
          ..write('accountId: $accountId')
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
  late final $ChildrenTable children = $ChildrenTable(this);
  late final $TopicUnlocksTable topicUnlocks = $TopicUnlocksTable(this);
  late final $SyncFieldsTable syncFields = $SyncFieldsTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $BankFilesTable bankFiles = $BankFilesTable(this);
  late final $CrashReportsTable crashReports = $CrashReportsTable(this);
  late final $PlusStateTable plusState = $PlusStateTable(this);
  late final Index roundsUuid = Index(
    'rounds_uuid',
    'CREATE UNIQUE INDEX rounds_uuid ON rounds (uuid)',
  );
  late final Index attemptsUuid = Index(
    'attempts_uuid',
    'CREATE UNIQUE INDEX attempts_uuid ON attempts (uuid)',
  );
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
    children,
    topicUnlocks,
    syncFields,
    syncState,
    bankFiles,
    crashReports,
    plusState,
    roundsUuid,
    attemptsUuid,
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
      Value<String> deviceId,
      Value<DateTime?> bankCheckedAt,
      Value<String?> bankCheckNote,
      Value<int> currentChildId,
      Value<bool> switchNeedsPin,
      Value<String?> setupStep,
      Value<bool> crashReports,
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
      Value<String> deviceId,
      Value<DateTime?> bankCheckedAt,
      Value<String?> bankCheckNote,
      Value<int> currentChildId,
      Value<bool> switchNeedsPin,
      Value<String?> setupStep,
      Value<bool> crashReports,
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

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get bankCheckedAt => $composableBuilder(
    column: $table.bankCheckedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankCheckNote => $composableBuilder(
    column: $table.bankCheckNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentChildId => $composableBuilder(
    column: $table.currentChildId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get switchNeedsPin => $composableBuilder(
    column: $table.switchNeedsPin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setupStep => $composableBuilder(
    column: $table.setupStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get crashReports => $composableBuilder(
    column: $table.crashReports,
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

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get bankCheckedAt => $composableBuilder(
    column: $table.bankCheckedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankCheckNote => $composableBuilder(
    column: $table.bankCheckNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentChildId => $composableBuilder(
    column: $table.currentChildId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get switchNeedsPin => $composableBuilder(
    column: $table.switchNeedsPin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setupStep => $composableBuilder(
    column: $table.setupStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get crashReports => $composableBuilder(
    column: $table.crashReports,
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

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get bankCheckedAt => $composableBuilder(
    column: $table.bankCheckedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bankCheckNote => $composableBuilder(
    column: $table.bankCheckNote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentChildId => $composableBuilder(
    column: $table.currentChildId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get switchNeedsPin => $composableBuilder(
    column: $table.switchNeedsPin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get setupStep =>
      $composableBuilder(column: $table.setupStep, builder: (column) => column);

  GeneratedColumn<bool> get crashReports => $composableBuilder(
    column: $table.crashReports,
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
                Value<String> deviceId = const Value.absent(),
                Value<DateTime?> bankCheckedAt = const Value.absent(),
                Value<String?> bankCheckNote = const Value.absent(),
                Value<int> currentChildId = const Value.absent(),
                Value<bool> switchNeedsPin = const Value.absent(),
                Value<String?> setupStep = const Value.absent(),
                Value<bool> crashReports = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                pinHash: pinHash,
                pinSalt: pinSalt,
                dailyLimitMin: dailyLimitMin,
                bankVersion: bankVersion,
                soundOn: soundOn,
                profilePending: profilePending,
                deviceId: deviceId,
                bankCheckedAt: bankCheckedAt,
                bankCheckNote: bankCheckNote,
                currentChildId: currentChildId,
                switchNeedsPin: switchNeedsPin,
                setupStep: setupStep,
                crashReports: crashReports,
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
                Value<String> deviceId = const Value.absent(),
                Value<DateTime?> bankCheckedAt = const Value.absent(),
                Value<String?> bankCheckNote = const Value.absent(),
                Value<int> currentChildId = const Value.absent(),
                Value<bool> switchNeedsPin = const Value.absent(),
                Value<String?> setupStep = const Value.absent(),
                Value<bool> crashReports = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                pinHash: pinHash,
                pinSalt: pinSalt,
                dailyLimitMin: dailyLimitMin,
                bankVersion: bankVersion,
                soundOn: soundOn,
                profilePending: profilePending,
                deviceId: deviceId,
                bankCheckedAt: bankCheckedAt,
                bankCheckNote: bankCheckNote,
                currentChildId: currentChildId,
                switchNeedsPin: switchNeedsPin,
                setupStep: setupStep,
                crashReports: crashReports,
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
  required int childId,
  required String topicId,
  Value<int> level,
  required DateTime startedAt,
  Value<int> score,
  Value<int> durationMs,
  Value<int> stars,
  Value<DateTime?> finishedAt,
  Value<String> kind,
  Value<String> uuid,
  Value<int> dirty,
  Value<String?> remoteId,
});
typedef $$RoundsTableUpdateCompanionBuilder = RoundsCompanion Function({
  Value<int> id,
  Value<int> sessionId,
  Value<int> childId,
  Value<String> topicId,
  Value<int> level,
  Value<DateTime> startedAt,
  Value<int> score,
  Value<int> durationMs,
  Value<int> stars,
  Value<DateTime?> finishedAt,
  Value<String> kind,
  Value<String> uuid,
  Value<int> dirty,
  Value<String?> remoteId,
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

  ColumnFilters<int> get childId => $composableBuilder(
    column: $table.childId,
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
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

  ColumnOrderings<int> get childId => $composableBuilder(
    column: $table.childId,
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
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

  GeneratedColumn<int> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

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

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

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
                Value<int> childId = const Value.absent(),
                Value<String> topicId = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> stars = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<int> dirty = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
              }) => RoundsCompanion(
                id: id,
                sessionId: sessionId,
                childId: childId,
                topicId: topicId,
                level: level,
                startedAt: startedAt,
                score: score,
                durationMs: durationMs,
                stars: stars,
                finishedAt: finishedAt,
                kind: kind,
                uuid: uuid,
                dirty: dirty,
                remoteId: remoteId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int childId,
                required String topicId,
                Value<int> level = const Value.absent(),
                required DateTime startedAt,
                Value<int> score = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> stars = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<int> dirty = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
              }) => RoundsCompanion.insert(
                id: id,
                sessionId: sessionId,
                childId: childId,
                topicId: topicId,
                level: level,
                startedAt: startedAt,
                score: score,
                durationMs: durationMs,
                stars: stars,
                finishedAt: finishedAt,
                kind: kind,
                uuid: uuid,
                dirty: dirty,
                remoteId: remoteId,
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
  required int childId,
  required String questionId,
  required String answerGiven,
  required bool correct,
  required int timeMs,
  required DateTime answeredAt,
  Value<String> uuid,
  Value<int> dirty,
});
typedef $$AttemptsTableUpdateCompanionBuilder = AttemptsCompanion Function({
  Value<int> id,
  Value<int> roundId,
  Value<int> childId,
  Value<String> questionId,
  Value<String> answerGiven,
  Value<bool> correct,
  Value<int> timeMs,
  Value<DateTime> answeredAt,
  Value<String> uuid,
  Value<int> dirty,
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

  ColumnFilters<int> get childId => $composableBuilder(
    column: $table.childId,
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dirty => $composableBuilder(
    column: $table.dirty,
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

  ColumnOrderings<int> get childId => $composableBuilder(
    column: $table.childId,
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dirty => $composableBuilder(
    column: $table.dirty,
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

  GeneratedColumn<int> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

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

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

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
                Value<int> childId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> answerGiven = const Value.absent(),
                Value<bool> correct = const Value.absent(),
                Value<int> timeMs = const Value.absent(),
                Value<DateTime> answeredAt = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<int> dirty = const Value.absent(),
              }) => AttemptsCompanion(
                id: id,
                roundId: roundId,
                childId: childId,
                questionId: questionId,
                answerGiven: answerGiven,
                correct: correct,
                timeMs: timeMs,
                answeredAt: answeredAt,
                uuid: uuid,
                dirty: dirty,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int roundId,
                required int childId,
                required String questionId,
                required String answerGiven,
                required bool correct,
                required int timeMs,
                required DateTime answeredAt,
                Value<String> uuid = const Value.absent(),
                Value<int> dirty = const Value.absent(),
              }) => AttemptsCompanion.insert(
                id: id,
                roundId: roundId,
                childId: childId,
                questionId: questionId,
                answerGiven: answerGiven,
                correct: correct,
                timeMs: timeMs,
                answeredAt: answeredAt,
                uuid: uuid,
                dirty: dirty,
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
  required int childId,
  required String day,
  required String deviceId,
  Value<int> secondsUsed,
  Value<int> extraSecondsGranted,
  Value<int> dirty,
  Value<String?> remoteId,
  Value<int> rowid,
});
typedef $$DailyUsageTableUpdateCompanionBuilder = DailyUsageCompanion Function({
  Value<int> childId,
  Value<String> day,
  Value<String> deviceId,
  Value<int> secondsUsed,
  Value<int> extraSecondsGranted,
  Value<int> dirty,
  Value<String?> remoteId,
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
  ColumnFilters<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
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

  ColumnFilters<int> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
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
  ColumnOrderings<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
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

  ColumnOrderings<int> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
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
  GeneratedColumn<int> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get secondsUsed => $composableBuilder(
    column: $table.secondsUsed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get extraSecondsGranted => $composableBuilder(
    column: $table.extraSecondsGranted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);
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
                Value<int> childId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> secondsUsed = const Value.absent(),
                Value<int> extraSecondsGranted = const Value.absent(),
                Value<int> dirty = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyUsageCompanion(
                childId: childId,
                day: day,
                deviceId: deviceId,
                secondsUsed: secondsUsed,
                extraSecondsGranted: extraSecondsGranted,
                dirty: dirty,
                remoteId: remoteId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int childId,
                required String day,
                required String deviceId,
                Value<int> secondsUsed = const Value.absent(),
                Value<int> extraSecondsGranted = const Value.absent(),
                Value<int> dirty = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyUsageCompanion.insert(
                childId: childId,
                day: day,
                deviceId: deviceId,
                secondsUsed: secondsUsed,
                extraSecondsGranted: extraSecondsGranted,
                dirty: dirty,
                remoteId: remoteId,
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
      required int childId,
      required String badgeId,
      required DateTime earnedAt,
      Value<int> dirty,
      Value<String?> remoteId,
      Value<int> rowid,
    });
typedef $$BadgesEarnedTableUpdateCompanionBuilder =
    BadgesEarnedCompanion Function({
      Value<int> childId,
      Value<String> badgeId,
      Value<DateTime> earnedAt,
      Value<int> dirty,
      Value<String?> remoteId,
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
  ColumnFilters<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get badgeId => $composableBuilder(
    column: $table.badgeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get earnedAt => $composableBuilder(
    column: $table.earnedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
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
  ColumnOrderings<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get badgeId => $composableBuilder(
    column: $table.badgeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get earnedAt => $composableBuilder(
    column: $table.earnedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
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
  GeneratedColumn<int> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<String> get badgeId =>
      $composableBuilder(column: $table.badgeId, builder: (column) => column);

  GeneratedColumn<DateTime> get earnedAt =>
      $composableBuilder(column: $table.earnedAt, builder: (column) => column);

  GeneratedColumn<int> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);
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
                Value<int> childId = const Value.absent(),
                Value<String> badgeId = const Value.absent(),
                Value<DateTime> earnedAt = const Value.absent(),
                Value<int> dirty = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BadgesEarnedCompanion(
                childId: childId,
                badgeId: badgeId,
                earnedAt: earnedAt,
                dirty: dirty,
                remoteId: remoteId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int childId,
                required String badgeId,
                required DateTime earnedAt,
                Value<int> dirty = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BadgesEarnedCompanion.insert(
                childId: childId,
                badgeId: badgeId,
                earnedAt: earnedAt,
                dirty: dirty,
                remoteId: remoteId,
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
typedef $$ChildrenTableCreateCompanionBuilder = ChildrenCompanion Function({
  Value<int> id,
  Value<String> nickname,
  Value<int> schoolYear,
  Value<int?> schoolStartLevel,
  Value<int?> olympiadStartLevel,
  Value<String> avatar,
  Value<int> dailyLimitMin,
  Value<bool> soundOn,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String?> remoteId,
  Value<int> resetEpoch,
  Value<bool> pendingReset,
  Value<bool> pendingDelete,
});
typedef $$ChildrenTableUpdateCompanionBuilder = ChildrenCompanion Function({
  Value<int> id,
  Value<String> nickname,
  Value<int> schoolYear,
  Value<int?> schoolStartLevel,
  Value<int?> olympiadStartLevel,
  Value<String> avatar,
  Value<int> dailyLimitMin,
  Value<bool> soundOn,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String?> remoteId,
  Value<int> resetEpoch,
  Value<bool> pendingReset,
  Value<bool> pendingDelete,
});

class $$ChildrenTableFilterComposer
    extends Composer<_$AppDatabase, $ChildrenTable> {
  $$ChildrenTableFilterComposer({
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

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyLimitMin => $composableBuilder(
    column: $table.dailyLimitMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get soundOn => $composableBuilder(
    column: $table.soundOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resetEpoch => $composableBuilder(
    column: $table.resetEpoch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingReset => $composableBuilder(
    column: $table.pendingReset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingDelete => $composableBuilder(
    column: $table.pendingDelete,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChildrenTableOrderingComposer
    extends Composer<_$AppDatabase, $ChildrenTable> {
  $$ChildrenTableOrderingComposer({
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

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyLimitMin => $composableBuilder(
    column: $table.dailyLimitMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get soundOn => $composableBuilder(
    column: $table.soundOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resetEpoch => $composableBuilder(
    column: $table.resetEpoch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingReset => $composableBuilder(
    column: $table.pendingReset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingDelete => $composableBuilder(
    column: $table.pendingDelete,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChildrenTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChildrenTable> {
  $$ChildrenTableAnnotationComposer({
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

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<int> get dailyLimitMin => $composableBuilder(
    column: $table.dailyLimitMin,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get soundOn =>
      $composableBuilder(column: $table.soundOn, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<int> get resetEpoch => $composableBuilder(
    column: $table.resetEpoch,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pendingReset => $composableBuilder(
    column: $table.pendingReset,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pendingDelete => $composableBuilder(
    column: $table.pendingDelete,
    builder: (column) => column,
  );
}

class $$ChildrenTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChildrenTable,
          ChildRow,
          $$ChildrenTableFilterComposer,
          $$ChildrenTableOrderingComposer,
          $$ChildrenTableAnnotationComposer,
          $$ChildrenTableCreateCompanionBuilder,
          $$ChildrenTableUpdateCompanionBuilder,
          (ChildRow, BaseReferences<_$AppDatabase, $ChildrenTable, ChildRow>),
          ChildRow,
          PrefetchHooks Function()
        > {
  $$ChildrenTableTableManager(_$AppDatabase db, $ChildrenTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChildrenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChildrenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChildrenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<int> schoolYear = const Value.absent(),
                Value<int?> schoolStartLevel = const Value.absent(),
                Value<int?> olympiadStartLevel = const Value.absent(),
                Value<String> avatar = const Value.absent(),
                Value<int> dailyLimitMin = const Value.absent(),
                Value<bool> soundOn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<int> resetEpoch = const Value.absent(),
                Value<bool> pendingReset = const Value.absent(),
                Value<bool> pendingDelete = const Value.absent(),
              }) => ChildrenCompanion(
                id: id,
                nickname: nickname,
                schoolYear: schoolYear,
                schoolStartLevel: schoolStartLevel,
                olympiadStartLevel: olympiadStartLevel,
                avatar: avatar,
                dailyLimitMin: dailyLimitMin,
                soundOn: soundOn,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteId: remoteId,
                resetEpoch: resetEpoch,
                pendingReset: pendingReset,
                pendingDelete: pendingDelete,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<int> schoolYear = const Value.absent(),
                Value<int?> schoolStartLevel = const Value.absent(),
                Value<int?> olympiadStartLevel = const Value.absent(),
                Value<String> avatar = const Value.absent(),
                Value<int> dailyLimitMin = const Value.absent(),
                Value<bool> soundOn = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> remoteId = const Value.absent(),
                Value<int> resetEpoch = const Value.absent(),
                Value<bool> pendingReset = const Value.absent(),
                Value<bool> pendingDelete = const Value.absent(),
              }) => ChildrenCompanion.insert(
                id: id,
                nickname: nickname,
                schoolYear: schoolYear,
                schoolStartLevel: schoolStartLevel,
                olympiadStartLevel: olympiadStartLevel,
                avatar: avatar,
                dailyLimitMin: dailyLimitMin,
                soundOn: soundOn,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteId: remoteId,
                resetEpoch: resetEpoch,
                pendingReset: pendingReset,
                pendingDelete: pendingDelete,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChildrenTable, ChildRow>(table),
                  BaseReferences<_$AppDatabase, $ChildrenTable, ChildRow>(
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

typedef $$ChildrenTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChildrenTable,
      ChildRow,
      $$ChildrenTableFilterComposer,
      $$ChildrenTableOrderingComposer,
      $$ChildrenTableAnnotationComposer,
      $$ChildrenTableCreateCompanionBuilder,
      $$ChildrenTableUpdateCompanionBuilder,
      (ChildRow, BaseReferences<_$AppDatabase, $ChildrenTable, ChildRow>),
      ChildRow,
      PrefetchHooks Function()
    >;
typedef $$TopicUnlocksTableCreateCompanionBuilder =
    TopicUnlocksCompanion Function({
      required int childId,
      required String topicId,
      required DateTime openedAt,
      Value<int> rowid,
    });
typedef $$TopicUnlocksTableUpdateCompanionBuilder =
    TopicUnlocksCompanion Function({
      Value<int> childId,
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
  ColumnFilters<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

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
  ColumnOrderings<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

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
  GeneratedColumn<int> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

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
                Value<int> childId = const Value.absent(),
                Value<String> topicId = const Value.absent(),
                Value<DateTime> openedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TopicUnlocksCompanion(
                childId: childId,
                topicId: topicId,
                openedAt: openedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int childId,
                required String topicId,
                required DateTime openedAt,
                Value<int> rowid = const Value.absent(),
              }) => TopicUnlocksCompanion.insert(
                childId: childId,
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
typedef $$SyncFieldsTableCreateCompanionBuilder = SyncFieldsCompanion Function({
  required int childId,
  required String field,
  required DateTime changedAt,
  Value<int> dirty,
  Value<int> rowid,
});
typedef $$SyncFieldsTableUpdateCompanionBuilder = SyncFieldsCompanion Function({
  Value<int> childId,
  Value<String> field,
  Value<DateTime> changedAt,
  Value<int> dirty,
  Value<int> rowid,
});

class $$SyncFieldsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncFieldsTable> {
  $$SyncFieldsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncFieldsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncFieldsTable> {
  $$SyncFieldsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncFieldsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncFieldsTable> {
  $$SyncFieldsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<DateTime> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);

  GeneratedColumn<int> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);
}

class $$SyncFieldsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncFieldsTable,
          SyncField,
          $$SyncFieldsTableFilterComposer,
          $$SyncFieldsTableOrderingComposer,
          $$SyncFieldsTableAnnotationComposer,
          $$SyncFieldsTableCreateCompanionBuilder,
          $$SyncFieldsTableUpdateCompanionBuilder,
          (
            SyncField,
            BaseReferences<_$AppDatabase, $SyncFieldsTable, SyncField>,
          ),
          SyncField,
          PrefetchHooks Function()
        > {
  $$SyncFieldsTableTableManager(_$AppDatabase db, $SyncFieldsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncFieldsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncFieldsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncFieldsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> childId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<DateTime> changedAt = const Value.absent(),
                Value<int> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncFieldsCompanion(
                childId: childId,
                field: field,
                changedAt: changedAt,
                dirty: dirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int childId,
                required String field,
                required DateTime changedAt,
                Value<int> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncFieldsCompanion.insert(
                childId: childId,
                field: field,
                changedAt: changedAt,
                dirty: dirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncFieldsTable, SyncField>(table),
                  BaseReferences<_$AppDatabase, $SyncFieldsTable, SyncField>(
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

typedef $$SyncFieldsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncFieldsTable,
      SyncField,
      $$SyncFieldsTableFilterComposer,
      $$SyncFieldsTableOrderingComposer,
      $$SyncFieldsTableAnnotationComposer,
      $$SyncFieldsTableCreateCompanionBuilder,
      $$SyncFieldsTableUpdateCompanionBuilder,
      (SyncField, BaseReferences<_$AppDatabase, $SyncFieldsTable, SyncField>),
      SyncField,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder = SyncStateCompanion Function({
  Value<int> id,
  Value<String?> accountId,
  Value<String?> childId,
  Value<int> resetEpoch,
  Value<bool> pendingReset,
  Value<String> cursors,
  Value<DateTime?> lastSyncAt,
  Value<String?> lastError,
});
typedef $$SyncStateTableUpdateCompanionBuilder = SyncStateCompanion Function({
  Value<int> id,
  Value<String?> accountId,
  Value<String?> childId,
  Value<int> resetEpoch,
  Value<bool> pendingReset,
  Value<String> cursors,
  Value<DateTime?> lastSyncAt,
  Value<String?> lastError,
});

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
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

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resetEpoch => $composableBuilder(
    column: $table.resetEpoch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingReset => $composableBuilder(
    column: $table.pendingReset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cursors => $composableBuilder(
    column: $table.cursors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
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

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resetEpoch => $composableBuilder(
    column: $table.resetEpoch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingReset => $composableBuilder(
    column: $table.pendingReset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursors => $composableBuilder(
    column: $table.cursors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<int> get resetEpoch => $composableBuilder(
    column: $table.resetEpoch,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pendingReset => $composableBuilder(
    column: $table.pendingReset,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cursors =>
      $composableBuilder(column: $table.cursors, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateData,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateData,
            BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
          ),
          SyncStateData,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String?> childId = const Value.absent(),
                Value<int> resetEpoch = const Value.absent(),
                Value<bool> pendingReset = const Value.absent(),
                Value<String> cursors = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => SyncStateCompanion(
                id: id,
                accountId: accountId,
                childId: childId,
                resetEpoch: resetEpoch,
                pendingReset: pendingReset,
                cursors: cursors,
                lastSyncAt: lastSyncAt,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String?> childId = const Value.absent(),
                Value<int> resetEpoch = const Value.absent(),
                Value<bool> pendingReset = const Value.absent(),
                Value<String> cursors = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => SyncStateCompanion.insert(
                id: id,
                accountId: accountId,
                childId: childId,
                resetEpoch: resetEpoch,
                pendingReset: pendingReset,
                cursors: cursors,
                lastSyncAt: lastSyncAt,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncStateTable, SyncStateData>(table),
                  BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>(
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

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateData,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateData,
        BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
      ),
      SyncStateData,
      PrefetchHooks Function()
    >;
typedef $$BankFilesTableCreateCompanionBuilder = BankFilesCompanion Function({
  Value<int> version,
  required int format,
  required String sha256,
  required String path,
  required DateTime downloadedAt,
});
typedef $$BankFilesTableUpdateCompanionBuilder = BankFilesCompanion Function({
  Value<int> version,
  Value<int> format,
  Value<String> sha256,
  Value<String> path,
  Value<DateTime> downloadedAt,
});

class $$BankFilesTableFilterComposer
    extends Composer<_$AppDatabase, $BankFilesTable> {
  $$BankFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BankFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $BankFilesTable> {
  $$BankFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BankFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BankFilesTable> {
  $$BankFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );
}

class $$BankFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BankFilesTable,
          BankFileRow,
          $$BankFilesTableFilterComposer,
          $$BankFilesTableOrderingComposer,
          $$BankFilesTableAnnotationComposer,
          $$BankFilesTableCreateCompanionBuilder,
          $$BankFilesTableUpdateCompanionBuilder,
          (
            BankFileRow,
            BaseReferences<_$AppDatabase, $BankFilesTable, BankFileRow>,
          ),
          BankFileRow,
          PrefetchHooks Function()
        > {
  $$BankFilesTableTableManager(_$AppDatabase db, $BankFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BankFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BankFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BankFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> version = const Value.absent(),
                Value<int> format = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
              }) => BankFilesCompanion(
                version: version,
                format: format,
                sha256: sha256,
                path: path,
                downloadedAt: downloadedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> version = const Value.absent(),
                required int format,
                required String sha256,
                required String path,
                required DateTime downloadedAt,
              }) => BankFilesCompanion.insert(
                version: version,
                format: format,
                sha256: sha256,
                path: path,
                downloadedAt: downloadedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BankFilesTable, BankFileRow>(table),
                  BaseReferences<_$AppDatabase, $BankFilesTable, BankFileRow>(
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

typedef $$BankFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BankFilesTable,
      BankFileRow,
      $$BankFilesTableFilterComposer,
      $$BankFilesTableOrderingComposer,
      $$BankFilesTableAnnotationComposer,
      $$BankFilesTableCreateCompanionBuilder,
      $$BankFilesTableUpdateCompanionBuilder,
      (
        BankFileRow,
        BaseReferences<_$AppDatabase, $BankFilesTable, BankFileRow>,
      ),
      BankFileRow,
      PrefetchHooks Function()
    >;
typedef $$CrashReportsTableCreateCompanionBuilder =
    CrashReportsCompanion Function({
      Value<int> id,
      required String signature,
      required String appVersion,
      required int bankVersion,
      required String os,
      required String device,
      required String screen,
      required String errorType,
      required String message,
      required String stack,
      Value<int> count,
      required DateTime firstAt,
      required DateTime lastAt,
      Value<DateTime?> sentAt,
    });
typedef $$CrashReportsTableUpdateCompanionBuilder =
    CrashReportsCompanion Function({
      Value<int> id,
      Value<String> signature,
      Value<String> appVersion,
      Value<int> bankVersion,
      Value<String> os,
      Value<String> device,
      Value<String> screen,
      Value<String> errorType,
      Value<String> message,
      Value<String> stack,
      Value<int> count,
      Value<DateTime> firstAt,
      Value<DateTime> lastAt,
      Value<DateTime?> sentAt,
    });

class $$CrashReportsTableFilterComposer
    extends Composer<_$AppDatabase, $CrashReportsTable> {
  $$CrashReportsTableFilterComposer({
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

  ColumnFilters<String> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bankVersion => $composableBuilder(
    column: $table.bankVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get os => $composableBuilder(
    column: $table.os,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get device => $composableBuilder(
    column: $table.device,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get screen => $composableBuilder(
    column: $table.screen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorType => $composableBuilder(
    column: $table.errorType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stack => $composableBuilder(
    column: $table.stack,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstAt => $composableBuilder(
    column: $table.firstAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAt => $composableBuilder(
    column: $table.lastAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CrashReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $CrashReportsTable> {
  $$CrashReportsTableOrderingComposer({
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

  ColumnOrderings<String> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bankVersion => $composableBuilder(
    column: $table.bankVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get os => $composableBuilder(
    column: $table.os,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get device => $composableBuilder(
    column: $table.device,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get screen => $composableBuilder(
    column: $table.screen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorType => $composableBuilder(
    column: $table.errorType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stack => $composableBuilder(
    column: $table.stack,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstAt => $composableBuilder(
    column: $table.firstAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAt => $composableBuilder(
    column: $table.lastAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CrashReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CrashReportsTable> {
  $$CrashReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get signature =>
      $composableBuilder(column: $table.signature, builder: (column) => column);

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bankVersion => $composableBuilder(
    column: $table.bankVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get os =>
      $composableBuilder(column: $table.os, builder: (column) => column);

  GeneratedColumn<String> get device =>
      $composableBuilder(column: $table.device, builder: (column) => column);

  GeneratedColumn<String> get screen =>
      $composableBuilder(column: $table.screen, builder: (column) => column);

  GeneratedColumn<String> get errorType =>
      $composableBuilder(column: $table.errorType, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get stack =>
      $composableBuilder(column: $table.stack, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<DateTime> get firstAt =>
      $composableBuilder(column: $table.firstAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAt =>
      $composableBuilder(column: $table.lastAt, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);
}

class $$CrashReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CrashReportsTable,
          CrashReport,
          $$CrashReportsTableFilterComposer,
          $$CrashReportsTableOrderingComposer,
          $$CrashReportsTableAnnotationComposer,
          $$CrashReportsTableCreateCompanionBuilder,
          $$CrashReportsTableUpdateCompanionBuilder,
          (
            CrashReport,
            BaseReferences<_$AppDatabase, $CrashReportsTable, CrashReport>,
          ),
          CrashReport,
          PrefetchHooks Function()
        > {
  $$CrashReportsTableTableManager(_$AppDatabase db, $CrashReportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CrashReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CrashReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CrashReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> signature = const Value.absent(),
                Value<String> appVersion = const Value.absent(),
                Value<int> bankVersion = const Value.absent(),
                Value<String> os = const Value.absent(),
                Value<String> device = const Value.absent(),
                Value<String> screen = const Value.absent(),
                Value<String> errorType = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String> stack = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<DateTime> firstAt = const Value.absent(),
                Value<DateTime> lastAt = const Value.absent(),
                Value<DateTime?> sentAt = const Value.absent(),
              }) => CrashReportsCompanion(
                id: id,
                signature: signature,
                appVersion: appVersion,
                bankVersion: bankVersion,
                os: os,
                device: device,
                screen: screen,
                errorType: errorType,
                message: message,
                stack: stack,
                count: count,
                firstAt: firstAt,
                lastAt: lastAt,
                sentAt: sentAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String signature,
                required String appVersion,
                required int bankVersion,
                required String os,
                required String device,
                required String screen,
                required String errorType,
                required String message,
                required String stack,
                Value<int> count = const Value.absent(),
                required DateTime firstAt,
                required DateTime lastAt,
                Value<DateTime?> sentAt = const Value.absent(),
              }) => CrashReportsCompanion.insert(
                id: id,
                signature: signature,
                appVersion: appVersion,
                bankVersion: bankVersion,
                os: os,
                device: device,
                screen: screen,
                errorType: errorType,
                message: message,
                stack: stack,
                count: count,
                firstAt: firstAt,
                lastAt: lastAt,
                sentAt: sentAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CrashReportsTable, CrashReport>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CrashReportsTable,
                    CrashReport
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CrashReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CrashReportsTable,
      CrashReport,
      $$CrashReportsTableFilterComposer,
      $$CrashReportsTableOrderingComposer,
      $$CrashReportsTableAnnotationComposer,
      $$CrashReportsTableCreateCompanionBuilder,
      $$CrashReportsTableUpdateCompanionBuilder,
      (
        CrashReport,
        BaseReferences<_$AppDatabase, $CrashReportsTable, CrashReport>,
      ),
      CrashReport,
      PrefetchHooks Function()
    >;
typedef $$PlusStateTableCreateCompanionBuilder = PlusStateCompanion Function({
  Value<int> id,
  required bool plus,
  Value<DateTime?> until,
  Value<String?> source,
  Value<String?> status,
  Value<bool> willRenew,
  Value<DateTime?> endedAt,
  required DateTime serverCheckedAt,
  required DateTime deviceCheckedAt,
  required String accountId,
});
typedef $$PlusStateTableUpdateCompanionBuilder = PlusStateCompanion Function({
  Value<int> id,
  Value<bool> plus,
  Value<DateTime?> until,
  Value<String?> source,
  Value<String?> status,
  Value<bool> willRenew,
  Value<DateTime?> endedAt,
  Value<DateTime> serverCheckedAt,
  Value<DateTime> deviceCheckedAt,
  Value<String> accountId,
});

class $$PlusStateTableFilterComposer
    extends Composer<_$AppDatabase, $PlusStateTable> {
  $$PlusStateTableFilterComposer({
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

  ColumnFilters<bool> get plus => $composableBuilder(
    column: $table.plus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get until => $composableBuilder(
    column: $table.until,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get willRenew => $composableBuilder(
    column: $table.willRenew,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverCheckedAt => $composableBuilder(
    column: $table.serverCheckedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deviceCheckedAt => $composableBuilder(
    column: $table.deviceCheckedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlusStateTableOrderingComposer
    extends Composer<_$AppDatabase, $PlusStateTable> {
  $$PlusStateTableOrderingComposer({
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

  ColumnOrderings<bool> get plus => $composableBuilder(
    column: $table.plus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get until => $composableBuilder(
    column: $table.until,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get willRenew => $composableBuilder(
    column: $table.willRenew,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverCheckedAt => $composableBuilder(
    column: $table.serverCheckedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deviceCheckedAt => $composableBuilder(
    column: $table.deviceCheckedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlusStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlusStateTable> {
  $$PlusStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get plus =>
      $composableBuilder(column: $table.plus, builder: (column) => column);

  GeneratedColumn<DateTime> get until =>
      $composableBuilder(column: $table.until, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get willRenew =>
      $composableBuilder(column: $table.willRenew, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverCheckedAt => $composableBuilder(
    column: $table.serverCheckedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deviceCheckedAt => $composableBuilder(
    column: $table.deviceCheckedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);
}

class $$PlusStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlusStateTable,
          PlusStateData,
          $$PlusStateTableFilterComposer,
          $$PlusStateTableOrderingComposer,
          $$PlusStateTableAnnotationComposer,
          $$PlusStateTableCreateCompanionBuilder,
          $$PlusStateTableUpdateCompanionBuilder,
          (
            PlusStateData,
            BaseReferences<_$AppDatabase, $PlusStateTable, PlusStateData>,
          ),
          PlusStateData,
          PrefetchHooks Function()
        > {
  $$PlusStateTableTableManager(_$AppDatabase db, $PlusStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlusStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlusStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlusStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> plus = const Value.absent(),
                Value<DateTime?> until = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<bool> willRenew = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<DateTime> serverCheckedAt = const Value.absent(),
                Value<DateTime> deviceCheckedAt = const Value.absent(),
                Value<String> accountId = const Value.absent(),
              }) => PlusStateCompanion(
                id: id,
                plus: plus,
                until: until,
                source: source,
                status: status,
                willRenew: willRenew,
                endedAt: endedAt,
                serverCheckedAt: serverCheckedAt,
                deviceCheckedAt: deviceCheckedAt,
                accountId: accountId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required bool plus,
                Value<DateTime?> until = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<bool> willRenew = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                required DateTime serverCheckedAt,
                required DateTime deviceCheckedAt,
                required String accountId,
              }) => PlusStateCompanion.insert(
                id: id,
                plus: plus,
                until: until,
                source: source,
                status: status,
                willRenew: willRenew,
                endedAt: endedAt,
                serverCheckedAt: serverCheckedAt,
                deviceCheckedAt: deviceCheckedAt,
                accountId: accountId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlusStateTable, PlusStateData>(table),
                  BaseReferences<_$AppDatabase, $PlusStateTable, PlusStateData>(
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

typedef $$PlusStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlusStateTable,
      PlusStateData,
      $$PlusStateTableFilterComposer,
      $$PlusStateTableOrderingComposer,
      $$PlusStateTableAnnotationComposer,
      $$PlusStateTableCreateCompanionBuilder,
      $$PlusStateTableUpdateCompanionBuilder,
      (
        PlusStateData,
        BaseReferences<_$AppDatabase, $PlusStateTable, PlusStateData>,
      ),
      PlusStateData,
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
  $$ChildrenTableTableManager get children =>
      $$ChildrenTableTableManager(_db, _db.children);
  $$TopicUnlocksTableTableManager get topicUnlocks =>
      $$TopicUnlocksTableTableManager(_db, _db.topicUnlocks);
  $$SyncFieldsTableTableManager get syncFields =>
      $$SyncFieldsTableTableManager(_db, _db.syncFields);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$BankFilesTableTableManager get bankFiles =>
      $$BankFilesTableTableManager(_db, _db.bankFiles);
  $$CrashReportsTableTableManager get crashReports =>
      $$CrashReportsTableTableManager(_db, _db.crashReports);
  $$PlusStateTableTableManager get plusState =>
      $$PlusStateTableTableManager(_db, _db.plusState);
}
