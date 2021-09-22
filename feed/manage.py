import subprocess
import os
import click

host = os.environ['POSTGRES_HOST']
user = os.environ['POSTGRES_USER']
db = os.environ['POSTGRES_DB']
password = os.environ['POSTGRES_PASSWORD']
os.environ['PGPASSWORD'] = password

@click.group()
def cli():
    pass

@click.command()
def create():
    """Cria as tabelas do Banco de dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_municipio.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_orgao.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_licitacao.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_documento_licitacao.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_empenho_raw.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_item.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_fornecedor.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_cnae.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_natureza_juridica.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_dados_cadastrais.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_socios.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_cnae_secundario.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_contrato.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_empenho.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_alteracoes_contrato.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_item_contrato.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_licitante.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_tipo_novidade.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_novidade.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_itens_unicos_similaridade.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_tipo_alerta.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_alerta.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_item_atipico.sql'])

@click.command()
def create_empenho_raw():
    """Cria as tabelas de empenhos raw do Banco de dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_empenho_raw.sql'])

@click.command()
def create_empenho_raw_gov_federal():
    """Cria as tabelas de empenhos do Governo Federal raw do Banco de dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_empenhos_raw_federais.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create/create_itens_empenhos_raw_federais.sql'])

@click.command()
def update_data():
    """Atualiza as tabelas do Banco de Dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/update/update_orgao.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/update/update_licitacao.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/update/update_licitante.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/update/update_item.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/update/update_fornecedor.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/update/update_contrato.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/update/update_item_contrato.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/update/update_alteracoes_contrato.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/update/update_tipo_novidade.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/update/update_novidade.sql'])

@click.command()
def update_fornecedores():
    """Atualiza as tabelas do Banco de Dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/update/update_fornecedor.sql'])

@click.command()
def import_data():
    """Importa dados para as tabelas do Banco de dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/import/import_data.sql'])

@click.command()
def import_empenho_raw():
    """Importa dados (licitações e contratos) para as tabelas do Banco de dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/import/import_empenho_raw.sql'])

@click.command()
def import_empenho_raw_gov_federal():
    """Importa dados (licitações e contratos) para as tabelas do Banco de dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/import/import_empenhos_federais.sql'])

@click.command()
def import_empenho():
    """Importa dados de empenhos para as tabelas do Banco de dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/import/import_empenho.sql'])

@click.command()
def import_novidade():
    """Importa novidades para as tabelas do Banco de dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/import/import_novidade.sql'])

@click.command()
def import_alerta():
    """Importa alertas para as tabelas do Banco de dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/import/import_alerta.sql'])

@click.command()
def import_itens_similares_data():
    """Importa itens similares para as tabelas do Banco de dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/import/import_itens_unicos_similaridade.sql'])

@click.command()
def clean_empenho():
    """Dropa a tabela de empenhos do Banco de Dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/drop/drop_empenho.sql'])

@click.command()
def clean_empenho_federal():
    """Dropa a tabela de empenhos federais do Banco de Dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/drop/drop_empenho_federal.sql'])

@click.command()
def clean_data():
    """Dropa as tabelas do Banco de Dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/drop/drop_tables.sql'])

@click.command()
def shell():
    """Acessa terminal do banco de dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db])

@click.command()
def process_itens_similares():
    """Cria tabela com itens similares"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/function/function_processa_itens_similares.sql'])

cli.add_command(create)
cli.add_command(create_empenho_raw)
cli.add_command(create_empenho_raw_gov_federal)
cli.add_command(import_empenho_raw_gov_federal)
cli.add_command(update_data)
cli.add_command(update_fornecedores)
cli.add_command(import_data)
cli.add_command(import_empenho)
cli.add_command(import_novidade)
cli.add_command(clean_empenho)
cli.add_command(clean_empenho_federal)
cli.add_command(clean_data)
cli.add_command(shell)
cli.add_command(import_empenho_raw)
cli.add_command(import_alerta)
cli.add_command(import_itens_similares_data)
cli.add_command(process_itens_similares)

if __name__ == '__main__':
    cli()
