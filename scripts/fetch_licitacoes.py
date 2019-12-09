import requests, zipfile, io, sys
from colorama import Fore, Style


def print_usage():
    '''
    Função que printa a chamada correta em caso de o usuário passar o número errado
    de argumentos
    '''

    print ('Chamada errada ou ano inválido! \nChamada Correta: ' + Fore.YELLOW +'python3.6 fetch_licitacoes.py <ano>')

def download_zip(url):
    '''
    Função que baixa o arquivo compactado das licitações
    '''
    try:
        return requests.get(url)
    except requests.exceptions.RequestException as e:
        print(e)
        sys.exit(1)

def unzip_file(file, output_path):
    '''
    Função que descompacta arquivo
    '''
    try:
        z = zipfile.ZipFile(io.BytesIO(file.content))
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

    r = download_zip(url)
    unzip_file(r, path)
    
