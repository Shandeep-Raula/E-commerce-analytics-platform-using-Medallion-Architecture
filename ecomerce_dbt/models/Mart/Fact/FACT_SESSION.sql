{{ config(
    materialized='incremental',
    schema='GOLD',
    incremental_strategy='append',
    cluster_by=['session_date'],
    tags=['fact', 'session']
) }}


SELECT
    session_id,
    customer_id,
    channel_id,
    session_date,

    device_type,

    -- measures
    page_views,
    product_views,
    add_to_cart_count,
    wishlist_additions,
    search_count,
    checkout_attempts,
    purchases,

    exit_page_type,

    session_duration_in_sec,
    engagement_level,

    -- KPIs
    is_converted,
    add_to_cart_rate,
    checkout_conversion_rate

FROM {{ ref('INT_SESSION') }}


{% if is_incremental() %}
WHERE session_date >= (
    SELECT COALESCE(MAX(session_date), '1900-01-01')
    FROM {{ this }}
)
{% endif %}