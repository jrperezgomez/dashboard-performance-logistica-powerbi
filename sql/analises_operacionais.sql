-- Análises Operacionais para o Dashboard de Performance Logística
-- Cenário simulado - Projeto de Portfólio
-- PostgreSQL 12+
-- Author: José Pérez | Data: 2026

-- Análise 1: Eficiência de Entrega por Região
SELECT
    c.regiao,
    COUNT(DISTINCT e.id_entrega) AS total_entregas,
    ROUND(AVG(e.tempo_entrega_dias)::numeric, 2) AS tempo_medio,
    ROUND(COUNT(CASE WHEN e.tempo_entrega_dias <= 3 THEN 1 END) * 100.0 /
          NULLIF(COUNT(*), 0), 2) AS pct_no_prazo
FROM entregas e
JOIN pedidos p ON e.id_pedido = p.id_pedido
JOIN clientes c ON p.cliente_id = c.id_cliente
WHERE e.status_entrega = 'Entregue' AND e.data_entrega IS NOT NULL
GROUP BY c.regiao
ORDER BY tempo_medio ASC;

-- Análise 2: Rotatividade de Estoque
SELECT
    pr.categoria,
    COUNT(DISTINCT pr.id_produto) AS total_produtos,
    SUM(e.quantidade) AS estoque_total,
    ROUND(AVG(e.quantidade)::numeric, 2) AS estoque_medio
FROM estoque e
JOIN produtos pr ON e.id_produto = pr.id_produto
GROUP BY pr.categoria
ORDER BY estoque_total DESC;

-- Análise 3: Tendência de Vendas por Mês
SELECT
    DATE_TRUNC('month', p.data_pedido)::DATE AS mes,
    COUNT(p.id_pedido) AS total_pedidos,
    ROUND(SUM(p.valor_total)::numeric, 2) AS receita,
    ROUND(AVG(p.valor_total)::numeric, 2) AS ticket_medio
FROM pedidos p
WHERE p.status != 'Cancelado'
GROUP BY DATE_TRUNC('month', p.data_pedido)
ORDER BY mes DESC;

-- Análise 4: Clientes Top 10 por Receita
SELECT
    c.nome_cliente,
    c.regiao,
    COUNT(p.id_pedido) AS total_pedidos,
    ROUND(SUM(p.valor_total)::numeric, 2) AS receita_total,
    ROUND(AVG(p.valor_total)::numeric, 2) AS ticket_medio
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id_cliente
WHERE p.status = 'Confirmado'
GROUP BY c.id_cliente, c.nome_cliente, c.regiao
ORDER BY receita_total DESC
LIMIT 10;

-- Análise 5: Taxa de Cancelamento de Pedidos
SELECT
    CASE WHEN status = 'Cancelado' THEN 'Cancelado' ELSE 'Não Cancelado' END AS categoria,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM pedidos), 2) AS percentual
FROM pedidos
GROUP BY CASE WHEN status = 'Cancelado' THEN 'Cancelado' ELSE 'Não Cancelado' END;
