
select {{ var('main_id')}}, 'days_since_last_seen' as feature_name, {{get_end_timestamp()}} as end_timestamp, days_since_last_seen as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('days_since_last_seen')}}
union
{% for lookback_days in var('lookback_days')%}
select {{ var('main_id')}}, feature_name, {{get_end_timestamp()}} as end_timestamp, feature_value as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('is_churned_n_days')}} where feature_name = 'is_churned_{{lookback_days}}_days'
union
select {{ var('main_id')}}, feature_name, {{get_end_timestamp()}} as end_timestamp, feature_value as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('active_days_in_past_n_days')}} where feature_name = 'active_days_in_past_{{lookback_days}}_days'
union
{% endfor %}
select {{ var('main_id')}}, feature_name, {{get_end_timestamp()}} as end_timestamp, feature_value as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('stg_session_features')}}