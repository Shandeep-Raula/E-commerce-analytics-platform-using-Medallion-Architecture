{% macro calculate_cpc(spend_amount, clicks) %}

     ROUND({{ spend_amount }} / NULLIF({{ clicks }}, 0), 2)
  
{% endmacro %}