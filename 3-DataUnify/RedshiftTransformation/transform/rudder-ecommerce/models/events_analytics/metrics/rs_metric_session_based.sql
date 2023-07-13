select
    event_date,
    source_medium,
    channel,
    referrer,
    device_type,
    total_sessions,
    case when total_sessions = 0 then 0 else total_bounced_sessions / total_sessions end as bounce_rate,
    case when total_sessions = 0 then 0 else total_session_length_in_sec / total_sessions end as avg_session_length
from
    (
        select
            event_date,
            source_medium,
            channel,
            referrer,
            device_type,
            sum(n_sessions) as total_sessions,
            sum(bounced_sessions) as total_bounced_sessions,
            sum(total_session_length) as total_session_length_in_sec
        from {{ ref("rs_stg_session_metrics") }}
        group by event_date, source_medium, channel, referrer, device_type
    )
order by event_date desc 