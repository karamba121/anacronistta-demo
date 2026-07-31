// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TimeEntriesTable extends TimeEntries
    with TableInfo<$TimeEntriesTable, TimeEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimeEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, type, occurredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'time_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimeEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimeEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimeEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $TimeEntriesTable createAlias(String alias) {
    return $TimeEntriesTable(attachedDatabase, alias);
  }
}

class TimeEntryRow extends DataClass implements Insertable<TimeEntryRow> {
  final int id;
  final String type;
  final DateTime occurredAt;
  const TimeEntryRow({
    required this.id,
    required this.type,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  TimeEntriesCompanion toCompanion(bool nullToAbsent) {
    return TimeEntriesCompanion(
      id: Value(id),
      type: Value(type),
      occurredAt: Value(occurredAt),
    );
  }

  factory TimeEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimeEntryRow(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  TimeEntryRow copyWith({int? id, String? type, DateTime? occurredAt}) =>
      TimeEntryRow(
        id: id ?? this.id,
        type: type ?? this.type,
        occurredAt: occurredAt ?? this.occurredAt,
      );
  TimeEntryRow copyWithCompanion(TimeEntriesCompanion data) {
    return TimeEntryRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimeEntryRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeEntryRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt);
}

class TimeEntriesCompanion extends UpdateCompanion<TimeEntryRow> {
  final Value<int> id;
  final Value<String> type;
  final Value<DateTime> occurredAt;
  const TimeEntriesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
  });
  TimeEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required DateTime occurredAt,
  }) : type = Value(type),
       occurredAt = Value(occurredAt);
  static Insertable<TimeEntryRow> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
    });
  }

  TimeEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<DateTime>? occurredAt,
  }) {
    return TimeEntriesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimeEntriesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }
}

class $WorkDaySchedulesTable extends WorkDaySchedules
    with TableInfo<$WorkDaySchedulesTable, WorkDaySchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkDaySchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [weekday, enabled];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_day_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkDaySchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {weekday};
  @override
  WorkDaySchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkDaySchedule(
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $WorkDaySchedulesTable createAlias(String alias) {
    return $WorkDaySchedulesTable(attachedDatabase, alias);
  }
}

class WorkDaySchedule extends DataClass implements Insertable<WorkDaySchedule> {
  final int weekday;
  final bool enabled;
  const WorkDaySchedule({required this.weekday, required this.enabled});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['weekday'] = Variable<int>(weekday);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  WorkDaySchedulesCompanion toCompanion(bool nullToAbsent) {
    return WorkDaySchedulesCompanion(
      weekday: Value(weekday),
      enabled: Value(enabled),
    );
  }

  factory WorkDaySchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkDaySchedule(
      weekday: serializer.fromJson<int>(json['weekday']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'weekday': serializer.toJson<int>(weekday),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  WorkDaySchedule copyWith({int? weekday, bool? enabled}) => WorkDaySchedule(
    weekday: weekday ?? this.weekday,
    enabled: enabled ?? this.enabled,
  );
  WorkDaySchedule copyWithCompanion(WorkDaySchedulesCompanion data) {
    return WorkDaySchedule(
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkDaySchedule(')
          ..write('weekday: $weekday, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(weekday, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkDaySchedule &&
          other.weekday == this.weekday &&
          other.enabled == this.enabled);
}

class WorkDaySchedulesCompanion extends UpdateCompanion<WorkDaySchedule> {
  final Value<int> weekday;
  final Value<bool> enabled;
  const WorkDaySchedulesCompanion({
    this.weekday = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  WorkDaySchedulesCompanion.insert({
    this.weekday = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  static Insertable<WorkDaySchedule> custom({
    Expression<int>? weekday,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (weekday != null) 'weekday': weekday,
      if (enabled != null) 'enabled': enabled,
    });
  }

  WorkDaySchedulesCompanion copyWith({
    Value<int>? weekday,
    Value<bool>? enabled,
  }) {
    return WorkDaySchedulesCompanion(
      weekday: weekday ?? this.weekday,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkDaySchedulesCompanion(')
          ..write('weekday: $weekday, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

class $WorkShiftsTable extends WorkShifts
    with TableInfo<$WorkShiftsTable, WorkShift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkShiftsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES work_day_schedules (weekday)',
    ),
  );
  static const VerificationMeta _startMinutesMeta = const VerificationMeta(
    'startMinutes',
  );
  @override
  late final GeneratedColumn<int> startMinutes = GeneratedColumn<int>(
    'start_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMinutesMeta = const VerificationMeta(
    'endMinutes',
  );
  @override
  late final GeneratedColumn<int> endMinutes = GeneratedColumn<int>(
    'end_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    weekday,
    startMinutes,
    endMinutes,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_shifts';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkShift> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('start_minutes')) {
      context.handle(
        _startMinutesMeta,
        startMinutes.isAcceptableOrUnknown(
          data['start_minutes']!,
          _startMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startMinutesMeta);
    }
    if (data.containsKey('end_minutes')) {
      context.handle(
        _endMinutesMeta,
        endMinutes.isAcceptableOrUnknown(data['end_minutes']!, _endMinutesMeta),
      );
    } else if (isInserting) {
      context.missing(_endMinutesMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkShift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkShift(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
      startMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minutes'],
      )!,
      endMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minutes'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $WorkShiftsTable createAlias(String alias) {
    return $WorkShiftsTable(attachedDatabase, alias);
  }
}

class WorkShift extends DataClass implements Insertable<WorkShift> {
  final int id;
  final int weekday;
  final int startMinutes;
  final int endMinutes;
  final int position;
  const WorkShift({
    required this.id,
    required this.weekday,
    required this.startMinutes,
    required this.endMinutes,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['weekday'] = Variable<int>(weekday);
    map['start_minutes'] = Variable<int>(startMinutes);
    map['end_minutes'] = Variable<int>(endMinutes);
    map['position'] = Variable<int>(position);
    return map;
  }

  WorkShiftsCompanion toCompanion(bool nullToAbsent) {
    return WorkShiftsCompanion(
      id: Value(id),
      weekday: Value(weekday),
      startMinutes: Value(startMinutes),
      endMinutes: Value(endMinutes),
      position: Value(position),
    );
  }

  factory WorkShift.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkShift(
      id: serializer.fromJson<int>(json['id']),
      weekday: serializer.fromJson<int>(json['weekday']),
      startMinutes: serializer.fromJson<int>(json['startMinutes']),
      endMinutes: serializer.fromJson<int>(json['endMinutes']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weekday': serializer.toJson<int>(weekday),
      'startMinutes': serializer.toJson<int>(startMinutes),
      'endMinutes': serializer.toJson<int>(endMinutes),
      'position': serializer.toJson<int>(position),
    };
  }

  WorkShift copyWith({
    int? id,
    int? weekday,
    int? startMinutes,
    int? endMinutes,
    int? position,
  }) => WorkShift(
    id: id ?? this.id,
    weekday: weekday ?? this.weekday,
    startMinutes: startMinutes ?? this.startMinutes,
    endMinutes: endMinutes ?? this.endMinutes,
    position: position ?? this.position,
  );
  WorkShift copyWithCompanion(WorkShiftsCompanion data) {
    return WorkShift(
      id: data.id.present ? data.id.value : this.id,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      startMinutes: data.startMinutes.present
          ? data.startMinutes.value
          : this.startMinutes,
      endMinutes: data.endMinutes.present
          ? data.endMinutes.value
          : this.endMinutes,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkShift(')
          ..write('id: $id, ')
          ..write('weekday: $weekday, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, weekday, startMinutes, endMinutes, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkShift &&
          other.id == this.id &&
          other.weekday == this.weekday &&
          other.startMinutes == this.startMinutes &&
          other.endMinutes == this.endMinutes &&
          other.position == this.position);
}

class WorkShiftsCompanion extends UpdateCompanion<WorkShift> {
  final Value<int> id;
  final Value<int> weekday;
  final Value<int> startMinutes;
  final Value<int> endMinutes;
  final Value<int> position;
  const WorkShiftsCompanion({
    this.id = const Value.absent(),
    this.weekday = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.endMinutes = const Value.absent(),
    this.position = const Value.absent(),
  });
  WorkShiftsCompanion.insert({
    this.id = const Value.absent(),
    required int weekday,
    required int startMinutes,
    required int endMinutes,
    required int position,
  }) : weekday = Value(weekday),
       startMinutes = Value(startMinutes),
       endMinutes = Value(endMinutes),
       position = Value(position);
  static Insertable<WorkShift> custom({
    Expression<int>? id,
    Expression<int>? weekday,
    Expression<int>? startMinutes,
    Expression<int>? endMinutes,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weekday != null) 'weekday': weekday,
      if (startMinutes != null) 'start_minutes': startMinutes,
      if (endMinutes != null) 'end_minutes': endMinutes,
      if (position != null) 'position': position,
    });
  }

  WorkShiftsCompanion copyWith({
    Value<int>? id,
    Value<int>? weekday,
    Value<int>? startMinutes,
    Value<int>? endMinutes,
    Value<int>? position,
  }) {
    return WorkShiftsCompanion(
      id: id ?? this.id,
      weekday: weekday ?? this.weekday,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (startMinutes.present) {
      map['start_minutes'] = Variable<int>(startMinutes.value);
    }
    if (endMinutes.present) {
      map['end_minutes'] = Variable<int>(endMinutes.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkShiftsCompanion(')
          ..write('id: $id, ')
          ..write('weekday: $weekday, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TimeEntriesTable timeEntries = $TimeEntriesTable(this);
  late final $WorkDaySchedulesTable workDaySchedules = $WorkDaySchedulesTable(
    this,
  );
  late final $WorkShiftsTable workShifts = $WorkShiftsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    timeEntries,
    workDaySchedules,
    workShifts,
  ];
}

typedef $$TimeEntriesTableCreateCompanionBuilder =
    TimeEntriesCompanion Function({
      Value<int> id,
      required String type,
      required DateTime occurredAt,
    });
typedef $$TimeEntriesTableUpdateCompanionBuilder =
    TimeEntriesCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<DateTime> occurredAt,
    });

class $$TimeEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TimeEntriesTable> {
  $$TimeEntriesTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimeEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TimeEntriesTable> {
  $$TimeEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimeEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimeEntriesTable> {
  $$TimeEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );
}

class $$TimeEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimeEntriesTable,
          TimeEntryRow,
          $$TimeEntriesTableFilterComposer,
          $$TimeEntriesTableOrderingComposer,
          $$TimeEntriesTableAnnotationComposer,
          $$TimeEntriesTableCreateCompanionBuilder,
          $$TimeEntriesTableUpdateCompanionBuilder,
          (
            TimeEntryRow,
            BaseReferences<_$AppDatabase, $TimeEntriesTable, TimeEntryRow>,
          ),
          TimeEntryRow,
          PrefetchHooks Function()
        > {
  $$TimeEntriesTableTableManager(_$AppDatabase db, $TimeEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimeEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimeEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimeEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
              }) => TimeEntriesCompanion(
                id: id,
                type: type,
                occurredAt: occurredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required DateTime occurredAt,
              }) => TimeEntriesCompanion.insert(
                id: id,
                type: type,
                occurredAt: occurredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimeEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimeEntriesTable,
      TimeEntryRow,
      $$TimeEntriesTableFilterComposer,
      $$TimeEntriesTableOrderingComposer,
      $$TimeEntriesTableAnnotationComposer,
      $$TimeEntriesTableCreateCompanionBuilder,
      $$TimeEntriesTableUpdateCompanionBuilder,
      (
        TimeEntryRow,
        BaseReferences<_$AppDatabase, $TimeEntriesTable, TimeEntryRow>,
      ),
      TimeEntryRow,
      PrefetchHooks Function()
    >;
typedef $$WorkDaySchedulesTableCreateCompanionBuilder =
    WorkDaySchedulesCompanion Function({
      Value<int> weekday,
      Value<bool> enabled,
    });
typedef $$WorkDaySchedulesTableUpdateCompanionBuilder =
    WorkDaySchedulesCompanion Function({
      Value<int> weekday,
      Value<bool> enabled,
    });

final class $$WorkDaySchedulesTableReferences
    extends
        BaseReferences<_$AppDatabase, $WorkDaySchedulesTable, WorkDaySchedule> {
  $$WorkDaySchedulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$WorkShiftsTable, List<WorkShift>>
  _workShiftsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workShifts,
    aliasName: 'work_day_schedules__weekday__work_shifts__weekday',
  );

  $$WorkShiftsTableProcessedTableManager get workShiftsRefs {
    final manager = $$WorkShiftsTableTableManager(
      $_db,
      $_db.workShifts,
    ).filter((f) => f.weekday.weekday.sqlEquals($_itemColumn<int>('weekday')!));

    final cache = $_typedResult.readTableOrNull(_workShiftsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkDaySchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkDaySchedulesTable> {
  $$WorkDaySchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workShiftsRefs(
    Expression<bool> Function($$WorkShiftsTableFilterComposer f) f,
  ) {
    final $$WorkShiftsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weekday,
      referencedTable: $db.workShifts,
      getReferencedColumn: (t) => t.weekday,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkShiftsTableFilterComposer(
            $db: $db,
            $table: $db.workShifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkDaySchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkDaySchedulesTable> {
  $$WorkDaySchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkDaySchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkDaySchedulesTable> {
  $$WorkDaySchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  Expression<T> workShiftsRefs<T extends Object>(
    Expression<T> Function($$WorkShiftsTableAnnotationComposer a) f,
  ) {
    final $$WorkShiftsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weekday,
      referencedTable: $db.workShifts,
      getReferencedColumn: (t) => t.weekday,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkShiftsTableAnnotationComposer(
            $db: $db,
            $table: $db.workShifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkDaySchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkDaySchedulesTable,
          WorkDaySchedule,
          $$WorkDaySchedulesTableFilterComposer,
          $$WorkDaySchedulesTableOrderingComposer,
          $$WorkDaySchedulesTableAnnotationComposer,
          $$WorkDaySchedulesTableCreateCompanionBuilder,
          $$WorkDaySchedulesTableUpdateCompanionBuilder,
          (WorkDaySchedule, $$WorkDaySchedulesTableReferences),
          WorkDaySchedule,
          PrefetchHooks Function({bool workShiftsRefs})
        > {
  $$WorkDaySchedulesTableTableManager(
    _$AppDatabase db,
    $WorkDaySchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkDaySchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkDaySchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkDaySchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> weekday = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) =>
                  WorkDaySchedulesCompanion(weekday: weekday, enabled: enabled),
          createCompanionCallback:
              ({
                Value<int> weekday = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => WorkDaySchedulesCompanion.insert(
                weekday: weekday,
                enabled: enabled,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkDaySchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workShiftsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (workShiftsRefs) db.workShifts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workShiftsRefs)
                    await $_getPrefetchedData<
                      WorkDaySchedule,
                      $WorkDaySchedulesTable,
                      WorkShift
                    >(
                      currentTable: table,
                      referencedTable: $$WorkDaySchedulesTableReferences
                          ._workShiftsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WorkDaySchedulesTableReferences(
                            db,
                            table,
                            p0,
                          ).workShiftsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.weekday == item.weekday,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkDaySchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkDaySchedulesTable,
      WorkDaySchedule,
      $$WorkDaySchedulesTableFilterComposer,
      $$WorkDaySchedulesTableOrderingComposer,
      $$WorkDaySchedulesTableAnnotationComposer,
      $$WorkDaySchedulesTableCreateCompanionBuilder,
      $$WorkDaySchedulesTableUpdateCompanionBuilder,
      (WorkDaySchedule, $$WorkDaySchedulesTableReferences),
      WorkDaySchedule,
      PrefetchHooks Function({bool workShiftsRefs})
    >;
typedef $$WorkShiftsTableCreateCompanionBuilder =
    WorkShiftsCompanion Function({
      Value<int> id,
      required int weekday,
      required int startMinutes,
      required int endMinutes,
      required int position,
    });
typedef $$WorkShiftsTableUpdateCompanionBuilder =
    WorkShiftsCompanion Function({
      Value<int> id,
      Value<int> weekday,
      Value<int> startMinutes,
      Value<int> endMinutes,
      Value<int> position,
    });

final class $$WorkShiftsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkShiftsTable, WorkShift> {
  $$WorkShiftsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkDaySchedulesTable _weekdayTable(_$AppDatabase db) => db
      .workDaySchedules
      .createAlias('work_shifts__weekday__work_day_schedules__weekday');

  $$WorkDaySchedulesTableProcessedTableManager get weekday {
    final $_column = $_itemColumn<int>('weekday')!;

    final manager = $$WorkDaySchedulesTableTableManager(
      $_db,
      $_db.workDaySchedules,
    ).filter((f) => f.weekday.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_weekdayTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkShiftsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkShiftsTable> {
  $$WorkShiftsTableFilterComposer({
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

  ColumnFilters<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkDaySchedulesTableFilterComposer get weekday {
    final $$WorkDaySchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weekday,
      referencedTable: $db.workDaySchedules,
      getReferencedColumn: (t) => t.weekday,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkDaySchedulesTableFilterComposer(
            $db: $db,
            $table: $db.workDaySchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkShiftsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkShiftsTable> {
  $$WorkShiftsTableOrderingComposer({
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

  ColumnOrderings<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkDaySchedulesTableOrderingComposer get weekday {
    final $$WorkDaySchedulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weekday,
      referencedTable: $db.workDaySchedules,
      getReferencedColumn: (t) => t.weekday,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkDaySchedulesTableOrderingComposer(
            $db: $db,
            $table: $db.workDaySchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkShiftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkShiftsTable> {
  $$WorkShiftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$WorkDaySchedulesTableAnnotationComposer get weekday {
    final $$WorkDaySchedulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weekday,
      referencedTable: $db.workDaySchedules,
      getReferencedColumn: (t) => t.weekday,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkDaySchedulesTableAnnotationComposer(
            $db: $db,
            $table: $db.workDaySchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkShiftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkShiftsTable,
          WorkShift,
          $$WorkShiftsTableFilterComposer,
          $$WorkShiftsTableOrderingComposer,
          $$WorkShiftsTableAnnotationComposer,
          $$WorkShiftsTableCreateCompanionBuilder,
          $$WorkShiftsTableUpdateCompanionBuilder,
          (WorkShift, $$WorkShiftsTableReferences),
          WorkShift,
          PrefetchHooks Function({bool weekday})
        > {
  $$WorkShiftsTableTableManager(_$AppDatabase db, $WorkShiftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkShiftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkShiftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkShiftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> weekday = const Value.absent(),
                Value<int> startMinutes = const Value.absent(),
                Value<int> endMinutes = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => WorkShiftsCompanion(
                id: id,
                weekday: weekday,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int weekday,
                required int startMinutes,
                required int endMinutes,
                required int position,
              }) => WorkShiftsCompanion.insert(
                id: id,
                weekday: weekday,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkShiftsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({weekday = false}) {
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
                    if (weekday) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.weekday,
                                referencedTable: $$WorkShiftsTableReferences
                                    ._weekdayTable(db),
                                referencedColumn: $$WorkShiftsTableReferences
                                    ._weekdayTable(db)
                                    .weekday,
                              )
                              as T;
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

typedef $$WorkShiftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkShiftsTable,
      WorkShift,
      $$WorkShiftsTableFilterComposer,
      $$WorkShiftsTableOrderingComposer,
      $$WorkShiftsTableAnnotationComposer,
      $$WorkShiftsTableCreateCompanionBuilder,
      $$WorkShiftsTableUpdateCompanionBuilder,
      (WorkShift, $$WorkShiftsTableReferences),
      WorkShift,
      PrefetchHooks Function({bool weekday})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TimeEntriesTableTableManager get timeEntries =>
      $$TimeEntriesTableTableManager(_db, _db.timeEntries);
  $$WorkDaySchedulesTableTableManager get workDaySchedules =>
      $$WorkDaySchedulesTableTableManager(_db, _db.workDaySchedules);
  $$WorkShiftsTableTableManager get workShifts =>
      $$WorkShiftsTableTableManager(_db, _db.workShifts);
}
