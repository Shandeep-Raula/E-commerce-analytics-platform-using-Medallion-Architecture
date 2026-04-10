{{ config(materialized='table',
        unique_key = 'fulfillment_id') }}

SELECT

    fulfillment_id,


    UPPER(TRIM(shipping_method)) AS shipping_method,
    UPPER(TRIM(service_level))   AS service_level,


    CAST(delivery_sla_days AS INTEGER)        AS delivery_sla_days,
    CAST(base_shipping_cost AS DECIMAL(10,2)) AS base_shipping_cost

FROM {{ ref('STG_FULLFILLMENT') }}