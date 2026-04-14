{{ config(
    materialized='incremental',
    unique_key='marketing_id',
    incremental_strategy='merge',
    cluster_by=['date']
) }}



SELECT
    "MARKETING_ID"        AS marketing_id,
    "DATE"                AS date,

    "CAMPAIGN_ID"         AS campaign_id,
    "CHANNEL_ID"          AS channel_id,
    "LOCATION_ID"         AS location_id,

    "SPEND_AMOUNT"        AS spend_amount,
    "IMPRESSIONS"         AS impressions,
    "CLICKS"              AS clicks,
    "CONVERSIONS"         AS conversions,

    "REVENUE_GENERATED"   AS revenue_generated,

    "CAMPAIGN_NAME"       AS campaign_name,
    "CAMPAIGN_TYPE"       AS campaign_type,
    "OBJECTIVE"           AS objective,

    "CHANNEL_TYPE"        AS channel_type,
    "DESCRIPTION"         AS description,

    "STATE"               AS state,
    "CITY"                AS city,

    "_LOADED_AT"          AS _loaded_at

 from {{ source('ecommerce_landing', 'raw_marketing') }}



{% if is_incremental() %}

WHERE date > (
    SELECT COALESCE(MAX(date), '1900-01-01'::TIMESTAMP_TZ)
    FROM {{ this }}
)

{% endif %}