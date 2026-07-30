import snowflake.connector
from sqlalchemy import create_engine
import os
import pandas as pd
from dotenv import load_dotenv
import time
# https://www.youtube.com/watch?v=oRlqaEokbeY
class chargement_donnees :
    def __init__(self) : 
        self.user = "ALEX"
        self.password = "Attineos1234!!"
        self.account = "OYVMAZH-RRB57272"
        self.warehouse = "dwh_deliv_center"
        self.database = "DB_DELIVERY_CENTER"
        self.schema = "SCH_DELIVERY_CENTER"
        self.role = "ACCOUNTADMIN"

        self.engine = None

        self.file_src = "operations/treated_data/"
        self.file_list = []
        self.df = None

    def connect(self):
        try :
            url = (f"snowflake://{self.user}:{self.password}@{self.account}/{self.database}/{self.schema}?warehouse={self.warehouse}&role={self.role}")
            self.engine = create_engine(url)
            print(f"Connexion établie à la BD {self.database}")
        except Exception as e: 
            print(f"Connexion a la BD a ecoué {e}")

    def load_files(self):
        self.file_list = os.listdir(self.file_src)
        print("fichiers chargées...")

    def load_data (self):
        if self.engine is None or self.file_list == []:
            print("erreur au chargement")

        for ff in self.file_list:
            
            print(f"{ff[:-4]} en cours de traitement")
            self.df = pd.read_csv(self.file_src+ff)
            self.df.to_sql(
                 name=ff[:-4].lower(), 
                 con = self.engine, 
                 schema=self.schema, 
                 if_exists='append', 
                 index=False,
                 chunksize=10000,
                 method='multi')
            print(f"Chargement terminé pour {ff}")
            self.df = None
            time.sleep(3)

        
    