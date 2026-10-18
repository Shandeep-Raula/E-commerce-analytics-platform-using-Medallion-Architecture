{{ config(severity='warn') }}

-- Product views should not exceed page views,
-- and purchases should not exceed checkout attempts.
select
    session_id,
    page_views,
    product_views,
    checkout_attempts,
    purchases
from {{ ref('FACT_SESSION') }}
where product_views > page_views
   or purchases > checkout_attempts
