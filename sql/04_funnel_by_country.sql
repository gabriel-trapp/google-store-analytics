-- Purchase funnel for the top 10 countries (by product viewers)
-- One row per country, one column per funnel step, plus overall conversion rate (%).

SELECT geo.country AS country, 
    COUNT(DISTINCT CASE WHEN event_name = 'view_item'        THEN user_pseudo_id END) AS views,
    COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart'      THEN user_pseudo_id END) AS add_to_carts,
    COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout'   THEN user_pseudo_id END) AS checkouts,
    COUNT(DISTINCT CASE WHEN event_name = 'add_payment_info' THEN user_pseudo_id END) AS payment_infos,
    COUNT(DISTINCT CASE WHEN event_name = 'purchase'         THEN user_pseudo_id END) AS purchases,
    ROUND(SAFE_DIVIDE(COUNT(DISTINCT CASE WHEN event_name = 'purchase'         THEN user_pseudo_id END), COUNT(DISTINCT CASE WHEN event_name = 'view_item'        THEN user_pseudo_id END)) * 100, 1) AS conversion_rate
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name IN ('view_item', 'add_to_cart', 'begin_checkout', 'add_payment_info', 'purchase')
  GROUP BY geo.country
  ORDER BY views DESC, add_to_carts DESC, checkouts DESC, payment_infos DESC, purchases DESC
LIMIT 10;