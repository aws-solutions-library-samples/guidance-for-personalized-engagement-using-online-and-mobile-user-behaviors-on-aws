with cte_is_churned_n_days as (

    {% for lookback_days in var('lookback_days')%}
        select {{ var('main_id') }},
        (case when days_since_last_seen>{{lookback_days}} then 1 else 0 end) as is_churned_n_days,
        {{lookback_days}} as n_value
        from {{ref('days_since_last_seen')}}
        {% if not loop.last %} union {% endif %}
    {% endfor %}

)

{% for lookback_days in var('lookback_days') %}
    select {{ var('main_id') }}, 
    'is_churned_{{lookback_days}}_days' as feature_name, is_churned_n_days as feature_value 
    from cte_is_churned_n_days 
    where n_value = {{lookback_days}}
    {% if not loop.last %} union {% endif %}
{% endfor %}