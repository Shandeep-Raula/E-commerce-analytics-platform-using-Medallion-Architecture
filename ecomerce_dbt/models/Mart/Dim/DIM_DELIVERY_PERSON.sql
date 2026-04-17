{{ config(
    materialized='table',
    schema='GOLD',
    tags=['dimension', 'de']
) }}

SELECT
    delivery_person_id,
    delivery_person_name,
    employment_type,
    gender,
    location_id,
    phone_number,
    vehicle_type,
    date_of_joining
FROM {{ ref('int_delivery_person_snapshot') }}
WHERE DBT_VALID_TO IS NULL