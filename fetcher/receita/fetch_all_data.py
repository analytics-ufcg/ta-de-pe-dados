import sys, os
import utils

PYTHON_VERSION = 'python3.6'
        
def call_fetch(call):
    '''
    Requesita arquivo de acao de acordo com o(s) ano(s) solicitado(s).
    '''
    os.system(PYTHON_VERSION + ' ' + call)

def call_all_fetch():
    '''
    Requisita todos os arquivos de baixar dados.
    '''
    os.system(PYTHON_VERSION + ' fetch_licitacoes.py ')
    os.system(PYTHON_VERSION + ' fetch_empenhos.py ')
    os.system(PYTHON_VERSION + ' fetch_itens_empenhos.py ')


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print('Chamada Correta: python3.6 fetch_all_data.py <ano>')
        exit(1)

    if len(sys.argv) == 2:
        action = str(sys.argv[1])

    else:
        print('Escolha uma opcao: ')
        print('1 - Baixar empenhos')
        print('2 - Baixar itens de empenhos')
        print('3 - Baixar licitacoes')
        print('4 - Baixar tudo')

        action = input('Digite sua opcao: ')

    if action == '4':
        print("Baixando todos os dados!")
        call_all_fetch()
            
    elif action == '1':
        call_fetch('fetch_empenhos.py')

    elif action == '2':
        call_fetch('fetch_itens_empenhos.py')

    elif action == '3':
        call_fetch('fetch_licitacoes.py')
    
    else:
        print('Opcao incorreta.')


    