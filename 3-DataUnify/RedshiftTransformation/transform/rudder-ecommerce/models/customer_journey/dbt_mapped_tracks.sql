/*

 Use the ID generated while creating dbt_aliases_mapping to link all events for the same user on that device. Also note the idle time between events

*/

{{ config(materialized='table') }}
with dt1 as (
    select t.id as event_id
    ,t.anonymous_id
    ,a2v.dbt_visitor_id
    ,t.timestamp as event_timestamp
    ,t.event as event
  from {{ var("tbl_rudder_tracks") }} as t
  inner join {{ ref('dbt_aliases_mapping') }} as a2v
  on a2v.alias = coalesce(t.user_id, t.anonymous_id)
),
dt2 as (
    select *
    ,lag(event_timestamp) over(partition by dbt_visitor_id order by event_timestamp) as lag_event_timestamp
  from dt1
)
select *
        ,{{ dbt.datediff(
              'lag_event_timestamp',
              'event_timestamp',
              'minute') }} as idle_time_minutes
      from dt2