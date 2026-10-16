# AcademiaDB — Python

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
