{% macro calculate_roas(revenue, spend) %}
    ROUND(
        {{ revenue }} / NULLIF({{ spend }}, 0),
        2
    )
{% endmacro %}