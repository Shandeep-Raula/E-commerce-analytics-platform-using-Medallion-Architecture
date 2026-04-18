{{ config(
    materialized='incremental',
    schema='GOLD',
    unique_key='order_line_id',
    incremental_strategy='merge',
    cluster_by=['order_date'],
    tags=['fact', 'feedback']
) }}

SELECT 
    order_line_id,
    order_date,
    seller_rating,
    customer_rating,
    review_text,
    sentiment_score

FROM {{ ref('ENRICHED_ORDER') }}