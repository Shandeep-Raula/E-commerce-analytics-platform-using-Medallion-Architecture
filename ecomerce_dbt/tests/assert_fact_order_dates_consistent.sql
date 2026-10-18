-- The order_date of the same order_line_id must match
-- across FACT_SALES, FACT_DELIVERY and FACT_FEEDBACK.
select
    s.order_line_id,
    s.order_date as sales_order_date,
    d.order_date as delivery_order_date,
    f.order_date as feedback_order_date
from {{ ref('FACT_SALES') }} as s
join {{ ref('FACT_DELIVERY') }} as d
    on s.order_line_id = d.order_line_id
join {{ ref('FACT_FEEDBACK') }} as f
    on s.order_line_id = f.order_line_id
where s.order_date <> d.order_date
   or s.order_date <> f.order_date
