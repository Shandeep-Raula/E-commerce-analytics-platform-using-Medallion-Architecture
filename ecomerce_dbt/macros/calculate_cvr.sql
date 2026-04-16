{% macro calculate_cvr(conversions, clicks) %}
    ROUND(
        {{ conversions }} / NULLIF({{ clicks }}, 0),
        2
    )
{% endmacro %}