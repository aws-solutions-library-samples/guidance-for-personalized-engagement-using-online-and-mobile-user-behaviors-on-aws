with cte_purchased_items as 
(
    select a.*, b.item_id
    from {{ ref('stg_order_completed') }} a
    left join (
        select order_id, item_id
        from {{ source('rs', 'master_orderitems') }}  
    ) b on a.order_id = b.order_id
)
select {{ var('main_id') }}, listagg( distinct item_id, ', ') as {{ var('product_ref_var') }} from cte_purchased_items
group by 1