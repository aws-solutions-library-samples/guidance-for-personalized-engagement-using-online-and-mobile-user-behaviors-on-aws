with cte_product_casted as 
(select {{var('main_id')}}, cast({{var('properties_product_ref_var')}} as varchar) as product_id_str, 
	{{ var('col_ecommerce_product_added_timestamp') }}
	from {{ ref('stg_product_added') }}
), cte_products_added_in_past_n_days as (
    {% for lookback_days in var('lookback_days') %}
        select {{ var('main_id') }},
        {{array_agg( 'product_id_str')}} as products_added_in_past_n_days,
        {{lookback_days}} as n_value
        from cte_product_casted
        where datediff(day, date({{ var('col_ecommerce_product_added_timestamp') }}), date({{get_end_timestamp()}})) <= {{lookback_days}} and {{timebound( var('col_ecommerce_product_added_timestamp'))}} and {{ var('main_id')}} is not null
        group by {{ var('main_id') }}
        {% if not loop.last %} union {% endif %}
    {% endfor %}
)

select {{var('main_id')}}, concat(concat('products_added_in_past_', n_value::varchar),'_days') as feature_name, 
products_added_in_past_n_days AS feature_value
from cte_products_added_in_past_n_days
