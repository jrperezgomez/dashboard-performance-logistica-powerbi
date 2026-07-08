# Modelo Dimensional - Dashboard Operacional Logístico

## Star Schema

```
                dim_data
                   |
                   |
dim_operador ---- fato_operacoes ---- dim_produto
                   |
                   |
                dim_turno
```

## Tabelas Dimensionais

### dim_data

Contexto temporal das operações.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id_data | INT | Chave primária |
| data_completa | DATE | Data da operação |
| ano | INT | Ano (2026) |
| mes | INT | Mês (4-6) |
| trimestre | INT | Trimestre (2) |
| nome_mes | VARCHAR | Nome mês português |
| nome_dia_semana | VARCHAR | Dia semana português |
| semana_ano | INT | Semana do ano |

**Granularidade**: Uma linha por dia

---

### dim_operador

Dados do pessoal operacional.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id_operador | INT | Chave primária |
| codigo_operador | VARCHAR | Identificador (OP001-OP020) |
| nome_operador | VARCHAR | Nome completo |
| experiencia_meses | INT | Meses trabalhando |
| treinado | BOOLEAN | Status de treinamento |

**Granularidade**: Um operador por linha

**Dados**: 20 operadores com experiência 5-48 meses

---

### dim_produto

Catálogo de produtos processados.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id_produto | INT | Chave primária |
| nome_produto | VARCHAR | Nome produto |
| categoria | VARCHAR | Categoria |
| peso_kg | DECIMAL | Peso para logística |

**Granularidade**: Um produto por linha

**Categorias**:
- Eletrônicos
- Vestuário
- Alimentos
- Limpeza
- Higiene
- Mobiliário
- Papelaria

---

### dim_turno

Turnos de operação.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id_turno | INT | Chave primária |
| nome_turno | VARCHAR | Matutino / Vespertino / Noturno |
| hora_inicio | TIME | Hora início |
| hora_fim | TIME | Hora fim |

**Granularidade**: Um turno por linha

---

## Tabela de Fatos

### fato_operacoes

Registro de cada operação (separação, contagem, embalagem, etc).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id_operacao | INT | Chave primária |
| id_data | INT | FK → dim_data |
| id_operador | INT | FK → dim_operador |
| id_turno | INT | FK → dim_turno |
| id_produto | INT | FK → dim_produto |
| volume | INT | Unidades processadas |
| tempo_processamento_minutos | INT | Tempo gasto |
| status | VARCHAR | Completado / Com_Erro / Incompleto |
| divergencia | INT | 1=há erro, 0=sem erro |
| acuracia_percentual | INT | % acertos (0-100) |
| sla_cumprido | INT | 1=dentro prazo, 0=atrasado |

**Granularidade**: Uma operação = uma linha

**Volume de dados**: ~500 operaciónes (90 dias)

---

## Relacionamentos

1. **fato_operacoes → dim_data**
   - Cardinalidade: N:1
   - Uso: Agrupar por período

2. **fato_operacoes → dim_operador**
   - Cardinalidade: N:1
   - Uso: Análise por operador

3. **fato_operacoes → dim_turno**
   - Cardinalidade: N:1
   - Uso: Comparar desempenho turno

4. **fato_operacoes → dim_produto**
   - Cardinalidade: N:1
   - Uso: Análise por categoria

---

## Métricas Derivadas (para DAX)

### Volume

```
Total Volume = SUM(fato_operacoes[volume])
Volume Médio = AVERAGE(fato_operacoes[volume])
```

### Produtividade

```
Items/Minuto = 
  SUM(fato_operacoes[volume]) / 
  SUM(fato_operacoes[tempo_processamento_minutos])
```

### Qualidade

```
Acurácia Média = AVERAGE(fato_operacoes[acuracia_percentual])

Taxa Divergência = 
  COUNTIF(fato_operacoes[divergencia], 1) / 
  COUNTIF(fato_operacoes[divergencia])
```

### SLA

```
SLA Cumprido % = 
  COUNTIF(fato_operacoes[sla_cumprido], 1) / 
  COUNTIF(fato_operacoes[sla_cumprido])
```

### Tempo

```
Tempo Médio = AVERAGE(fato_operacoes[tempo_processamento_minutos])
```

---

## Padrões de Análise Esperados

1. **Por Operador**: Quem tem melhor produtividade?
2. **Por Turno**: Qual turno tem mais divergências?
3. **Por Categoria**: Qual produto é mais difícil?
4. **Série Temporal**: Há melhoria ao longo de 90 dias?
5. **Gargalos**: Onde investir em treinamento?

---

## Notas de Implementação

- Modelo é normalizado e otimizado para análise
- Índices criados em FK para melhor performance
- Dataset é simulado mas baseado em padrões logísticos reais
- Estrutura suporta crescimento até 1M+ operações
