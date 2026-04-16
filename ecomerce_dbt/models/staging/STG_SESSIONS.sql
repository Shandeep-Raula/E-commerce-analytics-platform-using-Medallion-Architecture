{{ config(
    materialized='table',
    unique_key='session_id'
) }}

SELECT
    session_id,
    customer_id,
    channel_id,
    date,

    device_type,
    exit_page_type,

    page_views,
    product_views,
    add_to_cart_count,
    wishlist_additions,
    search_count,
    checkout_attempts,
    purchases,

    session_duration_in_sec,

    _ab_cdc_updated_at 

FROM {{ source('ecommerce_landing', 'raw_sessions') }}

