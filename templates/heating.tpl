{{ name }}
&cntrl
    ! General flags
    imin = {{ imin | default(0) }},          ! Run type (0 = MD, 1 = minimization)
    nmropt = {{ nmropt | default(1) }},      ! NMR options flag

    ! Nature and format of input
    ntx = {{ ntx | default(1) }},            ! Input coordinates format
    irest = {{ irest | default(0) }},        ! Restart flag (0 = new, 1 = continue)

    ! Nature and format of output
    ntxo = {{ ntxo | default(2) }},          ! Coordinate output format
    ntpr = {{ ntpr | default(5000) }},       ! Print frequency (steps)
    ntrx = {{ ntrx | default(1) }},          ! Trajectory restart flag
    ntwr = {{ ntwr | default(5000) }},       ! Write restart frequency
    iwrap = {{ iwrap | default(1) }},        ! Wrap coordinates
    ntwx = {{ ntwx | default(5000) }},       ! Write coordinates to trajectory
    ntwv = {{ ntwv | default(0) }},          ! Write velocities to trajectory
    ioutfm = {{ ioutfm | default(1) }},      ! Output format (1 = NetCDF)

    ! Potential function
    {%+ set nct = ntc | default(2) -%}
    ntc = {{ ntc }},
    {%+ if ntc == 2 -%}
    {%- set ntf = 2 -%}
    {%- elif ntc == 3 -%}
    {%- set ntf = 3 -%}
    {%- else -%}
    {%- set ntf = ntf | default(2) -%}
    {%- endif +%}
    ntf = {{ ntf }},                         ! Force evaluation flag
    {%+ if ntp == 0 -%}
    {%- set ntb = ntb | default(1) -%}
    {%- elif ntp == 1 -%}
    {%- set ntb = ntb | default(2) -%}
    {%- endif +%}
    ntb = {{ ntb }},                         ! Periodic boundary conditions
    igb = {{ igb | default(0) }},            ! Implicit solvent model (0 = off)
    nsnb = {{ nsnb | default(10) }},         ! Nonbonded pair list update freq
    cut = {{ cut | default(10.00000) }},     ! Nonbonded cutoff (Å)

    {%+ set ntr = ntr | default(0) -%}
    {%- if ntr == 1 +%}
    ! Frozen or restrained atoms
    ntr = {{ ntr | default(1) }},            ! Positional restraints (1 = on)
    restraint_wt = {{ restraint_wt | default(200.0) }}, ! Restraint weight (kcal/mol·Å²)
    restraintmask = '{{ restraintmask | default("!@H=") }}',   ! Restraint mask
    {%- endif +%}

    ! Molecular dynamics
    {% set nstlim = nstlim | default(100000) %}
    nstlim = {{ nstlim }},     ! Number of MD steps
    dt = {{ dt | default(0.0005) }},            ! Time step (ps)

    {%+ set temp0 = temp0 | default(300.0) -%}
    {%- set tempi = tempi | default(100.0) +%}
    ! Temperature control
    temp0 = {{ temp0 }},                         ! Target temperature (K)
    tempi = {{ tempi }},                         ! Initial temperature (K)
    ig = {{ ig | default(-1) }},                 ! Random seed for thermostat (used if stochastic)
    gamma_ln = {{ gamma_ln | default(1.00000) }},! Friction coefficient (Langevin, ps^-1)
    tautp = {{ tautp | default(0.00000) }},      ! Temperature coupling constant (Berendsen/Nose-Hoover, ps)
    ntt = {{ ntt | default(3) }},                ! Thermostat type (0=none, 1=Berendsen, 2=Andersen, 3=Langevin, 4=weak coupling)

    ! SHAKE algorithm
    ntc = {{ ntc | default(2) }},            ! SHAKE flag (2 = bonds to H)
&end
&wt
    {%+ set istep1 = 0 -%}
    {%- set step_half = (nstlim/2) | int -%}
    {%- set temp_half = (tempi + (temp0-tempi)/2) | round(1) +%}
    type = 'TEMP0', ! Varying variable
    istep1 = 0,
    istep2 = {{ step_half }},
    value1 = {{ tempi }},
    value2 = {{ temp_half }},
&end
&wt
    {% set step_half2 = step_half + 1 %}
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
    type = 'TAUTP', ! Varying variable
    istep1 = {{ step_half2 }},
    istep2 = {{ nstlim }},
    value1 = 1.0,
    value2 = 1.0,
&end
&wt
    type='END'
&end
{{ "\n" }}
