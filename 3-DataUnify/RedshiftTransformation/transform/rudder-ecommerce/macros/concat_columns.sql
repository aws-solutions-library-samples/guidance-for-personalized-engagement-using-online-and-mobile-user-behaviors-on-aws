{% macro concat_columns(cols_list) %}
{% if target.type == 'redshift' %}
 {% for col in cols_list %}
      {% if not loop.last %}
      concat({{col}},
      {% else %}
      {{col}})
      {% endif %}
 {% endfor %}
 {% for i in range (0,cols_list|length - 2 ) %}
     )
 {% endfor %}

{% else %}
concat_ws(
 {% for col in cols_list %}
      {{col}}
       {% if not loop.last %} , {% endif %}
 {% endfor %})
{% endif %}
{% endmacro %}