{{ config( 
    materialized = 'incremental', 
    unique_key = 'row_id',
    incremental_strategy='delete+insert'
   ) 
}} 

select
   {{ var('main_id')}},
   feature_name,
   {{get_end_timestamp()}} as {{timestamp_call('timestamp')}},
   feature_value_numeric,
   feature_value_string,
   feature_value_array,
   feature_type,
   {{concat_columns( [ var('main_id'), date_to_char(get_end_timestamp()), "feature_name"])}} as row_id 
from
(
  select 
    {{ var('main_id')}}, 
    feature_name, 
    end_timestamp, 
    cast(feature_value_numeric as real) as feature_value_numeric,
    cast(feature_value_string as varchar) as feature_value_string, 
    feature_value_array, 
    feature_type from  {{ref('stg_user_traits')}}
    union all
    select 
    {{ var('main_id')}}, 
    feature_name, 
    end_timestamp, 
    cast(feature_value_numeric as real) as feature_value_numeric,
    cast(feature_value_string as varchar) as feature_value_string, 
    feature_value_array, 
    feature_type  from {{ref('stg_engagement_features')}}
    union all
    select 
    {{ var('main_id')}}, 
    feature_name, 
    end_timestamp, 
    cast(feature_value_numeric as real) as feature_value_numeric,
    cast(feature_value_string as varchar) as feature_value_string, 
    feature_value_array, 
    feature_type from {{ref('stg_pre_revenue_features')}}
    union all
    select 
    {{ var('main_id')}}, 
    feature_name, 
    end_timestamp, 
    cast(feature_value_numeric as real) as feature_value_numeric,
    cast(feature_value_string as varchar) as feature_value_string, 
    feature_value_array, 
    feature_type  from {{ref('stg_revenue_features')}}
    union all
    select 
    {{ var('main_id')}}, 
    feature_name, 
    end_timestamp, 
    cast(feature_value_numeric as real) as feature_value_numeric,
    cast(feature_value_string as varchar) as feature_value_string, 
    feature_value_array, 
    feature_type from {{ref('stg_sku_based_features')}}
)
