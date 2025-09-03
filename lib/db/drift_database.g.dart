// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $DriftSettingsTable extends DriftSettings
    with TableInfo<$DriftSettingsTable, DriftSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DriftSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<UserTheme, String> theme =
      GeneratedColumn<String>('theme', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<UserTheme>($DriftSettingsTable.$convertertheme);
  @override
  late final GeneratedColumnWithTypeConverter<Duration?, String>
      intraSetRestTimer = GeneratedColumn<String>(
              'intra_set_rest_timer', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Duration?>(
              $DriftSettingsTable.$converterintraSetRestTimer);
  @override
  List<GeneratedColumn> get $columns =>
      [id, updatedAt, createdAt, theme, intraSetRestTimer];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<DriftSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      theme: $DriftSettingsTable.$convertertheme.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme'])!),
      intraSetRestTimer: $DriftSettingsTable.$converterintraSetRestTimer
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}intra_set_rest_timer'])),
    );
  }

  @override
  $DriftSettingsTable createAlias(String alias) {
    return $DriftSettingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<UserTheme, String, String> $convertertheme =
      const EnumNameConverter<UserTheme>(UserTheme.values);
  static TypeConverter<Duration?, String?> $converterintraSetRestTimer =
      const DurationConverter();
}

class DriftSetting extends DataClass implements Insertable<DriftSetting> {
  final int id;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final UserTheme theme;
  final Duration? intraSetRestTimer;
  const DriftSetting(
      {required this.id,
      this.updatedAt,
      this.createdAt,
      required this.theme,
      this.intraSetRestTimer});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    {
      map['theme'] =
          Variable<String>($DriftSettingsTable.$convertertheme.toSql(theme));
    }
    if (!nullToAbsent || intraSetRestTimer != null) {
      map['intra_set_rest_timer'] = Variable<String>($DriftSettingsTable
          .$converterintraSetRestTimer
          .toSql(intraSetRestTimer));
    }
    return map;
  }

  DriftSettingsCompanion toCompanion(bool nullToAbsent) {
    return DriftSettingsCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      theme: Value(theme),
      intraSetRestTimer: intraSetRestTimer == null && nullToAbsent
          ? const Value.absent()
          : Value(intraSetRestTimer),
    );
  }

  factory DriftSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftSetting(
      id: serializer.fromJson<int>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      theme: $DriftSettingsTable.$convertertheme
          .fromJson(serializer.fromJson<String>(json['theme'])),
      intraSetRestTimer:
          serializer.fromJson<Duration?>(json['intraSetRestTimer']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'theme': serializer
          .toJson<String>($DriftSettingsTable.$convertertheme.toJson(theme)),
      'intraSetRestTimer': serializer.toJson<Duration?>(intraSetRestTimer),
    };
  }

  DriftSetting copyWith(
          {int? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          UserTheme? theme,
          Value<Duration?> intraSetRestTimer = const Value.absent()}) =>
      DriftSetting(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        theme: theme ?? this.theme,
        intraSetRestTimer: intraSetRestTimer.present
            ? intraSetRestTimer.value
            : this.intraSetRestTimer,
      );
  DriftSetting copyWithCompanion(DriftSettingsCompanion data) {
    return DriftSetting(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      theme: data.theme.present ? data.theme.value : this.theme,
      intraSetRestTimer: data.intraSetRestTimer.present
          ? data.intraSetRestTimer.value
          : this.intraSetRestTimer,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftSetting(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('theme: $theme, ')
          ..write('intraSetRestTimer: $intraSetRestTimer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, createdAt, theme, intraSetRestTimer);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftSetting &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt &&
          other.theme == this.theme &&
          other.intraSetRestTimer == this.intraSetRestTimer);
}

class DriftSettingsCompanion extends UpdateCompanion<DriftSetting> {
  final Value<int> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> createdAt;
  final Value<UserTheme> theme;
  final Value<Duration?> intraSetRestTimer;
  const DriftSettingsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.theme = const Value.absent(),
    this.intraSetRestTimer = const Value.absent(),
  });
  DriftSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    required UserTheme theme,
    this.intraSetRestTimer = const Value.absent(),
  }) : theme = Value(theme);
  static Insertable<DriftSetting> custom({
    Expression<int>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<String>? theme,
    Expression<String>? intraSetRestTimer,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (theme != null) 'theme': theme,
      if (intraSetRestTimer != null) 'intra_set_rest_timer': intraSetRestTimer,
    });
  }

  DriftSettingsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? createdAt,
      Value<UserTheme>? theme,
      Value<Duration?>? intraSetRestTimer}) {
    return DriftSettingsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      theme: theme ?? this.theme,
      intraSetRestTimer: intraSetRestTimer ?? this.intraSetRestTimer,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(
          $DriftSettingsTable.$convertertheme.toSql(theme.value));
    }
    if (intraSetRestTimer.present) {
      map['intra_set_rest_timer'] = Variable<String>($DriftSettingsTable
          .$converterintraSetRestTimer
          .toSql(intraSetRestTimer.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DriftSettingsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('theme: $theme, ')
          ..write('intraSetRestTimer: $intraSetRestTimer')
          ..write(')'))
        .toString();
  }
}

class $DriftBodyweightsTable extends DriftBodyweights
    with TableInfo<$DriftBodyweightsTable, DriftBodyweight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DriftBodyweightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitsMeta = const VerificationMeta('units');
  @override
  late final GeneratedColumn<String> units = GeneratedColumn<String>(
      'units', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, updatedAt, createdAt, date, weight, units];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bodyweight';
  @override
  VerificationContext validateIntegrity(Insertable<DriftBodyweight> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('units')) {
      context.handle(
          _unitsMeta, units.isAcceptableOrUnknown(data['units']!, _unitsMeta));
    } else if (isInserting) {
      context.missing(_unitsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftBodyweight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftBodyweight(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight'])!,
      units: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}units'])!,
    );
  }

  @override
  $DriftBodyweightsTable createAlias(String alias) {
    return $DriftBodyweightsTable(attachedDatabase, alias);
  }
}

class DriftBodyweight extends DataClass implements Insertable<DriftBodyweight> {
  final int id;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final DateTime date;
  final double weight;
  final String units;
  const DriftBodyweight(
      {required this.id,
      this.updatedAt,
      this.createdAt,
      required this.date,
      required this.weight,
      required this.units});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['date'] = Variable<DateTime>(date);
    map['weight'] = Variable<double>(weight);
    map['units'] = Variable<String>(units);
    return map;
  }

  DriftBodyweightsCompanion toCompanion(bool nullToAbsent) {
    return DriftBodyweightsCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      date: Value(date),
      weight: Value(weight),
      units: Value(units),
    );
  }

  factory DriftBodyweight.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftBodyweight(
      id: serializer.fromJson<int>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      date: serializer.fromJson<DateTime>(json['date']),
      weight: serializer.fromJson<double>(json['weight']),
      units: serializer.fromJson<String>(json['units']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'date': serializer.toJson<DateTime>(date),
      'weight': serializer.toJson<double>(weight),
      'units': serializer.toJson<String>(units),
    };
  }

  DriftBodyweight copyWith(
          {int? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          DateTime? date,
          double? weight,
          String? units}) =>
      DriftBodyweight(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        date: date ?? this.date,
        weight: weight ?? this.weight,
        units: units ?? this.units,
      );
  DriftBodyweight copyWithCompanion(DriftBodyweightsCompanion data) {
    return DriftBodyweight(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      date: data.date.present ? data.date.value : this.date,
      weight: data.weight.present ? data.weight.value : this.weight,
      units: data.units.present ? data.units.value : this.units,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftBodyweight(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('date: $date, ')
          ..write('weight: $weight, ')
          ..write('units: $units')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, createdAt, date, weight, units);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftBodyweight &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt &&
          other.date == this.date &&
          other.weight == this.weight &&
          other.units == this.units);
}

class DriftBodyweightsCompanion extends UpdateCompanion<DriftBodyweight> {
  final Value<int> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> createdAt;
  final Value<DateTime> date;
  final Value<double> weight;
  final Value<String> units;
  const DriftBodyweightsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.date = const Value.absent(),
    this.weight = const Value.absent(),
    this.units = const Value.absent(),
  });
  DriftBodyweightsCompanion.insert({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    required DateTime date,
    required double weight,
    required String units,
  })  : date = Value(date),
        weight = Value(weight),
        units = Value(units);
  static Insertable<DriftBodyweight> custom({
    Expression<int>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? date,
    Expression<double>? weight,
    Expression<String>? units,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (date != null) 'date': date,
      if (weight != null) 'weight': weight,
      if (units != null) 'units': units,
    });
  }

  DriftBodyweightsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? createdAt,
      Value<DateTime>? date,
      Value<double>? weight,
      Value<String>? units}) {
    return DriftBodyweightsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      units: units ?? this.units,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (units.present) {
      map['units'] = Variable<String>(units.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DriftBodyweightsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('date: $date, ')
          ..write('weight: $weight, ')
          ..write('units: $units')
          ..write(')'))
        .toString();
  }
}

class $DriftFlavourTextSchedulesTable extends DriftFlavourTextSchedules
    with TableInfo<$DriftFlavourTextSchedulesTable, DriftFlavourTextSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DriftFlavourTextSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _flavourTextIdMeta =
      const VerificationMeta('flavourTextId');
  @override
  late final GeneratedColumn<int> flavourTextId = GeneratedColumn<int>(
      'flavour_text_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dismissedMeta =
      const VerificationMeta('dismissed');
  @override
  late final GeneratedColumn<bool> dismissed = GeneratedColumn<bool>(
      'dismissed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dismissed" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, updatedAt, createdAt, flavourTextId, date, dismissed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flavour_text_schedule';
  @override
  VerificationContext validateIntegrity(
      Insertable<DriftFlavourTextSchedule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('flavour_text_id')) {
      context.handle(
          _flavourTextIdMeta,
          flavourTextId.isAcceptableOrUnknown(
              data['flavour_text_id']!, _flavourTextIdMeta));
    } else if (isInserting) {
      context.missing(_flavourTextIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('dismissed')) {
      context.handle(_dismissedMeta,
          dismissed.isAcceptableOrUnknown(data['dismissed']!, _dismissedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftFlavourTextSchedule map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftFlavourTextSchedule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      flavourTextId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}flavour_text_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      dismissed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dismissed'])!,
    );
  }

  @override
  $DriftFlavourTextSchedulesTable createAlias(String alias) {
    return $DriftFlavourTextSchedulesTable(attachedDatabase, alias);
  }
}

class DriftFlavourTextSchedule extends DataClass
    implements Insertable<DriftFlavourTextSchedule> {
  final int id;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int flavourTextId;
  final DateTime date;
  final bool dismissed;
  const DriftFlavourTextSchedule(
      {required this.id,
      this.updatedAt,
      this.createdAt,
      required this.flavourTextId,
      required this.date,
      required this.dismissed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['flavour_text_id'] = Variable<int>(flavourTextId);
    map['date'] = Variable<DateTime>(date);
    map['dismissed'] = Variable<bool>(dismissed);
    return map;
  }

  DriftFlavourTextSchedulesCompanion toCompanion(bool nullToAbsent) {
    return DriftFlavourTextSchedulesCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      flavourTextId: Value(flavourTextId),
      date: Value(date),
      dismissed: Value(dismissed),
    );
  }

  factory DriftFlavourTextSchedule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftFlavourTextSchedule(
      id: serializer.fromJson<int>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      flavourTextId: serializer.fromJson<int>(json['flavourTextId']),
      date: serializer.fromJson<DateTime>(json['date']),
      dismissed: serializer.fromJson<bool>(json['dismissed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'flavourTextId': serializer.toJson<int>(flavourTextId),
      'date': serializer.toJson<DateTime>(date),
      'dismissed': serializer.toJson<bool>(dismissed),
    };
  }

  DriftFlavourTextSchedule copyWith(
          {int? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          int? flavourTextId,
          DateTime? date,
          bool? dismissed}) =>
      DriftFlavourTextSchedule(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        flavourTextId: flavourTextId ?? this.flavourTextId,
        date: date ?? this.date,
        dismissed: dismissed ?? this.dismissed,
      );
  DriftFlavourTextSchedule copyWithCompanion(
      DriftFlavourTextSchedulesCompanion data) {
    return DriftFlavourTextSchedule(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      flavourTextId: data.flavourTextId.present
          ? data.flavourTextId.value
          : this.flavourTextId,
      date: data.date.present ? data.date.value : this.date,
      dismissed: data.dismissed.present ? data.dismissed.value : this.dismissed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftFlavourTextSchedule(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('flavourTextId: $flavourTextId, ')
          ..write('date: $date, ')
          ..write('dismissed: $dismissed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, createdAt, flavourTextId, date, dismissed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftFlavourTextSchedule &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt &&
          other.flavourTextId == this.flavourTextId &&
          other.date == this.date &&
          other.dismissed == this.dismissed);
}

class DriftFlavourTextSchedulesCompanion
    extends UpdateCompanion<DriftFlavourTextSchedule> {
  final Value<int> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> createdAt;
  final Value<int> flavourTextId;
  final Value<DateTime> date;
  final Value<bool> dismissed;
  const DriftFlavourTextSchedulesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.flavourTextId = const Value.absent(),
    this.date = const Value.absent(),
    this.dismissed = const Value.absent(),
  });
  DriftFlavourTextSchedulesCompanion.insert({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    required int flavourTextId,
    required DateTime date,
    this.dismissed = const Value.absent(),
  })  : flavourTextId = Value(flavourTextId),
        date = Value(date);
  static Insertable<DriftFlavourTextSchedule> custom({
    Expression<int>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? flavourTextId,
    Expression<DateTime>? date,
    Expression<bool>? dismissed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (flavourTextId != null) 'flavour_text_id': flavourTextId,
      if (date != null) 'date': date,
      if (dismissed != null) 'dismissed': dismissed,
    });
  }

  DriftFlavourTextSchedulesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? createdAt,
      Value<int>? flavourTextId,
      Value<DateTime>? date,
      Value<bool>? dismissed}) {
    return DriftFlavourTextSchedulesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      flavourTextId: flavourTextId ?? this.flavourTextId,
      date: date ?? this.date,
      dismissed: dismissed ?? this.dismissed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (flavourTextId.present) {
      map['flavour_text_id'] = Variable<int>(flavourTextId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (dismissed.present) {
      map['dismissed'] = Variable<bool>(dismissed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DriftFlavourTextSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('flavourTextId: $flavourTextId, ')
          ..write('date: $date, ')
          ..write('dismissed: $dismissed')
          ..write(')'))
        .toString();
  }
}

class $DriftNotesTable extends DriftNotes
    with TableInfo<$DriftNotesTable, DriftNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DriftNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _objectIdMeta =
      const VerificationMeta('objectId');
  @override
  late final GeneratedColumn<String> objectId = GeneratedColumn<String>(
      'object_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<NoteType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<NoteType>($DriftNotesTable.$convertertype);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, updatedAt, createdAt, objectId, type, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note';
  @override
  VerificationContext validateIntegrity(Insertable<DriftNote> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('object_id')) {
      context.handle(_objectIdMeta,
          objectId.isAcceptableOrUnknown(data['object_id']!, _objectIdMeta));
    } else if (isInserting) {
      context.missing(_objectIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftNote(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      objectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}object_id'])!,
      type: $DriftNotesTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
    );
  }

  @override
  $DriftNotesTable createAlias(String alias) {
    return $DriftNotesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<NoteType, String, String> $convertertype =
      const EnumNameConverter<NoteType>(NoteType.values);
}

class DriftNote extends DataClass implements Insertable<DriftNote> {
  final int id;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final String objectId;
  final NoteType type;
  final String note;
  const DriftNote(
      {required this.id,
      this.updatedAt,
      this.createdAt,
      required this.objectId,
      required this.type,
      required this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['object_id'] = Variable<String>(objectId);
    {
      map['type'] =
          Variable<String>($DriftNotesTable.$convertertype.toSql(type));
    }
    map['note'] = Variable<String>(note);
    return map;
  }

  DriftNotesCompanion toCompanion(bool nullToAbsent) {
    return DriftNotesCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      objectId: Value(objectId),
      type: Value(type),
      note: Value(note),
    );
  }

  factory DriftNote.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftNote(
      id: serializer.fromJson<int>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      objectId: serializer.fromJson<String>(json['objectId']),
      type: $DriftNotesTable.$convertertype
          .fromJson(serializer.fromJson<String>(json['type'])),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'objectId': serializer.toJson<String>(objectId),
      'type': serializer
          .toJson<String>($DriftNotesTable.$convertertype.toJson(type)),
      'note': serializer.toJson<String>(note),
    };
  }

  DriftNote copyWith(
          {int? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          String? objectId,
          NoteType? type,
          String? note}) =>
      DriftNote(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        objectId: objectId ?? this.objectId,
        type: type ?? this.type,
        note: note ?? this.note,
      );
  DriftNote copyWithCompanion(DriftNotesCompanion data) {
    return DriftNote(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      objectId: data.objectId.present ? data.objectId.value : this.objectId,
      type: data.type.present ? data.type.value : this.type,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftNote(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('objectId: $objectId, ')
          ..write('type: $type, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, createdAt, objectId, type, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftNote &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt &&
          other.objectId == this.objectId &&
          other.type == this.type &&
          other.note == this.note);
}

class DriftNotesCompanion extends UpdateCompanion<DriftNote> {
  final Value<int> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> createdAt;
  final Value<String> objectId;
  final Value<NoteType> type;
  final Value<String> note;
  const DriftNotesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.objectId = const Value.absent(),
    this.type = const Value.absent(),
    this.note = const Value.absent(),
  });
  DriftNotesCompanion.insert({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String objectId,
    required NoteType type,
    required String note,
  })  : objectId = Value(objectId),
        type = Value(type),
        note = Value(note);
  static Insertable<DriftNote> custom({
    Expression<int>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<String>? objectId,
    Expression<String>? type,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (objectId != null) 'object_id': objectId,
      if (type != null) 'type': type,
      if (note != null) 'note': note,
    });
  }

  DriftNotesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? createdAt,
      Value<String>? objectId,
      Value<NoteType>? type,
      Value<String>? note}) {
    return DriftNotesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      objectId: objectId ?? this.objectId,
      type: type ?? this.type,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (objectId.present) {
      map['object_id'] = Variable<String>(objectId.value);
    }
    if (type.present) {
      map['type'] =
          Variable<String>($DriftNotesTable.$convertertype.toSql(type.value));
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DriftNotesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('objectId: $objectId, ')
          ..write('type: $type, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $DriftWorkoutsTable extends DriftWorkouts
    with TableInfo<$DriftWorkoutsTable, DriftWorkout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DriftWorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _exerciseOrderMeta =
      const VerificationMeta('exerciseOrder');
  @override
  late final GeneratedColumn<String> exerciseOrder = GeneratedColumn<String>(
      'exercise_order', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, updatedAt, createdAt, date, endDate, exerciseOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout';
  @override
  VerificationContext validateIntegrity(Insertable<DriftWorkout> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('exercise_order')) {
      context.handle(
          _exerciseOrderMeta,
          exerciseOrder.isAcceptableOrUnknown(
              data['exercise_order']!, _exerciseOrderMeta));
    } else if (isInserting) {
      context.missing(_exerciseOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftWorkout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftWorkout(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      exerciseOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exercise_order'])!,
    );
  }

  @override
  $DriftWorkoutsTable createAlias(String alias) {
    return $DriftWorkoutsTable(attachedDatabase, alias);
  }
}

class DriftWorkout extends DataClass implements Insertable<DriftWorkout> {
  final int id;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final DateTime date;
  final DateTime? endDate;
  final String exerciseOrder;
  const DriftWorkout(
      {required this.id,
      this.updatedAt,
      this.createdAt,
      required this.date,
      this.endDate,
      required this.exerciseOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['exercise_order'] = Variable<String>(exerciseOrder);
    return map;
  }

  DriftWorkoutsCompanion toCompanion(bool nullToAbsent) {
    return DriftWorkoutsCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      date: Value(date),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      exerciseOrder: Value(exerciseOrder),
    );
  }

  factory DriftWorkout.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftWorkout(
      id: serializer.fromJson<int>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      date: serializer.fromJson<DateTime>(json['date']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      exerciseOrder: serializer.fromJson<String>(json['exerciseOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'date': serializer.toJson<DateTime>(date),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'exerciseOrder': serializer.toJson<String>(exerciseOrder),
    };
  }

  DriftWorkout copyWith(
          {int? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          DateTime? date,
          Value<DateTime?> endDate = const Value.absent(),
          String? exerciseOrder}) =>
      DriftWorkout(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        date: date ?? this.date,
        endDate: endDate.present ? endDate.value : this.endDate,
        exerciseOrder: exerciseOrder ?? this.exerciseOrder,
      );
  DriftWorkout copyWithCompanion(DriftWorkoutsCompanion data) {
    return DriftWorkout(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      date: data.date.present ? data.date.value : this.date,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      exerciseOrder: data.exerciseOrder.present
          ? data.exerciseOrder.value
          : this.exerciseOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftWorkout(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('date: $date, ')
          ..write('endDate: $endDate, ')
          ..write('exerciseOrder: $exerciseOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, createdAt, date, endDate, exerciseOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftWorkout &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt &&
          other.date == this.date &&
          other.endDate == this.endDate &&
          other.exerciseOrder == this.exerciseOrder);
}

class DriftWorkoutsCompanion extends UpdateCompanion<DriftWorkout> {
  final Value<int> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> createdAt;
  final Value<DateTime> date;
  final Value<DateTime?> endDate;
  final Value<String> exerciseOrder;
  const DriftWorkoutsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.date = const Value.absent(),
    this.endDate = const Value.absent(),
    this.exerciseOrder = const Value.absent(),
  });
  DriftWorkoutsCompanion.insert({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    required DateTime date,
    this.endDate = const Value.absent(),
    required String exerciseOrder,
  })  : date = Value(date),
        exerciseOrder = Value(exerciseOrder);
  static Insertable<DriftWorkout> custom({
    Expression<int>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? date,
    Expression<DateTime>? endDate,
    Expression<String>? exerciseOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (date != null) 'date': date,
      if (endDate != null) 'end_date': endDate,
      if (exerciseOrder != null) 'exercise_order': exerciseOrder,
    });
  }

  DriftWorkoutsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? createdAt,
      Value<DateTime>? date,
      Value<DateTime?>? endDate,
      Value<String>? exerciseOrder}) {
    return DriftWorkoutsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      date: date ?? this.date,
      endDate: endDate ?? this.endDate,
      exerciseOrder: exerciseOrder ?? this.exerciseOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (exerciseOrder.present) {
      map['exercise_order'] = Variable<String>(exerciseOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DriftWorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('date: $date, ')
          ..write('endDate: $endDate, ')
          ..write('exerciseOrder: $exerciseOrder')
          ..write(')'))
        .toString();
  }
}

class $DriftWorkoutCategoriesTable extends DriftWorkoutCategories
    with TableInfo<$DriftWorkoutCategoriesTable, DriftWorkoutCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DriftWorkoutCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _workoutIdMeta =
      const VerificationMeta('workoutId');
  @override
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
      'workout_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES workout (id)'));
  @override
  late final GeneratedColumnWithTypeConverter<Category, String> category =
      GeneratedColumn<String>('category', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Category>(
              $DriftWorkoutCategoriesTable.$convertercategory);
  @override
  List<GeneratedColumn> get $columns =>
      [id, updatedAt, createdAt, workoutId, category];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_category';
  @override
  VerificationContext validateIntegrity(
      Insertable<DriftWorkoutCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('workout_id')) {
      context.handle(_workoutIdMeta,
          workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta));
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftWorkoutCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftWorkoutCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      workoutId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}workout_id'])!,
      category: $DriftWorkoutCategoriesTable.$convertercategory.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}category'])!),
    );
  }

  @override
  $DriftWorkoutCategoriesTable createAlias(String alias) {
    return $DriftWorkoutCategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Category, String, String> $convertercategory =
      const EnumNameConverter<Category>(Category.values);
}

class DriftWorkoutCategory extends DataClass
    implements Insertable<DriftWorkoutCategory> {
  final int id;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int workoutId;
  final Category category;
  const DriftWorkoutCategory(
      {required this.id,
      this.updatedAt,
      this.createdAt,
      required this.workoutId,
      required this.category});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['workout_id'] = Variable<int>(workoutId);
    {
      map['category'] = Variable<String>(
          $DriftWorkoutCategoriesTable.$convertercategory.toSql(category));
    }
    return map;
  }

  DriftWorkoutCategoriesCompanion toCompanion(bool nullToAbsent) {
    return DriftWorkoutCategoriesCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      workoutId: Value(workoutId),
      category: Value(category),
    );
  }

  factory DriftWorkoutCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftWorkoutCategory(
      id: serializer.fromJson<int>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      workoutId: serializer.fromJson<int>(json['workoutId']),
      category: $DriftWorkoutCategoriesTable.$convertercategory
          .fromJson(serializer.fromJson<String>(json['category'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'workoutId': serializer.toJson<int>(workoutId),
      'category': serializer.toJson<String>(
          $DriftWorkoutCategoriesTable.$convertercategory.toJson(category)),
    };
  }

  DriftWorkoutCategory copyWith(
          {int? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          int? workoutId,
          Category? category}) =>
      DriftWorkoutCategory(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        workoutId: workoutId ?? this.workoutId,
        category: category ?? this.category,
      );
  DriftWorkoutCategory copyWithCompanion(DriftWorkoutCategoriesCompanion data) {
    return DriftWorkoutCategory(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      category: data.category.present ? data.category.value : this.category,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftWorkoutCategory(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('workoutId: $workoutId, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, createdAt, workoutId, category);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftWorkoutCategory &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt &&
          other.workoutId == this.workoutId &&
          other.category == this.category);
}

class DriftWorkoutCategoriesCompanion
    extends UpdateCompanion<DriftWorkoutCategory> {
  final Value<int> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> createdAt;
  final Value<int> workoutId;
  final Value<Category> category;
  const DriftWorkoutCategoriesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.category = const Value.absent(),
  });
  DriftWorkoutCategoriesCompanion.insert({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    required int workoutId,
    required Category category,
  })  : workoutId = Value(workoutId),
        category = Value(category);
  static Insertable<DriftWorkoutCategory> custom({
    Expression<int>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? workoutId,
    Expression<String>? category,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (workoutId != null) 'workout_id': workoutId,
      if (category != null) 'category': category,
    });
  }

  DriftWorkoutCategoriesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? createdAt,
      Value<int>? workoutId,
      Value<Category>? category}) {
    return DriftWorkoutCategoriesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      workoutId: workoutId ?? this.workoutId,
      category: category ?? this.category,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>($DriftWorkoutCategoriesTable
          .$convertercategory
          .toSql(category.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DriftWorkoutCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('workoutId: $workoutId, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }
}

class $DriftWorkoutExercisesTable extends DriftWorkoutExercises
    with TableInfo<$DriftWorkoutExercisesTable, DriftWorkoutExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DriftWorkoutExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _workoutIdMeta =
      const VerificationMeta('workoutId');
  @override
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
      'workout_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES workout (id)'));
  static const VerificationMeta _exerciseIdentifierMeta =
      const VerificationMeta('exerciseIdentifier');
  @override
  late final GeneratedColumn<String> exerciseIdentifier =
      GeneratedColumn<String>('exercise_identifier', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
      'done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("done" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _setOrderMeta =
      const VerificationMeta('setOrder');
  @override
  late final GeneratedColumn<String> setOrder = GeneratedColumn<String>(
      'set_order', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, updatedAt, createdAt, workoutId, exerciseIdentifier, done, setOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_exercise';
  @override
  VerificationContext validateIntegrity(
      Insertable<DriftWorkoutExercise> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('workout_id')) {
      context.handle(_workoutIdMeta,
          workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta));
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('exercise_identifier')) {
      context.handle(
          _exerciseIdentifierMeta,
          exerciseIdentifier.isAcceptableOrUnknown(
              data['exercise_identifier']!, _exerciseIdentifierMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdentifierMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
          _doneMeta, done.isAcceptableOrUnknown(data['done']!, _doneMeta));
    }
    if (data.containsKey('set_order')) {
      context.handle(_setOrderMeta,
          setOrder.isAcceptableOrUnknown(data['set_order']!, _setOrderMeta));
    } else if (isInserting) {
      context.missing(_setOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftWorkoutExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftWorkoutExercise(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      workoutId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}workout_id'])!,
      exerciseIdentifier: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}exercise_identifier'])!,
      done: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}done'])!,
      setOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}set_order'])!,
    );
  }

  @override
  $DriftWorkoutExercisesTable createAlias(String alias) {
    return $DriftWorkoutExercisesTable(attachedDatabase, alias);
  }
}

class DriftWorkoutExercise extends DataClass
    implements Insertable<DriftWorkoutExercise> {
  final int id;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int workoutId;
  final String exerciseIdentifier;
  final bool done;
  final String setOrder;
  const DriftWorkoutExercise(
      {required this.id,
      this.updatedAt,
      this.createdAt,
      required this.workoutId,
      required this.exerciseIdentifier,
      required this.done,
      required this.setOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['workout_id'] = Variable<int>(workoutId);
    map['exercise_identifier'] = Variable<String>(exerciseIdentifier);
    map['done'] = Variable<bool>(done);
    map['set_order'] = Variable<String>(setOrder);
    return map;
  }

  DriftWorkoutExercisesCompanion toCompanion(bool nullToAbsent) {
    return DriftWorkoutExercisesCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      workoutId: Value(workoutId),
      exerciseIdentifier: Value(exerciseIdentifier),
      done: Value(done),
      setOrder: Value(setOrder),
    );
  }

  factory DriftWorkoutExercise.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftWorkoutExercise(
      id: serializer.fromJson<int>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      workoutId: serializer.fromJson<int>(json['workoutId']),
      exerciseIdentifier:
          serializer.fromJson<String>(json['exerciseIdentifier']),
      done: serializer.fromJson<bool>(json['done']),
      setOrder: serializer.fromJson<String>(json['setOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'workoutId': serializer.toJson<int>(workoutId),
      'exerciseIdentifier': serializer.toJson<String>(exerciseIdentifier),
      'done': serializer.toJson<bool>(done),
      'setOrder': serializer.toJson<String>(setOrder),
    };
  }

  DriftWorkoutExercise copyWith(
          {int? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          int? workoutId,
          String? exerciseIdentifier,
          bool? done,
          String? setOrder}) =>
      DriftWorkoutExercise(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        workoutId: workoutId ?? this.workoutId,
        exerciseIdentifier: exerciseIdentifier ?? this.exerciseIdentifier,
        done: done ?? this.done,
        setOrder: setOrder ?? this.setOrder,
      );
  DriftWorkoutExercise copyWithCompanion(DriftWorkoutExercisesCompanion data) {
    return DriftWorkoutExercise(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      exerciseIdentifier: data.exerciseIdentifier.present
          ? data.exerciseIdentifier.value
          : this.exerciseIdentifier,
      done: data.done.present ? data.done.value : this.done,
      setOrder: data.setOrder.present ? data.setOrder.value : this.setOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftWorkoutExercise(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('workoutId: $workoutId, ')
          ..write('exerciseIdentifier: $exerciseIdentifier, ')
          ..write('done: $done, ')
          ..write('setOrder: $setOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, updatedAt, createdAt, workoutId, exerciseIdentifier, done, setOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftWorkoutExercise &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt &&
          other.workoutId == this.workoutId &&
          other.exerciseIdentifier == this.exerciseIdentifier &&
          other.done == this.done &&
          other.setOrder == this.setOrder);
}

class DriftWorkoutExercisesCompanion
    extends UpdateCompanion<DriftWorkoutExercise> {
  final Value<int> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> createdAt;
  final Value<int> workoutId;
  final Value<String> exerciseIdentifier;
  final Value<bool> done;
  final Value<String> setOrder;
  const DriftWorkoutExercisesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.exerciseIdentifier = const Value.absent(),
    this.done = const Value.absent(),
    this.setOrder = const Value.absent(),
  });
  DriftWorkoutExercisesCompanion.insert({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    required int workoutId,
    required String exerciseIdentifier,
    this.done = const Value.absent(),
    required String setOrder,
  })  : workoutId = Value(workoutId),
        exerciseIdentifier = Value(exerciseIdentifier),
        setOrder = Value(setOrder);
  static Insertable<DriftWorkoutExercise> custom({
    Expression<int>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? workoutId,
    Expression<String>? exerciseIdentifier,
    Expression<bool>? done,
    Expression<String>? setOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (workoutId != null) 'workout_id': workoutId,
      if (exerciseIdentifier != null) 'exercise_identifier': exerciseIdentifier,
      if (done != null) 'done': done,
      if (setOrder != null) 'set_order': setOrder,
    });
  }

  DriftWorkoutExercisesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? createdAt,
      Value<int>? workoutId,
      Value<String>? exerciseIdentifier,
      Value<bool>? done,
      Value<String>? setOrder}) {
    return DriftWorkoutExercisesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      workoutId: workoutId ?? this.workoutId,
      exerciseIdentifier: exerciseIdentifier ?? this.exerciseIdentifier,
      done: done ?? this.done,
      setOrder: setOrder ?? this.setOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    if (exerciseIdentifier.present) {
      map['exercise_identifier'] = Variable<String>(exerciseIdentifier.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (setOrder.present) {
      map['set_order'] = Variable<String>(setOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DriftWorkoutExercisesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('workoutId: $workoutId, ')
          ..write('exerciseIdentifier: $exerciseIdentifier, ')
          ..write('done: $done, ')
          ..write('setOrder: $setOrder')
          ..write(')'))
        .toString();
  }
}

class $DriftWorkoutSetsTable extends DriftWorkoutSets
    with TableInfo<$DriftWorkoutSetsTable, DriftWorkoutSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DriftWorkoutSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _workoutExerciseIdMeta =
      const VerificationMeta('workoutExerciseId');
  @override
  late final GeneratedColumn<int> workoutExerciseId = GeneratedColumn<int>(
      'workout_exercise_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES workout_exercise (id)'));
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
      'reps', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<Duration?, String> time =
      GeneratedColumn<String>('time', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Duration?>($DriftWorkoutSetsTable.$convertertime);
  static const VerificationMeta _distanceMeta =
      const VerificationMeta('distance');
  @override
  late final GeneratedColumn<double> distance = GeneratedColumn<double>(
      'distance', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _calsBurnedMeta =
      const VerificationMeta('calsBurned');
  @override
  late final GeneratedColumn<int> calsBurned = GeneratedColumn<int>(
      'cals_burned', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
      'done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("done" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        updatedAt,
        createdAt,
        workoutExerciseId,
        weight,
        reps,
        time,
        distance,
        calsBurned,
        done
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_set';
  @override
  VerificationContext validateIntegrity(Insertable<DriftWorkoutSet> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('workout_exercise_id')) {
      context.handle(
          _workoutExerciseIdMeta,
          workoutExerciseId.isAcceptableOrUnknown(
              data['workout_exercise_id']!, _workoutExerciseIdMeta));
    } else if (isInserting) {
      context.missing(_workoutExerciseIdMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('reps')) {
      context.handle(
          _repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    }
    if (data.containsKey('distance')) {
      context.handle(_distanceMeta,
          distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta));
    }
    if (data.containsKey('cals_burned')) {
      context.handle(
          _calsBurnedMeta,
          calsBurned.isAcceptableOrUnknown(
              data['cals_burned']!, _calsBurnedMeta));
    }
    if (data.containsKey('done')) {
      context.handle(
          _doneMeta, done.isAcceptableOrUnknown(data['done']!, _doneMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftWorkoutSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftWorkoutSet(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      workoutExerciseId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}workout_exercise_id'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight']),
      reps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps']),
      time: $DriftWorkoutSetsTable.$convertertime.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time'])),
      distance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}distance']),
      calsBurned: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cals_burned']),
      done: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}done'])!,
    );
  }

  @override
  $DriftWorkoutSetsTable createAlias(String alias) {
    return $DriftWorkoutSetsTable(attachedDatabase, alias);
  }

  static TypeConverter<Duration?, String?> $convertertime =
      const DurationConverter();
}

class DriftWorkoutSet extends DataClass implements Insertable<DriftWorkoutSet> {
  final int id;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int workoutExerciseId;
  final double? weight;
  final int? reps;
  final Duration? time;
  final double? distance;
  final int? calsBurned;
  final bool done;
  const DriftWorkoutSet(
      {required this.id,
      this.updatedAt,
      this.createdAt,
      required this.workoutExerciseId,
      this.weight,
      this.reps,
      this.time,
      this.distance,
      this.calsBurned,
      required this.done});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['workout_exercise_id'] = Variable<int>(workoutExerciseId);
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || time != null) {
      map['time'] =
          Variable<String>($DriftWorkoutSetsTable.$convertertime.toSql(time));
    }
    if (!nullToAbsent || distance != null) {
      map['distance'] = Variable<double>(distance);
    }
    if (!nullToAbsent || calsBurned != null) {
      map['cals_burned'] = Variable<int>(calsBurned);
    }
    map['done'] = Variable<bool>(done);
    return map;
  }

  DriftWorkoutSetsCompanion toCompanion(bool nullToAbsent) {
    return DriftWorkoutSetsCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      workoutExerciseId: Value(workoutExerciseId),
      weight:
          weight == null && nullToAbsent ? const Value.absent() : Value(weight),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      time: time == null && nullToAbsent ? const Value.absent() : Value(time),
      distance: distance == null && nullToAbsent
          ? const Value.absent()
          : Value(distance),
      calsBurned: calsBurned == null && nullToAbsent
          ? const Value.absent()
          : Value(calsBurned),
      done: Value(done),
    );
  }

  factory DriftWorkoutSet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftWorkoutSet(
      id: serializer.fromJson<int>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      workoutExerciseId: serializer.fromJson<int>(json['workoutExerciseId']),
      weight: serializer.fromJson<double?>(json['weight']),
      reps: serializer.fromJson<int?>(json['reps']),
      time: serializer.fromJson<Duration?>(json['time']),
      distance: serializer.fromJson<double?>(json['distance']),
      calsBurned: serializer.fromJson<int?>(json['calsBurned']),
      done: serializer.fromJson<bool>(json['done']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'workoutExerciseId': serializer.toJson<int>(workoutExerciseId),
      'weight': serializer.toJson<double?>(weight),
      'reps': serializer.toJson<int?>(reps),
      'time': serializer.toJson<Duration?>(time),
      'distance': serializer.toJson<double?>(distance),
      'calsBurned': serializer.toJson<int?>(calsBurned),
      'done': serializer.toJson<bool>(done),
    };
  }

  DriftWorkoutSet copyWith(
          {int? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          int? workoutExerciseId,
          Value<double?> weight = const Value.absent(),
          Value<int?> reps = const Value.absent(),
          Value<Duration?> time = const Value.absent(),
          Value<double?> distance = const Value.absent(),
          Value<int?> calsBurned = const Value.absent(),
          bool? done}) =>
      DriftWorkoutSet(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        workoutExerciseId: workoutExerciseId ?? this.workoutExerciseId,
        weight: weight.present ? weight.value : this.weight,
        reps: reps.present ? reps.value : this.reps,
        time: time.present ? time.value : this.time,
        distance: distance.present ? distance.value : this.distance,
        calsBurned: calsBurned.present ? calsBurned.value : this.calsBurned,
        done: done ?? this.done,
      );
  DriftWorkoutSet copyWithCompanion(DriftWorkoutSetsCompanion data) {
    return DriftWorkoutSet(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      workoutExerciseId: data.workoutExerciseId.present
          ? data.workoutExerciseId.value
          : this.workoutExerciseId,
      weight: data.weight.present ? data.weight.value : this.weight,
      reps: data.reps.present ? data.reps.value : this.reps,
      time: data.time.present ? data.time.value : this.time,
      distance: data.distance.present ? data.distance.value : this.distance,
      calsBurned:
          data.calsBurned.present ? data.calsBurned.value : this.calsBurned,
      done: data.done.present ? data.done.value : this.done,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftWorkoutSet(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('workoutExerciseId: $workoutExerciseId, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('time: $time, ')
          ..write('distance: $distance, ')
          ..write('calsBurned: $calsBurned, ')
          ..write('done: $done')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, createdAt, workoutExerciseId,
      weight, reps, time, distance, calsBurned, done);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftWorkoutSet &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt &&
          other.workoutExerciseId == this.workoutExerciseId &&
          other.weight == this.weight &&
          other.reps == this.reps &&
          other.time == this.time &&
          other.distance == this.distance &&
          other.calsBurned == this.calsBurned &&
          other.done == this.done);
}

class DriftWorkoutSetsCompanion extends UpdateCompanion<DriftWorkoutSet> {
  final Value<int> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> createdAt;
  final Value<int> workoutExerciseId;
  final Value<double?> weight;
  final Value<int?> reps;
  final Value<Duration?> time;
  final Value<double?> distance;
  final Value<int?> calsBurned;
  final Value<bool> done;
  const DriftWorkoutSetsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.workoutExerciseId = const Value.absent(),
    this.weight = const Value.absent(),
    this.reps = const Value.absent(),
    this.time = const Value.absent(),
    this.distance = const Value.absent(),
    this.calsBurned = const Value.absent(),
    this.done = const Value.absent(),
  });
  DriftWorkoutSetsCompanion.insert({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    required int workoutExerciseId,
    this.weight = const Value.absent(),
    this.reps = const Value.absent(),
    this.time = const Value.absent(),
    this.distance = const Value.absent(),
    this.calsBurned = const Value.absent(),
    this.done = const Value.absent(),
  }) : workoutExerciseId = Value(workoutExerciseId);
  static Insertable<DriftWorkoutSet> custom({
    Expression<int>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? workoutExerciseId,
    Expression<double>? weight,
    Expression<int>? reps,
    Expression<String>? time,
    Expression<double>? distance,
    Expression<int>? calsBurned,
    Expression<bool>? done,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (workoutExerciseId != null) 'workout_exercise_id': workoutExerciseId,
      if (weight != null) 'weight': weight,
      if (reps != null) 'reps': reps,
      if (time != null) 'time': time,
      if (distance != null) 'distance': distance,
      if (calsBurned != null) 'cals_burned': calsBurned,
      if (done != null) 'done': done,
    });
  }

  DriftWorkoutSetsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? createdAt,
      Value<int>? workoutExerciseId,
      Value<double?>? weight,
      Value<int?>? reps,
      Value<Duration?>? time,
      Value<double?>? distance,
      Value<int?>? calsBurned,
      Value<bool>? done}) {
    return DriftWorkoutSetsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      workoutExerciseId: workoutExerciseId ?? this.workoutExerciseId,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      time: time ?? this.time,
      distance: distance ?? this.distance,
      calsBurned: calsBurned ?? this.calsBurned,
      done: done ?? this.done,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (workoutExerciseId.present) {
      map['workout_exercise_id'] = Variable<int>(workoutExerciseId.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(
          $DriftWorkoutSetsTable.$convertertime.toSql(time.value));
    }
    if (distance.present) {
      map['distance'] = Variable<double>(distance.value);
    }
    if (calsBurned.present) {
      map['cals_burned'] = Variable<int>(calsBurned.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DriftWorkoutSetsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('workoutExerciseId: $workoutExerciseId, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('time: $time, ')
          ..write('distance: $distance, ')
          ..write('calsBurned: $calsBurned, ')
          ..write('done: $done')
          ..write(')'))
        .toString();
  }
}

class $DriftSchedulesTable extends DriftSchedules
    with TableInfo<$DriftSchedulesTable, DriftSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DriftSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<ScheduleType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ScheduleType>($DriftSchedulesTable.$convertertype);
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
      'active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'));
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, updatedAt, createdAt, name, type, active, startDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule';
  @override
  VerificationContext validateIntegrity(Insertable<DriftSchedule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta,
          active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    } else if (isInserting) {
      context.missing(_activeMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftSchedule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: $DriftSchedulesTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      active: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}active'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
    );
  }

  @override
  $DriftSchedulesTable createAlias(String alias) {
    return $DriftSchedulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ScheduleType, String, String> $convertertype =
      const EnumNameConverter<ScheduleType>(ScheduleType.values);
}

class DriftSchedule extends DataClass implements Insertable<DriftSchedule> {
  final int id;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final String name;
  final ScheduleType type;
  final bool active;
  final DateTime startDate;
  const DriftSchedule(
      {required this.id,
      this.updatedAt,
      this.createdAt,
      required this.name,
      required this.type,
      required this.active,
      required this.startDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['name'] = Variable<String>(name);
    {
      map['type'] =
          Variable<String>($DriftSchedulesTable.$convertertype.toSql(type));
    }
    map['active'] = Variable<bool>(active);
    map['start_date'] = Variable<DateTime>(startDate);
    return map;
  }

  DriftSchedulesCompanion toCompanion(bool nullToAbsent) {
    return DriftSchedulesCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      name: Value(name),
      type: Value(type),
      active: Value(active),
      startDate: Value(startDate),
    );
  }

  factory DriftSchedule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftSchedule(
      id: serializer.fromJson<int>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      name: serializer.fromJson<String>(json['name']),
      type: $DriftSchedulesTable.$convertertype
          .fromJson(serializer.fromJson<String>(json['type'])),
      active: serializer.fromJson<bool>(json['active']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'name': serializer.toJson<String>(name),
      'type': serializer
          .toJson<String>($DriftSchedulesTable.$convertertype.toJson(type)),
      'active': serializer.toJson<bool>(active),
      'startDate': serializer.toJson<DateTime>(startDate),
    };
  }

  DriftSchedule copyWith(
          {int? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          String? name,
          ScheduleType? type,
          bool? active,
          DateTime? startDate}) =>
      DriftSchedule(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        name: name ?? this.name,
        type: type ?? this.type,
        active: active ?? this.active,
        startDate: startDate ?? this.startDate,
      );
  DriftSchedule copyWithCompanion(DriftSchedulesCompanion data) {
    return DriftSchedule(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      active: data.active.present ? data.active.value : this.active,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftSchedule(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('active: $active, ')
          ..write('startDate: $startDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, createdAt, name, type, active, startDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftSchedule &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt &&
          other.name == this.name &&
          other.type == this.type &&
          other.active == this.active &&
          other.startDate == this.startDate);
}

class DriftSchedulesCompanion extends UpdateCompanion<DriftSchedule> {
  final Value<int> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> createdAt;
  final Value<String> name;
  final Value<ScheduleType> type;
  final Value<bool> active;
  final Value<DateTime> startDate;
  const DriftSchedulesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.active = const Value.absent(),
    this.startDate = const Value.absent(),
  });
  DriftSchedulesCompanion.insert({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String name,
    required ScheduleType type,
    required bool active,
    required DateTime startDate,
  })  : name = Value(name),
        type = Value(type),
        active = Value(active),
        startDate = Value(startDate);
  static Insertable<DriftSchedule> custom({
    Expression<int>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<String>? name,
    Expression<String>? type,
    Expression<bool>? active,
    Expression<DateTime>? startDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (active != null) 'active': active,
      if (startDate != null) 'start_date': startDate,
    });
  }

  DriftSchedulesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? createdAt,
      Value<String>? name,
      Value<ScheduleType>? type,
      Value<bool>? active,
      Value<DateTime>? startDate}) {
    return DriftSchedulesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      type: type ?? this.type,
      active: active ?? this.active,
      startDate: startDate ?? this.startDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
          $DriftSchedulesTable.$convertertype.toSql(type.value));
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DriftSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('active: $active, ')
          ..write('startDate: $startDate')
          ..write(')'))
        .toString();
  }
}

class $DriftScheduleItemsTable extends DriftScheduleItems
    with TableInfo<$DriftScheduleItemsTable, DriftScheduleItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DriftScheduleItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _scheduleIdMeta =
      const VerificationMeta('scheduleId');
  @override
  late final GeneratedColumn<int> scheduleId = GeneratedColumn<int>(
      'schedule_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES schedule (id)'));
  static const VerificationMeta _itemOrderMeta =
      const VerificationMeta('itemOrder');
  @override
  late final GeneratedColumn<int> itemOrder = GeneratedColumn<int>(
      'item_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, updatedAt, createdAt, scheduleId, itemOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_item';
  @override
  VerificationContext validateIntegrity(Insertable<DriftScheduleItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
          _scheduleIdMeta,
          scheduleId.isAcceptableOrUnknown(
              data['schedule_id']!, _scheduleIdMeta));
    } else if (isInserting) {
      context.missing(_scheduleIdMeta);
    }
    if (data.containsKey('item_order')) {
      context.handle(_itemOrderMeta,
          itemOrder.isAcceptableOrUnknown(data['item_order']!, _itemOrderMeta));
    } else if (isInserting) {
      context.missing(_itemOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftScheduleItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftScheduleItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      scheduleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}schedule_id'])!,
      itemOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}item_order'])!,
    );
  }

  @override
  $DriftScheduleItemsTable createAlias(String alias) {
    return $DriftScheduleItemsTable(attachedDatabase, alias);
  }
}

class DriftScheduleItem extends DataClass
    implements Insertable<DriftScheduleItem> {
  final int id;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int scheduleId;
  final int itemOrder;
  const DriftScheduleItem(
      {required this.id,
      this.updatedAt,
      this.createdAt,
      required this.scheduleId,
      required this.itemOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['schedule_id'] = Variable<int>(scheduleId);
    map['item_order'] = Variable<int>(itemOrder);
    return map;
  }

  DriftScheduleItemsCompanion toCompanion(bool nullToAbsent) {
    return DriftScheduleItemsCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      scheduleId: Value(scheduleId),
      itemOrder: Value(itemOrder),
    );
  }

  factory DriftScheduleItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftScheduleItem(
      id: serializer.fromJson<int>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      scheduleId: serializer.fromJson<int>(json['scheduleId']),
      itemOrder: serializer.fromJson<int>(json['itemOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'scheduleId': serializer.toJson<int>(scheduleId),
      'itemOrder': serializer.toJson<int>(itemOrder),
    };
  }

  DriftScheduleItem copyWith(
          {int? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          int? scheduleId,
          int? itemOrder}) =>
      DriftScheduleItem(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        scheduleId: scheduleId ?? this.scheduleId,
        itemOrder: itemOrder ?? this.itemOrder,
      );
  DriftScheduleItem copyWithCompanion(DriftScheduleItemsCompanion data) {
    return DriftScheduleItem(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      scheduleId:
          data.scheduleId.present ? data.scheduleId.value : this.scheduleId,
      itemOrder: data.itemOrder.present ? data.itemOrder.value : this.itemOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftScheduleItem(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('itemOrder: $itemOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, createdAt, scheduleId, itemOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftScheduleItem &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt &&
          other.scheduleId == this.scheduleId &&
          other.itemOrder == this.itemOrder);
}

class DriftScheduleItemsCompanion extends UpdateCompanion<DriftScheduleItem> {
  final Value<int> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> createdAt;
  final Value<int> scheduleId;
  final Value<int> itemOrder;
  const DriftScheduleItemsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.itemOrder = const Value.absent(),
  });
  DriftScheduleItemsCompanion.insert({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    required int scheduleId,
    required int itemOrder,
  })  : scheduleId = Value(scheduleId),
        itemOrder = Value(itemOrder);
  static Insertable<DriftScheduleItem> custom({
    Expression<int>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? scheduleId,
    Expression<int>? itemOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (itemOrder != null) 'item_order': itemOrder,
    });
  }

  DriftScheduleItemsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? createdAt,
      Value<int>? scheduleId,
      Value<int>? itemOrder}) {
    return DriftScheduleItemsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      scheduleId: scheduleId ?? this.scheduleId,
      itemOrder: itemOrder ?? this.itemOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<int>(scheduleId.value);
    }
    if (itemOrder.present) {
      map['item_order'] = Variable<int>(itemOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DriftScheduleItemsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('itemOrder: $itemOrder')
          ..write(')'))
        .toString();
  }
}

class $DriftScheduleCategoriesTable extends DriftScheduleCategories
    with TableInfo<$DriftScheduleCategoriesTable, DriftScheduleCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DriftScheduleCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _scheduleItemIdMeta =
      const VerificationMeta('scheduleItemId');
  @override
  late final GeneratedColumn<int> scheduleItemId = GeneratedColumn<int>(
      'schedule_item_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES schedule_item (id)'));
  @override
  late final GeneratedColumnWithTypeConverter<Category, String> category =
      GeneratedColumn<String>('category', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Category>(
              $DriftScheduleCategoriesTable.$convertercategory);
  @override
  List<GeneratedColumn> get $columns =>
      [id, updatedAt, createdAt, scheduleItemId, category];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_category';
  @override
  VerificationContext validateIntegrity(
      Insertable<DriftScheduleCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('schedule_item_id')) {
      context.handle(
          _scheduleItemIdMeta,
          scheduleItemId.isAcceptableOrUnknown(
              data['schedule_item_id']!, _scheduleItemIdMeta));
    } else if (isInserting) {
      context.missing(_scheduleItemIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftScheduleCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftScheduleCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      scheduleItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}schedule_item_id'])!,
      category: $DriftScheduleCategoriesTable.$convertercategory.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}category'])!),
    );
  }

  @override
  $DriftScheduleCategoriesTable createAlias(String alias) {
    return $DriftScheduleCategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Category, String, String> $convertercategory =
      const EnumNameConverter<Category>(Category.values);
}

class DriftScheduleCategory extends DataClass
    implements Insertable<DriftScheduleCategory> {
  final int id;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int scheduleItemId;
  final Category category;
  const DriftScheduleCategory(
      {required this.id,
      this.updatedAt,
      this.createdAt,
      required this.scheduleItemId,
      required this.category});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['schedule_item_id'] = Variable<int>(scheduleItemId);
    {
      map['category'] = Variable<String>(
          $DriftScheduleCategoriesTable.$convertercategory.toSql(category));
    }
    return map;
  }

  DriftScheduleCategoriesCompanion toCompanion(bool nullToAbsent) {
    return DriftScheduleCategoriesCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      scheduleItemId: Value(scheduleItemId),
      category: Value(category),
    );
  }

  factory DriftScheduleCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftScheduleCategory(
      id: serializer.fromJson<int>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      scheduleItemId: serializer.fromJson<int>(json['scheduleItemId']),
      category: $DriftScheduleCategoriesTable.$convertercategory
          .fromJson(serializer.fromJson<String>(json['category'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'scheduleItemId': serializer.toJson<int>(scheduleItemId),
      'category': serializer.toJson<String>(
          $DriftScheduleCategoriesTable.$convertercategory.toJson(category)),
    };
  }

  DriftScheduleCategory copyWith(
          {int? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          int? scheduleItemId,
          Category? category}) =>
      DriftScheduleCategory(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        scheduleItemId: scheduleItemId ?? this.scheduleItemId,
        category: category ?? this.category,
      );
  DriftScheduleCategory copyWithCompanion(
      DriftScheduleCategoriesCompanion data) {
    return DriftScheduleCategory(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      scheduleItemId: data.scheduleItemId.present
          ? data.scheduleItemId.value
          : this.scheduleItemId,
      category: data.category.present ? data.category.value : this.category,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftScheduleCategory(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('scheduleItemId: $scheduleItemId, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, createdAt, scheduleItemId, category);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftScheduleCategory &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt &&
          other.scheduleItemId == this.scheduleItemId &&
          other.category == this.category);
}

class DriftScheduleCategoriesCompanion
    extends UpdateCompanion<DriftScheduleCategory> {
  final Value<int> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> createdAt;
  final Value<int> scheduleItemId;
  final Value<Category> category;
  const DriftScheduleCategoriesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.scheduleItemId = const Value.absent(),
    this.category = const Value.absent(),
  });
  DriftScheduleCategoriesCompanion.insert({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    required int scheduleItemId,
    required Category category,
  })  : scheduleItemId = Value(scheduleItemId),
        category = Value(category);
  static Insertable<DriftScheduleCategory> custom({
    Expression<int>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? scheduleItemId,
    Expression<String>? category,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (scheduleItemId != null) 'schedule_item_id': scheduleItemId,
      if (category != null) 'category': category,
    });
  }

  DriftScheduleCategoriesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? createdAt,
      Value<int>? scheduleItemId,
      Value<Category>? category}) {
    return DriftScheduleCategoriesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      scheduleItemId: scheduleItemId ?? this.scheduleItemId,
      category: category ?? this.category,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (scheduleItemId.present) {
      map['schedule_item_id'] = Variable<int>(scheduleItemId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>($DriftScheduleCategoriesTable
          .$convertercategory
          .toSql(category.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DriftScheduleCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('scheduleItemId: $scheduleItemId, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DriftSettingsTable driftSettings = $DriftSettingsTable(this);
  late final $DriftBodyweightsTable driftBodyweights =
      $DriftBodyweightsTable(this);
  late final $DriftFlavourTextSchedulesTable driftFlavourTextSchedules =
      $DriftFlavourTextSchedulesTable(this);
  late final $DriftNotesTable driftNotes = $DriftNotesTable(this);
  late final $DriftWorkoutsTable driftWorkouts = $DriftWorkoutsTable(this);
  late final $DriftWorkoutCategoriesTable driftWorkoutCategories =
      $DriftWorkoutCategoriesTable(this);
  late final $DriftWorkoutExercisesTable driftWorkoutExercises =
      $DriftWorkoutExercisesTable(this);
  late final $DriftWorkoutSetsTable driftWorkoutSets =
      $DriftWorkoutSetsTable(this);
  late final $DriftSchedulesTable driftSchedules = $DriftSchedulesTable(this);
  late final $DriftScheduleItemsTable driftScheduleItems =
      $DriftScheduleItemsTable(this);
  late final $DriftScheduleCategoriesTable driftScheduleCategories =
      $DriftScheduleCategoriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        driftSettings,
        driftBodyweights,
        driftFlavourTextSchedules,
        driftNotes,
        driftWorkouts,
        driftWorkoutCategories,
        driftWorkoutExercises,
        driftWorkoutSets,
        driftSchedules,
        driftScheduleItems,
        driftScheduleCategories
      ];
}

typedef $$DriftSettingsTableCreateCompanionBuilder = DriftSettingsCompanion
    Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  required UserTheme theme,
  Value<Duration?> intraSetRestTimer,
});
typedef $$DriftSettingsTableUpdateCompanionBuilder = DriftSettingsCompanion
    Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<UserTheme> theme,
  Value<Duration?> intraSetRestTimer,
});

class $$DriftSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $DriftSettingsTable> {
  $$DriftSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<UserTheme, UserTheme, String> get theme =>
      $composableBuilder(
          column: $table.theme,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Duration?, Duration, String>
      get intraSetRestTimer => $composableBuilder(
          column: $table.intraSetRestTimer,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$DriftSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $DriftSettingsTable> {
  $$DriftSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get theme => $composableBuilder(
      column: $table.theme, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get intraSetRestTimer => $composableBuilder(
      column: $table.intraSetRestTimer,
      builder: (column) => ColumnOrderings(column));
}

class $$DriftSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DriftSettingsTable> {
  $$DriftSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<UserTheme, String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Duration?, String> get intraSetRestTimer =>
      $composableBuilder(
          column: $table.intraSetRestTimer, builder: (column) => column);
}

class $$DriftSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DriftSettingsTable,
    DriftSetting,
    $$DriftSettingsTableFilterComposer,
    $$DriftSettingsTableOrderingComposer,
    $$DriftSettingsTableAnnotationComposer,
    $$DriftSettingsTableCreateCompanionBuilder,
    $$DriftSettingsTableUpdateCompanionBuilder,
    (
      DriftSetting,
      BaseReferences<_$AppDatabase, $DriftSettingsTable, DriftSetting>
    ),
    DriftSetting,
    PrefetchHooks Function()> {
  $$DriftSettingsTableTableManager(_$AppDatabase db, $DriftSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DriftSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DriftSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DriftSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<UserTheme> theme = const Value.absent(),
            Value<Duration?> intraSetRestTimer = const Value.absent(),
          }) =>
              DriftSettingsCompanion(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            theme: theme,
            intraSetRestTimer: intraSetRestTimer,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            required UserTheme theme,
            Value<Duration?> intraSetRestTimer = const Value.absent(),
          }) =>
              DriftSettingsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            theme: theme,
            intraSetRestTimer: intraSetRestTimer,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DriftSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DriftSettingsTable,
    DriftSetting,
    $$DriftSettingsTableFilterComposer,
    $$DriftSettingsTableOrderingComposer,
    $$DriftSettingsTableAnnotationComposer,
    $$DriftSettingsTableCreateCompanionBuilder,
    $$DriftSettingsTableUpdateCompanionBuilder,
    (
      DriftSetting,
      BaseReferences<_$AppDatabase, $DriftSettingsTable, DriftSetting>
    ),
    DriftSetting,
    PrefetchHooks Function()>;
typedef $$DriftBodyweightsTableCreateCompanionBuilder
    = DriftBodyweightsCompanion Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  required DateTime date,
  required double weight,
  required String units,
});
typedef $$DriftBodyweightsTableUpdateCompanionBuilder
    = DriftBodyweightsCompanion Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<DateTime> date,
  Value<double> weight,
  Value<String> units,
});

class $$DriftBodyweightsTableFilterComposer
    extends Composer<_$AppDatabase, $DriftBodyweightsTable> {
  $$DriftBodyweightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get units => $composableBuilder(
      column: $table.units, builder: (column) => ColumnFilters(column));
}

class $$DriftBodyweightsTableOrderingComposer
    extends Composer<_$AppDatabase, $DriftBodyweightsTable> {
  $$DriftBodyweightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get units => $composableBuilder(
      column: $table.units, builder: (column) => ColumnOrderings(column));
}

class $$DriftBodyweightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DriftBodyweightsTable> {
  $$DriftBodyweightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get units =>
      $composableBuilder(column: $table.units, builder: (column) => column);
}

class $$DriftBodyweightsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DriftBodyweightsTable,
    DriftBodyweight,
    $$DriftBodyweightsTableFilterComposer,
    $$DriftBodyweightsTableOrderingComposer,
    $$DriftBodyweightsTableAnnotationComposer,
    $$DriftBodyweightsTableCreateCompanionBuilder,
    $$DriftBodyweightsTableUpdateCompanionBuilder,
    (
      DriftBodyweight,
      BaseReferences<_$AppDatabase, $DriftBodyweightsTable, DriftBodyweight>
    ),
    DriftBodyweight,
    PrefetchHooks Function()> {
  $$DriftBodyweightsTableTableManager(
      _$AppDatabase db, $DriftBodyweightsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DriftBodyweightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DriftBodyweightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DriftBodyweightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<String> units = const Value.absent(),
          }) =>
              DriftBodyweightsCompanion(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            date: date,
            weight: weight,
            units: units,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            required DateTime date,
            required double weight,
            required String units,
          }) =>
              DriftBodyweightsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            date: date,
            weight: weight,
            units: units,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DriftBodyweightsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DriftBodyweightsTable,
    DriftBodyweight,
    $$DriftBodyweightsTableFilterComposer,
    $$DriftBodyweightsTableOrderingComposer,
    $$DriftBodyweightsTableAnnotationComposer,
    $$DriftBodyweightsTableCreateCompanionBuilder,
    $$DriftBodyweightsTableUpdateCompanionBuilder,
    (
      DriftBodyweight,
      BaseReferences<_$AppDatabase, $DriftBodyweightsTable, DriftBodyweight>
    ),
    DriftBodyweight,
    PrefetchHooks Function()>;
typedef $$DriftFlavourTextSchedulesTableCreateCompanionBuilder
    = DriftFlavourTextSchedulesCompanion Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  required int flavourTextId,
  required DateTime date,
  Value<bool> dismissed,
});
typedef $$DriftFlavourTextSchedulesTableUpdateCompanionBuilder
    = DriftFlavourTextSchedulesCompanion Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<int> flavourTextId,
  Value<DateTime> date,
  Value<bool> dismissed,
});

class $$DriftFlavourTextSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $DriftFlavourTextSchedulesTable> {
  $$DriftFlavourTextSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get flavourTextId => $composableBuilder(
      column: $table.flavourTextId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dismissed => $composableBuilder(
      column: $table.dismissed, builder: (column) => ColumnFilters(column));
}

class $$DriftFlavourTextSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $DriftFlavourTextSchedulesTable> {
  $$DriftFlavourTextSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get flavourTextId => $composableBuilder(
      column: $table.flavourTextId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dismissed => $composableBuilder(
      column: $table.dismissed, builder: (column) => ColumnOrderings(column));
}

class $$DriftFlavourTextSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DriftFlavourTextSchedulesTable> {
  $$DriftFlavourTextSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get flavourTextId => $composableBuilder(
      column: $table.flavourTextId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get dismissed =>
      $composableBuilder(column: $table.dismissed, builder: (column) => column);
}

class $$DriftFlavourTextSchedulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DriftFlavourTextSchedulesTable,
    DriftFlavourTextSchedule,
    $$DriftFlavourTextSchedulesTableFilterComposer,
    $$DriftFlavourTextSchedulesTableOrderingComposer,
    $$DriftFlavourTextSchedulesTableAnnotationComposer,
    $$DriftFlavourTextSchedulesTableCreateCompanionBuilder,
    $$DriftFlavourTextSchedulesTableUpdateCompanionBuilder,
    (
      DriftFlavourTextSchedule,
      BaseReferences<_$AppDatabase, $DriftFlavourTextSchedulesTable,
          DriftFlavourTextSchedule>
    ),
    DriftFlavourTextSchedule,
    PrefetchHooks Function()> {
  $$DriftFlavourTextSchedulesTableTableManager(
      _$AppDatabase db, $DriftFlavourTextSchedulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DriftFlavourTextSchedulesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$DriftFlavourTextSchedulesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DriftFlavourTextSchedulesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> flavourTextId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<bool> dismissed = const Value.absent(),
          }) =>
              DriftFlavourTextSchedulesCompanion(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            flavourTextId: flavourTextId,
            date: date,
            dismissed: dismissed,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            required int flavourTextId,
            required DateTime date,
            Value<bool> dismissed = const Value.absent(),
          }) =>
              DriftFlavourTextSchedulesCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            flavourTextId: flavourTextId,
            date: date,
            dismissed: dismissed,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DriftFlavourTextSchedulesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $DriftFlavourTextSchedulesTable,
        DriftFlavourTextSchedule,
        $$DriftFlavourTextSchedulesTableFilterComposer,
        $$DriftFlavourTextSchedulesTableOrderingComposer,
        $$DriftFlavourTextSchedulesTableAnnotationComposer,
        $$DriftFlavourTextSchedulesTableCreateCompanionBuilder,
        $$DriftFlavourTextSchedulesTableUpdateCompanionBuilder,
        (
          DriftFlavourTextSchedule,
          BaseReferences<_$AppDatabase, $DriftFlavourTextSchedulesTable,
              DriftFlavourTextSchedule>
        ),
        DriftFlavourTextSchedule,
        PrefetchHooks Function()>;
typedef $$DriftNotesTableCreateCompanionBuilder = DriftNotesCompanion Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  required String objectId,
  required NoteType type,
  required String note,
});
typedef $$DriftNotesTableUpdateCompanionBuilder = DriftNotesCompanion Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<String> objectId,
  Value<NoteType> type,
  Value<String> note,
});

class $$DriftNotesTableFilterComposer
    extends Composer<_$AppDatabase, $DriftNotesTable> {
  $$DriftNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get objectId => $composableBuilder(
      column: $table.objectId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<NoteType, NoteType, String> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$DriftNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $DriftNotesTable> {
  $$DriftNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get objectId => $composableBuilder(
      column: $table.objectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$DriftNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DriftNotesTable> {
  $$DriftNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get objectId =>
      $composableBuilder(column: $table.objectId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NoteType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$DriftNotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DriftNotesTable,
    DriftNote,
    $$DriftNotesTableFilterComposer,
    $$DriftNotesTableOrderingComposer,
    $$DriftNotesTableAnnotationComposer,
    $$DriftNotesTableCreateCompanionBuilder,
    $$DriftNotesTableUpdateCompanionBuilder,
    (DriftNote, BaseReferences<_$AppDatabase, $DriftNotesTable, DriftNote>),
    DriftNote,
    PrefetchHooks Function()> {
  $$DriftNotesTableTableManager(_$AppDatabase db, $DriftNotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DriftNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DriftNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DriftNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<String> objectId = const Value.absent(),
            Value<NoteType> type = const Value.absent(),
            Value<String> note = const Value.absent(),
          }) =>
              DriftNotesCompanion(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            objectId: objectId,
            type: type,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            required String objectId,
            required NoteType type,
            required String note,
          }) =>
              DriftNotesCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            objectId: objectId,
            type: type,
            note: note,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DriftNotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DriftNotesTable,
    DriftNote,
    $$DriftNotesTableFilterComposer,
    $$DriftNotesTableOrderingComposer,
    $$DriftNotesTableAnnotationComposer,
    $$DriftNotesTableCreateCompanionBuilder,
    $$DriftNotesTableUpdateCompanionBuilder,
    (DriftNote, BaseReferences<_$AppDatabase, $DriftNotesTable, DriftNote>),
    DriftNote,
    PrefetchHooks Function()>;
typedef $$DriftWorkoutsTableCreateCompanionBuilder = DriftWorkoutsCompanion
    Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  required DateTime date,
  Value<DateTime?> endDate,
  required String exerciseOrder,
});
typedef $$DriftWorkoutsTableUpdateCompanionBuilder = DriftWorkoutsCompanion
    Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<DateTime> date,
  Value<DateTime?> endDate,
  Value<String> exerciseOrder,
});

final class $$DriftWorkoutsTableReferences
    extends BaseReferences<_$AppDatabase, $DriftWorkoutsTable, DriftWorkout> {
  $$DriftWorkoutsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DriftWorkoutCategoriesTable,
      List<DriftWorkoutCategory>> _driftWorkoutCategoriesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.driftWorkoutCategories,
          aliasName: $_aliasNameGenerator(
              db.driftWorkouts.id, db.driftWorkoutCategories.workoutId));

  $$DriftWorkoutCategoriesTableProcessedTableManager
      get driftWorkoutCategoriesRefs {
    final manager = $$DriftWorkoutCategoriesTableTableManager(
            $_db, $_db.driftWorkoutCategories)
        .filter((f) => f.workoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_driftWorkoutCategoriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DriftWorkoutExercisesTable,
      List<DriftWorkoutExercise>> _driftWorkoutExercisesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.driftWorkoutExercises,
          aliasName: $_aliasNameGenerator(
              db.driftWorkouts.id, db.driftWorkoutExercises.workoutId));

  $$DriftWorkoutExercisesTableProcessedTableManager
      get driftWorkoutExercisesRefs {
    final manager = $$DriftWorkoutExercisesTableTableManager(
            $_db, $_db.driftWorkoutExercises)
        .filter((f) => f.workoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_driftWorkoutExercisesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DriftWorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $DriftWorkoutsTable> {
  $$DriftWorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exerciseOrder => $composableBuilder(
      column: $table.exerciseOrder, builder: (column) => ColumnFilters(column));

  Expression<bool> driftWorkoutCategoriesRefs(
      Expression<bool> Function($$DriftWorkoutCategoriesTableFilterComposer f)
          f) {
    final $$DriftWorkoutCategoriesTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.driftWorkoutCategories,
            getReferencedColumn: (t) => t.workoutId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DriftWorkoutCategoriesTableFilterComposer(
                  $db: $db,
                  $table: $db.driftWorkoutCategories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> driftWorkoutExercisesRefs(
      Expression<bool> Function($$DriftWorkoutExercisesTableFilterComposer f)
          f) {
    final $$DriftWorkoutExercisesTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.driftWorkoutExercises,
            getReferencedColumn: (t) => t.workoutId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DriftWorkoutExercisesTableFilterComposer(
                  $db: $db,
                  $table: $db.driftWorkoutExercises,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$DriftWorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $DriftWorkoutsTable> {
  $$DriftWorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exerciseOrder => $composableBuilder(
      column: $table.exerciseOrder,
      builder: (column) => ColumnOrderings(column));
}

class $$DriftWorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DriftWorkoutsTable> {
  $$DriftWorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get exerciseOrder => $composableBuilder(
      column: $table.exerciseOrder, builder: (column) => column);

  Expression<T> driftWorkoutCategoriesRefs<T extends Object>(
      Expression<T> Function($$DriftWorkoutCategoriesTableAnnotationComposer a)
          f) {
    final $$DriftWorkoutCategoriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.driftWorkoutCategories,
            getReferencedColumn: (t) => t.workoutId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DriftWorkoutCategoriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.driftWorkoutCategories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> driftWorkoutExercisesRefs<T extends Object>(
      Expression<T> Function($$DriftWorkoutExercisesTableAnnotationComposer a)
          f) {
    final $$DriftWorkoutExercisesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.driftWorkoutExercises,
            getReferencedColumn: (t) => t.workoutId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DriftWorkoutExercisesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.driftWorkoutExercises,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$DriftWorkoutsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DriftWorkoutsTable,
    DriftWorkout,
    $$DriftWorkoutsTableFilterComposer,
    $$DriftWorkoutsTableOrderingComposer,
    $$DriftWorkoutsTableAnnotationComposer,
    $$DriftWorkoutsTableCreateCompanionBuilder,
    $$DriftWorkoutsTableUpdateCompanionBuilder,
    (DriftWorkout, $$DriftWorkoutsTableReferences),
    DriftWorkout,
    PrefetchHooks Function(
        {bool driftWorkoutCategoriesRefs, bool driftWorkoutExercisesRefs})> {
  $$DriftWorkoutsTableTableManager(_$AppDatabase db, $DriftWorkoutsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DriftWorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DriftWorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DriftWorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<String> exerciseOrder = const Value.absent(),
          }) =>
              DriftWorkoutsCompanion(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            date: date,
            endDate: endDate,
            exerciseOrder: exerciseOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            required DateTime date,
            Value<DateTime?> endDate = const Value.absent(),
            required String exerciseOrder,
          }) =>
              DriftWorkoutsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            date: date,
            endDate: endDate,
            exerciseOrder: exerciseOrder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DriftWorkoutsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {driftWorkoutCategoriesRefs = false,
              driftWorkoutExercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (driftWorkoutCategoriesRefs) db.driftWorkoutCategories,
                if (driftWorkoutExercisesRefs) db.driftWorkoutExercises
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (driftWorkoutCategoriesRefs)
                    await $_getPrefetchedData<DriftWorkout, $DriftWorkoutsTable,
                            DriftWorkoutCategory>(
                        currentTable: table,
                        referencedTable: $$DriftWorkoutsTableReferences
                            ._driftWorkoutCategoriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DriftWorkoutsTableReferences(db, table, p0)
                                .driftWorkoutCategoriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workoutId == item.id),
                        typedResults: items),
                  if (driftWorkoutExercisesRefs)
                    await $_getPrefetchedData<DriftWorkout, $DriftWorkoutsTable,
                            DriftWorkoutExercise>(
                        currentTable: table,
                        referencedTable: $$DriftWorkoutsTableReferences
                            ._driftWorkoutExercisesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DriftWorkoutsTableReferences(db, table, p0)
                                .driftWorkoutExercisesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workoutId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DriftWorkoutsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DriftWorkoutsTable,
    DriftWorkout,
    $$DriftWorkoutsTableFilterComposer,
    $$DriftWorkoutsTableOrderingComposer,
    $$DriftWorkoutsTableAnnotationComposer,
    $$DriftWorkoutsTableCreateCompanionBuilder,
    $$DriftWorkoutsTableUpdateCompanionBuilder,
    (DriftWorkout, $$DriftWorkoutsTableReferences),
    DriftWorkout,
    PrefetchHooks Function(
        {bool driftWorkoutCategoriesRefs, bool driftWorkoutExercisesRefs})>;
typedef $$DriftWorkoutCategoriesTableCreateCompanionBuilder
    = DriftWorkoutCategoriesCompanion Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  required int workoutId,
  required Category category,
});
typedef $$DriftWorkoutCategoriesTableUpdateCompanionBuilder
    = DriftWorkoutCategoriesCompanion Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<int> workoutId,
  Value<Category> category,
});

final class $$DriftWorkoutCategoriesTableReferences extends BaseReferences<
    _$AppDatabase, $DriftWorkoutCategoriesTable, DriftWorkoutCategory> {
  $$DriftWorkoutCategoriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DriftWorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.driftWorkouts.createAlias($_aliasNameGenerator(
          db.driftWorkoutCategories.workoutId, db.driftWorkouts.id));

  $$DriftWorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<int>('workout_id')!;

    final manager = $$DriftWorkoutsTableTableManager($_db, $_db.driftWorkouts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DriftWorkoutCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $DriftWorkoutCategoriesTable> {
  $$DriftWorkoutCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Category, Category, String> get category =>
      $composableBuilder(
          column: $table.category,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$DriftWorkoutsTableFilterComposer get workoutId {
    final $$DriftWorkoutsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.driftWorkouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DriftWorkoutsTableFilterComposer(
              $db: $db,
              $table: $db.driftWorkouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DriftWorkoutCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DriftWorkoutCategoriesTable> {
  $$DriftWorkoutCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  $$DriftWorkoutsTableOrderingComposer get workoutId {
    final $$DriftWorkoutsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.driftWorkouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DriftWorkoutsTableOrderingComposer(
              $db: $db,
              $table: $db.driftWorkouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DriftWorkoutCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DriftWorkoutCategoriesTable> {
  $$DriftWorkoutCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Category, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  $$DriftWorkoutsTableAnnotationComposer get workoutId {
    final $$DriftWorkoutsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.driftWorkouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DriftWorkoutsTableAnnotationComposer(
              $db: $db,
              $table: $db.driftWorkouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DriftWorkoutCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DriftWorkoutCategoriesTable,
    DriftWorkoutCategory,
    $$DriftWorkoutCategoriesTableFilterComposer,
    $$DriftWorkoutCategoriesTableOrderingComposer,
    $$DriftWorkoutCategoriesTableAnnotationComposer,
    $$DriftWorkoutCategoriesTableCreateCompanionBuilder,
    $$DriftWorkoutCategoriesTableUpdateCompanionBuilder,
    (DriftWorkoutCategory, $$DriftWorkoutCategoriesTableReferences),
    DriftWorkoutCategory,
    PrefetchHooks Function({bool workoutId})> {
  $$DriftWorkoutCategoriesTableTableManager(
      _$AppDatabase db, $DriftWorkoutCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DriftWorkoutCategoriesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$DriftWorkoutCategoriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DriftWorkoutCategoriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> workoutId = const Value.absent(),
            Value<Category> category = const Value.absent(),
          }) =>
              DriftWorkoutCategoriesCompanion(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            workoutId: workoutId,
            category: category,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            required int workoutId,
            required Category category,
          }) =>
              DriftWorkoutCategoriesCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            workoutId: workoutId,
            category: category,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DriftWorkoutCategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workoutId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (workoutId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workoutId,
                    referencedTable: $$DriftWorkoutCategoriesTableReferences
                        ._workoutIdTable(db),
                    referencedColumn: $$DriftWorkoutCategoriesTableReferences
                        ._workoutIdTable(db)
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
        ));
}

typedef $$DriftWorkoutCategoriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $DriftWorkoutCategoriesTable,
        DriftWorkoutCategory,
        $$DriftWorkoutCategoriesTableFilterComposer,
        $$DriftWorkoutCategoriesTableOrderingComposer,
        $$DriftWorkoutCategoriesTableAnnotationComposer,
        $$DriftWorkoutCategoriesTableCreateCompanionBuilder,
        $$DriftWorkoutCategoriesTableUpdateCompanionBuilder,
        (DriftWorkoutCategory, $$DriftWorkoutCategoriesTableReferences),
        DriftWorkoutCategory,
        PrefetchHooks Function({bool workoutId})>;
typedef $$DriftWorkoutExercisesTableCreateCompanionBuilder
    = DriftWorkoutExercisesCompanion Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  required int workoutId,
  required String exerciseIdentifier,
  Value<bool> done,
  required String setOrder,
});
typedef $$DriftWorkoutExercisesTableUpdateCompanionBuilder
    = DriftWorkoutExercisesCompanion Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<int> workoutId,
  Value<String> exerciseIdentifier,
  Value<bool> done,
  Value<String> setOrder,
});

final class $$DriftWorkoutExercisesTableReferences extends BaseReferences<
    _$AppDatabase, $DriftWorkoutExercisesTable, DriftWorkoutExercise> {
  $$DriftWorkoutExercisesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DriftWorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.driftWorkouts.createAlias($_aliasNameGenerator(
          db.driftWorkoutExercises.workoutId, db.driftWorkouts.id));

  $$DriftWorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<int>('workout_id')!;

    final manager = $$DriftWorkoutsTableTableManager($_db, $_db.driftWorkouts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$DriftWorkoutSetsTable, List<DriftWorkoutSet>>
      _driftWorkoutSetsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.driftWorkoutSets,
              aliasName: $_aliasNameGenerator(db.driftWorkoutExercises.id,
                  db.driftWorkoutSets.workoutExerciseId));

  $$DriftWorkoutSetsTableProcessedTableManager get driftWorkoutSetsRefs {
    final manager =
        $$DriftWorkoutSetsTableTableManager($_db, $_db.driftWorkoutSets).filter(
            (f) => f.workoutExerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_driftWorkoutSetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DriftWorkoutExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $DriftWorkoutExercisesTable> {
  $$DriftWorkoutExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exerciseIdentifier => $composableBuilder(
      column: $table.exerciseIdentifier,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get done => $composableBuilder(
      column: $table.done, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get setOrder => $composableBuilder(
      column: $table.setOrder, builder: (column) => ColumnFilters(column));

  $$DriftWorkoutsTableFilterComposer get workoutId {
    final $$DriftWorkoutsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.driftWorkouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DriftWorkoutsTableFilterComposer(
              $db: $db,
              $table: $db.driftWorkouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> driftWorkoutSetsRefs(
      Expression<bool> Function($$DriftWorkoutSetsTableFilterComposer f) f) {
    final $$DriftWorkoutSetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.driftWorkoutSets,
        getReferencedColumn: (t) => t.workoutExerciseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DriftWorkoutSetsTableFilterComposer(
              $db: $db,
              $table: $db.driftWorkoutSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DriftWorkoutExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $DriftWorkoutExercisesTable> {
  $$DriftWorkoutExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exerciseIdentifier => $composableBuilder(
      column: $table.exerciseIdentifier,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get done => $composableBuilder(
      column: $table.done, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get setOrder => $composableBuilder(
      column: $table.setOrder, builder: (column) => ColumnOrderings(column));

  $$DriftWorkoutsTableOrderingComposer get workoutId {
    final $$DriftWorkoutsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.driftWorkouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DriftWorkoutsTableOrderingComposer(
              $db: $db,
              $table: $db.driftWorkouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DriftWorkoutExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DriftWorkoutExercisesTable> {
  $$DriftWorkoutExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get exerciseIdentifier => $composableBuilder(
      column: $table.exerciseIdentifier, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<String> get setOrder =>
      $composableBuilder(column: $table.setOrder, builder: (column) => column);

  $$DriftWorkoutsTableAnnotationComposer get workoutId {
    final $$DriftWorkoutsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.driftWorkouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DriftWorkoutsTableAnnotationComposer(
              $db: $db,
              $table: $db.driftWorkouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> driftWorkoutSetsRefs<T extends Object>(
      Expression<T> Function($$DriftWorkoutSetsTableAnnotationComposer a) f) {
    final $$DriftWorkoutSetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.driftWorkoutSets,
        getReferencedColumn: (t) => t.workoutExerciseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DriftWorkoutSetsTableAnnotationComposer(
              $db: $db,
              $table: $db.driftWorkoutSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DriftWorkoutExercisesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DriftWorkoutExercisesTable,
    DriftWorkoutExercise,
    $$DriftWorkoutExercisesTableFilterComposer,
    $$DriftWorkoutExercisesTableOrderingComposer,
    $$DriftWorkoutExercisesTableAnnotationComposer,
    $$DriftWorkoutExercisesTableCreateCompanionBuilder,
    $$DriftWorkoutExercisesTableUpdateCompanionBuilder,
    (DriftWorkoutExercise, $$DriftWorkoutExercisesTableReferences),
    DriftWorkoutExercise,
    PrefetchHooks Function({bool workoutId, bool driftWorkoutSetsRefs})> {
  $$DriftWorkoutExercisesTableTableManager(
      _$AppDatabase db, $DriftWorkoutExercisesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DriftWorkoutExercisesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$DriftWorkoutExercisesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DriftWorkoutExercisesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> workoutId = const Value.absent(),
            Value<String> exerciseIdentifier = const Value.absent(),
            Value<bool> done = const Value.absent(),
            Value<String> setOrder = const Value.absent(),
          }) =>
              DriftWorkoutExercisesCompanion(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            workoutId: workoutId,
            exerciseIdentifier: exerciseIdentifier,
            done: done,
            setOrder: setOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            required int workoutId,
            required String exerciseIdentifier,
            Value<bool> done = const Value.absent(),
            required String setOrder,
          }) =>
              DriftWorkoutExercisesCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            workoutId: workoutId,
            exerciseIdentifier: exerciseIdentifier,
            done: done,
            setOrder: setOrder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DriftWorkoutExercisesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {workoutId = false, driftWorkoutSetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (driftWorkoutSetsRefs) db.driftWorkoutSets
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (workoutId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workoutId,
                    referencedTable: $$DriftWorkoutExercisesTableReferences
                        ._workoutIdTable(db),
                    referencedColumn: $$DriftWorkoutExercisesTableReferences
                        ._workoutIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (driftWorkoutSetsRefs)
                    await $_getPrefetchedData<DriftWorkoutExercise,
                            $DriftWorkoutExercisesTable, DriftWorkoutSet>(
                        currentTable: table,
                        referencedTable: $$DriftWorkoutExercisesTableReferences
                            ._driftWorkoutSetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DriftWorkoutExercisesTableReferences(
                                    db, table, p0)
                                .driftWorkoutSetsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workoutExerciseId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DriftWorkoutExercisesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $DriftWorkoutExercisesTable,
        DriftWorkoutExercise,
        $$DriftWorkoutExercisesTableFilterComposer,
        $$DriftWorkoutExercisesTableOrderingComposer,
        $$DriftWorkoutExercisesTableAnnotationComposer,
        $$DriftWorkoutExercisesTableCreateCompanionBuilder,
        $$DriftWorkoutExercisesTableUpdateCompanionBuilder,
        (DriftWorkoutExercise, $$DriftWorkoutExercisesTableReferences),
        DriftWorkoutExercise,
        PrefetchHooks Function({bool workoutId, bool driftWorkoutSetsRefs})>;
typedef $$DriftWorkoutSetsTableCreateCompanionBuilder
    = DriftWorkoutSetsCompanion Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  required int workoutExerciseId,
  Value<double?> weight,
  Value<int?> reps,
  Value<Duration?> time,
  Value<double?> distance,
  Value<int?> calsBurned,
  Value<bool> done,
});
typedef $$DriftWorkoutSetsTableUpdateCompanionBuilder
    = DriftWorkoutSetsCompanion Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<int> workoutExerciseId,
  Value<double?> weight,
  Value<int?> reps,
  Value<Duration?> time,
  Value<double?> distance,
  Value<int?> calsBurned,
  Value<bool> done,
});

final class $$DriftWorkoutSetsTableReferences extends BaseReferences<
    _$AppDatabase, $DriftWorkoutSetsTable, DriftWorkoutSet> {
  $$DriftWorkoutSetsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DriftWorkoutExercisesTable _workoutExerciseIdTable(
          _$AppDatabase db) =>
      db.driftWorkoutExercises.createAlias($_aliasNameGenerator(
          db.driftWorkoutSets.workoutExerciseId, db.driftWorkoutExercises.id));

  $$DriftWorkoutExercisesTableProcessedTableManager get workoutExerciseId {
    final $_column = $_itemColumn<int>('workout_exercise_id')!;

    final manager = $$DriftWorkoutExercisesTableTableManager(
            $_db, $_db.driftWorkoutExercises)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DriftWorkoutSetsTableFilterComposer
    extends Composer<_$AppDatabase, $DriftWorkoutSetsTable> {
  $$DriftWorkoutSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Duration?, Duration, String> get time =>
      $composableBuilder(
          column: $table.time,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get calsBurned => $composableBuilder(
      column: $table.calsBurned, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get done => $composableBuilder(
      column: $table.done, builder: (column) => ColumnFilters(column));

  $$DriftWorkoutExercisesTableFilterComposer get workoutExerciseId {
    final $$DriftWorkoutExercisesTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.workoutExerciseId,
            referencedTable: $db.driftWorkoutExercises,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DriftWorkoutExercisesTableFilterComposer(
                  $db: $db,
                  $table: $db.driftWorkoutExercises,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$DriftWorkoutSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $DriftWorkoutSetsTable> {
  $$DriftWorkoutSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get calsBurned => $composableBuilder(
      column: $table.calsBurned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get done => $composableBuilder(
      column: $table.done, builder: (column) => ColumnOrderings(column));

  $$DriftWorkoutExercisesTableOrderingComposer get workoutExerciseId {
    final $$DriftWorkoutExercisesTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.workoutExerciseId,
            referencedTable: $db.driftWorkoutExercises,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DriftWorkoutExercisesTableOrderingComposer(
                  $db: $db,
                  $table: $db.driftWorkoutExercises,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$DriftWorkoutSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DriftWorkoutSetsTable> {
  $$DriftWorkoutSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Duration?, String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<double> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);

  GeneratedColumn<int> get calsBurned => $composableBuilder(
      column: $table.calsBurned, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  $$DriftWorkoutExercisesTableAnnotationComposer get workoutExerciseId {
    final $$DriftWorkoutExercisesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.workoutExerciseId,
            referencedTable: $db.driftWorkoutExercises,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DriftWorkoutExercisesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.driftWorkoutExercises,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$DriftWorkoutSetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DriftWorkoutSetsTable,
    DriftWorkoutSet,
    $$DriftWorkoutSetsTableFilterComposer,
    $$DriftWorkoutSetsTableOrderingComposer,
    $$DriftWorkoutSetsTableAnnotationComposer,
    $$DriftWorkoutSetsTableCreateCompanionBuilder,
    $$DriftWorkoutSetsTableUpdateCompanionBuilder,
    (DriftWorkoutSet, $$DriftWorkoutSetsTableReferences),
    DriftWorkoutSet,
    PrefetchHooks Function({bool workoutExerciseId})> {
  $$DriftWorkoutSetsTableTableManager(
      _$AppDatabase db, $DriftWorkoutSetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DriftWorkoutSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DriftWorkoutSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DriftWorkoutSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> workoutExerciseId = const Value.absent(),
            Value<double?> weight = const Value.absent(),
            Value<int?> reps = const Value.absent(),
            Value<Duration?> time = const Value.absent(),
            Value<double?> distance = const Value.absent(),
            Value<int?> calsBurned = const Value.absent(),
            Value<bool> done = const Value.absent(),
          }) =>
              DriftWorkoutSetsCompanion(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            workoutExerciseId: workoutExerciseId,
            weight: weight,
            reps: reps,
            time: time,
            distance: distance,
            calsBurned: calsBurned,
            done: done,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            required int workoutExerciseId,
            Value<double?> weight = const Value.absent(),
            Value<int?> reps = const Value.absent(),
            Value<Duration?> time = const Value.absent(),
            Value<double?> distance = const Value.absent(),
            Value<int?> calsBurned = const Value.absent(),
            Value<bool> done = const Value.absent(),
          }) =>
              DriftWorkoutSetsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            workoutExerciseId: workoutExerciseId,
            weight: weight,
            reps: reps,
            time: time,
            distance: distance,
            calsBurned: calsBurned,
            done: done,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DriftWorkoutSetsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workoutExerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (workoutExerciseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workoutExerciseId,
                    referencedTable: $$DriftWorkoutSetsTableReferences
                        ._workoutExerciseIdTable(db),
                    referencedColumn: $$DriftWorkoutSetsTableReferences
                        ._workoutExerciseIdTable(db)
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
        ));
}

typedef $$DriftWorkoutSetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DriftWorkoutSetsTable,
    DriftWorkoutSet,
    $$DriftWorkoutSetsTableFilterComposer,
    $$DriftWorkoutSetsTableOrderingComposer,
    $$DriftWorkoutSetsTableAnnotationComposer,
    $$DriftWorkoutSetsTableCreateCompanionBuilder,
    $$DriftWorkoutSetsTableUpdateCompanionBuilder,
    (DriftWorkoutSet, $$DriftWorkoutSetsTableReferences),
    DriftWorkoutSet,
    PrefetchHooks Function({bool workoutExerciseId})>;
typedef $$DriftSchedulesTableCreateCompanionBuilder = DriftSchedulesCompanion
    Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  required String name,
  required ScheduleType type,
  required bool active,
  required DateTime startDate,
});
typedef $$DriftSchedulesTableUpdateCompanionBuilder = DriftSchedulesCompanion
    Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<String> name,
  Value<ScheduleType> type,
  Value<bool> active,
  Value<DateTime> startDate,
});

final class $$DriftSchedulesTableReferences
    extends BaseReferences<_$AppDatabase, $DriftSchedulesTable, DriftSchedule> {
  $$DriftSchedulesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DriftScheduleItemsTable, List<DriftScheduleItem>>
      _driftScheduleItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.driftScheduleItems,
              aliasName: $_aliasNameGenerator(
                  db.driftSchedules.id, db.driftScheduleItems.scheduleId));

  $$DriftScheduleItemsTableProcessedTableManager get driftScheduleItemsRefs {
    final manager =
        $$DriftScheduleItemsTableTableManager($_db, $_db.driftScheduleItems)
            .filter((f) => f.scheduleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_driftScheduleItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DriftSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $DriftSchedulesTable> {
  $$DriftSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ScheduleType, ScheduleType, String> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  Expression<bool> driftScheduleItemsRefs(
      Expression<bool> Function($$DriftScheduleItemsTableFilterComposer f) f) {
    final $$DriftScheduleItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.driftScheduleItems,
        getReferencedColumn: (t) => t.scheduleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DriftScheduleItemsTableFilterComposer(
              $db: $db,
              $table: $db.driftScheduleItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DriftSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $DriftSchedulesTable> {
  $$DriftSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));
}

class $$DriftSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DriftSchedulesTable> {
  $$DriftSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ScheduleType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  Expression<T> driftScheduleItemsRefs<T extends Object>(
      Expression<T> Function($$DriftScheduleItemsTableAnnotationComposer a) f) {
    final $$DriftScheduleItemsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.driftScheduleItems,
            getReferencedColumn: (t) => t.scheduleId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DriftScheduleItemsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.driftScheduleItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$DriftSchedulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DriftSchedulesTable,
    DriftSchedule,
    $$DriftSchedulesTableFilterComposer,
    $$DriftSchedulesTableOrderingComposer,
    $$DriftSchedulesTableAnnotationComposer,
    $$DriftSchedulesTableCreateCompanionBuilder,
    $$DriftSchedulesTableUpdateCompanionBuilder,
    (DriftSchedule, $$DriftSchedulesTableReferences),
    DriftSchedule,
    PrefetchHooks Function({bool driftScheduleItemsRefs})> {
  $$DriftSchedulesTableTableManager(
      _$AppDatabase db, $DriftSchedulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DriftSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DriftSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DriftSchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<ScheduleType> type = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
          }) =>
              DriftSchedulesCompanion(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            name: name,
            type: type,
            active: active,
            startDate: startDate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            required String name,
            required ScheduleType type,
            required bool active,
            required DateTime startDate,
          }) =>
              DriftSchedulesCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            name: name,
            type: type,
            active: active,
            startDate: startDate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DriftSchedulesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({driftScheduleItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (driftScheduleItemsRefs) db.driftScheduleItems
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (driftScheduleItemsRefs)
                    await $_getPrefetchedData<DriftSchedule,
                            $DriftSchedulesTable, DriftScheduleItem>(
                        currentTable: table,
                        referencedTable: $$DriftSchedulesTableReferences
                            ._driftScheduleItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DriftSchedulesTableReferences(db, table, p0)
                                .driftScheduleItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.scheduleId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DriftSchedulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DriftSchedulesTable,
    DriftSchedule,
    $$DriftSchedulesTableFilterComposer,
    $$DriftSchedulesTableOrderingComposer,
    $$DriftSchedulesTableAnnotationComposer,
    $$DriftSchedulesTableCreateCompanionBuilder,
    $$DriftSchedulesTableUpdateCompanionBuilder,
    (DriftSchedule, $$DriftSchedulesTableReferences),
    DriftSchedule,
    PrefetchHooks Function({bool driftScheduleItemsRefs})>;
typedef $$DriftScheduleItemsTableCreateCompanionBuilder
    = DriftScheduleItemsCompanion Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  required int scheduleId,
  required int itemOrder,
});
typedef $$DriftScheduleItemsTableUpdateCompanionBuilder
    = DriftScheduleItemsCompanion Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<int> scheduleId,
  Value<int> itemOrder,
});

final class $$DriftScheduleItemsTableReferences extends BaseReferences<
    _$AppDatabase, $DriftScheduleItemsTable, DriftScheduleItem> {
  $$DriftScheduleItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DriftSchedulesTable _scheduleIdTable(_$AppDatabase db) =>
      db.driftSchedules.createAlias($_aliasNameGenerator(
          db.driftScheduleItems.scheduleId, db.driftSchedules.id));

  $$DriftSchedulesTableProcessedTableManager get scheduleId {
    final $_column = $_itemColumn<int>('schedule_id')!;

    final manager = $$DriftSchedulesTableTableManager($_db, $_db.driftSchedules)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$DriftScheduleCategoriesTable,
      List<DriftScheduleCategory>> _driftScheduleCategoriesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.driftScheduleCategories,
          aliasName: $_aliasNameGenerator(db.driftScheduleItems.id,
              db.driftScheduleCategories.scheduleItemId));

  $$DriftScheduleCategoriesTableProcessedTableManager
      get driftScheduleCategoriesRefs {
    final manager = $$DriftScheduleCategoriesTableTableManager(
            $_db, $_db.driftScheduleCategories)
        .filter((f) => f.scheduleItemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_driftScheduleCategoriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DriftScheduleItemsTableFilterComposer
    extends Composer<_$AppDatabase, $DriftScheduleItemsTable> {
  $$DriftScheduleItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get itemOrder => $composableBuilder(
      column: $table.itemOrder, builder: (column) => ColumnFilters(column));

  $$DriftSchedulesTableFilterComposer get scheduleId {
    final $$DriftSchedulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduleId,
        referencedTable: $db.driftSchedules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DriftSchedulesTableFilterComposer(
              $db: $db,
              $table: $db.driftSchedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> driftScheduleCategoriesRefs(
      Expression<bool> Function($$DriftScheduleCategoriesTableFilterComposer f)
          f) {
    final $$DriftScheduleCategoriesTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.driftScheduleCategories,
            getReferencedColumn: (t) => t.scheduleItemId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DriftScheduleCategoriesTableFilterComposer(
                  $db: $db,
                  $table: $db.driftScheduleCategories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$DriftScheduleItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $DriftScheduleItemsTable> {
  $$DriftScheduleItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get itemOrder => $composableBuilder(
      column: $table.itemOrder, builder: (column) => ColumnOrderings(column));

  $$DriftSchedulesTableOrderingComposer get scheduleId {
    final $$DriftSchedulesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduleId,
        referencedTable: $db.driftSchedules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DriftSchedulesTableOrderingComposer(
              $db: $db,
              $table: $db.driftSchedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DriftScheduleItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DriftScheduleItemsTable> {
  $$DriftScheduleItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get itemOrder =>
      $composableBuilder(column: $table.itemOrder, builder: (column) => column);

  $$DriftSchedulesTableAnnotationComposer get scheduleId {
    final $$DriftSchedulesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduleId,
        referencedTable: $db.driftSchedules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DriftSchedulesTableAnnotationComposer(
              $db: $db,
              $table: $db.driftSchedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> driftScheduleCategoriesRefs<T extends Object>(
      Expression<T> Function($$DriftScheduleCategoriesTableAnnotationComposer a)
          f) {
    final $$DriftScheduleCategoriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.driftScheduleCategories,
            getReferencedColumn: (t) => t.scheduleItemId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DriftScheduleCategoriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.driftScheduleCategories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$DriftScheduleItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DriftScheduleItemsTable,
    DriftScheduleItem,
    $$DriftScheduleItemsTableFilterComposer,
    $$DriftScheduleItemsTableOrderingComposer,
    $$DriftScheduleItemsTableAnnotationComposer,
    $$DriftScheduleItemsTableCreateCompanionBuilder,
    $$DriftScheduleItemsTableUpdateCompanionBuilder,
    (DriftScheduleItem, $$DriftScheduleItemsTableReferences),
    DriftScheduleItem,
    PrefetchHooks Function(
        {bool scheduleId, bool driftScheduleCategoriesRefs})> {
  $$DriftScheduleItemsTableTableManager(
      _$AppDatabase db, $DriftScheduleItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DriftScheduleItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DriftScheduleItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DriftScheduleItemsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> scheduleId = const Value.absent(),
            Value<int> itemOrder = const Value.absent(),
          }) =>
              DriftScheduleItemsCompanion(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            scheduleId: scheduleId,
            itemOrder: itemOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            required int scheduleId,
            required int itemOrder,
          }) =>
              DriftScheduleItemsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            scheduleId: scheduleId,
            itemOrder: itemOrder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DriftScheduleItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {scheduleId = false, driftScheduleCategoriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (driftScheduleCategoriesRefs) db.driftScheduleCategories
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (scheduleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.scheduleId,
                    referencedTable: $$DriftScheduleItemsTableReferences
                        ._scheduleIdTable(db),
                    referencedColumn: $$DriftScheduleItemsTableReferences
                        ._scheduleIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (driftScheduleCategoriesRefs)
                    await $_getPrefetchedData<DriftScheduleItem,
                            $DriftScheduleItemsTable, DriftScheduleCategory>(
                        currentTable: table,
                        referencedTable: $$DriftScheduleItemsTableReferences
                            ._driftScheduleCategoriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DriftScheduleItemsTableReferences(db, table, p0)
                                .driftScheduleCategoriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.scheduleItemId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DriftScheduleItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DriftScheduleItemsTable,
    DriftScheduleItem,
    $$DriftScheduleItemsTableFilterComposer,
    $$DriftScheduleItemsTableOrderingComposer,
    $$DriftScheduleItemsTableAnnotationComposer,
    $$DriftScheduleItemsTableCreateCompanionBuilder,
    $$DriftScheduleItemsTableUpdateCompanionBuilder,
    (DriftScheduleItem, $$DriftScheduleItemsTableReferences),
    DriftScheduleItem,
    PrefetchHooks Function(
        {bool scheduleId, bool driftScheduleCategoriesRefs})>;
typedef $$DriftScheduleCategoriesTableCreateCompanionBuilder
    = DriftScheduleCategoriesCompanion Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  required int scheduleItemId,
  required Category category,
});
typedef $$DriftScheduleCategoriesTableUpdateCompanionBuilder
    = DriftScheduleCategoriesCompanion Function({
  Value<int> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<int> scheduleItemId,
  Value<Category> category,
});

final class $$DriftScheduleCategoriesTableReferences extends BaseReferences<
    _$AppDatabase, $DriftScheduleCategoriesTable, DriftScheduleCategory> {
  $$DriftScheduleCategoriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DriftScheduleItemsTable _scheduleItemIdTable(_$AppDatabase db) =>
      db.driftScheduleItems.createAlias($_aliasNameGenerator(
          db.driftScheduleCategories.scheduleItemId, db.driftScheduleItems.id));

  $$DriftScheduleItemsTableProcessedTableManager get scheduleItemId {
    final $_column = $_itemColumn<int>('schedule_item_id')!;

    final manager =
        $$DriftScheduleItemsTableTableManager($_db, $_db.driftScheduleItems)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduleItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DriftScheduleCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $DriftScheduleCategoriesTable> {
  $$DriftScheduleCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Category, Category, String> get category =>
      $composableBuilder(
          column: $table.category,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$DriftScheduleItemsTableFilterComposer get scheduleItemId {
    final $$DriftScheduleItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduleItemId,
        referencedTable: $db.driftScheduleItems,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DriftScheduleItemsTableFilterComposer(
              $db: $db,
              $table: $db.driftScheduleItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DriftScheduleCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DriftScheduleCategoriesTable> {
  $$DriftScheduleCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  $$DriftScheduleItemsTableOrderingComposer get scheduleItemId {
    final $$DriftScheduleItemsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduleItemId,
        referencedTable: $db.driftScheduleItems,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DriftScheduleItemsTableOrderingComposer(
              $db: $db,
              $table: $db.driftScheduleItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DriftScheduleCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DriftScheduleCategoriesTable> {
  $$DriftScheduleCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Category, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  $$DriftScheduleItemsTableAnnotationComposer get scheduleItemId {
    final $$DriftScheduleItemsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.scheduleItemId,
            referencedTable: $db.driftScheduleItems,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DriftScheduleItemsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.driftScheduleItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$DriftScheduleCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DriftScheduleCategoriesTable,
    DriftScheduleCategory,
    $$DriftScheduleCategoriesTableFilterComposer,
    $$DriftScheduleCategoriesTableOrderingComposer,
    $$DriftScheduleCategoriesTableAnnotationComposer,
    $$DriftScheduleCategoriesTableCreateCompanionBuilder,
    $$DriftScheduleCategoriesTableUpdateCompanionBuilder,
    (DriftScheduleCategory, $$DriftScheduleCategoriesTableReferences),
    DriftScheduleCategory,
    PrefetchHooks Function({bool scheduleItemId})> {
  $$DriftScheduleCategoriesTableTableManager(
      _$AppDatabase db, $DriftScheduleCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DriftScheduleCategoriesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$DriftScheduleCategoriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DriftScheduleCategoriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> scheduleItemId = const Value.absent(),
            Value<Category> category = const Value.absent(),
          }) =>
              DriftScheduleCategoriesCompanion(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            scheduleItemId: scheduleItemId,
            category: category,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            required int scheduleItemId,
            required Category category,
          }) =>
              DriftScheduleCategoriesCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            createdAt: createdAt,
            scheduleItemId: scheduleItemId,
            category: category,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DriftScheduleCategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({scheduleItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (scheduleItemId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.scheduleItemId,
                    referencedTable: $$DriftScheduleCategoriesTableReferences
                        ._scheduleItemIdTable(db),
                    referencedColumn: $$DriftScheduleCategoriesTableReferences
                        ._scheduleItemIdTable(db)
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
        ));
}

typedef $$DriftScheduleCategoriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $DriftScheduleCategoriesTable,
        DriftScheduleCategory,
        $$DriftScheduleCategoriesTableFilterComposer,
        $$DriftScheduleCategoriesTableOrderingComposer,
        $$DriftScheduleCategoriesTableAnnotationComposer,
        $$DriftScheduleCategoriesTableCreateCompanionBuilder,
        $$DriftScheduleCategoriesTableUpdateCompanionBuilder,
        (DriftScheduleCategory, $$DriftScheduleCategoriesTableReferences),
        DriftScheduleCategory,
        PrefetchHooks Function({bool scheduleItemId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DriftSettingsTableTableManager get driftSettings =>
      $$DriftSettingsTableTableManager(_db, _db.driftSettings);
  $$DriftBodyweightsTableTableManager get driftBodyweights =>
      $$DriftBodyweightsTableTableManager(_db, _db.driftBodyweights);
  $$DriftFlavourTextSchedulesTableTableManager get driftFlavourTextSchedules =>
      $$DriftFlavourTextSchedulesTableTableManager(
          _db, _db.driftFlavourTextSchedules);
  $$DriftNotesTableTableManager get driftNotes =>
      $$DriftNotesTableTableManager(_db, _db.driftNotes);
  $$DriftWorkoutsTableTableManager get driftWorkouts =>
      $$DriftWorkoutsTableTableManager(_db, _db.driftWorkouts);
  $$DriftWorkoutCategoriesTableTableManager get driftWorkoutCategories =>
      $$DriftWorkoutCategoriesTableTableManager(
          _db, _db.driftWorkoutCategories);
  $$DriftWorkoutExercisesTableTableManager get driftWorkoutExercises =>
      $$DriftWorkoutExercisesTableTableManager(_db, _db.driftWorkoutExercises);
  $$DriftWorkoutSetsTableTableManager get driftWorkoutSets =>
      $$DriftWorkoutSetsTableTableManager(_db, _db.driftWorkoutSets);
  $$DriftSchedulesTableTableManager get driftSchedules =>
      $$DriftSchedulesTableTableManager(_db, _db.driftSchedules);
  $$DriftScheduleItemsTableTableManager get driftScheduleItems =>
      $$DriftScheduleItemsTableTableManager(_db, _db.driftScheduleItems);
  $$DriftScheduleCategoriesTableTableManager get driftScheduleCategories =>
      $$DriftScheduleCategoriesTableTableManager(
          _db, _db.driftScheduleCategories);
}
