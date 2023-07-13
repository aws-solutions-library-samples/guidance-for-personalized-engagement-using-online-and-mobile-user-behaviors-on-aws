{% macro date_to_char(column_name) %}

{% if target.type == 'redshift' %}
    to_char( {{column_name}} , '{{var('date_format')}}')

{% else %}
    to_char({{column_name}})
{% endif %} 
{% endmacro %}