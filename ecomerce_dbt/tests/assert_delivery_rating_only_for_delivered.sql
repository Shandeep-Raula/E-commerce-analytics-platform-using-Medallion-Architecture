{{ config(severity='warn') }}

-- A delivery rating should only exist once the order has actually been delivered.
select
    order_line_id,
    actual_delivery_date,
    delivery_rating
from {{ ref('FACT_DELIVERY') }}
where delivery_rating is not null
  and actual_delivery_date is null
