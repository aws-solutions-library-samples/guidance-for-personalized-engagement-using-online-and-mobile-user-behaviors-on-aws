
select
    event_date,
    referrer,
    source_medium,
    channel,
    count(distinct b.{{var('ea_main_id') }}) as dau
from
    (
        select {{ var('ea_main_id') }}, referrer, source_medium, channel
        from {{ ref('rs_stg_user_first_touch') }}
    ) a
left join
    (
        select distinct event_date, {{ var('ea_main_id') }}
        from {{ ref('rs_stg_session_metrics') }} 
    ) b
    on a.{{ var('ea_main_id') }} = b.{{ var('ea_main_id') }}
group by event_date, referrer, source_medium, channel
order by event_date desc
