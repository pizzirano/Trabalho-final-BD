-- DDL do banco de dados Ecommerce

-- Criação de Dominios para dados comuns

 CREATE DOMAIN telDominio AS VARCHAR(20)
    CHECK (VALUE ~ '^\(?\d{2}\)?\s?\d{4,5}-?\d{4}$');

CREATE DOMAIN emailDominio AS VARCHAR(100)
    CHECK (VALUE ~ '^[\w\.-]+@[\w\.-]+\.\w{2,4}$');

CREATE DOMAIN precoDominio AS DECIMAL(10, 2)
    CHECK (VALUE >= 0);

CREATE DOMAIN quantidadeDominio AS INTEGER
    CHECK (VALUE >= 0);

-- Criação de Tabelas

CREATE TABLE categorias (
    id_categoria SERIAL PRIMARY KEY,
    nome VARCHAR(30) NOT NULL
);
 
CREATE TABLE produtos (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco precoDominio NOT NULL,
    id_categoria INTEGER,
    CONSTRAINT produto_categoria FOREIGN KEY (id_categoria) 
    REFERENCES categorias(id_categoria) ON DELETE RESTRICT
);

CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(30) NOT NULL,
    endereco VARCHAR(255),
    telefone telDominio,
    email emailDominio
);

CREATE TABLE pedidos (
    id_pedido SERIAL PRIMARY KEY,
    data_pedido DATE NOT NULL,
    id_cliente INTEGER,
    CONSTRAINT pedido_cliente FOREIGN KEY (id_cliente) 
    REFERENCES clientes(id_cliente) ON DELETE RESTRICT
);

CREATE TABLE detalhes_pedido (
    quantidade quantidadeDominio NOT NULL,
    id_pedido INTEGER,
    id_produto INTEGER,
    CONSTRAINT detalhes_pedido FOREIGN KEY (id_pedido) 
    REFERENCES pedidos(id_pedido) ON DELETE RESTRICT,
    CONSTRAINT detalhes_produto FOREIGN KEY (id_produto) 
    REFERENCES produtos(id_produto) ON DELETE RESTRICT
);

CREATE TABLE regiao (
    id_regiao SERIAL PRIMARY KEY,
    nome VARCHAR(30) NOT NULL
);

CREATE TABLE vendas (
    id_venda SERIAL PRIMARY KEY,
    quantidade quantidadeDominio NOT NULL,
    id_regiao INTEGER,
    id_produto INTEGER,
    CONSTRAINT venda_regiao FOREIGN KEY (id_regiao) 
    REFERENCES regiao(id_regiao) ON DELETE RESTRICT,
    CONSTRAINT venda_produto FOREIGN KEY (id_produto) 
    REFERENCES produtos(id_produto) ON DELETE RESTRICT
);