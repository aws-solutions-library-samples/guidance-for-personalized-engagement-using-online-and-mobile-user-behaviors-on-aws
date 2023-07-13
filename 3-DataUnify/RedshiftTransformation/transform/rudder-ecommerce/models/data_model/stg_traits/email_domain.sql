

with cte_user_max_time as 
(select {{ var('main_id') }}, max({{ var('col_ecommerce_identifies_timestamp') }}) as recent_ts from 
{{ ref('stg_identifies') }} group by 1
)
select a.{{ var('main_id') }}, max({{get_domain_from_email( var('col_ecommerce_identifies_email') )}}) as email_domain from {{ ref('stg_identifies') }} a left join 
cte_user_max_time b on 
a.{{ var('main_id') }} = b.{{ var('main_id') }}
group by 1