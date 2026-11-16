WITH medium_funnel AS (
  SELECT
    traffic_source.medium AS medium,
    COUNT(DISTINCT CASE WHEN event_name = 'view_item'        THEN user_pseudo_id END) AS views,
    COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart'      THEN user_pseudo_id END) AS add_to_carts,
    COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout'   THEN user_pseudo_id END) AS checkouts,
    COUNT(DISTINCT CASE WHEN event_name = 'add_payment_info' THEN user_pseudo_id END) AS payment_infos,
    COUNT(DISTINCT CASE WHEN event_name = 'purchase'         THEN user_pseudo_id END) AS purchases
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name IN ('view_item', 'add_to_cart', 'begin_checkout', 'add_payment_info', 'purchase')
  GROUP BY medium
)
SELECT
  *,
  ROUND(100 * SAFE_DIVIDE(purchases, views), 1) AS conversion_rate
FROM medium_funnel
ORDER BY conversion_rate DESC;