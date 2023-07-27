#!/bin/bash
#SBATCH --job-name="write"
#SBATCH --output="out.write"
#SBATCH --partition=debug
#SBATCH --constraint="lustre"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=8G
#SBATCH --account="ucb321"
#SBATCH --export=ALL
#SBATCH -t 00:30:00

module purge
module load cpu
module load gcc/10.2.0/npcyll4
module load openmpi/4.1.1
module load slurm

name='6.5A_s1'

n_start=30000
n_end=50000

twojmax=8
rcutfac=1.0
wj=1.0
radelem=2.0
wselfallflag=1
chemflag=0
bzeroflag=1
quadraticflag=0
bikflag=1
layer_sizes='[64, 64, 32]'
learning_rate=0.001
num_epochs=50
batch_size=1
multi_element_option=2
training_size=0.95
testing_size=0.05
eweight=1.0
fweight=10.0

partition_ML='compute'
nodes_ML=1
ntaskspernode_ML=4
mem_ML=160
account_ML='ucb321'
time_ML=17
np_ML=4

dt=0.001
TDAMP=10
run_steps=200000

partition_MD='compute'
nodes_MD=4
ntaskspernode_MD=4
mem_MD=8
account_MD='ucb321'
time_MD=2
np_MD=4

mkdir -p runs/$name

srun --mpi=pmi2 -n 1 python -c "from utils import data; data.trj2jsons($n_start, $n_end)"

srun --mpi=pmi2 -n 1 python -c \
"from utils import write; \

write.ml_in('$name',
$twojmax, $rcutfac, $wj, $radelem,\
$wselfallflag, $chemflag, $bzeroflag, $quadraticflag, $bikflag, \
$layer_sizes, $learning_rate, $num_epochs, $batch_size, $multi_element_option, \
$n_start, $n_end, $training_size, $testing_size, $eweight, $fweight); \

write.ml_sh('$name',\
'$partition_ML', $nodes_ML, $ntaskspernode_ML, $mem_ML, '$account_ML', $time_ML, $np_ML) \

write.md_in('$name', $dt, $TDAMP, $run_steps) \

write.md_sh('$name',\
'$partition_MD', $nodes_MD, $ntaskspernode_MD, $mem_MD, '$account_MD', $time_MD, $np_MD) \
"

cp src_files/mof_1co2.data runs/$name/mof_1co2.data
mv *ML.sh *ML.in *MD.sh in.$name out.write runs/$name/
cp write.sh runs/$name/write.sh

