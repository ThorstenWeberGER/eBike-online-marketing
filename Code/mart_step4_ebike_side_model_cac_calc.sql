-- create table for customer acquisition cost calculation - only users who converted

CREATE OR REPLACE TABLE `masteschool-gcp.analytics_marts.ebike_side_model_cac_calc` as
SELECT
  user_first_session_date,
  user_ever_converted,
  count(distinct user_id) as user_count
FROM `masteschool-gcp.Analytics_integration.step2_feature_engineering_user_level`
group by user_first_session_date, user_ever_converted
order by user_first_session_date, user_ever_converted
;
