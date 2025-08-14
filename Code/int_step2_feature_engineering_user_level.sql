CREATE OR REPLACE TABLE `masteschool-gcp.Analytics_integration.step2_feature_engineering_user_level` as
with create_session_counter as (SELECT 
  *,
  -- create counter for sessions for identify user_length_journey
  ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY session_id ASC) AS session_number
FROM `masteschool-gcp.Analytics_integration.step1_merge_all_tables` 
),
-- prepare aggregation on user level
prepare_user_level_aggregation as (
  select 
    * except(channel_type_tactical),
    -- clean column channel_type_tactical
    case when channel_type_tactical = 'direct' then 'Direct' else channel_type_tactical end 
      as channel_type_tactical,
    -- new column for days between session and leasing start date
    DATE_DIFF(contract_start_date, session_date, DAY) 
      as days_between_session_and_leasing_start,
    -- flag to identify a session as conversion session
    CASE WHEN leasing_contract_id IS NOT NULL THEN 1 ELSE 0 END 
      AS is_conversion_session,
    -- remember incoming channels
    case 
      when session_number = 1 
      then channel_type_strategic
      else null
    end as channel_incoming_strategic,
    case 
      when session_number = 1 
      then channel_type_tactical
      else null
    end as channel_incoming_tactical,
    -- remember closing channels if any
    case 
      when leasing_contract_id is not null 
      then channel_type_strategic
      else null
    end as channel_closing_strategic,
    case 
      when leasing_contract_id is not null 
      then channel_type_tactical
      else null
    end as channel_closing_tactical
  from create_session_counter
),
-- identify first conversion session and flag if user has ever converted
identify_first_conversion_session_number as (
  select
    user_id,
    -- remember year of first session
    min(session_date) as user_first_session_date,
    coalesce(count(session_id),0) as session_id_count,
    coalesce(sum(session_is_conversion),0) as conversions_sum,
    coalesce(sum(leasing_contract_activ),0) as leasing_contracts_still_activ_sum,
    coalesce(sum(days_between_session_and_leasing_start),0) as days_between_session_and_leasing_start_sum,
    coalesce(sum(case when bike_type = 'Fahrrad' then 1 else 0 end),0) as bike_type_manual_sum,
    coalesce(sum(case when bike_type like '%25%' then 1 else 0 end),0) as bike_type_pedelec25_sum,
    coalesce(sum(case when bike_type like '%45%' then 1 else 0 end),0) as bike_type_pedelec45_sum,
    coalesce(sum(bike_price_gross),0) as bike_price_gross_sum,
    -- Find the first session where a conversion occurred
    MIN(CASE WHEN is_conversion_session = 1 THEN session_number ELSE NULL END) AS first_conversion_session_number,
    MAX(CASE WHEN is_conversion_session = 1 THEN 1 ELSE 0 END) AS user_ever_converted, -- <<<<<<< ----
    MAX(session_number) AS total_sessions, 
    -- identify incoming_channel for later calculation of attribution model
    max(channel_incoming_strategic) as channel_incoming_strategic_max,
    max(channel_incoming_tactical) as channel_incoming_tactical_max,      
    -- identify first closing_channel for later calculation of attribution model. later conversion channels will not be used 
    max(channel_closing_strategic) as channel_closing_strategic_max,
    max(channel_closing_tactical) as channel_closing_tactical_max,
    coalesce(CAST(sum(ad_costs) AS NUMERIC),0) as ad_costs_sum,
    sum(case when user_device_type = "Desktop" then 1 else 0 end) as device_is_desktop_count,
    sum(case when user_device_type = "Mobile" then 1 else 0 end) as device_is_mobile_count
  from prepare_user_level_aggregation
  group by user_id
),
-- calculate user journey length in number of sessions
calculate_user_journey_length as ( 
select 
  *,
  CASE
    WHEN user_ever_converted = 1 
    THEN first_conversion_session_number
    ELSE total_sessions
  END AS journey_length_in_sessions  
from identify_first_conversion_session_number
)
select *
from calculate_user_journey_length
;
