import json
import pandas as pd
import numpy as np
from sklearn import utils
import os



def trj2jsons(n_start, n_end):
    task = f"s{n_start}_e{n_end}"
    if os.path.exists(f'data_json/{task}'):
        print("json frames exist!")
    else:
        Lattice_all = np.load("src_files/npy_data/Lattice_all.npy")
        Positions_all = np.load("src_files/npy_data/Positions_all.npy")
        Energy_all = np.load("src_files/npy_data/Energy_all.npy")
        Forces_all = np.load("src_files/npy_data/Forces_all.npy")
        AtomTypes = np.load("src_files/npy_data/AtomTypes.npy").tolist()
        frames2jsons(task, 
                     Lattice_all[n_start:n_end], Positions_all[n_start:n_end], 
                     Energy_all[n_start:n_end], Forces_all[n_start:n_end], 
                     AtomTypes)

def frame2json(Lattice, Positions, Energy, Forces, AtomTypes):
    n_atoms = len(AtomTypes)
    js = {}
    Data_dict = {}
    Data_dict["Positions"] = Positions.tolist()
    Data_dict["Energy"] = Energy.tolist()
    Data_dict["AtomTypes"] = AtomTypes
    Data_dict["Lattice"] = Lattice.tolist()
    Data_dict["NumAtoms"] = n_atoms
    Data_dict["Forces"] = Forces.tolist()
    Dataset = {}
    Dataset["Data"] = [Data_dict]
    Dataset["PositionsStyle"] = 'angstrom'
    Dataset["AtomTypeStyle"] = 'chemicalsymbol'
    Dataset["Label"] = f'Example containing 1 configurations, each with {n_atoms} atoms'
    Dataset["LatticeStyle"] = 'angstrom'
    Dataset["EnergyStyle"] = 'electronvolt'
    Dataset["ForcesStyle"] = 'electronvoltperangstrom'
    js["Dataset"] = Dataset
    return js

def frames2jsons(task, Lattice_all, Positions_all, Energy_all, Forces_all, AtomTypes):
    folder = f'data_json/{task}'
    os.makedirs(folder, exist_ok=True)
    jsons = []
    for index in range(len(Lattice_all)):
        name = f"MOF_1CO2_{index}"
        js = frame2json(Lattice_all[index], Positions_all[index], Energy_all[index], Forces_all[index], AtomTypes)
        with open(f"{folder}/{name}.json", "w") as f:
            json.dump(js, f)
            