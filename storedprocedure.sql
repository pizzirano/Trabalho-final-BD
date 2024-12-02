-- Stored Procedure para cadastrar um novo cliente
-- Parâmetros:
-- p_nome (nome do cliente)
-- p_endereco (endereço do cliente)
-- p_telefone (telefone do cliente)
-- p_email (email do cliente)

CREATE OR REPLACE PROCEDURE sp_Cadastrar_Cliente(
    p_nome VARCHAR(30),
    p_endereco VARCHAR(255),
    p_telefone VARCHAR(20),
    p_email VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Inserir um novo cliente na tabela clientes
    INSERT INTO clientes (nome, endereco, telefone, email)
    VALUES (p_nome, p_endereco, p_telefone, p_email);
END;
$$;

--Chamando a Procedure 
CALL sp_Cadastrar_Cliente('João Silva', 'Rua A, 123', '11987654321', 'joao.silva@example.com');

------------------------------------------------------------
-- Stored Procedure para atualizar o preço de um produto
-- Parâmetros:
-- p_id_produto (ID do produto a ser atualizado)
-- p_novo_preco (novo preço do produto)

CREATE OR REPLACE PROCEDURE sp_Atualizar_Preco_Produto(
    p_id_produto INTEGER,
    p_novo_preco DECIMAL(10, 2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Atualiza o preço do produto com base no ID do produto
    UPDATE produtos
    SET preco = p_novo_preco
    WHERE id_produto = p_id_produto;

    -- Caso deseje verificar se a atualização foi realizada
    IF NOT FOUND THEN
        RAISE NOTICE 'Produto com ID % não encontrado.', p_id_produto;
    END IF;
END;
$$;

-- Chamando a procedure 

CALL sp_Atualizar_Preco_Produto(2, 150.99);