--
-- PostgreSQL database dump
--

-- Dumped from database version 15.3
-- Dumped by pg_dump version 15.3

-- Started on 2024-12-01 23:12:39

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 860 (class 1247 OID 36251)
-- Name: emaildominio; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.emaildominio AS character varying(100)
	CONSTRAINT emaildominio_check CHECK (((VALUE)::text ~ '^[\w\.-]+@[\w\.-]+\.\w{2,4}$'::text));


ALTER DOMAIN public.emaildominio OWNER TO postgres;

--
-- TOC entry 864 (class 1247 OID 36254)
-- Name: precodominio; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.precodominio AS numeric(10,2)
	CONSTRAINT precodominio_check CHECK ((VALUE >= (0)::numeric));


ALTER DOMAIN public.precodominio OWNER TO postgres;

--
-- TOC entry 868 (class 1247 OID 36257)
-- Name: quantidadedominio; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.quantidadedominio AS integer
	CONSTRAINT quantidadedominio_check CHECK ((VALUE >= 0));


ALTER DOMAIN public.quantidadedominio OWNER TO postgres;

--
-- TOC entry 856 (class 1247 OID 36248)
-- Name: teldominio; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.teldominio AS character varying(20)
	CONSTRAINT teldominio_check CHECK (((VALUE)::text ~ '^\(?\d{2}\)?\s?\d{4,5}-?\d{4}$'::text));


ALTER DOMAIN public.teldominio OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 36341)
-- Name: fn_aplicar_desconto_categoria(integer, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_aplicar_desconto_categoria(p_id_categoria integer, p_desconto numeric) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.fn_aplicar_desconto_categoria(p_id_categoria integer, p_desconto numeric) OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 36354)
-- Name: fn_atualizar_estoque_apos_pedido(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_atualizar_estoque_apos_pedido() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Atualiza o estoque do produto, subtraindo a quantidade pedida
    UPDATE produtos
    SET quantidade_estoque = quantidade_estoque - NEW.quantidade
    WHERE id_produto = NEW.id_produto;

    -- Retorna o novo registro inserido na tabela 'detalhes_pedido'
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_atualizar_estoque_apos_pedido() OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 36343)
-- Name: fn_calcular_vendas_por_regiao(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_calcular_vendas_por_regiao(p_id_produto integer, p_id_regiao integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.fn_calcular_vendas_por_regiao(p_id_produto integer, p_id_regiao integer) OWNER TO postgres;

--
-- TOC entry 230 (class 1255 OID 36340)
-- Name: sp_atualizar_preco_produto(integer, numeric); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_atualizar_preco_produto(IN p_id_produto integer, IN p_novo_preco numeric)
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


ALTER PROCEDURE public.sp_atualizar_preco_produto(IN p_id_produto integer, IN p_novo_preco numeric) OWNER TO postgres;

--
-- TOC entry 229 (class 1255 OID 36339)
-- Name: sp_cadastrar_cliente(character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_cadastrar_cliente(IN p_nome character varying, IN p_endereco character varying, IN p_telefone character varying, IN p_email character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Inserir um novo cliente na tabela clientes
    INSERT INTO clientes (nome, endereco, telefone, email)
    VALUES (p_nome, p_endereco, p_telefone, p_email);
END;
$$;


ALTER PROCEDURE public.sp_cadastrar_cliente(IN p_nome character varying, IN p_endereco character varying, IN p_telefone character varying, IN p_email character varying) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 36260)
-- Name: categorias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categorias (
    id_categoria integer NOT NULL,
    nome character varying(30) NOT NULL
);


ALTER TABLE public.categorias OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 36259)
-- Name: categorias_id_categoria_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categorias_id_categoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categorias_id_categoria_seq OWNER TO postgres;

--
-- TOC entry 3419 (class 0 OID 0)
-- Dependencies: 214
-- Name: categorias_id_categoria_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categorias_id_categoria_seq OWNED BY public.categorias.id_categoria;


--
-- TOC entry 219 (class 1259 OID 36281)
-- Name: clientes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clientes (
    id_cliente integer NOT NULL,
    nome character varying(30) NOT NULL,
    endereco character varying(255),
    telefone public.teldominio,
    email public.emaildominio
);


ALTER TABLE public.clientes OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 36280)
-- Name: clientes_id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.clientes_id_cliente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.clientes_id_cliente_seq OWNER TO postgres;

--
-- TOC entry 3420 (class 0 OID 0)
-- Dependencies: 218
-- Name: clientes_id_cliente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.clientes_id_cliente_seq OWNED BY public.clientes.id_cliente;


--
-- TOC entry 222 (class 1259 OID 36301)
-- Name: detalhes_pedido; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detalhes_pedido (
    quantidade public.quantidadedominio NOT NULL,
    id_pedido integer,
    id_produto integer
);


ALTER TABLE public.detalhes_pedido OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 36290)
-- Name: pedidos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pedidos (
    id_pedido integer NOT NULL,
    data_pedido date NOT NULL,
    id_cliente integer
);


ALTER TABLE public.pedidos OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 36289)
-- Name: pedidos_id_pedido_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pedidos_id_pedido_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pedidos_id_pedido_seq OWNER TO postgres;

--
-- TOC entry 3421 (class 0 OID 0)
-- Dependencies: 220
-- Name: pedidos_id_pedido_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pedidos_id_pedido_seq OWNED BY public.pedidos.id_pedido;


--
-- TOC entry 217 (class 1259 OID 36267)
-- Name: produtos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.produtos (
    id_produto integer NOT NULL,
    nome character varying(100) NOT NULL,
    descricao text,
    preco public.precodominio NOT NULL,
    id_categoria integer,
    quantidade_estoque integer DEFAULT 0
);


ALTER TABLE public.produtos OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 36266)
-- Name: produtos_id_produto_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.produtos_id_produto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.produtos_id_produto_seq OWNER TO postgres;

--
-- TOC entry 3422 (class 0 OID 0)
-- Dependencies: 216
-- Name: produtos_id_produto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.produtos_id_produto_seq OWNED BY public.produtos.id_produto;


--
-- TOC entry 224 (class 1259 OID 36315)
-- Name: regiao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.regiao (
    id_regiao integer NOT NULL,
    nome character varying(30) NOT NULL
);


ALTER TABLE public.regiao OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 36314)
-- Name: regiao_id_regiao_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.regiao_id_regiao_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.regiao_id_regiao_seq OWNER TO postgres;

--
-- TOC entry 3423 (class 0 OID 0)
-- Dependencies: 223
-- Name: regiao_id_regiao_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.regiao_id_regiao_seq OWNED BY public.regiao.id_regiao;


--
-- TOC entry 226 (class 1259 OID 36322)
-- Name: vendas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vendas (
    id_venda integer NOT NULL,
    quantidade public.quantidadedominio NOT NULL,
    id_regiao integer,
    id_produto integer
);


ALTER TABLE public.vendas OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 36321)
-- Name: vendas_id_venda_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vendas_id_venda_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vendas_id_venda_seq OWNER TO postgres;

--
-- TOC entry 3424 (class 0 OID 0)
-- Dependencies: 225
-- Name: vendas_id_venda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vendas_id_venda_seq OWNED BY public.vendas.id_venda;


--
-- TOC entry 228 (class 1259 OID 36349)
-- Name: vw_clientes_ultimos_pedidos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_clientes_ultimos_pedidos AS
 SELECT c.nome AS cliente_nome,
    p.id_pedido,
    p.data_pedido
   FROM (public.clientes c
     JOIN public.pedidos p ON ((c.id_cliente = p.id_cliente)))
  WHERE (p.data_pedido = ( SELECT max(pedidos.data_pedido) AS max
           FROM public.pedidos
          WHERE (pedidos.id_cliente = c.id_cliente)));


ALTER TABLE public.vw_clientes_ultimos_pedidos OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 36344)
-- Name: vw_vendas_por_produto_regiao; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_vendas_por_produto_regiao AS
SELECT
    NULL::character varying(100) AS produto_nome,
    NULL::character varying(30) AS regiao_nome,
    NULL::bigint AS total_vendido,
    NULL::numeric AS valor_total_vendido;


ALTER TABLE public.vw_vendas_por_produto_regiao OWNER TO postgres;

--
-- TOC entry 3231 (class 2604 OID 36263)
-- Name: categorias id_categoria; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias ALTER COLUMN id_categoria SET DEFAULT nextval('public.categorias_id_categoria_seq'::regclass);


--
-- TOC entry 3234 (class 2604 OID 36284)
-- Name: clientes id_cliente; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes ALTER COLUMN id_cliente SET DEFAULT nextval('public.clientes_id_cliente_seq'::regclass);


--
-- TOC entry 3235 (class 2604 OID 36293)
-- Name: pedidos id_pedido; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos ALTER COLUMN id_pedido SET DEFAULT nextval('public.pedidos_id_pedido_seq'::regclass);


--
-- TOC entry 3232 (class 2604 OID 36270)
-- Name: produtos id_produto; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produtos ALTER COLUMN id_produto SET DEFAULT nextval('public.produtos_id_produto_seq'::regclass);


--
-- TOC entry 3236 (class 2604 OID 36318)
-- Name: regiao id_regiao; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regiao ALTER COLUMN id_regiao SET DEFAULT nextval('public.regiao_id_regiao_seq'::regclass);


--
-- TOC entry 3237 (class 2604 OID 36325)
-- Name: vendas id_venda; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendas ALTER COLUMN id_venda SET DEFAULT nextval('public.vendas_id_venda_seq'::regclass);


--
-- TOC entry 3402 (class 0 OID 36260)
-- Dependencies: 215
-- Data for Name: categorias; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categorias (id_categoria, nome) FROM stdin;
1	Livros
2	Eletrodomésticos
3	Vestuário
4	Móveis
5	Brinquedos
\.


--
-- TOC entry 3406 (class 0 OID 36281)
-- Dependencies: 219
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clientes (id_cliente, nome, endereco, telefone, email) FROM stdin;
1	João Silva	Rua A, 123	11987654321	joao.silva@example.com
2	Maria Oliveira	Rua B, 456	21987654321	maria.oliveira@example.com
3	Carlos Souza	Rua C, 789	31987654321	carlos.souza@example.com
4	Ana Santos	Rua D, 101	41987654321	ana.santos@example.com
5	Roberta Lima	Rua E, 202	61987654321	roberta.lima@example.com
6	João Silva	Rua A, 123	11987654321	joao.silva@example.com
\.


--
-- TOC entry 3409 (class 0 OID 36301)
-- Dependencies: 222
-- Data for Name: detalhes_pedido; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.detalhes_pedido (quantidade, id_pedido, id_produto) FROM stdin;
2	1	2
3	2	3
1	3	4
5	4	5
4	5	1
3	1	2
\.


--
-- TOC entry 3408 (class 0 OID 36290)
-- Dependencies: 221
-- Data for Name: pedidos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pedidos (id_pedido, data_pedido, id_cliente) FROM stdin;
1	2023-09-01	1
2	2020-07-12	2
3	2024-05-30	3
4	2024-12-20	4
5	2024-10-01	5
\.


--
-- TOC entry 3404 (class 0 OID 36267)
-- Dependencies: 217
-- Data for Name: produtos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.produtos (id_produto, nome, descricao, preco, id_categoria, quantidade_estoque) FROM stdin;
1	Cadeira de Escritório	Cadeira ergonômica para escritório	199.99	4	0
4	Camisa Polo	Camisa polo masculina	79.90	3	0
5	Bicicleta Infantil	Bicicleta infantil para crianças	299.90	5	0
3	Televisão LED 32"	Televisão de 32 polegadas, LED Full HD	899.91	2	0
2	Livro: O Senhor dos Anéis	Livro de fantasia épica	150.99	1	-3
\.


--
-- TOC entry 3411 (class 0 OID 36315)
-- Dependencies: 224
-- Data for Name: regiao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.regiao (id_regiao, nome) FROM stdin;
1	Sudeste
2	Nordeste
3	Sul
4	Centro-Oeste
5	Norte
\.


--
-- TOC entry 3413 (class 0 OID 36322)
-- Dependencies: 226
-- Data for Name: vendas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vendas (id_venda, quantidade, id_regiao, id_produto) FROM stdin;
1	10	1	2
2	5	2	3
3	8	3	4
4	7	4	5
5	12	5	1
\.


--
-- TOC entry 3425 (class 0 OID 0)
-- Dependencies: 214
-- Name: categorias_id_categoria_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categorias_id_categoria_seq', 5, true);


--
-- TOC entry 3426 (class 0 OID 0)
-- Dependencies: 218
-- Name: clientes_id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clientes_id_cliente_seq', 6, true);


--
-- TOC entry 3427 (class 0 OID 0)
-- Dependencies: 220
-- Name: pedidos_id_pedido_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pedidos_id_pedido_seq', 5, true);


--
-- TOC entry 3428 (class 0 OID 0)
-- Dependencies: 216
-- Name: produtos_id_produto_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.produtos_id_produto_seq', 5, true);


--
-- TOC entry 3429 (class 0 OID 0)
-- Dependencies: 223
-- Name: regiao_id_regiao_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.regiao_id_regiao_seq', 5, true);


--
-- TOC entry 3430 (class 0 OID 0)
-- Dependencies: 225
-- Name: vendas_id_venda_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vendas_id_venda_seq', 5, true);


--
-- TOC entry 3239 (class 2606 OID 36265)
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (id_categoria);


--
-- TOC entry 3243 (class 2606 OID 36288)
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id_cliente);


--
-- TOC entry 3245 (class 2606 OID 36295)
-- Name: pedidos pedidos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_pkey PRIMARY KEY (id_pedido);


--
-- TOC entry 3241 (class 2606 OID 36274)
-- Name: produtos produtos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produtos
    ADD CONSTRAINT produtos_pkey PRIMARY KEY (id_produto);


--
-- TOC entry 3247 (class 2606 OID 36320)
-- Name: regiao regiao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regiao
    ADD CONSTRAINT regiao_pkey PRIMARY KEY (id_regiao);


--
-- TOC entry 3249 (class 2606 OID 36327)
-- Name: vendas vendas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendas
    ADD CONSTRAINT vendas_pkey PRIMARY KEY (id_venda);


--
-- TOC entry 3399 (class 2618 OID 36347)
-- Name: vw_vendas_por_produto_regiao _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.vw_vendas_por_produto_regiao AS
 SELECT pr.nome AS produto_nome,
    r.nome AS regiao_nome,
    sum((v.quantidade)::integer) AS total_vendido,
    sum(((v.quantidade)::numeric * (pr.preco)::numeric)) AS valor_total_vendido
   FROM ((public.vendas v
     JOIN public.produtos pr ON ((v.id_produto = pr.id_produto)))
     JOIN public.regiao r ON ((v.id_regiao = r.id_regiao)))
  GROUP BY pr.id_produto, r.id_regiao
  ORDER BY (sum(((v.quantidade)::numeric * (pr.preco)::numeric))) DESC;


--
-- TOC entry 3256 (class 2620 OID 36358)
-- Name: detalhes_pedido trg_atualizar_estoque; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_atualizar_estoque AFTER INSERT ON public.detalhes_pedido FOR EACH ROW EXECUTE FUNCTION public.fn_atualizar_estoque_apos_pedido();


--
-- TOC entry 3252 (class 2606 OID 36304)
-- Name: detalhes_pedido detalhes_pedido; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalhes_pedido
    ADD CONSTRAINT detalhes_pedido FOREIGN KEY (id_pedido) REFERENCES public.pedidos(id_pedido) ON DELETE RESTRICT;


--
-- TOC entry 3253 (class 2606 OID 36309)
-- Name: detalhes_pedido detalhes_produto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalhes_pedido
    ADD CONSTRAINT detalhes_produto FOREIGN KEY (id_produto) REFERENCES public.produtos(id_produto) ON DELETE RESTRICT;


--
-- TOC entry 3251 (class 2606 OID 36296)
-- Name: pedidos pedido_cliente; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedido_cliente FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente) ON DELETE RESTRICT;


--
-- TOC entry 3250 (class 2606 OID 36275)
-- Name: produtos produto_categoria; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produtos
    ADD CONSTRAINT produto_categoria FOREIGN KEY (id_categoria) REFERENCES public.categorias(id_categoria) ON DELETE RESTRICT;


--
-- TOC entry 3254 (class 2606 OID 36333)
-- Name: vendas venda_produto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendas
    ADD CONSTRAINT venda_produto FOREIGN KEY (id_produto) REFERENCES public.produtos(id_produto) ON DELETE RESTRICT;


--
-- TOC entry 3255 (class 2606 OID 36328)
-- Name: vendas venda_regiao; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendas
    ADD CONSTRAINT venda_regiao FOREIGN KEY (id_regiao) REFERENCES public.regiao(id_regiao) ON DELETE RESTRICT;


-- Completed on 2024-12-01 23:12:39

--
-- PostgreSQL database dump complete
--

