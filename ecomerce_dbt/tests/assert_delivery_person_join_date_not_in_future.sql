-- Fails if a delivery person has a joining date in the future.
select
    delivery_person_id,
    date_of_joining
from {{ ref('DIM_DELIVERY_PERSON') }}
where to_date(date_of_joining) > current_date()
