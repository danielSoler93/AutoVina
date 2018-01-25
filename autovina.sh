#!/bin/bash

#######################################################
# autoVina: Automatization script for Autodock Vina docking
# 
# https://github.com/miniaoshi/PelePlop
#
# Author: Daniel Soler, daniel.soler@nostrumbiodiscovery.com
#
# Copyright 2017 Daniel Soler
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
########################################################


function dock {

    $pythonsh $MGLTOOLS/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_ligand4.py -l $9 -o $6

 	echo "Receptor: $1"
 	echo "Center of mass: $2 $3 $4"
 	echo "Box size: $5"
 	echo "Ligand to dock: $6"
 	
 	#Launch vina dock
 	vina --receptor $1 --ligand $6 \
 	--center_x $2 \
 	--center_y $3 \
 	--center_z $4 \
 	--size_x $5 \
 	--size_y $5 \
 	--size_z $5 \
 	--cpu $CPU \
 	--exhaustiveness $EXHAUSTIVENESS \
 	--out $7 \
 	| tee "${log_dir}/${8}"
               
}  

#Parse arguments from input
source $(dirname $0)/Utilities/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('infile', help="pdb receptor with ligand inside defining Binding site")
parser.add_argument('cpu', help="Numbers of cpu to perform docking with")
parser.add_argument('exhaustiveness', help="Vina exhaustiveness to use. From 0 to 8.")
parser.add_argument('--resname', '-r', help="residue of the ligand to extrat from pdb", default="LIG")
parser.add_argument('--reschain', '-c', help="chain of the ligand to extrat from pdb", default="Z")
EOF

source env_var.sh


#Check env variables
if [ "$MGLTOOLS" == '' ]; then
    echo "MGLTOOLS IS NOT EXPORTED"
    exit 1
elif [[ $(which pythonsh 2>&1 > /dev/null) != "" ]]; then
	echo "set pythonsh binary folder to $PATH with: $: set export PATH=/path/to/binary/:$PATH"
	exit 1
else

#Set mgltools python
pythonsh=$(which pythonsh)

#Set global variables
pdb=$(basename "$INFILE")
    filename="${pdb%.*}"
initial_system_prepared="${filename}_prep.pdb"
ligand_native="${filename}_ligand.pdb"
ligand_native_pdbqt="${filename}_ligand.pdbqt"
ligand_mae_file="${filename}_ligand.mae"
ligand_minimized_mae="${filename}_ligand_min.mae"
ligand_minimized="${filename}_ligand_min.pdb"
ligand_to_dock="${filename}_ligand.pdbqt"
protein="${filename}_protein.pdb"
protein_to_dock="${filename}_protein.pdbqt"
cross_docking_files="crossligands/*"
split_sd_files_dir="split_sd"
sdfiles="split_sd/*"
results="${filename}_out"
log_dir="${results}/log"
ligand_output="${results}/${filename}_out.pdbqt"


##############################################Vina Dock################################################

#Create results & log directories
mkdir $results
mkdir $log_dir

#remove files
#rm -f $initial_system_prepared
rm -f $ligand_native
rm -f $ligand_mae_file
rm -f $ligand_minimized_mae
rm -f $protein
rm -f $protein_to_dock
rm -f $ligand_output

#Prepare system with maestro prepwizard

#Extract ligand & protein based on ligand chain
sys=$(basename "$INFILE")
sys_name="${sys%.*}"
echo "$INFILE $RESCHAIN"
python Utilities/extract_ligand.py --pdb $INFILE --general_name $sys_name --ligand_chain $RESCHAIN --ligand_res $RESNAME --executing_folder $PWD

#Prepare protein
$pythonsh $MGLTOOLS/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_receptor4.py -r $protein -o $protein_to_dock

#Prepare native ligand pdbqt to create grid
$pythonsh $MGLTOOLS/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_ligand4.py -l $ligand_native -o $ligand_native_pdbqt

#Center of ligand's box
mapfile -t center_of_mass < <(python Utilities/center_of_mass.py $ligand_native)

#Size of ligand's box
box_size=$(perl Utilities/eBoxSize-1.1.pl $ligand_native_pdbqt)


dock $protein_to_dock ${center_of_mass[0]} ${center_of_mass[1]} ${center_of_mass[2]} \
$box_size $ligand_to_dock $ligand_output "${filename}.log" $ligand_minimized

rm $ligand_to_dock $ligand_native

#Crossdock pdb files
for f in $cross_docking_files
do
    filename=$(basename "$f")
    extension="${filename##*.}"
    

	if [[ "$extension" == "sd" || "$extension" == "sdf" ]]; then

		mkdir $split_sd_files_dir
		pushd $split_sd_files_dir

		ligand=$(basename "$filename")
		ligand_name="${ligand%.*}"
		echo "babel "../${f}" -opdb ligand -m"
		babel "../${f}" -opdb "ligand.pdb" -m
		
		popd

	fi
done



#Crossdock sdf files
if [ -d "${split_sd_files_dir}" ]; then

for f in $sdfiles
do
	echo "$f"
	filename=$(basename "$f")
    extension="${filename##*.}"
    
    if [[ "$extension" == "pdb" ]]; then
		
		ligand=$(basename "$filename")
		ligand_name="${ligand%.*}"
		ligand_to_dock="${ligand_name}.pdbqt"
	    ligand_output="${results}/${ligand_name}_out.pdbqt"

	    dock $protein_to_dock ${center_of_mass[0]} ${center_of_mass[1]} ${center_of_mass[2]} \
	    $box_size "${split_sd_files_dir}/$ligand_to_dock" $ligand_output "${filename}.log" "${split_sd_files_dir}/$ligand"
	fi

done

rm -r $split_sd_files_dir $protein $protein_to_dock

fi

######################################################################################################

#####################################################Report results##################################
mkdir "${results}/analysis"

cd ${results}

python ../Utilities/top.py > analysis/vina_order.txt


bash ../Utilities/split_pdb.bash

cd ..

#####################################################################################################

fi

