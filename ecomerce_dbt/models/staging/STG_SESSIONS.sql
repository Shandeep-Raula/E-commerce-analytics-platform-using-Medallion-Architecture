{{ config(
    materialized='incremental',
    unique_key='session_id',
    incremental_strategy='merge'
) }}

SELECT *
FROM {{ source('ecommerce_landing', 'raw_sessions') }}

{% if is_incremental() %}
WHERE _ab_cdc_updated_at >= (
    SELECT COALESCE(MAX(_ab_cdc_updated_at), '1900-01-01')
    FROM {{ this }}
)
{% endif %}