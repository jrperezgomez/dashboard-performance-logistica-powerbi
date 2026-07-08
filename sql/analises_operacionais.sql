-- Análises Operacionais Avançadas
-- Dashboard Operacional Logístico
-- PostgreSQL 12+
-- Author: José Pérez | Data: 2026

-- ============================================
-- ANÁLISE 1: Gargalos por Turno (Volume vs Tempo)
-- ============================================

SELECT
    t.nome_turno,
    SUM(f.volume) as volume_processado,
    ROUND(AVG(f.tempo_processamento_minutos)::NUMERIC, 2) as tempo_medio_minutos,
    COUNT(*) as total_operacoes,
    ROUND((SUM(f.volume)::NUMERIC / COUNT(*)), 2) as volume_por_operacao,
    CASE WHEN AVG(f.tempo_processamento_minutos) > 60 THEN 'Alto Gargalo'
         WHEN AVG(f.tempo_processamento_minutos) > 40 THEN 'Médio Gargalo'
         ELSE 'Sem Gargalo' END as situacao_gargalo
FROM fato_operacoes f
JOIN dim_turno t ON f.id_turno = t.id_turno
GROUP BY t.id_turno, t.nome_turno
ORDER BY tempo_medio_minutos DESC;

-- ============================================
-- ANÁLISE 2: Comparação de Operadores (Eficiência)
-- ============================================

WITH ranking_operadores AS (
    SELECT
        op.id_operador,
        op.codigo_operador,
        op.nome_operador,
        SUM(f.volume) as volume_total,
        ROUND((SUM(f.volume)::NUMERIC / SUM(f.tempo_processamento_minutos)), 2) as items_minuto,
        ROUND(AVG(f.acuracia_percentual)::NUMERIC, 2) as acuracia_media,
        ROUND(100.0 * SUM(CASE WHEN f.sla_cumprido = 1 THEN 1 ELSE 0 END) /
              NULLIF(COUNT(*), 0), 2) as sla_percentual,
        ROW_NUMBER() OVER (ORDER BY SUM(f.volume)::NUMERIC / SUM(f.tempo_processamento_minutos) DESC) as rank_eficiencia
    FROM fato_operacoes f
    JOIN dim_operador op ON f.id_operador = op.id_operador
    GROUP BY op.id_operador, op.codigo_operador, op.nome_operador
)
SELECT
    rank_eficiencia as rank,
    codigo_operador,
    nome_operador,
    items_minuto,
    acuracia_media,
    sla_percentual,
    volume_total,
    CASE WHEN rank_eficiencia <= 5 THEN 'Top 5'
         WHEN rank_eficiencia <= 10 THEN 'Acima da Média'
         ELSE 'Abaixo da Média' END as classificacao
FROM ranking_operadores
ORDER BY rank_eficiencia;

-- ============================================
-- ANÁLISE 3: Divergências por Categoria
-- ============================================

SELECT
    p.categoria,
    SUM(CASE WHEN f.divergencia = 1 THEN 1 ELSE 0 END) as total_divergencias,
    COUNT(*) as total_operacoes,
    ROUND(100.0 * SUM(CASE WHEN f.divergencia = 1 THEN 1 ELSE 0 END) /
          NULLIF(COUNT(*), 0), 2) as taxa_divergencia_pct,
    STRING_AGG(DISTINCT p.nome_produto, ', ') as produtos_com_divergencia
FROM fato_operacoes f
JOIN dim_produto p ON f.id_produto = p.id_produto
WHERE f.divergencia = 1
GROUP BY p.categoria
ORDER BY taxa_divergencia_pct DESC;

-- ============================================
-- ANÁLISE 4: Tendência Semanal (Série Temporal)
-- ============================================

WITH semanas_dados AS (
    SELECT
        d.semana_ano,
        d.mes,
        SUM(f.volume) as volume_semanal,
        COUNT(*) as operacoes_semanal,
        ROUND(AVG(f.acuracia_percentual)::NUMERIC, 2) as acuracia_semanal,
        ROUND(100.0 * SUM(CASE WHEN f.sla_cumprido = 1 THEN 1 ELSE 0 END) /
              NULLIF(COUNT(*), 0), 2) as sla_semanal
    FROM fato_operacoes f
    JOIN dim_data d ON f.id_data = d.id_data
    GROUP BY d.semana_ano, d.mes
)
SELECT
    'Semana ' || semana_ano as semana,
    volume_semanal,
    operacoes_semanal,
    acuracia_semanal,
    sla_semanal,
    LAG(volume_semanal) OVER (ORDER BY semana_ano) as volume_semana_anterior,
    ROUND(((volume_semanal - LAG(volume_semanal) OVER (ORDER BY semana_ano))::NUMERIC /
           LAG(volume_semanal) OVER (ORDER BY semana_ano)) * 100, 2) as variacao_pct
FROM semanas_dados
ORDER BY semana_ano;

-- ============================================
-- ANÁLISE 5: Distribuição de Turno x Operador
-- ============================================

SELECT
    t.nome_turno,
    op.codigo_operador,
    COUNT(*) as total_operacoes,
    SUM(f.volume) as volume_total,
    ROUND(AVG(f.tempo_processamento_minutos)::NUMERIC, 2) as tempo_medio,
    ROUND(AVG(f.acuracia_percentual)::NUMERIC, 2) as acuracia_media
FROM fato_operacoes f
JOIN dim_turno t ON f.id_turno = t.id_turno
JOIN dim_operador op ON f.id_operador = op.id_operador
GROUP BY t.id_turno, t.nome_turno, op.id_operador, op.codigo_operador
ORDER BY t.nome_turno, volume_total DESC;

-- ============================================
-- ANÁLISE 6: Correlação Status x SLA
-- ============================================

SELECT
    f.status,
    COUNT(*) as total_operacoes,
    SUM(CASE WHEN f.sla_cumprido = 1 THEN 1 ELSE 0 END) as sla_cumprido,
    SUM(CASE WHEN f.sla_cumprido = 0 THEN 1 ELSE 0 END) as sla_nao_cumprido,
    ROUND(100.0 * SUM(CASE WHEN f.sla_cumprido = 1 THEN 1 ELSE 0 END) /
          NULLIF(COUNT(*), 0), 2) as sla_percentual,
    ROUND(AVG(f.acuracia_percentual)::NUMERIC, 2) as acuracia_media
FROM fato_operacoes f
GROUP BY f.status
ORDER BY sla_percentual DESC;

-- ============================================
-- ANÁLISE 7: Produtos Críticos (Baixa Acurácia)
-- ============================================

WITH produtos_criticos AS (
    SELECT
        p.nome_produto,
        p.categoria,
        COUNT(*) as total_operacoes,
        ROUND(AVG(f.acuracia_percentual)::NUMERIC, 2) as acuracia_media,
        SUM(CASE WHEN f.divergencia = 1 THEN 1 ELSE 0 END) as divergencias,
        ROUND(100.0 * SUM(CASE WHEN f.sla_cumprido = 1 THEN 1 ELSE 0 END) /
              NULLIF(COUNT(*), 0), 2) as sla_pct
    FROM fato_operacoes f
    JOIN dim_produto p ON f.id_produto = p.id_produto
    GROUP BY p.id_produto, p.nome_produto, p.categoria
    HAVING AVG(f.acuracia_percentual) < 90 OR SUM(CASE WHEN f.divergencia = 1 THEN 1 ELSE 0 END) > 2
)
SELECT
    nome_produto,
    categoria,
    total_operacoes,
    acuracia_media,
    divergencias,
    sla_pct,
    CASE WHEN acuracia_media < 80 THEN 'Crítico'
         WHEN acuracia_media < 90 THEN 'Atenção'
         ELSE 'Normal' END as nivel_risco
FROM produtos_criticos
ORDER BY acuracia_media ASC;
