import sys
import glob

def doit():
    file_names = glob.glob('*_out.pdbqt')
    results = []
    everything = []
    failures = []
    print 'Found', len(file_names), 'pdbqt files'
    for file_name in file_names:
        # print(file_name)
        file = open(file_name)
        lines = file.readlines()
        file.close()
        try:
            line = lines[1]
            result = float(line.split(':')[1].split()[0])
            everything.append([result, file_name])
        except:
            failures.append(file_name)
    everything.sort(lambda x,y: cmp(x[0], y[0]))
    for ligand in everything:
        print(ligand[0], ligand[1])
    if len(failures) > 0:
        print 'WARNING:', len(failures), 'pdbqt files could not be processed'

if __name__ == '__main__':
    doit()
