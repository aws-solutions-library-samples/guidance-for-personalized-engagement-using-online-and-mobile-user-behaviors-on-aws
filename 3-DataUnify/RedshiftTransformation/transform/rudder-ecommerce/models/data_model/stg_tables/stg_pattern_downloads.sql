
with cte_id_stitched_pattern_downloads as (
SELECT b.{{ var('main_id') }}, a.*
FROM
  (SELECT *
   FROM {{var('tbl_patterns_downloaded')}}
   
   WHERE 
    {{timebound(var('col_patterns_downloaded_timestamp'))}}  
    ) a
LEFT JOIN {{ var('tbl_id_stitcher') }} b ON 

a.user_id = b.user_id 

where b.user_id is not null

    
)

select * from cte_id_stitched_pattern_downloads

