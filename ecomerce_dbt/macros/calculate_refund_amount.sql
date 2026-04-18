{% macro calculate_refund_amount(quantity, unit_price, discount_percentage, tax_percentage, shipping_fee, refund_amount) %}
   CASE 
        WHEN {{ refund_amount }} = 0 THEN 0
        ELSE 
            {{calculate_order_value(quantity, unit_price, discount_percentage, tax_percentage, shipping_fee)}} - ABS(TRY_CAST({{ refund_amount }} AS DECIMAL(10,2)))
    END
{% endmacro %}

