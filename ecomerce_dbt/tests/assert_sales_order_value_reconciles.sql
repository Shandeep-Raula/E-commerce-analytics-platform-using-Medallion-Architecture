{{ config(severity='warn') }}

-- Assumes order_value = gross_amount - discount_amount + tax_amount + shipping_fee.
-- Adjust the formula if ENRICHED_ORDER calculates it differently.
select
    order_line_id,
    gross_amount,
    discount_amount,
    tax_amount,
    shipping_fee,
    order_value,
    gross_amount - discount_amount + tax_amount + shipping_fee as expected_order_value
from {{ ref('FACT_SALES') }}
where abs(order_value - (gross_amount - discount_amount + tax_amount + shipping_fee)) > 0.01
