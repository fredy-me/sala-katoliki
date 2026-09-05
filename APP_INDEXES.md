# APP_INDEXES.md

Sala Katoliki — web URL scheme for App Indexing.

- **Site base:** `https://busaradigital.com/salakatoliki/`
- **Slugs:** Kiswahili title slugs (kebab-case), derived from the real bundled SW titles.
- **IDs:** the exact IDs used in the app (`assets/content/`), byte-for-byte.
- Every entry shows the **start URL** (web) followed by the **real app ID** and the **app route** it must open.

---

## Legend

- `{prayerId}` → real prayer ID from `assets/content/prayers/{lang}/*.json`
- `{novenaId}` → real novena ID from `assets/content/novenas/{lang}/*.json`
- `{mysteryId}` → real rosary mystery ID from `assets/content/rosary/{lang}/mysteries.json`
- `{day}` → novena day number, `1..N`

---

## 1. Home / Today

| Web URL | App route |
| --- | --- |
| `https://busaradigital.com/salakatoliki/` | `/today` |

---

## 2. Prayer library (all prayers)

| Web URL | App route |
| --- | --- |
| `https://busaradigital.com/salakatoliki/prayers/` | `/prayers` |

---

## 3. Categories

| Web URL | Category ID (app) | App route |
| --- | --- | --- |
| `https://busaradigital.com/salakatoliki/prayers/common/` | `common_prayers` | `/prayers/category/common_prayers` |
| `https://busaradigital.com/salakatoliki/prayers/marian/` | `marian_prayers` | `/prayers/category/marian_prayers` |
| `https://busaradigital.com/salakatoliki/prayers/confession/` | `confession_prayers` | `/prayers/category/confession_prayers` |
| `https://busaradigital.com/salakatoliki/prayers/litanies/` | `litanies` | `/prayers/category/litanies` |
| `https://busaradigital.com/salakatoliki/prayers/mass/` | `mass_prayers` | `/prayers/category/mass_prayers` |
| `https://busaradigital.com/salakatoliki/prayers/divine-mercy/` | `divine_mercy` | `/prayers/category/divine_mercy` |

---

## 4. Prayers (individual)

### 4.1 Common Prayers — `/prayers/common/{slug}` → `/prayers/{prayerId}`

| Web URL | `{prayerId}` (app) |
| --- | --- |
| `https://busaradigital.com/salakatoliki/prayers/common/baba-yetu` | `our_father` |
| `https://busaradigital.com/salakatoliki/prayers/common/atukuzwe-baba` | `glory_be` |
| `https://busaradigital.com/salakatoliki/prayers/common/sala-kwa-mt-yosefu` | `prayer_to_st_joseph` |
| `https://busaradigital.com/salakatoliki/prayers/common/salamu-malkia` | `hail_holy_queen` |
| `https://busaradigital.com/salakatoliki/prayers/common/sala-ya-asubuhi` | `morning_prayer` |
| `https://busaradigital.com/salakatoliki/prayers/common/amri-za-mungu` | `commandments_of_god` |
| `https://busaradigital.com/salakatoliki/prayers/common/amri-za-kanisa` | `commandments_of_the_church` |
| `https://busaradigital.com/salakatoliki/prayers/common/sala-ya-jioni` | `evening_prayer` |

### 4.2 Marian Prayers — `/prayers/marian/{slug}` → `/prayers/{prayerId}`

| Web URL | `{prayerId}` (app) |
| --- | --- |
| `https://busaradigital.com/salakatoliki/prayers/marian/salamu-maria` | `hail_mary` |

### 4.3 Confession Prayers — `/prayers/confession/{slug}` → `/prayers/{prayerId}`

| Web URL | `{prayerId}` (app) |
| --- | --- |
| `https://busaradigital.com/salakatoliki/prayers/confession/toba` | `act_of_contrition` |

### 4.4 Litanies — `/prayers/litanies/{slug}` → `/prayers/{prayerId}`

| Web URL | `{prayerId}` (app) |
| --- | --- |
| `https://busaradigital.com/salakatoliki/prayers/litanies/litania-ya-mtakatifu-rita` | `st_rita_litany` |
| `https://busaradigital.com/salakatoliki/prayers/litanies/litania-ya-bikira-maria` | `bikira_maria_litany` |
| `https://busaradigital.com/salakatoliki/prayers/litanies/litania-ya-huruma-ya-mungu` | `divine_mercy_litany` |
| `https://busaradigital.com/salakatoliki/prayers/litanies/litania-ya-roho-mtakatifu` | `holy_spirit_litany` |
| `https://busaradigital.com/salakatoliki/prayers/litanies/litania-kwa-kichwa-kitakatifu-cha-yesu` | `sacred_head_of_jesus_litany` |
| `https://busaradigital.com/salakatoliki/prayers/litanies/litania-ya-mtakatifu-aloysius-gonzaga` | `st_aloysius_gonzaga_litany` |
| `https://busaradigital.com/salakatoliki/prayers/litanies/litania-ya-mtakatifu-yuda-thadei` | `st_jude_thaddeus_litany` |
| `https://busaradigital.com/salakatoliki/prayers/litanies/litania-ya-mtakatifu-yosefu` | `st_joseph_litany` |
| `https://busaradigital.com/salakatoliki/prayers/litanies/litania-ya-mtakatifu-antoni-wa-padua-toleo-la-1` | `st_anthony_of_padua_litany_v1` |
| `https://busaradigital.com/salakatoliki/prayers/litanies/litania-ya-mtakatifu-antoni-wa-padua-toleo-la-2` | `st_anthony_of_padua_litany_v2` |
| `https://busaradigital.com/salakatoliki/prayers/litanies/litania-ya-kifransiskani-ya-mtakatifu-antoni` | `franciscan_st_anthony_litany` |
| `https://busaradigital.com/salakatoliki/prayers/litanies/litania-ya-mtakatifu-ana` | `st_anne_litany` |
| `https://busaradigital.com/salakatoliki/prayers/litanies/litania-ya-malaika-watakatifu` | `holy_angels_litany` |
| `https://busaradigital.com/salakatoliki/prayers/litanies/litania-ya-moyo-mtakatifu-wa-yesu` | `sacred_heart_of_jesus_litany` |
| `https://busaradigital.com/salakatoliki/prayers/litanies/litania-ya-uso-mtakatifu-wa-yesu` | `holy_face_of_jesus_litany` |
| `https://busaradigital.com/salakatoliki/prayers/litanies/litania-ya-roho-za-toharani` | `souls_in_purgatory_litany` |
| `https://busaradigital.com/salakatoliki/prayers/litanies/litania-ya-mama-yetu-wa-mateso-saba` | `seven_sorrows_mary_litany` |
| `https://busaradigital.com/salakatoliki/prayers/litanies/litania-ya-malipizi` | `litany_of_reparation` |

### 4.5 Mass Prayers — `/prayers/mass/{slug}` → `/prayers/{prayerId}`

| Web URL | `{prayerId}` (app) |
| --- | --- |
| `https://busaradigital.com/salakatoliki/prayers/mass/kanuni-ya-imani` | `apostles_creed` |

### 4.6 Divine Mercy — `/prayers/divine-mercy/{slug}` → `/prayers/{prayerId}`

| Web URL | `{prayerId}` (app) |
| --- | --- |
| `https://busaradigital.com/salakatoliki/prayers/divine-mercy/baba-wa-milele` | `divine_mercy_eternal_father` ⚠️ see note A |
| `https://busaradigital.com/salakatoliki/prayers/divine-mercy/kwa-ajili-ya-mateso-makali` | `divine_mercy_small_bead_prayer` |
| `https://busaradigital.com/salakatoliki/prayers/divine-mercy/mungu-mtakatifu-mwenye-enzi-mwenye-milele` | `divine_mercy_closing_prayer` |

> **Note A — EN/SW ID mismatch:** `divine_mercy_eternal_father` exists only in EN; Swahili uses the equivalent ID `divine_mercy_prayer` ("Baba wa Milele"). The web must serve **one canonical page** — `baba-wa-milele` — that deep-links into that screen. Resolving this is a pre-release item.

---

## 5. Novenas

### 5.1 Novena index — `/prayers/novena/`

| Web URL | App route |
| --- | --- |
| `https://busaradigital.com/salakatoliki/prayers/novena/` | `/novenas` |

### 5.2 Novena detail — `/prayers/novena/{slug}` → `/novenas/{novenaId}`

| Web URL | `{novenaId}` (app) |
| --- | --- |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-watakatifu-wote` | `all_saints_day_novena` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-huruma-ya-mungu` | `divine_mercy_novena` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-familia-takatifu` | `holy_family_novena` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-kwa-roho-mtakatifu` | `holy_spirit_novena` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-litania-ya-tumaini` | `litany_of_trust_novena` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-kwa-moyo-mtakatifu-wa-yesu` | `sacred_heart_of_jesus_novena` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-mtakatifu-aloysius-gonzaga` | `st_aloysius_gonzaga_novena` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-mtakatifu-yuda` | `st_jude_novena` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-mt-rita-wa-kashia` | `st_rita_novena` |

### 5.3 Novena day — `/prayers/novena/{slug}/day/{day}` → `/novenas/{novenaId}/day/{day}`

Pattern per novena:

| Web URL pattern | App route |
| --- | --- |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-watakatifu-wote/day/{day}` | `/novenas/all_saints_day_novena/day/{day}` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-huruma-ya-mungu/day/{day}` | `/novenas/divine_mercy_novena/day/{day}` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-familia-takatifu/day/{day}` | `/novenas/holy_family_novena/day/{day}` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-kwa-roho-mtakatifu/day/{day}` | `/novenas/holy_spirit_novena/day/{day}` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-litania-ya-tumaini/day/{day}` | `/novenas/litany_of_trust_novena/day/{day}` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-kwa-moyo-mtakatifu-wa-yesu/day/{day}` | `/novenas/sacred_heart_of_jesus_novena/day/{day}` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-mtakatifu-aloysius-gonzaga/day/{day}` | `/novenas/st_aloysius_gonzaga_novena/day/{day}` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-mtakatifu-yuda/day/{day}` | `/novenas/st_jude_novena/day/{day}` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-mt-rita-wa-kashia/day/{day}` | `/novenas/st_rita_novena/day/{day}` |

> Day range: `1..9` by default. **Exception:** `st_rita_novena` is 12 days → `1..12` (see IMPLEMENTATION_PLAN.md reconciliation item 2).

### 5.4 Novena closing prayer — `/prayers/novena/{slug}/closing-prayer` → `/novenas/{novenaId}/closing-prayer`

Pattern per novena:

| Web URL pattern | App route |
| --- | --- |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-watakatifu-wote/closing-prayer` | `/novenas/all_saints_day_novena/closing-prayer` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-huruma-ya-mungu/closing-prayer` | `/novenas/divine_mercy_novena/closing-prayer` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-familia-takatifu/closing-prayer` | `/novenas/holy_family_novena/closing-prayer` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-kwa-roho-mtakatifu/closing-prayer` | `/novenas/holy_spirit_novena/closing-prayer` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-litania-ya-tumaini/closing-prayer` | `/novenas/litany_of_trust_novena/closing-prayer` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-kwa-moyo-mtakatifu-wa-yesu/closing-prayer` | `/novenas/sacred_heart_of_jesus_novena/closing-prayer` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-mtakatifu-aloysius-gonzaga/closing-prayer` | `/novenas/st_aloysius_gonzaga_novena/closing-prayer` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-mtakatifu-yuda/closing-prayer` | `/novenas/st_jude_novena/closing-prayer` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-mt-rita-wa-kashia/closing-prayer` | `/novenas/st_rita_novena/closing-prayer` |

### 5.5 Novena thanksgiving — `/prayers/novena/{slug}/thanksgiving` → `/novenas/{novenaId}/thanksgiving`

Pattern per novena:

| Web URL pattern | App route |
| --- | --- |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-watakatifu-wote/thanksgiving` | `/novenas/all_saints_day_novena/thanksgiving` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-huruma-ya-mungu/thanksgiving` | `/novenas/divine_mercy_novena/thanksgiving` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-familia-takatifu/thanksgiving` | `/novenas/holy_family_novena/thanksgiving` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-kwa-roho-mtakatifu/thanksgiving` | `/novenas/holy_spirit_novena/thanksgiving` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-litania-ya-tumaini/thanksgiving` | `/novenas/litany_of_trust_novena/thanksgiving` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-kwa-moyo-mtakatifu-wa-yesu/thanksgiving` | `/novenas/sacred_heart_of_jesus_novena/thanksgiving` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-mtakatifu-aloysius-gonzaga/thanksgiving` | `/novenas/st_aloysius_gonzaga_novena/thanksgiving` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-mtakatifu-yuda/thanksgiving` | `/novenas/st_jude_novena/thanksgiving` |
| `https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-mt-rita-wa-kashia/thanksgiving` | `/novenas/st_rita_novena/thanksgiving` |

---

## 6. Rosary

### 6.1 Rosary index / mystery select

| Web URL | App route |
| --- | --- |
| `https://busaradigital.com/salakatoliki/prayers/rosary/` | `/rosary` (start) · `/rosary/select` (mystery selection) |

### 6.2 Rosary mysteries — `/prayers/rosary/{slug}` → `/rosary/step/{mysteryId}`

| Web URL | `{mysteryId}` (app) |
| --- | --- |
| `https://busaradigital.com/salakatoliki/prayers/rosary/rozari-ya-huruma-ya-mungu` | `divine_mercy_rosary` |
| `https://busaradigital.com/salakatoliki/prayers/rosary/matendo-ya-furaha` | `joyful_mysteries` |
| `https://busaradigital.com/salakatoliki/prayers/rosary/matendo-ya-uchungu` | `sorrowful_mysteries` |
| `https://busaradigital.com/salakatoliki/prayers/rosary/matendo-ya-utukufu` | `glorious_mysteries` |
| `https://busaradigital.com/salakatoliki/prayers/rosary/matendo-ya-mwanga` | `luminous_mysteries` |

> Rosary step prayers themselves (`rosary_prayers.json`) are references to existing prayer IDs (e.g. `apostles_creed`); they have no separate URLs — they deep-link to the same prayer screens listed in section 4.

---

## 7. App-only surfaces (no web pages)

These routes exist in the app but should **not** be indexed (no useful crawlable content, or duplicate of others):

| App route | Reason |
| --- | --- |
| `/startup` | Loading gate; not user content |
| `/onboarding` | First-launch flow; no content |
| `/settings` | App settings UI |
| `/about` | App metadata; optionally one page later |
| `/favorites` | Personal user data; must not be indexed |
| `/library` | Redirects to `/settings` in app |

---

## 8. Indexing infrastructure (fixed locations)

| Asset | Location |
| --- | --- |
| Sitemap | `https://busaradigital.com/salakatoliki/sitemap.xml` |
| App Links verification | `https://busaradigital.com/.well-known/assetlinks.json` |

---

## 9. Sync rules (for the web build and later app work)

1. **Web URL slug ↔ app ID** must remain 1:1 per the tables above. If a prayer ID or title changes, update this file first.
2. Every web page must carry `<link rel="alternate" android-app="com.busaradigital.salakatoliki/reference">` pointing at the same web URL, so Google maps page ↔ screen.
3. Language is resolved by the app (device/selected language); web pages serve EN + SW content with `hreflang` alternates on a **single** URL — no `/en/` or `/sw/` path prefixes.
4. `st_rita_novena` exception: day range `1..12`, all other novenas `1..9`.
5. **Known to fix (Note A):** `divine_mercy_eternal_father` / `divine_mercy_prayer` EN–SW ID mismatch — consolidate to one canonical web URL `baba-wa-milele`.

*Sala Katoliki · Busara Digital — generated from real app content, 2026-09-06.*