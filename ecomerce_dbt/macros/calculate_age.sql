{% macro calculate_age(date_column) %}
    DATEDIFF(YEAR, {{ date_column }}, CURRENT_DATE())
{% endmacro %}