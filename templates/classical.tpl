{{ name }}
&cntrl
    ! General flags
    {%- if type == "minimization" %}
    {%- set imin = 1 %}
    {%- else %}
    {%- set imin = 0 %}
    {%- endif %}
    imin = {{ imin }}, ! Minimization (0=off, 1=on)
    {%- if type == "heating" %}
    nmropt = 1, ! NMROPT flag (0 = off, 1 = on)
    {%- else %}
    nmropt = {{nmropt | default(0) }}, ! NMROPT flag (0 = off, 1 = on)
    {%- endif %}

    ! Nature and format of the input
    irest = {{ irest | default(0) }}, ! Restart simulation (0 = new, 1 = restart)
    {%- if irest == 0 %}
    {%- set ntx = 5 %}
    {%- elif irest == 0 %}
    {%- set ntx = 1 %}
    {%- endif %}
    ntx = {{ ntx }}, ! Input format (1 = read coordinates, 5 = and velocities)


    ! Nature and format of the output
    ntxo = {{ ntxo | default(2) }},          ! Coordinate output format
    ntpr = {{ ntpr | default(500) }},        ! Print frequency (steps)
    ntwr = {{ ntwr | default(1) }},          ! Restart write frequency
    iwrap = {{ iwrap | default(1) }},        ! Wrap coordinates (0 = off, 1 = on)
    ntwx = {{ ntwx | default(0) }},          ! Write coordinates to trajectory
    ntwv = {{ ntwv | default(0) }},          ! Write velocities to trajectory
    ioutfm = {{ ioutfm | default(1) }},      ! Output format (1 = NetCDF)
    
    ! Pressure regulation
    {%- set ntp = ntp | default(0) %}
    ntp = {{ ntp }}, ! Pressure scaling (0 = off, 1 = isotropic, 2 = anisotropic)
    {%- if ntp > 0 %}
    pres0 = {{ pres0 | default(1.00000) }}, ! Target pressure (atm)
    comp = {{ comp | default(44.60000) }},  ! Compressibility (10^-6 bar^-1)
    taup = {{ taup | default(1.00000) }},  ! Pressure relaxation time (ps)
    {%- endif %}

    ! Potential function
    {%- set igb = igb | default(0) %}
    igb = {{ igb }}, ! Continuum solvent (0 = off)
    {%- if igb > 0 %}
    {%- set ntb = 0 %}
    {%- elif igb == 0 %}
    {%- if ntp == 0 %}
    {%- set ntb = 1 %}
    {%- elif ntp > 0 %}
    {%- set ntb = 2 %}
    {%- endif %}
    {%- endif %}
    ntb = {{ ntb }}, ! Periodic Boundaries conditions (0 = off, 1 = Cnst. Volume, 2 = Cnst. Pressure)
    {%- set ntc = ntc | default(2) %}
    ntc = {{ ntc }}, ! SHAKE algorithm (1 = off, 2 = hydrogens, 3 = all)
    {%- if ntc == 1 %}
    {%- set ntf = 1 %}
    {%- elif ntc == 2 %}
    {%- set ntf = 2 %}
    {%- elif ntc == 3 %}
    {%- set ntc = 3 %}
    {%- endif %}
    ntf = {{ ntf }}, ! Force evaluation (1 = all atoms, 2 = no bonds with H, 3 = omitt all)
    cut = {{ cut | default(10) }}, ! Non-Bonded interactions cutoff
    nsnb = {{ nsnb | default(10) }}, ! Frequency to update non-bonded list 
    
    ! Frozen or restrained atoms
    {%- set ntr = ntr | default(0) %}
    ntr = {{ ntr }}, ! Restraints (0 = off, 1 = on)
    {%- if ntr == 1 %}
    restraint_wt = {{ restraint_wt | default(200) }}, ! Restraint weight
    restraintmask = '{{ restraintmask | default("!@H=") }}', ! Restraint mask
    {%- endif %}
    {%- if type == "minimization" %}
    {% include "minimization.tpl" %}
    {%- elif type == "heating" %}
    {% include "production.tpl" %}
    {% include "heating.tpl" %}
    {%- elif type == "production" or type == "equilibration" %}
    {% include "production.tpl" %}
    {%- endif %}
{{ "\n" }}
