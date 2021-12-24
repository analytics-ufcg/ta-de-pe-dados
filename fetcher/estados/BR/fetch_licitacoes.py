import requests
import zipfile
import os
cwd = os.getcwd()
print(cwd)
def download_file_from_google_drive(id, destination):
    URL = "https://docs.google.com/uc?export=download"

    session = requests.Session()

    response = session.get(URL, params = { 'id' : id }, stream = True)
    token = get_confirm_token(response)

    if token:
        params = { 'id' : id, 'confirm' : token }
        response = session.get(URL, params = params, stream = True)

    save_response_content(response, destination)    

def get_confirm_token(response):
    for key, value in response.cookies.items():
        if key.startswith('download_warning'):
            return value

    return None

def save_response_content(response, destination):
    CHUNK_SIZE = 32768

    with open(destination, "wb") as f:
        for chunk in response.iter_content(CHUNK_SIZE):
            if chunk: 
                f.write(chunk)


file_id = '1qsgQhbtmKaZAt9igk9hghhCIER4dMlcr'
destination = '/code/scripts/data/dados_federais/licitacoes.zip'
download_file_from_google_drive(file_id, destination)

Zip_ref = zipfile.ZipFile('/code/scripts/data/dados_federais/licitacoes.zip', 'r')
Zip_ref.extractall('/code/scripts/data/dados_federais')
Zip_ref.close()

os.remove('/code/scripts/data/dados_federais/licitacoes.zip')