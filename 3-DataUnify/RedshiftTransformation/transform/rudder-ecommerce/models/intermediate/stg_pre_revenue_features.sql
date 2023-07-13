{% for lookback_days in var('lookback_days')%}
select {{ var('main_id')}}, feature_name, {{get_end_timestamp()}} as end_timestamp, feature_value as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('carts_in_past_n_days')}} where feature_name = 'carts_in_past_{{lookback_days}}_days'
union
{% endfor %}
select {{ var('main_id')}}, 'total_carts' as feature_name, {{get_end_timestamp()}} as end_timestamp, total_carts as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('total_carts')}}
union
select {{ var('main_id')}}, 'total_products_added_to_cart' as feature_name, {{get_end_timestamp()}} as end_timestamp, total_products_added_to_cart as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('total_products_added_to_cart')}}
union
{% for lookback_days in var('lookback_days')%}
select {{ var('main_id')}}, feature_name, {{get_end_timestamp()}} as end_timestamp, null as feature_value_numeric, null as feature_value_string, feature_value as feature_value_array, 'array' as feature_type from {{ref('products_added_in_past_n_days')}} where feature_name = 'products_added_in_past_{{lookback_days}}_days'
union 
{% endfor %}
select {{ var('main_id')}}, 'days_since_last_cart_add' as feature_name, {{get_end_timestamp()}} as end_timestamp, days_since_last_cart_add as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('days_since_last_cart_add')}}