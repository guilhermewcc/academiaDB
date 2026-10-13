"""Interface de terminal do AcademiaDB. Não executa schema.sql nem apaga dados."""
from datetime import date
import pyodbc
import crud
from database import testar_conexao

def texto(prompt, obrigatorio=True):
    while True:
        v = input(prompt).strip()
        if v or not obrigatorio:
            return v or None
        print("Campo obrigatório.")

def inteiro(prompt, minimo=1, opcional=False):
    while True:
        v = input(prompt).strip()
        if opcional and not v:
            return None
        try:
            n = int(v)
            if n < minimo:
                print(f"Informe um inteiro >= {minimo}.")
                continue
            return n
        except ValueError:
            print("Digite um número inteiro válido.")

def numero(prompt, minimo=0):
    while True:
        try:
            n = float(input(prompt).strip().replace(",", "."))
            if n < minimo:
                print(f"Informe um valor >= {minimo}.")
                continue
            return n
        except ValueError:
            print("Digite um número válido.")

def data(prompt, opcional=False):
    while True:
        v = input(prompt).strip()
        if opcional and not v:
            return None
        try:
            return date.fromisoformat(v)
        except ValueError:
            print("Use AAAA-MM-DD, por exemplo 2026-10-13.")

def tabela(titulo, cabecalhos, linhas):
    print(f"\n--- {titulo} ---")
    if not linhas:
        print("Nenhum registro encontrado.")
        return
    print(" | ".join(cabecalhos))
    for linha in linhas:
        print(" | ".join("-" if x is None else str(x) for x in linha))

def executar(func, *args):
    try:
        func(*args)
        print("Operação concluída.")
    except (pyodbc.Error, RuntimeError) as exc:
        print(f"Erro do banco: {exc}")
        print("Confira IDs, campos obrigatórios e restrições do PostgreSQL.")
    except ValueError as exc:
        print(f"Dados inválidos: {exc}")

def alunos():
    while True:
        op = input("\nALUNOS: 1 cadastrar | 2 listar | 3 excluir por ID | 0 voltar: ").strip()
        if op == "1":
            nome = texto("Nome: ")
            cpf = texto("CPF (11 dígitos): ")
            if not cpf.isdigit() or len(cpf) != 11:
                print("CPF deve conter exatamente 11 números."); continue
            nascimento = data("Nascimento AAAA-MM-DD (Enter se não souber): ", True)
            executar(crud.cadastrar_aluno, nome, cpf, nascimento,
                     texto("Telefone (opcional): ", False), texto("E-mail (opcional): ", False))
        elif op == "2":
            try: tabela("ALUNOS", ["ID","Nome","CPF","Nascimento","Telefone","E-mail"], crud.listar_alunos())
            except (pyodbc.Error, RuntimeError) as e: print(e)
        elif op == "3":
            id_ = inteiro("ID do aluno: ")
            if input("Confirmar exclusão? (s/N): ").lower() == "s": executar(crud.excluir_por_id, "aluno", id_)
        elif op == "0": return
        else: print("Opção inválida.")

def planos():
    while True:
        op = input("\nPLANOS: 1 cadastrar | 2 listar | 3 excluir por ID | 0 voltar: ").strip()
        if op == "1":
            executar(crud.cadastrar_plano, texto("Nome: "), numero("Valor R$: "), inteiro("Duração em dias: "))
        elif op == "2":
            try:
                rows = [(r[0], r[1], f"R$ {float(r[2]):.2f}", r[3]) for r in crud.listar_planos()]
                tabela("PLANOS", ["ID","Nome","Valor","Duração (dias)"], rows)
            except (pyodbc.Error, RuntimeError) as e: print(e)
        elif op == "3":
            id_ = inteiro("ID do plano: ")
            if input("Confirmar exclusão? (s/N): ").lower() == "s": executar(crud.excluir_por_id, "plano", id_)
        elif op == "0": return
        else: print("Opção inválida.")

def professores():
    while True:
        op = input("\nPROFESSORES: 1 cadastrar | 2 listar | 3 excluir por ID | 0 voltar: ").strip()
        if op == "1":
            nome = texto("Nome: "); cpf = texto("CPF opcional: ", False)
            if cpf and (not cpf.isdigit() or len(cpf) != 11):
                print("CPF deve ter 11 números ou ficar vazio."); continue
            executar(crud.cadastrar_professor, nome, cpf, texto("Telefone opcional: ", False), texto("E-mail opcional: ", False))
        elif op == "2":
            try: tabela("PROFESSORES", ["ID","Nome","CPF","Telefone","E-mail"], crud.listar_professores())
            except (pyodbc.Error, RuntimeError) as e: print(e)
        elif op == "3":
            id_ = inteiro("ID do professor: ")
            if input("Confirmar exclusão? (s/N): ").lower() == "s": executar(crud.excluir_por_id, "professor", id_)
        elif op == "0": return
        else: print("Opção inválida.")

def exercicios():
    while True:
        op = input("\nEXERCÍCIOS: 1 cadastrar | 2 listar | 3 excluir por ID | 0 voltar: ").strip()
        if op == "1":
            executar(crud.cadastrar_exercicio, texto("Nome: "), texto("Grupo muscular: "), texto("Descrição opcional: ", False))
        elif op == "2":
            try: tabela("EXERCÍCIOS", ["ID","Nome","Grupo muscular","Descrição"], crud.listar_exercicios())
            except (pyodbc.Error, RuntimeError) as e: print(e)
        elif op == "3":
            id_ = inteiro("ID do exercício: ")
            if input("Confirmar exclusão? (s/N): ").lower() == "s": executar(crud.excluir_por_id, "exercicio", id_)
        elif op == "0": return
        else: print("Opção inválida.")

def matriculas():
    while True:
        op = input("\nMATRÍCULAS: 1 cadastrar | 2 listar | 0 voltar: ").strip()
        if op == "1":
            try:
                tabela("ALUNOS", ["ID","Nome","CPF","Nascimento","Telefone","E-mail"], crud.listar_alunos())
                tabela("PLANOS", ["ID","Nome","Valor","Duração (dias)"], crud.listar_planos())
            except (pyodbc.Error, RuntimeError) as e: print(e); continue
            aid = inteiro("ID do aluno: "); pid = inteiro("ID do plano: ")
            inicio = data("Data início AAAA-MM-DD: ")
            fim = data("Data fim AAAA-MM-DD (Enter se não houver): ", True)
            status = (texto("Status ATIVA/CANCELADA/FINALIZADA (padrão ATIVA): ", False) or "ATIVA").upper()
            if status not in {"ATIVA","CANCELADA","FINALIZADA"}:
                print("Status inválido."); continue
            executar(crud.cadastrar_matricula, aid, pid, inicio, fim, status)
        elif op == "2":
            try: tabela("MATRÍCULAS", ["ID","Aluno","Plano","Início","Fim","Status"], crud.listar_matriculas())
            except (pyodbc.Error, RuntimeError) as e: print(e)
        elif op == "0": return
        else: print("Opção inválida.")

def treinos():
    while True:
        op = input("\nTREINOS: 1 cadastrar treino | 2 listar | 3 associar exercício | 4 listar exercícios | 0 voltar: ").strip()
        if op == "1":
            try:
                tabela("MATRÍCULAS", ["ID","Aluno","Plano","Início","Fim","Status"], crud.listar_matriculas())
                tabela("PROFESSORES", ["ID","Nome","CPF","Telefone","E-mail"], crud.listar_professores())
            except (pyodbc.Error, RuntimeError) as e: print(e); continue
            executar(crud.cadastrar_treino, inteiro("ID da matrícula: "), inteiro("ID do professor: "),
                     texto("Nome do treino: "), texto("Objetivo opcional: ", False))
        elif op == "2":
            try: tabela("TREINOS", ["ID","Treino","Aluno","Professor","Data","Objetivo"], crud.listar_treinos())
            except (pyodbc.Error, RuntimeError) as e: print(e)
        elif op == "3":
            try:
                tabela("TREINOS", ["ID","Treino","Aluno","Professor","Data","Objetivo"], crud.listar_treinos())
                tabela("EXERCÍCIOS", ["ID","Nome","Grupo muscular","Descrição"], crud.listar_exercicios())
            except (pyodbc.Error, RuntimeError) as e: print(e); continue
            tid = inteiro("ID do treino: "); eid = inteiro("ID do exercício: ")
            series = inteiro("Séries (Enter para vazio): ", opcional=True)
            reps = inteiro("Repetições (Enter para vazio): ", opcional=True)
            carga = numero("Carga em kg (0 ou mais): ") if input("Informar carga? (s/N): ").lower() == "s" else None
            descanso = inteiro("Descanso em segundos (Enter para vazio): ", minimo=0, opcional=True)
            executar(crud.associar_exercicio, tid, eid, series, reps, carga, descanso)
        elif op == "4":
            try: tabela("EXERCÍCIOS POR TREINO", ["ID treino","Treino","Exercício","Grupo","Séries","Repetições","Carga","Descanso"], crud.listar_treino_exercicios())
            except (pyodbc.Error, RuntimeError) as e: print(e)
        elif op == "0": return
        else: print("Opção inválida.")

def relatorios():
    while True:
        print("\nRELATÓRIOS SQL\n1 resumo da academia\n2 média dos planos (AVG)\n3 matrículas por status (COUNT/GROUP BY)\n4 treinos por aluno (JOIN/COUNT)\n5 carga média por grupo (AVG/GROUP BY)\n0 voltar")
        op = input("Opção: ").strip()
        try:
            if op == "1": tabela("RESUMO", ["Alunos","Professores","Planos","Matrículas ativas","Treinos","Exercícios"], [crud.resumo()])
            elif op == "2":
                media = crud.media_valor_planos()
                print("Média dos valores dos planos:", "sem dados" if media is None else f"R$ {float(media):.2f}")
            elif op == "3": tabela("MATRÍCULAS POR STATUS", ["Status","Quantidade"], crud.matriculas_por_status())
            elif op == "4": tabela("TREINOS POR ALUNO", ["Aluno","Quantidade de treinos"], crud.treinos_por_aluno())
            elif op == "5": tabela("CARGA MÉDIA POR GRUPO", ["Grupo muscular","Carga média"], crud.carga_media_por_grupo())
            elif op == "0": return
            else: print("Opção inválida.")
        except (pyodbc.Error, RuntimeError) as e: print(f"Erro no relatório: {e}")

def main():
    try:
        db, user = testar_conexao()
        print(f"Conectado ao banco '{db}' como '{user}'.")
    except (RuntimeError, pyodbc.Error) as e:
        print(e)
        print("Encerrando sem modificar o banco.")
        return
    menus = {"1": alunos, "2": planos, "3": professores, "4": exercicios,
             "5": matriculas, "6": treinos, "7": relatorios}
    while True:
        print("\n" + "=" * 40 + "\n          ACADEMIA DB\n" + "=" * 40)
        print("1 Alunos\n2 Planos\n3 Professores\n4 Exercícios\n5 Matrículas\n6 Treinos\n7 Relatórios SQL\n0 Sair")
        op = input("Opção: ").strip()
        if op == "0":
            print("Encerrado. O esquema e os dados existentes foram preservados.")
            break
        if op in menus: menus[op]()
        else: print("Opção inválida.")

if __name__ == "__main__":
    main()
