select 
    distinct {{ var('main_id') }},
    datediff(day, date(max({{ var('col_ecommerce_product_added_timestamp') }})), date({{get_end_timestamp()}})) as days_since_last_cart_add
from {{ ref('stg_product_added') }}
where {{timebound( var('col_ecommerce_product_added_timestamp'))}} and {{ var('main_id')}} is not null
group by {{ var('main_id') }}