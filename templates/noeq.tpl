{%- if noeq_method == 'smd' %}
&smd
    output_file = 'smd_qmmm.txt',
{%- elif noeq_method == 'usampling' %}
&pmd
    output_file = 'pmd_qmmm.txt',
{%- endif %}
    output_freq = 50,
    cv_file = 'cv.in',
&end

