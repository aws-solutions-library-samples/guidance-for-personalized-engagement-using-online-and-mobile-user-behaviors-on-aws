{{ config( 
    materialized = 'incremental', 
    unique_key = 'row_id',
    incremental_strategy='delete+insert'
   ) 
}} 

{% set numeric_features = dbt_utils.get_column_values(table=ref('event_stream_feature_table'), column='feature_name', where='feature_type=\'numeric\'') %}
{% set string_features = dbt_utils.get_column_values(table=ref('event_stream_feature_table'), column='feature_name', where='feature_type=\'string\'') %}
{% set array_features = dbt_utils.get_column_values(table=ref('event_stream_feature_table'), column='feature_name', where='feature_type=\'array\'') %}

select
    {{ var('main_id')}}, 
    {{timestamp_call('timestamp')}},
    {{concat_columns( [ var('main_id'), date_to_char(get_end_timestamp())])}} as row_id,
    {% for feature_name in numeric_features %}
    max(case when feature_name='{{feature_name}}' then feature_value_numeric
                  end) as {{feature_name}},
    {% endfor %} 
     {% for feature_name in string_features%}
    max(case when feature_name='{{feature_name}}' then feature_value_string  
                  end) as {{feature_name}},
    {% endfor %}    
    {% for feature_name in array_features%}
    max(case when feature_name='{{feature_name}}' then
                {% if target.type == 'redshift' %}
                feature_value_array
                {% elif target.type == 'snowflake' %}
                array_to_string(feature_value_array,',') 
                {% endif %}
                end) as {{feature_name}}
                {%- if not loop.last %},{% endif -%}
    {% endfor %}   
from {{ref('event_stream_feature_table')}}
where {{timestamp_call('timestamp')}} = {{get_end_timestamp()}}
group by {{ var('main_id')}}, {{timestamp_call('timestamp')}}, {{concat_columns( [ var('main_id'), date_to_char(get_end_timestamp())])}}
