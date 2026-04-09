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
- Phase: P5/Wk7 in progress
- Tests passing: 230
- Last stable commit: P5/Wk7 menu scanner: MenuScannerPage + MenuHighlightPainter + MenuScannerService (230 tests)
- Known issues: USDA FSIS API blocked from WSL2 dev environment (HTTP 000). Supabase project not yet created. USDA FDC API key pending (DEMO_KEY in use for dev). Run tests with `LD_LIBRARY_PATH=/tmp/sqlitelib /home/rkucher/flutter/bin/flutter test -j 1` (WSL2: use Linux flutter at /home/rkucher/flutter/bin/flutter — Windows flutter at /mnt/c/tools/flutter has CRLF script endings that break in WSL2; sqlite3 symlink needed; -j 1 needed to prevent native-plugin parallel test drop). OcrScannerPage uses image_picker for capture (mobile_scanner v5.2.3 has no captureImage() — live frame OCR upgrade to camera package deferred to P3).
- Next action: P5/Wk7 Session 3 — ProductFlagPage + FlagSyncService (community flags → Supabase POST)
- GitHub remote: https://github.com/RKucher1/GlutenGuard
- Assets built: assets/gluten_knowledge_base.json (T1:8, T2:17, Flagged:6), assets/gluten_products_kb.json (28 patterns, 10 categories), assets/pantry_ingredients.json (199 items)
- Recipe module spec: GlutenGuard_RecipeModule.docx — AI recipe generation + smart pantry (P5+ feature, Claude API)
- Database: lib/data/database/ — AppDatabase (5 tables: ScanHistoryItems, SafeListItems, ProductCacheItems, PantryItems, ReactionLogs), ScanHistoryDao, ProductCacheDao, database_provider.dart (Riverpod providers)
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

## Recipe module — full spec

### What it is
A full AI-powered recipe system. Not a bolt-on. The pantry is the central
concept — everything else derives from it. A user who builds their pantry
is a retained user.

### Screen inventory
| File | Purpose |
|---|---|
| `features/recipes/recipe_home_page.dart` | Tab home — Quick Cook button + curated library |
| `features/recipes/quick_cook_page.dart` | Select up to 5 pantry items → AI generates instantly |
| `features/recipes/recipe_builder_page.dart` | Full pantry selection + cooking profile → AI generation |
| `features/recipes/recipe_detail_page.dart` | Full recipe view, serving scaler, save, start cooking |
| `features/recipes/cooking_mode_page.dart` | Step-by-step, screen stays on, built-in timers per step |
| `features/recipes/recipe_library_page.dart` | Browse curated recipes, filter by category/time/flags |
| `features/pantry/pantry_page.dart` | Manage pantry — add/remove/search/bulk import |
| `features/pantry/pantry_provider.dart` | Riverpod state, drift persistence |
| `features/pantry/pantry_quick_start_widget.dart` | Category bulk-add packs |
| `features/cooking_profile/cooking_profile_page.dart` | One-screen profile setup |
| `core/recipes/recipe_service.dart` | Claude API calls — system prompt injection |
| `core/recipes/recipe_safety_checker.dart` | Layer 3 post-generation ingredient check |
| `core/recipes/recipe_response.dart` | @freezed JSON model |
| `core/recipes/pantry_item.dart` | @freezed pantry item model |

### Cooking profile — set during onboarding, drives everything
| Field | Options |
|---|---|
| Experience level | New to GF (<1yr) / Experienced (1-3yr) / Pro home cook |
| Who you cook for | Just me / Me + partner / Family with children / Cooking for someone else with celiac |
| Dietary flags | Dairy-free, egg-free, nut-free, nightshade-free, low-FODMAP, low-sodium, high-protein, vegan, vegetarian |
| Cuisine preference | Italian, Asian, Mexican, Mediterranean, American, British, Middle Eastern, No preference |
| Cook time preference | Under 20 min / Under 45 min / Any |

How it's used:
- Experience → adjusts explanation depth in AI output (new users get safety notes)
- Who for → sets default servings, kid-friendliness filter
- Dietary flags → filters pantry selection list + injected into AI system prompt as hard constraints
- Cuisine → biases AI generation and curated library surfacing
- Cook time → filters curated library, sets complexity ceiling for AI

### Pantry UI — not a dropdown, structured as:
- Quick-start packs: "Add proteins" / "Add vegetables" / "Add GF grains" / "Add condiments" — bulk-add whole categories
- Search with smart match: type "chick" → chicken breast, chickpeas, chicken stock GF, chicken thighs
- Recently used items float to top — pantry learns habits
- Import from safe list: one-tap add scanned safe products to pantry
- After a GREEN scan: prompt "Add [product] to your pantry?" — this is the key retention loop
- Ingredient swaps: if recipe calls for rice flour and user has almond flour → suggest substitution

### Quick Cook mode (the daily driver)
- User taps "Quick Cook" on recipe home
- App shows their top 10 pantry items, user selects up to 5
- Tap Generate → Claude returns 3 recipes in under 3 seconds
- Each recipe: 5 ingredients or fewer, under 30 min, one pan where possible
- Free: 3 AI generations/day. Pro: unlimited.

### Full mode (dinner party / meal planning)
- User selects up to 20 pantry items
- Sets: difficulty (easy/medium/impressive), servings (2/4/6/8+), cuisine, cook time
- Claude generates complete meal plan: starter + main + side + dessert
- Shopping list: diffs recipe ingredients vs pantry, shows what to buy
- Shopping list integrates with scanner — user scans items in store to verify safe before buying

### AI safety architecture — three layers, non-negotiable
- Layer 1: User selects only from pre-verified GF ingredient list. No free-text entry. The selectable pool IS the safety boundary.
- Layer 2: System prompt hard-prohibits any ingredient not in injected pantry list. Claude instructed to refuse and regenerate rather than add non-pantry items.
- Layer 3: Generated recipe output parsed and every ingredient cross-checked against GlutenAnalysisEngine before display. Any Tier 1 or Tier 2 match triggers warning overlay before showing recipe to user.

### Claude API system prompt — exact template
```dart// recipe_service.dart — inject at runtime:
// [USER_PANTRY] [EXPERIENCE_LEVEL] [DIETARY_FLAGS] [CUISINE_PREF] [COOK_TIME] [SERVINGS] [MODE]const systemPrompt = """
You are GlutenGuard's recipe assistant. You help people with celiac disease
cook safe, delicious gluten-free meals.ABSOLUTE SAFETY RULES — never violate:

Only use ingredients from the user's pantry list. No exceptions.
Never suggest flour without specifying GF type: rice flour, almond flour,
coconut flour, tapioca flour, chickpea flour.
Never suggest soy sauce — use tamari GF or coconut aminos only if in pantry.
Never suggest breadcrumbs without GF qualifier.
Never suggest oats without certified GF qualifier.
Thickeners only: cornstarch, tapioca starch, arrowroot, xanthan gum — and
only if in the pantry list.
Never suggest an ingredient not in the pantry as 'to taste'.
If you cannot make a complete recipe from the pantry, say so and suggest
the 2-3 additions that would help most.
USER PROFILE:
Experience: [EXPERIENCE_LEVEL]
Dietary flags: [DIETARY_FLAGS]
Cuisine: [CUISINE_PREF]
Servings: [SERVINGS]
Max cook time: [COOK_TIME] minutesPANTRY: [USER_PANTRY — comma-separated verified GF list]OUTPUT: valid JSON only — no preamble, no markdown fences.
{
"recipes": [{
"name": string,
"cuisine": string,
"difficulty": "easy"|"medium"|"impressive",
"prep_minutes": number,
"cook_minutes": number,
"servings": number,
"ingredients": [{"item": string, "amount": string, "unit": string}],
"steps": [string],
"substitutions": [{"missing": string, "substitute": string, "note": string}],
"nutrition_flags": [string],
"celiac_safety_note": string
}],
"pantry_suggestions": [string]
}QUICK mode: 3 recipes, max 5 ingredients each, max 20 min.
FULL mode: 2 recipes with full meal plan option.
MEAL PLAN mode: starter + main + side + dessert as one object.
For 'new' experience level: explain WHY each ingredient is safe.
""";

### Recipe cache — drift table (avoids repeat API calls)
```dartclass RecipeCache extends Table {
IntColumn get id => integer().autoIncrement()();
TextColumn get promptHash => text()();    // SHA256 of pantry+profile — cache key
TextColumn get title => text()();
TextColumn get category => text()();
TextColumn get ingredientsJson => text()();
TextColumn get stepsJson => text()();
TextColumn get nutritionFlags => text()();
DateTimeColumn get generatedAt => dateTime()();
}
// Logic: hash request → check DB → hit Claude API only on miss → save result
// Claude API key: flutter_secure_storage, never hardcode. From console.anthropic.com

### Recipe cache — exact logic, non-negotiable
1. Hash the request: SHA256 of (sorted pantry items + cooking profile fields) = promptHash
2. Check RecipeCache table for matching promptHash FIRST — if hit, return cached, NO API call
3. Only on cache miss: call Claude API with system prompt
4. On API response: run RecipeSafetyChecker (Layer 3) before saving
5. If safety check passes: save to RecipeCache with promptHash, serve to user
6. If safety check fails: show warning overlay, do NOT save to cache
7. Same pantry + same profile = same hash = always serves from cache forever
8. Cache never expires — recipes are static once generated and verified safe
9. User can manually "regenerate" which busts cache for that hash only

### Pantry ingredient JSON schema
```json{
"name": "chicken breast",
"categories": ["poultry", "protein"],
"safety_tier": 0,
"fodmap_flag": false,
"fodmap_note": null,
"dietary_flags": ["dairyFree", "eggFree", "nutFree", "glutenFree"],
"quick_start_packs": ["proteins"]
}

### Design spec — recipe screens
- RecipeHomePage: `AppColors.surfaceGray` bg, brand header, "Quick Cook" card in `AppColors.blueLight` with `AppColors.brandBlue` CTA, curated library below in white cards
- QuickCookPage: ingredient chips — unselected `AppColors.surfaceGray` + `AppColors.textMuted`, selected `AppColors.blueLight` + `AppColors.brandBlue` border + text, Generate button `AppColors.brandBlue` full width, disabled until ≥1 selected
- RecipeDetailPage: white bg, title `AppColors.textPrimary` bold 22px, meta row `AppColors.textMuted`, section headers with `AppColors.borderColor` bottom border, step numbers `AppColors.brandBlue` circle white text, ingredient rows green checkmark if in pantry
- CookingModePage: dark bg `#111111`, white text, step card white with `AppColors.textPrimary`, timer in `AppColors.brandBlue`, "Next step" `AppColors.brandBlue` full width
- PantryPage: search bar with `AppColors.borderColor` border, quick-start pack chips in `AppColors.blueLight`, ingredient rows white cards with green checkmark when added
- Pro gate card: `AppColors.blueLight` bg, `AppColors.brandBlue` lock icon, upgrade CTA

### Must-pass recipe tests[ ] RecipeSafetyChecker flags Tier 1 ingredient in AI output before display
[ ] RecipeSafetyChecker passes clean recipe without false positives
[ ] Free tier: 4th AI generation same day shows paywall
[ ] Free tier: new day resets AI generation count
[ ] Serving scaler: 4 servings → 8 servings doubles all quantities correctly
[ ] Serving scaler: shows "1/4 tsp" not "0.25 tsp"
[ ] Pantry quick-start "proteins" pack adds expected items
[ ] Curated library filter "under 20 min" only shows matching recipes
[ ] FODMAP mode hides garlic from pantry selection
[ ] Pantry persists across app restarts
[ ] Cache hit: same pantry+profile returns cached recipe, no API call
[ ] Shopping list correctly diffs recipe ingredients vs pantry
[ ] CookingMode: screen stays on during cooking, turns off on exit
[ ] Import from safe list correctly maps scanned product to pantry item
[ ] After GREEN scan: "Add to pantry?" prompt appears


### Global rules
- All screen backgrounds: `AppColors.surfaceGray` (#F5F6FA)
- All card/container backgrounds: white (#FFFFFF) with `AppColors.borderColor` border, 12px radius
- All dividers: `AppColors.borderColor`
- All primary text: `AppColors.textPrimary`
- All secondary/timestamp text: `AppColors.textMuted`
- No hardcoded colors anywhere — always AppColors.*
- All CTAs/buttons: `AppColors.brandBlue` fill, white text, 12px radius
- All secondary buttons: white fill, `AppColors.brandBlue` text, `AppColors.brandBlue` border
- Bottom nav: `AppColors.surfaceGray` bg, top border `AppColors.borderColor`

### Brand header (appears on Scan, Safe List, Recipes, History)
- Navy rounded square logo mark (8px radius) + white leaf inside
- "GlutenGuard" wordmark `AppColors.brandNavy`, bold, 17px
- Subtitle line below in `AppColors.textMuted`, 11px
- White background, `AppColors.borderColor` bottom border

### Scan screen
- Header: brand header
- Mode pills: Barcode / Ingredients / Menu — active pill `AppColors.blueLight` bg + `AppColors.brandBlue` text + border, inactive white bg + `AppColors.textMuted` text
- Viewfinder: `#111111` bg, 16px radius, corner brackets `AppColors.brandBlue`, animated scan line `Color(0xFF4ADE80)`
- Below viewfinder: instruction text in `AppColors.textMuted`, centered
- Tab bar: active `AppColors.brandBlue` + `AppColors.blueLight` icon bg, inactive `Color(0xFFB0B3BE)`

### Safe list screen
- Header: brand header
- Empty state: centered icon + `AppColors.textMuted` message + `AppColors.brandBlue` "Start Scanning" CTA
- Product cards: white bg, 12px radius, `AppColors.borderColor` border
  - Product name: `AppColors.textPrimary` bold
  - Brand + date saved: `AppColors.textMuted`
  - GREEN dot left edge on safe products
  - AMBER dot + amber banner if product has new community flag — `AppColors.amberLight` bg + `AppColors.resultAmber` text
  - Chevron right in `AppColors.textMuted`

### History screen
- Header: brand header
- Scan rows grouped by date — date header in `AppColors.textMuted` uppercase small
- Each row: color dot left (RED/AMBER/GREEN using result colors), product name `AppColors.textPrimary`, scan method + time `AppColors.textMuted`, chevron right
- "Log a reaction" floating button: `AppColors.brandBlue`, white icon, bottom right

### Reaction logger
- White screen, `AppColors.borderColor` section dividers
- Pre-selected product highlighted in `AppColors.amberLight`
- Symptom chips: unselected `AppColors.surfaceGray` + `AppColors.textMuted`, selected `AppColors.blueLight` + `AppColors.brandBlue`
- Privacy note below save button: `AppColors.textMuted` italic — "This data is stored only on your device and will never be shared"
- Save button: `AppColors.brandBlue` full width

### Recipes screen
- Header: brand header
- Category filter chips at top: same pill style as mode pills
- Recipe cards: white bg, 12px radius, `AppColors.borderColor` border
  - Recipe image placeholder: `AppColors.surfaceGray` with centered icon
  - Title: `AppColors.textPrimary` bold
  - Cook time + servings: `AppColors.textMuted`
  - GREEN "GF Safe" badge: `AppColors.greenLight` bg + `AppColors.resultGreen` text
- Pro gate card at bottom of free list: `AppColors.blueLight` bg, `AppColors.brandBlue` lock icon, upgrade CTA

### Recipe detail screen
- White background
- Hero image area: `AppColors.surfaceGray` if no image
- Title: `AppColors.textPrimary` bold 22px
- Meta row (time/servings): `AppColors.textMuted`
- Section headers ("Ingredients", "Steps"): `AppColors.textPrimary` bold 15px, `AppColors.borderColor` bottom border
- Ingredient rows: green checkmark if in pantry, `AppColors.textMuted` dot if not
- Step numbers: `AppColors.brandBlue` circle, white number
- "Save to pantry" button: secondary style

### Settings screen
- Grouped list style — each group has white card bg, `AppColors.borderColor` dividers
- Group headers: `AppColors.textMuted` uppercase small, `AppColors.surfaceGray` bg
- Active subscription row: `AppColors.greenLight` bg, `AppColors.resultGreen` "Pro" badge
- Toggle switches: active `AppColors.brandBlue`
- Destructive actions (clear history, sign out): `AppColors.resultRed` text

### Paywall screen
- `AppColors.brandNavy` top section with white logo + headline
- Feature comparison: white cards, green checkmarks `AppColors.resultGreen` for Pro, grey dash for Free
- Annual plan card: `AppColors.blueLight` border + "Best Value" `AppColors.brandBlue` badge
- Monthly plan card: standard white card
- Lifetime option: smaller secondary link below main CTAs
- Restore purchases: `AppColors.textMuted` small text at bottom

### Onboarding screens (3 screens)
- White background throughout
- Progress dots at top: active `AppColors.brandBlue`, inactive `AppColors.borderColor`
- Illustration area: `AppColors.blueLight` bg circle with icon
- Headline: `AppColors.textPrimary` bold 24px centered
- Body: `AppColors.textMuted` centered 16px
- Primary CTA: `AppColors.brandBlue` full width, 12px radius
- Skip: `AppColors.textMuted` small text top right

### Error + empty states (all screens)
- Centered layout: icon in `AppColors.surfaceGray` circle, headline `AppColors.textPrimary`, body `AppColors.textMuted`, retry CTA `AppColors.brandBlue`
- Network error icon: `AppColors.resultAmber`
- Camera permission denied: `AppColors.resultAmber` icon + Settings deep link CTA
- No results found: `AppColors.textMuted` icon

### Loading states
- All async ops over 300ms: `AppColors.brandBlue` CircularProgressIndicator
- Skeleton loaders on list screens: `AppColors.surfaceGray` animated shimmer
- Full screen blocking loader: white overlay + `AppColors.brandBlue` spinner + `AppColors.textMuted` message below


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

_Last updated: P4/Wk6 complete — Q2 2026_
_Flutter · iOS & Android · Claude Code Workflow_