{{
  config(
    materialized = 'table',
    unique_key = 'product_id'
    )
}}

SELECT
product_id,
UPPER(TRIM(product_name)) AS product_name,
UPPER(TRIM(brand)) AS brand,
UPPER(TRIM(category)) AS category,
UPPER(TRIM(sub_category)) AS sub_category,
CAST(price AS DECIMAL(10,2)) AS price
FROM {{ ref('STG_PRODUCTS') }}