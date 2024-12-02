-- Essa trigger ajuda a manter o estoque atualizado automaticamente
-- e evita que o sistema permita pedidos quando não houver estoque suficiente.
-- Objetivo: Atualizar automaticamente o estoque de um produto quando um pedido for realizado.
-- A trigger será acionada após a inserção de um novo item na tabela 'detalhes_pedido'
-- (ou seja, após a inserção de um pedido).
-- A trigger vai atualizar o estoque do produto subtraindo a quantidade do pedido.

CREATE OR REPLACE FUNCTION fn_atualizar_estoque_apos_pedido() 
RETURNS TRIGGER AS $$
BEGIN
    -- Atualiza o estoque do produto, subtraindo a quantidade pedida
    UPDATE produtos
    SET quantidade_estoque = quantidade_estoque - NEW.quantidade
    WHERE id_produto = NEW.id_produto;

    -- Retorna o novo registro inserido na tabela 'detalhes_pedido'
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criando a trigger 'trg_atualizar_estoque'
-- A trigger será acionada 'AFTER INSERT' na tabela 'detalhes_pedido'
-- Para cada nova linha inserida, ela chama a função 'fn_atualizar_estoque_apos_pedido'
-- que atualiza o estoque do produto correspondente.

CREATE TRIGGER trg_atualizar_estoque
AFTER INSERT ON detalhes_pedido
FOR EACH ROW
EXECUTE FUNCTION fn_atualizar_estoque_apos_pedido();

-- Teste: Ao inserir um novo pedido, por exemplo:
-- INSERT INTO detalhes_pedido (quantidade, id_pedido, id_produto) 
-- VALUES (3, 1, 2);

-- A trigger irá automaticamente reduzir a quantidade disponível do produto com id_produto = 2
-- no estoque. Se a quantidade em estoque não for suficiente para atender à quantidade do pedido (3),
-- a trigger gerará um erro.