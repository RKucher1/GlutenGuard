# GlutenGuard — API Validation Results
**Date:** 2026-03-28
**Phase:** P0/Wk1 Session 3

---

## Summary

| API | Status | Notes |
|-----|--------|-------|
| Open Food Facts | ✅ CONFIRMED | Returns product name + ingredients |
| OpenFDA Food Enforcement | ✅ CONFIRMED | 557 gluten-related recalls in database |
| USDA FSIS Recall API | ❌ BLOCKED | Connection refused from WSL2 / dev environment |
| USDA FoodData Central | ✅ CONFIRMED | DEMO_KEY works; free API key required for production |
| Supabase (product_flags) | ⏳ PENDING | Credentials not yet configured |

---

## TEST 1 — Open Food Facts (primary barcode API)

**Endpoint:** `https://world.openfoodfacts.org/api/v0/product/{barcode}.json`
**Key required:** None
**Status:** ✅ CONFIRMED

**Test barcode:** `0049000028911` (Diet Coke)

**Sample response structure:**
```json
{
  "product": {
    "product_name": "Diet Coke Soft Drink",
    "ingredients_text": "CARBONATED WATER, CARAMEL COLOR, ASPARTAME, PHOSPHORIC ACID, POTASSIUM BENZOATE...",
    "brands": "Coca-Cola",
    "code": "0049000028911",
    "image_url": "...",
    "_keywords": [...]
  },
  "status": 1,
  "status_verbose": "product found"
}
```

**Note:** Barcode `0037600164801` returned no product data (not in OFF database). Use fallback to USDA FDC or manual input when OFF returns empty.

---

## TEST 2 — OpenFDA Food Enforcement (recall data)

**Endpoint:** `https://api.fda.gov/food/enforcement.json?search=gluten&limit=3`
**Key required:** None
**Status:** ✅ CONFIRMED

**Total gluten-related records in FDA database:** 557

**Sample results:**
- "Tiny Isle Chocolate Truffles Macadamia Nut: Gluten Free, Raw..."
- "Oregano, Mediterranean ground, stock code 03355, packaged in..."
- "Fudge Brownie Cookie, net wt. 2 oz..."

**Sample response structure:**
```json
{
  "meta": {
    "results": { "total": 557, "skip": 0, "limit": 3 }
  },
  "results": [
    {
      "product_description": "Product name...",
      "reason_for_recall": "Reason...",
      "recalling_firm": "Company name",
      "recall_initiation_date": "2024-01-01",
      "status": "Ongoing",
      "classification": "Class I"
    }
  ]
}
```

**Integration plan:** Poll weekly or monthly. Cache results locally. Surface matching recalls on product scan result screen.

---

## TEST 3 — USDA FSIS Recall API (meat/poultry)

**Endpoint:** `https://www.fsis.usda.gov/fsis/api/recall/v/1`
**Key required:** None
**Status:** ❌ BLOCKED (HTTP 000 — connection refused from WSL2 dev environment)

**Workaround:** FSIS may be blocking non-browser user agents or blocking WSL2 IP ranges. Test from a deployed environment or use FSIS RSS feed as alternative.

**Alternative endpoint to try:** `https://www.fsis.usda.gov/recalls` (HTML scraping)
**Alternative data source:** OpenFDA also includes FSIS meat/poultry recalls via `api.fda.gov/food/enforcement.json`

**Status for P0:** Document as pending. Re-test after app deployment. OpenFDA covers sufficient recall data for launch.

---

## TEST 4 — USDA FoodData Central (secondary barcode fallback)

**Endpoint:** `https://api.nal.usda.gov/fdc/v1/foods/search?query={name}&api_key={key}`
**Key required:** Free at https://fdc.nal.usda.gov/api-guide.html
**Status:** ✅ CONFIRMED (DEMO_KEY works for development)

**Test query:** `chicken breast` (dataType=Branded, pageSize=3)

**Result:** 21,944 branded products found matching "chicken breast"

**Sample response structure:**
```json
{
  "totalHits": 21944,
  "foods": [
    {
      "fdcId": 123456,
      "description": "CHICKEN BREAST",
      "brandOwner": "Brand Name",
      "ingredients": "CHICKEN BREAST, WATER, SALT...",
      "dataType": "Branded"
    }
  ]
}
```

**API Key status:** DEMO_KEY works for dev (100 requests/hour). Register for a free production key at https://fdc.nal.usda.gov/api-guide.html before launch. Add to `.env` as `USDA_FDC_API_KEY`.

---

## TEST 5 — Supabase (community product_flags table)

**Endpoint:** `https://{project}.supabase.co/rest/v1/product_flags`
**Key required:** Supabase anon key
**Status:** ⏳ PENDING — credentials not yet configured

**Setup required:**
1. Create Supabase project at https://supabase.com
2. Create `product_flags` table with schema:
   ```sql
   create table product_flags (
     id uuid default gen_random_uuid() primary key,
     product_name text not null,
     brand text,
     barcode text,
     flag_type text not null,
     description text,
     photo_url text,
     submitted_at timestamptz default now(),
     reviewed boolean default false,
     is_approved boolean default false,
     user_id text
   );
   ```
3. Add credentials to `.env`:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```
4. Enable Row Level Security (RLS) — allow inserts from anon, restrict reads to approved flags only

---

## Environment Setup

### `.env` file (do not commit — see `.gitignore`)
```
USDA_FDC_API_KEY=your_key_here
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### Keys status
- **OFF API:** No key needed
- **OpenFDA:** No key needed
- **USDA FDC:** DEMO_KEY for dev → register free key at fdc.nal.usda.gov for production
- **USDA FSIS:** No key needed (API currently blocked — investigate)
- **Supabase:** Pending project setup

---

## Failures and Workarounds

| Issue | Workaround |
|-------|------------|
| USDA FSIS API blocked from WSL2 | Use OpenFDA as primary recall source; re-test FSIS from deployed app |
| OFF API: some barcodes not in database | Cascade to USDA FDC name search, then prompt user to enter manually |
| USDA FDC DEMO_KEY rate limited | Register free production key before TestFlight / Play beta |
| Supabase not configured | Manual flag review via Supabase dashboard until automated moderation ready |

---

_Generated: P0/Wk1 Session 3 — 2026-03-28_
