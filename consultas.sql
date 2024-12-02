--  Consulta de Produtos por Categoria
-- Aqui '' podemos escolher a categoria desejada, podendo ser filtrada pelo nome ou id_Categoria
SELECT 
    pr.id_produto,
    pr.nome AS produto_nome,
    pr.descricao,
    pr.preco,
    c.nome AS categoria_nome
FROM 
    produtos pr
INNER JOIN 
    categorias c ON pr.id_categoria = c.id_categoria
WHERE 
    c.nome = 'Eletrodomésticos'; 

---------------------------------------------------
--Consulta de Pedidos por Clientes
-- Esta consulta exibe os pedidos realizados por um cliente, incluindo os detalhes dos produtos, quantidades e valores totais.
SELECT 
    p.id_pedido,
    p.data_pedido,
    c.nome AS cliente_nome,
    pr.nome AS produto_nome,
    dp.quantidade,
    pr.preco,
    dp.quantidade * pr.preco AS total_item
FROM 
    pedidos p
INNER JOIN 
    clientes c ON p.id_cliente = c.id_cliente
INNER JOIN 
    detalhes_pedido dp ON p.id_pedido = dp.id_pedido
INNER JOIN 
    produtos pr ON dp.id_produto = pr.id_produto
WHERE 
    c.id_cliente = 1; 

-----------------------------------------------------
--Relatório de Estoque Baixo
--Identifica produtos com estoque abaixo de um valor de referência, no quaso escolhi '<10' como referencia 

SELECT 
    pr.id_produto,
    pr.nome AS produto_nome,
    SUM(v.quantidade) AS total_vendido,
    pr.preco,
    (SUM(v.quantidade) < 10) AS estoque_baixo
FROM 
    produtos pr
INNER JOIN 
    vendas v ON pr.id_produto = v.id_produto
GROUP BY 
    pr.id_produto, pr.nome, pr.preco
HAVING 
    SUM(v.quantidade) < 10;

-------------------------------------------------------
-- Relatorio das Vendas mensais
-- Análise de vendas realizadas por mês, considerando a quantidade vendida e o valor total. 
--A consulta considera que a data das vendas está na tabela vendas e a data do pedido está na tabela pedidos.

SELECT 
    EXTRACT(YEAR FROM p.data_pedido) AS ano,
    EXTRACT(MONTH FROM p.data_pedido) AS mes,
    pr.nome AS produto_nome,
    SUM(dp.quantidade) AS total_vendido,
    SUM(dp.quantidade * pr.preco) AS valor_total
FROM 
    pedidos p
INNER JOIN 
    detalhes_pedido dp ON p.id_pedido = dp.id_pedido
INNER JOIN 
    produtos pr ON dp.id_produto = pr.id_produto
GROUP BY 
    ano, mes, pr.id_produto
ORDER BY 
    ano, mes, total_vendido DESC;

---------------------------------------------------------

-- Relatório de Vendas por Região

--Análise de vendas por região, considerando a quantidade de vendas e o valor total. Esse relatório envolve a tabela vendas e a tabela regiao.

SELECT 
    r.nome AS regiao_nome,
    pr.nome AS produto_nome,
    SUM(v.quantidade) AS total_vendido,
    SUM(v.quantidade * pr.preco) AS valor_total
FROM 
    vendas v
INNER JOIN 
    regiao r ON v.id_regiao = r.id_regiao
INNER JOIN 
    produtos pr ON v.id_produto = pr.id_produto
GROUP BY 
    r.id_regiao, pr.id_produto
ORDER BY 
    valor_total DESC;