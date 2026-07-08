-- Análises Operacionais para o Dashboard de Performance Logística
-- Cenário simulado - Projeto de Portfólio
-- Author: José Pérez | Data: 2026

-- Análise 1: Eficiência de Entrega por Região
SELECT 
    c.regiao,
    COUNT(DISTINCT e.id_entrega) AS total_entregas,
    AVG(e.tempo_entrega_dias) AS tempo_medio,
    COUNT(CASE WHEN e.tempo_entrega_dias <= 3 THEN 1 END) * 100.0 / COUNT(*) AS pct_no_prazo
FROM entregas e
JOIN pedidos p ON e.id_pedido = p.id_pedido
JOIN clientes c ON p.cliente_id = c.id_cliente
WHERE e.status_entrega = 'Entregue'
GROUP BY c.regiao;

-- Análise 2: Rotatividade de Estoque
SELECT 
    pr.categoria,
    COUNT(DISTINCT pr.id_produto) AS total_produtos,
    SUM(e.quantidade) AS estoque_total,
    AVG(e.quantidade) AS estoque_medio
FROM estoque e
JOIN produtos pr ON e.id_produto = pr.id_produto
GROUP BY pr.categoria;

-- Análise 3: Tendência de Vendas por Mês
SELECT 
    DATE_TRUNC('month', p.data_pedido) AS mes,
    COUNT(p.id_pedido) AS total_pedidos,
    SUM(p.valor_total) AS receita,
    AVG(p.valor_total) AS ticket_medio
FROM pedidos p
WHERE p.status != 'Cancelado'
GROUP BY DATE_TRUNC('month', p.data_pedido)
ORDER BY mes DESC;

-- Análise 4: Clientes Top 10 por Receita
SELECT 
    c.nome_cliente,
    c.regiao,
    COUNT(p.id_pedido) AS total_pedidos,
    SUM(p.valor_total) AS receita_total,
    AVG(p.valor_total) AS ticket_medio
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
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM pedidos) AS percentual
FROM pedidos
GROUP BY CASE WHEN status = 'Cancelado' THEN 'Cancelado' ELSE 'Não Cancelado' END;
