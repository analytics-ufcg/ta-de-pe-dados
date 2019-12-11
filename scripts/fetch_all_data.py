import sys, os
import utils

PYTHON_VERSION = 'python3.6'
        
def call_fetch(year, call, path):
    '''
    Requesita arquivo de acao de acordo com o(s) ano(s) solicitado(s).
    '''
    for y in year:
        os.system(PYTHON_VERSION + ' ' + call + ' ' + y + ' ' + path)

def call_all_fetch(year, path):
    '''
    Requisita todos os arquivos de baixar dados.
    '''
    os.system(PYTHON_VERSION + ' fetch_contratos.py ' + year + ' ' + path)
    os.system(PYTHON_VERSION + ' fetch_empenhos.py ' + year + ' ' + path)
    os.system(PYTHON_VERSION + ' fetch_licitacoes.py ' + year + ' ' + path)

if __name__ == "__main__":

    if len(sys.argv) != 3:
        utils.print_usage()
        exit(1)

    print('Escolha uma opcao: ')
    print('1 - Baixar contratos')
    print('2 - Baixar licitacoes')
    print('3 - Baixar empenhos')
    print('4 - Baixar tudo')

    action = input('Digite sua opcao: ')

    inp_year = str(sys.argv[1])
    path = str(sys.argv[2])

    if action == '4':
        call_all_fetch(inp_year, path)
            
    elif action == '1':
        call_fetch(inp_year, 'fetch_contratos.py', path)

    elif action == '2':
        call_fetch(inp_year, 'fetch_licitacoes.py', path)
    
    elif action == '3':
        call_fetch(inp_year, 'fetch_empenhos.py', path)
    
    else:
        print('Opcao incorreta.')


    