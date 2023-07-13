with cte_id_stitched_order_completed as (
    
    {{id_stitch( var('tbl_ecommerce_order_completed'), [ var('col_ecommerce_order_completed_user_id') ], var('col_ecommerce_order_completed_timestamp'))}}
)

select {{ var('col_ecommerce_order_completed_user_id') }}, 
{{ var('col_ecommerce_order_completed_properties_total') }}::real,
{{ var('col_ecommerce_order_completed_timestamp') }},
{{ var('col_ecommerce_order_completed_properties_products') }},
 {{ var('main_id') }}, order_id,
 'current' as tbl_source from cte_id_stitched_order_completed