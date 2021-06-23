import os, sys
import utils
import subprocess
from shutil import copyfile

if __name__ == "__main__":
    output_path = './data/tce_rs'
    path = output_path + '/orgaos/'
    utils.create_dirs(path)

    file_name = 'orgaos.csv'
    url = 'http://dados.tce.rs.gov.br/dados/auxiliar/orgaos_auditados_rs.csv'
    utils.download_zip(url, file_name)
    copyfile(file_name, path + file_name)
    subprocess.call(['chmod', '-R', '0777', output_path + '/orgaos/'])
    os.remove(file_name)
    