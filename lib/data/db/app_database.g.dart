// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppsTable extends Apps with TableInfo<$AppsTable, App> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _packageMeta = const VerificationMeta(
    'package',
  );
  @override
  late final GeneratedColumn<String> package = GeneratedColumn<String>(
    'package',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isShortVideoMeta = const VerificationMeta(
    'isShortVideo',
  );
  @override
  late final GeneratedColumn<bool> isShortVideo = GeneratedColumn<bool>(
    'is_short_video',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_short_video" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _trackedMeta = const VerificationMeta(
    'tracked',
  );
  @override
  late final GeneratedColumn<bool> tracked = GeneratedColumn<bool>(
    'tracked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("tracked" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    package,
    label,
    platform,
    category,
    isShortVideo,
    tracked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'apps';
  @override
  VerificationContext validateIntegrity(
    Insertable<App> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('package')) {
      context.handle(
        _packageMeta,
        package.isAcceptableOrUnknown(data['package']!, _packageMeta),
      );
    } else if (isInserting) {
      context.missing(_packageMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('is_short_video')) {
      context.handle(
        _isShortVideoMeta,
        isShortVideo.isAcceptableOrUnknown(
          data['is_short_video']!,
          _isShortVideoMeta,
        ),
      );
    }
    if (data.containsKey('tracked')) {
      context.handle(
        _trackedMeta,
        tracked.isAcceptableOrUnknown(data['tracked']!, _trackedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {package};
  @override
  App map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return App(
      package: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      isShortVideo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_short_video'],
      )!,
      tracked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}tracked'],
      )!,
    );
  }

  @override
  $AppsTable createAlias(String alias) {
    return $AppsTable(attachedDatabase, alias);
  }
}

class App extends DataClass implements Insertable<App> {
  final String package;
  final String label;
  final String platform;
  final String category;
  final bool isShortVideo;
  final bool tracked;
  const App({
    required this.package,
    required this.label,
    required this.platform,
    required this.category,
    required this.isShortVideo,
    required this.tracked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['package'] = Variable<String>(package);
    map['label'] = Variable<String>(label);
    map['platform'] = Variable<String>(platform);
    map['category'] = Variable<String>(category);
    map['is_short_video'] = Variable<bool>(isShortVideo);
    map['tracked'] = Variable<bool>(tracked);
    return map;
  }

  AppsCompanion toCompanion(bool nullToAbsent) {
    return AppsCompanion(
      package: Value(package),
      label: Value(label),
      platform: Value(platform),
      category: Value(category),
      isShortVideo: Value(isShortVideo),
      tracked: Value(tracked),
    );
  }

  factory App.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return App(
      package: serializer.fromJson<String>(json['package']),
      label: serializer.fromJson<String>(json['label']),
      platform: serializer.fromJson<String>(json['platform']),
      category: serializer.fromJson<String>(json['category']),
      isShortVideo: serializer.fromJson<bool>(json['isShortVideo']),
      tracked: serializer.fromJson<bool>(json['tracked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'package': serializer.toJson<String>(package),
      'label': serializer.toJson<String>(label),
      'platform': serializer.toJson<String>(platform),
      'category': serializer.toJson<String>(category),
      'isShortVideo': serializer.toJson<bool>(isShortVideo),
      'tracked': serializer.toJson<bool>(tracked),
    };
  }

  App copyWith({
    String? package,
    String? label,
    String? platform,
    String? category,
    bool? isShortVideo,
    bool? tracked,
  }) => App(
    package: package ?? this.package,
    label: label ?? this.label,
    platform: platform ?? this.platform,
    category: category ?? this.category,
    isShortVideo: isShortVideo ?? this.isShortVideo,
    tracked: tracked ?? this.tracked,
  );
  App copyWithCompanion(AppsCompanion data) {
    return App(
      package: data.package.present ? data.package.value : this.package,
      label: data.label.present ? data.label.value : this.label,
      platform: data.platform.present ? data.platform.value : this.platform,
      category: data.category.present ? data.category.value : this.category,
      isShortVideo: data.isShortVideo.present
          ? data.isShortVideo.value
          : this.isShortVideo,
      tracked: data.tracked.present ? data.tracked.value : this.tracked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('App(')
          ..write('package: $package, ')
          ..write('label: $label, ')
          ..write('platform: $platform, ')
          ..write('category: $category, ')
          ..write('isShortVideo: $isShortVideo, ')
          ..write('tracked: $tracked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(package, label, platform, category, isShortVideo, tracked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is App &&
          other.package == this.package &&
          other.label == this.label &&
          other.platform == this.platform &&
          other.category == this.category &&
          other.isShortVideo == this.isShortVideo &&
          other.tracked == this.tracked);
}

class AppsCompanion extends UpdateCompanion<App> {
  final Value<String> package;
  final Value<String> label;
  final Value<String> platform;
  final Value<String> category;
  final Value<bool> isShortVideo;
  final Value<bool> tracked;
  final Value<int> rowid;
  const AppsCompanion({
    this.package = const Value.absent(),
    this.label = const Value.absent(),
    this.platform = const Value.absent(),
    this.category = const Value.absent(),
    this.isShortVideo = const Value.absent(),
    this.tracked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppsCompanion.insert({
    required String package,
    required String label,
    required String platform,
    required String category,
    this.isShortVideo = const Value.absent(),
    this.tracked = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : package = Value(package),
       label = Value(label),
       platform = Value(platform),
       category = Value(category);
  static Insertable<App> custom({
    Expression<String>? package,
    Expression<String>? label,
    Expression<String>? platform,
    Expression<String>? category,
    Expression<bool>? isShortVideo,
    Expression<bool>? tracked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (package != null) 'package': package,
      if (label != null) 'label': label,
      if (platform != null) 'platform': platform,
      if (category != null) 'category': category,
      if (isShortVideo != null) 'is_short_video': isShortVideo,
      if (tracked != null) 'tracked': tracked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppsCompanion copyWith({
    Value<String>? package,
    Value<String>? label,
    Value<String>? platform,
    Value<String>? category,
    Value<bool>? isShortVideo,
    Value<bool>? tracked,
    Value<int>? rowid,
  }) {
    return AppsCompanion(
      package: package ?? this.package,
      label: label ?? this.label,
      platform: platform ?? this.platform,
      category: category ?? this.category,
      isShortVideo: isShortVideo ?? this.isShortVideo,
      tracked: tracked ?? this.tracked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (package.present) {
      map['package'] = Variable<String>(package.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isShortVideo.present) {
      map['is_short_video'] = Variable<bool>(isShortVideo.value);
    }
    if (tracked.present) {
      map['tracked'] = Variable<bool>(tracked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppsCompanion(')
          ..write('package: $package, ')
          ..write('label: $label, ')
          ..write('platform: $platform, ')
          ..write('category: $category, ')
          ..write('isShortVideo: $isShortVideo, ')
          ..write('tracked: $tracked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _packageMeta = const VerificationMeta(
    'package',
  );
  @override
  late final GeneratedColumn<String> package = GeneratedColumn<String>(
    'package',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES apps (package)',
    ),
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
  static const VerificationMeta _startMsMeta = const VerificationMeta(
    'startMs',
  );
  @override
  late final GeneratedColumn<int> startMs = GeneratedColumn<int>(
    'start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMsMeta = const VerificationMeta('endMs');
  @override
  late final GeneratedColumn<int> endMs = GeneratedColumn<int>(
    'end_ms',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    package,
    deviceId,
    startMs,
    endMs,
    day,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package')) {
      context.handle(
        _packageMeta,
        package.isAcceptableOrUnknown(data['package']!, _packageMeta),
      );
    } else if (isInserting) {
      context.missing(_packageMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('start_ms')) {
      context.handle(
        _startMsMeta,
        startMs.isAcceptableOrUnknown(data['start_ms']!, _startMsMeta),
      );
    } else if (isInserting) {
      context.missing(_startMsMeta);
    }
    if (data.containsKey('end_ms')) {
      context.handle(
        _endMsMeta,
        endMs.isAcceptableOrUnknown(data['end_ms']!, _endMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endMsMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      package: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      startMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ms'],
      )!,
      endMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_ms'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final String package;
  final String deviceId;
  final int startMs;
  final int endMs;
  final String day;
  const Session({
    required this.id,
    required this.package,
    required this.deviceId,
    required this.startMs,
    required this.endMs,
    required this.day,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package'] = Variable<String>(package);
    map['device_id'] = Variable<String>(deviceId);
    map['start_ms'] = Variable<int>(startMs);
    map['end_ms'] = Variable<int>(endMs);
    map['day'] = Variable<String>(day);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      package: Value(package),
      deviceId: Value(deviceId),
      startMs: Value(startMs),
      endMs: Value(endMs),
      day: Value(day),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      package: serializer.fromJson<String>(json['package']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      startMs: serializer.fromJson<int>(json['startMs']),
      endMs: serializer.fromJson<int>(json['endMs']),
      day: serializer.fromJson<String>(json['day']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'package': serializer.toJson<String>(package),
      'deviceId': serializer.toJson<String>(deviceId),
      'startMs': serializer.toJson<int>(startMs),
      'endMs': serializer.toJson<int>(endMs),
      'day': serializer.toJson<String>(day),
    };
  }

  Session copyWith({
    int? id,
    String? package,
    String? deviceId,
    int? startMs,
    int? endMs,
    String? day,
  }) => Session(
    id: id ?? this.id,
    package: package ?? this.package,
    deviceId: deviceId ?? this.deviceId,
    startMs: startMs ?? this.startMs,
    endMs: endMs ?? this.endMs,
    day: day ?? this.day,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      package: data.package.present ? data.package.value : this.package,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      startMs: data.startMs.present ? data.startMs.value : this.startMs,
      endMs: data.endMs.present ? data.endMs.value : this.endMs,
      day: data.day.present ? data.day.value : this.day,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('package: $package, ')
          ..write('deviceId: $deviceId, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, package, deviceId, startMs, endMs, day);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.package == this.package &&
          other.deviceId == this.deviceId &&
          other.startMs == this.startMs &&
          other.endMs == this.endMs &&
          other.day == this.day);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<String> package;
  final Value<String> deviceId;
  final Value<int> startMs;
  final Value<int> endMs;
  final Value<String> day;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.package = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.startMs = const Value.absent(),
    this.endMs = const Value.absent(),
    this.day = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required String package,
    required String deviceId,
    required int startMs,
    required int endMs,
    required String day,
  }) : package = Value(package),
       deviceId = Value(deviceId),
       startMs = Value(startMs),
       endMs = Value(endMs),
       day = Value(day);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<String>? package,
    Expression<String>? deviceId,
    Expression<int>? startMs,
    Expression<int>? endMs,
    Expression<String>? day,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (package != null) 'package': package,
      if (deviceId != null) 'device_id': deviceId,
      if (startMs != null) 'start_ms': startMs,
      if (endMs != null) 'end_ms': endMs,
      if (day != null) 'day': day,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? package,
    Value<String>? deviceId,
    Value<int>? startMs,
    Value<int>? endMs,
    Value<String>? day,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      package: package ?? this.package,
      deviceId: deviceId ?? this.deviceId,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      day: day ?? this.day,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (package.present) {
      map['package'] = Variable<String>(package.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (startMs.present) {
      map['start_ms'] = Variable<int>(startMs.value);
    }
    if (endMs.present) {
      map['end_ms'] = Variable<int>(endMs.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('package: $package, ')
          ..write('deviceId: $deviceId, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }
}

class $ReelEventsTable extends ReelEvents
    with TableInfo<$ReelEventsTable, ReelEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReelEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _packageMeta = const VerificationMeta(
    'package',
  );
  @override
  late final GeneratedColumn<String> package = GeneratedColumn<String>(
    'package',
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
  static const VerificationMeta _atMsMeta = const VerificationMeta('atMs');
  @override
  late final GeneratedColumn<int> atMs = GeneratedColumn<int>(
    'at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dwellMsMeta = const VerificationMeta(
    'dwellMs',
  );
  @override
  late final GeneratedColumn<int> dwellMs = GeneratedColumn<int>(
    'dwell_ms',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    package,
    deviceId,
    atMs,
    dwellMs,
    day,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reel_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReelEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package')) {
      context.handle(
        _packageMeta,
        package.isAcceptableOrUnknown(data['package']!, _packageMeta),
      );
    } else if (isInserting) {
      context.missing(_packageMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('at_ms')) {
      context.handle(
        _atMsMeta,
        atMs.isAcceptableOrUnknown(data['at_ms']!, _atMsMeta),
      );
    } else if (isInserting) {
      context.missing(_atMsMeta);
    }
    if (data.containsKey('dwell_ms')) {
      context.handle(
        _dwellMsMeta,
        dwellMs.isAcceptableOrUnknown(data['dwell_ms']!, _dwellMsMeta),
      );
    } else if (isInserting) {
      context.missing(_dwellMsMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReelEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReelEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      package: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      atMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at_ms'],
      )!,
      dwellMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dwell_ms'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
    );
  }

  @override
  $ReelEventsTable createAlias(String alias) {
    return $ReelEventsTable(attachedDatabase, alias);
  }
}

class ReelEvent extends DataClass implements Insertable<ReelEvent> {
  final int id;
  final String package;
  final String deviceId;
  final int atMs;
  final int dwellMs;
  final String day;
  const ReelEvent({
    required this.id,
    required this.package,
    required this.deviceId,
    required this.atMs,
    required this.dwellMs,
    required this.day,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package'] = Variable<String>(package);
    map['device_id'] = Variable<String>(deviceId);
    map['at_ms'] = Variable<int>(atMs);
    map['dwell_ms'] = Variable<int>(dwellMs);
    map['day'] = Variable<String>(day);
    return map;
  }

  ReelEventsCompanion toCompanion(bool nullToAbsent) {
    return ReelEventsCompanion(
      id: Value(id),
      package: Value(package),
      deviceId: Value(deviceId),
      atMs: Value(atMs),
      dwellMs: Value(dwellMs),
      day: Value(day),
    );
  }

  factory ReelEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReelEvent(
      id: serializer.fromJson<int>(json['id']),
      package: serializer.fromJson<String>(json['package']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      atMs: serializer.fromJson<int>(json['atMs']),
      dwellMs: serializer.fromJson<int>(json['dwellMs']),
      day: serializer.fromJson<String>(json['day']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'package': serializer.toJson<String>(package),
      'deviceId': serializer.toJson<String>(deviceId),
      'atMs': serializer.toJson<int>(atMs),
      'dwellMs': serializer.toJson<int>(dwellMs),
      'day': serializer.toJson<String>(day),
    };
  }

  ReelEvent copyWith({
    int? id,
    String? package,
    String? deviceId,
    int? atMs,
    int? dwellMs,
    String? day,
  }) => ReelEvent(
    id: id ?? this.id,
    package: package ?? this.package,
    deviceId: deviceId ?? this.deviceId,
    atMs: atMs ?? this.atMs,
    dwellMs: dwellMs ?? this.dwellMs,
    day: day ?? this.day,
  );
  ReelEvent copyWithCompanion(ReelEventsCompanion data) {
    return ReelEvent(
      id: data.id.present ? data.id.value : this.id,
      package: data.package.present ? data.package.value : this.package,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      atMs: data.atMs.present ? data.atMs.value : this.atMs,
      dwellMs: data.dwellMs.present ? data.dwellMs.value : this.dwellMs,
      day: data.day.present ? data.day.value : this.day,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReelEvent(')
          ..write('id: $id, ')
          ..write('package: $package, ')
          ..write('deviceId: $deviceId, ')
          ..write('atMs: $atMs, ')
          ..write('dwellMs: $dwellMs, ')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, package, deviceId, atMs, dwellMs, day);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReelEvent &&
          other.id == this.id &&
          other.package == this.package &&
          other.deviceId == this.deviceId &&
          other.atMs == this.atMs &&
          other.dwellMs == this.dwellMs &&
          other.day == this.day);
}

class ReelEventsCompanion extends UpdateCompanion<ReelEvent> {
  final Value<int> id;
  final Value<String> package;
  final Value<String> deviceId;
  final Value<int> atMs;
  final Value<int> dwellMs;
  final Value<String> day;
  const ReelEventsCompanion({
    this.id = const Value.absent(),
    this.package = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.atMs = const Value.absent(),
    this.dwellMs = const Value.absent(),
    this.day = const Value.absent(),
  });
  ReelEventsCompanion.insert({
    this.id = const Value.absent(),
    required String package,
    required String deviceId,
    required int atMs,
    required int dwellMs,
    required String day,
  }) : package = Value(package),
       deviceId = Value(deviceId),
       atMs = Value(atMs),
       dwellMs = Value(dwellMs),
       day = Value(day);
  static Insertable<ReelEvent> custom({
    Expression<int>? id,
    Expression<String>? package,
    Expression<String>? deviceId,
    Expression<int>? atMs,
    Expression<int>? dwellMs,
    Expression<String>? day,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (package != null) 'package': package,
      if (deviceId != null) 'device_id': deviceId,
      if (atMs != null) 'at_ms': atMs,
      if (dwellMs != null) 'dwell_ms': dwellMs,
      if (day != null) 'day': day,
    });
  }

  ReelEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? package,
    Value<String>? deviceId,
    Value<int>? atMs,
    Value<int>? dwellMs,
    Value<String>? day,
  }) {
    return ReelEventsCompanion(
      id: id ?? this.id,
      package: package ?? this.package,
      deviceId: deviceId ?? this.deviceId,
      atMs: atMs ?? this.atMs,
      dwellMs: dwellMs ?? this.dwellMs,
      day: day ?? this.day,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (package.present) {
      map['package'] = Variable<String>(package.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (atMs.present) {
      map['at_ms'] = Variable<int>(atMs.value);
    }
    if (dwellMs.present) {
      map['dwell_ms'] = Variable<int>(dwellMs.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReelEventsCompanion(')
          ..write('id: $id, ')
          ..write('package: $package, ')
          ..write('deviceId: $deviceId, ')
          ..write('atMs: $atMs, ')
          ..write('dwellMs: $dwellMs, ')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }
}

class $DailyTotalsTable extends DailyTotals
    with TableInfo<$DailyTotalsTable, DailyTotal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyTotalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageMeta = const VerificationMeta(
    'package',
  );
  @override
  late final GeneratedColumn<String> package = GeneratedColumn<String>(
    'package',
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
  static const VerificationMeta _foregroundMsMeta = const VerificationMeta(
    'foregroundMs',
  );
  @override
  late final GeneratedColumn<int> foregroundMs = GeneratedColumn<int>(
    'foreground_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _opensMeta = const VerificationMeta('opens');
  @override
  late final GeneratedColumn<int> opens = GeneratedColumn<int>(
    'opens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reelsMeta = const VerificationMeta('reels');
  @override
  late final GeneratedColumn<int> reels = GeneratedColumn<int>(
    'reels',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    day,
    package,
    deviceId,
    foregroundMs,
    opens,
    reels,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_totals';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyTotal> instance, {
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
    if (data.containsKey('package')) {
      context.handle(
        _packageMeta,
        package.isAcceptableOrUnknown(data['package']!, _packageMeta),
      );
    } else if (isInserting) {
      context.missing(_packageMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('foreground_ms')) {
      context.handle(
        _foregroundMsMeta,
        foregroundMs.isAcceptableOrUnknown(
          data['foreground_ms']!,
          _foregroundMsMeta,
        ),
      );
    }
    if (data.containsKey('opens')) {
      context.handle(
        _opensMeta,
        opens.isAcceptableOrUnknown(data['opens']!, _opensMeta),
      );
    }
    if (data.containsKey('reels')) {
      context.handle(
        _reelsMeta,
        reels.isAcceptableOrUnknown(data['reels']!, _reelsMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day, package, deviceId};
  @override
  DailyTotal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyTotal(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      package: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      foregroundMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}foreground_ms'],
      )!,
      opens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opens'],
      )!,
      reels: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reels'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $DailyTotalsTable createAlias(String alias) {
    return $DailyTotalsTable(attachedDatabase, alias);
  }
}

class DailyTotal extends DataClass implements Insertable<DailyTotal> {
  final String day;
  final String package;
  final String deviceId;
  final int foregroundMs;
  final int opens;
  final int reels;
  final int? syncedAt;
  const DailyTotal({
    required this.day,
    required this.package,
    required this.deviceId,
    required this.foregroundMs,
    required this.opens,
    required this.reels,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['package'] = Variable<String>(package);
    map['device_id'] = Variable<String>(deviceId);
    map['foreground_ms'] = Variable<int>(foregroundMs);
    map['opens'] = Variable<int>(opens);
    map['reels'] = Variable<int>(reels);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    return map;
  }

  DailyTotalsCompanion toCompanion(bool nullToAbsent) {
    return DailyTotalsCompanion(
      day: Value(day),
      package: Value(package),
      deviceId: Value(deviceId),
      foregroundMs: Value(foregroundMs),
      opens: Value(opens),
      reels: Value(reels),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory DailyTotal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyTotal(
      day: serializer.fromJson<String>(json['day']),
      package: serializer.fromJson<String>(json['package']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      foregroundMs: serializer.fromJson<int>(json['foregroundMs']),
      opens: serializer.fromJson<int>(json['opens']),
      reels: serializer.fromJson<int>(json['reels']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'package': serializer.toJson<String>(package),
      'deviceId': serializer.toJson<String>(deviceId),
      'foregroundMs': serializer.toJson<int>(foregroundMs),
      'opens': serializer.toJson<int>(opens),
      'reels': serializer.toJson<int>(reels),
      'syncedAt': serializer.toJson<int?>(syncedAt),
    };
  }

  DailyTotal copyWith({
    String? day,
    String? package,
    String? deviceId,
    int? foregroundMs,
    int? opens,
    int? reels,
    Value<int?> syncedAt = const Value.absent(),
  }) => DailyTotal(
    day: day ?? this.day,
    package: package ?? this.package,
    deviceId: deviceId ?? this.deviceId,
    foregroundMs: foregroundMs ?? this.foregroundMs,
    opens: opens ?? this.opens,
    reels: reels ?? this.reels,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  DailyTotal copyWithCompanion(DailyTotalsCompanion data) {
    return DailyTotal(
      day: data.day.present ? data.day.value : this.day,
      package: data.package.present ? data.package.value : this.package,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      foregroundMs: data.foregroundMs.present
          ? data.foregroundMs.value
          : this.foregroundMs,
      opens: data.opens.present ? data.opens.value : this.opens,
      reels: data.reels.present ? data.reels.value : this.reels,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyTotal(')
          ..write('day: $day, ')
          ..write('package: $package, ')
          ..write('deviceId: $deviceId, ')
          ..write('foregroundMs: $foregroundMs, ')
          ..write('opens: $opens, ')
          ..write('reels: $reels, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(day, package, deviceId, foregroundMs, opens, reels, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyTotal &&
          other.day == this.day &&
          other.package == this.package &&
          other.deviceId == this.deviceId &&
          other.foregroundMs == this.foregroundMs &&
          other.opens == this.opens &&
          other.reels == this.reels &&
          other.syncedAt == this.syncedAt);
}

class DailyTotalsCompanion extends UpdateCompanion<DailyTotal> {
  final Value<String> day;
  final Value<String> package;
  final Value<String> deviceId;
  final Value<int> foregroundMs;
  final Value<int> opens;
  final Value<int> reels;
  final Value<int?> syncedAt;
  final Value<int> rowid;
  const DailyTotalsCompanion({
    this.day = const Value.absent(),
    this.package = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.foregroundMs = const Value.absent(),
    this.opens = const Value.absent(),
    this.reels = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyTotalsCompanion.insert({
    required String day,
    required String package,
    required String deviceId,
    this.foregroundMs = const Value.absent(),
    this.opens = const Value.absent(),
    this.reels = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       package = Value(package),
       deviceId = Value(deviceId);
  static Insertable<DailyTotal> custom({
    Expression<String>? day,
    Expression<String>? package,
    Expression<String>? deviceId,
    Expression<int>? foregroundMs,
    Expression<int>? opens,
    Expression<int>? reels,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (package != null) 'package': package,
      if (deviceId != null) 'device_id': deviceId,
      if (foregroundMs != null) 'foreground_ms': foregroundMs,
      if (opens != null) 'opens': opens,
      if (reels != null) 'reels': reels,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyTotalsCompanion copyWith({
    Value<String>? day,
    Value<String>? package,
    Value<String>? deviceId,
    Value<int>? foregroundMs,
    Value<int>? opens,
    Value<int>? reels,
    Value<int?>? syncedAt,
    Value<int>? rowid,
  }) {
    return DailyTotalsCompanion(
      day: day ?? this.day,
      package: package ?? this.package,
      deviceId: deviceId ?? this.deviceId,
      foregroundMs: foregroundMs ?? this.foregroundMs,
      opens: opens ?? this.opens,
      reels: reels ?? this.reels,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (package.present) {
      map['package'] = Variable<String>(package.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (foregroundMs.present) {
      map['foreground_ms'] = Variable<int>(foregroundMs.value);
    }
    if (opens.present) {
      map['opens'] = Variable<int>(opens.value);
    }
    if (reels.present) {
      map['reels'] = Variable<int>(reels.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyTotalsCompanion(')
          ..write('day: $day, ')
          ..write('package: $package, ')
          ..write('deviceId: $deviceId, ')
          ..write('foregroundMs: $foregroundMs, ')
          ..write('opens: $opens, ')
          ..write('reels: $reels, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LimitsTable extends Limits with TableInfo<$LimitsTable, AppLimit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LimitsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageMeta = const VerificationMeta(
    'package',
  );
  @override
  late final GeneratedColumn<String> package = GeneratedColumn<String>(
    'package',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyLimitMsMeta = const VerificationMeta(
    'dailyLimitMs',
  );
  @override
  late final GeneratedColumn<int> dailyLimitMs = GeneratedColumn<int>(
    'daily_limit_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyLimitReelsMeta = const VerificationMeta(
    'dailyLimitReels',
  );
  @override
  late final GeneratedColumn<int> dailyLimitReels = GeneratedColumn<int>(
    'daily_limit_reels',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remindMeta = const VerificationMeta('remind');
  @override
  late final GeneratedColumn<bool> remind = GeneratedColumn<bool>(
    'remind',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("remind" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _snoozeUntilMsMeta = const VerificationMeta(
    'snoozeUntilMs',
  );
  @override
  late final GeneratedColumn<int> snoozeUntilMs = GeneratedColumn<int>(
    'snooze_until_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scope,
    package,
    dailyLimitMs,
    dailyLimitReels,
    remind,
    snoozeUntilMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'limits';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppLimit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('package')) {
      context.handle(
        _packageMeta,
        package.isAcceptableOrUnknown(data['package']!, _packageMeta),
      );
    }
    if (data.containsKey('daily_limit_ms')) {
      context.handle(
        _dailyLimitMsMeta,
        dailyLimitMs.isAcceptableOrUnknown(
          data['daily_limit_ms']!,
          _dailyLimitMsMeta,
        ),
      );
    }
    if (data.containsKey('daily_limit_reels')) {
      context.handle(
        _dailyLimitReelsMeta,
        dailyLimitReels.isAcceptableOrUnknown(
          data['daily_limit_reels']!,
          _dailyLimitReelsMeta,
        ),
      );
    }
    if (data.containsKey('remind')) {
      context.handle(
        _remindMeta,
        remind.isAcceptableOrUnknown(data['remind']!, _remindMeta),
      );
    }
    if (data.containsKey('snooze_until_ms')) {
      context.handle(
        _snoozeUntilMsMeta,
        snoozeUntilMs.isAcceptableOrUnknown(
          data['snooze_until_ms']!,
          _snoozeUntilMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppLimit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppLimit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      package: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package'],
      ),
      dailyLimitMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_limit_ms'],
      ),
      dailyLimitReels: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_limit_reels'],
      ),
      remind: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}remind'],
      )!,
      snoozeUntilMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snooze_until_ms'],
      ),
    );
  }

  @override
  $LimitsTable createAlias(String alias) {
    return $LimitsTable(attachedDatabase, alias);
  }
}

class AppLimit extends DataClass implements Insertable<AppLimit> {
  final int id;
  final String scope;
  final String? package;
  final int? dailyLimitMs;
  final int? dailyLimitReels;
  final bool remind;
  final int? snoozeUntilMs;
  const AppLimit({
    required this.id,
    required this.scope,
    this.package,
    this.dailyLimitMs,
    this.dailyLimitReels,
    required this.remind,
    this.snoozeUntilMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scope'] = Variable<String>(scope);
    if (!nullToAbsent || package != null) {
      map['package'] = Variable<String>(package);
    }
    if (!nullToAbsent || dailyLimitMs != null) {
      map['daily_limit_ms'] = Variable<int>(dailyLimitMs);
    }
    if (!nullToAbsent || dailyLimitReels != null) {
      map['daily_limit_reels'] = Variable<int>(dailyLimitReels);
    }
    map['remind'] = Variable<bool>(remind);
    if (!nullToAbsent || snoozeUntilMs != null) {
      map['snooze_until_ms'] = Variable<int>(snoozeUntilMs);
    }
    return map;
  }

  LimitsCompanion toCompanion(bool nullToAbsent) {
    return LimitsCompanion(
      id: Value(id),
      scope: Value(scope),
      package: package == null && nullToAbsent
          ? const Value.absent()
          : Value(package),
      dailyLimitMs: dailyLimitMs == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyLimitMs),
      dailyLimitReels: dailyLimitReels == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyLimitReels),
      remind: Value(remind),
      snoozeUntilMs: snoozeUntilMs == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozeUntilMs),
    );
  }

  factory AppLimit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppLimit(
      id: serializer.fromJson<int>(json['id']),
      scope: serializer.fromJson<String>(json['scope']),
      package: serializer.fromJson<String?>(json['package']),
      dailyLimitMs: serializer.fromJson<int?>(json['dailyLimitMs']),
      dailyLimitReels: serializer.fromJson<int?>(json['dailyLimitReels']),
      remind: serializer.fromJson<bool>(json['remind']),
      snoozeUntilMs: serializer.fromJson<int?>(json['snoozeUntilMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scope': serializer.toJson<String>(scope),
      'package': serializer.toJson<String?>(package),
      'dailyLimitMs': serializer.toJson<int?>(dailyLimitMs),
      'dailyLimitReels': serializer.toJson<int?>(dailyLimitReels),
      'remind': serializer.toJson<bool>(remind),
      'snoozeUntilMs': serializer.toJson<int?>(snoozeUntilMs),
    };
  }

  AppLimit copyWith({
    int? id,
    String? scope,
    Value<String?> package = const Value.absent(),
    Value<int?> dailyLimitMs = const Value.absent(),
    Value<int?> dailyLimitReels = const Value.absent(),
    bool? remind,
    Value<int?> snoozeUntilMs = const Value.absent(),
  }) => AppLimit(
    id: id ?? this.id,
    scope: scope ?? this.scope,
    package: package.present ? package.value : this.package,
    dailyLimitMs: dailyLimitMs.present ? dailyLimitMs.value : this.dailyLimitMs,
    dailyLimitReels: dailyLimitReels.present
        ? dailyLimitReels.value
        : this.dailyLimitReels,
    remind: remind ?? this.remind,
    snoozeUntilMs: snoozeUntilMs.present
        ? snoozeUntilMs.value
        : this.snoozeUntilMs,
  );
  AppLimit copyWithCompanion(LimitsCompanion data) {
    return AppLimit(
      id: data.id.present ? data.id.value : this.id,
      scope: data.scope.present ? data.scope.value : this.scope,
      package: data.package.present ? data.package.value : this.package,
      dailyLimitMs: data.dailyLimitMs.present
          ? data.dailyLimitMs.value
          : this.dailyLimitMs,
      dailyLimitReels: data.dailyLimitReels.present
          ? data.dailyLimitReels.value
          : this.dailyLimitReels,
      remind: data.remind.present ? data.remind.value : this.remind,
      snoozeUntilMs: data.snoozeUntilMs.present
          ? data.snoozeUntilMs.value
          : this.snoozeUntilMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppLimit(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('package: $package, ')
          ..write('dailyLimitMs: $dailyLimitMs, ')
          ..write('dailyLimitReels: $dailyLimitReels, ')
          ..write('remind: $remind, ')
          ..write('snoozeUntilMs: $snoozeUntilMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scope,
    package,
    dailyLimitMs,
    dailyLimitReels,
    remind,
    snoozeUntilMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppLimit &&
          other.id == this.id &&
          other.scope == this.scope &&
          other.package == this.package &&
          other.dailyLimitMs == this.dailyLimitMs &&
          other.dailyLimitReels == this.dailyLimitReels &&
          other.remind == this.remind &&
          other.snoozeUntilMs == this.snoozeUntilMs);
}

class LimitsCompanion extends UpdateCompanion<AppLimit> {
  final Value<int> id;
  final Value<String> scope;
  final Value<String?> package;
  final Value<int?> dailyLimitMs;
  final Value<int?> dailyLimitReels;
  final Value<bool> remind;
  final Value<int?> snoozeUntilMs;
  const LimitsCompanion({
    this.id = const Value.absent(),
    this.scope = const Value.absent(),
    this.package = const Value.absent(),
    this.dailyLimitMs = const Value.absent(),
    this.dailyLimitReels = const Value.absent(),
    this.remind = const Value.absent(),
    this.snoozeUntilMs = const Value.absent(),
  });
  LimitsCompanion.insert({
    this.id = const Value.absent(),
    required String scope,
    this.package = const Value.absent(),
    this.dailyLimitMs = const Value.absent(),
    this.dailyLimitReels = const Value.absent(),
    this.remind = const Value.absent(),
    this.snoozeUntilMs = const Value.absent(),
  }) : scope = Value(scope);
  static Insertable<AppLimit> custom({
    Expression<int>? id,
    Expression<String>? scope,
    Expression<String>? package,
    Expression<int>? dailyLimitMs,
    Expression<int>? dailyLimitReels,
    Expression<bool>? remind,
    Expression<int>? snoozeUntilMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scope != null) 'scope': scope,
      if (package != null) 'package': package,
      if (dailyLimitMs != null) 'daily_limit_ms': dailyLimitMs,
      if (dailyLimitReels != null) 'daily_limit_reels': dailyLimitReels,
      if (remind != null) 'remind': remind,
      if (snoozeUntilMs != null) 'snooze_until_ms': snoozeUntilMs,
    });
  }

  LimitsCompanion copyWith({
    Value<int>? id,
    Value<String>? scope,
    Value<String?>? package,
    Value<int?>? dailyLimitMs,
    Value<int?>? dailyLimitReels,
    Value<bool>? remind,
    Value<int?>? snoozeUntilMs,
  }) {
    return LimitsCompanion(
      id: id ?? this.id,
      scope: scope ?? this.scope,
      package: package ?? this.package,
      dailyLimitMs: dailyLimitMs ?? this.dailyLimitMs,
      dailyLimitReels: dailyLimitReels ?? this.dailyLimitReels,
      remind: remind ?? this.remind,
      snoozeUntilMs: snoozeUntilMs ?? this.snoozeUntilMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (package.present) {
      map['package'] = Variable<String>(package.value);
    }
    if (dailyLimitMs.present) {
      map['daily_limit_ms'] = Variable<int>(dailyLimitMs.value);
    }
    if (dailyLimitReels.present) {
      map['daily_limit_reels'] = Variable<int>(dailyLimitReels.value);
    }
    if (remind.present) {
      map['remind'] = Variable<bool>(remind.value);
    }
    if (snoozeUntilMs.present) {
      map['snooze_until_ms'] = Variable<int>(snoozeUntilMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LimitsCompanion(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('package: $package, ')
          ..write('dailyLimitMs: $dailyLimitMs, ')
          ..write('dailyLimitReels: $dailyLimitReels, ')
          ..write('remind: $remind, ')
          ..write('snoozeUntilMs: $snoozeUntilMs')
          ..write(')'))
        .toString();
  }
}

class $SettingsEntriesTable extends SettingsEntries
    with TableInfo<$SettingsEntriesTable, SettingsEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingsEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsEntriesTable createAlias(String alias) {
    return $SettingsEntriesTable(attachedDatabase, alias);
  }
}

class SettingsEntry extends DataClass implements Insertable<SettingsEntry> {
  final String key;
  final String value;
  const SettingsEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return SettingsEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory SettingsEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingsEntry copyWith({String? key, String? value}) =>
      SettingsEntry(key: key ?? this.key, value: value ?? this.value);
  SettingsEntry copyWithCompanion(SettingsEntriesCompanion data) {
    return SettingsEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsEntriesCompanion extends UpdateCompanion<SettingsEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingsEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppsTable apps = $AppsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $ReelEventsTable reelEvents = $ReelEventsTable(this);
  late final $DailyTotalsTable dailyTotals = $DailyTotalsTable(this);
  late final $LimitsTable limits = $LimitsTable(this);
  late final $SettingsEntriesTable settingsEntries = $SettingsEntriesTable(
    this,
  );
  late final UsageDao usageDao = UsageDao(this as AppDatabase);
  late final ReelDao reelDao = ReelDao(this as AppDatabase);
  late final LimitDao limitDao = LimitDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    apps,
    sessions,
    reelEvents,
    dailyTotals,
    limits,
    settingsEntries,
  ];
}

typedef $$AppsTableCreateCompanionBuilder = AppsCompanion Function({
  required String package,
  required String label,
  required String platform,
  required String category,
  Value<bool> isShortVideo,
  Value<bool> tracked,
  Value<int> rowid,
});
typedef $$AppsTableUpdateCompanionBuilder = AppsCompanion Function({
  Value<String> package,
  Value<String> label,
  Value<String> platform,
  Value<String> category,
  Value<bool> isShortVideo,
  Value<bool> tracked,
  Value<int> rowid,
});

final class $$AppsTableReferences
    extends BaseReferences<_$AppDatabase, $AppsTable, App> {
  $$AppsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: 'apps__package__sessions__package',
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager($_db, $_db.sessions).filter(
      (f) => f.package.package.sqlEquals($_itemColumn<String>('package')!),
    );

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AppsTableFilterComposer extends Composer<_$AppDatabase, $AppsTable> {
  $$AppsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get package => $composableBuilder(
    column: $table.package,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isShortVideo => $composableBuilder(
    column: $table.isShortVideo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get tracked => $composableBuilder(
    column: $table.tracked,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.package,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.package,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AppsTableOrderingComposer extends Composer<_$AppDatabase, $AppsTable> {
  $$AppsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get package => $composableBuilder(
    column: $table.package,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isShortVideo => $composableBuilder(
    column: $table.isShortVideo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get tracked => $composableBuilder(
    column: $table.tracked,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppsTable> {
  $$AppsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get package =>
      $composableBuilder(column: $table.package, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isShortVideo => $composableBuilder(
    column: $table.isShortVideo,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get tracked =>
      $composableBuilder(column: $table.tracked, builder: (column) => column);

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.package,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.package,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AppsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppsTable,
          App,
          $$AppsTableFilterComposer,
          $$AppsTableOrderingComposer,
          $$AppsTableAnnotationComposer,
          $$AppsTableCreateCompanionBuilder,
          $$AppsTableUpdateCompanionBuilder,
          (App, $$AppsTableReferences),
          App,
          PrefetchHooks Function({bool sessionsRefs})
        > {
  $$AppsTableTableManager(_$AppDatabase db, $AppsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> package = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> isShortVideo = const Value.absent(),
                Value<bool> tracked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppsCompanion(
                package: package,
                label: label,
                platform: platform,
                category: category,
                isShortVideo: isShortVideo,
                tracked: tracked,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String package,
                required String label,
                required String platform,
                required String category,
                Value<bool> isShortVideo = const Value.absent(),
                Value<bool> tracked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppsCompanion.insert(
                package: package,
                label: label,
                platform: platform,
                category: category,
                isShortVideo: isShortVideo,
                tracked: tracked,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppsTable, App>(table),
                  $$AppsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sessionsRefs) db.sessions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionsRefs)
                    await $_getPrefetchedDataByColumns<
                      App,
                      $AppsTable,
                      Session,
                      $SessionsTable
                    >(
                      currentTable: table,
                      referencedTable: $$AppsTableReferences._sessionsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$AppsTableReferences(db, table, p0).sessionsRefs,
                      currentColumn: 'package',
                      referencedColumn: 'package',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AppsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppsTable,
      App,
      $$AppsTableFilterComposer,
      $$AppsTableOrderingComposer,
      $$AppsTableAnnotationComposer,
      $$AppsTableCreateCompanionBuilder,
      $$AppsTableUpdateCompanionBuilder,
      (App, $$AppsTableReferences),
      App,
      PrefetchHooks Function({bool sessionsRefs})
    >;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  required String package,
  required String deviceId,
  required int startMs,
  required int endMs,
  required String day,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<String> package,
  Value<String> deviceId,
  Value<int> startMs,
  Value<int> endMs,
  Value<String> day,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AppsTable _packageTable(_$AppDatabase db) =>
      db.apps.createAlias('sessions__package__apps__package');

  $$AppsTableProcessedTableManager get package {
    final $_column = $_itemColumn<String>('package')!;

    final manager = $$AppsTableTableManager(
      $_db,
      $_db.apps,
    ).filter((f) => f.package.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packageTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  $$AppsTableFilterComposer get package {
    final $$AppsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.package,
      referencedTable: $db.apps,
      getReferencedColumn: (t) => t.package,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppsTableFilterComposer(
            $db: $db,
            $table: $db.apps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  $$AppsTableOrderingComposer get package {
    final $$AppsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.package,
      referencedTable: $db.apps,
      getReferencedColumn: (t) => t.package,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppsTableOrderingComposer(
            $db: $db,
            $table: $db.apps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get startMs =>
      $composableBuilder(column: $table.startMs, builder: (column) => column);

  GeneratedColumn<int> get endMs =>
      $composableBuilder(column: $table.endMs, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  $$AppsTableAnnotationComposer get package {
    final $$AppsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.package,
      referencedTable: $db.apps,
      getReferencedColumn: (t) => t.package,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppsTableAnnotationComposer(
            $db: $db,
            $table: $db.apps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({bool package})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> package = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> startMs = const Value.absent(),
                Value<int> endMs = const Value.absent(),
                Value<String> day = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                package: package,
                deviceId: deviceId,
                startMs: startMs,
                endMs: endMs,
                day: day,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String package,
                required String deviceId,
                required int startMs,
                required int endMs,
                required String day,
              }) => SessionsCompanion.insert(
                id: id,
                package: package,
                deviceId: deviceId,
                startMs: startMs,
                endMs: endMs,
                day: day,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, Session>(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({package = false}) {
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
                    if (package) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.package,
                        referencedTable: $$SessionsTableReferences
                            ._packageTable(db),
                        referencedColumn: $$SessionsTableReferences
                            ._packageTable(db)
                            .package,
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

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({bool package})
    >;
typedef $$ReelEventsTableCreateCompanionBuilder = ReelEventsCompanion Function({
  Value<int> id,
  required String package,
  required String deviceId,
  required int atMs,
  required int dwellMs,
  required String day,
});
typedef $$ReelEventsTableUpdateCompanionBuilder = ReelEventsCompanion Function({
  Value<int> id,
  Value<String> package,
  Value<String> deviceId,
  Value<int> atMs,
  Value<int> dwellMs,
  Value<String> day,
});

class $$ReelEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ReelEventsTable> {
  $$ReelEventsTableFilterComposer({
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

  ColumnFilters<String> get package => $composableBuilder(
    column: $table.package,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get atMs => $composableBuilder(
    column: $table.atMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dwellMs => $composableBuilder(
    column: $table.dwellMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReelEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReelEventsTable> {
  $$ReelEventsTableOrderingComposer({
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

  ColumnOrderings<String> get package => $composableBuilder(
    column: $table.package,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get atMs => $composableBuilder(
    column: $table.atMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dwellMs => $composableBuilder(
    column: $table.dwellMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReelEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReelEventsTable> {
  $$ReelEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get package =>
      $composableBuilder(column: $table.package, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get atMs =>
      $composableBuilder(column: $table.atMs, builder: (column) => column);

  GeneratedColumn<int> get dwellMs =>
      $composableBuilder(column: $table.dwellMs, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);
}

class $$ReelEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReelEventsTable,
          ReelEvent,
          $$ReelEventsTableFilterComposer,
          $$ReelEventsTableOrderingComposer,
          $$ReelEventsTableAnnotationComposer,
          $$ReelEventsTableCreateCompanionBuilder,
          $$ReelEventsTableUpdateCompanionBuilder,
          (
            ReelEvent,
            BaseReferences<_$AppDatabase, $ReelEventsTable, ReelEvent>,
          ),
          ReelEvent,
          PrefetchHooks Function()
        > {
  $$ReelEventsTableTableManager(_$AppDatabase db, $ReelEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReelEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReelEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReelEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> package = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> atMs = const Value.absent(),
                Value<int> dwellMs = const Value.absent(),
                Value<String> day = const Value.absent(),
              }) => ReelEventsCompanion(
                id: id,
                package: package,
                deviceId: deviceId,
                atMs: atMs,
                dwellMs: dwellMs,
                day: day,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String package,
                required String deviceId,
                required int atMs,
                required int dwellMs,
                required String day,
              }) => ReelEventsCompanion.insert(
                id: id,
                package: package,
                deviceId: deviceId,
                atMs: atMs,
                dwellMs: dwellMs,
                day: day,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReelEventsTable, ReelEvent>(table),
                  BaseReferences<_$AppDatabase, $ReelEventsTable, ReelEvent>(
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

typedef $$ReelEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReelEventsTable,
      ReelEvent,
      $$ReelEventsTableFilterComposer,
      $$ReelEventsTableOrderingComposer,
      $$ReelEventsTableAnnotationComposer,
      $$ReelEventsTableCreateCompanionBuilder,
      $$ReelEventsTableUpdateCompanionBuilder,
      (ReelEvent, BaseReferences<_$AppDatabase, $ReelEventsTable, ReelEvent>),
      ReelEvent,
      PrefetchHooks Function()
    >;
typedef $$DailyTotalsTableCreateCompanionBuilder =
    DailyTotalsCompanion Function({
      required String day,
      required String package,
      required String deviceId,
      Value<int> foregroundMs,
      Value<int> opens,
      Value<int> reels,
      Value<int?> syncedAt,
      Value<int> rowid,
    });
typedef $$DailyTotalsTableUpdateCompanionBuilder =
    DailyTotalsCompanion Function({
      Value<String> day,
      Value<String> package,
      Value<String> deviceId,
      Value<int> foregroundMs,
      Value<int> opens,
      Value<int> reels,
      Value<int?> syncedAt,
      Value<int> rowid,
    });

class $$DailyTotalsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyTotalsTable> {
  $$DailyTotalsTableFilterComposer({
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

  ColumnFilters<String> get package => $composableBuilder(
    column: $table.package,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get foregroundMs => $composableBuilder(
    column: $table.foregroundMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get opens => $composableBuilder(
    column: $table.opens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reels => $composableBuilder(
    column: $table.reels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyTotalsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyTotalsTable> {
  $$DailyTotalsTableOrderingComposer({
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

  ColumnOrderings<String> get package => $composableBuilder(
    column: $table.package,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get foregroundMs => $composableBuilder(
    column: $table.foregroundMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get opens => $composableBuilder(
    column: $table.opens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reels => $composableBuilder(
    column: $table.reels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyTotalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyTotalsTable> {
  $$DailyTotalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get package =>
      $composableBuilder(column: $table.package, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get foregroundMs => $composableBuilder(
    column: $table.foregroundMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get opens =>
      $composableBuilder(column: $table.opens, builder: (column) => column);

  GeneratedColumn<int> get reels =>
      $composableBuilder(column: $table.reels, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$DailyTotalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyTotalsTable,
          DailyTotal,
          $$DailyTotalsTableFilterComposer,
          $$DailyTotalsTableOrderingComposer,
          $$DailyTotalsTableAnnotationComposer,
          $$DailyTotalsTableCreateCompanionBuilder,
          $$DailyTotalsTableUpdateCompanionBuilder,
          (
            DailyTotal,
            BaseReferences<_$AppDatabase, $DailyTotalsTable, DailyTotal>,
          ),
          DailyTotal,
          PrefetchHooks Function()
        > {
  $$DailyTotalsTableTableManager(_$AppDatabase db, $DailyTotalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyTotalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyTotalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyTotalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<String> package = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> foregroundMs = const Value.absent(),
                Value<int> opens = const Value.absent(),
                Value<int> reels = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyTotalsCompanion(
                day: day,
                package: package,
                deviceId: deviceId,
                foregroundMs: foregroundMs,
                opens: opens,
                reels: reels,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String day,
                required String package,
                required String deviceId,
                Value<int> foregroundMs = const Value.absent(),
                Value<int> opens = const Value.absent(),
                Value<int> reels = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyTotalsCompanion.insert(
                day: day,
                package: package,
                deviceId: deviceId,
                foregroundMs: foregroundMs,
                opens: opens,
                reels: reels,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyTotalsTable, DailyTotal>(table),
                  BaseReferences<_$AppDatabase, $DailyTotalsTable, DailyTotal>(
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

typedef $$DailyTotalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyTotalsTable,
      DailyTotal,
      $$DailyTotalsTableFilterComposer,
      $$DailyTotalsTableOrderingComposer,
      $$DailyTotalsTableAnnotationComposer,
      $$DailyTotalsTableCreateCompanionBuilder,
      $$DailyTotalsTableUpdateCompanionBuilder,
      (
        DailyTotal,
        BaseReferences<_$AppDatabase, $DailyTotalsTable, DailyTotal>,
      ),
      DailyTotal,
      PrefetchHooks Function()
    >;
typedef $$LimitsTableCreateCompanionBuilder = LimitsCompanion Function({
  Value<int> id,
  required String scope,
  Value<String?> package,
  Value<int?> dailyLimitMs,
  Value<int?> dailyLimitReels,
  Value<bool> remind,
  Value<int?> snoozeUntilMs,
});
typedef $$LimitsTableUpdateCompanionBuilder = LimitsCompanion Function({
  Value<int> id,
  Value<String> scope,
  Value<String?> package,
  Value<int?> dailyLimitMs,
  Value<int?> dailyLimitReels,
  Value<bool> remind,
  Value<int?> snoozeUntilMs,
});

class $$LimitsTableFilterComposer
    extends Composer<_$AppDatabase, $LimitsTable> {
  $$LimitsTableFilterComposer({
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

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get package => $composableBuilder(
    column: $table.package,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyLimitMs => $composableBuilder(
    column: $table.dailyLimitMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyLimitReels => $composableBuilder(
    column: $table.dailyLimitReels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remind => $composableBuilder(
    column: $table.remind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozeUntilMs => $composableBuilder(
    column: $table.snoozeUntilMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LimitsTableOrderingComposer
    extends Composer<_$AppDatabase, $LimitsTable> {
  $$LimitsTableOrderingComposer({
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

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get package => $composableBuilder(
    column: $table.package,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyLimitMs => $composableBuilder(
    column: $table.dailyLimitMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyLimitReels => $composableBuilder(
    column: $table.dailyLimitReels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remind => $composableBuilder(
    column: $table.remind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeUntilMs => $composableBuilder(
    column: $table.snoozeUntilMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LimitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LimitsTable> {
  $$LimitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get package =>
      $composableBuilder(column: $table.package, builder: (column) => column);

  GeneratedColumn<int> get dailyLimitMs => $composableBuilder(
    column: $table.dailyLimitMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyLimitReels => $composableBuilder(
    column: $table.dailyLimitReels,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get remind =>
      $composableBuilder(column: $table.remind, builder: (column) => column);

  GeneratedColumn<int> get snoozeUntilMs => $composableBuilder(
    column: $table.snoozeUntilMs,
    builder: (column) => column,
  );
}

class $$LimitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LimitsTable,
          AppLimit,
          $$LimitsTableFilterComposer,
          $$LimitsTableOrderingComposer,
          $$LimitsTableAnnotationComposer,
          $$LimitsTableCreateCompanionBuilder,
          $$LimitsTableUpdateCompanionBuilder,
          (AppLimit, BaseReferences<_$AppDatabase, $LimitsTable, AppLimit>),
          AppLimit,
          PrefetchHooks Function()
        > {
  $$LimitsTableTableManager(_$AppDatabase db, $LimitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LimitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LimitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LimitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<String?> package = const Value.absent(),
                Value<int?> dailyLimitMs = const Value.absent(),
                Value<int?> dailyLimitReels = const Value.absent(),
                Value<bool> remind = const Value.absent(),
                Value<int?> snoozeUntilMs = const Value.absent(),
              }) => LimitsCompanion(
                id: id,
                scope: scope,
                package: package,
                dailyLimitMs: dailyLimitMs,
                dailyLimitReels: dailyLimitReels,
                remind: remind,
                snoozeUntilMs: snoozeUntilMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String scope,
                Value<String?> package = const Value.absent(),
                Value<int?> dailyLimitMs = const Value.absent(),
                Value<int?> dailyLimitReels = const Value.absent(),
                Value<bool> remind = const Value.absent(),
                Value<int?> snoozeUntilMs = const Value.absent(),
              }) => LimitsCompanion.insert(
                id: id,
                scope: scope,
                package: package,
                dailyLimitMs: dailyLimitMs,
                dailyLimitReels: dailyLimitReels,
                remind: remind,
                snoozeUntilMs: snoozeUntilMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LimitsTable, AppLimit>(table),
                  BaseReferences<_$AppDatabase, $LimitsTable, AppLimit>(
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

typedef $$LimitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LimitsTable,
      AppLimit,
      $$LimitsTableFilterComposer,
      $$LimitsTableOrderingComposer,
      $$LimitsTableAnnotationComposer,
      $$LimitsTableCreateCompanionBuilder,
      $$LimitsTableUpdateCompanionBuilder,
      (AppLimit, BaseReferences<_$AppDatabase, $LimitsTable, AppLimit>),
      AppLimit,
      PrefetchHooks Function()
    >;
typedef $$SettingsEntriesTableCreateCompanionBuilder =
    SettingsEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsEntriesTableUpdateCompanionBuilder =
    SettingsEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsEntriesTable,
          SettingsEntry,
          $$SettingsEntriesTableFilterComposer,
          $$SettingsEntriesTableOrderingComposer,
          $$SettingsEntriesTableAnnotationComposer,
          $$SettingsEntriesTableCreateCompanionBuilder,
          $$SettingsEntriesTableUpdateCompanionBuilder,
          (
            SettingsEntry,
            BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingsEntry>,
          ),
          SettingsEntry,
          PrefetchHooks Function()
        > {
  $$SettingsEntriesTableTableManager(
    _$AppDatabase db,
    $SettingsEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsEntriesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsEntriesTable, SettingsEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SettingsEntriesTable,
                    SettingsEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsEntriesTable,
      SettingsEntry,
      $$SettingsEntriesTableFilterComposer,
      $$SettingsEntriesTableOrderingComposer,
      $$SettingsEntriesTableAnnotationComposer,
      $$SettingsEntriesTableCreateCompanionBuilder,
      $$SettingsEntriesTableUpdateCompanionBuilder,
      (
        SettingsEntry,
        BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingsEntry>,
      ),
      SettingsEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppsTableTableManager get apps => $$AppsTableTableManager(_db, _db.apps);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$ReelEventsTableTableManager get reelEvents =>
      $$ReelEventsTableTableManager(_db, _db.reelEvents);
  $$DailyTotalsTableTableManager get dailyTotals =>
      $$DailyTotalsTableTableManager(_db, _db.dailyTotals);
  $$LimitsTableTableManager get limits =>
      $$LimitsTableTableManager(_db, _db.limits);
  $$SettingsEntriesTableTableManager get settingsEntries =>
      $$SettingsEntriesTableTableManager(_db, _db.settingsEntries);
}
