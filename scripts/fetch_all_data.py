import sys, os
import utils

PYTHON_VERSION = 'python3.6'

def call_action_year(action, year, path):
    '''
    Seleciona qual acao será retornada.
    '''
    if action.lower() == 'contrato':
        call_fetch(year, 'scripts/fetch_contratos.py', path)
        
    elif action.lower() == 'licitacao':
        call_fetch(year, 'scripts/fetch_licitacoes.py', path)
        
    elif action.lower() == 'empenho':
        call_fetch(year, 'scripts/fetch_empenhos.py', path)
        
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
    for y in year:
        os.system(PYTHON_VERSION + ' scripts/fetch_contratos.py '+ y + ' ' + path)
        os.system(PYTHON_VERSION + ' scripts/fetch_empenhos.py '+ y + ' ' + path)
        os.system(PYTHON_VERSION + ' scripts/fetch_licitacoes.py '+ y + ' ' + path)

if __name__ == "__main__":

    if len(sys.argv) != 4:
        utils.print_usage()
        exit(1)

    in_action = str(sys.argv[1])
    in_year = str(sys.argv[2])
    path = str(sys.argv[3])

    in_year = in_year.split(',')

    if in_action.lower() == 'all':
        call_all_fetch(in_year, path)
            
    else:
        in_action = in_action.split(',')
        for a in in_action:
            call_action_year(a, in_year, path)
    