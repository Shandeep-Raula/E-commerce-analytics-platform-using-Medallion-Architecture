{% macro calculate_ctr(clicks, impressions) %}

         ROUND(({{ clicks }} / NULLIF({{ impressions }}, 0)) * 100, 2)

{% endmacro %}