
select 
    {{ var('main_id')}}, 
    least(date(getdate()), {{ get_end_date()}}) - date(min({{ var('col_ecommerce_identifies_timestamp')}} ))
      as days_since_account_creation
from {{ ref('stg_identifies')}} 
group by 1


