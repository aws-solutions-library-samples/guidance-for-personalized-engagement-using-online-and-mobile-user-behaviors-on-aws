with cte_id_stitched_product_added as (
    
    {{id_stitch( var('tbl_ecommerce_product_added'), [ var('col_ecommerce_identifies_user_id'), var('col_ecommerce_identifies_anonymous_id')], var('col_ecommerce_product_added_timestamp') )}}

)
select {{ var('main_id') }}, 
 {{ var('col_ecommerce_product_added_user_id') }},
 {{ var('col_ecommerce_product_added_properties_cart_id') }},
 {{ var('col_ecommerce_product_added_timestamp') }},
 {{ var('properties_product_ref_var') }}
   from cte_id_stitched_product_added   
