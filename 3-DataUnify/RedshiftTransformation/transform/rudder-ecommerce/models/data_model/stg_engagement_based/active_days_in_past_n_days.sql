{{ config( 
    materialized = 'view'
   ) 
}} 
with cte_active_days_in_past_n_days as (

    {% for lookback_days in var('lookback_days') %}
        select {{ var('main_id') }},
        count(distinct date({{ var('col_ecommerce_tracks_timestamp') }})) as active_days_in_past_n_days,
        {{lookback_days}} as n_value
        from {{ ref('stg_tracks') }}
        where datediff(day, date({{ var('col_ecommerce_tracks_timestamp') }}), date({{get_end_timestamp()}})) <= {{lookback_days}} and {{timebound( var('col_ecommerce_tracks_timestamp'))}} and {{ var('main_id')}} is not null
        group by {{ var('main_id') }}
    {% if not loop.last %} union {% endif %}
    {% endfor %}
)

{% for lookback_days in var('lookback_days') %}
select {{ var('main_id') }}, 
    'active_days_in_past_{{lookback_days}}_days' as feature_name, active_days_in_past_n_days as feature_value 
from cte_active_days_in_past_n_days 
where n_value = {{lookback_days}}
{% if not loop.last %} union {% endif %}
{% endfor %}