{% macro delivery_delay_category(delay_column) %}

CASE 
    WHEN {{ delay_column }} = 0 THEN 'ON TIME'
    WHEN {{ delay_column }} BETWEEN 1 AND 2 THEN 'SLIGHT DELAY (1-2 DAYS)'
    WHEN {{ delay_column }} BETWEEN 3 AND 5 THEN 'MODERATE DELAY (3-5 DAYS)'
    ELSE 'SEVERE DELAY'
END

{% endmacro %}