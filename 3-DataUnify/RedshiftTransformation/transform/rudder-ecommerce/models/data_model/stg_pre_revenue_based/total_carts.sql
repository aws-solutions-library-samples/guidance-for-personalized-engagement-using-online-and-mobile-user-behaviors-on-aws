select 
    {{ var('main_id') }},
    count(distinct {{ var('col_ecommerce_product_added_properties_cart_id') }}) as total_carts
from {{ ref('stg_product_added') }}
where {{timebound( var('col_ecommerce_product_added_timestamp'))}} and {{ var('main_id')}} is not null
group by {{ var('main_id') }}