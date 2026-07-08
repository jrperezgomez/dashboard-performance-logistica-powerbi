-- Data Seed: Dashboard Operacional Logístico
-- Inserts para simular 500 operaciónes en 90 días
-- PostgreSQL 12+

-- ============================================
-- DIMENSIÓN: Datas (90 días: 01/04 a 30/06/2026)
-- ============================================

INSERT INTO dim_data (data_completa, ano, mes, dia, trimestre, nome_mes, nome_dia_semana, semana_ano)
SELECT DISTINCT
    CAST(data_completa AS DATE) as data_completa,
    EXTRACT(YEAR FROM data_completa)::INT as ano,
    EXTRACT(MONTH FROM data_completa)::INT as mes,
    EXTRACT(DAY FROM data_completa)::INT as dia,
    CASE WHEN EXTRACT(MONTH FROM data_completa) <= 3 THEN 1
         WHEN EXTRACT(MONTH FROM data_completa) <= 6 THEN 2
         WHEN EXTRACT(MONTH FROM data_completa) <= 9 THEN 3
         ELSE 4 END as trimestre,
    TO_CHAR(data_completa, 'Month') as nome_mes,
    TO_CHAR(data_completa, 'Day') as nome_dia_semana,
    EXTRACT(WEEK FROM data_completa)::INT as semana_ano
FROM generate_series('2026-04-01'::DATE, '2026-06-30'::DATE, '1 day'::INTERVAL) as data_completa
ON CONFLICT DO NOTHING;

-- ============================================
-- DIMENSIÓN: Productos
-- ============================================

INSERT INTO dim_produto (nome_produto, categoria, peso_kg) VALUES
('Notebook', 'Eletrônicos', 1.50),
('Mouse', 'Eletrônicos', 0.10),
('Camiseta', 'Vestuário', 0.25),
('Calça', 'Vestuário', 0.50),
('Arroz', 'Alimentos', 2.00),
('Feijão', 'Alimentos', 1.50),
('Sabonete', 'Higiene', 0.10),
('Detergente', 'Limpeza', 0.50),
('Cadeira', 'Mobiliário', 5.00),
('Mesa', 'Mobiliário', 15.00),
('Papel A4', 'Papelaria', 2.50),
('Tinta Impressora', 'Eletrônicos', 0.20)
ON CONFLICT DO NOTHING;

-- ============================================
-- DIMENSIÓN: Operadores (20 operadores)
-- ============================================

INSERT INTO dim_operador (codigo_operador, nome_operador, experiencia_meses, treinado) VALUES
('OP001', 'Anderson Silva', 36, TRUE),
('OP002', 'Beatriz Costa', 24, TRUE),
('OP003', 'Carlos Mendes', 18, TRUE),
('OP004', 'Diana Rocha', 12, TRUE),
('OP005', 'Eduardo Santos', 48, TRUE),
('OP006', 'Fernanda Oliveira', 8, TRUE),
('OP007', 'Gabriel Lima', 30, TRUE),
('OP008', 'Helena Ribeiro', 15, TRUE),
('OP009', 'Igor Pereira', 6, TRUE),
('OP010', 'Julia Martins', 42, TRUE),
('OP011', 'Kevin Alves', 9, TRUE),
('OP012', 'Larissa Gomes', 27, TRUE),
('OP013', 'Marcos Ferreira', 20, TRUE),
('OP014', 'Natalia Souza', 14, TRUE),
('OP015', 'Otavio Barbosa', 35, TRUE),
('OP016', 'Patricia Dias', 11, TRUE),
('OP017', 'Quincy Miranda', 28, TRUE),
('OP018', 'Rafael Teixeira', 5, FALSE),
('OP019', 'Sandra Moreira', 38, TRUE),
('OP020', 'Thiago Carvalho', 16, TRUE)
ON CONFLICT DO NOTHING;

-- ============================================
-- DIMENSIÓN: Turnos
-- ============================================

INSERT INTO dim_turno (nome_turno, hora_inicio, hora_fim) VALUES
('Matutino', '06:00:00', '14:00:00'),
('Vespertino', '14:00:00', '22:00:00'),
('Noturno', '22:00:00', '06:00:00')
ON CONFLICT DO NOTHING;

-- ============================================
-- FATO: Operações (Populate com 500 registros simulados)
-- ============================================

-- Inserts aleatorios generados desde CSV
-- Este é um ejemplo - em produção, usar COPY FROM csv

INSERT INTO fato_operacoes (id_data, id_operador, id_turno, id_produto, volume, tempo_processamento_minutos, status, divergencia, acuracia_percentual, sla_cumprido)
SELECT
    d.id_data,
    (ABS(HASHTEXT(CONCAT(d.data_completa, 'OP'))) % 20) + 1 as id_operador,
    (ABS(HASHTEXT(CONCAT(d.data_completa, 'TURNO'))) % 3) + 1 as id_turno,
    (ABS(HASHTEXT(CONCAT(d.data_completa, 'PROD'))) % 12) + 1 as id_produto,
    (ABS(HASHTEXT(CONCAT(d.data_completa, 'VOL'))) % 490) + 10 as volume,
    (ABS(HASHTEXT(CONCAT(d.data_completa, 'TEMPO'))) % 175) + 5 as tempo_processamento_minutos,
    CASE WHEN (ABS(HASHTEXT(CONCAT(d.data_completa, 'STATUS'))) % 100) < 85 THEN 'Completado'
         WHEN (ABS(HASHTEXT(CONCAT(d.data_completa, 'STATUS'))) % 100) < 95 THEN 'Com_Erro'
         ELSE 'Incompleto' END as status,
    CASE WHEN (ABS(HASHTEXT(CONCAT(d.data_completa, 'DIV'))) % 100) < 5 THEN 1 ELSE 0 END as divergencia,
    CASE WHEN (ABS(HASHTEXT(CONCAT(d.data_completa, 'DIV'))) % 100) < 5
         THEN (ABS(HASHTEXT(CONCAT(d.data_completa, 'ACC'))) % 16) + 75
         ELSE (ABS(HASHTEXT(CONCAT(d.data_completa, 'ACC'))) % 6) + 95 END as acuracia_percentual,
    CASE WHEN (ABS(HASHTEXT(CONCAT(d.data_completa, 'SLA'))) % 100) < 90 THEN 1 ELSE 0 END as sla_cumprido
FROM dim_data d
WHERE d.data_completa BETWEEN '2026-04-01' AND '2026-06-30'
LIMIT 500
ON CONFLICT DO NOTHING;

-- ============================================
-- VALIDACIÓN POST-INSERT
-- ============================================

-- Verificar inserts
SELECT 'dim_data' as tabla, COUNT(*) as registros FROM dim_data
UNION ALL
SELECT 'dim_produto', COUNT(*) FROM dim_produto
UNION ALL
SELECT 'dim_operador', COUNT(*) FROM dim_operador
UNION ALL
SELECT 'dim_turno', COUNT(*) FROM dim_turno
UNION ALL
SELECT 'fato_operacoes', COUNT(*) FROM fato_operacoes;
