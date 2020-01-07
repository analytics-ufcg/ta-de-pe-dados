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
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create_licitacao.sql'])
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/create_empenho.sql'])


@click.command()
def import_data():
    """Importa dados para as tabelas do Banco de dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/import_data.sql'])


@click.command()
def clean_data():
    """Dropa as tabelas do Banco de Dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db, '-f', '/feed/scripts/drop_tables.sql'])


@click.command()
def shell():
    """Acessa terminal do banco de dados"""
    subprocess.run(['psql', '-h', host, '-U', user, '-d', db])


cli.add_command(create)
cli.add_command(import_data)
cli.add_command(clean_data)
cli.add_command(shell)

if __name__ == '__main__':
    cli()
