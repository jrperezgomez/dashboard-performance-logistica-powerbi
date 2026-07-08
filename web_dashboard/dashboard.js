// Dashboard Operacional Logístico - JavaScript
// Carga datos desde CSV y genera visualizaciones interativas

let rawData = [];
let filteredData = [];

// Inicializar cuando carga página
document.addEventListener('DOMContentLoaded', () => {
    loadData();
    setupEventListeners();
});

// Cargar datos desde CSV
async function loadData() {
    try {
        const response = await fetch('../data/operacoes_logisticas.csv');
        const csv = await response.text();
        rawData = parseCSV(csv);
        filteredData = [...rawData];

        // Populate operador filter
        populateOperadorFilter();

        // Actualizar dashboard
        updateDashboard();

        document.getElementById('record-count').textContent = rawData.length;
    } catch (error) {
        console.error('Erro ao carregar dados:', error);
        showError('Erro ao carregar arquivo CSV. Verifique se data/operacoes_logisticas.csv existe.');
    }
}

// Parser simple CSV
function parseCSV(csv) {
    const lines = csv.trim().split('\n');
    const headers = lines[0].split(',');
    const data = [];

    for (let i = 1; i < lines.length; i++) {
        const obj = {};
        const values = lines[i].split(',');

        for (let j = 0; j < headers.length; j++) {
            const key = headers[j].trim();
            const value = values[j]?.trim();

            // Convertir tipos
            if (key === 'volume' || key === 'tempo_processamento_minutos' ||
                key === 'divergencia' || key === 'acuracia_percentual' || key === 'sla_cumprido') {
                obj[key] = parseInt(value) || 0;
            } else {
                obj[key] = value || '';
            }
        }

        if (obj.data) data.push(obj);
    }

    return data;
}

// Setup event listeners
function setupEventListeners() {
    document.getElementById('filter-turno').addEventListener('change', applyFilters);
    document.getElementById('filter-categoria').addEventListener('change', applyFilters);
    document.getElementById('filter-operador').addEventListener('change', applyFilters);
    document.getElementById('btn-reset').addEventListener('click', resetFilters);
}

// Populate operador filter
function populateOperadorFilter() {
    const operadores = [...new Set(rawData.map(r => r.operador))].sort();
    const select = document.getElementById('filter-operador');

    operadores.forEach(op => {
        const option = document.createElement('option');
        option.value = op;
        option.textContent = op;
        select.appendChild(option);
    });
}

// Aplicar filtros
function applyFilters() {
    const turno = document.getElementById('filter-turno').value;
    const categoria = document.getElementById('filter-categoria').value;
    const operador = document.getElementById('filter-operador').value;

    filteredData = rawData.filter(row => {
        return (!turno || row.turno === turno) &&
               (!categoria || row.categoria === categoria) &&
               (!operador || row.operador === operador);
    });

    updateDashboard();
}

// Reset filtros
function resetFilters() {
    document.getElementById('filter-turno').value = '';
    document.getElementById('filter-categoria').value = '';
    document.getElementById('filter-operador').value = '';
    filteredData = [...rawData];
    updateDashboard();
}

// Actualizar dashboard completo
function updateDashboard() {
    updateKPIs();
    updateCharts();
}

// Actualizar KPIs
function updateKPIs() {
    if (filteredData.length === 0) {
        document.getElementById('kpi-volume').textContent = '0';
        document.getElementById('kpi-produtividade').textContent = '0.00';
        document.getElementById('kpi-sla').textContent = '0%';
        document.getElementById('kpi-acuracia').textContent = '0%';
        document.getElementById('kpi-divergencia').textContent = '0%';
        return;
    }

    // Volume total
    const volume = filteredData.reduce((sum, r) => sum + r.volume, 0);
    document.getElementById('kpi-volume').textContent = volume.toLocaleString('pt-BR');

    // Produtividade
    const tempoTotal = filteredData.reduce((sum, r) => sum + r.tempo_processamento_minutos, 0);
    const produtividade = tempoTotal > 0 ? (volume / tempoTotal).toFixed(2) : 0;
    document.getElementById('kpi-produtividade').textContent = produtividade;

    // SLA
    const slaCount = filteredData.filter(r => r.sla_cumprido === 1).length;
    const slaPct = ((slaCount / filteredData.length) * 100).toFixed(1);
    document.getElementById('kpi-sla').textContent = slaPct + '%';

    // Acurácia
    const acuracia = (filteredData.reduce((sum, r) => sum + r.acuracia_percentual, 0) / filteredData.length).toFixed(1);
    document.getElementById('kpi-acuracia').textContent = acuracia + '%';

    // Divergência
    const divergCount = filteredData.filter(r => r.divergencia === 1).length;
    const divergPct = ((divergCount / filteredData.length) * 100).toFixed(1);
    document.getElementById('kpi-divergencia').textContent = divergPct + '%';
}

// Actualizar gráficos
function updateCharts() {
    createVolumeChart();
    createProdutividadeChart();
    createTurnoChart();
    createDivergenciaChart();
    createEvolucaoChart();
}

// Gráfico 1: Volume por data
function createVolumeChart() {
    const groupByDate = {};

    filteredData.forEach(row => {
        if (!groupByDate[row.data]) {
            groupByDate[row.data] = 0;
        }
        groupByDate[row.data] += row.volume;
    });

    const dates = Object.keys(groupByDate).sort();
    const volumes = dates.map(d => groupByDate[d]);

    const trace = {
        x: dates,
        y: volumes,
        type: 'scatter',
        mode: 'lines+markers',
        line: { color: '#0078D4', width: 2 },
        marker: { size: 6, color: '#0078D4' },
        hovertemplate: '<b>%{x}</b><br>Volume: %{y} itens<extra></extra>'
    };

    const layout = {
        xaxis: { title: 'Data' },
        yaxis: { title: 'Volume (itens)' },
        margin: { l: 50, r: 30, t: 30, b: 50 },
        hovermode: 'x unified'
    };

    Plotly.newPlot('chart-volume', [trace], layout, { responsive: true });
}

// Gráfico 2: Produtividade por operador
function createProdutividadeChart() {
    const groupByOperador = {};

    filteredData.forEach(row => {
        if (!groupByOperador[row.operador]) {
            groupByOperador[row.operador] = { volume: 0, tempo: 0 };
        }
        groupByOperador[row.operador].volume += row.volume;
        groupByOperador[row.operador].tempo += row.tempo_processamento_minutos;
    });

    const operadores = Object.keys(groupByOperador).sort();
    const produtividades = operadores.map(op => {
        const tempo = groupByOperador[op].tempo;
        return tempo > 0 ? groupByOperador[op].volume / tempo : 0;
    }).map(p => p.toFixed(2));

    const trace = {
        x: operadores,
        y: produtividades.map(p => parseFloat(p)),
        type: 'bar',
        marker: { color: '#107C10' },
        hovertemplate: '<b>%{x}</b><br>Produtividade: %{y:.2f} itens/min<extra></extra>'
    };

    const layout = {
        xaxis: { title: 'Operador' },
        yaxis: { title: 'Produtividade (itens/min)' },
        margin: { l: 50, r: 30, t: 30, b: 80 }
    };

    Plotly.newPlot('chart-produtividade', [trace], layout, { responsive: true });
}

// Gráfico 3: Performance por turno
function createTurnoChart() {
    const turnos = ['Matutino', 'Vespertino', 'Noturno'];
    const slaByTurno = {};
    const acuraciaByTurno = {};

    turnos.forEach(t => {
        const turnoData = filteredData.filter(r => r.turno === t);
        if (turnoData.length > 0) {
            const sla = (turnoData.filter(r => r.sla_cumprido === 1).length / turnoData.length) * 100;
            const acuracia = turnoData.reduce((sum, r) => sum + r.acuracia_percentual, 0) / turnoData.length;
            slaByTurno[t] = sla.toFixed(1);
            acuraciaByTurno[t] = acuracia.toFixed(1);
        } else {
            slaByTurno[t] = 0;
            acuraciaByTurno[t] = 0;
        }
    });

    const trace1 = {
        x: turnos,
        y: turnos.map(t => parseFloat(slaByTurno[t])),
        type: 'bar',
        name: 'SLA %',
        marker: { color: '#0078D4' },
        hovertemplate: '<b>%{x}</b><br>SLA: %{y:.1f}%<extra></extra>'
    };

    const trace2 = {
        x: turnos,
        y: turnos.map(t => parseFloat(acuraciaByTurno[t])),
        type: 'bar',
        name: 'Acurácia %',
        marker: { color: '#107C10' },
        hovertemplate: '<b>%{x}</b><br>Acurácia: %{y:.1f}%<extra></extra>'
    };

    const layout = {
        barmode: 'group',
        xaxis: { title: 'Turno' },
        yaxis: { title: 'Percentual (%)' },
        margin: { l: 50, r: 30, t: 30, b: 50 }
    };

    Plotly.newPlot('chart-turno', [trace1, trace2], layout, { responsive: true });
}

// Gráfico 4: Divergências por categoria
function createDivergenciaChart() {
    const divergByCategoria = {};
    const countByCategoria = {};

    filteredData.forEach(row => {
        if (!divergByCategoria[row.categoria]) {
            divergByCategoria[row.categoria] = 0;
            countByCategoria[row.categoria] = 0;
        }
        if (row.divergencia === 1) {
            divergByCategoria[row.categoria]++;
        }
        countByCategoria[row.categoria]++;
    });

    const categorias = Object.keys(divergByCategoria).sort();
    const divergencias = categorias.map(c => {
        const count = countByCategoria[c];
        return count > 0 ? ((divergByCategoria[c] / count) * 100).toFixed(1) : 0;
    });

    const trace = {
        labels: categorias,
        values: divergencias.map(d => parseFloat(d)),
        type: 'pie',
        hovertemplate: '<b>%{label}</b><br>Taxa: %{value:.1f}%<extra></extra>'
    };

    const layout = {
        margin: { l: 30, r: 30, t: 30, b: 30 }
    };

    Plotly.newPlot('chart-divergencia', [trace], layout, { responsive: true });
}

// Gráfico 5: Evolución semanal
function createEvolucaoChart() {
    const groupByWeek = {};

    filteredData.forEach(row => {
        const date = new Date(row.data + 'T00:00:00');
        const week = 'Semana ' + Math.ceil((date.getDate()) / 7);

        if (!groupByWeek[week]) {
            groupByWeek[week] = { volume: 0, acuracia: 0, count: 0 };
        }

        groupByWeek[week].volume += row.volume;
        groupByWeek[week].acuracia += row.acuracia_percentual;
        groupByWeek[week].count++;
    });

    const weeks = Object.keys(groupByWeek).sort();
    const volumes = weeks.map(w => groupByWeek[w].volume);
    const acuracias = weeks.map(w => (groupByWeek[w].acuracia / groupByWeek[w].count).toFixed(1));

    const trace1 = {
        x: weeks,
        y: volumes,
        type: 'bar',
        name: 'Volume',
        marker: { color: '#0078D4' },
        yaxis: 'y',
        hovertemplate: '<b>%{x}</b><br>Volume: %{y} itens<extra></extra>'
    };

    const trace2 = {
        x: weeks,
        y: acuracias.map(a => parseFloat(a)),
        type: 'scatter',
        mode: 'lines+markers',
        name: 'Acurácia',
        marker: { size: 8, color: '#107C10' },
        yaxis: 'y2',
        hovertemplate: '<b>%{x}</b><br>Acurácia: %{y:.1f}%<extra></extra>'
    };

    const layout = {
        xaxis: { title: 'Semana' },
        yaxis: { title: 'Volume (itens)' },
        yaxis2: {
            title: 'Acurácia (%)',
            overlaying: 'y',
            side: 'right',
            range: [0, 100]
        },
        margin: { l: 50, r: 50, t: 30, b: 50 },
        hovermode: 'x unified'
    };

    Plotly.newPlot('chart-evolucao', [trace1, trace2], layout, { responsive: true });
}

// Mostrar erro
function showError(message) {
    const errorDiv = document.createElement('div');
    errorDiv.className = 'error';
    errorDiv.textContent = message;
    document.body.insertBefore(errorDiv, document.body.firstChild);
}
