select 
    {{ var('main_id') }},
    sum({{ var('col_ecommerce_order_completed_properties_total') }}::real) as total_amt_spent
from {{ ref('stg_order_completed') }}
where {{timebound( var('col_ecommerce_order_completed_timestamp'))}} and {{ var('main_id')}} is not null
group by {{ var('main_id') }}