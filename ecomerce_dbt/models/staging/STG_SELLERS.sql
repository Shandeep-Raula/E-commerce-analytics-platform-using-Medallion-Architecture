{{ config(
    materialized='incremental',
    incremental_strategy='append',
    unique_key='seller_id'
) }}


SELECT 
"seller_id"       AS seller_id,
"seller_name"     AS seller_name,
"email"           AS email,
"phone_number"    AS phone_number,
"join_date"      AS join_date,
"location_id"    AS location_id,
"rating"         AS rating,
"category_focus" AS category_focus, 
"bank_account_number" AS bank_account_number,
"ifsc_code"       AS ifsc_code,
"_loaded_at"      AS _loaded_at

FROM {{ source('ecommerce_landing', 'raw_sellers') }}

{% if is_incremental() %}
WHERE _loaded_at > (
    SELECT COALESCE(MAX(_loaded_at), '1900-01-01')
    FROM {{ this }}
)
{% endif %}