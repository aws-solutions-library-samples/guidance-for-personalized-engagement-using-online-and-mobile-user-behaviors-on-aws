{% macro array_size(column_name) %}

{% if target.type == 'redshift' %}
case when is_valid_json_array({{column_name}}) then  get_array_length(json_parse({{column_name}})) else null end

{% else %}
    array_size( parse_json({{column_name}}) )
{% endif %} 
{% endmacro %}