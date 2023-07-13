{% macro array_agg(column_name) %}

{% if target.type == 'redshift' %}
    listagg( distinct {{column_name}}, ', ')
{% endif %}

{% if target.type == 'snowflake' %}
    array_agg( distinct {{column_name}})
{% endif %} 
{% endmacro %}