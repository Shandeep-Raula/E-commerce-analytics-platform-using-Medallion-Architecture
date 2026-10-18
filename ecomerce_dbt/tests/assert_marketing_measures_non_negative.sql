-- Fails if any marketing measure is negative.
select
    marketing_id,
    spend_amount,
    impressions,
    clicks,
    conversions,
    revenue_generated
from {{ ref('FACT_MARKETING') }}
where spend_amount < 0
   or impressions < 0
   or clicks < 0
   or conversions < 0
   or revenue_generated < 0
