import os, sys
import utils
import subprocess

if __name__ == "__main__":
    # Argumentos que o programa deve receber:
    # -1º: Ano que desejar baixar as licitações
    year = str(sys.argv[1])
    output_path = './data/tce_rs'

    if len(sys.argv) != 3:
        utils.print_usage()
        exit(1)

    url = 'http://dados.tce.rs.gov.br/dados/licitacon/licitacao/ano/' + year + '.csv.zip'
    path = output_path + '/licitacoes/' + year
    file_name = year + '.csv.zip'
    utils.download_zip(url, file_name)
    utils.unzip_file(file_name, path)
    subprocess.call(['chmod', '-R', '0777', output_path + '/licitacoes/'])
    os.remove(file_name)
    