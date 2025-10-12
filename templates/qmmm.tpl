&qmmm
    qmmask = '{{ qmmask | default('') }}', ! QM region
    qmcharge = {{ qmcharge | default(0) }}, ! QM charge
    {%- set qm_theory = qm_theory | default('DFTB3', true) %}
    qm_theory = '{{ qm_theory }}', ! QM level of theory
    qmshake = 0, ! SHAKE in the QM region
    writepdb=1, ! out QM region
    printcharges = 1, ! Print Mulliken QM atom charges
    {%- if qm_theory == 'DFTB3' %}
    dftb_telec = 100, ! Electronic temperature
    dftb_slko_path = '{{ dftb_slko_path | default("/path/to/sklo") }}',
    {%- endif %}
&end

