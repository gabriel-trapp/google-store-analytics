# Google Merchandise Store — Product Analytics

Where does the Google Merchandise Store lose its customers, and what should it test first?

## Data
Google Analytics 4 export of the Google Merchandise Store (Nov 2020 – Jan 2021),
public BigQuery dataset `bigquery-public-data.ga4_obfuscated_sample_ecommerce`.
One row per event (page view, product view, add to cart, purchase…).

## Tools
SQL (BigQuery): conditional aggregation, CTEs, `UNNEST` on nested GA4 parameters, session-level funnel.
Python (pandas, SciPy, statsmodels): two-proportion z-tests, confidence intervals, Bonferroni correction.

## Key findings
1. **Most visitors never reach the funnel.** Only about 23% of visitors (61,252 out of 270,154) view at least one product page.
2. **Only 7.2% of product viewers buy**, and the most unusual loss happens at checkout: 4 in 10 users who start checking out leave before entering their payment details, on every device. This makes the checkout process the **first candidate for an A/B test**.
3. **Many purchases take several visits.** Measured within a single session, conversion falls to 3.6%, and almost all the gap sits between cart and checkout: visitors add items in one visit and come back later to buy. Cart-recovery features (saved carts, reminder emails) could be valuable.
4. **Black Friday – Cyber Monday raised conversion from 6.2% to 10.3%** (+4.2 pts, 95% CI +3.0 to +5.3; z = 8.4, p < 0.001).
5. **Paid ads convert the least** (4.8%), while referral traffic converts the most (8.1%).

## 1. Purchase funnel
Users reaching each step (distinct users, whole period):

| Step | Users | Conversion from previous step |
| --- | --- | --- |
| View product | 61,252 | — |
| Add to cart | 12,545 | 20.5% |
| Begin checkout | 9,715 | 77.4% |
| Add payment info | 5,751 | 59.2% |
| Purchase | 4,419 | 76.8% |

- The largest drop happens at the first step (only 20.5% add a product to their cart), but the most unusual loss happens during checkout.
- Overall conversion by device: desktop 7.0%, mobile 7.5%, tablet 6.7%. The checkout drop is almost identical across devices, which suggests the issue lies in the checkout process itself (e.g. unexpected shipping costs or a mandatory account) rather than in the mobile experience.

## 2. Funnel by country
Conversion rates across the top 10 countries range from 5.7% (Italy) to 7.7% (France), a wider spread than across devices (6.7% to 7.5%). The United States accounts for about 44% of product viewers, so it drives the overall rate. A significance test shows that even the widest gap, France vs Italy, is not significant (p = 0.07): conversion is essentially the same across the top 10 countries.

## 3. Funnel by traffic source
Medium of the user's first visit (`traffic_source.medium`):

| Medium | Product viewers | Conversion |
| --- | --- | --- |
| organic (Google search) | 24,077 | 5.5% |
| (none) (direct) | 16,492 | 6.4% |
| referral (link from another site) | 12,730 | 8.1% |
| cpc (paid ads) | 3,156 | 4.8% |
| \<Other\> | 10,439 | 4.8% |
| (data deleted) | 4,994 | 13.8% |

- Referral traffic converts best; paid ads bring few visitors and convert the least. Judging their profitability would require ad cost data.
- `<Other>` and `(data deleted)` come from the dataset's obfuscation and cannot be interpreted.

## 4. Sessions and strict funnel
- 270,154 visitors made 360,129 sessions (1.33 sessions per user): most visitors come only once.
- Only about 23% of visitors view at least one product page: more than 3 out of 4 leave without looking at a single product. This drop happens before the purchase funnel even starts, which suggests the homepage and navigation are worth investigating.

The funnel above counts users over three months, regardless of the order of steps. The **strict funnel** only counts sessions that go through every step, in order:

| Step | Sessions | Conversion from previous step | Same step, user-level funnel |
| --- | --- | --- | --- |
| View product | 77,020 | — | — |
| Add to cart | 15,146 | 19.7% | 20.5% |
| Begin checkout | 5,293 | 34.9% | 77.4% |
| Add payment info | 3,723 | 70.3% | 59.2% |
| Purchase | 2,751 | 73.9% | 76.8% |

Strict conversion is 3.6%, half the user-level rate (7.2%). Almost all the gap sits between cart and checkout: many visitors add items in one visit and come back later to buy. The unit of analysis (user or session) must therefore always be stated.

## 5. Seasonality: Black Friday and Cyber Monday
Compared with an average day in early November (≈750 product viewers, ≈5.5% conversion, ≈$3,200 revenue):

| Day | Product viewers | Conversion | Revenue |
| --- | --- | --- | --- |
| Black Friday (Nov 27) | 827 (+10%) | 10.8% (×2) | $6,699 (×2.1) |
| Cyber Monday (Nov 30) | 1,117 (+49%) | 11.3% (×2.1) | $11,990 (×3.8) |

- On Black Friday, traffic barely increases, but **conversion doubles**: the revenue gain comes from existing visitors buying more, not from more visitors.
- Cyber Monday combines more traffic **and** higher conversion, nearly quadrupling daily revenue.
- Revenue collapses around December 20, consistent with the last shipping date before Christmas.

Over whole periods (distinct users):

| Period | Days | Product viewers | Purchasers | Conversion |
| --- | --- | --- | --- | --- |
| Normal (Nov 1–20) | 20 | 14,041 | 866 | 6.2% |
| Black Friday – Cyber Monday (Nov 27–30) | 4 | 3,225 | 333 | 10.3% |

Conversion rose from 6.2% to 10.3%. Since the shorter window gives the promotion period less time to capture late purchases, the true uplift is, if anything, understated.

## Caveats
- The dataset is a partially obfuscated sample.
- Funnels 1 to 3 count users at each step without checking that they went through every previous step in order (see the strict funnel in section 4).
- Traffic-source groups overlap: some users appear under several mediums, so the groups cannot be added up.
- The Black Friday comparison is observational (not randomized), and a user can appear in both periods.

## Queries
- [`sql/01_funnel_overall.sql`](sql/01_funnel_overall.sql) — funnel on the whole period
- [`sql/02_funnel_by_device.sql`](sql/02_funnel_by_device.sql) — funnel by device
- [`sql/03_daily_trend.sql`](sql/03_daily_trend.sql) — daily viewers, buyers, conversion and revenue
- [`sql/04_funnel_by_country.sql`](sql/04_funnel_by_country.sql) — funnel for the top 10 countries
- [`sql/05_funnel_by_medium.sql`](sql/05_funnel_by_medium.sql) — funnel by traffic source
- [`sql/06_sessions_overview.sql`](sql/06_sessions_overview.sql) — users, sessions and sessions per user
- [`sql/07_strict_funnel_by_session.sql`](sql/07_strict_funnel_by_session.sql) — session-level funnel, steps in order
- [`sql/08_black_friday_vs_normal.sql`](sql/08_black_friday_vs_normal.sql) — conversion over Black Friday – Cyber Monday vs normal days
## Notebooks
- [`notebooks/01_significance.ipynb`](notebooks/01_significance.ipynb) — significance tests: Black Friday vs normal days, conversion by country

## Next steps
- Sample size needed for an A/B test on the checkout
- Charts in Python