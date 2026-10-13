import os
import pyodbc

# Configurações de conexão ODBC
HOST = "localhost"
PORT = 5432
DATABASE = "academia"
USER = "postgres"
PASSWORD = "chtnd"
DRIVER = "PostgreSQL Unicode"  # Nome do Driver ODBC instalado no SO

CONN_STR = (
    f"DRIVER={{{DRIVER}}};"
    f"SERVER={HOST};"
    f"PORT={PORT};"
    f"DATABASE={DATABASE};"
    f"UID={USER};"
    f"PWD={PASSWORD};"
)

def get_connection():
    """Abre e retorna a conexão via pyodbc."""
    try:
        return pyodbc.connect(CONN_STR, autocommit=False)
    except pyodbc.Error as e:
        print(f"\n[ERRO DE CONEXÃO ODBC] {e}")
        return None

def inicializar_banco_de_dados(sql_filepath="schema.sql"):
    """Lê um arquivo .sql e executa os comandos no banco via ODBC."""
    if not os.path.exists(sql_filepath):
        print(f"[AVISO] Arquivo SQL '{sql_filepath}' não foi encontrado.")
        return

    conn = get_connection()
    if not conn:
        return

    try:
        with open(sql_filepath, "r", encoding="utf-8") as file:
            sql_script = file.read()

        cursor = conn.cursor()
        cursor.execute(sql_script)
        conn.commit()
        cursor.close()
        print(f"✓ Banco inicializado com sucesso a partir de '{sql_filepath}'!")
    except pyodbc.Error as e:
        conn.rollback()
        print(f"[ERRO SQL] Falha ao executar o script SQL: {e}")
    finally:
        conn.close()