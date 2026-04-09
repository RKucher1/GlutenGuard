// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ScanHistoryItemsTable extends ScanHistoryItems
    with TableInfo<$ScanHistoryItemsTable, ScanHistoryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanHistoryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resultTierMeta =
      const VerificationMeta('resultTier');
  @override
  late final GeneratedColumn<String> resultTier = GeneratedColumn<String>(
      'result_tier', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _flaggedIngredientsMeta =
      const VerificationMeta('flaggedIngredients');
  @override
  late final GeneratedColumn<String> flaggedIngredients =
      GeneratedColumn<String>('flagged_ingredients', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scannedAtMeta =
      const VerificationMeta('scannedAt');
  @override
  late final GeneratedColumn<DateTime> scannedAt = GeneratedColumn<DateTime>(
      'scanned_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, barcode, productName, resultTier, flaggedIngredients, scannedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_history_items';
  @override
  VerificationContext validateIntegrity(Insertable<ScanHistoryItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('result_tier')) {
      context.handle(
          _resultTierMeta,
          resultTier.isAcceptableOrUnknown(
              data['result_tier']!, _resultTierMeta));
    } else if (isInserting) {
      context.missing(_resultTierMeta);
    }
    if (data.containsKey('flagged_ingredients')) {
      context.handle(
          _flaggedIngredientsMeta,
          flaggedIngredients.isAcceptableOrUnknown(
              data['flagged_ingredients']!, _flaggedIngredientsMeta));
    } else if (isInserting) {
      context.missing(_flaggedIngredientsMeta);
    }
    if (data.containsKey('scanned_at')) {
      context.handle(_scannedAtMeta,
          scannedAt.isAcceptableOrUnknown(data['scanned_at']!, _scannedAtMeta));
    } else if (isInserting) {
      context.missing(_scannedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanHistoryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanHistoryItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      resultTier: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result_tier'])!,
      flaggedIngredients: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}flagged_ingredients'])!,
      scannedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scanned_at'])!,
    );
  }

  @override
  $ScanHistoryItemsTable createAlias(String alias) {
    return $ScanHistoryItemsTable(attachedDatabase, alias);
  }
}

class ScanHistoryItem extends DataClass implements Insertable<ScanHistoryItem> {
  final int id;
  final String barcode;
  final String productName;
  final String resultTier;
  final String flaggedIngredients;
  final DateTime scannedAt;
  const ScanHistoryItem(
      {required this.id,
      required this.barcode,
      required this.productName,
      required this.resultTier,
      required this.flaggedIngredients,
      required this.scannedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['barcode'] = Variable<String>(barcode);
    map['product_name'] = Variable<String>(productName);
    map['result_tier'] = Variable<String>(resultTier);
    map['flagged_ingredients'] = Variable<String>(flaggedIngredients);
    map['scanned_at'] = Variable<DateTime>(scannedAt);
    return map;
  }

  ScanHistoryItemsCompanion toCompanion(bool nullToAbsent) {
    return ScanHistoryItemsCompanion(
      id: Value(id),
      barcode: Value(barcode),
      productName: Value(productName),
      resultTier: Value(resultTier),
      flaggedIngredients: Value(flaggedIngredients),
      scannedAt: Value(scannedAt),
    );
  }

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanHistoryItem(
      id: serializer.fromJson<int>(json['id']),
      barcode: serializer.fromJson<String>(json['barcode']),
      productName: serializer.fromJson<String>(json['productName']),
      resultTier: serializer.fromJson<String>(json['resultTier']),
      flaggedIngredients:
          serializer.fromJson<String>(json['flaggedIngredients']),
      scannedAt: serializer.fromJson<DateTime>(json['scannedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'barcode': serializer.toJson<String>(barcode),
      'productName': serializer.toJson<String>(productName),
      'resultTier': serializer.toJson<String>(resultTier),
      'flaggedIngredients': serializer.toJson<String>(flaggedIngredients),
      'scannedAt': serializer.toJson<DateTime>(scannedAt),
    };
  }

  ScanHistoryItem copyWith(
          {int? id,
          String? barcode,
          String? productName,
          String? resultTier,
          String? flaggedIngredients,
          DateTime? scannedAt}) =>
      ScanHistoryItem(
        id: id ?? this.id,
        barcode: barcode ?? this.barcode,
        productName: productName ?? this.productName,
        resultTier: resultTier ?? this.resultTier,
        flaggedIngredients: flaggedIngredients ?? this.flaggedIngredients,
        scannedAt: scannedAt ?? this.scannedAt,
      );
  ScanHistoryItem copyWithCompanion(ScanHistoryItemsCompanion data) {
    return ScanHistoryItem(
      id: data.id.present ? data.id.value : this.id,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      resultTier:
          data.resultTier.present ? data.resultTier.value : this.resultTier,
      flaggedIngredients: data.flaggedIngredients.present
          ? data.flaggedIngredients.value
          : this.flaggedIngredients,
      scannedAt: data.scannedAt.present ? data.scannedAt.value : this.scannedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanHistoryItem(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('productName: $productName, ')
          ..write('resultTier: $resultTier, ')
          ..write('flaggedIngredients: $flaggedIngredients, ')
          ..write('scannedAt: $scannedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, barcode, productName, resultTier, flaggedIngredients, scannedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanHistoryItem &&
          other.id == this.id &&
          other.barcode == this.barcode &&
          other.productName == this.productName &&
          other.resultTier == this.resultTier &&
          other.flaggedIngredients == this.flaggedIngredients &&
          other.scannedAt == this.scannedAt);
}

class ScanHistoryItemsCompanion extends UpdateCompanion<ScanHistoryItem> {
  final Value<int> id;
  final Value<String> barcode;
  final Value<String> productName;
  final Value<String> resultTier;
  final Value<String> flaggedIngredients;
  final Value<DateTime> scannedAt;
  const ScanHistoryItemsCompanion({
    this.id = const Value.absent(),
    this.barcode = const Value.absent(),
    this.productName = const Value.absent(),
    this.resultTier = const Value.absent(),
    this.flaggedIngredients = const Value.absent(),
    this.scannedAt = const Value.absent(),
  });
  ScanHistoryItemsCompanion.insert({
    this.id = const Value.absent(),
    required String barcode,
    required String productName,
    required String resultTier,
    required String flaggedIngredients,
    required DateTime scannedAt,
  })  : barcode = Value(barcode),
        productName = Value(productName),
        resultTier = Value(resultTier),
        flaggedIngredients = Value(flaggedIngredients),
        scannedAt = Value(scannedAt);
  static Insertable<ScanHistoryItem> custom({
    Expression<int>? id,
    Expression<String>? barcode,
    Expression<String>? productName,
    Expression<String>? resultTier,
    Expression<String>? flaggedIngredients,
    Expression<DateTime>? scannedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (barcode != null) 'barcode': barcode,
      if (productName != null) 'product_name': productName,
      if (resultTier != null) 'result_tier': resultTier,
      if (flaggedIngredients != null) 'flagged_ingredients': flaggedIngredients,
      if (scannedAt != null) 'scanned_at': scannedAt,
    });
  }

  ScanHistoryItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? barcode,
      Value<String>? productName,
      Value<String>? resultTier,
      Value<String>? flaggedIngredients,
      Value<DateTime>? scannedAt}) {
    return ScanHistoryItemsCompanion(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      productName: productName ?? this.productName,
      resultTier: resultTier ?? this.resultTier,
      flaggedIngredients: flaggedIngredients ?? this.flaggedIngredients,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (resultTier.present) {
      map['result_tier'] = Variable<String>(resultTier.value);
    }
    if (flaggedIngredients.present) {
      map['flagged_ingredients'] = Variable<String>(flaggedIngredients.value);
    }
    if (scannedAt.present) {
      map['scanned_at'] = Variable<DateTime>(scannedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanHistoryItemsCompanion(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('productName: $productName, ')
          ..write('resultTier: $resultTier, ')
          ..write('flaggedIngredients: $flaggedIngredients, ')
          ..write('scannedAt: $scannedAt')
          ..write(')'))
        .toString();
  }
}

class $SafeListItemsTable extends SafeListItems
    with TableInfo<$SafeListItemsTable, SafeListItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SafeListItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, barcode, productName, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'safe_list_items';
  @override
  VerificationContext validateIntegrity(Insertable<SafeListItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SafeListItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SafeListItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
    );
  }

  @override
  $SafeListItemsTable createAlias(String alias) {
    return $SafeListItemsTable(attachedDatabase, alias);
  }
}

class SafeListItem extends DataClass implements Insertable<SafeListItem> {
  final int id;
  final String barcode;
  final String productName;
  final DateTime addedAt;
  const SafeListItem(
      {required this.id,
      required this.barcode,
      required this.productName,
      required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['barcode'] = Variable<String>(barcode);
    map['product_name'] = Variable<String>(productName);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  SafeListItemsCompanion toCompanion(bool nullToAbsent) {
    return SafeListItemsCompanion(
      id: Value(id),
      barcode: Value(barcode),
      productName: Value(productName),
      addedAt: Value(addedAt),
    );
  }

  factory SafeListItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SafeListItem(
      id: serializer.fromJson<int>(json['id']),
      barcode: serializer.fromJson<String>(json['barcode']),
      productName: serializer.fromJson<String>(json['productName']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'barcode': serializer.toJson<String>(barcode),
      'productName': serializer.toJson<String>(productName),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  SafeListItem copyWith(
          {int? id, String? barcode, String? productName, DateTime? addedAt}) =>
      SafeListItem(
        id: id ?? this.id,
        barcode: barcode ?? this.barcode,
        productName: productName ?? this.productName,
        addedAt: addedAt ?? this.addedAt,
      );
  SafeListItem copyWithCompanion(SafeListItemsCompanion data) {
    return SafeListItem(
      id: data.id.present ? data.id.value : this.id,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SafeListItem(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('productName: $productName, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, barcode, productName, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SafeListItem &&
          other.id == this.id &&
          other.barcode == this.barcode &&
          other.productName == this.productName &&
          other.addedAt == this.addedAt);
}

class SafeListItemsCompanion extends UpdateCompanion<SafeListItem> {
  final Value<int> id;
  final Value<String> barcode;
  final Value<String> productName;
  final Value<DateTime> addedAt;
  const SafeListItemsCompanion({
    this.id = const Value.absent(),
    this.barcode = const Value.absent(),
    this.productName = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  SafeListItemsCompanion.insert({
    this.id = const Value.absent(),
    required String barcode,
    required String productName,
    required DateTime addedAt,
  })  : barcode = Value(barcode),
        productName = Value(productName),
        addedAt = Value(addedAt);
  static Insertable<SafeListItem> custom({
    Expression<int>? id,
    Expression<String>? barcode,
    Expression<String>? productName,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (barcode != null) 'barcode': barcode,
      if (productName != null) 'product_name': productName,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  SafeListItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? barcode,
      Value<String>? productName,
      Value<DateTime>? addedAt}) {
    return SafeListItemsCompanion(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      productName: productName ?? this.productName,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SafeListItemsCompanion(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('productName: $productName, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $ProductCacheItemsTable extends ProductCacheItems
    with TableInfo<$ProductCacheItemsTable, ProductCacheItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductCacheItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _jsonPayloadMeta =
      const VerificationMeta('jsonPayload');
  @override
  late final GeneratedColumn<String> jsonPayload = GeneratedColumn<String>(
      'json_payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, barcode, jsonPayload, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_cache_items';
  @override
  VerificationContext validateIntegrity(Insertable<ProductCacheItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('json_payload')) {
      context.handle(
          _jsonPayloadMeta,
          jsonPayload.isAcceptableOrUnknown(
              data['json_payload']!, _jsonPayloadMeta));
    } else if (isInserting) {
      context.missing(_jsonPayloadMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductCacheItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductCacheItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode'])!,
      jsonPayload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}json_payload'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $ProductCacheItemsTable createAlias(String alias) {
    return $ProductCacheItemsTable(attachedDatabase, alias);
  }
}

class ProductCacheItem extends DataClass
    implements Insertable<ProductCacheItem> {
  final int id;
  final String barcode;
  final String jsonPayload;
  final DateTime cachedAt;
  const ProductCacheItem(
      {required this.id,
      required this.barcode,
      required this.jsonPayload,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['barcode'] = Variable<String>(barcode);
    map['json_payload'] = Variable<String>(jsonPayload);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  ProductCacheItemsCompanion toCompanion(bool nullToAbsent) {
    return ProductCacheItemsCompanion(
      id: Value(id),
      barcode: Value(barcode),
      jsonPayload: Value(jsonPayload),
      cachedAt: Value(cachedAt),
    );
  }

  factory ProductCacheItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductCacheItem(
      id: serializer.fromJson<int>(json['id']),
      barcode: serializer.fromJson<String>(json['barcode']),
      jsonPayload: serializer.fromJson<String>(json['jsonPayload']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'barcode': serializer.toJson<String>(barcode),
      'jsonPayload': serializer.toJson<String>(jsonPayload),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  ProductCacheItem copyWith(
          {int? id,
          String? barcode,
          String? jsonPayload,
          DateTime? cachedAt}) =>
      ProductCacheItem(
        id: id ?? this.id,
        barcode: barcode ?? this.barcode,
        jsonPayload: jsonPayload ?? this.jsonPayload,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  ProductCacheItem copyWithCompanion(ProductCacheItemsCompanion data) {
    return ProductCacheItem(
      id: data.id.present ? data.id.value : this.id,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      jsonPayload:
          data.jsonPayload.present ? data.jsonPayload.value : this.jsonPayload,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductCacheItem(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('jsonPayload: $jsonPayload, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, barcode, jsonPayload, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductCacheItem &&
          other.id == this.id &&
          other.barcode == this.barcode &&
          other.jsonPayload == this.jsonPayload &&
          other.cachedAt == this.cachedAt);
}

class ProductCacheItemsCompanion extends UpdateCompanion<ProductCacheItem> {
  final Value<int> id;
  final Value<String> barcode;
  final Value<String> jsonPayload;
  final Value<DateTime> cachedAt;
  const ProductCacheItemsCompanion({
    this.id = const Value.absent(),
    this.barcode = const Value.absent(),
    this.jsonPayload = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  ProductCacheItemsCompanion.insert({
    this.id = const Value.absent(),
    required String barcode,
    required String jsonPayload,
    required DateTime cachedAt,
  })  : barcode = Value(barcode),
        jsonPayload = Value(jsonPayload),
        cachedAt = Value(cachedAt);
  static Insertable<ProductCacheItem> custom({
    Expression<int>? id,
    Expression<String>? barcode,
    Expression<String>? jsonPayload,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (barcode != null) 'barcode': barcode,
      if (jsonPayload != null) 'json_payload': jsonPayload,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  ProductCacheItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? barcode,
      Value<String>? jsonPayload,
      Value<DateTime>? cachedAt}) {
    return ProductCacheItemsCompanion(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      jsonPayload: jsonPayload ?? this.jsonPayload,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (jsonPayload.present) {
      map['json_payload'] = Variable<String>(jsonPayload.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductCacheItemsCompanion(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('jsonPayload: $jsonPayload, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $PantryItemsTable extends PantryItems
    with TableInfo<$PantryItemsTable, PantryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PantryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _ingredientIdMeta =
      const VerificationMeta('ingredientId');
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
      'ingredient_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isInPantryMeta =
      const VerificationMeta('isInPantry');
  @override
  late final GeneratedColumn<bool> isInPantry = GeneratedColumn<bool>(
      'is_in_pantry', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_in_pantry" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, ingredientId, name, isInPantry, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pantry_items';
  @override
  VerificationContext validateIntegrity(Insertable<PantryItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
          _ingredientIdMeta,
          ingredientId.isAcceptableOrUnknown(
              data['ingredient_id']!, _ingredientIdMeta));
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_in_pantry')) {
      context.handle(
          _isInPantryMeta,
          isInPantry.isAcceptableOrUnknown(
              data['is_in_pantry']!, _isInPantryMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PantryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PantryItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ingredientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ingredient_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isInPantry: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_in_pantry'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PantryItemsTable createAlias(String alias) {
    return $PantryItemsTable(attachedDatabase, alias);
  }
}

class PantryItem extends DataClass implements Insertable<PantryItem> {
  final int id;
  final String ingredientId;
  final String name;
  final bool isInPantry;
  final DateTime updatedAt;
  const PantryItem(
      {required this.id,
      required this.ingredientId,
      required this.name,
      required this.isInPantry,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ingredient_id'] = Variable<String>(ingredientId);
    map['name'] = Variable<String>(name);
    map['is_in_pantry'] = Variable<bool>(isInPantry);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PantryItemsCompanion toCompanion(bool nullToAbsent) {
    return PantryItemsCompanion(
      id: Value(id),
      ingredientId: Value(ingredientId),
      name: Value(name),
      isInPantry: Value(isInPantry),
      updatedAt: Value(updatedAt),
    );
  }

  factory PantryItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PantryItem(
      id: serializer.fromJson<int>(json['id']),
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      name: serializer.fromJson<String>(json['name']),
      isInPantry: serializer.fromJson<bool>(json['isInPantry']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ingredientId': serializer.toJson<String>(ingredientId),
      'name': serializer.toJson<String>(name),
      'isInPantry': serializer.toJson<bool>(isInPantry),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PantryItem copyWith(
          {int? id,
          String? ingredientId,
          String? name,
          bool? isInPantry,
          DateTime? updatedAt}) =>
      PantryItem(
        id: id ?? this.id,
        ingredientId: ingredientId ?? this.ingredientId,
        name: name ?? this.name,
        isInPantry: isInPantry ?? this.isInPantry,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PantryItem copyWithCompanion(PantryItemsCompanion data) {
    return PantryItem(
      id: data.id.present ? data.id.value : this.id,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      name: data.name.present ? data.name.value : this.name,
      isInPantry:
          data.isInPantry.present ? data.isInPantry.value : this.isInPantry,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PantryItem(')
          ..write('id: $id, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('name: $name, ')
          ..write('isInPantry: $isInPantry, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ingredientId, name, isInPantry, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PantryItem &&
          other.id == this.id &&
          other.ingredientId == this.ingredientId &&
          other.name == this.name &&
          other.isInPantry == this.isInPantry &&
          other.updatedAt == this.updatedAt);
}

class PantryItemsCompanion extends UpdateCompanion<PantryItem> {
  final Value<int> id;
  final Value<String> ingredientId;
  final Value<String> name;
  final Value<bool> isInPantry;
  final Value<DateTime> updatedAt;
  const PantryItemsCompanion({
    this.id = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.name = const Value.absent(),
    this.isInPantry = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PantryItemsCompanion.insert({
    this.id = const Value.absent(),
    required String ingredientId,
    required String name,
    this.isInPantry = const Value.absent(),
    required DateTime updatedAt,
  })  : ingredientId = Value(ingredientId),
        name = Value(name),
        updatedAt = Value(updatedAt);
  static Insertable<PantryItem> custom({
    Expression<int>? id,
    Expression<String>? ingredientId,
    Expression<String>? name,
    Expression<bool>? isInPantry,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (name != null) 'name': name,
      if (isInPantry != null) 'is_in_pantry': isInPantry,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PantryItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? ingredientId,
      Value<String>? name,
      Value<bool>? isInPantry,
      Value<DateTime>? updatedAt}) {
    return PantryItemsCompanion(
      id: id ?? this.id,
      ingredientId: ingredientId ?? this.ingredientId,
      name: name ?? this.name,
      isInPantry: isInPantry ?? this.isInPantry,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isInPantry.present) {
      map['is_in_pantry'] = Variable<bool>(isInPantry.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PantryItemsCompanion(')
          ..write('id: $id, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('name: $name, ')
          ..write('isInPantry: $isInPantry, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ReactionLogsTable extends ReactionLogs
    with TableInfo<$ReactionLogsTable, ReactionLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReactionLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reactionDateMeta =
      const VerificationMeta('reactionDate');
  @override
  late final GeneratedColumn<DateTime> reactionDate = GeneratedColumn<DateTime>(
      'reaction_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _symptomsJsonMeta =
      const VerificationMeta('symptomsJson');
  @override
  late final GeneratedColumn<String> symptomsJson = GeneratedColumn<String>(
      'symptoms_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<int> severity = GeneratedColumn<int>(
      'severity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, productName, barcode, reactionDate, symptomsJson, severity, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reaction_logs';
  @override
  VerificationContext validateIntegrity(Insertable<ReactionLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    if (data.containsKey('reaction_date')) {
      context.handle(
          _reactionDateMeta,
          reactionDate.isAcceptableOrUnknown(
              data['reaction_date']!, _reactionDateMeta));
    } else if (isInserting) {
      context.missing(_reactionDateMeta);
    }
    if (data.containsKey('symptoms_json')) {
      context.handle(
          _symptomsJsonMeta,
          symptomsJson.isAcceptableOrUnknown(
              data['symptoms_json']!, _symptomsJsonMeta));
    } else if (isInserting) {
      context.missing(_symptomsJsonMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReactionLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReactionLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode']),
      reactionDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}reaction_date'])!,
      symptomsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symptoms_json'])!,
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}severity'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $ReactionLogsTable createAlias(String alias) {
    return $ReactionLogsTable(attachedDatabase, alias);
  }
}

class ReactionLog extends DataClass implements Insertable<ReactionLog> {
  final int id;
  final String productName;
  final String? barcode;
  final DateTime reactionDate;
  final String symptomsJson;
  final int severity;
  final String? notes;
  const ReactionLog(
      {required this.id,
      required this.productName,
      this.barcode,
      required this.reactionDate,
      required this.symptomsJson,
      required this.severity,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_name'] = Variable<String>(productName);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['reaction_date'] = Variable<DateTime>(reactionDate);
    map['symptoms_json'] = Variable<String>(symptomsJson);
    map['severity'] = Variable<int>(severity);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ReactionLogsCompanion toCompanion(bool nullToAbsent) {
    return ReactionLogsCompanion(
      id: Value(id),
      productName: Value(productName),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      reactionDate: Value(reactionDate),
      symptomsJson: Value(symptomsJson),
      severity: Value(severity),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory ReactionLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReactionLog(
      id: serializer.fromJson<int>(json['id']),
      productName: serializer.fromJson<String>(json['productName']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      reactionDate: serializer.fromJson<DateTime>(json['reactionDate']),
      symptomsJson: serializer.fromJson<String>(json['symptomsJson']),
      severity: serializer.fromJson<int>(json['severity']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productName': serializer.toJson<String>(productName),
      'barcode': serializer.toJson<String?>(barcode),
      'reactionDate': serializer.toJson<DateTime>(reactionDate),
      'symptomsJson': serializer.toJson<String>(symptomsJson),
      'severity': serializer.toJson<int>(severity),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  ReactionLog copyWith(
          {int? id,
          String? productName,
          Value<String?> barcode = const Value.absent(),
          DateTime? reactionDate,
          String? symptomsJson,
          int? severity,
          Value<String?> notes = const Value.absent()}) =>
      ReactionLog(
        id: id ?? this.id,
        productName: productName ?? this.productName,
        barcode: barcode.present ? barcode.value : this.barcode,
        reactionDate: reactionDate ?? this.reactionDate,
        symptomsJson: symptomsJson ?? this.symptomsJson,
        severity: severity ?? this.severity,
        notes: notes.present ? notes.value : this.notes,
      );
  ReactionLog copyWithCompanion(ReactionLogsCompanion data) {
    return ReactionLog(
      id: data.id.present ? data.id.value : this.id,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      reactionDate: data.reactionDate.present
          ? data.reactionDate.value
          : this.reactionDate,
      symptomsJson: data.symptomsJson.present
          ? data.symptomsJson.value
          : this.symptomsJson,
      severity: data.severity.present ? data.severity.value : this.severity,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReactionLog(')
          ..write('id: $id, ')
          ..write('productName: $productName, ')
          ..write('barcode: $barcode, ')
          ..write('reactionDate: $reactionDate, ')
          ..write('symptomsJson: $symptomsJson, ')
          ..write('severity: $severity, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, productName, barcode, reactionDate, symptomsJson, severity, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReactionLog &&
          other.id == this.id &&
          other.productName == this.productName &&
          other.barcode == this.barcode &&
          other.reactionDate == this.reactionDate &&
          other.symptomsJson == this.symptomsJson &&
          other.severity == this.severity &&
          other.notes == this.notes);
}

class ReactionLogsCompanion extends UpdateCompanion<ReactionLog> {
  final Value<int> id;
  final Value<String> productName;
  final Value<String?> barcode;
  final Value<DateTime> reactionDate;
  final Value<String> symptomsJson;
  final Value<int> severity;
  final Value<String?> notes;
  const ReactionLogsCompanion({
    this.id = const Value.absent(),
    this.productName = const Value.absent(),
    this.barcode = const Value.absent(),
    this.reactionDate = const Value.absent(),
    this.symptomsJson = const Value.absent(),
    this.severity = const Value.absent(),
    this.notes = const Value.absent(),
  });
  ReactionLogsCompanion.insert({
    this.id = const Value.absent(),
    required String productName,
    this.barcode = const Value.absent(),
    required DateTime reactionDate,
    required String symptomsJson,
    required int severity,
    this.notes = const Value.absent(),
  })  : productName = Value(productName),
        reactionDate = Value(reactionDate),
        symptomsJson = Value(symptomsJson),
        severity = Value(severity);
  static Insertable<ReactionLog> custom({
    Expression<int>? id,
    Expression<String>? productName,
    Expression<String>? barcode,
    Expression<DateTime>? reactionDate,
    Expression<String>? symptomsJson,
    Expression<int>? severity,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productName != null) 'product_name': productName,
      if (barcode != null) 'barcode': barcode,
      if (reactionDate != null) 'reaction_date': reactionDate,
      if (symptomsJson != null) 'symptoms_json': symptomsJson,
      if (severity != null) 'severity': severity,
      if (notes != null) 'notes': notes,
    });
  }

  ReactionLogsCompanion copyWith(
      {Value<int>? id,
      Value<String>? productName,
      Value<String?>? barcode,
      Value<DateTime>? reactionDate,
      Value<String>? symptomsJson,
      Value<int>? severity,
      Value<String?>? notes}) {
    return ReactionLogsCompanion(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      barcode: barcode ?? this.barcode,
      reactionDate: reactionDate ?? this.reactionDate,
      symptomsJson: symptomsJson ?? this.symptomsJson,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (reactionDate.present) {
      map['reaction_date'] = Variable<DateTime>(reactionDate.value);
    }
    if (symptomsJson.present) {
      map['symptoms_json'] = Variable<String>(symptomsJson.value);
    }
    if (severity.present) {
      map['severity'] = Variable<int>(severity.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReactionLogsCompanion(')
          ..write('id: $id, ')
          ..write('productName: $productName, ')
          ..write('barcode: $barcode, ')
          ..write('reactionDate: $reactionDate, ')
          ..write('symptomsJson: $symptomsJson, ')
          ..write('severity: $severity, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ScanHistoryItemsTable scanHistoryItems =
      $ScanHistoryItemsTable(this);
  late final $SafeListItemsTable safeListItems = $SafeListItemsTable(this);
  late final $ProductCacheItemsTable productCacheItems =
      $ProductCacheItemsTable(this);
  late final $PantryItemsTable pantryItems = $PantryItemsTable(this);
  late final $ReactionLogsTable reactionLogs = $ReactionLogsTable(this);
  late final ScanHistoryDao scanHistoryDao =
      ScanHistoryDao(this as AppDatabase);
  late final ProductCacheDao productCacheDao =
      ProductCacheDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        scanHistoryItems,
        safeListItems,
        productCacheItems,
        pantryItems,
        reactionLogs
      ];
}

typedef $$ScanHistoryItemsTableCreateCompanionBuilder
    = ScanHistoryItemsCompanion Function({
  Value<int> id,
  required String barcode,
  required String productName,
  required String resultTier,
  required String flaggedIngredients,
  required DateTime scannedAt,
});
typedef $$ScanHistoryItemsTableUpdateCompanionBuilder
    = ScanHistoryItemsCompanion Function({
  Value<int> id,
  Value<String> barcode,
  Value<String> productName,
  Value<String> resultTier,
  Value<String> flaggedIngredients,
  Value<DateTime> scannedAt,
});

class $$ScanHistoryItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScanHistoryItemsTable,
    ScanHistoryItem,
    $$ScanHistoryItemsTableFilterComposer,
    $$ScanHistoryItemsTableOrderingComposer,
    $$ScanHistoryItemsTableCreateCompanionBuilder,
    $$ScanHistoryItemsTableUpdateCompanionBuilder> {
  $$ScanHistoryItemsTableTableManager(
      _$AppDatabase db, $ScanHistoryItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ScanHistoryItemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ScanHistoryItemsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> barcode = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<String> resultTier = const Value.absent(),
            Value<String> flaggedIngredients = const Value.absent(),
            Value<DateTime> scannedAt = const Value.absent(),
          }) =>
              ScanHistoryItemsCompanion(
            id: id,
            barcode: barcode,
            productName: productName,
            resultTier: resultTier,
            flaggedIngredients: flaggedIngredients,
            scannedAt: scannedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String barcode,
            required String productName,
            required String resultTier,
            required String flaggedIngredients,
            required DateTime scannedAt,
          }) =>
              ScanHistoryItemsCompanion.insert(
            id: id,
            barcode: barcode,
            productName: productName,
            resultTier: resultTier,
            flaggedIngredients: flaggedIngredients,
            scannedAt: scannedAt,
          ),
        ));
}

class $$ScanHistoryItemsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ScanHistoryItemsTable> {
  $$ScanHistoryItemsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get barcode => $state.composableBuilder(
      column: $state.table.barcode,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get productName => $state.composableBuilder(
      column: $state.table.productName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get resultTier => $state.composableBuilder(
      column: $state.table.resultTier,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get flaggedIngredients => $state.composableBuilder(
      column: $state.table.flaggedIngredients,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get scannedAt => $state.composableBuilder(
      column: $state.table.scannedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ScanHistoryItemsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ScanHistoryItemsTable> {
  $$ScanHistoryItemsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get barcode => $state.composableBuilder(
      column: $state.table.barcode,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get productName => $state.composableBuilder(
      column: $state.table.productName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get resultTier => $state.composableBuilder(
      column: $state.table.resultTier,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get flaggedIngredients => $state.composableBuilder(
      column: $state.table.flaggedIngredients,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get scannedAt => $state.composableBuilder(
      column: $state.table.scannedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$SafeListItemsTableCreateCompanionBuilder = SafeListItemsCompanion
    Function({
  Value<int> id,
  required String barcode,
  required String productName,
  required DateTime addedAt,
});
typedef $$SafeListItemsTableUpdateCompanionBuilder = SafeListItemsCompanion
    Function({
  Value<int> id,
  Value<String> barcode,
  Value<String> productName,
  Value<DateTime> addedAt,
});

class $$SafeListItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SafeListItemsTable,
    SafeListItem,
    $$SafeListItemsTableFilterComposer,
    $$SafeListItemsTableOrderingComposer,
    $$SafeListItemsTableCreateCompanionBuilder,
    $$SafeListItemsTableUpdateCompanionBuilder> {
  $$SafeListItemsTableTableManager(_$AppDatabase db, $SafeListItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SafeListItemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SafeListItemsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> barcode = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
          }) =>
              SafeListItemsCompanion(
            id: id,
            barcode: barcode,
            productName: productName,
            addedAt: addedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String barcode,
            required String productName,
            required DateTime addedAt,
          }) =>
              SafeListItemsCompanion.insert(
            id: id,
            barcode: barcode,
            productName: productName,
            addedAt: addedAt,
          ),
        ));
}

class $$SafeListItemsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SafeListItemsTable> {
  $$SafeListItemsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get barcode => $state.composableBuilder(
      column: $state.table.barcode,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get productName => $state.composableBuilder(
      column: $state.table.productName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get addedAt => $state.composableBuilder(
      column: $state.table.addedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SafeListItemsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SafeListItemsTable> {
  $$SafeListItemsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get barcode => $state.composableBuilder(
      column: $state.table.barcode,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get productName => $state.composableBuilder(
      column: $state.table.productName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get addedAt => $state.composableBuilder(
      column: $state.table.addedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ProductCacheItemsTableCreateCompanionBuilder
    = ProductCacheItemsCompanion Function({
  Value<int> id,
  required String barcode,
  required String jsonPayload,
  required DateTime cachedAt,
});
typedef $$ProductCacheItemsTableUpdateCompanionBuilder
    = ProductCacheItemsCompanion Function({
  Value<int> id,
  Value<String> barcode,
  Value<String> jsonPayload,
  Value<DateTime> cachedAt,
});

class $$ProductCacheItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductCacheItemsTable,
    ProductCacheItem,
    $$ProductCacheItemsTableFilterComposer,
    $$ProductCacheItemsTableOrderingComposer,
    $$ProductCacheItemsTableCreateCompanionBuilder,
    $$ProductCacheItemsTableUpdateCompanionBuilder> {
  $$ProductCacheItemsTableTableManager(
      _$AppDatabase db, $ProductCacheItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ProductCacheItemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$ProductCacheItemsTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> barcode = const Value.absent(),
            Value<String> jsonPayload = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
          }) =>
              ProductCacheItemsCompanion(
            id: id,
            barcode: barcode,
            jsonPayload: jsonPayload,
            cachedAt: cachedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String barcode,
            required String jsonPayload,
            required DateTime cachedAt,
          }) =>
              ProductCacheItemsCompanion.insert(
            id: id,
            barcode: barcode,
            jsonPayload: jsonPayload,
            cachedAt: cachedAt,
          ),
        ));
}

class $$ProductCacheItemsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ProductCacheItemsTable> {
  $$ProductCacheItemsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get barcode => $state.composableBuilder(
      column: $state.table.barcode,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get jsonPayload => $state.composableBuilder(
      column: $state.table.jsonPayload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get cachedAt => $state.composableBuilder(
      column: $state.table.cachedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ProductCacheItemsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ProductCacheItemsTable> {
  $$ProductCacheItemsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get barcode => $state.composableBuilder(
      column: $state.table.barcode,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get jsonPayload => $state.composableBuilder(
      column: $state.table.jsonPayload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get cachedAt => $state.composableBuilder(
      column: $state.table.cachedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$PantryItemsTableCreateCompanionBuilder = PantryItemsCompanion
    Function({
  Value<int> id,
  required String ingredientId,
  required String name,
  Value<bool> isInPantry,
  required DateTime updatedAt,
});
typedef $$PantryItemsTableUpdateCompanionBuilder = PantryItemsCompanion
    Function({
  Value<int> id,
  Value<String> ingredientId,
  Value<String> name,
  Value<bool> isInPantry,
  Value<DateTime> updatedAt,
});

class $$PantryItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PantryItemsTable,
    PantryItem,
    $$PantryItemsTableFilterComposer,
    $$PantryItemsTableOrderingComposer,
    $$PantryItemsTableCreateCompanionBuilder,
    $$PantryItemsTableUpdateCompanionBuilder> {
  $$PantryItemsTableTableManager(_$AppDatabase db, $PantryItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$PantryItemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$PantryItemsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> ingredientId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isInPantry = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PantryItemsCompanion(
            id: id,
            ingredientId: ingredientId,
            name: name,
            isInPantry: isInPantry,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String ingredientId,
            required String name,
            Value<bool> isInPantry = const Value.absent(),
            required DateTime updatedAt,
          }) =>
              PantryItemsCompanion.insert(
            id: id,
            ingredientId: ingredientId,
            name: name,
            isInPantry: isInPantry,
            updatedAt: updatedAt,
          ),
        ));
}

class $$PantryItemsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $PantryItemsTable> {
  $$PantryItemsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get ingredientId => $state.composableBuilder(
      column: $state.table.ingredientId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isInPantry => $state.composableBuilder(
      column: $state.table.isInPantry,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$PantryItemsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $PantryItemsTable> {
  $$PantryItemsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get ingredientId => $state.composableBuilder(
      column: $state.table.ingredientId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isInPantry => $state.composableBuilder(
      column: $state.table.isInPantry,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ReactionLogsTableCreateCompanionBuilder = ReactionLogsCompanion
    Function({
  Value<int> id,
  required String productName,
  Value<String?> barcode,
  required DateTime reactionDate,
  required String symptomsJson,
  required int severity,
  Value<String?> notes,
});
typedef $$ReactionLogsTableUpdateCompanionBuilder = ReactionLogsCompanion
    Function({
  Value<int> id,
  Value<String> productName,
  Value<String?> barcode,
  Value<DateTime> reactionDate,
  Value<String> symptomsJson,
  Value<int> severity,
  Value<String?> notes,
});

class $$ReactionLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReactionLogsTable,
    ReactionLog,
    $$ReactionLogsTableFilterComposer,
    $$ReactionLogsTableOrderingComposer,
    $$ReactionLogsTableCreateCompanionBuilder,
    $$ReactionLogsTableUpdateCompanionBuilder> {
  $$ReactionLogsTableTableManager(_$AppDatabase db, $ReactionLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ReactionLogsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ReactionLogsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<DateTime> reactionDate = const Value.absent(),
            Value<String> symptomsJson = const Value.absent(),
            Value<int> severity = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              ReactionLogsCompanion(
            id: id,
            productName: productName,
            barcode: barcode,
            reactionDate: reactionDate,
            symptomsJson: symptomsJson,
            severity: severity,
            notes: notes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String productName,
            Value<String?> barcode = const Value.absent(),
            required DateTime reactionDate,
            required String symptomsJson,
            required int severity,
            Value<String?> notes = const Value.absent(),
          }) =>
              ReactionLogsCompanion.insert(
            id: id,
            productName: productName,
            barcode: barcode,
            reactionDate: reactionDate,
            symptomsJson: symptomsJson,
            severity: severity,
            notes: notes,
          ),
        ));
}

class $$ReactionLogsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ReactionLogsTable> {
  $$ReactionLogsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get productName => $state.composableBuilder(
      column: $state.table.productName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get barcode => $state.composableBuilder(
      column: $state.table.barcode,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get reactionDate => $state.composableBuilder(
      column: $state.table.reactionDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get symptomsJson => $state.composableBuilder(
      column: $state.table.symptomsJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get severity => $state.composableBuilder(
      column: $state.table.severity,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ReactionLogsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ReactionLogsTable> {
  $$ReactionLogsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get productName => $state.composableBuilder(
      column: $state.table.productName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get barcode => $state.composableBuilder(
      column: $state.table.barcode,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get reactionDate => $state.composableBuilder(
      column: $state.table.reactionDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get symptomsJson => $state.composableBuilder(
      column: $state.table.symptomsJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get severity => $state.composableBuilder(
      column: $state.table.severity,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ScanHistoryItemsTableTableManager get scanHistoryItems =>
      $$ScanHistoryItemsTableTableManager(_db, _db.scanHistoryItems);
  $$SafeListItemsTableTableManager get safeListItems =>
      $$SafeListItemsTableTableManager(_db, _db.safeListItems);
  $$ProductCacheItemsTableTableManager get productCacheItems =>
      $$ProductCacheItemsTableTableManager(_db, _db.productCacheItems);
  $$PantryItemsTableTableManager get pantryItems =>
      $$PantryItemsTableTableManager(_db, _db.pantryItems);
  $$ReactionLogsTableTableManager get reactionLogs =>
      $$ReactionLogsTableTableManager(_db, _db.reactionLogs);
}
