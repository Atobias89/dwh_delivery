import sys
import tr_donnees_brut as tr_data
import chargement_donnees as cd


def main () -> int : 
    data_cleanance = tr_data.tr_donnees_brut()
    data_cleanance.load_file()
    data_cleanance.erease_duplicates()
    data_cleanance.erease_na_data()

    chargement = cd.chargement_donnees()
    chargement.connect()
    chargement.load_files()
    chargement.load_data()
    return 0

if __name__ == '__main__':
    sys.exit(main())
