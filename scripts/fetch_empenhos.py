import requests, zipfile, io, sys

def print_usage():
    '''
    Função que printa a chamada correta em caso de o usuário passar o número errado
    de argumentos
    '''

    print ('Chamada errada ou ano inválido! \nChamada Correta: python3.6 fetch_empenhos.py <year>')

def download_zip(url):
    '''
    Função que baixa o arquivo compactado dos empenhos
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
    # -1º: Ano que desejar baixar dos empenhos

    if len(sys.argv) != 2:
        print_usage()
        exit(1)

    year = str(sys.argv[1])
    url = 'http://dados.tce.rs.gov.br/dados/municipal/empenhos/' + year + '.csv.zip'
    path = '../data/empenhos/' + year

    r = download_zip(url)
    unzip_file(r, path)