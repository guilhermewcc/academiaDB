"""Conexão PostgreSQL via ODBC; não recria nem modifica o esquema automaticamente."""
import os
import pyodbc

def get_connection():
    driver = os.getenv("ACADEMIA_DB_DRIVER", "PostgreSQL Unicode")
    host = os.getenv("ACADEMIA_DB_HOST", "localhost")
    port = os.getenv("ACADEMIA_DB_PORT", "5432")
    database = os.getenv("ACADEMIA_DB_NAME", "academia")
    user = os.getenv("ACADEMIA_DB_USER", "postgres")
    password = os.getenv("ACADEMIA_DB_PASSWORD", "")
    connection_string = (
        f"DRIVER={{{driver}}};SERVER={host};PORT={port};"
        f"DATABASE={database};UID={user};PWD={password};"
    )
    try:
        return pyodbc.connect(connection_string, autocommit=False, timeout=5)
    except pyodbc.Error as exc:
        raise RuntimeError(
            "Falha na conexão PostgreSQL. Verifique o serviço, o banco, "
            "as variáveis ACADEMIA_DB_* e o driver ODBC. "
            f"Detalhes: {exc}"
        ) from exc

def testar_conexao():
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT current_database(), current_user")
        return cursor.fetchone()
    finally:
        conn.close()
