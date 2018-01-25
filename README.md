# AutoVina
Automatic Vina Launcher

## Getting started
1) Change the path of MGLTOOLS & SPYTHON in env_var.sh
2) Have a .pdb with the receptor with a ligand inside the binding site.
2) If you want place and .sd file with all the ligands you want to crossdock in the folder crossligands/.
3) run $bash pdb file cpus exhaustivity -c ligand's pdb chain -r ligand's pdb residue name

e.g bash 2sp5.pdb 10 8 -c Z -r LIG

