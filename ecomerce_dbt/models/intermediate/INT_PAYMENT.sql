{{
  config(
    materialized = 'table',
    unique_id='payment_id'
    )
}}

select
    payment_id,
    UPPER(TRIM(payment_method)) AS payment_method,
    UPPER((TRIM(payment_provider))) AS payment_provider,
    TRIM(description) AS description
from {{ ref('STG_PAYMENT') }}
