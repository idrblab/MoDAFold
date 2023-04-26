#!/bin/bash

filename=$1
protein=$2
num_amino=$3
num_atom=$4
gpu_device=$5

pdb4amber -i $filename -o "$protein"_noH.pdb -y --dry
reduce "$protein"_noH.pdb > "$protein"_H.pdb
pdb4amber -i "$protein"_H.pdb -o "$protein".pdb

echo "#tleap.in
source leaprc.protein.ff14SB
source leaprc.water.tip3p
$protein = loadpdb $protein.pdb
saveamberparm $protein "$protein"_start.prmtop "$protein"_start.inpcrd
solvateoct $protein TIP3PBOX 10.0
addions $protein Cl- 0
addions $protein Na+ 0
saveamberparm $protein $protein.prmtop $protein.inpcrd
Quit" > tleap.in

if [ -e tleap.in ]
then
    tleap -f tleap.in

fi

echo "&cntrl
  imin = 1,
  maxcyc = 5000,
  ncyc = 2500,
  ntb = 1,
  ntp = 0,
  cut = 8,
  ntwx = 500,
  ntpr = 500,
  ntwr = 500,
  ntr = 1,
  restraintmask = ':1-$num_amino',
  restraint_wt = 2,
  ntxo = 1,
  ioutfm = 1,
&end" > 01_min.in 

echo "&cntrl
  imin = 1,
  maxcyc = 5000,
  ncyc = 2500,
  ntb = 1,
  ntp = 0,
  cut = 8,
  ntwx = 500,
  ntpr = 500,
  ntwr = 500,
  ntr = 0,
  ntxo = 1,
  ioutfm = 1,
&end
" > 02_min.in

echo "&cntrl
  imin = 0,
  irest = 0,
  ntx = 1,
  nstlim = 25000,
  dt = 0.002,
  ntc = 2,
  ntf = 2,
  tol = 0.000001,
  ntr = 1,
  iwrap = 1,
  ntb = 1,
  cut = 12,
  ntt = 3,
  gamma_ln = 2.0,
  tempi = 0.0,
  temp0 = 300.0,
  ntpr = 500,
  ntwx = 500,
  ntwr = 500,
  ntr = 1,
  restraintmask = ':1-$num_amino',
  restraint_wt = 2,
  ntxo = 1,
  ioutfm = 1,
  ig = -1,
  ntwprt = $num_atom,
&end" > 03_heat.in

echo "&cntrl
  imin = 0,
  irest = 1,
  ntx = 5,
  nstlim = 50000,
  dt = 0.002,
  ntc = 2,
  ntf = 2,
  tol = 0.000001,
  iwrap = 1,
  ntb = 2,
  ntp = 1,
  taup = 2.0,
  cut = 12,
  ntt = 3,
  gamma_ln = 2.0,
  tempi = 300.0,
  temp0 = 300.0,
  ntpr = 5000,
  ntwx = 5000,
  ntwr = 5000,
  ntr = 0,
  ntxo = 1,
  ioutfm = 1,
  ig = -1,
  ntwprt = $num_atom,
&end" > 04_equil.in

echo "&cntrl
  imin = 0,
  irest = 1,
  ntx = 5,
  nstlim = 250000000,
  dt = 0.002,
  ntc = 2,
  ntf = 2,
  tol = 0.000001,
  iwrap = 1,
  ntb = 2,
  ntp = 1,
  taup = 2.0,
  cut = 12,
  ntt = 3,
  gamma_ln = 2.0,
  tempi = 300.0,
  temp0 = 300.0,
  ntpr = 5000,
  ntwx = 5000,
  ntwr = 5000,
  ntr = 0,
  ntxo = 1,
  ioutfm = 1,
  ig = -1,
  ntwprt = $num_atom,
&end" > 05_prod.in

echo "&cntrl
  imin = 0,
  irest = 1,
  ntx = 5,
  nstlim = 50000000,
  dt = 0.002,
  ntc = 2,
  ntf = 2,
  tol = 0.000001,
  iwrap = 1,
  ntb = 2,
  ntp = 1,
  taup = 2.0,
  igb=2,
  saltcon=0.1,
  icnstph=1,
  solvph=4.4, 
  ntcnstph=0.5,
  cut = 12,
  ntt = 3,
  gamma_ln = 2.0,
  tempi = 300.0,
  temp0 = 300.0,
  ntpr = 5000,
  ntwx = 5000,
  ntwr = 5000,
  ntr = 0,
  ntxo = 1,
  ioutfm = 1,
  ig = -1,
  ntwprt = $num_atom,

  igamd = 3,
  iE = 1,
  irest_gamd = 0,
  ntcmdprep = 200000,
  ntcmd = 2000000,
  ntebprep = 200000,
  nteb = 24000000,
  ntave = 200000, 
  sigma0P = 6.0,
  sigma0D = 6.0,
&end" > gamd_0.in

echo "&cntrl
  imin = 0,
  irest = 0,
  ntx = 1,
  nstlim = 100000000,
  dt = 0.002,
  ntc = 2,
  ntf = 2,
  tol = 0.000001,
  iwrap = 1,
  ntb = 2,
  ntp = 1,
  taup = 2.0,
  igb=2,
  saltcon=0.1,
  icnstph=1,
  solvph=4.4, 
  ntcnstph=0.5,
  cut = 12,
  ntt = 3,
  gamma_ln = 2.0,
  tempi = 300.0,
  temp0 = 300.0,
  ntpr = 5000,
  ntwx = 5000,
  ntwr = 5000,
  ntr = 0,
  ntxo = 1,
  ioutfm = 1,
  ig = -1,
  ntwprt = $num_atom,
  
  igamd = 3,
  iE = 1,
  irest_gamd = 1,
  ntcmdprep = 0,
  ntcmd = 0,
  ntebprep = 0,
  nteb = 0,
  ntave = 400000,
  sigma0P = 6.0,
  sigma0D = 6.0,
&end" > gamd_1.in

echo "&cntrl
  imin = 0,
  irest = 1,
  ntx = 5,
  nstlim = 100000000,
  dt = 0.002,
  ntc = 2,
  ntf = 2,
  tol = 0.000001,
  iwrap = 1,
  ntb = 2,
  ntp = 1,
  taup = 2.0,
  igb=2,
  saltcon=0.1,
  icnstph=1,
  solvph=4.4, 
  ntcnstph=0.5,
  cut = 12,
  ntt = 3,
  gamma_ln = 2.0,
  tempi = 300.0,
  temp0 = 300.0,
  ntpr = 5000,
  ntwx = 5000,
  ntwr = 5000,
  ntr = 0,
  ntxo = 1,
  ioutfm = 1,
  ig = -1,
  ntwprt = $num_atom,
  
  igamd = 3,
  iE = 1,
  irest_gamd = 1,
  ntcmdprep = 0,
  ntcmd = 0,
  ntebprep = 0,
  nteb = 0,
  ntave = 400000,
  sigma0P = 6.0,
  sigma0D = 6.0,
&end" > gamd_2.in



if [ -e $protein.prmtop ]
then
 export CUDA_VISIBLE_DEVICES=$gpu_device
 pmemd.cuda -O -i 01_min.in -o 01_min.out -p $protein.prmtop -c $protein.inpcrd -ref $protein.inpcrd -x 01_min.nc -r 01_min.rst

fi

if [ -e 01_min.out ]
then
 export CUDA_VISIBLE_DEVICES=$gpu_device
 pmemd.cuda -O -i 02_min.in -o 02_min.out -p $protein.prmtop -c 01_min.rst -ref 01_min.rst -x 02_min.nc -r 02_min.rst

fi

if [ -e 02_min.out ]
then
 export CUDA_VISIBLE_DEVICES=$gpu_device
 pmemd.cuda -O -i 03_heat.in -o 03_heat.out -p $protein.prmtop -c 02_min.rst -ref 02_min.rst -x 03_heat.nc -r 03_heat.rst 

fi

if [ -e 03_heat.out ]
then
 export CUDA_VISIBLE_DEVICES=$gpu_device
 pmemd.cuda -O -i 04_equil.in -o 04_equil.out -p $protein.prmtop -c 03_heat.rst -ref 03_heat.rst -x 04_equil.nc -r 04_equil.rst

fi

if [ -e 04_equil.out ]
then
 export CUDA_VISIBLE_DEVICES=$gpu_device
 pmemd.cuda -O -i 05_prod.in -o 05_prod.out -p $protein.prmtop -c 04_equil.rst -ref 04_equil.rst -x 05_prod.nc -r 05_prod.rst

fi

if [ -e 05_prod.out ]
then
  export CUDA_VISIBLE_DEVICES=$gpu_device
  pmemd.cuda -O -i gamd_0.in -o gamd_00.out -p $protein.prmtop -c 05_prod.rst -r gamd_00.rst -x gamd_00.nc -gamd gamd_00.log

fi

if [ -e gamd_00.out ]
then
  export CUDA_VISIBLE_DEVICES=$gpu_device
  pmemd.cuda -O -i gamd_1.in -o gamd_01.out -p $protein.prmtop -c gamd_00.rst -r gamd_01.rst -x gamd_01.nc -gamd gamd_01.log 

fi

if [ -e gamd_01.out ]
then
  export CUDA_VISIBLE_DEVICES=$gpu_device
  pmemd.cuda -O -i gamd_2.in -o gamd_02.out -p $protein.prmtop -c gamd_01.rst -r gamd_02.rst -x gamd_02.nc -gamd gamd_02.log 

fi

if [ -e gamd_02.out ]
then
  export CUDA_VISIBLE_DEVICES=$gpu_device
  pmemd.cuda -O -i gamd_2.in -o gamd_03.out -p $protein.prmtop -c gamd_02.rst -r gamd_03.rst -x gamd_03.nc -gamd gamd_03.log

fi

# if [ -e gamd_03.out ]
# then
#   export CUDA_VISIBLE_DEVICES=$gpu_device
#   pmemd.cuda -O -i gamd_2.in -o gamd_04.out -p $protein.prmtop -c gamd_03.rst -r gamd_04.rst -x gamd_04.nc -gamd gamd_04.log

# fi

# if [ -e gamd_04.out ]
# then
#   export CUDA_VISIBLE_DEVICES=$gpu_device
#   pmemd.cuda -O -i gamd_2.in -o gamd_05.out -p $protein.prmtop -c gamd_04.rst -r gamd_05.rst -x gamd_05.nc -gamd gamd_05.log

# fi

# if [ -e gamd_05.out ]
# then
#   export CUDA_VISIBLE_DEVICES=$gpu_device
#   pmemd.cuda -O -i gamd_2.in -o gamd_06.out -p $protein.prmtop -c gamd_05.rst -r gamd_06.rst -x gamd_06.nc -gamd gamd_06.log

# fi

# if [ -e gamd_06.out ]
# then
#   export CUDA_VISIBLE_DEVICES=$gpu_device
#   pmemd.cuda -O -i gamd_2.in -o gamd_07.out -p $protein.prmtop -c gamd_06.rst -r gamd_07.rst -x gamd_07.nc -gamd gamd_07.log

# fi

# if [ -e gamd_07.out ]
# then
#   export CUDA_VISIBLE_DEVICES=$gpu_device
#   pmemd.cuda -O -i gamd_2.in -o gamd_08.out -p $protein.prmtop -c gamd_07.rst -r gamd_08.rst -x gamd_08.nc -gamd gamd_08.log

# fi

# if [ -e gamd_08.out ]
# then
#   export CUDA_VISIBLE_DEVICES=$gpu_device
#   pmemd.cuda -O -i gamd_2.in -o gamd_09.out -p $protein.prmtop -c gamd_08.rst -r gamd_09.rst -x gamd_09.nc -gamd gamd_09.log

# fi

# if [ -e gamd_09.out ]
# then
#   export CUDA_VISIBLE_DEVICES=$gpu_device
#   pmemd.cuda -O -i gamd_2.in -o gamd_10.out -p $protein.prmtop -c gamd_09.rst -r gamd_10.rst -x gamd_10.nc -gamd gamd_10.log

# fi
echo "DONE"
