{{ config(
    materialized='incremental',
    incremental_strategy='append',
    unique_key='seller_id'
) }}


SELECT 
    "delivery_person_id"   AS delivery_person_id,
    "delivery_person_name" AS delivery_person_name,
    "phone_number"         AS phone_number,
    "vehicle_type"         AS vehicle_type,
    "employment_type"      AS employment_type,
    "gender"               AS gender,
    "location_id"          AS location_id,
    "date_of_joining"      AS date_of_joining,
    "_loaded_at"           AS _loaded_at

FROM {{ source('ecommerce_landing', 'raw_delivery_persons') }}

{% if is_incremental() %}

WHERE "_loaded_at" > (
    SELECT COALESCE(MAX("_loaded_at"), '1900-01-01'::TIMESTAMP_TZ)
    FROM {{ this }}
)

{% endif %}