{% macro sentiment_category(sentiment_score) %}

CASE
    WHEN {{ sentiment_score }} >= 0.5 THEN 'POSITIVE'
    WHEN {{ sentiment_score }} >= 0 THEN 'NEUTRAL'
    ELSE 'NEGATIVE'
END

{% endmacro %}