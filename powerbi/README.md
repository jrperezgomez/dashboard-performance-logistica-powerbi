# Power BI Dashboard Structure

## Visão Geral

Dashboard operacional com 4 páginas interativas para análise de performance logística.

---

## Página 1: Visão Executiva

**Objetivo**: KPIs principais + tendências

### Visuais

1. **Card KPI**: Volume Total
   - Medida: `Total Volume`
   - Formato: Número inteiro
   - Unidade: itens

2. **Card KPI**: Produtividade
   - Medida: `Items por Minuto`
   - Formato: 2 casas decimais
   - Unidade: itens/min

3. **Card KPI**: Acurácia
   - Medida: `Acurácia Média`
   - Formato: Percentual
   - Cor condicional: Verde ≥98%, Amarelo 95-98%, Vermelho <95%

4. **Card KPI**: SLA
   - Medida: `SLA Percentual`
   - Indicador: `SLA Indicator`

5. **Gráfico Série Temporal**
   - Eixo X: `dim_data[data_completa]`
   - Eixo Y: `Total Volume`
   - Período: 90 dias
   - Linha: Trending

6. **Tabela Resumo**
   - Coluna: `dim_turno[nome_turno]`
   - Valor 1: `Total Volume`
   - Valor 2: `Items por Minuto`
   - Valor 3: `SLA Percentual`

---

## Página 2: Produtividade

**Objetivo**: Performance por operador e turno

### Visuais

1. **Tabela Ranking**
   - Coluna 1: `dim_operador[codigo_operador]` (Ordenado)
   - Coluna 2: `Items por Minuto` (Desc)
   - Coluna 3: `Total Volume`
   - Coluna 4: `Tempo Médio`
   - Filtro: Top 20 operadores
   - Ranking: Verde top 5, Amarelo 6-10, Cinza resto

2. **Gráfico Barras**
   - Categoria: `dim_operador[codigo_operador]`
   - Valor: `Items por Minuto`
   - Ordenação: Descendente
   - Cor: Gradiente

3. **Gráfico Barras Agrupado**
   - Eixo: `dim_turno[nome_turno]`
   - Legenda: Status operação
   - Valor: `Total Volume`

4. **Card**: Top Operador
   - Medida: MAX operador por produtividade
   - Ranking: 1/20

---

## Página 3: Qualidade

**Objetivo**: Erros, divergências, problemas

### Visuais

1. **Gráfico Pizza**: Divergências por Categoria
   - Legenda: `dim_produto[categoria]`
   - Valor: `Divergências Totais`
   - Filtro: Apenas registros com divergencia = 1

2. **Tabela Crítica**
   - Colunas:
     - `dim_produto[nome_produto]`
     - `Acurácia Média`
     - `Divergências Totais`
     - `Taxa Divergência %`
   - Ordenação: Acurácia (Asc)
   - Condicional: Vermelho se <90%

3. **Gráfico Linha**: Acurácia Trending
   - Eixo X: `dim_data[semana_ano]`
   - Eixo Y: `Acurácia Média`
   - Meta: Linha ref 95%

4. **Card**: Total Erros
   - Medida: `Divergências Totais`
   - Cor: Vermelho

5. **Card**: Taxa Erro %
   - Medida: `Taxa Divergência %`

---

## Página 4: Tendências

**Objetivo**: Série temporal e comparações

### Visuais

1. **Combo Chart**: Volume + Acurácia
   - Eixo X: `dim_data[semana_ano]`
   - Valor 1 (Coluna): `Total Volume`
   - Valor 2 (Linha): `Acurácia Média`
   - Período: 12 semanas

2. **Gráfico Barras**: Comparativo Turnos
   - Categoria: `dim_turno[nome_turno]`
   - Valor 1: `Items por Minuto`
   - Valor 2: `SLA Percentual`
   - Disposição: Lado a lado

3. **Matriz Heatmap**: Operador x Turno
   - Linhas: `dim_operador[codigo_operador]`
   - Colunas: `dim_turno[nome_turno]`
   - Valor: `Items por Minuto`
   - Cor: Gradiente (azul=baixo, verde=alto)

4. **KPI Gauge**: Variação Semanal
   - Medida: `Variação Volume %`
   - Meta: 0% (sem queda)
   - Intervalo: -20% a +20%

---

## Filtros Globais (Slicers)

1. **Data**: 
   - Tipo: Relatório datas
   - Granularidade: Mês
   - Padrão: Últimos 90 dias

2. **Operador**:
   - Tipo: Lista
   - Multi-select: Sim
   - Padrão: Todos

3. **Turno**:
   - Tipo: Lista
   - Multi-select: Sim
   - Padrão: Todos

4. **Categoria**:
   - Tipo: Lista
   - Multi-select: Sim
   - Padrão: Todos

---

## Design Recomendado

### Cores
- Principal: Azul corporativo (#0078D4)
- Sucesso: Verde (#107C10)
- Alerta: Amarelo (#FFB900)
- Crítico: Vermelho (#E81123)
- Fundo: Cinza claro (#F0F0F0)

### Fontes
- Título: Segoe UI, 24pt, Bold
- Subtítulo: Segoe UI, 14pt
- Valor: Segoe UI, 18pt, Bold
- Label: Segoe UI, 11pt

### Layout
- Página: 1280x720px
- Margem: 20px
- Grid: Alinhado 20px

---

## Interatividade

✅ Cross-filter entre páginas  
✅ Drill-down por data  
✅ Tooltip customizado  
✅ Botões navegação  
✅ Bookmark de estados

---

## Performance

- Atualização: Diária (agendado)
- Cache: Habilitado
- Modo: DirectQuery (PostgreSQL)
- Partições: Por mês (se necessário)

