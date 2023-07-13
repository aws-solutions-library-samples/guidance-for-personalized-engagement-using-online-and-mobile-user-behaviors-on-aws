select 
    {{ var('main_id') }},
    median({{ var('col_ecommerce_order_completed_properties_total') }}::real) as median_transaction_value
from {{ ref('stg_order_completed') }}
where {{timebound( var('col_ecommerce_order_completed_timestamp'))}} and {{ var('main_id')}} is not null
group by {{ var('main_id') }}