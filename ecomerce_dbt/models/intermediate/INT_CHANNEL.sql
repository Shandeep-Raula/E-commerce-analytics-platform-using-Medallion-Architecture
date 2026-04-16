{{ config(materialized='table',
        unique_key = 'channel_id') 
}}

WITH source AS (

    SELECT * 
    FROM {{ ref('STG_CHANNEL') }}

)

    SELECT
        TRIM(CHANNEL_ID) AS channel_id,
        UPPER(TRIM(CHANNEL_NAME)) AS channel_name,
        UPPER(TRIM(CHANNEL_TYPE)) AS channel_type,
        INITCAP(TRIM(DESCRIPTION)) AS description

    FROM source

