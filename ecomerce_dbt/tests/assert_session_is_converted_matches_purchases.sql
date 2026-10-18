{{ config(severity='warn') }}

-- is_converted should be true exactly when the session has at least one purchase.
-- try_to_boolean makes this work whether is_converted is BOOLEAN, 0/1 or 'Y'/'N'.
select
    session_id,
    purchases,
    is_converted
from {{ ref('FACT_SESSION') }}
where (purchases > 0) <> coalesce(try_to_boolean(is_converted::varchar), false)
