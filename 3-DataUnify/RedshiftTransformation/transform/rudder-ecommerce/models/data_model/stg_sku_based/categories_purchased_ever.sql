{% if var('category_ref_var') != '' %}
  {{config(enabled=True)}}
{% else %}
  {{config(enabled=False)}}
{% endif %}


{% if target.type == 'redshift' %}
with numbers as ({{dbt_utils.generate_series(upper_bound=var('var_max_list_size'))}}),
cte_json as ( 

    select {{ var('main_id')}}, 
        {{ var('col_ecommerce_order_completed_properties_products')}}, 
        {{ array_size ( var('col_ecommerce_order_completed_properties_products') )}}  as n_array
    from {{ ref('stg_order_completed') }}

), cte_product_data as (

    select {{ var('main_id')}},  
    json_extract_array_element_text({{ var('col_ecommerce_order_completed_properties_products')}}, generated_number::int, true) as product_array
    from cte_json a cross join (select generated_number - 1 as generated_number from numbers) b where b.generated_number <= (a.n_array-1)

), cte_user_product_category as (

    select {{ var('main_id')}}, 
        json_extract_path_text(product_array, '{{ var('category_ref_var') }}') as {{ var('category_ref_var') }} 
    from cte_product_data

), cte_users_n_categories as (
    select {{ var('main_id') }}, count(distinct {{ var('category_ref_var') }}) as n_categories
    from cte_user_product_category group by 1 
), cte_user_product_category_eligible_users as (
    select a.* from cte_user_product_category a inner join cte_users_n_categories b on 
    a.{{ var('main_id') }} = b.{{ var('main_id') }} where n_categories < {{ var('var_max_list_size') }}
)

{% endif %}
select {{ var('main_id')}}, 
{% if target.type == 'redshift' %}
    {{array_agg( var('category_ref_var') )}} as {{ var('category_ref_var') }}
from cte_user_product_category_eligible_users
{% else %}
array_agg(distinct t.value['{{var('category_ref_var')}}']) as {{ var('category_ref_var') }} 
from {{ ref('stg_order_completed') }} , TABLE(FLATTEN(parse_json({{ var('col_ecommerce_order_completed_properties_products')}}))) t
where {{timebound( var('col_ecommerce_order_completed_timestamp'))}} and {{ var('main_id')}} is not null
{% endif %}
group by {{ var('main_id')}}