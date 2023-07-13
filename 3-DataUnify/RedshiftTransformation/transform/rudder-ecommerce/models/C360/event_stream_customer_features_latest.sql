{{ config( 
    materialized = 'view'
   ) 
}} 

select * from {{ ref('event_stream_customer_features') }}
where timestamp = (select max(timestamp) from {{ ref('event_stream_customer_features') }} )