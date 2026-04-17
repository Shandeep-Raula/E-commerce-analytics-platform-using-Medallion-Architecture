{{ config(
    materialized='table',
    schema='GOLD',
    tags=['dimension', 'seller']
) }}

SELECT
    seller_id,
    seller_name,
    email,
    phone_number,
    TO_DATE(join_date) AS join_date,
    location_id,
    rating,
    category_focus,
    bank_account_number,
    ifsc_code
FROM {{ ref('int_seller_snapshot') }}
WHERE DBT_VALID_TO IS NULL