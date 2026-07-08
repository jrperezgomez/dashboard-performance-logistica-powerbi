# Dashboard Operacional Logístico - Power BI

**Projeto de Portfólio** | Análise de operações logísticas com Power BI, PostgreSQL e modelagem analítica

## Objetivo

Demonstrar habilidades em análise de dados operacionais, BI e SQL através da construção de um dashboard executivo para monitoramento de performance logística.

## Problema de Negócio

Centros de distribuição logística processam milhares de operações diárias. Sem visibilidade em tempo real sobre produtividade, qualidade e eficiência, não é possível identificar gargalos, otimizar recursos ou manter SLAs.

## Solução Proposta

Dashboard analítico que centraliza KPIs operacionais:
- **Volume Processado**: Total de itens movimentados por período
- **Produtividade**: Items/hora por operador
- **Acurácia**: Taxa de precisão em separação/contagem
- **Taxa de Divergência**: Erros operacionais identificados
- **SLA**: Cumprimento de tempo de processamento
- **Tempo Médio**: Ciclo de operação

Modelo dimensional permite análise por operador, turno, categoria de produto e período.

## Arquitetura do Projeto

### Stack Tecnológico

- **PostgreSQL**: Base de dados (Star Schema)
- **Power BI**: Visualização e análise interativa
- **DAX**: Cálculos avançados e medidas
- **SQL**: Queries analíticas com CTE, JOINs, window functions

### Estrutura de Dados

```
Star Schema - Modelo Dimensional

             dim_data
               |
fato_operacoes--+--dim_produto
               |
               +--dim_operador
               |
               +--dim_turno
```

**Fato Central**: `fato_operacoes`
- Granularidade: Uma linha por operação (item separado, contado, etc.)

**Dimensões**:
- `dim_data`: Datas com contexto (semana, mês, etc.)
- `dim_produto`: Categorias de produtos
- `dim_operador`: Equipo operacional
- `dim_turno`: Turnos de operação

## Dataset

**Arquivo**: `data/pedidos_logisticos.csv`

- **Registros**: 500+ operações simuladas
- **Período**: 90 dias de operação
- **Variáveis**:
  - data, operador, turno
  - produto, categoria, volume
  - tempo_processamento_minutos
  - status (completado, com_erro, incompleto)
  - divergencia, acuracia_percentual
  - sla_cumprido

**Cenário**: Simulação de operações reais de centro logístico brasileño

## KPIs

| KPI | Fórmula | Objetivo |
|-----|---------|----------|
| **Volume Processado** | SUM(volume) | Total itens movimentados |
| **Produtividade** | SUM(volume) / SUM(tempo_minutos) | Items/minuto por operador |
| **Acurácia Média** | AVG(acuracia_percentual) | Precisão operacional |
| **Taxa Divergência** | COUNT(divergencia=1) / COUNT(*) | % erros identificados |
| **SLA Cumprido** | COUNT(sla_cumprido=1) / COUNT(*) | % dentro de prazo |
| **Tempo Médio** | AVG(tempo_processamento_minutos) | Ciclo médio operacional |

## Análises Realizadas

### SQL Queries (consultas_kpis.sql)

Principais KPIs para monitoreo:
- Taxa de cumplimiento SLA por turno
- Produtividad por operador (ranking)
- Acurácia por categoría de producto
- Divergencias por turno y período

### SQL Queries Avançadas (analises_operacionais.sql)

Análisis profundos:
- Gargalos por turno (tempo vs volume)
- Performance comparativa: melhor vs pior operador
- Trending: produtividade semanal
- Correlação: categoria vs divergencias

## Tecnologias

- **PostgreSQL 12+**: Banco relacional, queries otimizadas
- **Power BI Desktop**: Visualización e interactividad
- **DAX**: 10+ medidas calculadas
- **SQL avanzado**: CTEs, window functions, subconsultas
- **CSV**: Dados reproduzíveis

## Como Executar

### 1. Preparação

```bash
# Clonar repositorio
git clone https://github.com/jrperezgomez/dashboard-performance-logistica-powerbi.git
cd dashboard-performance-logistica-powerbi
```

### 2. Database PostgreSQL

```bash
# Crear banco
createdb logistica_portfolio

# Executar schema
psql logistica_portfolio -f sql/create_tables.sql

# Popular dados
psql logistica_portfolio -f sql/data_seed.sql
```

### 3. Validar Dados

```sql
SELECT COUNT(*) FROM fato_operacoes;        -- esperado: 500+
SELECT COUNT(*) FROM dim_operador;          -- esperado: 20+
SELECT COUNT(*) FROM dim_produto;           -- esperado: 15+
```

### 4. Power BI

1. Abrir Power BI Desktop
2. Conectar a PostgreSQL
3. Importar tabelas (fato + dimensões)
4. Crear modelo relacional (conforme `docs/modelo_dimensional.md`)
5. Implementar medidas DAX (conforme `docs/dax_measures.md`)
6. Construir dashboard (conforme `powerbi/README.md`)

### 5. Explorar

Testar cada página:
- Visão Executiva (KPIs)
- Produtividade (operador ranking)
- Qualidade (divergencias, acurácia)
- Tendências (series temporales)

## Insights Esperados

- **Operador X** tem produtividade 15% maior que média
- **Turno Y** gera 2x mais divergencias que outros
- **Categoria Z** demanda 30% mais tempo de processamento
- **SLA**: Cumprimento caiu de 98% para 94% semana passada

## Próximas Melhorias

- Integración con sistema ERP real
- Alertas automáticas para SLA
- Forecast de volume usando ML
- Dashboard mobile (Power BI Mobile)
- Análisis de causas raíz (5W2H)

## Documentação

- `docs/modelo_dimensional.md`: Explicação completa do schema
- `docs/kpis.md`: Cada KPI con fórmula e interpretación
- `docs/dax_measures.md`: Medidas DAX implementadas
- `powerbi/README.md`: Estructura recomendada del dashboard

## Notas Importantes

⚠️ **Cenário Simulado**: Todos os dados são fictícios baseados em padrões reais de operações logísticas brasileñas

🎯 **Proyecto de Aprendizado**: Desenvolvido para demonstração de habilidades em:
- Modelagem dimensional (Star Schema)
- SQL análitico (CTE, window functions, JOINs)
- DAX avanzado (medidas, contexto, variables)
- BI design (UX, interatividad, storytelling)

📊 **Reproduzível**: Scripts SQL permitem recriar cenário completo em qualquer ambiente PostgreSQL

## Tecnologias Utilizadas

```
LENGUAJES:    SQL, DAX, M Query
BANCO:        PostgreSQL 12.0+
BI:           Power BI Desktop (versão 2024+)
FERRAMENTAS:  pgAdmin, DAX Studio, Git
MÉTODO:       Star Schema, Análisis Dimensional
```

## Contato

**José Pérez** - Analista de Dados Jr | BI Operacional  
📧 bookingperezjose@gmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/jose-ronaldo-perez-gomez) | [GitHub](https://github.com/jrperezgomez)

Curitiba, PR | Brasil

---

*Projeto desenvolvido em julho de 2026 para demonstração de competências em análise de dados operacionais e BI.*
