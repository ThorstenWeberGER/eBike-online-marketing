-- create main KPI table for consumer layer
create or replace table `masteschool-gcp.analytics_marts.ebike_main_model` AS
SELECT 
  f.user_first_session_date as session_month_year,
  coalesce(count(distinct f.user_id),0) as user_count,
  coalesce(sum(journey_length_in_sessions), 0) as journey_length_in_sessions_sum,
  coalesce(sum(f.user_ever_converted),0) as user_converted_count,  -- <<<<<<<<<----
  coalesce(sum(f.session_id_count), 0) as session_count, 
  coalesce(sum(f.conversions_sum),0) as total_conversions_count,
  coalesce(sum(f.days_between_session_and_leasing_start_sum),0) as days_between_session_and_leasing_start_sum,
  coalesce(sum(bike_type_manual_sum), 0) as bike_type_manual_sum,
  coalesce(sum(bike_type_pedelec25_sum), 0) as bike_type_pedelec25_sum,
  coalesce(sum(bike_type_pedelec45_sum), 0) as bike_type_pedelec45_sum,
  coalesce(sum(bike_price_gross_sum),0) as bike_price_gross_sum,
  f.channel_incoming_strategic_max as channel_incoming_strategic, 
  f.channel_incoming_tactical_max as channel_incoming_tactical,
  f.channel_closing_strategic_max as channel_closing_strategic, 
  f.channel_closing_tactical_max as channel_closing_tactical,
  coalesce(CAST(sum(f.ad_costs_sum) AS NUMERIC),0) as ad_costs_sum,
  -- note: values of benchmark_sessions and benchmark_costs are aggregated on monthly level. don't simple sum up in later processing
  coalesce(max(a.sessions_benchmarks),0) as benchmark_sessions, 
  -- increase costs to a senseful level 
  coalesce(CAST(max(a.costs_benchmarks) AS NUMERIC),0)*3000 as benchmark_costs,
  sum(f.device_is_desktop_count) as device_is_desktop_count,
  sum(f.device_is_mobile_count) as device_is_mobile_count
FROM `masteschool-gcp.Analytics_integration.step2_feature_engineering_user_level` AS f
-- now pull benchmarks as they are on monthly level
LEFT JOIN `masteschool-gcp.analytics_stage.ads_benchmarks` AS a   
  ON extract(MONTH from f.user_first_session_date) = extract(MONTH from a.date) -- joins benchmark to all channel_types and all years  
group by f.user_first_session_date, 
  f.channel_incoming_strategic_max, 
  f.channel_incoming_tactical_max,
  f.channel_closing_strategic_max, 
  f.channel_closing_tactical_max
order by f.user_first_session_date, 
  f.channel_incoming_strategic_max, 
  f.channel_incoming_tactical_max,
  f.channel_closing_strategic_max, 
  f.channel_closing_tactical_max
;
