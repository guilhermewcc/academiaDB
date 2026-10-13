# AcademiaDB — Python refatorado

Esta versão usa o banco PostgreSQL existente e **não executa `schema.sql` automaticamente**. Portanto, iniciar o programa não recria tabelas nem apaga dados.

## Arquivos
- `main.py`: menus e validação de entrada.
- `database.py`: conexão ODBC configurável por variáveis de ambiente.
- `crud.py`: operações de cadastro, listagem, exclusão e relatórios SQL.
- `requirements.txt`: dependência `pyodbc`.

## Requisitos
1. Python 3.10+.
2. PostgreSQL ativo, com o banco `academia` já existente.
3. Driver ODBC PostgreSQL Unicode instalado.
4. Permissões para consultar e alterar as tabelas.

## Instalação
Na pasta do projeto:

```bash
python -m venv .venv
```

Windows PowerShell:
```powershell
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
$env:ACADEMIA_DB_HOST="localhost"
$env:ACADEMIA_DB_PORT="5432"
$env:ACADEMIA_DB_NAME="academia"
$env:ACADEMIA_DB_USER="postgres"
$env:ACADEMIA_DB_PASSWORD="SUA_SENHA"
$env:ACADEMIA_DB_DRIVER="PostgreSQL Unicode"
python main.py
```

Linux/macOS:
```bash
source .venv/bin/activate
python -m pip install -r requirements.txt
export ACADEMIA_DB_HOST=localhost
export ACADEMIA_DB_PORT=5432
export ACADEMIA_DB_NAME=academia
export ACADEMIA_DB_USER=postgres
export ACADEMIA_DB_PASSWORD='SUA_SENHA'
export ACADEMIA_DB_DRIVER='PostgreSQL Unicode'
python main.py
```

Substitua `SUA_SENHA` pela senha local. Não publique credenciais no GitHub. Se o driver tiver outro nome no computador, ajuste `ACADEMIA_DB_DRIVER`.

## Funcionalidades
- Cadastro e listagem de alunos, planos, professores e exercícios.
- Cadastro e listagem de matrículas.
- Cadastro de treinos e associação de exercícios aos treinos.
- Relatórios com `AVG`, `COUNT`, `GROUP BY` e `JOIN`.
- Exclusão por ID em alunos, planos, professores e exercícios, protegida por confirmação e pelas chaves estrangeiras.
- Mensagens de erro de conexão e de integridade.

## Observações
- A inicialização faz apenas uma consulta de teste, `SELECT current_database(), current_user`.
- A aplicação não executa `schema.sql`, `insercoes.sql` nem `consultas.sql`.
- Os exemplos acadêmicos completos devem permanecer em `consultas.sql` para execução direta no PostgreSQL.
- As ações escolhidas no menu podem modificar dados (inserir ou excluir). A inicialização em si não modifica o banco.
