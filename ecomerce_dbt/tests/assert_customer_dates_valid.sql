-- Fails if a customer registered on/before their own birth date,
-- or has a registration date in the future.
select
    customer_id,
    date_of_birth,
    registration_date
from {{ ref('DIM_CUSTOMER') }}
where to_date(date_of_birth) >= to_date(registration_date)
   or to_date(registration_date) > current_date()
