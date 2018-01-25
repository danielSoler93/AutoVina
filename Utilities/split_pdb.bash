#!/bin/bash
for f in *_out.pdbqt; do
	echo "$f"
	/opt/autodock_vina_1_1_2_linux_x86/bin/vina_split --input $f;
	name=$(basename "${f}_ligand_1.pdbqt")
	filename1="${name%.*}"
	filename2="${filename1%.*}"
	filename3="${filename2%.*}"
	cut -c-66 ${filename2}_ligand_1.pdbqt > "analysis/${filename3}_1.pdb"
	cut -c-66 ${filename2}_ligand_2.pdbqt > "analysis/${filename3}_2.pdb"
	cut -c-66 ${filename2}_ligand_3.pdbqt > "analysis/${filename3}_3.pdb"
	done
rm *_out_ligand*