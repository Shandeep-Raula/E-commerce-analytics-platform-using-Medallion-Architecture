{{ config(severity='warn') }}

-- The funnel should narrow: clicks <= impressions and conversions <= clicks.
-- Severity is 'warn' because view-through conversions can legitimately exceed clicks.
select
    marketing_id,
    impressions,
    clicks,
    conversions
from {{ ref('FACT_MARKETING') }}
where clicks > impressions
   or conversions > clicks
