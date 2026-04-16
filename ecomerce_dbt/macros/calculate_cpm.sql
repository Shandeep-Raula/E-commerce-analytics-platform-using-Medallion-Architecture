{% macro calculate_cpm(spend, impressions) %}
    ROUND(
        ({{ spend }} / NULLIF({{ impressions }}, 0)) * 1000,
        2
    )
{% endmacro %}