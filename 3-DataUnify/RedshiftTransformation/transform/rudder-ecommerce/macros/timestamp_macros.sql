{% macro get_end_date() %}
    {% if var('end_date') == 'now' %}
    '{{ run_started_at.strftime("%Y-%m-%d") }}'
    {% else %}
    '{{ var('end_date') }}'
    {% endif %}
{% endmacro %}


{% macro get_end_timestamp() %}
    {% if var('end_date') == 'now' %}
    to_timestamp('{{ run_started_at.strftime("%Y-%m-%d") }}', '{{ var('date_format')}}')
    {% else %}
    least(to_timestamp('{{ var('end_date') }}', '{{ var('date_format')}}'), to_timestamp('{{ run_started_at.strftime("%Y-%m-%d") }}', '{{ var('date_format')}}'))
    {% endif %}
{% endmacro %}


{% macro timebound(column_name) %}
    {% if var('end_date') == 'now' %}
    {{column_name}} between to_date('{{ var('start_date') }}', '{{var('date_format')}}') and getdate()
    {% else %}
    {{column_name}} between to_date('{{ var('start_date') }}', '{{var('date_format')}}') and  to_date('{{ var('end_date') }}', '{{var('date_format')}}')
    {% endif %}
{% endmacro %}


{% macro timestamp_call(column_name) %}
{% if target.type == 'redshift' %}
    "{{column_name}}"

{% else %}
    {{column_name}}
{% endif %} 
{% endmacro %}


{% macro to_date(timestamp_col) %}
{% if target.type == 'snowflake' %}
    to_date({{timestamp_col}})
{% elif target.type == 'redshift' %}
    trunc({{timestamp_col}})
{% endif %}
{% endmacro %}