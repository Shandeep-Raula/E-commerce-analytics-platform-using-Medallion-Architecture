-- Fails if an order has a date in the future.
select
    order_line_id,
    order_date
from {{ ref('FACT_SALES') }}
where to_date(order_date) > current_date()
