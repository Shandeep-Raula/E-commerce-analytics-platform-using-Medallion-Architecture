{{ config(
    materialized='incremental',
    unique_key='order_line_id',
    incremental_strategy='merge',
    cluster_by=['order_date']
) }}

with base as (

    select 
        order_line_id,
        order_id,
        order_date,

        customer_id,
        product_id,
        seller_id,
        location_id,
        delivery_person_id,
        payment_id,
        campaign_id,
        fulfillment_id,

        quantity,
        unit_price,
        discount_percentage,
        tax_percentage,
        shipping_fee,

        expected_delivery_date,
        actual_delivery_date,
        return_date,

        UPPER(TRIM(order_status)) AS order_status,
        return_flag,
        ABS(refund_amount) AS refund_amount,

        delivery_rating,
        seller_rating,
        customer_rating,

 

        INITCAP(TRIM(review_text)) AS review_text,
        sentiment_score,


        payment_details,

        _loaded_at,
        ROW_NUMBER() OVER (PARTITION BY order_line_id ORDER BY _loaded_at DESC) as rn

    FROM {{ ref('STG_ORDERS') }}

),

deduped as (
    select 
        order_line_id,
        order_id,
        order_date,
        customer_id,
        product_id,
        seller_id,
        location_id,
        delivery_person_id,
        payment_id,
        campaign_id,
        fulfillment_id,
        quantity,
        unit_price,
        discount_percentage,
        tax_percentage,
        shipping_fee,
        expected_delivery_date,
        actual_delivery_date,
        return_date,
        order_status,
        return_flag,
        refund_amount,
        delivery_rating,
        seller_rating,
        customer_rating,
        review_text,
        sentiment_score,
        payment_details,
        _loaded_at
    from base 
    where rn = 1
)
select
        order_line_id,
        order_id,
        order_date,

        customer_id,
        product_id,
        seller_id,
        location_id,
        delivery_person_id,
        payment_id,
        campaign_id,
        fulfillment_id,
        quantity,
        unit_price,


        {{calculate_gross_amount('quantity', 'unit_price')}} AS gross_amount,
        discount_percentage,
        {{calculate_discount_amount('quantity', 'unit_price', 'discount_percentage')}} AS discount_amount,
        tax_percentage,
        {{calculate_tax_amount('quantity', 'unit_price', 'discount_percentage', 'tax_percentage')}} AS tax_amount,
        shipping_fee,
        {{calculate_order_value('quantity', 'unit_price', 'discount_percentage', 'tax_percentage', 'shipping_fee')}} AS order_value,


        expected_delivery_date,
        actual_delivery_date,
        return_date,
        {{calculate_delay('expected_delivery_date', 'actual_delivery_date')}} AS delivery_delay,

        order_status,
        {{return_flag('return_flag')}} AS return_flag,
        {{calculate_refund_amount('quantity', 'unit_price', 'discount_percentage', 'tax_percentage', 'shipping_fee', 'refund_amount')}} AS refund_amount,

        delivery_rating,
        seller_rating,
        customer_rating,

        review_text,
        sentiment_score,

        payment_details

from deduped

{% if is_incremental() %}
    where order_date > (select max(order_date) from {{ this }})
{% endif %}



