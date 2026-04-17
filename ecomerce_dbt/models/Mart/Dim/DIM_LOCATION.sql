{{ config(
    materialized='table',
    schema='GOLD',
    tags=['dimension', 'location']
) }}


select * from {{ ref('INT_LOCATION') }}