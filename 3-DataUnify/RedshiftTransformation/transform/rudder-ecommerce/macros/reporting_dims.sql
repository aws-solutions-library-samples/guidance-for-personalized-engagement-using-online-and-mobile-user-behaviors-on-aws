/*
1. Referrer: if it is $direct, then 'direct'; Else, strips the www. , .com etc extensions from referring domain (not very extensive.) and takes that as referrer
2. source: if context_campaign_source is not null, then that value is taken. Else, referrer is taken from step 1
3. medium: same as source, just replace context_campaign_source with context_campaign_medium
*/
{% macro get_utm_params(table_name) %}
with
    cte_referrer as (
        select
            {{ var('ea_main_id') }},
            {{ var('col_timestamp') }},
            {{ var('col_session_id') }},
            case
                when lower({{ var('col_referrer') }}) = '$direct'
                then 'direct'
                else
                    regexp_replace(
                        regexp_replace({{ var('col_referring_domain') }}, '^www\.', ''),
                        '\.com(\.\w+)?$|\.co(\.\w+)?$|\.org$',
                        ''
                    )
            end as referrer,
            {{ var('col_utm_source') }},
            {{ var('col_utm_medium') }}, {{ var('col_screen_height') }}, {{ var('col_screen_width') }}
        from {{ table_name }}
    )
select
    {{ var('ea_main_id') }},
    {{ var('col_timestamp') }},
    {{ var('col_session_id') }}, {{ var('col_screen_height') }}, {{ var('col_screen_width') }},
    referrer,
    case
        when
            lower(coalesce({{ var('col_utm_source') }}, 'null')) != 'null'
            and {{ var('col_utm_source') }} != ''
        then lower({{ var('col_utm_source') }})
        else referrer
    end as utm_source,
    case
        when
            lower(coalesce({{ var('col_utm_medium') }}, 'null')) != 'null'
            and {{ var('col_utm_medium') }} != ''
        then lower({{ var('col_utm_medium') }})
        else referrer
    end as utm_medium
from cte_referrer
{% endmacro %}

{% macro like_in(column_name, conditions_list) %}
{% for condition in conditions_list %}
{{ column_name }} like '{{condition}}' {% if not loop.last %} or {% endif %}
{% endfor %}
{% endmacro %}

{% macro is_known_search_engine(referrer) %}
-- Returns 
{{
    like_in(
        referrer,
        (
            '%google.com%',
            '%bing%',
            '%duckduckgo%',
            '%yahoo%',
            '%ecosia.org%',
            '%baidu%',
            '%qwant.com%',
            '%naver%',
        ),
    )
}}
{% endmacro %}

{% macro get_channel(utm_source, utm_medium, referrer) %}
case
    when
        {{ referrer }} = 'direct'
        or {{ utm_source }} = 'direct'
        or {{ utm_medium }} in ('none', 'not set')
    then 'Direct'
    when {{ is_known_search_engine(referrer) }} or {{ utm_medium }} = 'organic'
    then 'Organic Search'
    when
        {{ like_in(utm_medium, ('%display%', 'cpm', 'banner', '%doubleclick%')) }}
        or {{ referrer }} like '%doubleclick%'
    then 'Paid Display'
    when {{ utm_medium }} in ('cpc', 'ppc', 'paidsearch')
    then 'Paid Search'
    when
        (
            {{ utm_medium }} in (
                'social',
                'social-network',
                'social-media',
                'sm',
                'social network',
                'social media'
            )
            or {{ like_in(utm_medium, ('%paidsocial%', '%video%')) }}
            or {{
                like_in(
                    referrer,
                    (
                        '%linkedin%',
                        '%facebook%',
                        '%reddit%',
                        '%twitter%',
                        '%youtube%',
                    ),
                )
            }}
        )
    then 'Social'
    when {{ utm_medium }} = 'email'
    then 'Email'
    when {{ utm_medium }} = 'affiliate'
    then 'Affiliates'
    when {{ utm_medium }} = 'referral'
    then 'Referral'
    when {{ utm_medium }} in ('cpv', 'cpa', 'cpp', 'content-text')
    then 'Other Advertising'

    else '(other)'
end
{% endmacro %}


{% macro get_device_type(screen_height, screen_width) %}
case 
when cast({{screen_height}} as numeric) >= 1024  and cast({{screen_width}} as numeric) >= 768 then 'Desktop'
when cast({{screen_height}} as numeric) between 360 and 414 and cast({{screen_width}} as numeric) between 640 and 896 then 'Mobile'
when cast({{screen_height}} as numeric) between 601 and 1280 and cast({{screen_width}} as numeric) between 800 and 962 then 'Tablet'
when cast({{screen_width}} as numeric) >= 1024  and cast({{screen_height}} as numeric) >= 768 then 'Desktop'
when cast({{screen_width}} as numeric) between 360 and 414 and cast({{screen_height}} as numeric) between 640 and 896 then 'Mobile'
when cast({{screen_width}} as numeric) between 601 and 1280 and cast({{screen_height}} as numeric) between 800 and 962 then 'Tablet'
else 'Others' end
{% endmacro %}