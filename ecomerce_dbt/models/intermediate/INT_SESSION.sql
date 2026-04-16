{{ config(
    materialized='incremental',
    unique_key='session_id',
    incremental_strategy='merge'
) }}

WITH base AS (

    SELECT
        session_id,
        customer_id,
        channel_id,
        TRY_TO_DATE(date) AS session_date,

        UPPER(TRIM(device_type)) AS device_type,

        page_views,
        product_views,
        add_to_cart_count,
        wishlist_additions,
        search_count,
        checkout_attempts,
        purchases,

        
        UPPER(TRIM(exit_page_type)) AS exit_page_type,

        session_duration_in_sec


    FROM {{ ref('STG_SESSIONS') }}

),

enriched AS (

    SELECT
        *,

        --  Conversion flag
        CASE 
            WHEN purchases > 0 THEN 1 ELSE 0
        END AS is_converted,

        --  Add-to-cart rate
        CASE 
            WHEN product_views > 0 
            THEN add_to_cart_count / product_views
            ELSE 0
        END AS add_to_cart_rate,

        --  Checkout conversion rate
        CASE 
            WHEN checkout_attempts > 0 
            THEN purchases / checkout_attempts
            ELSE 0
        END AS checkout_conversion_rate,

        --  Engagement level
        CASE 
            WHEN session_duration_in_sec > 3000 THEN 'High'
            WHEN session_duration_in_sec > 1000 THEN 'Medium'
            ELSE 'Low'
        END AS engagement_level

    FROM base

)

SELECT *
FROM enriched

{% if is_incremental() %}
-- prevent reprocessing same sessions
WHERE session_id NOT IN (SELECT session_id FROM {{ this }})
{% endif %}