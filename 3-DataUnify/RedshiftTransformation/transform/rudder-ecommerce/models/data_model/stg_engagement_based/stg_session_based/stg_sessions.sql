with cte_incremental_ts as (

    select {{ var('main_id') }}, 
    {{ var('col_ecommerce_tracks_timestamp') }}, 
    coalesce(datediff(second, {{ lag_col( var('col_ecommerce_tracks_timestamp'))}} over(
        partition by {{ var('main_id') }} 
        order by {{ var('col_ecommerce_tracks_timestamp') }} asc
    ),{{ var('col_ecommerce_tracks_timestamp') }}),0) as incremental_ts 
    from {{ ref('stg_tracks') }} 
    where {{timebound( var('col_ecommerce_tracks_timestamp'))}} and {{ var('main_id')}} is not null

), cte_new_session as (

    select {{ var('main_id') }}, 
    {{ var('col_ecommerce_tracks_timestamp') }}, 
    case when incremental_ts >= {{ var('session_cutoff_in_sec') }} then 1 else 0 end as new_session 
    from cte_incremental_ts 

), cte_session_id as (

    select {{ var('main_id') }}, 
    {{ var('col_ecommerce_tracks_timestamp') }}, 
    sum(new_session) over(
        partition by {{ var('main_id') }} 
        order by {{ var('col_ecommerce_tracks_timestamp') }} asc {{frame_clause('rows between unbounded preceding and current row')}}
        ) as session_id 
    from cte_new_session
)

select 
    {{ var('main_id') }}, 
    session_id, 
    min({{ var('col_ecommerce_tracks_timestamp') }}) as session_start_time, 
    max({{ var('col_ecommerce_tracks_timestamp') }}) as session_end_time 
from cte_session_id 
group by {{ var('main_id') }}, session_id