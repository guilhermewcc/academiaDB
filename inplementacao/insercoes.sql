INSERT INTO aluno (nome, cpf, data_nascimento, telefone, email) VALUES
('Ana Silva',      '11111111101', '2000-03-15', '63990000001', 'ana@academia.com'),
('Bruno Souza',    '11111111102', '1998-07-22', '63990000002', 'bruno@academia.com'),
('Carla Oliveira', '11111111103', '2002-11-10', '63990000003', 'carla@academia.com'),
('Diego Santos',   '11111111104', '1995-01-30', '63990000004', 'diego@academia.com'),
('Elisa Costa',    '11111111105', '2001-09-05', '63990000005', 'elisa@academia.com'),
('Felipe Lima',    '11111111106', '1997-05-18', '63990000006', 'felipe@academia.com');

INSERT INTO plano (nome, valor, duracao_dias) VALUES
('Mensal',      100.00, 30),
('Trimestral',  270.00, 90),
('Semestral',   480.00, 180),
('Anual',       840.00, 365);

INSERT INTO professor (nome, cpf, telefone, email) VALUES
('Carlos Mendes', '22222222201', '63991111101', 'carlos@academia.com'),
('Juliana Alves', '22222222202', '63991111102', 'juliana@academia.com'),
('Marcos Rocha',  '22222222203', '63991111103', 'marcos@academia.com');

INSERT INTO exercicio (nome, grupo_muscular, descricao) VALUES
('Supino reto',       'Peito',      'Exercício para peitoral maior.'),
('Agachamento livre', 'Pernas',     'Exercício composto para membros inferiores.'),
('Puxada frontal',    'Costas',     'Exercício para dorsais.'),
('Rosca direta',      'Bíceps',     'Exercício para bíceps.'),
('Tríceps pulley',    'Tríceps',    'Exercício para tríceps.'),
('Elevação lateral',  'Ombros',     'Exercício para deltoides.'),
('Leg press',         'Pernas',     'Exercício para quadríceps e glúteos.'),
('Abdominal',         'Abdômen',    'Exercício para musculatura abdominal.');

-- Um aluno pode ter uma matrícula ATIVA e também matrículas antigas
-- FINALIZADAS/CANCELADAS.
INSERT INTO matricula (aluno_id, plano_id, data_inicio, data_fim, status) VALUES
(1, 1, '2026-01-10', NULL,       'ATIVA'),
(2, 2, '2026-02-01', NULL,       'ATIVA'),
(3, 3, '2025-09-01', '2026-02-28', 'FINALIZADA'),
(4, 1, '2026-03-05', NULL,       'ATIVA'),
(5, 4, '2026-01-15', NULL,       'ATIVA'),
(6, 1, '2025-10-01', '2025-10-20', 'CANCELADA');

INSERT INTO treino (matricula_id, professor_id, nome, objetivo, data_criacao) VALUES
(1, 1, 'Treino A', 'Hipertrofia de membros superiores', '2026-01-11'),
(1, 2, 'Treino B', 'Fortalecimento de membros inferiores', '2026-01-12'),
(2, 1, 'Treino A', 'Hipertrofia geral', '2026-02-02'),
(3, 3, 'Treino A', 'Condicionamento físico', '2025-09-02'),
(4, 2, 'Treino A', 'Hipertrofia', '2026-03-06'),
(5, 3, 'Treino A', 'Força', '2026-01-16');

INSERT INTO treino_exercicio
    (treino_id, exercicio_id, series, repeticoes, carga, descanso_segundos)
VALUES
(1, 1, 4, 10, 60.00, 90),
(1, 4, 3, 12, 25.00, 60),
(1, 5, 3, 12, 30.00, 60),
(2, 2, 4, 10, 80.00, 120),
(2, 7, 3, 12, 100.00, 120),
(3, 1, 4, 8,  70.00, 90),
(3, 3, 4, 10, 55.00, 90),
(4, 6, 3, 15, 10.00, 60),
(5, 2, 4, 8,  90.00, 120),
(5, 8, 3, 20, 0.00, 45),
(6, 3, 4, 8,  60.00, 90),
(6, 7, 4, 10, 110.00, 120);