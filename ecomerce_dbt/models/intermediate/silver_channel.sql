{{ config(materialized='table') }}

WITH source AS (

    SELECT * 
    FROM {{ ref('RAW_CHANNEL') }}

),

cleaned AS (

    SELECT
        TRIM(CHANNEL_ID) AS channel_id,
        UPPER(TRIM(CHANNEL_NAME)) AS channel_name,
        LOWER(TRIM(CHANNEL_TYPE)) AS channel_type,
        TRIM(DESCRIPTION) AS description

    FROM source

),

deduplicated AS (

    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY channel_id ORDER BY channel_id) AS rn
        FROM cleaned
    )
    WHERE rn = 1

)

SELECT * FROM deduplicated