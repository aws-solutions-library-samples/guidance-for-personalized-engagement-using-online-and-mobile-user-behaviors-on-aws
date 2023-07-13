select {{ var('main_id')}}, 'items_purchased_ever' as feature_name, {{get_end_timestamp()}} as end_timestamp, null as feature_value_numeric, null as feature_value_string, {{ var('product_ref_var') }} as feature_value_array, 'array' as feature_type from {{ref('items_purchased_ever')}}
{% if var('category_ref_var') != '' %}
union
select {{ var('main_id')}}, '{{ var('category_ref_var') }}_purchased_ever' as feature_name, {{get_end_timestamp()}} as end_timestamp, null as feature_value_numeric, null as feature_value_string, {{ var('category_ref_var') }} as feature_value_array, 'array' as feature_type from {{ref('categories_purchased_ever')}}
union
select {{ var('main_id')}}, 'highest_spent_category' as feature_name, {{get_end_timestamp()}} as end_timestamp, null as feature_value_numeric, highest_spent_category as feature_value_string, null as feature_value_array, 'string' as feature_type from {{ref('highest_spent_category')}}
union
select {{ var('main_id')}}, 'highest_transacted_category' as feature_name, {{get_end_timestamp()}} as end_timestamp, null as feature_value_numeric, highest_transacted_category as feature_value_string, null as feature_value_array, 'string' as feature_type from {{ref('highest_transacted_category')}}
{% endif %}