{{ config(
    materialized='table',
    schema='GOLD',
    tags=['dimension', 'campaign']
) }}

select 
    campaign_id,
    campaign_name,
    campaign_type,
    objective,
    channel_id,
    MIN(event_date) AS start_date,
    MAX(event_date) AS end_date

from {{ ref('INT_MARKETING_EVENT') }}

group by
    campaign_id,
    campaign_name,
    campaign_type,
    objective,
    channel_id
order by start_date , campaign_id

