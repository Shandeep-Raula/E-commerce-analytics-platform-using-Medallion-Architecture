{% macro calculate_discount_amount(quantity , unit_price, discount_percentage) %}
  ROUND({{ quantity }} * {{ unit_price }} * {{ discount_percentage }} / 100, 2)
{% endmacro %}