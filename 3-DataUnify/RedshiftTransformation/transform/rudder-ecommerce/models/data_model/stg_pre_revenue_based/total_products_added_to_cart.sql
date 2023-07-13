select 
    {{ var('main_id') }},
    count(*) as total_products_added_to_cart
from {{ ref('stg_product_added') }}
where {{timebound( var('col_ecommerce_product_added_timestamp'))}} and {{ var('main_id')}} is not null
group by {{ var('main_id') }}