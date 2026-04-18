{% macro calculate_tax_amount(quantity, unit_price, discount_percentage, tax_percentage) %}
    ROUND({{ calculate_net_amount(quantity, unit_price, discount_percentage) }} 
    * ({{ tax_percentage }} / 100), 2)
{% endmacro %}