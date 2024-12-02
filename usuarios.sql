-Criação do usuário administrador do sistema de e-commerce
CREATE USER admin_ecommerce PASSWORD 'admin123456';

-- Criação do usuário gerente de estoque
CREATE USER gerente_estoque PASSWORD 'estoque123456';

-- Criação do usuário vendedor
CREATE USER vendedor PASSWORD 'venda123456';

-- Permissões para o administrador
GRANT SELECT, INSERT, UPDATE, DELETE ON produtos, pedidos, clientes, vendas, regiao, categorias, detalhes_pedido TO admin_ecommerce;

-- Permissões para o gerente de estoque
GRANT SELECT, INSERT, UPDATE ON produtos, categorias TO gerente_estoque;
GRANT SELECT ON vendas TO gerente_estoque;

-- Permissões para o vendedor
GRANT SELECT, INSERT ON pedidos, clientes, detalhes_pedido TO vendedor;
GRANT SELECT ON produtos, categorias TO vendedor;



