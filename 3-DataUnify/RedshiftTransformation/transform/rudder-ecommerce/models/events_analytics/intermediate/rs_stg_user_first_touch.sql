select *
from
    (
        select
            {{ var('ea_main_id') }},
            first_value({{ var('col_timestamp') }}) over (
                partition by {{ var('ea_main_id') }}
                order by {{ var('col_timestamp') }} asc
                rows between unbounded preceding and unbounded following
            ) as first_seen_ts,
            first_value(referrer) over (
                partition by {{ var('ea_main_id') }}
                order by {{ var('col_timestamp') }} asc
                rows between unbounded preceding and unbounded following
            ) as referrer,
            first_value(utm_source) over (
                partition by {{ var('ea_main_id') }}
                order by {{ var('col_timestamp') }} asc
                rows between unbounded preceding and unbounded following
            ) as utm_source,
            first_value(utm_medium) over (
                partition by {{ var('ea_main_id') }}
                order by {{ var('col_timestamp') }} asc
                rows between unbounded preceding and unbounded following
            ) as utm_medium,
            first_value(channel) over (
                partition by {{ var('ea_main_id') }}
                order by {{ var('col_timestamp') }} asc
                rows between unbounded preceding and unbounded following
            ) as channel,
            first_value(source_medium) over (
                partition by {{ var('ea_main_id') }}
                order by {{ var('col_timestamp') }} asc
                rows between unbounded preceding and unbounded following
            ) as source_medium
        from {{ ref('rs_stg_all_events') }}
    )
group by 1, 2, 3, 4, 5, 6, 7
