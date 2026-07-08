# Medidas DAX - Dashboard Operacional Logístico

## Medidas Básicas de Volume

### Total Volume
```dax
Total Volume = SUM(fato_operacoes[volume])
```
Total unidades processadas.

### Volume Médio
```dax
Volume Médio = AVERAGE(fato_operacoes[volume])
```
Média de unidades por operação.

---

## Medidas de Produtividade

### Items por Minuto
```dax
Items por Minuto = 
SUM(fato_operacoes[volume]) / 
SUM(fato_operacoes[tempo_processamento_minutos])
```
Eficiência: unidades/minuto.

### Tempo Médio
```dax
Tempo Médio = AVERAGE(fato_operacoes[tempo_processamento_minutos])
```
Ciclo médio em minutos.

### Produtividade Operador
```dax
Produtividade Operador = 
VAR VolumeOp = SUM(fato_operacoes[volume])
VAR TempoOp = SUM(fato_operacoes[tempo_processamento_minutos])
RETURN
  IF(TempoOp = 0, 0, DIVIDE(VolumeOp, TempoOp, 0))
```
Produtividade por operador selecionado.

---

## Medidas de Qualidade

### Acurácia Média
```dax
Acurácia Média = AVERAGE(fato_operacoes[acuracia_percentual])
```
% acertos em operações.

### Divergências Totais
```dax
Divergências Totais = 
COUNTIF(fato_operacoes[divergencia], 1)
```
Count de erros detectados.

### Taxa Divergência %
```dax
Taxa Divergência = 
VAR Divergencias = COUNTIF(fato_operacoes[divergencia], 1)
VAR Total = COUNTA(fato_operacoes[divergencia])
RETURN
  IF(Total = 0, 0, DIVIDE(Divergencias, Total, 0) * 100)
```
% de operações com erro.

### Status Operação
```dax
Status Operação = 
VAR Completado = COUNTIF(fato_operacoes[status], "Completado")
VAR Erro = COUNTIF(fato_operacoes[status], "Com_Erro")
VAR Incompleto = COUNTIF(fato_operacoes[status], "Incompleto")
RETURN
  IF(Erro > 0 OR Incompleto > 0, "Com Problemas", "Operacional")
```
Indicador semáforo de status.

---

## Medidas de SLA

### SLA Cumprido
```dax
SLA Cumprido = 
COUNTIF(fato_operacoes[sla_cumprido], 1)
```
Count operações dentro do prazo.

### SLA %
```dax
SLA Percentual = 
VAR Cumprido = COUNTIF(fato_operacoes[sla_cumprido], 1)
VAR Total = COUNTA(fato_operacoes[sla_cumprido])
RETURN
  IF(Total = 0, 0, DIVIDE(Cumprido, Total, 0) * 100)
```
% cumprimento SLA.

### SLA Indicator
```dax
SLA Indicator = 
VAR SLAPct = [SLA Percentual]
RETURN
  IF(SLAPct >= 95, "✓ OK", IF(SLAPct >= 90, "⚠ Atenção", "✗ Crítico"))
```
Indicador visual SLA.

---

## Medidas de Contexto e Comparação

### Volume vs Período Anterior
```dax
Volume MÊS Anterior = 
CALCULATE(
  [Total Volume],
  DATEADD(dim_data[data_completa], -1, MONTH)
)
```
Volume do mês anterior para trending.

### Variação %
```dax
Variação Volume % = 
VAR VolAtual = [Total Volume]
VAR VolAnterior = [Volume Mês Anterior]
RETURN
  IF(VolAnterior = 0, 0, DIVIDE(VolAtual - VolAnterior, VolAnterior, 0) * 100)
```
Crescimento/queda % mês a mês.

### Ranking Operador
```dax
Ranking Operador = 
RANK(
  [Items por Minuto],
  ALL(dim_operador[codigo_operador])
)
```
Posição do operador no ranking.

---

## Medidas Avançadas

### Gargalo por Turno
```dax
Gargalo Turno = 
VAR TempoMedio = [Tempo Médio]
RETURN
  IF(TempoMedio > 60, "Alto Gargalo",
    IF(TempoMedio > 40, "Médio Gargalo", "Sem Gargalo"))
```
Diagnóstico de gargalos por turno.

### Operador Crítico
```dax
Operador Crítico = 
VAR Acuracia = [Acurácia Média]
VAR Produtiv = [Items por Minuto]
VAR Média Geral = CALCULATE([Acurácia Média], ALL(dim_operador))
RETURN
  IF(Acuracia < Média Geral * 0.9, "Atenção", "Ok")
```
Flag operadores abaixo da média.

### Total Operações
```dax
Total Operações = COUNTA(fato_operacoes[id_operacao])
```
Count total de operações.

### Custo Estimado (com estimativa)
```dax
Custo Estimado = 
VAR VolumeTotal = [Total Volume]
VAR CustoPorItem = 0.50  -- R$ 0,50 por item
RETURN
  VolumeTotal * CustooPorItem
```
Estimativa de custo operacional.

---

## Como Implementar

1. **Power BI Desktop**: Home → New Measure
2. **Copiar fórmula DAX** exata
3. **Nomeación**: Usar nome exato (sem espaços extra)
4. **Validar**: Verificar sem erros
5. **Testar**: Arrastar para visual e checar resultado

---

## Melhores Práticas

✅ Usar CALCULATE para contexto  
✅ Usar DIVIDE para evitar divisão zero  
✅ Comentar fórmulas complexas  
✅ Testar com filtros cruzados  
✅ Usar variáveis (VAR) para legibilidade  
❌ Evitar MEASURE dentro de MEASURE  
❌ Não adicionar lógica complexa em medidas simples  

