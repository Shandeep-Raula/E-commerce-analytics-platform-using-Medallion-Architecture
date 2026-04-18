{{ config(
    materialized='incremental',
    schema='GOLD',
    unique_key='order_line_id',
    incremental_strategy='merge',
    cluster_by=['order_date'],
    tags=['fact', 'order']
) }}

select 
    order_line_id,
    order_id,
    order_date,

    customer_id,
    product_id,
    seller_id,
    location_id,
    payment_id,
    campaign_id,
    fulfillment_id,

    quantity,
    unit_price,
    gross_amount,
    discount_percentage,
    discount_amount,
    tax_percentage,
    tax_amount,
    shipping_fee,
    order_value,

    order_status,
    return_flag,
    refund_amount,

    payment_details

from {{ ref('ENRICHED_ORDER') }}

