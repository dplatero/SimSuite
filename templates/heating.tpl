{%- set nstlim = nstlim | default(10000) %}
{%- set temp0 = temp0 | default(300) %}
{%- set tempi = tempi | default(100) %}
&wt
    {%- set istep1 = 0 %}
    {%- set step_half = (nstlim/2) | int %}
    {%- set temp_half = (tempi + (temp0-tempi)/2) | round(1) %}
    type = 'TEMP0', ! Varying variable
    istep1 = 0,
    istep2 = {{ step_half }},
    value1 = {{ tempi }},
    value2 = {{ temp_half }},
&end
&wt
    {%- set step_half2 = step_half + 1 %}
    type = 'TEMP0', ! Varying variable
    istep1 = {{ step_half2 }},
    istep2 = {{ nstlim }},
    value1 = {{ temp_half }},
    value2 = {{ temp0 }},
&end
&wt
    type = 'TAUTP', ! Varying variable
    istep1 = 0,
    istep2 = {{ step_half }},
    value1 = 0.2,
    value2 = 0.2,
&end
&wt
    type='END'
&end
{{ "\n" }}
