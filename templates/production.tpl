{{ name }}
&cntrl
    ! General flags
    imin = {{ imin | default(0) }},          ! Run type (0 = MD, 1 = minimization)
    nmropt = {{ nmropt | default(0) }},      ! NMR options flag (0 = off)

    ! Nature and format of input
    ntx = {{ ntx | default(5) }},            ! Input coords (5 = restart)
    irest = {{ irest | default(1) }},        ! Restart flag (1 = continue)

    ! Nature and format of output
    ntxo = {{ ntxo | default(2) }},          ! Output coordinate format
    ntpr = {{ ntpr | default(500) }},         ! Print frequency
    ntrx = {{ ntrx | default(1) }},          ! Trajectory restart flag
    ntwr = {{ ntwr | default(500) }},        ! Write restart every N steps
    iwrap = {{ iwrap | default(1) }},        ! Wrap coordinates
    ntwx = {{ ntwx | default(500) }},        ! Write coords to trajectory
    ntwv = {{ ntwv | default(0) }},          ! Write velocities to trajectory
    ioutfm = {{ ioutfm | default(1) }},      ! Output format (1 = NetCDF)

    ! Potential function
    {%+ set ntc = ntc | default(2) -%}
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
    nstlim = {{ nstlim | default(5000) }},  ! Number of MD steps
    dt = {{ dt | default(0.002) }},          ! Time step (ps)

    {%+ set temp0 = temp0 | default(300.0) -%}
    {%- set tempi = tempi | default(300.0) +%}
    ! Temperature control
    ntt = {{ ntt | default(3) }},                ! Thermostat type (0=none, 1=Berendsen, 2=Andersen, 3=Langevin)
    temp0 = {{ temp0 | default(300.00000) }},    ! Target temperature (K)
    tempi = {{ tempi | default(300.00000) }},    ! Initial temperature (K)
    ig = {{ ig | default(-1) }},             ! Random seed (stochastic thermostats)
    gamma_ln = {{ gamma_ln | default(1.00000) }},! Friction coefficient (Langevin ps^-1)
    tautp = {{ tautp | default(0.0) }},          ! Coupling constant (ignored if ntt=3)

    ! Pressure regulation (barostat)
    ntp = {{ ntp | default(0) }},           ! Pressure coupling (0 = off, 1 = isotropic)
    pres0 = {{ pres0 | default(1.00000) }}, ! Target pressure (atm)
    comp = {{ comp | default(44.60000) }},  ! Compressibility (10^-6 bar^-1)
    taup = {{ taup | default(1.00000) }},  ! Pressure relaxation time (ps)

    ! SHAKE algorithm
    ntc = {{ ntc | default(2) }},            ! SHAKE constraint flag (2 = H-bonds)
    tol = {{ tol | default(0.00001) }},      ! SHAKE tolerance
&end
{{ "\n" }}
