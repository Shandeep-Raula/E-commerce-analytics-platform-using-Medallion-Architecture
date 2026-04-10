{{ config(materialized='table',
        unique_key = 'location_id') }}

SELECT
    -- Primary Key
    location_id,

    -- Standardized text fields
    UPPER(TRIM(city))            AS city,
    UPPER(TRIM(state))           AS state,
    UPPER(TRIM(region))          AS region,

    -- Category normalization
    UPPER(TRIM(location_category)) AS location_category,
    UPPER(TRIM(area_type))         AS area_type,

    -- Numeric fields
    postal_code,
    latitude,
    longitude

FROM {{ ref('STG_LOCATION') }}