-- Fails if a seller rating is outside the 0-5 scale.
select
    seller_id,
    rating
from {{ ref('DIM_SELLER') }}
where rating < 0
   or rating > 5
