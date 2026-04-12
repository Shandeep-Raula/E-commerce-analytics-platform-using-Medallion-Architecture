{% macro age_category(age_column) %}
    CASE 
        WHEN {{ age_column }} < 18 THEN 'Minor (0-17)'
        WHEN {{ age_column }} <= 25 THEN 'Young Adult (18-25)'
        WHEN {{ age_column }} <= 35 THEN 'Adult (26-35)'
        WHEN {{ age_column }} <= 50 THEN 'Mid Age (36-50)'
        WHEN {{ age_column }} <= 65 THEN 'Senior (51-65)'
        ELSE 'Elderly (65+)'
    END
{% endmacro %}