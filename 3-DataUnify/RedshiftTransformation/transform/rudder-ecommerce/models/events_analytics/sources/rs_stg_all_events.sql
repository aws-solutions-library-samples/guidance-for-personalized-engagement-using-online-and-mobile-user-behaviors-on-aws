{{
    config(
        materialized='ephemeral'
    )
}}
with
    cte_tracks as ({{ get_utm_params(var('tbl_rudder_tracks')) }}),
    cte_pages as ({{ get_utm_params(var('tbl_rudder_pages')) }}),
    cte_identifies as ({{ get_utm_params(var('tbl_rudder_identifies')) }}),
    cte_all_events as 
(
    select *, {{ get_channel('utm_source', 'utm_medium', 'referrer') }} as channel, {{get_device_type(var('col_screen_height'), var('col_screen_width'))}} as device_type
    from cte_tracks where {{ var('col_timestamp') }} >= '{{ var('start_dt') }}'
    union all
    select *, {{ get_channel('utm_source', 'utm_medium', 'referrer') }} as channel, {{get_device_type(var('col_screen_height'), var('col_screen_width'))}} as device_type
    from cte_pages where {{ var('col_timestamp') }} >= '{{ var('start_dt') }}'
    union all
    select *, {{ get_channel('utm_source', 'utm_medium', 'referrer') }} as channel, {{get_device_type(var('col_screen_height'), var('col_screen_width'))}} as device_type
    from cte_identifies where {{ var('col_timestamp') }} >= '{{ var('start_dt') }}'
)
select *, case when coalesce(utm_source, utm_medium) = utm_medium then coalesce(utm_source, utm_medium) else 
utm_source || '-' || utm_medium end as source_medium from 
cte_all_events