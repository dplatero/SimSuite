#!/bin/python

from jinja2 import Environment, FileSystemLoader
import yaml
import os
import sys
import mdtraj as md
import numpy as np
from numpy.typing import NDArray

# Templates
current_dir = os.path.dirname(os.path.abspath(__file__)
env = Environment(loader=FileSystemLoader(f'{current_dir}/templates'))
tpl_files = {'production': 'production.tpl',
             'qmmm':'qmmm.tpl',
             'cv': 'cv_usampling.tpl',
             'noeq': 'noeq.tpl'}

# If no arguments, print the configuration template
if len(sys.argv) < 2:
    sys.exit()

# Read the configuration file
print('Reading configuration file ...')
config_file = sys.argv[1]
with open(config_file, 'r') as f:
    config = yaml.safe_load(f) # User config file

# Only USampling section
section = 'USampling'
config_keys = config.keys() # Get all section in the config file
if section not in config_keys:
    print(f'{section} section not found')
    sys.exit()

# Get and check top and traj
try:
    topo_file = config['System']['topology']
    traj_file = config['System']['trajectory']
except:
    print('Topology and/or trajectory file not specified')
    sys.exit()
try:
    os.path.exists(topo_file)
    os.path.exists(traj_file)
except:
    print('Topology and/or trajectory file do not exist')
    sys.exit()

# Get and check variables and collective variables
try:
    variables_list = list(config['Variables'])
    cv_list = list(config['Collective_Variables'])
except:
    print('No variables and/or collective variables not specified')
    sys.exit()

# Load topo and traj
try:
    traj = md.load(traj_file, top=topo_file)
    print(f'Loaded trajectory with {traj.n_frames} frames')
except:
    print('Error while loading the trajectory')
    sys.exit()

# Get variables values =========================================================
variables_dict = {}
for var in variables_list:
    var_name = var['name'] # variable name
    var_type = var['type'] # variable type
    var_atoms = var['atoms'].strip().split()
    var_atoms = np.asarray([var_atoms], dtype=int) - 1
    if var_type == 'distance':
        if len(var_atoms.flatten()) != 2:
            print(f'Variable {var_name} have wrong number of atoms')
            sys.exit()
        values = md.compute_distances(traj, var_atoms) * 10 # to AA
    elif var_type == 'angle':
        if len(var_atoms.flatten()) != 3:
            print(f'Variable {var_name} have wrong number of atoms')
            sys.exit()
        values = md.compute_angles(traj, var_atoms) * 57.2958 # to degrees
    elif var_type == 'dihedral':
        if len(var_atoms.flatten()) != 4:
            print(f'Variable {var_name} have wrong number of atoms')
            sys.exit()
        values = md.compute_dihedrals(traj, var_atoms)
    variables_dict[var['name']] = {'name': var_name, 'type': var_type,
                                   'atoms': var_atoms,
                                   'values': values.flatten()}
# ==============================================================================

# Get collective variables values ==============================================
if len(cv_list) == 0:
    print('No CV defined')
    sys.exit()
elif len(cv_list) > 1: # limit the USampling for a single CV
    print('The current implementation only supports a single CV for USampling')
    sys.exit()

cv_values = {}
for cv in cv_list:
    cv_name = cv['name'] # cv name
    cv_type = cv['type'] # cv type
    cv_vars = cv['variables'].strip().split() # variables in the cv

    values = np.zeros(traj.n_frames)
    atoms = []
    if cv_type == 'LCOD':
        if len(cv_vars) <= 1:
            print(f'CV {cv_name} of type {cv_type} have wrong number of variables')
            sys.exit()
        try:
            coefficients = cv['coefficients'].strip().split() # get the coeff
            coefficients = np.asarray(coefficients, dtype=float)
            if len(coefficients) != len(cv_vars):
                print(f'Wrong number of coefficients for CV {cv_name}')
                sys.exit()
        except:
            print(f'No coefficients found for {cv_name}. Assuming 1')
        
    elif cv_type != 'LCOD':
        if len(cv_vars) > 1:
            print(f'CV {cv_name} of type {cv_type} have wrong number of variables')
            sys.exit()
        coefficients = [1]
    for var, coeff in zip(cv_vars, coefficients):
        values += coeff * variables_dict[var]['values']
        atoms_ = variables_dict[var]['atoms'].flatten()
        atoms_ = np.asarray(atoms_, dtype=int)
        atoms.extend(atoms_)
        print(atoms)
    cv_values[cv_name] = {'name': cv_name, 'type': cv_type,
                          'atoms':atoms, 'values': values,
                          'coefficients': coefficients}
# ==============================================================================

# Find windows based on spacing ================================================
def find_closest(array: NDArray, reference: float) -> tuple: 
    diff = abs(array - reference)
    closest_id = diff.argmin()
    value = array[closest_id]
    return value, closest_id

spacing = config[section]['window_spacing']
cv_name = cv_list[0]['name'] # only because the list has a single CV
cv_i = cv_values[cv_name]['values'][0] # first item in the cv_values

windows_frame, windows_cv = [0], [cv_i] # initial window
reference_value = cv_i

while True: # iterate until all windows are created
    print(f'Window using Frame {windows_frame[-1] + 1} and value {windows_cv[-1]}')
    reference_value += spacing
    value, frame = find_closest(cv_values[cv_name]['values'], reference_value)
    if frame in windows_frame:
        break
    windows_frame.append(frame)
    windows_cv.append(value)
print(f'Total of {len(windows_frame)} with spacing of {spacing} AA')
# ==============================================================================

# Create output folder =========================================================
try:
    output_dir = config['Output']
except:
    output_dir = './'

if os.path.isdir(output_dir):
    print(f'Writting files in: {output_dir}')
else:
    print(f'Creating output dir: {output_dir}')
    os.mkdir(output_dir)

# Writing files ================================================================
for id, frame in enumerate(windows_frame):
    os.mkdir(f'{output_dir}/w{id+1}') # window folder

    # Templates for QM/MM USampling production
    template_prod = env.get_template(tpl_files['production'])
    production_text = template_prod.render(**config[section],
                                           **{'qmmm_flag': 'true',
                                              'noeq_flag': 'true'})
    template_qmmm = env.get_template(tpl_files['qmmm'])
    qmmm_text = template_qmmm.render(**config[section])
    template_noeq = env.get_template(tpl_files['noeq'])
    noeq_text = template_noeq.render(**{'noeq_method':'usampling'})

    with open(f'{output_dir}/w{id+1}/qmmm.in', 'w') as f:
        f.write(production_text + '\n')
        f.write(qmmm_text + '\n')
        f.write(noeq_text)
    
    # Templates for CV file
    cv_value = cv_values[cv_name]['values'][frame]
    template_cv = env.get_template(tpl_files['cv'])
    cv_text = template_cv.render(**config[section], **cv_values[cv_name],
                                 **{'position': cv_value})
    with open(f'{output_dir}/w{id+1}/cv.in', 'w') as f:
        f.write(cv_text)

    # Output frame
    traj_frame = traj[frame]
    traj_frame.save(f'{output_dir}/w{id+1}/frame.rst7')

    # Write run file
    with open(f'{output_dir}/w{id+1}/run.sh', 'w') as f:
        f.write('#!/bin/bash\n\n')
        f.write('mol=$1\n')
        f.write('source /path/to/amber/amber.sh\n')
        f.write('export openmpi=/path/to/openmpi\n')
        f.write('export PATH=${openmpi}/bin/${PATH:+:${PATH}}\n')
        f.write('export mpirun=${openmpi}/bin/mpirun\n')
        f.write('export PMEMD=pmemd.cuda\n\n')

        f.write(f'$PMEMD -O -i qmmm.in -o qmmm.out -p $mol.parm7 '
                f'-c frame.rst7 -r qmmm.rst -x qmmm.nc '
                f'-ref frame.rst7\n')
# ==============================================================================
print('Files created :)')
