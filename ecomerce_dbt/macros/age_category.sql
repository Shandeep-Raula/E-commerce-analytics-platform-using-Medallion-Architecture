{% macro age_category(age_column) %}
    CASE 
        WHEN {{ age_column }} < 18 THEN 'MINOR (0-17)'
        WHEN {{ age_column }} <= 25 THEN 'YOUNG ADULT (18-25)'
        WHEN {{ age_column }} <= 35 THEN 'ADULT (26-35)'
        WHEN {{ age_column }} <= 50 THEN 'MID AGE (36-50)'
        WHEN {{ age_column }} <= 65 THEN 'SENIOR (51-65)'
        ELSE 'ELDERLY (65+)'
    END
{% endmacro %}