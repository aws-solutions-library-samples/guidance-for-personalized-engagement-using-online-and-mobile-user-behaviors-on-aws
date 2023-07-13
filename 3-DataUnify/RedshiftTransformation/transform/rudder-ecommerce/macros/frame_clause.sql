{% macro frame_clause(frame_condition = 'rows between unbounded preceding and unbounded following') %}

{% if target.type == 'redshift' %}
    {{frame_condition}}
{% endif %} 
{% endmacro %}