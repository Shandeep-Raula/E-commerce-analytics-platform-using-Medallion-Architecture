{{ config(
    materialized='incremental',
    unique_key='marketing_id',
    incremental_strategy='merge',
    cluster_by=['event_date']
) }}


WITH marketing AS (

SELECT
    marketing_id,
    TO_DATE(date) AS event_date,

    campaign_id,
    channel_id,
    location_id,

    CAST(spend_amount AS NUMBER(10,2))        AS spend_amount,
    CAST(impressions AS NUMBER(12,0))         AS impressions,
    CAST(clicks AS NUMBER(12,0))              AS clicks,
    CAST(conversions AS NUMBER(12,0))         AS conversions,

    CAST(revenue_generated AS NUMBER(10,2))   AS revenue_generated,

    campaign_name,
    campaign_type,
    objective,

    channel_type,
    description,

    state,
    city

FROM {{ ref('STG_MARKETING') }}

)

select 
  marketing_id,
  event_date,
  campaign_id,
  channel_id,
  location_id,
  spend_amount,
 impressions,
 clicks,
    conversions,
    revenue_generated,

    {{ calculate_ctr('clicks', 'impressions') }} AS ctr,
    {{ calculate_cpc('spend_amount', 'clicks') }} AS cpc,
    {{ calculate_cpa('spend_amount', 'conversions') }} AS cpa,
    {{ calculate_cvr('conversions', 'clicks') }} AS conversion_rate,
    {{ calculate_roas('revenue_generated', 'spend_amount') }} AS roas,
    {{ calculate_cpm('spend_amount', 'impressions') }} AS cpm,
    {{ calculate_rpc('revenue_generated', 'clicks') }} AS rpc,

    INITCAP(TRIM(campaign_name)) AS campaign_name,
    
    UPPER(TRIM(campaign_type)) AS campaign_type,
    UPPER(TRIM(objective)) AS objective,

    UPPER(TRIM(channel_type)) AS channel_type,
    INITCAP(TRIM(description)) AS description,

    UPPER(TRIM(state)) AS state,
    UPPER(TRIM(city)) AS city

from marketing




{% if is_incremental() %}

WHERE event_date > (
    SELECT COALESCE(MAX(event_date), '1900-01-01')
    FROM {{ this }}
)

{% endif %}