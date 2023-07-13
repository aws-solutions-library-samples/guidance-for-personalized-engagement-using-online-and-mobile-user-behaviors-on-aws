{% macro get_age_from_dob(birthday_col) %}
CASE WHEN getdate() < {{ get_end_date() }}
THEN
(CASE WHEN dateadd(year, datediff (year, {{birthday_col}}, getdate()), {{birthday_col}}) > getdate()
      THEN datediff(year, {{birthday_col}}, getdate()) - 1
      ELSE datediff(year, {{birthday_col}}, getdate())
 END)
 ELSE
(CASE WHEN dateadd(year, datediff (year, {{birthday_col}}, {{ get_end_date() }}), {{birthday_col}}) > {{ get_end_date() }}
      THEN datediff(year, {{birthday_col}}, {{ get_end_date() }}) - 1
      ELSE datediff(year, {{birthday_col}}, {{ get_end_date() }})
 END)
 END
 {% endmacro %}