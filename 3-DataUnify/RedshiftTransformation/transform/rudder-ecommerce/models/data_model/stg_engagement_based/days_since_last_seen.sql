select 
    {{ var('main_id')}}, 
    datediff(day, date(max({{ var('col_ecommerce_tracks_timestamp') }})),date({{get_end_timestamp()}})) as days_since_last_seen
from {{ ref('stg_tracks') }}
where {{timebound( var('col_ecommerce_tracks_timestamp'))}} and {{ var('main_id')}} is not null
group by {{ var('main_id')}}