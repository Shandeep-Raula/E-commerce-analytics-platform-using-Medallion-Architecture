{% macro calculate_delay(expected_delivery_date,actual_delivery_date) %}

    DATEDIFF(day, {{expected_delivery_date}}, {{actual_delivery_date}})
  
{% endmacro %}