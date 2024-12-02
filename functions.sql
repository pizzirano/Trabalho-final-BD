-- Função para aplicar desconto a todos os produtos de uma categoria
-- Parâmetros:
-- p_id_categoria: ID da categoria dos produtos
-- p_desconto: porcentagem de desconto a ser aplicada
-- Retorna o número de produtos que tiveram o desconto aplicado.

CREATE OR REPLACE FUNCTION fn_Aplicar_Desconto_Categoria(
    p_id_categoria INTEGER,
    p_desconto DECIMAL(5, 2)
)
RETURNS INTEGER AS $$
DECLARE
    v_produtos_afetados INTEGER;
BEGIN
    -- Aplica o desconto a todos os produtos da categoria
    UPDATE produtos
    SET preco = preco - (preco * p_desconto / 100)
    WHERE id_categoria = p_id_categoria;

    -- Conta quantos produtos foram afetados
    GET DIAGNOSTICS v_produtos_afetados = ROW_COUNT;

    -- Retorna o número de produtos que tiveram o desconto aplicado
    RETURN v_produtos_afetados;
END;
$$ LANGUAGE plpgsql;

-- Chamando a Function que ira aplicar 10% de desconto aos produtos da categoria ID 2, ou seja os Eletrodomesticos 
SELECT fn_Aplicar_Desconto_Categoria(2, 10);  -- Aplica 10% de desconto aos produtos da categoria com ID 2

----------------------------------------------------------------------------
-- Função para calcular o total de vendas de um produto em uma região específica
-- Parâmetros:
-- p_id_produto: ID do produto
-- p_id_regiao: ID da região
-- Retorna o valor total de vendas do produto na região especificada.

CREATE OR REPLACE FUNCTION fn_Calcular_Vendas_Por_Regiao(
    p_id_produto INTEGER,
    p_id_regiao INTEGER
)
RETURNS DECIMAL(10, 2) AS $$
DECLARE
    v_total_vendas DECIMAL(10, 2);
BEGIN
    -- Calcula o total de vendas do produto na região especificada
    SELECT SUM(v.quantidade * pr.preco)
    INTO v_total_vendas
    FROM vendas v
    JOIN produtos pr ON v.id_produto = pr.id_produto
    WHERE v.id_produto = p_id_produto
    AND v.id_regiao = p_id_regiao;

    -- Se não houver vendas, retorna 0
    IF v_total_vendas IS NULL THEN
        RETURN 0;
    END IF;

    -- Retorna o total de vendas
    RETURN v_total_vendas;
END;
$$ LANGUAGE plpgsql;

-- Chamando function que retorna o total de vendas da regiao '1' ou seja Sudeste 
SELECT fn_Calcular_Vendas_Por_Regiao(2, 1);