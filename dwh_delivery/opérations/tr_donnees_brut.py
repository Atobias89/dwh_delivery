import pandas as pd 
import os

class tr_donnees_brut:
    def __init__(self):
        self.path = "/raw_data"
        self.dest_path = "/treated_data"
        self.files_list = []
        self.df = None

    def load_file(self):
        self.files_list = os.listdir(self.path)

    def erease_duplicates(self):
        if not self.files_list:
            print("list de fichier vide")
        fnum = 0
        for f in self.files_list:
            self.df = pd.read_csv(self.path+"/"+f)
            self.df.drop_duplicates(subset = None, keep = 'first', inplace = True)
            self.df.to_csv(self.path)
            fnum += 1
            self.df = None
        print(f"{fnum} treateds")

    def erease_na_data(self):
        if not self.files_list:
            print("liste de fichier vide")
        fnum = 0 
        for f in self.files_list:
            self.df = pd.read_csv(self.path+"/"+f)
            dfclean = self.df.dropna()
            dfclean.to_csv(self.path)
            fnum += 1
            self.df = None