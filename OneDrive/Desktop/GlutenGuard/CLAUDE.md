# GlutenGuard — CLAUDE.md
# Flutter · iOS & Android
# Read this file first. Every session. No exceptions.


---

## What GlutenGuard is — read this before writing any code

GlutenGuard is a cross-platform mobile app for people with celiac disease and gluten sensitivity. It is a health-safety tool, not a lifestyle app.

**Core mechanic:** Camera → ingredient label → OCR → GlutenAnalysisEngine classifies each ingredient → RED (gluten), AMBER (uncertain), or GREEN (safe).

**Who uses it:** Celiac patients scanning food in stressful environments — grocery aisles, restaurant tables. Anxiety must go down when they open the app, not up.

**The critical safety principle — never violate this:**
- A GREEN on a gluten-containing product is a health event for someone who trusted this app.
- An AMBER on a safe product is an inconvenience.
- Err conservative. AMBER over GREEN, RED over AMBER. When in doubt, flag it.
- The medical disclaimer exists. The engineering goal is to never need it.

---


## Project identity
- App name: GlutenGuard
- Bundle ID (iOS): com.[yourname].glutenguard
- Package name (Android): com.[yourname].glutenguard
- Platform: Flutter · Dart 3 · iOS 16+ · Android API 21+
- Architecture: OCR-first gluten detection with barcode cascade fallback
- State management: Riverpod (flutter_riverpod)
- Database: drift (type-safe SQLite ORM)
- Purchases: RevenueCat (purchases_flutter) — handles both App Store and Google Play

---

## Current state
- Phase: P2/Wk4 session 2 complete
- Tests passing: 90
- Last stable commit: P2/Wk4 OCR scanner UI: OcrScannerPage + OcrResultPage wired to OcrService, Ingredients chip wired in BarcodeScannerPage (90 tests)
- Known issues: USDA FSIS API blocked from WSL2 dev environment (HTTP 000). Supabase project not yet created. USDA FDC API key pending (DEMO_KEY in use for dev). Run tests with `LD_LIBRARY_PATH=/tmp/sqlitelib /home/rkucher/flutter/bin/flutter test -j 1` (WSL2: use Linux flutter at /home/rkucher/flutter/bin/flutter — Windows flutter at /mnt/c/tools/flutter has CRLF script endings that break in WSL2; sqlite3 symlink needed; -j 1 needed to prevent native-plugin parallel test drop). OcrScannerPage uses image_picker for capture (mobile_scanner v5.2.3 has no captureImage() — live frame OCR upgrade to camera package deferred to P3).
- Next action: P3/Wk5 — Result screens: RED/AMBER/GREEN full result pages (ResultHeader, ExplanationCard, IngredientChip, SourceBadge, QuickSaveToast)
- GitHub remote: https://github.com/RKucher1/GlutenGuard
- Assets built: assets/gluten_knowledge_base.json (T1:8, T2:17, Flagged:6), assets/gluten_products_kb.json (28 patterns, 10 categories), assets/pantry_ingredients.json (199 items)
- Recipe module spec: GlutenGuard_RecipeModule.docx — AI recipe generation + smart pantry (P5+ feature, Claude API)
- Database: lib/data/database/ — AppDatabase (4 tables), ScanHistoryDao, ProductCacheDao, database_provider.dart (Riverpod providers)
- Recipe cache DB: Recipes table not yet built — schema planned:
  promptHash (cache key), title, category, ingredientsJson, stepsJson, generatedAt
  Logic: hash request → check DB first → hit Claude API only on cache miss → save result
  Claude API key: store in flutter_secure_storage, never hardcode. Get from console.anthropic.com
  Build in P5 alongside recipe UI session.
  - Menu scan feature: planned for P5 — full-frame OCR capture on menu text, run each
  dish description through GlutenAnalysisEngine, display inline color dot per dish
  (RED/AMBER/GREEN). Same OcrService + GlutenAnalysisEngine pipeline as ingredients scan,
  no new analysis logic needed. Add manual override checkbox ("waiter confirmed contains X").
  Files: menu_scanner_page.dart, menu_highlight_painter.dart (already in architecture).
---

## Session protocol
1. Read this file. Always. Before writing any code.
2. Check Current State above — current phase and exact test count.
3. Build only the current phase milestone. Do not skip ahead.
4. **Write tests alongside every feature — no feature ships without tests.**
5. Run `LD_LIBRARY_PATH=/tmp/sqlitelib /home/rkucher/flutter/bin/flutter test -j 1` before committing.
6. End every session: git commit → update Current State above.
7. Commit format: `P{n}/Wk{n} {description}: {key changes} ({N} tests passing)`
8. Never pad the test count. Exact number only.
9. Never leave the project in a broken build state.
10. Run `/home/rkucher/flutter/bin/flutter analyze` before committing — zero warnings in new code.
11. After any model, provider, or database change: `/home/rkucher/flutter/bin/flutter pub run build_runner build --delete-conflicting-outputs`


## Claude Code efficiency rules — follow every session

- No preamble, no summaries, no affirmations — go straight to work
- Diffs only — never rewrite a full file when a targeted edit will do
- Use `str_replace` for edits, not full file rewrites
- **Test-driven: every new file, class, or function gets a test. No exceptions.**
  - New service/logic class → unit test in `test/core/` or `test/features/`
  - New widget page → widget test verifying key UI elements and states
  - New provider → test with fake/stub dependencies
  - Tests must cover: happy path, empty/null edge case, error state
- Run only tests affected by the change — not the full suite — unless doing final pre-commit check
- Read files before asking questions about their contents
- Stop before `git` ops and destructive DB ops — report and wait for direction
- If scope changes mid-session, stop and report — do not expand silently
- End-of-session output only: "X passing, Y failing. [one line summary of what was built]"

---

---

## Key commands
```bash
# WSL2: Always use the Linux flutter, NOT /mnt/c/tools/flutter (Windows version has CRLF scripts that break in WSL2)
FLUTTER=/home/rkucher/flutter/bin/flutter

$FLUTTER pub get                                                          # install dependencies
$FLUTTER pub run build_runner build --delete-conflicting-outputs          # code generation
LD_LIBRARY_PATH=/tmp/sqlitelib $FLUTTER test -j 1                        # run all tests (WSL2)
LD_LIBRARY_PATH=/tmp/sqlitelib $FLUTTER test test/core/ -j 1             # core tests only
LD_LIBRARY_PATH=/tmp/sqlitelib $FLUTTER test test/features/ -j 1         # feature tests only
$FLUTTER analyze                                                          # static analysis
$FLUTTER run -d ios                                                       # iOS simulator
$FLUTTER run -d android                                                   # Android emulator
$FLUTTER build ios --release                                              # iOS release build
$FLUTTER build appbundle --release                                        # Android Play Store upload
```

---

## Git commit examples
```
P0/Wk1 knowledge base: scrapers built, 200 ingredients seeded (0 tests)
P1/Wk2 scaffold: flutter create, routing, drift wired (5 tests)
P1/Wk3 barcode: OFF API cascade working, result screen live (22 tests)
P2/Wk4 analysis engine: tier classification + all edge cases (112 tests)
P3/Wk5 result screens: RED/AMBER/GREEN + quick-save toast (156 tests)
P4/Wk6 safe list + history + reaction tracker (198 tests)
P5/Wk7 remote KB + community flags + menu OCR (238 tests)
P6/Wk8 RevenueCat + onboarding + accessibility (288 tests)
P7/Wk9 TestFlight + Play beta (288 tests)
```

---

## Phase checklist

### P0 — Week 1 — Knowledge Base (no Flutter yet)
- [ ] Python scraper: celiac.com forbidden + safe lists → ingredients[] in JSON
- [ ] OpenFDA recall API tested: `api.fda.gov/food/enforcement.json?search=gluten&limit=100`
- [ ] USDA FSIS recall API tested: `api.fsis.usda.gov/recalls`
- [ ] Open Food Facts API tested: `world.openfoodfacts.org/api/v0/product/{barcode}.json`
- [ ] GlutenKnowledgeBase.json built: 200+ ingredients, 60 flagged products
- [ ] JSON validated against schema below
- [ ] Commit: P0/Wk1

### P1 — Weeks 2-3 — Flutter Scaffold + Barcode
- [ ] `flutter create glutenguard` — folder structure matches architecture below
- [ ] pubspec.yaml: all dependencies installed and resolving
- [ ] Code generation verified: `build_runner build` runs clean
- [ ] `app_colors.dart` with all brand tokens
- [ ] go_router: bottom nav (Scan / Safe List / History / Settings), all routes defined
- [ ] drift AppDatabase: ScanHistoryDao, ProductCacheDao — tables + DAOs
- [ ] BarcodeScanner: mobile_scanner widget, live decode, haptic on success
- [ ] OpenFoodFactsService: barcode → Product model
- [ ] USDAFoodDataService: name search fallback
- [ ] ProductCacheService: drift cache keyed by barcode
- [ ] Basic ResultPage: shows product name + raw ingredients
- [ ] Commit: P1/Wk3 (target: 32 tests)

### P2 — Weeks 3-4 — OCR + Analysis Engine
- [ ] OcrService: google_mlkit_text_recognition, confidence 0.7 threshold
- [ ] OcrScannerPage: live text preview showing partial detected text
- [ ] IngredientRegionDetector: anchor/terminator block extraction
- [ ] IngredientParser: raw text → List<String>, handles parentheses, multilingual
- [ ] GlutenAnalysisEngine: tier 1/2/3 classification, word-boundary RegExp
- [ ] RiskScorer: safe_qualifiers check distinguishes AMBER from GREEN
- [ ] All hardcoded edge cases passing (see must-pass test cases below)
- [ ] Commit: P2/Wk4 (target: 112 tests)

### P3 — Week 5 — Result Screens
- [ ] ResultPage: routes to RED/AMBER/YELLOW/GREEN based on ScanResult
- [ ] ResultHeader: coloured band, icon, verdict, product name
- [ ] ExplanationCard: leads RED result — which ingredient + why in plain English
- [ ] IngredientChip: per-ingredient status chip for every ingredient
- [ ] SourceBadge: detection method + confidence % on all results
- [ ] QuickSaveToast: in-screen save confirmation with Undo action
- [ ] AMBER: community flag citation shown first, manufacturer CTA
- [ ] Medical disclaimer visible on all result screens
- [ ] Commit: P3/Wk5 (target: 156 tests)

### P4 — Week 6 — Safe List + History + Reaction Tracker
- [ ] SafeListPage: drift persistence, amber alert banner on newly flagged products
- [ ] SafeListShareService: plain text export via share_plus
- [ ] ScanHistoryPage: colour-coded dots, date grouping, 7-day/unlimited Pro gate
- [ ] ReactionLoggerPage: device-local drift, pre-selects suspicious recent product
- [ ] Explicit 'This data will not be shared' label on reaction logger
- [ ] Commit: P4/Wk6 (target: 198 tests)

### P5 — Week 7 — Remote KB + Community Flags + Menu Mode
- [ ] KnowledgeBaseManager: dio fetch GitHub raw JSON, ETag caching, schema_version check
- [ ] ProductFlagPage: flag type picker, optional image_picker photo, Supabase POST
- [ ] Manual review gate — flags never auto-escalate without review
- [ ] MenuScannerPage: full-frame MLKit capture, MenuHighlightPainter for inline flags
- [ ] MenuScannerPage: reuses OcrService + GlutenAnalysisEngine — no new analysis logic
- [ ] Manual ingredient check input on menu page
- [ ] Commit: P5/Wk7 (target: 238 tests)

### P6 — Week 8 — RevenueCat + Onboarding + Accessibility
- [ ] purchases_flutter configured for iOS (App Store Connect product IDs)
- [ ] purchases_flutter configured for Android (Google Play Console product IDs)
- [ ] RevenueCat dashboard: Entitlement 'pro', all three products linked
- [ ] PaywallPage: Free vs Pro comparison, annual plan as best value
- [ ] Restore purchases flow
- [ ] Free gating: OCR 5/day, AMBER details, history 7 days, sync, share, reaction
- [ ] Onboarding: 3 screens, sensitivity selector, feature preview, medical disclaimer
- [ ] Semantics() labels on all interactive widgets
- [ ] Dynamic text scaling tested
- [ ] Haptic feedback on successful scan
- [ ] Commit: P6/Wk8 (target: 288 tests)

### P7 — Weeks 9-11 — Beta + Submission
- [ ] TestFlight beta: 20-30 celiac community testers, critical bugs fixed
- [ ] Google Play internal testing beta: same testers on Android
- [ ] iOS App Store screenshots: 6.9" and 6.5" iPhone required
- [ ] Android Play Store screenshots: phone + feature graphic (1024×500)
- [ ] App Store listing copy: no medical language, OCR as headline differentiator
- [ ] Google Play listing copy: description text weighted by algorithm — include ASO keywords
- [ ] App Store submission
- [ ] Google Play submission

---

## Architecture — key files

```
glutenguard/
├── lib/
│   ├── main.dart                         # Entry point, Riverpod ProviderScope
│   ├── app.dart                          # MaterialApp, go_router
│   │
│   ├── core/
│   │   ├── analysis/
│   │   │   ├── gluten_analysis_engine.dart
│   │   │   ├── ingredient_parser.dart
│   │   │   └── risk_scorer.dart
│   │   ├── knowledge_base/
│   │   │   ├── gluten_knowledge_base.dart
│   │   │   ├── knowledge_base_manager.dart
│   │   │   └── assets/gluten_knowledge_base.json
│   │   └── constants/
│   │       ├── app_colors.dart
│   │       └── app_text_styles.dart
│   │
│   ├── features/
│   │   ├── scanner/barcode/
│   │   │   ├── barcode_scanner_page.dart
│   │   │   └── barcode_scanner_provider.dart
│   │   ├── scanner/ocr/
│   │   │   ├── ocr_scanner_page.dart
│   │   │   ├── ocr_service.dart
│   │   │   └── ingredient_region_detector.dart
│   │   ├── scanner/menu/
│   │   │   ├── menu_scanner_page.dart
│   │   │   └── menu_highlight_painter.dart
│   │   ├── results/
│   │   │   ├── result_page.dart
│   │   │   ├── result_header_widget.dart
│   │   │   ├── ingredient_chip_widget.dart
│   │   │   ├── explanation_card_widget.dart
│   │   │   ├── source_badge_widget.dart
│   │   │   └── quick_save_toast.dart
│   │   ├── product_lookup/
│   │   │   ├── open_food_facts_service.dart
│   │   │   ├── usda_food_data_service.dart
│   │   │   └── product_cache_service.dart
│   │   ├── safe_list/
│   │   │   ├── safe_list_page.dart
│   │   │   ├── safe_list_provider.dart
│   │   │   └── safe_list_share_service.dart
│   │   ├── history/
│   │   │   ├── scan_history_page.dart
│   │   │   └── reaction_logger_page.dart
│   │   ├── community/
│   │   │   ├── product_flag_page.dart
│   │   │   └── flag_sync_service.dart
│   │   ├── onboarding/
│   │   │   ├── onboarding_page.dart
│   │   │   └── sensitivity_selector_widget.dart
│   │   └── paywall/
│   │       ├── paywall_page.dart
│   │       └── purchases_provider.dart
│   │
│   └── data/
│       ├── models/
│       │   ├── product.dart              # @freezed
│       │   ├── scan_result.dart          # @freezed
│       │   └── ingredient_analysis.dart  # @freezed
│       └── database/
│           ├── app_database.dart
│           ├── scan_history_dao.dart
│           └── product_cache_dao.dart
│
├── test/
│   ├── core/
│   │   ├── gluten_analysis_engine_test.dart
│   │   ├── ingredient_parser_test.dart
│   │   └── risk_scorer_test.dart
│   └── features/
│       ├── product_lookup_test.dart
│       └── safe_list_test.dart
│
├── assets/
│   └── gluten_knowledge_base.json
├── pubspec.yaml
└── CLAUDE.md
```

---

## API endpoints

| API | Endpoint | Key required |
|---|---|---|
| Open Food Facts | `https://world.openfoodfacts.org/api/v0/product/{barcode}.json` | None |
| USDA FoodData Central | `https://api.nal.usda.gov/fdc/v1/foods/search?query={name}&api_key={key}` | Free at api.nal.usda.gov |
| OpenFDA Food Recalls | `https://api.fda.gov/food/enforcement.json?search=gluten&limit=100` | None |
| USDA FSIS Recalls | `https://api.fsis.usda.gov/recalls` | None |
| Community Flags | `https://{supabase-url}/rest/v1/product_flags` | Supabase anon key |
| Remote Knowledge Base | `https://raw.githubusercontent.com/{repo}/main/assets/gluten_knowledge_base.json` | None |

---

## Knowledge base JSON schema

```json
{
  "schema_version": 1,
  "last_updated": "2026-04-01",
  "ingredients": [
    {
      "name": "barley malt",
      "tier": 1,
      "aliases": ["malt", "malt extract", "malted barley", "malt syrup", "malt flavoring", "barley malt extract"],
      "safe_qualifiers": [],
      "reason": "Direct derivative of barley, a primary gluten-containing grain",
      "source_url": "https://www.celiac.com/celiac-disease/forbidden-gluten-food-list"
    },
    {
      "name": "starch",
      "tier": 2,
      "aliases": ["food starch", "modified starch", "modified food starch"],
      "safe_qualifiers": ["tapioca", "corn", "potato", "rice", "arrowroot", "cassava"],
      "reason": "May be wheat-derived when source grain is unspecified on the label",
      "source_url": "https://celiac.org/gluten-free-living/what-is-gluten/sources-of-gluten/"
    }
  ],
  "flagged_products": [
    {
      "name": "Gluten-Free Rolled Oats",
      "brand": "Trader Joe's",
      "upc": null,
      "issue": "Tested above 20ppm gluten in multiple 2024 bags. GF label unreliable for extremely sensitive celiacs.",
      "source_url": "https://www.glutenfreewatchdog.org",
      "date_flagged": "2024-01-01",
      "is_recall": false
    }
  ]
}
```

---

## OCR implementation — Dart

```dart
// ocr_service.dart
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  static const double confidenceThreshold = 0.7;

  static const _anchors = [
    'Ingredients:', 'INGREDIENTS:', 'Contains:',
    'Contient:', 'Ingredientes:', 'Zutaten:',
  ];

  static const _terminators = [
    'Nutrition Facts', 'Supplement Facts', 'Distributed by',
    'Best before', 'Best by', 'Net wt', 'Net weight',
    'Manufactured by', 'Keep refrigerated', 'www.', 'UPC',
  ];

  Future<OcrResult> scanIngredients(InputImage image) async {
    final recognised = await _recognizer.processImage(image);
    final lines = recognised.blocks
        .expand((b) => b.lines)
        .where((l) => l.confidence >= confidenceThreshold)
        .map((l) => l.text)
        .toList();

    final block = IngredientRegionDetector.extract(lines, _anchors, _terminators);
    return OcrResult(rawText: block, confidence: _avgConfidence(recognised));
  }

  void dispose() => _recognizer.close();
}
```

---

## Risk classification — Dart

```dart
// gluten_analysis_engine.dart — critical: word boundary matching
IngredientResult _analyseIngredient(String raw) {
  final n = raw.toLowerCase().trim();

  // Tier 1 — word boundary RegExp (NEVER use contains — catches buckwheat as wheat)
  for (final item in kb.tier1) {
    for (final alias in [item.name, ...item.aliases]) {
      final pattern = RegExp(r'\b' + RegExp.escape(alias) + r'\b');
      if (pattern.hasMatch(n)) {
        return IngredientResult(raw: raw, tier: 1, reason: item.reason);
      }
    }
  }

  // Tier 2 — check safe_qualifiers before flagging AMBER
  for (final item in kb.tier2) {
    final aliasHit = [item.name, ...item.aliases].any((a) => n.contains(a));
    if (aliasHit) {
      final safe = item.safeQualifiers.any((q) => n.contains(q));
      if (!safe) return IngredientResult(raw: raw, tier: 2, reason: item.reason);
    }
  }

  return IngredientResult(raw: raw, tier: 0, reason: null);
}
```

---

## Hardcoded edge cases — never change without review

| Ingredient | Result | Reason |
|---|---|---|
| buckwheat | GREEN | Not wheat — word boundary regex prevents false positive |
| gluten-free oats | GREEN + note | Certified safe but note oat sensitivity exists |
| oats (no GF qualifier) | AMBER | High cross-contamination risk |
| brown rice syrup | AMBER | Often made with barley enzymes |
| yeast extract | AMBER | May be barley-derived |
| soy sauce | RED | Traditional contains wheat — unless GF labelled |
| tamari | AMBER | Usually GF but verify — some brands contain wheat |
| malt (any form) | RED | Always barley-derived |
| modified food starch on meat/poultry | AMBER | FDA allows unlabelled wheat starch in these categories |
| caramel color in EU imports | AMBER | May be wheat-derived outside North America |
| wheat-free claim alone | YELLOW | Not GREEN — may contain rye or barley |

---

## Must-pass test cases

### Always GREEN — never flag these
```
buckwheat, tapioca starch, potato starch, rice starch, corn starch,
cassava flour, almond flour, coconut flour, distilled vinegar,
xanthan gum, guar gum, locust bean gum, arrowroot starch,
rice flour, sorghum flour, quinoa, amaranth, millet
```

### Always RED — never miss these
```
wheat, wheat flour, enriched wheat flour, whole wheat flour,
barley, barley malt, malt, malt extract, malt syrup, malt flavoring,
malt vinegar, malted barley flour, rye, spelt, kamut, farro,
einkorn, emmer, triticale, semolina, durum, bulgur, couscous,
farina, seitan, hydrolyzed wheat protein, brewer's yeast
```

### Always AMBER — always flag uncertain
```
starch, modified starch, modified food starch, natural flavors,
brown rice syrup, yeast extract, oats, dextrin
```

---

## Riverpod patterns — use these consistently

```dart
// Provider definition with annotation
@riverpod
Future<List<ScanResult>> scanHistory(ScanHistoryRef ref) {
  return ref.watch(scanHistoryDaoProvider).getAllScans();
}

// Always handle all three states
ref.watch(scanHistoryProvider).when(
  data: (history) => HistoryList(history),
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => ErrorView(message: e.toString()),
);

// Invalidate to refresh
ref.invalidate(scanHistoryProvider);
```

---

## Freezed model pattern

```dart
@freezed
class Product with _$Product {
  const factory Product({
    required String barcode,
    required String name,
    required String brand,
    required List<String> ingredients,
    String? imageUrl,
    @Default(false) bool isGlutenFreeLabelled,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
// Always run build_runner after changing a @freezed model
```

---

## Monetisation — RevenueCat

```dart
// purchases_provider.dart
Future<void> configurePurchases() async {
  final config = Platform.isIOS
    ? PurchasesConfiguration('appl_YOUR_IOS_KEY')
    : PurchasesConfiguration('goog_YOUR_ANDROID_KEY');
  await Purchases.configure(config);
}

// Product IDs — must match App Store Connect AND Google Play Console AND RevenueCat dashboard
const kProMonthly  = 'glutenguard_pro_monthly';   // $2.99/month
const kProAnnual   = 'glutenguard_pro_annual';    // $19.99/year
const kProLifetime = 'glutenguard_pro_lifetime';  // $7.99 one-time
```

### Free vs Pro gating
| Feature | Free | Pro |
|---|---|---|
| Barcode scans | Unlimited | Unlimited |
| OCR scans | 5/day | Unlimited |
| AMBER full explanation | Teaser only | Full |
| Scan history | 7 days | Unlimited |
| Safe list | Local only | Synced |
| Safe list sharing | No | Yes |
| Reaction tracker | No | Yes |
| Community flags layer | No | Yes |

---

## Brand tokens — paste into app_colors.dart

```dart
class AppColors {
  static const brandNavy   = Color(0xFF1A1A2E); // header bars, logo bg
  static const brandBlue   = Color(0xFF3A7BF7); // CTAs, logo mark, links
  static const blueLight   = Color(0xFFEBF1FF); // info backgrounds
  static const resultGreen = Color(0xFF2E7D32); // safe result text
  static const greenLight  = Color(0xFFEBF7EE); // safe result background
  static const resultRed   = Color(0xFFC0272D); // gluten result text
  static const redLight    = Color(0xFFFEF1F1); // gluten result background
  static const resultAmber = Color(0xFFB45309); // uncertain result text
  static const amberLight  = Color(0xFFFFF8EE); // uncertain result background
  static const surfaceGray = Color(0xFFF5F6FA); // screen backgrounds, cards
  static const borderColor = Color(0xFFE2E4E9); // dividers, outlines
  static const textPrimary = Color(0xFF1A1A2E); // all body text
  static const textMuted   = Color(0xFF5A5F72); // secondary labels, subtitles
}
```

---

## Platform-specific notes

### iOS
- Minimum deployment target: iOS 16.0
- Add to `ios/Runner/Info.plist`:
  `NSCameraUsageDescription` → `"GlutenGuard needs your camera to scan barcodes and ingredient labels."`
- TestFlight: `flutter build ios --release` → archive in Xcode → App Store Connect
- Category: Health & Fitness | Age rating: 9+

### Android
- minSdkVersion: 21 | targetSdkVersion: 34
- Camera permission declared automatically by mobile_scanner
- ML Kit downloads text recognition model on first OCR use (~3MB) — detect failure gracefully
- Play Console: create app → internal testing → closed testing → production
- `flutter build appbundle --release` → upload .aab to Play Console
- Content rating: no medical advice, no violence
- RevenueCat: link Google Play app in RevenueCat dashboard

---

## Competitive context
- Primary competitor: The Gluten Free Scanner (Lluis Guiu) — 4.7★, 4,300 ratings, launched 2015
- Their weakness: iOS only, US only, barcode only, "Not found" dead end, zero explanation
- GlutenGuard's advantages: OCR fallback (always answers), Android (3B more devices), explanation-first, worldwide, community flags
- Do not compete with their restaurant directory (150k US places) at launch
- Our menu OCR serves a better in-the-moment use case — scan the actual menu in front of you


## Result screen behavior — exact spec per verdict

**RED result:**
- Background `AppColors.redLight` — headline in `AppColors.resultRed`
- Explanation block ("which ingredient and why") appears FIRST, above the ingredient list
- Each flagged ingredient highlighted in list below
- "Do not eat" — label only, not a button
- Source badge + confidence score
- No save button

**GREEN result:**
- Background `AppColors.greenLight` — headline in `AppColors.resultGreen`
- Source and confidence shown prominently (not buried)
- "Save to Safe List" — `AppColors.brandBlue` button, shows in-screen toast on save
- "Scan another" secondary CTA

**AMBER result:**
- Background `AppColors.amberLight` — headline in `AppColors.resultAmber`
- If community flag exists: flag is the HEADLINE (GFWD source + date)
- Ingredient explanation below the flag
- "Contact manufacturer" CTA
- No save button

**All result screens:**
- Medical disclaimer visible — no exceptions
- Source badge shows scan method (OCR / Barcode / Manual) + confidence %

---


---




## Phase completion checklist — run before every commit

```
[ ] flutter test — all passing, exact count in Current State above
[ ] flutter analyze — zero warnings or errors in new code
[ ] build_runner run if any models/providers/database changed
[ ] No ! force-unwrap on nullable without null check
[ ] Error states handled: network failure, OCR failure, no camera permission
[ ] Loading state shown for any async op over 300ms
[ ] Semantics() on all interactive widgets
[ ] Medical disclaimer on all result screens
[ ] Pro gating correct: free limits enforced, paid features unlocked
[ ] Tested on iOS simulator AND Android emulator
[ ] CLAUDE.md Current State updated
[ ] Git committed with exact test count
```

---

_Last updated: P0/Wk1 start — Q2 2026_
_Flutter · iOS & Android · Claude Code Workflow_



- Remaining build scope: P3 result screens → P4 safe list/history → P5 remote KB/community flags/menu → P6 RevenueCat/onboarding → P7 beta/submission