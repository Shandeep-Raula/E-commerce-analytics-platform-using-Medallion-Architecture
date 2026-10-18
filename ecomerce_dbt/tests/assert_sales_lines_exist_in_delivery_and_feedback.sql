-- FACT_SALES, FACT_DELIVERY and FACT_FEEDBACK are all built from ENRICHED_ORDER,
-- so every order line in FACT_SALES must exist in the other two.
-- Returns the lines that are missing and which table they are missing from.
select
    s.order_line_id,
    'FACT_DELIVERY' as missing_from
from {{ ref('FACT_SALES') }} as s
left join {{ ref('FACT_DELIVERY') }} as d
    on s.order_line_id = d.order_line_id
where d.order_line_id is null

union all

select
    s.order_line_id,
    'FACT_FEEDBACK' as missing_from
from {{ ref('FACT_SALES') }} as s
left join {{ ref('FACT_FEEDBACK') }} as f
    on s.order_line_id = f.order_line_id
where f.order_line_id is null
