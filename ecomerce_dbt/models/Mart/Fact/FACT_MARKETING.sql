{{ config(
    materialized='incremental',
    schema='GOLD',
    unique_key='marketing_id',
    incremental_strategy='merge',
    cluster_by=['event_date'],
    tags=['fact', 'marketing']
) }}



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

    ctr,
    cpc,
    cpa,
    conversion_rate,
    roas,
    cpm,
    rpc,

    campaign_name,
    campaign_type,
    objective,
    channel_type,
    description,
    state,
    city

from {{ ref('INT_MARKETING_EVENT') }}


