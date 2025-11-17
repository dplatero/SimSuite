#!/bin/python
'''
@authors: Daniel Platero-Rochart 
'''
'''
Automatic creation of classical MD simulations input
'''

from jinja2 import Environment, FileSystemLoader
import yaml
import os
import sys

# Templates
current_dir = os.path.dirname(os.path.abspath(__file__))
env = Environment(loader=FileSystemLoader(f'{current_dir}/templates'))
tpl_file = 'classical.tpl'

# If no arguments, print the configuration template
if len(sys.argv) < 2:
    sys.exit()

# Read the configuration file
print('Reading configuration file ...')
config_file = sys.argv[1]
with open(config_file, 'r') as f:
    config = yaml.safe_load(f) # User config file

# Only ClassicalMD section
section = 'ClassicalMD'
config_keys = config.keys() # Get all section in the config file
if section not in config_keys:
    print(f'{section} section not found')
    sys.exit()

# Creating/Using output dir
try:
    output_dir = config['Output']
except:
    output_dir = './'

if os.path.isdir(output_dir):
    print(f'Writting files in: {output_dir}')
else:
    print(f'Creating output dir: {output_dir}')
    os.mkdir(output_dir)

# Collect data for the templates ===============================================
print('Creating input files ...')

step_no = 0
for step in config[section]:
    step_no += 1
    try:
        step_type = step['type'] # Check step type
    except:
        print(f'Missing type for a step {step_no}')
        sys.exit()
    try:
        step_name = step['name'] # Check step name
    except:
        print(f'Missing name for step {step_no}. Using {step_type} instead')
        step_name = step['type']
    
    template = env.get_template(tpl_file) # load template
    input_file = template.render(**step) # render template with user config
    with open(f'{output_dir}/{step_name}.in', 'w') as f: # write template
        f.write(input_file)    
# ==============================================================================

# Create run file ==============================================================
print('Creating run file')
with open(f'{output_dir}/run.sh', 'w') as f:
    f.write('#!/bin/bash\n\n')
    f.write('mol=$1\n')
    f.write('source /path/to/amber/amber.sh\n')
    f.write('export PMEMD=pmemd.cuda\n')
    
    old_name = '' # name of the previous step
    old_type = '' # type of the previous step

    for step in config[section]:
        step_type = step['type'] # step type
        name = step['name'] # step name

        if step_type != old_type:
            f.write(f'\n# {step_type.capitalize()}\n') # header with step name

        if step_type != 'production': # non-production step
            coord = '$mol.crd' if old_name == '' else f'$mol.{old_name}.rst '
            f.write(f'$PMEMD -O -i {name}.in -o $mol.{name}.out '
                    f'-p $mol.parm7 -c {coord} -r $mol.{name}.rst '
                    f'-ref {coord}\n') 
        elif step_type == 'production': # production steps
            if old_type != 'production':
                f.write('rm -f $1.md0.rst\n')
                f.write(f'ln -s $1.{old_name}.rst $1.md0.rst\n\n')
            try:
                istep = step['istep'] # initial step of the production cycle
                fstep = step['fstep'] # final step of the production cycle
            except:
                print('No steps provided for the md')
                sys.exit()
            f.write(f'for (( i={istep}; i<={fstep}; i++ )); do\n')
            f.write('echo $i\n')
            f.write('j=$((i-1))\n')
            f.write(f'$PMEMD -O -i {name}.in -o $mol.md$i.out -p $mol.parm7 '
                    f'-c $mol.md$j.rst -r $mol.md$i.rst -x $mol.md$i.nc '
                    f'-ref $mol.md$j.rst\n')
            f.write('bzip2 $mol.md$j.nc $mol.md$j.rst\n')
            f.write('done\n\n')
        old_name = name # update old step name
        old_type = step_type # update old step type
# ==============================================================================
print('Files created :)')
