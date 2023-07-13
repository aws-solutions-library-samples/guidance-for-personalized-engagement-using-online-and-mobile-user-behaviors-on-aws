with cte_carts_in_past_n_days as (
    {% for lookback_days in var('lookback_days') %}
        select {{ var('main_id') }},
        count(distinct {{ var('col_ecommerce_product_added_properties_cart_id') }}) as carts_in_past_n_days,
        {{lookback_days}} as n_value
        from {{ ref('stg_product_added') }}
        where datediff(day, date({{ var('col_ecommerce_product_added_timestamp') }}), date({{get_end_timestamp()}})) <= {{lookback_days}} and {{timebound( var('col_ecommerce_product_added_timestamp'))}} and {{ var('main_id')}} is not null
        group by {{ var('main_id') }}
    {% if not loop.last %} union {% endif %}
    {% endfor %}
)

{% for lookback_days in var('lookback_days') %}
select {{ var('main_id') }}, 
    'carts_in_past_{{lookback_days}}_days' as feature_name, carts_in_past_n_days as feature_value 
from cte_carts_in_past_n_days where n_value = {{lookback_days}}
{% if not loop.last %} union {% endif %}
{% endfor %}