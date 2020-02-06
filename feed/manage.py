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
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create_orgao.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create_licitacao.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create_empenho_raw.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create_empenho.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create_item.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create_contrato.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create_alteracoes_contrato.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create_item_contrato.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create_licitante.sql'])

@click.command()
def update_data():
    """Atualiza as tabelas do Banco de Dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/update/update_licitante.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/update/update_licitacao.sql'])

@click.command()
def import_data():
    """Importa dados para as tabelas do Banco de dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/import_data.sql'])

@click.command()
def import_empenho():
    """Importa dados de empenhos para as tabelas do Banco de dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/import_empenho.sql'])

@click.command()
def clean_empenho():
    """Dropa a tabela de empenhos do Banco de Dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/drop_empenho.sql'])

@click.command()
def clean_data():
    """Dropa as tabelas do Banco de Dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/drop_tables.sql'])


@click.command()
def shell():
    """Acessa terminal do banco de dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db])


cli.add_command(create)
cli.add_command(update_data)
cli.add_command(import_data)
cli.add_command(import_empenho)
cli.add_command(clean_empenho)
cli.add_command(clean_data)
cli.add_command(shell)

if __name__ == '__main__':
    cli()
