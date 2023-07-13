select 
    {{ var('main_id') }}, 
    max(case when lower({{ var('col_ecommerce_checkout_step_completed_payment_method') }}) in {{var('card_types')}} then 1 else 0 end) as has_credit_card
from {{ ref('stg_checkout_step_completed') }}
where {{timebound( var('col_ecommerce_checkout_step_completed_timestamp'))}} and {{ var('main_id')}} is not null
group by {{ var('main_id') }}
