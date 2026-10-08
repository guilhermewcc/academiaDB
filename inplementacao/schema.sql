CREATE TABLE aluno (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    data_nascimento DATE,
    telefone VARCHAR(20),
    email VARCHAR(100) UNIQUE
);


CREATE TABLE plano (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    valor NUMERIC(10,2) NOT NULL,
    duracao_dias INTEGER NOT NULL,

    CONSTRAINT plano_valor_check
        CHECK (valor >= 0),

    CONSTRAINT plano_duracao_check
        CHECK (duracao_dias > 0)
);


CREATE TABLE professor (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) UNIQUE,
    telefone VARCHAR(20),
    email VARCHAR(100) UNIQUE
);


CREATE TABLE exercicio (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    grupo_muscular VARCHAR(50) NOT NULL,
    descricao TEXT
);


CREATE TABLE matricula (
    id SERIAL PRIMARY KEY,

    aluno_id INTEGER NOT NULL,
    plano_id INTEGER NOT NULL,

    data_inicio DATE NOT NULL,
    data_fim DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'ATIVA',

    CONSTRAINT fk_matricula_aluno
        FOREIGN KEY (aluno_id)
        REFERENCES aluno(id),

    CONSTRAINT fk_matricula_plano
        FOREIGN KEY (plano_id)
        REFERENCES plano(id),

    CONSTRAINT matricula_status_check
        CHECK (status IN ('ATIVA', 'CANCELADA', 'FINALIZADA')),

    CONSTRAINT matricula_datas_check
        CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);


-- Um aluno só pode ter uma matrícula ATIVA
CREATE UNIQUE INDEX unica_matricula_ativa_por_aluno
ON matricula (aluno_id)
WHERE status = 'ATIVA';


CREATE TABLE treino (
    id SERIAL PRIMARY KEY,

    matricula_id INTEGER NOT NULL,
    professor_id INTEGER NOT NULL,

    nome VARCHAR(100) NOT NULL,
    objetivo TEXT,
    data_criacao DATE NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT fk_treino_matricula
        FOREIGN KEY (matricula_id)
        REFERENCES matricula(id),

    CONSTRAINT fk_treino_professor
        FOREIGN KEY (professor_id)
        REFERENCES professor(id),

    -- Uma matrícula não pode ter dois treinos
    -- com o mesmo nome
    CONSTRAINT treino_matricula_nome_unique
        UNIQUE (matricula_id, nome)
);


CREATE TABLE treino_exercicio (
    treino_id INTEGER NOT NULL,
    exercicio_id INTEGER NOT NULL,

    series INTEGER,
    repeticoes INTEGER,
    carga NUMERIC(6,2),
    descanso_segundos INTEGER,

    PRIMARY KEY (treino_id, exercicio_id),

    CONSTRAINT fk_treino_exercicio_treino
        FOREIGN KEY (treino_id)
        REFERENCES treino(id),

    CONSTRAINT fk_treino_exercicio_exercicio
        FOREIGN KEY (exercicio_id)
        REFERENCES exercicio(id),

    CONSTRAINT treino_exercicio_series_check
        CHECK (series IS NULL OR series > 0),

    CONSTRAINT treino_exercicio_repeticoes_check
        CHECK (repeticoes IS NULL OR repeticoes > 0),

    CONSTRAINT treino_exercicio_carga_check
        CHECK (carga IS NULL OR carga >= 0),

    CONSTRAINT treino_exercicio_descanso_check
        CHECK (descanso_segundos IS NULL OR descanso_segundos >= 0)
);

CREATE or REPLACE VIEW vw_treino_exercicio AS
SELECT
	t.id AS treino_id,
	t.nome AS treino_nome,
	t.objetivo AS treino_objetivo,
	e.id AS exercicio_id,
	e.nome AS exercicio_nome,
	e.grupo_muscular AS exercicio_grupo_muscular
FROM treino_exercicio te
INNER JOIN treino t ON te.treino_id =  t.id
INNER JOIN exercicio e ON te.exercicio_id = e.id
