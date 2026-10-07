import pyodbc
from database import get_connection

def cadastrar_aluno(nome: str, cpf: str, email: str):
    conn = get_connection()
    if not conn:
        return
    try:
        cursor = conn.cursor()
        # No pyodbc (ODBC padrão), usa-se '?' como marcador de parâmetro
        sql = "INSERT INTO alunos (nome, cpf, email) VALUES (?, ?, ?)"
        cursor.execute(sql, (nome, cpf, email))
        conn.commit()
        print("✓ Aluno cadastrado com sucesso!")
    except pyodbc.Error as e:
        conn.rollback()
        print(f"[ERRO] Falha ao cadastrar aluno: {e}")
    finally:
        conn.close()

def listar_alunos():
    conn = get_connection()
    if not conn:
        return []
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT id, nome, cpf, email FROM alunos")
        rows = cursor.fetchall()
        return rows
    except pyodbc.Error as e:
        print(f"[ERRO] Falha ao listar alunos: {e}")
        return []
    finally:
        conn.close()

def cadastrar_plano(nome: str, valor: float, duracao_meses: int):
    conn = get_connection()
    if not conn:
        return
    try:
        cursor = conn.cursor()
        sql = "INSERT INTO planos (nome, valor, duracao_meses) VALUES (?, ?, ?)"
        cursor.execute(sql, (nome, valor, duracao_meses))
        conn.commit()
        print("✓ Plano cadastrado com sucesso!")
    except pyodbc.Error as e:
        conn.rollback()
        print(f"[ERRO] Falha ao cadastrar plano: {e}")
    finally:
        conn.close()

def listar_planos():
    conn = get_connection()
    if not conn:
        return []
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT id, nome, valor, duracao_meses FROM planos")
        rows = cursor.fetchall()
        return rows
    except pyodbc.Error as e:
        print(f"[ERRO] Falha ao listar planos: {e}")
        return []
    finally:
        conn.close()