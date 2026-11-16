-- Daily trend: product viewers, buyers, conversion rate and revenue

WITH daily AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS day,
    COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN user_pseudo_id END) AS viewers,
    COUNT(DISTINCT CASE WHEN event_name = 'purchase'  THEN user_pseudo_id END) AS buyers,
    SUM(CASE WHEN event_name = 'purchase' THEN ecommerce.purchase_revenue_in_usd END) AS revenue_usd
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  GROUP BY day
)
SELECT
  day,
  viewers,
  buyers,
  ROUND(100 * SAFE_DIVIDE(buyers, viewers), 1) AS pct_conversion,
  ROUND(revenue_usd, 0) AS revenue_usd
FROM daily
ORDER BY day;