select {{ var('main_id')}}, 'total_amt_spent' as feature_name, {{get_end_timestamp()}} as end_timestamp, total_amt_spent as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('total_amt_spent')}}
union
select {{ var('main_id')}}, 'total_transactions' as feature_name, {{get_end_timestamp()}} as end_timestamp, total_transactions as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('total_transactions')}}
union
select {{ var('main_id')}}, 'avg_units_per_transaction' as feature_name, {{get_end_timestamp()}} as end_timestamp, avg_units_per_transaction as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('avg_units_per_transaction')}}
union
select {{ var('main_id')}}, 'last_transaction_value' as feature_name, {{get_end_timestamp()}} as end_timestamp, last_transaction_value as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('last_transaction_value')}}
union
select {{ var('main_id')}}, 'avg_transaction_value' as feature_name, {{get_end_timestamp()}} as end_timestamp, avg_transaction_value as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('avg_transaction_value')}}
union
select {{ var('main_id')}}, 'highest_transaction_value' as feature_name, {{get_end_timestamp()}} as end_timestamp, highest_transaction_value as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('highest_transaction_value')}}
union
select {{ var('main_id')}}, 'median_transaction_value' as feature_name, {{get_end_timestamp()}} as end_timestamp, median_transaction_value as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('median_transaction_value')}}
union
{% for lookback_days in var('lookback_days')%}
select {{ var('main_id')}}, feature_name, {{get_end_timestamp()}} as end_timestamp, feature_value as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('amt_spent_in_past_n_days')}} where feature_name = 'amt_spent_in_past_{{lookback_days}}_days'
{% if not loop.last %} union {% endif %}
{% endfor %}
union
select {{ var('main_id')}}, 'days_since_last_purchase' as feature_name, {{get_end_timestamp()}} as end_timestamp, days_since_last_purchase as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('days_since_last_purchase')}}
union
{% for lookback_days in var('lookback_days')%}
select {{ var('main_id')}}, feature_name, {{get_end_timestamp()}} as end_timestamp, feature_value as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('transactions_in_past_n_days')}} where feature_name = 'transactions_in_past_{{lookback_days}}_days'
{% if not loop.last %} union {% endif %}
{% endfor %}
union
select {{ var('main_id')}}, 'has_credit_card' as feature_name, {{get_end_timestamp()}} as end_timestamp, has_credit_card as feature_value_numeric, null as feature_value_string, null as feature_value_array, 'numeric' as feature_type from {{ref('has_credit_card')}}