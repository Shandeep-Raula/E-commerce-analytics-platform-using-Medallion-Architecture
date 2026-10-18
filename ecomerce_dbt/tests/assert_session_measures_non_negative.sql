-- Fails if any session count, duration or rate is negative.
select
    session_id,
    page_views,
    product_views,
    add_to_cart_count,
    wishlist_additions,
    search_count,
    checkout_attempts,
    purchases,
    session_duration_in_sec,
    add_to_cart_rate,
    checkout_conversion_rate
from {{ ref('FACT_SESSION') }}
where page_views < 0
   or product_views < 0
   or add_to_cart_count < 0
   or wishlist_additions < 0
   or search_count < 0
   or checkout_attempts < 0
   or purchases < 0
   or session_duration_in_sec < 0
   or add_to_cart_rate < 0
   or checkout_conversion_rate < 0
