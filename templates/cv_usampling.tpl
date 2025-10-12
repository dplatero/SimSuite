{{ name | default(cv) }}
{%- set window_size = window_size %}
{%- set position = position %}
{%- set r1 = position - window_size %}
{%- set r2 = position %}
{%- set r4 = position + window_size %}
{%- if type == 'LCOD' %}
&colvar
    cv_type='LCOD',
    cv_ni={{ atoms | length }},
    cv_i={{ atoms | join(', ') }},
    cv_nr={{ coefficients | length }},
    cv_r={{ coefficients | join(', ') }},
    anchor_position={{ r1 | round(3) }},{{ r2 | round(3) }},{{ r2 | round(3) }},{{ r4 | round(3) }},
    anchor_strenght={{ harmonic | join(', ') }},
/

{%- else %}
&colvar
    cv_type={{ type }},
    cv_ni={{ atoms | length }},
    cv_i={{ atoms | join(', ') }},
    anchor_position={{ r1 }},{{ r2 }},{{ r2 }},{{ r4 }},,
    anchor_strenght={{ harmonic }},
/

{%- endif %}
