{% macro id_stitch(TABLE_NAME, list_id_cols, timestamp_col='') %}
SELECT b.{{ var('main_id') }}, a.*
FROM (
  SELECT *
  FROM {{TABLE_NAME}} 
  {% if timestamp_col != '' %}
  WHERE {{timebound(timestamp_col)}} 
  {% endif %} 
) a
LEFT JOIN {{ var('tbl_id_stitcher') }} b ON 
{% if list_id_cols|length == 1 %}
a.{{list_id_cols|first}} = b.{{ var('col_id_stitcher_other_id')}} 
{% else %}
b.{{ var('col_id_stitcher_other_id')}}  = coalesce(
    {% for id_col in list_id_cols %}
    a.{{id_col}}
    {% if not loop.last %}
                , 
    {% endif %} 
    {% endfor %}
  )
{% endif %}
where b.{{ var('main_id') }} is not null
{% endmacro %}