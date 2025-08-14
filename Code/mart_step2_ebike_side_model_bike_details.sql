-- create table to keep detailed information about bikes and channels
CREATE OR REPLACE table `masteschool-gcp.analytics_marts.ebike_side_model_bike_details` as 
SELECT 
  f.session_date, 
  f.channel_type_strategic, 
  f.channel_type_tactical,
  f.bike_brand,
  f.bike_type,
  f.bike_insurance
FROM `masteschool-gcp.Analytics_integration.step1_merge_all_tables` AS f
where f.session_is_conversion = 1 
