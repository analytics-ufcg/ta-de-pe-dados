import os, sys
import utils

if __name__ == "__main__":
    # Argumentos que o programa deve receber:
    # -1º: Ano que desejar baixar dos empenhos

    if len(sys.argv) != 2:
        utils.print_usage()
        exit(1)

    year = str(sys.argv[1])
    url = 'http://dados.tce.rs.gov.br/dados/municipal/empenhos/' + year + '.csv.zip'
    path = '../data/empenhos/' + year
    file_name = year + '.csv.zip'
    utils.download_zip(url, file_name)
    utils.unzip_file(file_name, path)
    os.remove(file_name)
    