-- Star Schema: Dashboard Operacional Logístico
-- PostgreSQL 12+
-- Simulação de operações de centro de distribuição
-- Author: José Pérez | Data: 2026

-- ============================================
-- DIMENSÕES
-- ============================================

-- Tabela: Dimensão de Datas
CREATE TABLE IF NOT EXISTS dim_data (
    id_data SERIAL PRIMARY KEY,
    data_completa DATE NOT NULL UNIQUE,
    ano INT,
    mes INT,
    dia INT,
    trimestre INT,
    nome_mes VARCHAR(20),
    nome_dia_semana VARCHAR(20),
    semana_ano INT
);

-- Tabela: Dimensión de Produtos
CREATE TABLE IF NOT EXISTS dim_produto (
    id_produto SERIAL PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL UNIQUE,
    categoria VARCHAR(50) NOT NULL,
    peso_kg DECIMAL(8, 2)
);

-- Tabela: Dimensión de Operadores
CREATE TABLE IF NOT EXISTS dim_operador (
    id_operador SERIAL PRIMARY KEY,
    codigo_operador VARCHAR(20) NOT NULL UNIQUE,
    nome_operador VARCHAR(100),
    experiencia_meses INT,
    treinado BOOLEAN DEFAULT TRUE
);

-- Tabela: Dimensión de Turnos
CREATE TABLE IF NOT EXISTS dim_turno (
    id_turno SERIAL PRIMARY KEY,
    nome_turno VARCHAR(20) NOT NULL UNIQUE,
    hora_inicio TIME,
    hora_fim TIME
);

-- ============================================
-- TABELA DE FATOS
-- ============================================

-- Tabela: Fato de Operações (granularidade: uma operação = uma linha)
CREATE TABLE IF NOT EXISTS fato_operacoes (
    id_operacao SERIAL PRIMARY KEY,
    id_data INT NOT NULL,
    id_operador INT NOT NULL,
    id_turno INT NOT NULL,
    id_produto INT NOT NULL,
    volume INT NOT NULL,
    tempo_processamento_minutos INT NOT NULL,
    status VARCHAR(50),
    divergencia INT DEFAULT 0,
    acuracia_percentual INT,
    sla_cumprido INT,
    CONSTRAINT fk_data FOREIGN KEY (id_data) REFERENCES dim_data(id_data),
    CONSTRAINT fk_operador FOREIGN KEY (id_operador) REFERENCES dim_operador(id_operador),
    CONSTRAINT fk_turno FOREIGN KEY (id_turno) REFERENCES dim_turno(id_turno),
    CONSTRAINT fk_produto FOREIGN KEY (id_produto) REFERENCES dim_produto(id_produto)
);

-- ============================================
-- ÍNDICES PARA PERFORMANCE
-- ============================================

CREATE INDEX idx_fato_data ON fato_operacoes(id_data);
CREATE INDEX idx_fato_operador ON fato_operacoes(id_operador);
CREATE INDEX idx_fato_turno ON fato_operacoes(id_turno);
CREATE INDEX idx_fato_produto ON fato_operacoes(id_produto);
CREATE INDEX idx_dim_data ON dim_data(data_completa);
CREATE INDEX idx_dim_produto_categoria ON dim_produto(categoria);
CREATE INDEX idx_dim_operador_codigo ON dim_operador(codigo_operador);
