-- DML do banco de dados Ecommerce 

-- Inclusão de 5 registros para cada tabela;

-- Inserindo categorias

INSERT INTO categorias (nome) 
VALUES 
('Livros'),
('Eletrodomésticos'),
('Vestuário'),
('Móveis'),
('Brinquedos');

-- Inserindo produtos
INSERT INTO produtos (nome, descricao, preco, id_categoria) 
VALUES 
('Cadeira de Escritório', 'Cadeira ergonômica para escritório', 199.99, 4),
('Livro: O Senhor dos Anéis', 'Livro de fantasia épica', 49.90, 1),
('Televisão LED 32"', 'Televisão de 32 polegadas, LED Full HD', 999.90, 2),
('Camisa Polo', 'Camisa polo masculina', 79.90, 3),
('Bicicleta Infantil', 'Bicicleta infantil para crianças', 299.90, 5);

-- Inserindo clientes
INSERT INTO clientes (nome, endereco, telefone, email) 
VALUES 
('João Silva', 'Rua A, 123', '11987654321', 'joao.silva@example.com'),
('Maria Oliveira', 'Rua B, 456', '21987654321', 'maria.oliveira@example.com'),
('Carlos Souza', 'Rua C, 789', '31987654321', 'carlos.souza@example.com'),
('Ana Santos', 'Rua D, 101', '41987654321', 'ana.santos@example.com'),
('Roberta Lima', 'Rua E, 202', '61987654321', 'roberta.lima@example.com');

-- Inserindo regiões
INSERT INTO regiao (nome) 
VALUES 
('Sudeste'),
('Nordeste'),
('Sul'),
('Centro-Oeste'),
('Norte');

-- Inserindo pedidos
INSERT INTO pedidos (data_pedido, id_cliente) 
VALUES 
('2023-09-01', 1),
('2020-07-12', 2),
('2024-05-30', 3),
('2024-12-20', 4),
('2024-10-01', 5);

-- Inserindo vendas
INSERT INTO vendas (quantidade, id_regiao, id_produto) 
VALUES 
(10, 1, 2),
(5, 2, 3),
(8, 3, 4),
(7, 4, 5),
(12, 5, 1);

-- Inserindo detalhes de pedidos
INSERT INTO detalhes_pedido (quantidade, id_pedido, id_produto) 
VALUES 
(2, 1, 2),
(3, 2, 3),
(1, 3, 4),
(5, 4, 5),
(4, 5, 1);