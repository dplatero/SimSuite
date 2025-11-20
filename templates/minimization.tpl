
    ! Energy Minimization
    maxcyc = {{ maxcyc | default(5000) }},   ! Total minimization cycles
    ncyc = {{ ncyc | default(1000) }},       ! Steepest descent cycles
    ntmin = {{ ntmin | default(1) }},        ! Minimization method (1 = steepest descent)
    dx0 = {{ dx0 | default(0.10000) }},      ! Initial step size
    drms = {{ drms | default(0.01000) }},    ! Convergence criterion
&end
{{ "\n" }}
