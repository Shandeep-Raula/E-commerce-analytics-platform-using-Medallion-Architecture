{% macro calculate_cpa(spend_amount, conversions) %}
         ROUND(
        {{ spend_amount }} / NULLIF({{ conversions }}, 0),
        2
    )
{% endmacro %}