{% macro calculate_rpc(revenue, clicks) %}
    ROUND(
        {{ revenue }} / NULLIF({{ clicks }}, 0),
        2
    )
{% endmacro %}