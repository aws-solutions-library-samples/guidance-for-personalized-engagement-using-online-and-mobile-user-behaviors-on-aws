
select * from {{ref('demographics')}}
union
select * from {{ref('login_properties')}}
union
select * from {{ref('history')}}