with cte_amt_spent_in_past_n_days as (
    {% for lookback_days in var('lookback_days') %}
    select {{ var('main_id') }},
    sum({{ var('col_ecommerce_order_completed_properties_total') }}::real) as amt_spent_in_past_n_days,
    {{lookback_days}} as n_value
    from {{ ref('stg_order_completed') }}
    where datediff(day, date({{ var('col_ecommerce_order_completed_timestamp') }}), date({{get_end_timestamp()}})) <= {{lookback_days}} and {{timebound( var('col_ecommerce_order_completed_timestamp'))}} and {{ var('main_id')}} is not null
    group by {{ var('main_id') }}
    {% if not loop.last %} union {% endif %}
    {% endfor %}
)

{% for lookback_days in var('lookback_days') %}
select 
    {{ var('main_id') }}, 
    'amt_spent_in_past_{{lookback_days}}_days' as feature_name, amt_spent_in_past_n_days as feature_value 
    from cte_amt_spent_in_past_n_days where n_value = {{lookback_days}}
{% if not loop.last %} union {% endif %}
{% endfor %}