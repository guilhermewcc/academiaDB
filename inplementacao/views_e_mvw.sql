-- ============================================================
-- VISOES.SQL
-- Banco de dados: Academia
--   10 VIEWS
--   10 MATERIALIZED VIEWS
-- ============================================================

-- ============================================================
-- Views
-- ============================================================

CREATE or REPLACE VIEW vw_aluno_plano AS
SELECT
	a.id AS aluno_id,
	a.nome AS aluno_nome,
	a.email AS aluno_email,
	p.nome AS plano,
	p.valor AS plano_valor,
	m.data_inicio,
	m.data_fim,
	m.status AS status_matriculas
	
FROM aluno a 
INNER JOIN matricula m ON a.id = m.aluno_id
INNER JOIN plano p ON m.plano_id = p.id;


CREATE or REPLACE VIEW vw_treino_aluno AS
SELECT
	a.id AS aluno_id,
	a.nome AS aluno_nome,
	t.nome AS treino_nome,
	p.id AS professor_id,
	p.nome AS professor_nome
	
FROM aluno a 
INNER JOIN matricula m ON a.id = m.aluno_id
INNER JOIN treino t ON t.matricula_id = m.id
INNER JOIN professor p ON p.id = t.professor_id;

CREATE or REPLACE VIEW vw_treino_professor AS
SELECT
	t.id AS treino_id,
	t.nome AS treino_nome,
	p.id AS professor_id,
	p.nome AS professor_nome,
	p.cpf AS professor_cpf
	
FROM treino t 
INNER JOIN professor p ON p.id = t.professor_id;

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
INNER JOIN exercicio e ON te.exercicio_id = e.id;


CREATE OR REPLACE VIEW vw_exercicio_categoria AS
SELECT
    t.id AS treino_id,
    t.nome AS treino_nome,
    t.objetivo AS treino_objetivo,
    e.grupo_muscular AS categoria,
    e.nome AS exercicio
FROM treino_exercicio te
INNER JOIN treino t ON te.treino_id = t.id
INNER JOIN exercicio e ON te.exercicio_id = e.id;

CREATE OR REPLACE VIEW vw_professor_aluno AS
SELECT DISTINCT
    p.id AS professor_id,
    p.nome AS professor_nome,
    a.id AS aluno_id,
    a.nome AS aluno_nome
FROM professor p
INNER JOIN treino t ON t.professor_id = p.id
INNER JOIN matricula m ON m.id = t.matricula_id 
INNER JOIN aluno a ON a.id = m.aluno_id;

CREATE OR REPLACE VIEW vw_exercicio_treino_detalhado AS
SELECT
    t.id AS treino_id,
    t.nome AS treino_nome,
    t.objetivo AS treino_objetivo,
    e.id AS exercicio_id,
    e.nome AS exercicio_nome,
    e.grupo_muscular AS exercicio_grupo_muscular,
    e.descricao AS exercicio_descricao,
    te.series AS series,
    te.repeticoes AS repeticoes,
    te.carga AS carga,
    te.descanso_segundos AS descanso_segundos
FROM treino_exercicio te
INNER JOIN treino t ON te.treino_id = t.id
INNER JOIN exercicio e ON te.exercicio_id = e.id;

CREATE OR REPLACE VIEW vw_alunos_ativos AS
SELECT
    m.id AS matricula_id,
    a.id AS aluno_id,
    a.nome AS aluno_nome,
    p.nome AS plano_nome,
    m.status AS status
FROM matricula m
INNER JOIN aluno a ON m.aluno_id = a.id
INNER JOIN plano p ON m.plano_id = p.id
WHERE m.status = 'ATIVA';

CREATE or REPLACE VIEW vw_aluno_exercicios AS
SELECT

	m.id AS matricula_id,
	a.id AS aluno_id,
	a.nome AS aluno_nome,
	e.nome AS exercicio
	
FROM treino_exercicio te
INNER JOIN treino t ON t.id = te.treino_id
INNER JOIN matricula m ON t.matricula_id = m.id
INNER JOIN aluno a ON a.id = m.aluno_id
INNER JOIN exercicio e ON e.id = te.exercicio_id;

CREATE or REPLACE VIEW vw_treinos_completos AS
SELECT

	t.id AS treino_id,
	t.nome AS treino_nome,
	t.objetivo AS objetivo,
	t.data_criacao AS data_criacao,
	a.id AS aluno_id,
	a.nome AS aluno_nome,
	p.id AS professor_id,
	p.nome AS professor_nome
	
	
FROM treino t
INNER JOIN matricula m ON t.matricula_id = m.id
INNER JOIN aluno a ON a.id = m.aluno_id
INNER JOIN professor p ON p.id = t.professor_id;

-- ============================================================
-- Materialized Views
-- ============================================================

CREATE MATERIALIZED VIEW mvw_qtd_exercicios_treino AS
SELECT
    t.id AS treino_id,
    t.nome AS treino_nome,
    COUNT(te.exercicio_id) AS quantidade_exercicios
FROM treino t
INNER JOIN treino_exercicio te ON te.treino_id = t.id
GROUP BY t.id, t.nome;

CREATE MATERIALIZED VIEW mvw_qtd_alunos_professor AS
SELECT
    p.id AS professor_id,
    p.nome AS professor_nome,
    COUNT(DISTINCT m.aluno_id) AS quantidade_alunos
FROM professor p
INNER JOIN treino t ON t.professor_id = p.id
INNER JOIN matricula m ON t.matricula_id = m.id
GROUP BY p.id, p.nome;


CREATE MATERIALIZED VIEW mvw_qtd_alunos_plano AS
SELECT
    p.id AS plano_id,
    p.nome AS plano_nome,
    COUNT(m.aluno_id) AS quantidade_alunos
FROM plano p
INNER JOIN matricula m ON p.id = m.plano_id
GROUP BY p.id, p.nome;


CREATE MATERIALIZED VIEW mvw_qtd_treinos_aluno AS
SELECT
    a.id AS aluno_id,
    a.nome AS aluno_nome,
    COUNT(t.id) AS quantidade_treinos
FROM aluno a
INNER JOIN matricula m ON a.id = m.aluno_id
INNER JOIN treino t ON t.matricula_id = m.id
GROUP BY a.id, a.nome;

CREATE MATERIALIZED VIEW mvw_exercicios_mais_utilizados AS
SELECT
    e.id AS exercicio_id,
    e.nome AS exercicio_nome,
    COUNT(te.treino_id) AS frequencia_de_utilizacao
FROM exercicio e
INNER JOIN treino_exercicio te ON te.exercicio_id = e.id
GROUP BY e.id, e.nome
ORDER BY frequencia_de_utilizacao DESC;

CREATE MATERIALIZED VIEW mvw_qtd_exercicios_grupo_muscular AS
SELECT
    grupo_muscular,
    COUNT(*) AS quantidade_exercicios
FROM exercicio
GROUP BY grupo_muscular
ORDER BY quantidade_exercicios DESC;


CREATE MATERIALIZED VIEW mvw_qtd_treinos_professor AS
SELECT
    p.id AS professor_id,
    p.nome AS professor,
    COUNT(t.id) AS quantidade_treinos
FROM professor p
LEFT JOIN treino t
    ON p.id = t.professor_id
GROUP BY p.id, p.nome
ORDER BY quantidade_treinos DESC;


CREATE MATERIALIZED VIEW mvw_qtd_matriculas_status AS
SELECT
    status,
    COUNT(*) AS quantidade_matriculas
FROM matricula
GROUP BY status
ORDER BY quantidade_matriculas DESC;

CREATE MATERIALIZED VIEW mvw_media_carga_exercicio AS
SELECT
    e.id AS exercicio_id,
    e.nome AS exercicio,
    e.grupo_muscular,
    ROUND(AVG(te.carga), 2) AS media_carga
FROM exercicio e
JOIN treino_exercicio te
    ON e.id = te.exercicio_id
WHERE te.carga IS NOT NULL
GROUP BY e.id, e.nome, e.grupo_muscular
ORDER BY media_carga DESC;

CREATE MATERIALIZED VIEW mvw_media_exercicios_treino_professor AS
SELECT
    p.id AS professor_id,
    p.nome AS professor,
    ROUND(AVG(q.quantidade_exercicios), 2) AS media_exercicios_por_treino
FROM professor p
JOIN treino t
    ON p.id = t.professor_id
JOIN (
    SELECT
        treino_id,
        COUNT(*) AS quantidade_exercicios
    FROM treino_exercicio
    GROUP BY treino_id
) q
    ON t.id = q.treino_id
GROUP BY p.id, p.nome
ORDER BY media_exercicios_por_treino DESC;