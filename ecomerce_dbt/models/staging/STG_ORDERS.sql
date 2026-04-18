{{ config(
    materialized='incremental',
    unique_key='order_line_id',
    incremental_strategy='merge',
    cluster_by=['order_date']
) }}


select 
"ORDER_LINE_ID"              AS order_line_id,
    "ORDER_ID"                   AS order_id,
    "ORDER_DATE"                 AS order_date,
    "CUSTOMER_ID"                AS customer_id,
    "PRODUCT_ID"                 AS product_id,
    "SELLER_ID"                  AS seller_id,
    "LOCATION_ID"                AS location_id,
    "DELIVERY_PERSON_ID"         AS delivery_person_id,
    "PAYMENT_ID"                 AS payment_id,
    "CAMPAIGN_ID"                AS campaign_id,
    "FULFILLMENT_ID"             AS fulfillment_id,

    "QUANTITY"                   AS quantity,
    "UNIT_PRICE"                 AS unit_price,
    "DISCOUNT_PERCENTAGE"        AS discount_percentage,
    "TAX_PERCENTAGE"             AS tax_percentage,
    "SHIPPING_FEE"               AS shipping_fee,

    "EXPECTED_DELIVERY_DATE"     AS expected_delivery_date,
    "ACTUAL_DELIVERY_DATE"       AS actual_delivery_date,
    "RETURN_DATE"                AS return_date,

    "DELIVERY_RATING"            AS delivery_rating,
    "SELLER_RATING"              AS seller_rating,
    "CUSTOMER_RATING"            AS customer_rating,

    "ORDER_STATUS"               AS order_status,
    "RETURN_FLAG"                AS return_flag,
    "REFUND_AMOUNT"              AS refund_amount,
    "REVIEW_TEXT"                AS review_text,
    "SENTIMENT_SCORE"            AS sentiment_score,
    "PAYMENT_DETAILS"            AS payment_details,
    "DELIVERY_DELAY_DAYS"        AS delivery_delay_days,
    "DELIVERY_SLA_DAYS"          AS delivery_sla_days,

    "_LOADED_AT"                 AS _loaded_at



 from {{ source('ecommerce_landing', 'raw_order') }}



{% if is_incremental() %}

WHERE order_date > (
    SELECT COALESCE(MAX(order_date), '1900-01-01'::TIMESTAMP_TZ)
    FROM {{ this }}
)

{% endif %}