{% macro calculate_net_amount(quantity , unit_price, discount_percentage) %}
  ROUND({{ calculate_gross_amount(quantity, unit_price) }} - {{ calculate_discount_amount(quantity, unit_price, discount_percentage) }}, 2)
{% endmacro %}