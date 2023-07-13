select 
    distinct {{ var('main_id') }},
    datediff(day, date(max({{ var('col_ecommerce_order_completed_timestamp') }})),date({{get_end_timestamp()}})) as days_since_last_purchase
from {{ ref('stg_order_completed') }}
where {{timebound( var('col_ecommerce_order_completed_timestamp'))}} and {{ var('main_id')}} is not null
group by {{ var('main_id') }}