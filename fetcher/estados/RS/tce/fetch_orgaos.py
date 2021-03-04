import os, sys
import utils
import subprocess
from shutil import copyfile

if __name__ == "__main__":
    # Argumentos que o programa deve receber:
    # -1º: Caminho da pasta de destino

    if len(sys.argv) != 2:
        utils.print_usage()
        exit(1)

    output_path = str(sys.argv[1])
    url = 'http://dados.tce.rs.gov.br/dados/auxiliar/orgaos_auditados_rs.csv'
    path = output_path + '/orgaos/'
    if not os.path.isdir(path):
        os.mkdir(path)
    file_name = 'orgaos.csv'
    utils.download_zip(url, file_name)
    copyfile(file_name, path + file_name)
    subprocess.call(['chmod', '-R', '0777', output_path + '/orgaos/'])
    os.remove(file_name)
    