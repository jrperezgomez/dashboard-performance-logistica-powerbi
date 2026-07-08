-- Consultas KPI para o Dashboard de Performance Logística
-- Cenário simulado - Projeto de Portfólio
-- PostgreSQL 12+
-- Author: José Pérez | Data: 2026

-- KPI 1: Taxa de Entrega no Prazo (%)
SELECT
    ROUND(COUNT(CASE WHEN tempo_entrega_dias <= 3 THEN 1 END) * 100.0 /
          NULLIF(COUNT(*), 0), 2) AS taxa_entrega_prazo_pct
FROM entregas
WHERE status_entrega = 'Entregue' AND data_entrega IS NOT NULL;

-- KPI 2: Tempo Médio de Entrega
SELECT
    ROUND(AVG(tempo_entrega_dias)::numeric, 2) AS tempo_medio_entrega_dias,
    MIN(tempo_entrega_dias) AS min_dias,
    MAX(tempo_entrega_dias) AS max_dias
FROM entregas
WHERE data_entrega IS NOT NULL;

-- KPI 3: Receita Total por Região
SELECT
    c.regiao,
    ROUND(SUM(p.valor_total)::numeric, 2) AS receita_total,
    COUNT(DISTINCT p.cliente_id) AS total_clientes,
    ROUND((SUM(p.valor_total) / COUNT(DISTINCT p.cliente_id))::numeric, 2) AS ticket_medio
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id_cliente
GROUP BY c.regiao
ORDER BY receita_total DESC NULLS LAST;

-- KPI 4: Status dos Pedidos
SELECT
    status,
    COUNT(*) AS total_pedidos,
    ROUND(SUM(valor_total)::numeric, 2) AS valor_total_status
FROM pedidos
GROUP BY status
ORDER BY total_pedidos DESC;

-- KPI 5: Disponível vs Não Disponível em Estoque
SELECT
    COUNT(CASE WHEN quantidade > 0 THEN 1 END) AS produtos_disponiveis,
    COUNT(CASE WHEN quantidade = 0 THEN 1 END) AS produtos_indisponiveis,
    COUNT(*) AS total_skus,
    ROUND(100.0 * COUNT(CASE WHEN quantidade > 0 THEN 1 END) /
          NULLIF(COUNT(*), 0), 2) AS taxa_disponibilidade_pct
FROM estoque;
