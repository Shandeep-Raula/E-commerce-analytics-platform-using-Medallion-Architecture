-- delivery_delay should equal actual - expected delivery date in days
-- (negative = delivered early). Only checked for delivered orders.
select
    order_line_id,
    expected_delivery_date,
    actual_delivery_date,
    delivery_delay,
    datediff('day', to_date(expected_delivery_date), to_date(actual_delivery_date)) as expected_delay
from {{ ref('FACT_DELIVERY') }}
where actual_delivery_date is not null
  and (
        delivery_delay is null
        or delivery_delay <> datediff('day', to_date(expected_delivery_date), to_date(actual_delivery_date))
      )
