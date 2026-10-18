{{ config(severity='warn') }}

-- Recomputes ROAS and CPC from the raw measures (0.01 tolerance for rounding).
-- Assumes ROAS = revenue_generated / spend_amount and CPC = spend_amount / clicks.
-- Adjust if INT_MARKETING_EVENT defines them differently.
select
    marketing_id,
    roas,
    revenue_generated / nullif(spend_amount, 0) as expected_roas,
    cpc,
    spend_amount / nullif(clicks, 0) as expected_cpc
from {{ ref('FACT_MARKETING') }}
where abs(roas - revenue_generated / nullif(spend_amount, 0)) > 0.01
   or abs(cpc - spend_amount / nullif(clicks, 0)) > 0.01
