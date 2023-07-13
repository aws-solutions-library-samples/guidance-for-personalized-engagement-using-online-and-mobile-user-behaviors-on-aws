select {{ var('main_id')}}, 'gender' as feature_name, {{get_end_timestamp()}} as end_timestamp, null as feature_value_numeric, gender as feature_value_string, null as feature_value_array, 'string' as feature_type from {{ref('gender')}}
union
select {{ var('main_id')}}, 'age' as feature_name, {{get_end_timestamp()}} as end_timestamp, age as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('age')}}
union
select {{ var('main_id')}}, 'country' as feature_name, {{get_end_timestamp()}} as end_timestamp, null as feature_value_numeric, country as feature_value_string, null as feature_value_array, 'string' as feature_type from {{ref('country')}}
union
select {{ var('main_id')}}, 'state' as feature_name, {{get_end_timestamp()}} as end_timestamp, null as feature_value_numeric, state as feature_value_string, null as feature_value_array, 'string' as feature_type from {{ref('state')}}