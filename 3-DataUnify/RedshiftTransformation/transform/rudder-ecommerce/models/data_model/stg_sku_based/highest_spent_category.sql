{% if var('category_ref_var') != '' %}
  {{config(enabled=True)}}
{% else %}
  {{config(enabled=False)}}
{% endif %}

{% if target.type == 'redshift' %}
with numbers as ({{dbt_utils.generate_series(upper_bound=var('var_max_cart_size'))}}),
cte_json as ( 

    select {{ var('main_id')}}, 
        {{ var('col_ecommerce_order_completed_properties_products')}}, 
        {{ array_size (  var('col_ecommerce_order_completed_properties_products') )}} as n_array
    from {{ ref('stg_order_completed') }}

), cte_product_data as (

    select {{ var('main_id')}},  
    json_extract_array_element_text({{ var('col_ecommerce_order_completed_properties_products')}}, generated_number::int, true) as product_array
    from cte_json a cross join (select generated_number - 1 as generated_number from numbers) b where b.generated_number <= (a.n_array-1)

), cte_user_spent_category as (

    select {{ var('main_id')}}, 
        json_extract_path_text(product_array, '{{ var('category_ref_var') }}') as {{ var('category_ref_var') }},
        json_extract_path_text(product_array, 'price') as amount
    from cte_product_data

), cte_category_vs_spending as (

    select {{ var('main_id')}}, 
    {{var('category_ref_var')}} as {{ var('category_ref_var') }},
    sum(amount) as amount_spent
    from cte_user_spent_category 
    group by {{ var('main_id')}}, {{ var('category_ref_var') }}
)
{% elif target.type == 'snowflake' %}
with cte_category_vs_spending as (

    select {{ var('main_id')}},
    t.value['{{var('category_ref_var')}}'] as {{ var('category_ref_var') }}, sum(t.value['price']) as amount_spent
    from {{ ref('stg_order_completed') }}, TABLE(FLATTEN(parse_json({{ var('col_ecommerce_order_completed_properties_products')}}))) t
    where {{timebound( var('col_ecommerce_order_completed_timestamp'))}} and {{ var('main_id')}} is not null
    group by {{ var('main_id')}}, {{var('category_ref_var')}}
)
{% endif %}
select 
    {{ var('main_id')}}, 
    {{ var('category_ref_var') }} as highest_spent_category
from (
    select *,
        row_number() over(
        partition by {{ var('main_id')}} 
        order by amount_spent desc
        ) as row_num
    from cte_category_vs_spending
) where row_num = 1
