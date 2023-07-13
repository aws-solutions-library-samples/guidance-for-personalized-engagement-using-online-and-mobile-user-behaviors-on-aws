select 
    {{ var('main_id')}}, 
    ({{ array_agg( var('col_ecommerce_identifies_campaign_source') )}}) as campaign_sources 
from {{ ref('stg_identifies')}}
where {{timebound( var('col_ecommerce_identifies_timestamp'))}} and {{ var('main_id')}} is not null
group by {{ var('main_id')}}