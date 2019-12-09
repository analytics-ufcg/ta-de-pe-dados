import requests, zipfile, io, sys, os
from colorama import Fore, Style
from tqdm import tqdm
import urllib.request

def print_usage():
    '''
    Função que printa a chamada correta em caso de o usuário passar o número errado
    de argumentos
    '''

    print ('Chamada errada ou ano inválido! \nChamada Correta: ' + Fore.YELLOW +'python3.6 fetch_licitacoes.py <ano>')

def download_zip(url, file_name):
    '''
    Função que baixa o arquivo compactado das licitações
    '''
    chunkSize = 1024
    r = requests.get(url, stream=True)

    with open(file_name, 'wb') as f:
        pbar = tqdm( unit="B", total=int( r.headers['Content-Length'] ) )
        for chunk in r.iter_content(chunk_size=chunkSize): 
            if chunk:
                pbar.update (len(chunk))
                f.write(chunk)

def unzip_file(file, output_path):
    '''
    Função que descompacta arquivo
    '''
    try:
        z = zipfile.ZipFile(file)
        z.extractall(output_path)
    except Exception:
        print_usage()


if __name__ == "__main__":
    # Argumentos que o programa deve receber:
    # -1º: Ano que desejar baixar as licitações

    if len(sys.argv) != 2:
        print_usage()
        exit(1)

    ano = str(sys.argv[1])
    url = 'http://dados.tce.rs.gov.br/dados/licitacon/licitacao/ano/' + ano + '.csv.zip'
    path = '../data/licitacoes/' + ano
    file_name = ano + '.csv.zip'
    download_zip(url, file_name)
    unzip_file(file_name, path)
    os.remove(file_name)
    
