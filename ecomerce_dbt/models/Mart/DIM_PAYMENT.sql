{{ config(
    materialized='table',
    schema='GOLD',
    tags=['dimension', 'payment']
) }}


select * from {{ ref('INT_PAYMENT') }}