import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/knowledge_base/gluten_knowledge_base.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlutenKnowledgeBase.load();
  runApp(const ProviderScope(child: GlutenGuardApp()));
}
