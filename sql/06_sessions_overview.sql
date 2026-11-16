WITH events AS (SELECT user_pseudo_id,
CONCAT(user_pseudo_id, '-', CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS STRING)) AS session_id
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`)

SELECT COUNT(DISTINCT user_pseudo_id) AS nb_user,
COUNT(DISTINCT session_id) AS nb_session,
ROUND(SAFE_DIVIDE(COUNT(DISTINCT session_id), COUNT(DISTINCT user_pseudo_id)), 2) as nb_session_pr_user
FROM events;