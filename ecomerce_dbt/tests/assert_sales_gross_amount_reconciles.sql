{{ config(severity='warn') }}

-- gross_amount should equal quantity * unit_price (0.01 tolerance for rounding).
select
    order_line_id,
    quantity,
    unit_price,
    gross_amount,
    quantity * unit_price as expected_gross_amount
from {{ ref('FACT_SALES') }}
where abs(gross_amount - quantity * unit_price) > 0.01
