import sys, os
import utils

PYTHON_VERSION = 'python3.6'
        
def call_fetch(year, call):
    '''
    Requesita arquivo de acao de acordo com o(s) ano(s) solicitado(s).
    '''
    os.system(PYTHON_VERSION + ' ' + call + ' ' + year)

def call_all_fetch(year):
    '''
    Requisita todos os arquivos de baixar dados.
    '''
    os.system(PYTHON_VERSION + ' fetch_contratos.py ' + year)
    os.system(PYTHON_VERSION + ' fetch_empenhos.py ' + year)
    os.system(PYTHON_VERSION + ' fetch_licitacoes.py ' + year)

if __name__ == "__main__":

    if len(sys.argv) < 2:
        print('Chamada Correta: python3.6 fetch_all_data.py <ano>')
        exit(1)

    if len(sys.argv) == 3:
        action = str(sys.argv[2])
    else:
        print('Escolha uma opcao: ')
        print('1 - Baixar contratos')
        print('2 - Baixar licitacoes')
        print('3 - Baixar empenhos')
        print('4 - Baixar tudo')

        action = input('Digite sua opcao: ')

    inp_year = str(sys.argv[1])

    if action == '4':
        print("Baixando todos os dados!")
        call_all_fetch(inp_year)
            
    elif action == '1':
        call_fetch(inp_year, 'fetch_contratos.py')

    elif action == '2':
        call_fetch(inp_year, 'fetch_licitacoes.py')
    
    elif action == '3':
        call_fetch(inp_year, 'fetch_empenhos.py')
    
    else:
        print('Opcao incorreta.')


    