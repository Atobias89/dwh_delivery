import pandas as pd 
import os
import time

class tr_donnees_brut:
    def __init__(self):
        self.path = "raw_data/"
        self.dest_path = "treated_data/"
        self.files_list = []
        self.df = None

    def load_file(self):
        self.files_list = os.listdir(self.path)
        print("fichiers chargées...")

    def erease_duplicates(self):
        if not self.files_list:
            print("list de fichier vide")
        fnum = 0
        for f in self.files_list:
            
            self.df = pd.read_csv(self.path+f,  encoding = 'cp860')
            self.df.drop_duplicates(subset = None, keep = 'first', inplace = True)
            self.df.to_csv(path_or_buf = self.path+f, sep =',',mode='w')
            fnum += 1
            self.df = None
            print(self.dest_path+f)
            time.sleep(3)
        print(f"{fnum} fichier traités")

    def erease_na_data(self):
        if not self.files_list:
            print("liste de fichier vide")
        fnum = 0 
        for f in self.files_list:
            self.df = pd.read_csv(self.path+f,encoding = 'cp860')
            dfclean = self.df.dropna()
            dfclean.to_csv(self.dest_path+f)
            fnum += 1
            self.df = None
            print(self.dest_path+f)
            time.sleep(3)