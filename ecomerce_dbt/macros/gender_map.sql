{% macro gendermap(gender) %}
  CASE 
    WHEN gender = 'M' THEN 'Male'
    WHEN gender = 'F' THEN 'Female'
    ELSE 'Other'
  END
{% endmacro %}