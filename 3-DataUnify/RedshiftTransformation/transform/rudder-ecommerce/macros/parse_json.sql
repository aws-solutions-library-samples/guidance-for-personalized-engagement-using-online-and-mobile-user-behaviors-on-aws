{% macro parse_json(column_name) %}

{% if target.type == 'redshift' %}
    json_parse({{column_name}})

{% else %}
    parse_json({{column_name}})
{% endif %} 
{% endmacro %}