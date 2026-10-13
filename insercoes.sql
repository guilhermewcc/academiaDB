INSERT INTO aluno (nome, cpf, data_nascimento, telefone, email)
VALUES ('Fulano', '33474784013', '2001-01-01', '(63)98765-4321', 'fulano@email.com');


INSERT INTO plano (nome, valor, duracao_dias)
VALUES
    ('Semanal', 29.97, 7),
    ('Mensal', 39.97, 30),
    ('Anual', 119.90, 365);

INSERT INTO professor (nome, cpf, telefone, email)
VALUES ('João', '12345678909', '(11) 4002-8922', 'joaoednutri@email.com');


INSERT INTO exercicio (nome, grupo_muscular, descricao)
VALUES
    ('Supino reto', 'Peito', 'Exercício para peitoral'),
    ('Agachamento', 'Pernas', 'Exercício para membros inferiores'),
    ('Puxada frontal', 'Costas', 'Tração vertical realizada em máquinas ou polias');


INSERT INTO matricula (aluno_id, plano_id, data_inicio, data_fim)
VALUES (1, 2, '2026-09-26', '2026-10-26');
\end{lstlisting}


INSERT INTO treino (matricula_id, professor_id, nome, objetivo)
VALUES (1, 1, 'Treino A - Peito e Tríceps', 'Hipertrofia de peito e tríceps');


INSERT INTO treino_exercicio (treino_id, exercicio_id, series, repeticoes, carga, descanso_segundos)
VALUES (1, 3, 3, 12, 20.00, 60);
