{{ config(
    materialized='table',
    schema='GOLD',
    tags=['dimension', 'product']
) }}


select * from {{ ref('INT_PRODUCT') }}