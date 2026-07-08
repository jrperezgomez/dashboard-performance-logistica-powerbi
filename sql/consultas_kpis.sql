-- KPIs Dashboard Operacional Logístico
-- PostgreSQL 12+
-- Author: José Pérez | Data: 2026

-- ============================================
-- KPI 1: Volume Total Processado
-- ============================================

SELECT
    SUM(f.volume) as volume_total,
    COUNT(*) as total_operacoes,
    ROUND(AVG(f.volume)::NUMERIC, 2) as volume_medio
FROM fato_operacoes f;

-- ============================================
-- KPI 2: Produtividade por Operador
-- ============================================

SELECT
    op.codigo_operador,
    op.nome_operador,
    SUM(f.volume) as volume_processado,
    SUM(f.tempo_processamento_minutos) as tempo_total_minutos,
    ROUND((SUM(f.volume)::NUMERIC / SUM(f.tempo_processamento_minutos)), 2) as items_por_minuto,
    COUNT(*) as total_operacoes,
    ROUND(AVG(f.acuracia_percentual)::NUMERIC, 2) as acuracia_media
FROM fato_operacoes f
JOIN dim_operador op ON f.id_operador = op.id_operador
GROUP BY op.id_operador, op.codigo_operador, op.nome_operador
ORDER BY items_por_minuto DESC;

-- ============================================
-- KPI 3: Acurácia Média por Turno
-- ============================================

SELECT
    t.nome_turno,
    ROUND(AVG(f.acuracia_percentual)::NUMERIC, 2) as acuracia_media,
    MIN(f.acuracia_percentual) as acuracia_minima,
    MAX(f.acuracia_percentual) as acuracia_maxima,
    COUNT(*) as total_operacoes
FROM fato_operacoes f
JOIN dim_turno t ON f.id_turno = t.id_turno
GROUP BY t.id_turno, t.nome_turno
ORDER BY acuracia_media DESC;

-- ============================================
-- KPI 4: Taxa de Divergência
-- ============================================

SELECT
    SUM(CASE WHEN f.divergencia = 1 THEN 1 ELSE 0 END) as total_divergencias,
    COUNT(*) as total_operacoes,
    ROUND(100.0 * SUM(CASE WHEN f.divergencia = 1 THEN 1 ELSE 0 END) /
          NULLIF(COUNT(*), 0), 2) as taxa_divergencia_percentual,
    ROUND(AVG(CASE WHEN f.divergencia = 1 THEN 1 ELSE 0 END), 4) as taxa_divergencia_decimal
FROM fato_operacoes f;

-- ============================================
-- KPI 5: SLA Cumprido (%)
-- ============================================

SELECT
    SUM(CASE WHEN f.sla_cumprido = 1 THEN 1 ELSE 0 END) as operacoes_sla_cumprido,
    COUNT(*) as total_operacoes,
    ROUND(100.0 * SUM(CASE WHEN f.sla_cumprido = 1 THEN 1 ELSE 0 END) /
          NULLIF(COUNT(*), 0), 2) as sla_cumprido_percentual
FROM fato_operacoes f;

-- ============================================
-- KPI 6: Tempo Médio de Processamento
-- ============================================

SELECT
    ROUND(AVG(f.tempo_processamento_minutos)::NUMERIC, 2) as tempo_medio_minutos,
    MIN(f.tempo_processamento_minutos) as tempo_minimo_minutos,
    MAX(f.tempo_processamento_minutos) as tempo_maximo_minutos,
    ROUND(STDDEV_POP(f.tempo_processamento_minutos)::NUMERIC, 2) as desvio_padrao
FROM fato_operacoes f;

-- ============================================
-- KPI 7: Performance por Categoria de Produto
-- ============================================

SELECT
    p.categoria,
    SUM(f.volume) as volume_total,
    COUNT(*) as operacoes,
    ROUND(AVG(f.acuracia_percentual)::NUMERIC, 2) as acuracia_media,
    ROUND(100.0 * SUM(CASE WHEN f.sla_cumprido = 1 THEN 1 ELSE 0 END) /
          NULLIF(COUNT(*), 0), 2) as sla_percentual,
    ROUND(100.0 * SUM(CASE WHEN f.divergencia = 1 THEN 1 ELSE 0 END) /
          NULLIF(COUNT(*), 0), 2) as taxa_divergencia
FROM fato_operacoes f
JOIN dim_produto p ON f.id_produto = p.id_produto
GROUP BY p.categoria
ORDER BY volume_total DESC;

-- ============================================
-- KPI 8: Status das Operaciónes
-- ============================================

SELECT
    f.status,
    COUNT(*) as total_operacoes,
    SUM(f.volume) as volume_total,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as percentual
FROM fato_operacoes f
GROUP BY f.status
ORDER BY total_operacoes DESC;
