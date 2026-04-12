{{ config(
    materialized='incremental',
    incremental_strategy='append',
    unique_key='customer_id'
) }}

SELECT
    "customer_id"        AS customer_id,
    "first_name"         AS first_name,
    "last_name"          AS last_name,
    "email"              AS email,
    "phone_number"       AS phone_number,
    "gender"             AS gender,
    "date_of_birth"      AS date_of_birth,
    "income_bracket"     AS income_bracket,
    "marital_status"     AS marital_status,
    "location_id"        AS location_id,
    "registration_date"  AS registration_date,
    "credit_card_number" AS credit_card_number,
    "upi_id"             AS upi_id,
    "_loaded_at"         AS _loaded_at
FROM {{ source('ecommerce_landing', 'raw_customers') }}

{% if is_incremental() %}

WHERE "_loaded_at" > (
    SELECT COALESCE(MAX(_loaded_at), '1900-01-01'::TIMESTAMP_TZ)
    FROM {{ this }}
)

{% endif %}