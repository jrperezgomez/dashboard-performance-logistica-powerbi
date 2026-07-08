# Medidas DAX - Dashboard de Performance Logística

## Visão Geral

Este documento descreve exemplos de medidas DAX para implementação no Power BI. Cada medida foi projetada para suportar análises operacionais de performance logística.

---

## Medidas de Volume e Receita

### 1. Total de Pedidos

```dax
Total Pedidos = COUNTA(pedidos[id_pedido])
```

**Uso**: KPI principal - número absoluto de pedidos processados.

---

### 2. Receita Total

```dax
Receita Total = SUM(pedidos[valor_total])
```

**Uso**: Análise de faturamento por período, região, categoria.

---

### 3. Ticket Médio

```dax
Ticket Médio = AVERAGEX(pedidos, pedidos[valor_total])
```

**Uso**: Indicador de valor médio por transação.

---

### 4. Receita por Região

```dax
Receita por Região = 
SUMIF(
    pedidos,
    pedidos[cliente_id],
    clientes[regiao] = SELECTEDVALUE(clientes[regiao])
)
```

**Uso**: Comparação de desempenho entre regiões.

---

## Medidas de Performance Logística

### 5. Taxa de Entrega no Prazo (%)

```dax
Taxa Entrega Prazo = 
VAR TotalEntregues = 
    COUNTIF(entregas, entregas[status_entrega] = "Entregue")
VAR NoPrazo = 
    COUNTIF(entregas, 
        (entregas[status_entrega] = "Entregue") && 
        (entregas[tempo_entrega_dias] <= 3))
RETURN
    IF(TotalEntregues = 0, 0, DIVIDE(NoPrazo, TotalEntregues, 0) * 100)
```

**Uso**: KPI crítico - avaliar cumprimento de SLA.

**Interpretação**:
- 100% = Todas entregas dentro do prazo (≤ 3 dias)
- Meta típica: 95%+

---

### 6. Tempo Médio de Entrega (dias)

```dax
Tempo Médio Entrega = 
AVERAGEX(
    FILTER(entregas, entregas[status_entrega] = "Entregue"),
    entregas[tempo_entrega_dias]
)
```

**Uso**: Benchmark de eficiência logística.

---

### 7. Entregas Pendentes

```dax
Entregas Pendentes = 
COUNTIF(entregas, entregas[status_entrega] = "Pendente")
```

**Uso**: Monitoramento de backlog.

---

### 8. Entregas Canceladas

```dax
Entregas Canceladas = 
COUNTIF(entregas, entregas[status_entrega] = "Cancelado")
```

**Uso**: Análise de anomalias e retrabalho.

---

### 9. Cumprimento SLA

```dax
Cumprimento SLA = 
VAR TaxaPrazo = [Taxa Entrega Prazo]
VAR SLAMeta = 95 -- 95% é meta padrão
RETURN
    IF(TaxaPrazo >= SLAMeta, 
        "✓ Cumprido", 
        "✗ Não Cumprido")
```

**Uso**: Semáforo visual de performance.

---

## Medidas de Estoque

### 10. Produtos Disponíveis

```dax
Produtos Disponíveis = 
COUNTIF(estoque, estoque[quantidade] > 0)
```

**Uso**: Monitoramento de disponibilidade de SKUs.

---

### 11. Produtos Indisponíveis

```dax
Produtos Indisponíveis = 
COUNTIF(estoque, estoque[quantidade] = 0)
```

**Uso**: Identificar stock-outs críticos.

---

### 12. Taxa de Disponibilidade (%)

```dax
Taxa Disponibilidade = 
VAR Disponiveis = [Produtos Disponíveis]
VAR Total = COUNTA(estoque[id_estoque])
RETURN
    IF(Total = 0, 0, DIVIDE(Disponiveis, Total, 0) * 100)
```

**Uso**: KPI de saúde geral do inventário.

**Meta típica**: 95%+

---

### 13. Estoque Total (unidades)

```dax
Estoque Total = SUM(estoque[quantidade])
```

**Uso**: Volume agregado em armazém.

---

### 14. Estoque Médio por Produto

```dax
Estoque Médio = 
AVERAGEX(estoque, estoque[quantidade])
```

**Uso**: Análise de distribuição de estoque.

---

## Medidas de Análise Comparativa

### 15. Índice de Desempenho Regional

```dax
Índice Desempenho = 
VAR ReceitaRegiao = [Receita por Região]
VAR ReceitaMedia = 
    AVERAGEX(
        VALUES(clientes[regiao]), 
        [Receita por Região]
    )
RETURN
    IF(ReceitaMedia = 0, 0, DIVIDE(ReceitaRegiao, ReceitaMedia, 0))
```

**Uso**: Comparar performance de cada região contra a média.

**Interpretação**:
- > 1.0 = Acima da média
- = 1.0 = Alinhado com média
- < 1.0 = Abaixo da média

---

### 16. Variação Receita YoY

```dax
Receita YoY = 
VAR RecejaAtual = [Receita Total]
VAR ReceitaAnoAnt = 
    CALCULATE(
        [Receita Total],
        DATEADD(clientes[data_cadastro], -1, YEAR)
    )
RETURN
    IF(ReceitaAnoAnt = 0, 0, 
        DIVIDE(RecejaAtual - ReceitaAnoAnt, ReceitaAnoAnt, 0) * 100
    )
```

**Uso**: Tendência de crescimento anual.

---

## Medidas de Análise por Status

### 17. Pedidos Confirmados

```dax
Pedidos Confirmados = 
COUNTIF(pedidos, pedidos[status] = "Confirmado")
```

---

### 18. Pedidos Cancelados

```dax
Pedidos Cancelados = 
COUNTIF(pedidos, pedidos[status] = "Cancelado")
```

---

### 19. Taxa de Cancelamento (%)

```dax
Taxa Cancelamento = 
VAR Cancelados = [Pedidos Cancelados]
VAR Total = [Total Pedidos]
RETURN
    IF(Total = 0, 0, DIVIDE(Cancelados, Total, 0) * 100)
```

**Interpretação**:
- Baixo (< 5%) = Saudável
- Moderado (5-10%) = Monitorar
- Alto (> 10%) = Investigar

---

## Guia de Implementação

### Passos no Power BI Desktop

1. **Abrir Power BI Desktop**
2. **Ir a**: Home → New Measure
3. **Copiar fórmula DAX** do exemplo
4. **Nomeação**: Usar nomes descritivos (ex: "Taxa Entrega Prazo")
5. **Validar**: Verificar ausência de erros de sintaxe
6. **Testar**: Arrastar medida para card/visual e validar resultado
7. **Repetir**: Para cada medida desejada

### Melhores Práticas

- **Namespaces**: Agrupar medidas em pastas por tipo
- **Documentação**: Adicionar comentários com contexto
- **Performance**: Usar CALCULATE com cuidado em grandes datasets
- **Validação**: Testar contra queries SQL equivalentes

---

## Exemplos de Cards e Visuais

### Card KPI

```
[Taxa Entrega Prazo]
Cor: Verde se >= 95%, Vermelho se < 90%
Formato: 0.00%
```

### Gráfico de Barras

```
Eixo X: clientes[regiao]
Eixo Y: [Receita por Região]
Legenda: Status de pedidos
```

### Tabela de Análise

```
Colunas:
- clientes[regiao]
- [Total Pedidos]
- [Receita Total]
- [Ticket Médio]
- [Taxa Entrega Prazo]
```

---

## Notas

- Medidas foram otimizadas para dataset de ~30 clientes (dataset simulado)
- Em datasets maiores (> 1M linhas), considerar tabelas pré-agregadas
- DAX Studio pode ser usado para profiling e otimização
- Todas as medidas usam sintaxe nativa do Power BI (sem extensões)

