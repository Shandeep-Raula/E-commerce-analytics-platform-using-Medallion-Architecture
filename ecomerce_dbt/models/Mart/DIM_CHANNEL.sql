{{ config(
    materialized='table',
    schema='GOLD',
    tags=['dimension', 'channel']
) }}

select *
from {{ ref('INT_CHANNEL') }}