{{ config( 
    materialized = 'table'
   ) 
}}

with cte_id_stitched_tracks as (

    {{id_stitch( var('tbl_ecommerce_tracks'), [ var('col_ecommerce_identifies_user_id'), var('col_ecommerce_identifies_anonymous_id')], var('col_ecommerce_tracks_timestamp'))}}
    
)

select * from cte_id_stitched_tracks