
    ! Molecular dynamics
    nstlim = {{ nstlim | default(10000) }},  ! Number of MD steps
    dt = {{ dt | default(0.002) }},          ! Time step (ps)

    ! Temperature control
    {%- set temp0 = temp0 | default(300.0) %}
    {%- set tempi = tempi | default(300.0) %}
    ntt = {{ ntt | default(3) }},                ! Thermostat type (0=none, 1=Berendsen, 2=Andersen, 3=Langevin)
    temp0 = {{ temp0 | default(300.00000) }},    ! Target temperature (K)
    tempi = {{ tempi | default(300.00000) }},    ! Initial temperature (K)
    ig = {{ ig | default(-1) }},             ! Random seed (stochastic thermostats)
    gamma_ln = {{ gamma_ln | default(1.00000) }},! Friction coefficient (Langevin ps^-1)
    tautp = {{ tautp | default(0.0) }},          ! Coupling constant (ignored if ntt=3)
&end
{{ "\n" }}
