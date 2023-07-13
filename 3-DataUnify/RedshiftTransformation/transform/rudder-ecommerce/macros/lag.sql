{% macro lag_col(column_name) %}

{% if target.type == 'redshift' %}
    lag({{column_name}}, 1)

{% else %}
    lag({{column_name}}, 1, {{column_name}})
{% endif %} 
{% endmacro %}