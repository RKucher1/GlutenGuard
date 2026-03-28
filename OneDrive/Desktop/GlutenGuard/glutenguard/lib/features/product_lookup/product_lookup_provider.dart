import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product.dart';
import '../../data/models/scan_result.dart';
import '../../core/analysis/gluten_analysis_engine.dart';
import 'open_food_facts_service.dart';

// ── Service providers ─────────────────────────────────────────────────────────

final offServiceProvider = Provider<OpenFoodFactsService>((ref) {
  return OpenFoodFactsService();
});

// ── State ─────────────────────────────────────────────────────────────────────

class ProductLookupState {
  final Product? product;
  final ScanResult? scanResult;

  const ProductLookupState({this.product, this.scanResult});
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ProductLookupNotifier
    extends AsyncNotifier<ProductLookupState> {
  @override
  Future<ProductLookupState> build() async => const ProductLookupState();

  Future<void> lookupBarcode(String barcode) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Step 1: Try Open Food Facts
      final product =
          await ref.read(offServiceProvider).fetchByBarcode(barcode);

      if (product == null) return const ProductLookupState();

      // Step 2: Run gluten analysis
      final scanResult = GlutenAnalysisEngine.instance.analyseProduct(
        ingredients: product.ingredientsList,
        productName: product.productName,
        barcode: barcode,
        isGlutenFreeLabelled: product.isGlutenFreeLabelled,
      );

      return ProductLookupState(product: product, scanResult: scanResult);
    });
  }

  void reset() => state = const AsyncValue.data(ProductLookupState());
}

final productLookupProvider =
    AsyncNotifierProvider<ProductLookupNotifier, ProductLookupState>(
  ProductLookupNotifier.new,
);
