import argparse
import sys
import os


def extract_ligand(pdb_filename, general_name, ligand_chain, ligand_res, executing_folder):
    """
    This function creates 4 different files in .pdb format
    :param pdb_filename: nom del pdb
    :param general_name: el nom davant de l'extensio .pdb, split del nom per '.pdb'
    :param ligand_chain: cadena del lligand
    :return:
    :param executing_folder:
    """
    # receptor_with_waters_text = ""

    receptor_text = ""
    waters_text = ""
    ligand_text = ""

    ligand_filename = general_name + "_ligand.pdb"
    with open(pdb_filename, 'r') as pdb_file:
        for line in pdb_file:
            if line.startswith("ATOM") or line.startswith("HETATM"):
                if line[17:20] == ligand_res and line[21] == ligand_chain:
                    ligand_text += line
                else:
                    if line[17:20] == "HOH":
                        receptor_text += line
                    else:
                        receptor_text += line
    if ligand_text == "":
        print("Something went wrong when extracting the ligand.")
        return False
    elif receptor_text == "":
        print("Something went wrong when extracting the receptor.")
        return False
    # else:
    #     logging.info(" - Ligand and receptor extracted correctly.")

    with open(ligand_filename, 'w') as ligand_file:
        ligand_file.write(ligand_text)
    if receptor_text:
        receptor_no_waters_filename = general_name + "_protein.pdb"
        with open(receptor_no_waters_filename, 'w') as receptor_file:
            receptor_file.write(receptor_text)
        receptor_with_waters_filename = ""
        waters_filename = ""
    return ligand_filename


parser = argparse.ArgumentParser()
parser.add_argument("--pdb", type=str, required=True)
parser.add_argument("--general_name", type=str, required=True)
parser.add_argument("--ligand_chain", type=str, required=True)
parser.add_argument("--ligand_res", type=str, required=True)
parser.add_argument("--executing_folder", type=str, required=True)
args = parser.parse_args()

extract_ligand(args.pdb, args.general_name, args.ligand_chain, args.ligand_res, args.executing_folder)
