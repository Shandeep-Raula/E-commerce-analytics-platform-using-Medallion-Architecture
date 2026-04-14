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

    "DELIVERY_DELAY_DAYS"        AS delivery_delay_days,
    "DELIVERY_SLA_DAYS"          AS delivery_sla_days,
    "SERVICE_LEVEL"              AS service_level,
    "VEHICLE_TYPE"               AS vehicle_type,

    "STATE"                      AS state,
    "CITY"                       AS city,
    "POSTAL_CODE"                AS postal_code,
    "LOCATION_ID_CUSTOMER"       AS location_id_customer,
    "LOCATION_ID_DELIVERY_PERSON" AS location_id_delivery_person,

    "FIRST_NAME"                 AS first_name,
    "LAST_NAME"                  AS last_name,
    "EMAIL"                      AS email,
    "PHONE_NUMBER"               AS phone_number,

    "PRODUCT_NAME"               AS product_name,
    "BRAND"                      AS brand,
    "CATEGORY_PRODUCT"           AS category_product,
    "SUB_CATEGORY"               AS sub_category,
    "LIST_PRICE"                 AS list_price,

    "DELIVERY_PERSON_NAME"       AS delivery_person_name,
    "PHONE_NUMBER_DELIVERY_PERSON" AS phone_number_delivery_person,

    "PAYMENT_METHOD"             AS payment_method,
    "PAYMENT_PROVIDER"           AS payment_provider,
    "PAYMENT_DETAILS"            AS payment_details,

    "SELLER_NAME"                AS seller_name,
    "EMAIL_SELLER"               AS email_seller,
    "PHONE_NUMBER_SELLER"        AS phone_number_seller,

    "_LOADED_AT"                 AS _loaded_at



 from {{ source('ecommerce_landing', 'raw_order') }}



{% if is_incremental() %}

WHERE order_date > (
    SELECT COALESCE(MAX(order_date), '1900-01-01'::TIMESTAMP_TZ)
    FROM {{ this }}
)

{% endif %}