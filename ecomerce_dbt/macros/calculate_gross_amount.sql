{% macro calculate_gross_amount(quantity , unit_price) %}
  ROUND({{ quantity }} * {{ unit_price }}, 2)
{% endmacro %}