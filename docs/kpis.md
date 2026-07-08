# KPIs - Dashboard Operacional Logístico

## 1. Volume Processado

**Nome**: Total Volume

**Fórmula SQL**:
```sql
SUM(fato_operacoes.volume)
```

**Objetivo**: Medir total de unidades movimentadas no período

**Interpretação**:
- Meta: 10.000+ itens/dia
- Red flag: < 5.000 itens/dia

---

## 2. Produtividade

**Nome**: Items por Minuto

**Fórmula SQL**:
```sql
SUM(fato_operacoes.volume) / SUM(fato_operacoes.tempo_processamento_minutos)
```

**Objetivo**: Eficiência operacional por tempo gasto

**Interpretação**:
- Excelente: > 3 items/min
- Bom: 2-3 items/min
- Ruim: < 2 items/min

---

## 3. Acurácia Média

**Nome**: Acurácia %

**Fórmula SQL**:
```sql
AVG(fato_operacoes.acuracia_percentual)
```

**Objetivo**: Qualidade geral das operações

**Interpretação**:
- Alvo: 98%+
- Aceitável: 95-97%
- Crítico: < 95%

---

## 4. Taxa de Divergência

**Nome**: Erros %

**Fórmula SQL**:
```sql
100 * SUM(CASE WHEN fato_operacoes.divergencia = 1 THEN 1 ELSE 0 END) / COUNT(*)
```

**Objetivo**: % operações com erro detectado

**Interpretação**:
- Excelente: < 2%
- Normal: 2-5%
- Crítico: > 5%

---

## 5. SLA Cumprido

**Nome**: SLA %

**Fórmula SQL**:
```sql
100 * SUM(CASE WHEN fato_operacoes.sla_cumprido = 1 THEN 1 ELSE 0 END) / COUNT(*)
```

**Objetivo**: % operações dentro do prazo

**Interpretação**:
- Meta: 95%+
- Aceitável: 90-95%
- Crítico: < 90%

---

## 6. Tempo Médio de Processamento

**Nome**: Tempo Médio (min)

**Fórmula SQL**:
```sql
AVG(fato_operacoes.tempo_processamento_minutos)
```

**Objetivo**: Ciclo médio por operação

**Interpretação**:
- Baseado em categoria
- Eletrônicos: ~45 min
- Vestuário: ~25 min
- Alimentos: ~30 min

---

## Dashboards Sugeridos

### Página 1: Visão Executiva

- KPI: Volume Total
- KPI: Produtividade
- KPI: Acurácia
- Gráfico: Série temporal volume
- Gráfico: SLA trending

### Página 2: Produtividade

- Tabela: Ranking operadores
- Gráfico: Tempo por operador
- Gráfico: Volume por turno
- Card: Top operador

### Página 3: Qualidade

- Gráfico: Taxa divergência por categoria
- Tabela: Produtos críticos
- Gráfico: Acurácia trending
- Card: Erros total

### Página 4: Tendências

- Série temporal: Volume semanal
- Série temporal: Acurácia semanal
- Gráfico: Performance comparativa turnos
- Heatmap: Operador x Turno
