-- Fails if the expected or actual delivery date is before the order date.
select
    order_line_id,
    order_date,
    expected_delivery_date,
    actual_delivery_date
from {{ ref('FACT_DELIVERY') }}
where to_date(expected_delivery_date) < to_date(order_date)
   or to_date(actual_delivery_date) < to_date(order_date)
