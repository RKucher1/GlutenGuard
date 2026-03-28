import 'dart:convert';
import 'package:flutter/services.dart';

class KbIngredient {
  final String name;
  final int tier;
  final List<String> aliases;
  final List<String> safeQualifiers;
  final String reason;

  const KbIngredient({
    required this.name,
    required this.tier,
    required this.aliases,
    required this.safeQualifiers,
    required this.reason,
  });

  factory KbIngredient.fromJson(Map<String, dynamic> json) => KbIngredient(
        name: json['name'] as String,
        tier: json['tier'] as int,
        aliases: (json['aliases'] as List<dynamic>).cast<String>(),
        safeQualifiers: (json['safe_qualifiers'] as List<dynamic>).cast<String>(),
        reason: json['reason'] as String,
      );
}

class GlutenKnowledgeBase {
  final List<KbIngredient> tier1;
  final List<KbIngredient> tier2;

  const GlutenKnowledgeBase({required this.tier1, required this.tier2});

  static GlutenKnowledgeBase? _instance;

  static GlutenKnowledgeBase get instance {
    assert(_instance != null,
        'GlutenKnowledgeBase not loaded — call GlutenKnowledgeBase.load() first');
    return _instance!;
  }

  static Future<GlutenKnowledgeBase> load() async {
    if (_instance != null) return _instance!;
    final raw = await rootBundle.loadString('assets/gluten_knowledge_base.json');
    _instance = fromJson(jsonDecode(raw) as Map<String, dynamic>);
    return _instance!;
  }

  /// Synchronous factory — for tests that pass a pre-parsed map.
  static GlutenKnowledgeBase fromJson(Map<String, dynamic> json) {
    final t1 = (json['tier1_ingredients'] as List<dynamic>)
        .map((e) => KbIngredient.fromJson(e as Map<String, dynamic>))
        .toList();
    final t2 = (json['tier2_ingredients'] as List<dynamic>)
        .map((e) => KbIngredient.fromJson(e as Map<String, dynamic>))
        .toList();
    return GlutenKnowledgeBase(tier1: t1, tier2: t2);
  }

  /// Override instance — used in tests.
  static void setInstance(GlutenKnowledgeBase kb) => _instance = kb;
  static void clearInstance() => _instance = null;
}
