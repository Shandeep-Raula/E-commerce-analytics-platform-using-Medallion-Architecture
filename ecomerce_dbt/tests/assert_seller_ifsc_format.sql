{{ config(severity='warn') }}

-- Indian IFSC format: 4 letters, the digit 0, then 6 letters/digits (11 characters).
-- Severity is 'warn' so synthetic data with odd formats does not fail the build.
select
    seller_id,
    ifsc_code
from {{ ref('DIM_SELLER') }}
where ifsc_code is not null
  and not regexp_like(upper(ifsc_code), '[A-Z]{4}0[A-Z0-9]{6}')
