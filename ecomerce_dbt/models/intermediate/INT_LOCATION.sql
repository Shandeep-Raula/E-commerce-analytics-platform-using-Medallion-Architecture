{{ config(materialized='table',
        unique_key = 'location_id') }}

SELECT
    location_id,
    UPPER(TRIM(city))            AS city,
    UPPER(TRIM(state))           AS state,
    UPPER(TRIM(region))          AS region,
    UPPER(TRIM(location_category)) AS location_category,
    UPPER(TRIM(area_type))         AS area_type,
    postal_code,
    latitude,
    longitude

FROM {{ ref('STG_LOCATION') }}