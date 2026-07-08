# Modelo Dimensional - Dashboard de Performance Logística

## Visão Geral

Este documento descreve a estrutura dimensional do modelo de dados implementado no PostgreSQL para suportar análises de performance logística em Power BI.

**Padrão**: Modelo Estrela (Star Schema)

---

## Tabelas Dimensionais

### 1. Tabela: `clientes`

**Tipo**: Dimensão

**Descrição**: Armazena informações dos clientes que realizam pedidos.

**Colunas**:
| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id_cliente` | INT | Chave primária (PK) |
| `nome_cliente` | VARCHAR(100) | Nome do cliente |
| `cidade` | VARCHAR(50) | Cidade de localização |
| `regiao` | VARCHAR(50) | Região Brasil (Sudeste, Sul, Nordeste, Centro-Oeste) |
| `data_cadastro` | DATE | Data de registro do cliente |

**Relacionamentos**:
- Referenciada por: `pedidos.cliente_id`
- Relacionamento: 1:N (um cliente para muitos pedidos)

**Granularidade**: Um cliente por linha

---

### 2. Tabela: `produtos`

**Tipo**: Dimensão

**Descrição**: Catálogo de produtos disponíveis.

**Colunas**:
| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id_produto` | INT | Chave primária (PK) |
| `nome_produto` | VARCHAR(100) | Nome do produto |
| `categoria` | VARCHAR(50) | Categoria (Eletrônicos, Vestuário, Alimentos) |
| `preco` | DECIMAL(10, 2) | Preço unitário |
| `peso_kg` | DECIMAL(8, 2) | Peso para cálculo logístico |

**Relacionamentos**:
- Referenciada por: `estoque.id_produto`
- Relacionamento: 1:N (um produto para muitos registros de estoque)

**Granularidade**: Um produto por linha

---

## Tabelas de Fatos

### 3. Tabela: `pedidos`

**Tipo**: Fato

**Descrição**: Eventos transacionais de pedidos.

**Colunas**:
| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id_pedido` | INT | Chave primária (PK) |
| `data_pedido` | DATE | Data do pedido |
| `cliente_id` | INT | Chave estrangeira (FK) → `clientes` |
| `status` | VARCHAR(50) | Status (Pendente, Confirmado, Entregue, Cancelado) |
| `valor_total` | DECIMAL(10, 2) | Valor total do pedido |

**Relacionamentos**:
- Referencia: `clientes.id_cliente`
- Referenciada por: `entregas.id_pedido`

**Granularidade**: Um pedido por linha

---

### 4. Tabela: `entregas`

**Tipo**: Fato Transacional

**Descrição**: Rastreamento logístico de pedidos.

**Colunas**:
| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id_entrega` | INT | Chave primária (PK) |
| `id_pedido` | INT | Chave estrangeira (FK) → `pedidos` |
| `data_envio` | DATE | Data do envio |
| `data_entrega` | DATE | Data da entrega |
| `tempo_entrega_dias` | INT | Dias para entrega |
| `status_entrega` | VARCHAR(50) | Status (Pendente, Entregue, Cancelado) |

**Relacionamentos**:
- Referencia: `pedidos.id_pedido`

**Granularidade**: Uma entrega por linha

**Observação**: Derivado de `pedidos` com lógica de tempo

---

### 5. Tabela: `estoque`

**Tipo**: Fato Snapshot

**Descrição**: Snapshot de disponibilidade de produtos em armazéns.

**Colunas**:
| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id_estoque` | INT | Chave primária (PK) |
| `id_produto` | INT | Chave estrangeira (FK) → `produtos` |
| `quantidade` | INT | Unidades em estoque |
| `localizacao` | VARCHAR(50) | Localização no armazém |
| `data_atualizacao` | DATE | Última atualização |

**Relacionamentos**:
- Referencia: `produtos.id_produto`

**Granularidade**: Um SKU por localização por data

---

## Diagrama de Relacionamentos

```
clientes ────────┐
                 │
                 ├──> pedidos
                 │
                 └──> entregas
                 
produtos ────────┐
                 │
                 └──> estoque
```

---

## Modelagem em Power BI

### Relacionamentos a Criar

1. **Clientes → Pedidos**
   - `clientes.id_cliente` = `pedidos.cliente_id`
   - Cardinalidade: 1:N
   - Tipo: Um para Muitos

2. **Pedidos → Entregas**
   - `pedidos.id_pedido` = `entregas.id_pedido`
   - Cardinalidade: 1:N
   - Tipo: Um para Muitos

3. **Produtos → Estoque**
   - `produtos.id_produto` = `estoque.id_produto`
   - Cardinalidade: 1:N
   - Tipo: Um para Muitos

### Considerações para DAX

- **Dimensão Temporal**: Criar tabela de datas com granularidade diária
- **Medidas de SLA**: Comparar `data_entrega` contra SLA definido
- **Análise Regional**: Agrupar por `clientes.regiao`
- **Rotatividade de Estoque**: Correlacionar `pedidos` com `estoque`

---

## Fatos e Dimensões Propostas

| Tipo | Tabela | Uso |
|------|--------|-----|
| Dimensão | clientes | Análise por região, cidade, segmentação |
| Dimensão | produtos | Análise por categoria, preço, peso |
| Fato | pedidos | Volume, receita, padrões de compra |
| Fato | entregas | Performance logística, SLA, tempo |
| Fato | estoque | Disponibilidade, rotatividade, localização |

---

## Métricas Derivadas (para DAX)

### Baseadas em Pedidos

- **Total de Pedidos**: `COUNT(pedidos[id_pedido])`
- **Receita Total**: `SUM(pedidos[valor_total])`
- **Ticket Médio**: `AVERAGE(pedidos[valor_total])`
- **Pedidos por Status**: `COUNTIF(pedidos[status], <status>)`

### Baseadas em Entregas

- **Taxa de Entrega no Prazo**: `COUNT(entregas com tempo <= 3) / COUNT(entregas entregues)`
- **Tempo Médio**: `AVERAGE(entregas[tempo_entrega_dias])`
- **Entregas Pendentes**: `COUNTIF(entregas[status_entrega], "Pendente")`

### Baseadas em Estoque

- **Produtos Disponíveis**: `COUNTIF(estoque[quantidade], > 0)`
- **Estoque Total**: `SUM(estoque[quantidade])`
- **Taxa de Disponibilidade**: `Produtos Disponíveis / Total de SKUs`

---

## Notas Sobre o Cenário Simulado

- Todos os dados são fictícios para fins educacionais
- As relações FK garantem integridade referencial
- O modelo suporta análises operacionais em tempo real
- Índices foram criados em campos de busca frequente para performance

