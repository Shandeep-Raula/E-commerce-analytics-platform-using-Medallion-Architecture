{% macro return_flag(return_flag_column) %}

CASE 
    WHEN UPPER(TRIM({{ return_flag_column }})) IN ('Y', 'YES', 'TRUE', '1') THEN 1
    ELSE 0
END

{% endmacro %}