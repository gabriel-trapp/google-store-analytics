# Google Merchandise Store — Product Analytics

Where does the Google Merchandise Store lose its customers, and what should it test first?

## Data
Google Analytics 4 export of the Google Merchandise Store (Nov 2020 – Jan 2021),
public BigQuery dataset `bigquery-public-data.ga4_obfuscated_sample_ecommerce`.
One row per event (page view, product view, add to cart, purchase…).

## Tools
SQL (BigQuery)

## First results: purchase funnel
Users reaching each step (distinct users, whole period):

| Step | Users | Conversion from previous step |
| --- | --- | --- |
| View product | 61,252 | — |
| Add to cart | 12,545 | 20.5% |
| Begin checkout | 9,715 | 77.4% |
| Add payment info | 5,751 | 59.2% |
| Purchase | 4,419 | 76.8% |

Overall conversion by device: desktop 7.0%, mobile 7.5%, tablet 6.7%.

## Key findings
1. Only **7.2%** of users who viewed a product went on to make a purchase (4,419 out of 61,252).
2. The largest drop happens at the first step (only 20.5% add a product to their cart), but the most unusual loss happens during checkout: **4 in 10 users** who start checking out leave before entering their payment details.
3. This checkout drop is almost identical across devices, which suggests the issue lies in the checkout process itself (e.g. unexpected shipping costs or a mandatory account) rather than in the mobile experience, making it the **first candidate for an A/B test**.

*Caveats: the dataset is a partially obfuscated sample, and this funnel counts users at each step without checking that they went through every previous step in order.*

## Seasonality: Black Friday and Cyber Monday
Compared with an average day in early November (≈750 product viewers, ≈5.5% conversion, ≈$3,200 revenue):

| Day | Product viewers | Conversion | Revenue |
| --- | --- | --- | --- |
| Black Friday (Nov 27) | 827 (+10%) | 10.8% (×2) | $6,699 (×2.1) |
| Cyber Monday (Nov 30) | 1,117 (+49%) | 11.3% (×2.1) | $11,990 (×3.8) |

- On Black Friday, traffic barely increases, but **conversion doubles**: the revenue gain comes from existing visitors buying more, not from more visitors.
- Cyber Monday combines more traffic **and** higher conversion, nearly quadrupling daily revenue.
- Revenue collapses around December 20, consistent with the last shipping date before Christmas.
- Takeaway: the main lever is **converting existing visitors better**, which is consistent with the checkout drop identified in the funnel.

## Queries
- [`sql/01_funnel_overall.sql`](sql/01_funnel_overall.sql) — funnel on the whole period
- [`sql/02_funnel_by_device.sql`](sql/02_funnel_by_device.sql) — funnel by device
- [`sql/03_daily_trend.sql`](sql/03_daily_trend.sql) — daily viewers, buyers, conversion and revenue


## Next steps
- Funnel by country, traffic source, and before/after Black Friday
- Statistical tests on the differences observed
- Customer retention and segmentation
