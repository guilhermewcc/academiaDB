import os
import pyodbc

# -------------------------------------------------------------------
# CONFIGURAÇÃO DA CONEXÃO ODBC
# -------------------------------------------------------------------
# Altere as credenciais abaixo de acordo com seu ambiente
HOST = "localhost"
PORT = 5432
DATABASE = "academia"
USER = "postgres"
PASSWORD = "123"
# Driver ODBC instalado no sistema (ex: 'PostgreSQL Unicode' ou 'PostgreSQL ANSI')
DRIVER = "PostgreSQL Unicode"

CONN_STR = (
    f"DRIVER={{{DRIVER}}};"
    f"SERVER={HOST};"
    f"PORT={PORT};"
    f"DATABASE={DATABASE};"
    f"UID={USER};"
    f"PWD={PASSWORD};"
)


def obter_conexao():
    """Abre e retorna a conexão ODBC com o PostgreSQL."""
    try:
        conn = pyodbc.connect(CONN_STR, autocommit=False)
        return conn
    except pyodbc.Error as e:
        print(f"\n[ERRO DE CONEXÃO] Não foi possível conectar via ODBC: {e}")
        return None


# -------------------------------------------------------------------
# EXECUTAR O ARQUIVO dbSQL.txt
# -------------------------------------------------------------------
def inicializar_banco():
    """Lê o arquivo dbSQL.txt e executa os comandos DDL/DML no banco."""
    caminho_sql = "dbSQL.txt"

    if not os.path.exists(caminho_sql):
        print(f"[AVISO] Arquivo '{caminho_sql}' não encontrado. Pulando inicialização de tabelas.")
        return

    conn = obter_conexao()
    if not conn:
        return

    try:
        with open(caminho_sql, "r", encoding="utf-8") as f:
            sql_script = f.read()

        cursor = conn.cursor()
        # Executa todo o script SQL lido do arquivo
        cursor.execute(sql_script)
        conn.commit()
        cursor.close()
        print("[SUCESSO] Tabelas e scripts de 'dbSQL.txt' executados com sucesso!")
    except Exception as e:
        conn.rollback()
        print(f"[ERRO] Erro ao executar 'dbSQL.txt': {e}")
    finally:
        conn.close()


# -------------------------------------------------------------------
# FUNÇÕES DE GERENCIAMENTO (CRUD VIA ODBC)
# -------------------------------------------------------------------
def cadastrar_aluno():
    print("\n--- CADASTRO DE ALUNO ---")
    nome = input("Nome: ")
    cpf = input("CPF: ")
    email = input("E-mail: ")

    conn = obter_conexao()
    if conn:
        try:
            cursor = conn.cursor()
            # No pyodbc/ODBC, usamos '?' como marcador de parâmetro
            sql = "INSERT INTO alunos (nome, cpf, email) VALUES (?, ?, ?)"
            cursor.execute(sql, (nome, cpf, email))
            conn.commit()
            print("✓ Aluno cadastrado com sucesso!")
            cursor.close()
        except pyodbc.Error as e:
            conn.rollback()
            print(f"Erro ao inserir aluno: {e}")
        finally:
            conn.close()


def listar_alunos():
    print("\n--- LISTA DE ALUNOS ---")
    conn = obter_conexao()
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM alunos")
            linhas = cursor.fetchall()

            if not linhas:
                print("Nenhum aluno encontrado.")
            else:
                for row in linhas:
                    # Exibe as colunas retornadas
                    print(row)
            cursor.close()
        except pyodbc.Error as e:
            print(f"Erro ao consultar alunos: {e}")
        finally:
            conn.close()


def cadastrar_plano():
    print("\n--- CADASTRO DE PLANO ---")
    nome = input("Nome do Plano: ")
    valor = float(input("Valor (R$): "))
    duracao = int(input("Duração (meses): "))

    conn = obter_conexao()
    if conn:
        try:
            cursor = conn.cursor()
            sql = "INSERT INTO planos (nome, valor, duracao_meses) VALUES (?, ?, ?)"
            cursor.execute(sql, (nome, valor, duracao))
            conn.commit()
            print("✓ Plano cadastrado com sucesso!")
            cursor.close()
        except pyodbc.Error as e:
            conn.rollback()
            print(f"Erro ao cadastrar plano: {e}")
        finally:
            conn.close()


def listar_planos():
    print("\n--- LISTA DE PLANOS ---")
    conn = obter_conexao()
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM planos")
            linhas = cursor.fetchall()

            if not linhas:
                print("Nenhum plano encontrado.")
            else:
                for row in linhas:
                    print(row)
            cursor.close()
        except pyodbc.Error as e:
            print(f"Erro ao consultar planos: {e}")
        finally:
            conn.close()


# -------------------------------------------------------------------
# MENU PRINCIPAL DO SISTEMA
# -------------------------------------------------------------------
def main():
    # 1. Carrega a estrutura inicial do arquivo dbSQL.txt
    inicializar_banco()

    # 2. Menu interativo
    while True:
        print("\n" + "=" * 35)
        print("    GERENCIAMENTO ACADEMIA DB (ODBC)")
        print("=" * 35)
        print("1. Cadastrar Aluno")
        print("2. Listar Alunos")
        print("3. Cadastrar Plano")
        print("4. Listar Planos")
        print("0. Sair")
        
        opcao = input("Escolha uma opção: ")

        if opcao == "1":
            cadastrar_aluno()
        elif opcao == "2":
            listar_alunos()
        elif opcao == "3":
            cadastrar_plano()
        elif opcao == "4":
            listar_planos()
        elif opcao == "0":
            print("\nEncerrando o programa...")
            break
        else:
            print("\nOpção inválida! Tente novamente.")


if __name__ == "__main__":
    main()