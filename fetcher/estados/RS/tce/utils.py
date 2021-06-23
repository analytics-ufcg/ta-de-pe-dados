import requests, zipfile, sys
from colorama import Fore, Style
from tqdm import tqdm
import pathlib
import os

def print_usage(file):
    '''
    Função que printa a chamada correta em caso de o usuário passar o número errado
    de argumentos
    '''

    print(Fore.WHITE +'Chamada Correta: ' + Fore.YELLOW + 'python3.6 ' + file + ' <ano>')

def download_zip(url, file_name):
    '''
    Função que baixa o arquivo compactado das licitações
    '''
    try:
        chunkSize = 1024
        r = requests.get(url, stream=True)
        if r.status_code == 404:
            print(Fore.RED + 'Ano inválido!')
            print_usage()
            sys.exit(1)
        with open(file_name, 'wb') as f:
            pbar = tqdm( unit="B", total=int( r.headers['Content-Length'] ) )
            for chunk in r.iter_content(chunk_size=chunkSize): 
                if chunk:
                    pbar.update (len(chunk))
                    f.write(chunk)
    except requests.exceptions.RequestException as e:
        print(e)
        sys.exit(1)


def unzip_file(file, output_path):
    '''
    Função que descompacta arquivo
    '''
    try:
        z = zipfile.ZipFile(file)
        z.extractall(output_path)
    except Exception:
        print_usage()

def create_dirs(directory):
    try:
        if not os.path.exists(directory):
            os.makedirs(directory)
    except OSError:
        print ('Erro ao criar o diretório: ' +  directory)