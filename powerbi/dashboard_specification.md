# Dashboard Operacional Logístico - Especificación Técnica Power BI

**Versión**: 1.0  
**Data**: Julho 2026  
**Autor**: José Pérez - Analista de Dados Jr

---

## 1. MODELO DE DADOS

### 1.1 Fonte de Dados

**Arquivo**: `data/operacoes_logisticas.csv`

**Localização**: Diretório raiz do projeto

**Registros**: 500+ operações (abril-junho 2026)

**Atualização**: Mensal (simulado)

---

## 1.2 Tabelas e Estrutura

### TABELA FATO: `fato_operacoes`

**Propósito**: Eventos transacionais de operações logísticas

**Granularidade**: Uma linha por operação realizada

| Coluna | Tipo | Descrição | Uso BI |
|--------|------|-----------|--------|
| data | DATE | Data da operação | Eixo temporal, filtros |
| operador | VARCHAR | Código operador (OP001-OP020) | Dimensão operador |
| turno | VARCHAR | Matutino/Vespertino/Noturno | Dimensão turno |
| produto | VARCHAR | Nome produto processado | Dimensão produto |
| categoria | VARCHAR | Categoria (7 tipos) | Dimensão categoria |
| volume | INT | Unidades processadas | Métrica volume |
| tempo_processamento_minutos | INT | Tempo gasto (5-180 min) | Métrica tempo |
| status | VARCHAR | Completado/Com_Erro/Incompleto | Filtro, análise |
| divergencia | INT | 1=erro, 0=sem erro | Métrica divergência |
| acuracia_percentual | INT | 0-100% | Métrica qualidade |
| sla_cumprido | INT | 1=sim, 0=não | Métrica SLA |

**Total Campos**: 11  
**Cardinalidade**: ~500 registros

---

### DIMENSÃO: `dim_data`

**Propósito**: Contexto temporal

**Construir em Power BI**: 
```
Usar "Novo parámetro" → "Data/Hora"
```

| Campo | Tipo | Cálculo |
|-------|------|---------|
| Data | DATE | Campo direto |
| Ano | INT | YEAR(data) |
| Mês | INT | MONTH(data) |
| Dia | INT | DAY(data) |
| Semana | INT | WEEKNUM(data) |
| Nome Mês | TEXT | FORMAT(data, "MMMM") |
| Nome Dia Semana | TEXT | FORMAT(data, "DDDD") |
| Trimestre | INT | ROUNDUP(MONTH(data)/3, 0) |

**Filtros sugeridos**: Data (Slicer rango)

---

### DIMENSIÓN: `dim_operador`

**Construir en Power BI**:
1. Nueva tabla: `dim_operador = DISTINCT(fato_operacoes[operador])`
2. Agregar columna: experiencia (simulado)
3. Agregar columna: desempeño relativo

| Campo | Tipo | Fuente |
|-------|------|--------|
| Código | TEXT | CSV directo |
| Experiencia (meses) | INT | Simulado (5-48) |
| Treinado | BOOLEAN | TRUE (asumido) |
| Performance | TEXT | Ranking por produtividad |

**Relación**: 1:N con fato_operacoes

---

### DIMENSIÓN: `dim_turno`

**Construir en Power BI**:
```
Nueva tabla manual:
Matutino | 06:00 | 14:00
Vespertino | 14:00 | 22:00
Noturno | 22:00 | 06:00
```

| Campo | Tipo |
|-------|------|
| Nombre Turno | TEXT |
| Hora Inicio | TIME |
| Hora Fin | TIME |

**Relación**: 1:N con fato_operacoes

---

### DIMENSIÓN: `dim_produto`

**Construir en Power BI**:
```
Nueva tabla: dim_produto = DISTINCT(fato_operacoes[categoria], fato_operacoes[produto])
```

| Campo | Tipo | Nota |
|-------|------|------|
| Categoría | TEXT | Eletrônicos, Vestuário, Alimentos, Limpeza, Higiene, Mobiliário, Papelaria |
| Producto | TEXT | 12 produtos |

**Relación**: 1:N con fato_operacoes

---

## 2. RELACIONES (Configuración Power BI)

```
dim_data[Data] ──────────┐
                         ├──→ fato_operacoes
dim_operador[Código] ────┤
                         ├──→ (Many:1)
dim_turno[Nombre] ───────┤    (Activa)
                         │
dim_producto[Categoría]──┘
```

### Detalles Relaciones

| Relación | Cardinalidad | Dirección Filtro | Activa |
|----------|--------------|------------------|--------|
| dim_data → fato_operacoes | 1:N | Ambas | ✓ |
| dim_operador → fato_operacoes | 1:N | Ambas | ✓ |
| dim_turno → fato_operacoes | 1:N | Ambas | ✓ |
| dim_producto → fato_operacoes | 1:N | Ambas | ✓ |

---

## 3. MEDIDAS DAX

### 3.1 Medidas Básicas de Volume

#### Total Volume
```dax
Total Volume = SUM(fato_operacoes[volume])
```
- **Formato**: Número entero
- **Unidad**: itens
- **Uso**: KPI principal
- **Meta**: 10.000+ por día

#### Volume Médio
```dax
Volume Médio = AVERAGE(fato_operacoes[volume])
```
- **Formato**: Número 2 decimales
- **Uso**: Análisis por operador

---

### 3.2 Medidas de Productividad

#### Produtividade Média
```dax
Produtividade Média = 
SUM(fato_operacoes[volume]) / 
SUM(fato_operacoes[tempo_processamento_minutos])
```
- **Formato**: 2 decimales
- **Unidad**: itens/minuto
- **Interpretación**:
  - Excelente: > 3
  - Bueno: 2-3
  - Pobre: < 2

#### Tempo Médio Processamento
```dax
Tempo Médio = AVERAGE(fato_operacoes[tempo_processamento_minutos])
```
- **Formato**: Número entero
- **Unidad**: minutos

---

### 3.3 Medidas de Qualidad

#### Acurácia Média
```dax
Acurácia Média = AVERAGE(fato_operacoes[acuracia_percentual])
```
- **Formato**: Percentual 2 decimales
- **Meta**: 98%+
- **Alerta**: < 95%

#### Taxa Divergência %
```dax
Taxa Divergência = 
VAR Divergencias = COUNTIF(fato_operacoes[divergencia], 1)
VAR Total = COUNTA(fato_operacoes[divergencia])
RETURN
  IF(Total = 0, 0, DIVIDE(Divergencias, Total, 0) * 100)
```
- **Formato**: Percentual 2 decimales
- **Meta**: < 2%
- **Crítico**: > 5%

---

### 3.4 Medidas de SLA

#### SLA Cumprido %
```dax
SLA Percentual = 
VAR Cumprido = COUNTIF(fato_operacoes[sla_cumprido], 1)
VAR Total = COUNTA(fato_operacoes[sla_cumprido])
RETURN
  IF(Total = 0, 0, DIVIDE(Cumprido, Total, 0) * 100)
```
- **Formato**: Percentual 2 decimales
- **Meta**: 95%+
- **Crítico**: < 90%

#### Indicador SLA
```dax
SLA Indicator = 
VAR SLAPct = [SLA Percentual]
RETURN
  IF(SLAPct >= 95, "✓ OK", 
    IF(SLAPct >= 90, "⚠ Atenção", "✗ Crítico"))
```
- **Formato**: Texto
- **Uso**: Semáforo visual

---

### 3.5 Medidas Avanzadas

#### Total Operações
```dax
Total Operações = COUNTA(fato_operacoes[id_operacao])
```

#### Operações Completadas
```dax
Operações Completas = 
COUNTIF(fato_operacoes[status], "Completado")
```

#### Taxa Completamento %
```dax
Taxa Completo = 
[Operações Completas] / [Total Operações] * 100
```

---

## 4. DISEÑO DE PÁGINAS

### PÁGINA 1: Visão Executiva

**Propósito**: Visión rápida (30 seg) para gerente

**Layout**: 4 columnas x 3 filas

#### Fila 1: Cards KPI (4 cards)

1. **Card**: Volume Total
   - Medida: `Total Volume`
   - Subtítulo: "Itens Processados"
   - Formato: Número entero
   - Tamaño: 25% ancho

2. **Card**: SLA Cumprido
   - Medida: `SLA Percentual`
   - Indicador: `SLA Indicator`
   - Formato: % con fondo rojo/amarelo/verde
   - Tamaño: 25% ancho

3. **Card**: Acurácia Média
   - Medida: `Acurácia Média`
   - Formato: % con fondo verde (95%+)
   - Tamaño: 25% ancho

4. **Card**: Taxa Divergência
   - Medida: `Taxa Divergência %`
   - Formato: % con fondo (< 2% verde)
   - Tamaño: 25% ancho

#### Fila 2: Série Temporal (gráfico + tabla)

1. **Gráfico Línea**:
   - Eje X: `dim_data[Data]` (por día)
   - Eje Y: `Total Volume`
   - Período: 90 días
   - Filtros: Data (slicer rango)
   - Interacción: Click → drilldown semana
   - Tamaño: 75% ancho x 40% alto

2. **Tabla Resumen**:
   - Columnas: Turno, Volume, SLA %, Acurácia %
   - Orden: Volume DESC
   - Tamaño: 25% ancho x 40% alto

#### Fila 3: Performance por Turno (gráfico barras)

1. **Gráfico Barras Agrupado**:
   - Categoría: `dim_turno[Nombre]` (3 turnos)
   - Eje Y: `SLA Percentual`
   - Segunda barra: `Acurácia Média`
   - Orden: SLA DESC
   - Tamaño: 100% ancho x 30% alto

#### Slicers (Filtros)

- **Data**: Rango (fecha inicio/fin)
- **Turno**: Multi-select (Matutino/Vespertino/Noturno)
- **Categoría**: Multi-select (7 categorías)

---

### PÁGINA 2: Produtividade Operacional

**Propósito**: Análisis por operador

#### Fila 1: Ranking Operadores (tabla)

- Columnas:
  - Ranking (1-20)
  - Código Operador
  - Produtividad Média (items/min) [DESC]
  - Volume Processado
  - Tempo Médio
  - Acurácia Média
- Datos: Top 20 operadores
- Condicional: Fondo verde top 5, amarillo 6-10, gris resto
- Tamaño: 50% ancho x 50% alto

#### Fila 2: Gráficos Complementarios

1. **Gráfico Barras**: Produtividad por Operador
   - Eje X: Operador (OP001-OP020)
   - Eje Y: Produtividad Média
   - Orden: DESC
   - Color: Gradiente
   - Tamaño: 25% ancho x 50% alto

2. **Gráfico Barras**: Volume por Turno
   - Eje X: Turno
   - Eje Y: Volume Processado
   - Tamaño: 25% ancho x 50% alto

#### Slicers

- **Operador**: Multi-select
- **Turno**: Multi-select

---

### PÁGINA 3: Qualidade Operacional

**Propósito**: Análisis de errores y acurácia

#### Fila 1: Divergencias (gráficos)

1. **Gráfico Pastel**: Divergencias por Categoría
   - Legenda: Categoria (filtrado: divergencia = 1)
   - Valores: Conteo de divergencias
   - Tamaño: 50% ancho x 40% alto

2. **Gráfico Barras**: Acurácia por Operador
   - Eje X: Operador
   - Eje Y: Acurácia Média
   - Meta: Línea horizontal 95%
   - Tamaño: 50% ancho x 40% alto

#### Fila 2: Tabla de Análisis

- Columnas:
  - Operador
  - Categoría
  - Volume
  - Acurácia Média
  - Divergencias (conteo)
  - Taxa Divergência %
- Orden: Acurácia ASC (peores primero)
- Condicional: Rojo si Acurácia < 90%
- Tamaño: 100% ancho x 40% alto

#### Slicers

- **Operador**: Multi-select
- **Categoría**: Multi-select

---

### PÁGINA 4: Tendências e Gargalos

**Propósito**: Identificar patrones y gargalos

#### Fila 1: Série Temporal Combinada (combo chart)

- Eje X: Semana del año (12 semanas)
- Eje Y1 (columnas): `Total Volume`
- Eje Y2 (línea): `Acurácia Média`
- Meta: Línea ref 95% acurácia
- Interacción: Hover muestra valores
- Tamaño: 70% ancho x 50% alto

#### Fila 2: Comparativa (gráfico barras)

- Eje X: Turno
- Eje Y: Produtividad + SLA %
- Disposición: Lado a lado
- Tamaño: 30% ancho x 50% alto

#### Fila 3: Heatmap (matriz)

- Filas: Día semana (Mon-Sun)
- Columnas: Turno (3)
- Valores: Produtividad Média
- Color: Gradiente (azul bajo, rojo alto)
- Objetivo: Encontrar gargalos día/turno
- Tamaño: 100% ancho x 35% alto

#### Slicers

- **Data**: Rango de semanas

---

## 5. REGLAS VISUALES

### Colores (Padrón Corporativo)

```
Primario:      #0078D4 (Azul)
Sucesso:       #107C10 (Verde)
Advertencia:   #FFB900 (Amarelo)
Crítico:       #E81123 (Rojo)
Fondo:         #F3F3F3 (Gris claro)
Texto:         #000000 (Negro)
```

### Tipografía

- **Título página**: Segoe UI, 24pt, Bold, #0078D4
- **Subtítulo**: Segoe UI, 14pt, Normal
- **Label**: Segoe UI, 11pt, Normal, #666666
- **Número KPI**: Segoe UI, 32pt, Bold

### Formato Números

- **Volume**: Número entero con separador mil (1.234)
- **Porcentaje**: 2 decimales con símbolo % (95,25%)
- **Tiempo**: Número entero + "min" (45 min)
- **Producción**: 2 decimales (2,45 itens/min)

### Filtros Globales

- **Ubicación**: Arriba página (slicer horizontal)
- **Tipo**: Dropdown o selección múltiple
- **Ancho**: 100% página
- **Altura**: 40px

---

## 6. STORYTELLING Y NAVEGACIÓN

### Flujo Usuario

```
Entrada → Página 1 (Visión Ejecutiva)
           ↓
           ¿SLA cumple? ¿Acurácia bien?
           ↓ (Si problemas)
           Página 3 (Cualidad) o Página 2 (Productividad)
           ↓
           ¿Operador específico? → Filtrar
           ¿Turno específico? → Filtrar
           ↓
           Página 4 (Tendencias) para patrones
```

### Preguntas que Responde Cada Página

#### Página 1 - Visión Ejecutiva
- **¿Cómo está el negocio hoy?**
- ¿Alcanzamos metas de volumen?
- ¿Cumplimos SLA?
- ¿Está bajo control la calidad?

#### Página 2 - Productividad
- **¿Quién es eficiente?**
- ¿Qué operador procesa más volumen?
- ¿Cuál es el turno más productivo?
- ¿Hay diferencias entre operadores?

#### Página 3 - Qualidad
- **¿Dónde hay problemas?**
- ¿Qué categoría genera errores?
- ¿Qué operador necesita capacitación?
- ¿Acurácia está en meta?

#### Página 4 - Tendencias
- **¿Hay patrones de mejora/caída?**
- ¿Qué día/turno es problemático?
- ¿Mejoramos con el tiempo?
- ¿Dónde invertir recursos?

### Decisiones Habilitadas

| Página | Decisión |
|--------|----------|
| Ejecutiva | Escalar problemas, informar gerencia |
| Productividad | Redistribuir operadores, bonus/incentivos |
| Qualidad | Capacitación, rediseño proceso |
| Tendencias | Ajuste turnos, inversión infraestructura |

---

## 7. GUÍA CONSTRUCCIÓN POWER BI

### Paso 1: Importar Datos

```
Power BI Desktop → Inicio → Obtener datos
  ↓
Seleccionar: Texto/CSV
  ↓
Navegar: data/operacoes_logisticas.csv
  ↓
Cargar (Load)
```

### Paso 2: Crear Dimensión Fecha

```
Modelado → Nueva tabla
  ↓
Escribir:
dim_data = 
ADDCOLUMNS(
  CALENDAR(DATE(2026,4,1), DATE(2026,6,30)),
  "Año", YEAR([Date]),
  "Mes", MONTH([Date]),
  "Semana", WEEKNUM([Date]),
  "Día Semana", FORMAT([Date], "DDDD")
)
```

### Paso 3: Crear Dimensiones Lookup

```
Modelado → Nueva tabla
  ↓
dim_operador = DISTINCT(fato_operacoes[operador])
dim_turno = DISTINCT(fato_operacoes[turno])
dim_producto = DISTINCT(fato_operacoes[categoria])
```

### Paso 4: Configurar Relaciones

```
Modelado → Administrar relaciones
  ↓
Para cada dimensión:
  Origen: dim_X[campo]
  Destino: fato_operacoes[campo]
  Cardinalidad: 1:N
  Dirección filtro: Ambas
  Marcar como activa
```

### Paso 5: Crear Medidas DAX

```
Modelado → Nueva medida
  ↓
Copiar cada medida desde sección 3
  ↓
Validar sintaxis (sin errores rojos)
```

### Paso 6: Crear Páginas

Insertar → Nueva página (x4)

Para cada página:
- Insertar visuales (cards, gráficos, tablas)
- Configurar campos
- Aplicar slicers
- Ajustar colores/formato

### Paso 7: Publicar

```
Inicio → Publicar
  ↓
Seleccionar workspace
  ↓
El dashboard está disponible en Power BI Service
```

---

## 8. VALIDACIÓN CHECKLIST

### Antes de Finalizar

- [ ] Todas medidas DAX sin errores
- [ ] Relaciones correctas (sin mensajes de conflicto)
- [ ] Slicers filtran correctamente
- [ ] Gráficos muestran datos correctos
- [ ] Formatos están aplicados (%, números, tiempo)
- [ ] Colores siguen padrón corporativo
- [ ] Títulos en PT-BR sin errores
- [ ] Interactividad funciona (click, filtros cruzados)
- [ ] Sin campos sin usar en visuales
- [ ] Performance aceptable (< 3 seg carga)

---

## 9. REFERENCIAS

- **Modelo dimensional**: `docs/modelo_dimensional.md`
- **Medidas DAX detalles**: `docs/dax_measures.md`
- **KPIs explicados**: `docs/kpis.md`
- **Estructura propuesta**: `powerbi/README.md`

---

## 10. VERSIONADO Y CAMBIOS

| Versión | Fecha | Cambio |
|---------|-------|--------|
| 1.0 | 2026-07-07 | Especificación inicial |

---

**Especificación Lista para Implementación en Power BI Desktop**

Tiempo estimado construcción: 2-3 horas (usuario con experiencia BI)
