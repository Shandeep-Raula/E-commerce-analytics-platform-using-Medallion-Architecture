{{ config(
    materialized='incremental',
    schema='GOLD',
    unique_key='order_line_id',
    incremental_strategy='merge',
    cluster_by=['expected_delivery_date'],
    tags=['fact', 'delivery']
) }}

WITH dedup AS (

    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY order_line_id 
            ORDER BY order_date DESC
        ) AS rn
    FROM {{ ref('ENRICHED_ORDER') }}

)

SELECT 
    order_line_id,
    delivery_person_id,
    order_date,
    expected_delivery_date,
    actual_delivery_date,
    delivery_delay,
    {{ delivery_delay_category('delivery_delay') }} AS delivery_delay_category,

    delivery_rating

FROM dedup
WHERE rn = 1