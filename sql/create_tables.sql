-- Criação de tabelas para o Dashboard de Performance Logística
-- Cenário simulado - Projeto de Portfólio
-- PostgreSQL 12+
-- Author: José Pérez | Data: 2026

-- Tabela de Clientes (referenciada por outras tabelas)
CREATE TABLE IF NOT EXISTS clientes (
  id_cliente SERIAL PRIMARY KEY,
  nome_cliente VARCHAR(100) NOT NULL,
  cidade VARCHAR(50),
  regiao VARCHAR(50),
  data_cadastro DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Tabela de Produtos
CREATE TABLE IF NOT EXISTS produtos (
  id_produto SERIAL PRIMARY KEY,
  nome_produto VARCHAR(100) NOT NULL,
  categoria VARCHAR(50) NOT NULL,
  preco DECIMAL(10, 2) NOT NULL,
  peso_kg DECIMAL(8, 2)
);

-- Tabela de Pedidos
CREATE TABLE IF NOT EXISTS pedidos (
  id_pedido SERIAL PRIMARY KEY,
  data_pedido DATE NOT NULL DEFAULT CURRENT_DATE,
  cliente_id INT NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'Pendente',
  valor_total DECIMAL(10, 2) NOT NULL,
  CONSTRAINT fk_pedidos_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id_cliente) ON DELETE CASCADE
);

-- Tabela de Entregas
CREATE TABLE IF NOT EXISTS entregas (
  id_entrega SERIAL PRIMARY KEY,
  id_pedido INT NOT NULL,
  data_envio DATE NOT NULL,
  data_entrega DATE,
  tempo_entrega_dias INT,
  status_entrega VARCHAR(50) NOT NULL DEFAULT 'Pendente',
  CONSTRAINT fk_entregas_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido) ON DELETE CASCADE
);

-- Tabela de Estoque
CREATE TABLE IF NOT EXISTS estoque (
  id_estoque SERIAL PRIMARY KEY,
  id_produto INT NOT NULL,
  quantidade INT NOT NULL DEFAULT 0,
  localizacao VARCHAR(50),
  data_atualizacao DATE NOT NULL DEFAULT CURRENT_DATE,
  CONSTRAINT fk_estoque_produto FOREIGN KEY (id_produto) REFERENCES produtos(id_produto) ON DELETE CASCADE
);

-- Índices para performance
CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX idx_pedidos_data ON pedidos(data_pedido);
CREATE INDEX idx_entregas_pedido ON entregas(id_pedido);
CREATE INDEX idx_estoque_produto ON estoque(id_produto);
