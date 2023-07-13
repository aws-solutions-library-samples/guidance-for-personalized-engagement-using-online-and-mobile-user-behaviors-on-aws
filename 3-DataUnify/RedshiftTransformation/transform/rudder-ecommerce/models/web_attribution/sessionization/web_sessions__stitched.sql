
{{ config(
    materialized = 'incremental',
    unique_key = 'session_id',
    sort = 'session_start_tstamp',
    dist = 'session_id'
    )}}

with sessions as (

    select * from {{ref('web_sessions__initial')}}

    {% if is_incremental() %}
        where cast(session_start_tstamp as datetime) > (
          select
            {{ dbt.dateadd(
                'hour',
                -var('sessionization_trailing_window'),
                'max(session_start_tstamp)'
            ) }}
          from {{ this }})
    {% endif %}

),

id_stitching as (

    select alias as anonymous_id, dbt_visitor_id as user_id from {{ref('dbt_aliases_mapping')}}

),

joined as (

    select

        sessions.*,

        coalesce(id_stitching.user_id, sessions.anonymous_id)
            as blended_user_id

    from sessions
    left join id_stitching using (anonymous_id)

)

select * from joined
