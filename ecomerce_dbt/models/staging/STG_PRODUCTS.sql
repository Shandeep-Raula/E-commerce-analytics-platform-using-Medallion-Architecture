SELECT 
"product_id"       AS product_id,
"product_name"     AS product_name,
"brand"            AS brand,
"category"         AS category,
"sub_category"     AS sub_category,
"list_price"            AS price
FROM {{ source('ecommerce_landing', 'raw_products') }}