
{% for lookback_days in var('lookback_days') %}
select {{var('main_id')}},
'pattern_downloads_in_past_{{lookback_days}}_days' as feature_name, 
count(*) as feature_value from {{ ref('stg_pattern_downloads') }}
where datediff(day, date({{ var('col_patterns_downloaded_timestamp') }}), date({{get_end_timestamp()}})) <= {{lookback_days}}
group by {{var('main_id')}}
union
{% endfor %}
select {{var('main_id')}},
'total_pattern_downloads' as feature_name, 
count(*) as feature_value from {{ ref('stg_pattern_downloads') }}
group by {{var('main_id')}}