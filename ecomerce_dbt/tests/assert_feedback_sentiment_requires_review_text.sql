{{ config(severity='warn') }}

-- sentiment_score is derived from review_text,
-- so a score without any review text is suspicious.
select
    order_line_id,
    review_text,
    sentiment_score
from {{ ref('FACT_FEEDBACK') }}
where sentiment_score is not null
  and (review_text is null or trim(review_text) = '')
