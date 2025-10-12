{{ name }}
&cntrl
    ! General flags
    imin = 1,                                ! Run type (1 = minimization)
    nmropt = {{ nmropt | default(0) }},      ! NMROPT flag (0 = none)

    ! Nature and format of input
    ntx = 1,                                 ! Input coordinates format
    irest = 0,                               ! Restart flag (0 = new simulation)

    ! Nature and format of output
    ntxo = {{ ntxo | default(2) }},          ! Coordinate output format
    ntpr = {{ ntpr | default(500) }},        ! Print frequency (steps)
    ntwr = {{ ntwr | default(1) }},          ! Restart write frequency
    iwrap = {{ iwrap | default(0) }},        ! Wrap coordinates (0 = no)
    ntwx = {{ ntwx | default(0) }},          ! Write coordinates to trajectory
    ntwv = {{ ntwv | default(0) }},          ! Write velocities to trajectory
    ioutfm = {{ ioutfm | default(1) }},      ! Output format (1 = NetCDF)

    ! Potential function
    ntf = {{ ntf | default(1) }},            ! Force evaluation flag
    ntb = {{ ntb | default(1) }},            ! Periodic boundary conditions
    nsnb = {{ nsnb | default(10) }},         ! Nonbonded pair list update
    cut = {{ cut | default(10.00000) }},     ! Nonbonded cutoff distance
    
    {%+ set ntr = ntr | default(0) -%}
    {%- if ntr == 1 -%}
    ! Frozen or restrained atoms
    ntr = {{ ntr }},            ! Positional restraints (1 = yes)
    restraint_wt = {{ restraint_wt | default(200.0)}}, ! Restraint weight
    restraintmask = '{{ restraintmask | default("!@H=") }}',   ! Restraint mask
    {%- endif +%}
    
    ! Energy minimization
    maxcyc = {{ maxcyc | default(20000) }},   ! Total minimization cycles
    ncyc = {{ ncyc | default(1000) }},       ! Steepest descent cycles
    ntmin = {{ ntmin | default(1) }},        ! Minimization method (1 = steepest descent)
    dx0 = {{ dx0 | default(0.10000) }},      ! Initial step size
    drms = {{ drms | default(0.01000) }},    ! Convergence criterion
&end
{{ "\n" }}