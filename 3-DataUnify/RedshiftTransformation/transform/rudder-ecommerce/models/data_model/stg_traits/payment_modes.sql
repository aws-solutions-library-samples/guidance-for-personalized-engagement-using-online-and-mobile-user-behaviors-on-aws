select 
    {{ var('main_id')}}, 
    {{array_agg( var('col_ecommerce_checkout_step_completed_payment_method') )}} as payment_modes 
from {{ ref('stg_checkout_step_completed') }}
where {{timebound( var('col_ecommerce_checkout_step_completed_timestamp'))}} and {{ var('main_id')}} is not null
group by {{ var('main_id')}}