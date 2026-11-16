-- Purchase funnel by device category (desktop, mobile, tablet)
-- One row per device, one column per funnel step, then step-to-step conversion rates (%).

WITH funnel AS (
  SELECT
    device.category AS device,
    COUNT(DISTINCT CASE WHEN event_name = 'view_item'        THEN user_pseudo_id END) AS views,
    COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart'      THEN user_pseudo_id END) AS add_to_carts,
    COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout'   THEN user_pseudo_id END) AS checkouts,
    COUNT(DISTINCT CASE WHEN event_name = 'add_payment_info' THEN user_pseudo_id END) AS payment_infos,
    COUNT(DISTINCT CASE WHEN event_name = 'purchase'         THEN user_pseudo_id END) AS purchases
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  GROUP BY device
)
SELECT
  device, views, add_to_carts, checkouts, payment_infos, purchases,
  ROUND(100 * add_to_carts / views, 1)       AS pct_view_to_cart,
  ROUND(100 * checkouts / add_to_carts, 1)   AS pct_cart_to_checkout,
  ROUND(100 * payment_infos / checkouts, 1)  AS pct_checkout_to_payment,
  ROUND(100 * purchases / payment_infos, 1)  AS pct_payment_to_purchase,
  ROUND(100 * purchases / views, 1)          AS pct_overall
FROM funnel
ORDER BY views DESC;