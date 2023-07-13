/*

Below code creates a table to link the track events to the session they belong to. 
The session association is established via the user identifier linkage and the user session start timestamp. 

So if a user U1 has session S1 with start time as T1 and session S2 with start time as T2 - then event E for user U1 would belong to session S1 if its timestamp falls between T1 and T2 or if T2 is null. 
The second case occurs for the last recorded session for that user.

*/


{{ config(materialized='table') }}

select t.anonymous_id
          , t.event_timestamp
          , t.event_id
          , t.event AS event
          , s.session_id
          , t.dbt_visitor_id
          , row_number() over(partition by s.session_id order by t.event_timestamp) as track_sequence_number
        from {{ ref('dbt_mapped_tracks') }} as t
        inner join {{ ref('dbt_session_tracks') }} as s
        on t.dbt_visitor_id = s.dbt_visitor_id
          and t.event_timestamp >= s.session_start_at
          and (t.event_timestamp < s.next_session_start_at or s.next_session_start_at is null)
