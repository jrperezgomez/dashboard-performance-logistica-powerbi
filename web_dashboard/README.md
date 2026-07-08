# Dashboard Web Interativo - Operações Logísticas

Dashboard interativo em HTML/CSS/JavaScript para análise de operações logísticas.

**Sem necessidade de Power BI Desktop ou servidor backend.**

---

## Como Executar

### Opção 1: Abrir arquivo local

1. Navegar até esta pasta: `web_dashboard/`
2. Clicar duas vezes em `index.html`
3. Dashboard abre no navegador

### Opção 2: Usar servidor local (recomendado)

```bash
# Com Python 3
python -m http.server 8000

# Com Node.js
npx http-server

# Com Live Server (VS Code)
Clicar direito em index.html → Open with Live Server
```

Depois abrir: `http://localhost:8000/web_dashboard/`

---

## Funcionalidades

### KPIs em Tempo Real

- **Volume Processado**: Total de itens movimentados
- **Produtividade Média**: items/minuto
- **SLA Cumprido**: % operações dentro prazo
- **Acurácia Média**: Qualidade geral
- **Taxa Divergência**: % erros identificados

### Gráficos Interativos

1. **Volume por Data**: Série temporal 90 dias
2. **Produtividade por Operador**: Ranking 20 operadores
3. **Performance por Turno**: Comparação SLA e Acurácia
4. **Divergências por Categoria**: Distribuição erros
5. **Evolução Semanal**: Trends com gráfico combinado

### Filtros Dinâmicos

- **Turno**: Matutino / Vespertino / Noturno
- **Categoria**: 7 categorias de produtos
- **Operador**: 20 operadores
- **Botão Limpar**: Reset todos filtros

---

## Tecnologias

- **HTML5**: Estrutura
- **CSS3**: Design responsivo, padrão corporativo
- **JavaScript**: Lógica, filtros, eventos
- **Plotly.js**: Gráficos interativos
- **CSV Parser**: Carregamento dados local

---

## Arquivos

```
web_dashboard/
├── index.html          # Página principal
├── styles.css          # Estilização corporativa
├── dashboard.js        # Lógica e gráficos
└── README.md           # Este arquivo
```

---

## Fonte de Dados

**Arquivo**: `../data/operacoes_logisticas.csv`

- 500+ registros de operações
- Período: Abril-Junho 2026
- Simulação realista de centro logístico

---

## Características de Design

### Responsivo

- Desktop: Layout 2 colunas
- Tablet: Layout 1-2 colunas
- Mobile: Layout 1 coluna

### Padrão Corporativo

- Paleta de cores profissional
- Tipografia limpa (Segoe UI)
- Ícones em emojis (performance)
- Sombras sutis

### Foco Operacional

- Sem gráficos redundantes
- KPIs visíveis
- Filtros rápidos
- Interactividad intuitiva

---

## Navegação

1. **Entrada**: Abrir index.html no navegador
2. **KPIs**: Visualizar métricas principais (cards)
3. **Filtros**: Aplicar filtros por turno/categoria/operador
4. **Gráficos**: Explorar dados con hover interactivo
5. **Reset**: Limpar filtros para voltar ao estado inicial

---

## Performance

- Carga: < 1 segundo (após download CSV)
- Gráficos: Renderização em tiempo real
- Filtros: Actualizacion instantánea
- Responsividad: Optimizado para todos dispositivos

---

## Limitaciones

- Dados simulados (não dados reales)
- CSV carregado em memória (< 500 registros)
- Sem persistencia (atualizar = reset filtros)
- Sem export de datos

---

## Notas

- **Projeto de Portfólio**: Desenvolvido para demonstração de habilidades BI
- **Cenário Simulado**: Todos dados são fictícios
- **Sem Backend**: Funciona 100% lado do cliente
- **Sem Dependencias Externas**: Apenas Plotly.js via CDN

---

## Autor

**José Pérez** - Analista de Dados Jr | BI Operacional

Julho 2026
