{{ config(
    materialized='table',
    schema='GOLD',
    tags=['dimension', 'fulfillment']
) }}

select * from {{ ref('INT_FULLFILLMENT') }}