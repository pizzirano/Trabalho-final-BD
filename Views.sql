-- View para exibir as vendas por produto e região

-- Objetivo: Esta view mostra o total de vendas de cada produto por região, incluindo a quantidade e o valor total das vendas.

-- Ela une as tabelas de vendas, produtos e regiões para gerar o relatório.

CREATE OR REPLACE VIEW vw_vendas_por_produto_regiao AS
SELECT 
    pr.nome AS produto_nome,
    r.nome AS regiao_nome,
    SUM(v.quantidade) AS total_vendido,
    SUM(v.quantidade * pr.preco) AS valor_total_vendido
FROM 
    vendas v
JOIN 
    produtos pr ON v.id_produto = pr.id_produto
JOIN 
    regiao r ON v.id_regiao = r.id_regiao
GROUP BY 
    pr.id_produto, r.id_regiao
ORDER BY 
    valor_total_vendido DESC;

    -- Chamando a View 

    SELECT * FROM vw_vendas_por_produto_regiao;
---------------------------------------------------------------------------------


-- View para exibir os clientes e seus pedidos mais recentes

-- Objetivo: Esta view retorna os clientes com seu respectivo pedido mais recente, incluindo a data e o ID do pedido.

-- Ela utiliza as tabelas clientes e pedidos para obter as informações.

CREATE OR REPLACE VIEW vw_clientes_ultimos_pedidos AS
SELECT 
    c.nome AS cliente_nome,
    p.id_pedido,
    p.data_pedido
FROM 
    clientes c
JOIN 
    pedidos p ON c.id_cliente = p.id_cliente
WHERE 
    p.data_pedido = (
        SELECT MAX(data_pedido) 
        FROM pedidos 
        WHERE id_cliente = c.id_cliente
    );

    -- chamando view
	
	SELECT * FROM vw_clientes_ultimos_pedidos;