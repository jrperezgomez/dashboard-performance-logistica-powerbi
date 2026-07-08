-- Consultas KPI para o Dashboard de Performance Logística
-- Cenário simulado - Projeto de Portfólio
-- Author: José Pérez | Data: 2026

-- KPI 1: Taxa de Entrega no Prazo
SELECT 
    COUNT(CASE WHEN tempo_entrega_dias <= 3 THEN 1 END) * 100.0 / COUNT(*) AS taxa_entrega_prazo_pct
FROM entregas
WHERE status_entrega = 'Entregue';

-- KPI 2: Tempo Médio de Entrega
SELECT 
    AVG(tempo_entrega_dias) AS tempo_medio_entrega_dias,
    MIN(tempo_entrega_dias) AS min_dias,
    MAX(tempo_entrega_dias) AS max_dias
FROM entregas;

-- KPI 3: Receita Total por Região
SELECT 
    c.regiao,
    SUM(p.valor_total) AS receita_total,
    COUNT(DISTINCT p.cliente_id) AS total_clientes,
    SUM(p.valor_total) / COUNT(DISTINCT p.cliente_id) AS ticket_medio
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id_cliente
GROUP BY c.regiao
ORDER BY receita_total DESC;

-- KPI 4: Status dos Pedidos
SELECT 
    status,
    COUNT(*) AS total_pedidos,
    SUM(valor_total) AS valor_total_status
FROM pedidos
GROUP BY status;

-- KPI 5: Disponível vs Não Disponível em Estoque
SELECT 
    COUNT(CASE WHEN quantidade > 0 THEN 1 END) AS produtos_disponiveis,
    COUNT(CASE WHEN quantidade = 0 THEN 1 END) AS produtos_indisponiveis,
    COUNT(*) AS total_skus
FROM estoque;
