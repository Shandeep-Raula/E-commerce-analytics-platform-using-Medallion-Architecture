-- Fails if a seller joined in the future.
select
    seller_id,
    join_date
from {{ ref('DIM_SELLER') }}
where join_date > current_date()
