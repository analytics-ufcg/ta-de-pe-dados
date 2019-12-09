import requests, zipfile, io, sys, os
from colorama import Fore, Style
from tqdm import tqdm

def print_usage():
    '''
    Função que printa a chamada correta em caso de o usuário passar o número errado
    de argumentos
    '''

    print ('Chamada errada ou ano inválido! \nChamada Correta: python3.6 fetch_contratos.py <year>')


def download_zip(url, file_name):
    '''
    Função que baixa o arquivo compactado dos contratos
    '''
    try:
        chunkSize = 1024
        r = requests.get(url, stream=True)

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


if __name__ == "__main__":
    # Argumentos que o programa deve receber:
    # -1º: Ano que desejar baixar dos contratos

    if len(sys.argv) != 2:
        print_usage()
        exit(1)

    year = str(sys.argv[1])
    url = 'http://dados.tce.rs.gov.br/dados/licitacon/contrato/ano/' + year + '.csv.zip'
    path = '../data/licitacoes/' + year
    file_name = year + '.csv.zip'
    download_zip(url, file_name)
    unzip_file(file_name, path)
    os.remove(file_name)
    