# Dashboard de Performance Logística - Power BI

**Projeto de Portfólio** | Análise de dados com Power BI, SQL e modelagem DAX em cenário simulado

## Descrição

Demonstração de habilidades em análise de dados e visualização usando Power BI, PostgreSQL e DAX. O projeto implementa um dashboard interativo para análise de performance logística com dataset fictício de pedidos, entregas e estoque.

**⚠️ Cenário Simulado para Fins de Portfólio**: Todos os dados são fictícios e não refletem organizações reais.

## Stack Tecnológico

- **PostgreSQL**: Criação de tabelas, consultas KPI e análises operacionais
- **Power BI**: Visualização interativa e modelagem dimensional
- **DAX**: Cálculos avançados e medidas analíticas
- **CSV**: Dados simulados reproduzíveis

## Processo Analítico

### 1. Entendimento do Problema

- Identificação de KPIs logísticos: taxa de entrega no prazo, tempo médio de entrega, disponibilidade de estoque
- Definição de dimensões: região, categoria de produto, status de entrega
- Escopo: cenário simulado para portfólio

### 2. Preparação dos Dados

**Schema relacional** (`sql/create_tables.sql`):
- `pedidos`: Informações de vendas e datas
- `clientes`: Dados demográficos e localização
- `entregas`: Rastreamento logístico
- `estoque`: Disponibilidade de produtos
- `produtos`: Catálogo com categorias e preços

Validação com constraints e foreign keys.

### 3. Modelagem

- **Dimensões**: Cliente, Produto, Data
- **Tabelas de Fatos**: Pedidos, Entregas, Estoque
- **Modelo Estrela**: Estrutura normalizada para análise eficiente

### 4. DAX (Data Analysis Expressions)

Medidas calculadas para Power BI:
- Taxa de Entrega no Prazo (%)
- Tempo Médio de Entrega (dias)
- Receita Total por Região
- Disponibilidade de Estoque
- Colunas derivadas para categorização temporal

### 5. Dashboard

**Páginas Propostas**:
1. Visão Executiva: KPIs principais e tendências
2. Performance de Entrega: Eficiência por região
3. Análise de Estoque: Disponibilidade e rotatividade
4. Análise de Vendas: Receita, ticket médio, clientes top

Filtros por região, período e categoria.

### 6. Insights

- Identificação de regiões com melhor desempenho de entrega
- Produtos com maior/menor disponibilidade
- Tendências de vendas e sazonalidade
- Clientes estratégicos com maior valor

## Estrutura do Projeto

```
dashboard-performance-logistica-powerbi/
├── data/
│   └── pedidos_logisticos.csv        # Dataset simulado
├── sql/
│   ├── create_tables.sql             # Schema e definição de tabelas
│   ├── data_seed.sql                 # Populate com dados simulados
│   ├── consultas_kpis.sql            # Queries de KPIs principais
│   └── analises_operacionais.sql     # Análises avançadas
├── docs/
│   ├── modelo_dimensional.md         # Documentação do modelo
│   └── dax_measures.md               # Exemplos de medidas DAX
├── README.md                         # Este arquivo
├── LICENSE                           # MIT License
└── .gitignore
```

## Como Executar

### Pré-requisitos

- PostgreSQL 12+
- Power BI Desktop (versão recente)
- Editor de texto ou IDE SQL

### Passos

1. **Criar banco de dados**:
   ```sql
   CREATE DATABASE logistica_portfolio;
   ```

2. **Executar scripts SQL**:
   ```sql
   -- Criar tabelas
   \i sql/create_tables.sql
   
   -- Inserir dados simulados
   \i sql/data_seed.sql
   ```

3. **Validar dados**:
   ```sql
   SELECT COUNT(*) FROM pedidos;
   SELECT COUNT(*) FROM entregas;
   SELECT COUNT(*) FROM estoque;
   ```

4. **Conectar Power BI**:
   - Usar PostgreSQL connector
   - Importar tabelas do schema
   - Criar modelo dimensional conforme `docs/modelo_dimensional.md`
   - Implementar medidas DAX conforme `docs/dax_measures.md`

5. **Explorar**: Interagir com filtros e visualizações

## Ferramentas e Versões

- **PostgreSQL**: 12.0+
- **Power BI Desktop**: Versão mais recente
- **DAX Studio**: Para otimização (opcional)

## Documentação

- `docs/modelo_dimensional.md`: Explicação de tabelas, relações e granularidade
- `docs/dax_measures.md`: Exemplos de medidas DAX para implementação

## Notas Importantes

- ⚠️ **Dataset Fictício**: Todos os dados são simulados para fins educacionais e de portfólio
- 🌟 **Projeto de Aprendizado**: Desenvolvido como exemplo de habilidades em análise de dados
- 🔄 **Reproduzível**: Scripts SQL permitem recriar dados simulados em qualquer ambiente

## Contato

**José Pérez** - Analista de Dados Jr  
Curitiba, PR | Brasil  
[LinkedIn](https://www.linkedin.com/in/jose-ronaldo-perez-gomez) | [GitHub](https://github.com/jrperezgomez)

---

*Projeto desenvolvido em julho de 2026 para demonstração de habilidades em análise de dados e BI.*
