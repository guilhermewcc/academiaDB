"""Acesso a dados do AcademiaDB. Consultas parametrizadas e transações seguras."""
import pyodbc
from database import get_connection

def _executar(sql, parametros=(), fetch=False, one=False):
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute(sql, parametros)
        if fetch:
            return cur.fetchone() if one else cur.fetchall()
        conn.commit()
        return cur.rowcount
    except pyodbc.Error:
        conn.rollback()
        raise
    finally:
        conn.close()

def listar_alunos():
    return _executar("SELECT id, nome, cpf, data_nascimento, telefone, email FROM aluno ORDER BY nome", fetch=True)

def cadastrar_aluno(nome, cpf, nascimento=None, telefone=None, email=None):
    _executar("INSERT INTO aluno (nome, cpf, data_nascimento, telefone, email) VALUES (?, ?, ?, ?, ?)",
              (nome, cpf, nascimento, telefone or None, email or None))

def listar_planos():
    return _executar("SELECT id, nome, valor, duracao_dias FROM plano ORDER BY nome", fetch=True)

def cadastrar_plano(nome, valor, duracao_dias):
    _executar("INSERT INTO plano (nome, valor, duracao_dias) VALUES (?, ?, ?)",
              (nome, valor, duracao_dias))

def listar_professores():
    return _executar("SELECT id, nome, cpf, telefone, email FROM professor ORDER BY nome", fetch=True)

def cadastrar_professor(nome, cpf=None, telefone=None, email=None):
    _executar("INSERT INTO professor (nome, cpf, telefone, email) VALUES (?, ?, ?, ?)",
              (nome, cpf or None, telefone or None, email or None))

def listar_exercicios():
    return _executar("SELECT id, nome, grupo_muscular, descricao FROM exercicio ORDER BY nome", fetch=True)

def cadastrar_exercicio(nome, grupo_muscular, descricao=None):
    _executar("INSERT INTO exercicio (nome, grupo_muscular, descricao) VALUES (?, ?, ?)",
              (nome, grupo_muscular, descricao or None))

def listar_matriculas():
    return _executar("""
        SELECT m.id, a.nome, p.nome, m.data_inicio, m.data_fim, m.status
        FROM matricula m JOIN aluno a ON a.id=m.aluno_id
        JOIN plano p ON p.id=m.plano_id ORDER BY m.id DESC
    """, fetch=True)

def cadastrar_matricula(aluno_id, plano_id, inicio, fim=None, status="ATIVA"):
    _executar("INSERT INTO matricula (aluno_id, plano_id, data_inicio, data_fim, status) VALUES (?, ?, ?, ?, ?)",
              (aluno_id, plano_id, inicio, fim, status))

def listar_treinos():
    return _executar("""
        SELECT t.id, t.nome, a.nome, p.nome, t.data_criacao, t.objetivo
        FROM treino t JOIN matricula m ON m.id=t.matricula_id
        JOIN aluno a ON a.id=m.aluno_id JOIN professor p ON p.id=t.professor_id
        ORDER BY t.id DESC
    """, fetch=True)

def cadastrar_treino(matricula_id, professor_id, nome, objetivo=None):
    _executar("INSERT INTO treino (matricula_id, professor_id, nome, objetivo) VALUES (?, ?, ?, ?)",
              (matricula_id, professor_id, nome, objetivo or None))

def associar_exercicio(treino_id, exercicio_id, series=None, repeticoes=None, carga=None, descanso=None):
    _executar("""
        INSERT INTO treino_exercicio
            (treino_id, exercicio_id, series, repeticoes, carga, descanso_segundos)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (treino_id, exercicio_id, series, repeticoes, carga, descanso))

def listar_treino_exercicios():
    return _executar("""
        SELECT t.id, t.nome, e.nome, e.grupo_muscular, te.series,
               te.repeticoes, te.carga, te.descanso_segundos
        FROM treino_exercicio te JOIN treino t ON t.id=te.treino_id
        JOIN exercicio e ON e.id=te.exercicio_id ORDER BY t.nome, e.nome
    """, fetch=True)

def excluir_por_id(tabela, registro_id):
    permitidas = {"aluno", "plano", "professor", "exercicio", "matricula", "treino"}
    if tabela not in permitidas:
        raise ValueError("Tabela não permitida para exclusão.")
    return _executar(f"DELETE FROM {tabela} WHERE id = ?", (registro_id,))

def resumo():
    return _executar("""
        SELECT (SELECT COUNT(*) FROM aluno),
               (SELECT COUNT(*) FROM professor),
               (SELECT COUNT(*) FROM plano),
               (SELECT COUNT(*) FROM matricula WHERE status='ATIVA'),
               (SELECT COUNT(*) FROM treino),
               (SELECT COUNT(*) FROM exercicio)
    """, fetch=True, one=True)

def media_valor_planos():
    return _executar("SELECT AVG(valor) FROM plano", fetch=True, one=True)[0]

def matriculas_por_status():
    return _executar("SELECT status, COUNT(*) FROM matricula GROUP BY status ORDER BY status", fetch=True)

def treinos_por_aluno():
    return _executar("""
        SELECT a.nome, COUNT(t.id) AS quantidade
        FROM aluno a LEFT JOIN matricula m ON m.aluno_id=a.id
        LEFT JOIN treino t ON t.matricula_id=m.id
        GROUP BY a.id, a.nome ORDER BY quantidade DESC, a.nome
    """, fetch=True)

def carga_media_por_grupo():
    return _executar("""
        SELECT e.grupo_muscular, AVG(te.carga)
        FROM exercicio e JOIN treino_exercicio te ON te.exercicio_id=e.id
        WHERE te.carga IS NOT NULL GROUP BY e.grupo_muscular ORDER BY e.grupo_muscular
    """, fetch=True)
