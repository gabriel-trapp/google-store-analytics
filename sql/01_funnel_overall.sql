-- Purchase funnel on the whole period (Nov 2020 – Jan 2021)
-- Counts distinct users who reached each step of the funnel.

SELECT
  event_name,
  COUNT(DISTINCT user_pseudo_id) AS users
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE event_name IN ('view_item', 'add_to_cart', 'begin_checkout', 'add_payment_info', 'purchase')
GROUP BY event_name
ORDER BY CASE event_name
           WHEN 'view_item'        THEN 1
           WHEN 'add_to_cart'      THEN 2
           WHEN 'begin_checkout'   THEN 3
           WHEN 'add_payment_info' THEN 4
           WHEN 'purchase'         THEN 5
         END;