{% macro calculate_order_value(quantity, unit_price, discount_percentage, tax_percentage, shipping_fee) %}
  ROUND({{ calculate_net_amount(quantity, unit_price, discount_percentage) }} 
  + {{ calculate_tax_amount(quantity, unit_price, discount_percentage, tax_percentage) }} 
  + {{ shipping_fee }}, 2)
{% endmacro %}