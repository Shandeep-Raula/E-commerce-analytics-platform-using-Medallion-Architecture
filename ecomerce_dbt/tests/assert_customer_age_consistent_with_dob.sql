-- Fails (returns rows) if a customer's AGE is outside 0-120,
-- or differs from the age calculated from DATE_OF_BIRTH by more than 1 year.
select
    customer_id,
    date_of_birth,
    age
from {{ ref('DIM_CUSTOMER') }}
where age < 0
   or age > 120
   or abs(age - datediff('year', to_date(date_of_birth), current_date())) > 1
