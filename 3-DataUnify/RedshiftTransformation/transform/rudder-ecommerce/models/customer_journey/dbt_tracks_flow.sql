/*

We leverage analytic functions like first_value and nth_value to create 5-event sequences that capture the flow of events during a session. 
5 can be increased or decreased as per requirements.

*/

{{ config(materialized='table') }}

with derived_table as (
          select
            event_id,
            session_id,
            track_sequence_number,
            first_value(event IGNORE NULLS) over(partition by session_id order by track_sequence_number asc
              rows between unbounded preceding and unbounded following) as event,
            dbt_visitor_id,
            event_timestamp,
            nth_value(event,2 IGNORE NULLS) over(partition by session_id order by track_sequence_number asc
              rows between unbounded preceding and unbounded following) as second_event,
            nth_value(event,3 IGNORE NULLS) over(partition by session_id order by track_sequence_number asc
              rows between unbounded preceding and unbounded following) as third_event,
            nth_value(event,4 IGNORE NULLS) over(partition by session_id order by track_sequence_number asc
              rows between unbounded preceding and unbounded following) as fourth_event,
            nth_value(event,5 IGNORE NULLS) over(partition by session_id order by track_sequence_number asc
              rows between unbounded preceding and unbounded following) as fifth_event
            from {{ ref('dbt_track_facts') }}
)

select event_id
      , session_id
      , track_sequence_number
      , event
      , dbt_visitor_id
      , cast(event_timestamp as timestamp) as event_timestamp
      , second_event as event_2
      , third_event as event_3
      , fourth_event as event_4
      , fifth_event as event_5
from derived_table a