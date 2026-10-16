-- ============================================================
-- CONSULTAS
-- ============================================================

-- ============================================================
-- CONSULTAS BÁSICAS
-- ============================================================

-- SELECT
SELECT nome
FROM aluno;

-- SELECT DISTINCT
SELECT DISTINCT grupo_muscular
FROM exercicio;

-- SELECT *
SELECT *
FROM plano;

-- Expressão aritmética + AS
SELECT nome, valor, valor / 30 AS valor_diario
FROM plano;

-- WHERE + AND
SELECT nome, email
FROM aluno
WHERE nome LIKE 'A%' AND email IS NOT NULL;

-- BETWEEN
SELECT nome, valor
FROM plano
WHERE valor BETWEEN 100 AND 500;

-- ORDER BY
SELECT nome, valor
FROM plano
ORDER BY valor DESC;

-- LIKE
SELECT nome
FROM aluno
WHERE nome LIKE '%a%';


-- ============================================================
-- JOIN
-- ============================================================

-- INNER JOIN
SELECT
    a.nome AS aluno,
    p.nome AS plano,
    m.status
FROM aluno a
INNER JOIN matricula m ON m.aluno_id = a.id
INNER JOIN plano p ON p.id = m.plano_id
ORDER BY a.nome;

-- LEFT JOIN
SELECT
    p.id AS professor_id,
    p.nome AS professor,
    COUNT(t.id) AS quantidade_treinos
FROM professor p
LEFT JOIN treino t
    ON p.id = t.professor_id
GROUP BY p.id, p.nome
ORDER BY quantidade_treinos DESC;

-- RIGHT JOIN
SELECT 
    p.nome AS professor_nome,
    t.nome AS treino_nome,
    t.objetivo
FROM treino t
RIGHT JOIN professor p ON t.professor_id = p.id;

-- FULL OUTER
SELECT 
    p.nome AS professor_nome,
    t.nome AS treino_nome,
    t.data_criacao
FROM professor p
FULL OUTER JOIN treino t ON t.professor_id = p.id;

-- NATURAL JOIN
SELECT 
    nome, 
    status, 
    data_inicio
FROM aluno
NATURAL JOIN matricula;


-- ============================================================
-- FUNÇÕES DE AGREGAÇÃO
-- Slides: AVG, MIN, MAX, SUM e COUNT
-- ============================================================

-- AVG(): média
SELECT AVG(valor) AS valor_medio_planos
FROM plano;

-- MIN(): menor valor
SELECT MIN(valor) AS menor_valor_plano
FROM plano;

-- MAX(): maior valor
SELECT MAX(valor) AS maior_valor_plano
FROM plano;

-- SUM(): soma
SELECT SUM(valor) AS soma_valores_planos
FROM plano;

-- COUNT(): quantidade de registros
SELECT COUNT(*) AS quantidade_alunos
FROM aluno;

-- COUNT(DISTINCT): quantidade de alunos com matrícula
SELECT COUNT(DISTINCT aluno_id) AS alunos_matriculados
FROM matricula;

-- GROUP BY + AVG()
SELECT
    grupo_muscular,
    AVG(carga) AS carga_media
FROM exercicio e
INNER JOIN treino_exercicio te ON te.exercicio_id = e.id
GROUP BY grupo_muscular
ORDER BY grupo_muscular;

-- GROUP BY + HAVING
SELECT
    grupo_muscular,
    AVG(carga) AS carga_media
FROM exercicio e
INNER JOIN treino_exercicio te ON te.exercicio_id = e.id
WHERE te.carga IS NOT NULL
GROUP BY grupo_muscular
HAVING AVG(carga) > 40
ORDER BY carga_media DESC;


-- ============================================================
-- SUBCONSULTAS
-- ============================================================

-- IN
SELECT nome
FROM aluno
WHERE id IN (
    SELECT aluno_id
    FROM matricula
    WHERE status = 'ATIVA'
);

-- NOT IN
SELECT nome
FROM aluno
WHERE id NOT IN (
    SELECT aluno_id
    FROM matricula
    WHERE status = 'CANCELADA'
);

-- EXISTS
SELECT a.nome
FROM aluno a
WHERE EXISTS (
    SELECT 1
    FROM matricula m
    WHERE m.aluno_id = a.id
);

-- NOT EXISTS
SELECT a.nome
FROM aluno a
WHERE NOT EXISTS (
    SELECT 1
    FROM treino t
    INNER JOIN matricula m ON m.id = t.matricula_id
    WHERE m.aluno_id = a.id
);

-- Subconsulta escalar
SELECT
    p.nome,
    p.valor,
    (SELECT AVG(valor) FROM plano) AS media_dos_planos
FROM plano p;


-- ============================================================
-- CASE
-- ============================================================

SELECT
    nome,
    valor,
    CASE
        WHEN valor < 200 THEN 'Plano econômico'
        WHEN valor <= 500 THEN 'Plano intermediário'
        ELSE 'Plano premium'
    END AS categoria
FROM plano;


-- ============================================================
-- FUNÇÕES DE RANKING
--    RANK, DENSE_RANK, PERCENT_RANK, CUME_DIST,
--    ROW_NUMBER e NTILE
-- ============================================================

-- RANK()
SELECT
    a.nome,
    COUNT(t.id) AS quantidade_treinos,
    RANK() OVER (ORDER BY COUNT(t.id) DESC) AS ranking
FROM aluno a
LEFT JOIN matricula m ON m.aluno_id = a.id
LEFT JOIN treino t ON t.matricula_id = m.id
GROUP BY a.id, a.nome
ORDER BY ranking, a.nome;

-- DENSE_RANK()
SELECT
    p.nome,
    p.valor,
    DENSE_RANK() OVER (ORDER BY p.valor DESC) AS ranking
FROM plano p
ORDER BY ranking;

-- PERCENT_RANK()
SELECT
    p.nome,
    p.valor,
    PERCENT_RANK() OVER (ORDER BY p.valor) AS percentual_ranking
FROM plano p
ORDER BY p.valor;

-- CUME_DIST()
SELECT
    p.nome,
    p.valor,
    CUME_DIST() OVER (ORDER BY p.valor) AS distribuicao_acumulada
FROM plano p
ORDER BY p.valor;

-- ROW_NUMBER()
SELECT
    p.nome,
    p.valor,
    ROW_NUMBER() OVER (ORDER BY p.valor DESC) AS numero_linha
FROM plano p
ORDER BY numero_linha;

-- NTILE(4)
SELECT
    p.nome,
    p.valor,
    NTILE(4) OVER (ORDER BY p.valor DESC) AS faixa
FROM plano p
ORDER BY faixa, p.valor DESC;


-- ============================================================
-- RANKING POR PARTIÇÃO
-- ============================================================

SELECT
    e.grupo_muscular,
    e.nome AS exercicio,
    te.carga,
    RANK() OVER (
        PARTITION BY e.grupo_muscular
        ORDER BY te.carga DESC
    ) AS ranking_no_grupo
FROM exercicio e
INNER JOIN treino_exercicio te ON te.exercicio_id = e.id
WHERE te.carga IS NOT NULL
ORDER BY e.grupo_muscular, ranking_no_grupo;


-- ============================================================
-- WINDOW FUNCTION COM SUM()
-- ============================================================

SELECT
    a.nome,
    m.id AS matricula_id,
    p.valor,
    SUM(p.valor) OVER (
        ORDER BY m.id
        ROWS UNBOUNDED PRECEDING
    ) AS soma_acumulada
FROM aluno a
INNER JOIN matricula m ON m.aluno_id = a.id
INNER JOIN plano p ON p.id = m.plano_id
ORDER BY m.id;


-- ============================================================
-- GROUPING + CUBE
-- ============================================================

SELECT
    e.grupo_muscular,
    e.nome AS exercicio,
    SUM(te.carga) AS carga_total,
    GROUPING(e.grupo_muscular) AS grupo_muscular_flag,
    GROUPING(e.nome) AS exercicio_flag
FROM exercicio e
INNER JOIN treino_exercicio te ON te.exercicio_id = e.id
WHERE te.carga IS NOT NULL
GROUP BY CUBE (e.grupo_muscular, e.nome)
ORDER BY e.grupo_muscular, e.nome;


-- ============================================================
-- ROLLUP
-- ============================================================

SELECT
    e.grupo_muscular,
    e.nome AS exercicio,
    SUM(te.carga) AS carga_total
FROM exercicio e
INNER JOIN treino_exercicio te ON te.exercicio_id = e.id
WHERE te.carga IS NOT NULL
GROUP BY ROLLUP (e.grupo_muscular, e.nome)
ORDER BY e.grupo_muscular, e.nome;

-- ============================================================
-- UNION
-- ============================================================

SELECT nome FROM aluno
UNION
SELECT nome FROM professor;

-- ============================================================
-- UNION ALL    
-- ============================================================

SELECT nome FROM aluno
UNION ALL
SELECT nome FROM professor;

-- ============================================================
-- INTERSECT   
-- ============================================================

WITH ativos AS (
	SELECT nome FROM aluno a
	INNER JOIN matricula m ON m.aluno_id = a.id
	WHERE m.status = 'ATIVA'
)
SELECT a.nome FROM aluno a
INNER JOIN matricula m ON m.aluno_id = a.id
INNER JOIN plano p ON m.plano_id = p.id
WHERE p.nome = 'Mensal'
intersect
SELECT nome FROM ativos;

-- ============================================================
-- EXCEPT
-- ============================================================

WITH ativos AS (
	SELECT nome FROM aluno a
	INNER JOIN matricula m ON m.aluno_id = a.id
	WHERE m.status = 'ATIVA'
)
SELECT nome FROM aluno a
INNER JOIN matricula m ON m.aluno_id = a.id
except
SELECT nome FROM ativos;


-- ============================================================
-- ANY
-- ============================================================

SELECT a.nome, p.nome AS plano FROM aluno a
INNER JOIN matricula m ON m.aluno_id = a.id
INNER JOIN plano p ON m.plano_id = p.id
WHERE p.valor > ANY (
	SELECT valor
	FROM plano
	WHERE valor <= 400
);

-- ============================================================
--ALL
-- ============================================================
SELECT a.nome, p.nome AS plano FROM aluno a
INNER JOIN matricula m ON m.aluno_id = a.id
INNER JOIN plano p ON m.plano_id = p.id
WHERE p.valor > ALL (
	SELECT valor
	FROM plano
	WHERE valor <= 400
);

-- ============================================================
-- WITH
-- ============================================================

WITH aluno_anual AS (
	SELECT a.id FROM aluno a
	INNER JOIN matricula m ON m.aluno_id = a.id
	INNER JOIN plano p ON m.plano_id = p.id
	WHERE p.nome = 'Anual'
)
select a.nome from aluno a
INNER JOIN aluno_anual ON a.id = aluno_anual.id;

-- ============================================================
-- WITH RECURSIVE
-- ============================================================

WITH RECURSIVE progressao_carga AS (
  
    SELECT 
        1 AS semana,
        40.0 AS carga_atual
    
    UNION ALL

    SELECT 
        semana + 1,
        carga_atual + 2.5
    FROM progressao_carga

    WHERE semana < 5
)
SELECT 
    semana,
    carga_atual AS carga_sugerida_kg
FROM progressao_carga;

-- ============================================================
-- FIM
-- ============================================================
