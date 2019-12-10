import sys, os

PYTHON_VERSION = 'python3.6'

def call_action_year(action, year):
    '''
    Seleciona qual acao será retornada.
    '''
    if action.lower() == 'contrato':
        call_fetch(year, 'fetch_contratos.py')
        
    elif action.lower() == 'licitacao':
        call_fetch(year, 'fetch_licitacoes.py')
        
    elif action.lower() == 'empenho':
        call_fetch(year, 'fetch_empenhos.py')
        
def call_fetch(year, call):
    '''
    Requesita arquivo de acao de acordo com o(s) ano(s) solicitado(s).
    '''
    for y in year:
        os.system(PYTHON_VERSION + call + ' ' + y)

def call_all_fetch(year):
    '''
    Requisita todos os arquivos de baixar dados.
    '''
    for y in year:
        os.system(PYTHON_VERSION + ' fetch_contratos.py '+ y)
        os.system(PYTHON_VERSION + ' fetch_empenhos.py '+ y)
        os.system(PYTHON_VERSION + ' fetch_licitacoes.py '+ y)

if __name__ == "__main__":
    in_action = str(sys.argv[1])
    in_year = str(sys.argv[2])
    in_year = in_year.split(',')

    if in_action.lower() == 'all':
        call_all_fetch(in_year)
            
    else:
        in_action = in_action.split(',')
        for a in in_action:
            call_action_year(a, in_year)
    