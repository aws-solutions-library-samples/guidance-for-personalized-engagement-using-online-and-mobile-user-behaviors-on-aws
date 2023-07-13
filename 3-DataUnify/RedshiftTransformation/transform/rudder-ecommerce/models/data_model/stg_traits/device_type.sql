select 
    distinct {{ var('main_id')}},
    first_value({{ var('col_ecommerce_identifies_device_type')}}) over(
        partition by {{ var('main_id')}} 
        order by case when {{ var('col_ecommerce_identifies_device_type')}} is not null and {{ var('col_ecommerce_identifies_device_type')}} != '' then 2 else 1 end desc, 
        {{ var('col_ecommerce_identifies_timestamp')}} desc {{frame_clause()}}
    ) as device_type
from {{ ref('stg_identifies')}} 
where {{timebound( var('col_ecommerce_identifies_timestamp'))}} and {{ var('main_id')}} is not null