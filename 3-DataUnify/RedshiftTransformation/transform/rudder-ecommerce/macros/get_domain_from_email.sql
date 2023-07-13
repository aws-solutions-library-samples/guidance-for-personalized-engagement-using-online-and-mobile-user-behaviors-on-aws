{% macro get_domain_from_email(email_col) %}
lower(split_part({{email_col}}, '@', 2))
{% endmacro %}