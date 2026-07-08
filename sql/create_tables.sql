-- Criação de tabelas para o Dashboard de Performance Logística
-- Cenário simulado - Projeto de Portfólio
-- Author: José Pérez | Data: 2026

-- Tabela de Pedidos
CREATE TABLE IF NOT EXISTS pedidos (
      id_pedido INT PRIMARY KEY,
      data_pedido DATE NOT NULL,
      cliente_id INT NOT NULL,
  status VARCHAR(50),
  valor_total DECIMAL(10, 2),
  CONSTRAINT fk_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id_cliente)
);

-- Tabela de Clientes
CREATE TABLE IF NOT EXISTS clientes (
      id_cliente INT PRIMARY KEY,
  nome_cliente VARCHAR(100) NOT NULL,
  cidade VARCHAR(50),
  regiao VARCHAR(50),
      data_cadastro DATE
);

-- Tabela de Entregas
CREATE TABLE IF NOT EXISTS entregas (
      id_entrega INT PRIMARY KEY,
      id_pedido INT NOT NULL,
      data_envio DATE,
      data_entrega DATE,
      tempo_entrega_dias INT,
  status_entrega VARCHAR(50),
  CONSTRAINT fk_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
);

-- Tabela de Armazém
CREATE TABLE IF NOT EXISTS estoque (
      id_estoque INT PRIMARY KEY,
      id_produto INT NOT NULL,
      quantidade INT,
  localizacao VARCHAR(50),
      data_atualizacao DATE,
  CONSTRAINT fk_produto FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

-- Tabela de Produtos
CREATE TABLE IF NOT EXISTS produtos (
      id_produto INT PRIMARY KEY,
  nome_produto VARCHAR(100),
  categoria VARCHAR(50),
  preco DECIMAL(10, 2),
  peso_kg DECIMAL(8, 2)
);
