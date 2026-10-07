
select * from mvw_exercicios_mais_utilizados;

drop materialized view mvw_exercicios_mais_utilizados;

CREATE MATERIALIZED VIEW mvw_exercicios_mais_utilizados AS
SELECT
    e.id AS exercicio_id,
    e.nome AS exercicio_nome,
    COUNT(te.treino_id) AS frequencia_de_utilizacao
FROM exercicio e
INNER JOIN treino_exercicio te ON te.exercicio_id = e.id
GROUP BY e.id, e.nome
ORDER BY frequencia_de_utilizacao DESC;