-- calculate conversion rate by journey_length_sessions
CREATE OR REPLACE TABLE `masteschool-gcp.analytics_marts.ebike_side_model_conversions_by_user_journey` as
SELECT
    f.user_first_session_date,
    f.channel_incoming_strategic_max as channel_incoming_strategic, 
    --f.channel_incoming_tactical_max as channel_incoming_tactical,
    --f.channel_closing_strategic_max as channel_closing_strategic, 
    --f.channel_closing_tactical_max as channel_closing_tactical,
    f.journey_length_in_sessions,
    COUNT(distinct f.user_id) AS total_users,
    SUM(f.user_ever_converted) AS users_conversions,
    (COUNT(distinct f.user_id) - SUM(f.user_ever_converted)) AS users_non_conversions,
    CAST(SUM(f.user_ever_converted) AS DECIMAL) * 100.0 / COUNT(distinct user_id) 
        AS conversion_rate_percentage
FROM `masteschool-gcp.Analytics_integration.step2_feature_engineering_user_level` as f
GROUP BY
    f.user_first_session_date,
    f.channel_incoming_strategic_max, 
    --f.channel_incoming_tactical_max,
    --f.channel_closing_strategic_max, 
    --f.channel_closing_tactical_max,
    f.journey_length_in_sessions
ORDER BY
    f.user_first_session_date,
    f.channel_incoming_strategic_max, 
    --f.channel_incoming_tactical_max,
    --f.channel_closing_strategic_max, 
    --f.channel_closing_tactical_max,
    f.journey_length_in_sessions
;

--- the above calculation could be done in looker directly, so i do not need to safe the table results