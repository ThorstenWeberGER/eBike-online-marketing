# step 1: merge tables and do minimal trasnformation

CREATE OR REPLACE TABLE `masteschool-gcp.Analytics_integration.step1_merge_all_tables` as

SELECT
  s.user_id,
  l.account_id,
  s.session_id,
  case when s.leasing_contract_id is not null then 1 else 0 end as session_is_conversion,
  s.session_date, 
  date_trunc(s.session_date, MONTH) as session_month_year,
  s.leasing_contract_id,
  l.contract_start_date,
  l.contract_end_date,
  case 
    when lower(l.state) = 'aktiv' then 1
    when lower(l.state) = 'inaktiv' then 0
    else null
  end as leasing_contract_activ,
  l.status as user_status,
  l.bike_type,
  l.bike_brand,
  l.saleprice_gross as bike_price_gross,
  l.insurance_type as bike_insurance,
  m.channel_name as channel_type_strategic,
  s.channel as channel_type_tactical,
  s.device as user_device_type,
  s.costs as ad_costs,
FROM 
  `masteschool-gcp`.`analytics_stage`.`sessions_csv_upload` AS s
LEFT JOIN `masteschool-gcp`.`analytics_stage`.`leases` AS l 
  ON l.leasing_contract_id = s.leasing_contract_id
LEFT JOIN `masteschool-gcp`.`analytics_stage`.`mapping_channel` AS m 
  ON m.channel_code = s.channel_code
;




