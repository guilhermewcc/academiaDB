from database import inicializar_banco_de_dados
import crud

def exibir_menu():
    print("\n" + "=" * 35)
    print("    SISTEMA ACADEMIA DB (ODBC)")
    print("=" * 35)
    print("1. Cadastrar Aluno")
    print("2. Listar Alunos")
    print("3. Cadastrar Plano")
    print("4. Listar Planos")
    print("0. Sair")
    return input("Opção: ")

def main():
    # Executa e aplica a estrutura do arquivo .sql ao iniciar
    inicializar_banco_de_dados("schema.sql")

    while True:
        opcao = exibir_menu()

        if opcao == "1":
            nome = input("Nome do Aluno: ")
            cpf = input("CPF: ")
            email = input("E-mail: ")
            crud.cadastrar_aluno(nome, cpf, email)

        elif opcao == "2":
            alunos = crud.listar_alunos()
            print("\n--- ALUNOS CADASTRADOS ---")
            for a in alunos:
                print(f"ID: {a[0]} | Nome: {a[1]} | CPF: {a[2]} | Email: {a[3]}")

        elif opcao == "3":
            nome = input("Nome do Plano: ")
            valor = float(input("Valor (R$): "))
            duracao = int(input("Duração (meses): "))
            crud.cadastrar_plano(nome, valor, duracao)

        elif opcao == "4":
            planos = crud.listar_planos()
            print("\n--- PLANOS CADASTRADOS ---")
            for p in planos:
                print(f"ID: {p[0]} | Nome: {p[1]} | Valor: R$ {p[2]:.2f} | Duração: {p[3]} meses")

        elif opcao == "0":
            print("\nSaindo...")
            break
        else:
            print("\nOpção inválida! Tente novamente.")

if __name__ == "__main__":
    main()