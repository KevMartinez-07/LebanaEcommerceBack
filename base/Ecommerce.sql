--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

-- Started on 2025-08-25 19:28:57

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 233 (class 1255 OID 16491)
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$;


ALTER FUNCTION public.set_updated_at() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 224 (class 1259 OID 16424)
-- Name: cart_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_items (
    cartitemid integer NOT NULL,
    cartid integer,
    productid integer,
    quantity integer NOT NULL,
    price numeric(12,2) NOT NULL,
    CONSTRAINT cart_items_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.cart_items OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16423)
-- Name: cart_items_cartitemid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cart_items_cartitemid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cart_items_cartitemid_seq OWNER TO postgres;

--
-- TOC entry 4894 (class 0 OID 0)
-- Dependencies: 223
-- Name: cart_items_cartitemid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cart_items_cartitemid_seq OWNED BY public.cart_items.cartitemid;


--
-- TOC entry 222 (class 1259 OID 16410)
-- Name: carts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.carts (
    cartid integer NOT NULL,
    userid integer,
    status character varying(20) DEFAULT 'OPEN'::character varying,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.carts OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16409)
-- Name: carts_cartid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.carts_cartid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.carts_cartid_seq OWNER TO postgres;

--
-- TOC entry 4895 (class 0 OID 0)
-- Dependencies: 221
-- Name: carts_cartid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.carts_cartid_seq OWNED BY public.carts.cartid;


--
-- TOC entry 232 (class 1259 OID 16496)
-- Name: mp_webhooks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mp_webhooks (
    id bigint NOT NULL,
    type text,
    data_id bigint,
    payload jsonb,
    received_at timestamp with time zone DEFAULT now(),
    processed boolean DEFAULT false,
    error text
);


ALTER TABLE public.mp_webhooks OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16495)
-- Name: mp_webhooks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mp_webhooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mp_webhooks_id_seq OWNER TO postgres;

--
-- TOC entry 4896 (class 0 OID 0)
-- Dependencies: 231
-- Name: mp_webhooks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mp_webhooks_id_seq OWNED BY public.mp_webhooks.id;


--
-- TOC entry 228 (class 1259 OID 16456)
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    orderitemid integer NOT NULL,
    orderid integer,
    productid integer,
    quantity integer NOT NULL,
    price numeric(12,2) NOT NULL
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16455)
-- Name: order_items_orderitemid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_orderitemid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_orderitemid_seq OWNER TO postgres;

--
-- TOC entry 4897 (class 0 OID 0)
-- Dependencies: 227
-- Name: order_items_orderitemid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_orderitemid_seq OWNED BY public.order_items.orderitemid;


--
-- TOC entry 230 (class 1259 OID 16473)
-- Name: order_payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_payments (
    id bigint NOT NULL,
    orderid integer,
    provider text DEFAULT 'mercado_pago'::text,
    mp_payment_id bigint,
    mp_preference_id text,
    external_reference text,
    status text,
    status_detail text,
    amount numeric(12,2),
    currency character varying(3),
    payer_email text,
    raw jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_checked_at timestamp with time zone
);


ALTER TABLE public.order_payments OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16472)
-- Name: order_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_payments_id_seq OWNER TO postgres;

--
-- TOC entry 4898 (class 0 OID 0)
-- Dependencies: 229
-- Name: order_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_payments_id_seq OWNED BY public.order_payments.id;


--
-- TOC entry 226 (class 1259 OID 16442)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    orderid integer NOT NULL,
    userid integer,
    total numeric(14,2) NOT NULL,
    status character varying(20) DEFAULT 'NEW'::character varying,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16441)
-- Name: orders_orderid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_orderid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_orderid_seq OWNER TO postgres;

--
-- TOC entry 4899 (class 0 OID 0)
-- Dependencies: 225
-- Name: orders_orderid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_orderid_seq OWNED BY public.orders.orderid;


--
-- TOC entry 218 (class 1259 OID 16390)
-- Name: productos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productos (
    productoid integer NOT NULL,
    codigo character varying(20) NOT NULL,
    descripcion character varying(100) NOT NULL,
    descripamplia character varying(7000),
    unidadid integer,
    stkminimo numeric(18,3),
    stkmaximo numeric(18,3),
    inhabilitado integer,
    gruposku character varying(1),
    codbarra character varying(50),
    precio numeric(12,2) DEFAULT 0 NOT NULL,
    imagen bytea
);


ALTER TABLE public.productos OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16389)
-- Name: productos_productoid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.productos_productoid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.productos_productoid_seq OWNER TO postgres;

--
-- TOC entry 4900 (class 0 OID 0)
-- Dependencies: 217
-- Name: productos_productoid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.productos_productoid_seq OWNED BY public.productos.productoid;


--
-- TOC entry 220 (class 1259 OID 16399)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    userid integer NOT NULL,
    email character varying(100) NOT NULL,
    passwordhash character varying(200) NOT NULL,
    fullname character varying(100),
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16398)
-- Name: users_userid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_userid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_userid_seq OWNER TO postgres;

--
-- TOC entry 4901 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_userid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_userid_seq OWNED BY public.users.userid;


--
-- TOC entry 4684 (class 2604 OID 16427)
-- Name: cart_items cartitemid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items ALTER COLUMN cartitemid SET DEFAULT nextval('public.cart_items_cartitemid_seq'::regclass);


--
-- TOC entry 4681 (class 2604 OID 16413)
-- Name: carts cartid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carts ALTER COLUMN cartid SET DEFAULT nextval('public.carts_cartid_seq'::regclass);


--
-- TOC entry 4693 (class 2604 OID 16499)
-- Name: mp_webhooks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mp_webhooks ALTER COLUMN id SET DEFAULT nextval('public.mp_webhooks_id_seq'::regclass);


--
-- TOC entry 4688 (class 2604 OID 16459)
-- Name: order_items orderitemid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN orderitemid SET DEFAULT nextval('public.order_items_orderitemid_seq'::regclass);


--
-- TOC entry 4689 (class 2604 OID 16476)
-- Name: order_payments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_payments ALTER COLUMN id SET DEFAULT nextval('public.order_payments_id_seq'::regclass);


--
-- TOC entry 4685 (class 2604 OID 16445)
-- Name: orders orderid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN orderid SET DEFAULT nextval('public.orders_orderid_seq'::regclass);


--
-- TOC entry 4677 (class 2604 OID 16393)
-- Name: productos productoid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos ALTER COLUMN productoid SET DEFAULT nextval('public.productos_productoid_seq'::regclass);


--
-- TOC entry 4679 (class 2604 OID 16402)
-- Name: users userid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN userid SET DEFAULT nextval('public.users_userid_seq'::regclass);


--
-- TOC entry 4880 (class 0 OID 16424)
-- Dependencies: 224
-- Data for Name: cart_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_items (cartitemid, cartid, productid, quantity, price) FROM stdin;
\.


--
-- TOC entry 4878 (class 0 OID 16410)
-- Dependencies: 222
-- Data for Name: carts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.carts (cartid, userid, status, created_at) FROM stdin;
\.


--
-- TOC entry 4888 (class 0 OID 16496)
-- Dependencies: 232
-- Data for Name: mp_webhooks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mp_webhooks (id, type, data_id, payload, received_at, processed, error) FROM stdin;
\.


--
-- TOC entry 4884 (class 0 OID 16456)
-- Dependencies: 228
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (orderitemid, orderid, productid, quantity, price) FROM stdin;
1	2	1	1	0.00
2	2	1	1	0.00
3	2	1	1	0.00
4	2	1	1	0.00
5	2	1	1	0.00
6	2	11	1	0.00
7	2	1	1	0.00
8	2	13	1	0.00
9	2	5	1	0.00
10	3	13	1	0.00
11	3	13	1	0.00
12	3	5	1	0.00
13	3	5	1	0.00
14	4	11	1	0.00
15	4	11	1	0.00
16	4	11	1	0.00
17	4	11	1	0.00
18	4	11	1	0.00
19	4	11	1	0.00
20	4	11	1	0.00
21	4	11	1	0.00
22	5	11	1	0.00
23	5	5	1	0.00
24	5	13	1	0.00
25	5	10	1	0.00
26	5	9	1	0.00
27	5	3	1	0.00
28	6	11	1	0.00
29	6	1	1	0.00
30	6	1	1	0.00
31	6	1	1	0.00
32	6	1	1	0.00
33	6	1	1	0.00
34	6	1	1	0.00
35	6	1	1	0.00
36	6	13	1	0.00
37	6	13	1	0.00
38	6	5	1	0.00
39	6	11	1	0.00
40	6	62	1	0.00
41	6	93	1	0.00
42	6	28	1	0.00
43	6	33	1	0.00
44	6	54	1	0.00
45	6	18	1	0.00
46	7	25	1	0.00
47	7	25	1	0.00
48	7	20	1	0.00
49	7	20	1	0.00
50	7	20	1	0.00
51	7	11	1	0.00
52	7	11	1	0.00
53	8	1	1	100.00
54	8	1	1	100.00
55	8	1	1	100.00
56	8	3	1	100.00
57	8	64	1	224.24
58	8	1	1	100.00
59	8	100	1	250.85
60	8	100	1	250.85
61	8	98	1	254.47
62	8	98	1	254.47
63	8	98	1	254.47
64	8	38	1	330.14
65	8	38	1	330.14
66	8	38	1	330.14
67	8	40	1	280.44
68	8	40	1	280.44
69	8	39	1	296.37
70	8	39	1	296.37
71	8	63	1	234.93
72	8	63	1	234.93
73	8	63	1	234.93
74	8	64	1	224.24
75	8	64	1	224.24
76	8	62	1	125.76
77	8	62	1	125.76
\.


--
-- TOC entry 4886 (class 0 OID 16473)
-- Dependencies: 230
-- Data for Name: order_payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_payments (id, orderid, provider, mp_payment_id, mp_preference_id, external_reference, status, status_detail, amount, currency, payer_email, raw, created_at, updated_at, last_checked_at) FROM stdin;
\.


--
-- TOC entry 4882 (class 0 OID 16442)
-- Dependencies: 226
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (orderid, userid, total, status, created_at) FROM stdin;
2	1	0.00	pendiente	2025-07-21 22:17:25.939919
3	1	0.00	pendiente	2025-07-21 22:19:30.040251
4	1	0.00	pendiente	2025-07-27 18:56:05.345652
5	1	0.00	pendiente	2025-07-27 19:30:05.260969
6	1	0.00	pendiente	2025-08-10 18:45:06.097493
7	1	0.00	pendiente	2025-08-10 20:43:39.078466
8	1	5538.18	pendiente	2025-08-25 18:49:35.044221
\.


--
-- TOC entry 4874 (class 0 OID 16390)
-- Dependencies: 218
-- Data for Name: productos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.productos (productoid, codigo, descripcion, descripamplia, unidadid, stkminimo, stkmaximo, inhabilitado, gruposku, codbarra, precio, imagen) FROM stdin;
1	VST1001	Blusa de lino blanca	Blusa fresca de lino 100% natural, ideal para verano.	1	5.000	30.000	0	A	7790000000011	100.00	\N
2	JNS1002	Jeans skinny azul	Jeans entallados de tiro alto, con efecto push-up.	1	10.000	100.000	0	A	7790000000012	100.00	\N
3	DRS1003	Vestido floral corto	Vestido con estampado floral y escote en V. Ideal para primavera.	1	3.000	20.000	0	A	7790000000013	100.00	\N
4	TSH1004	Remera básica negra	Remera de algodón suave, cuello redondo. Must-have de temporada.	1	20.000	150.000	0	A	7790000000014	100.00	\N
5	JKT1005	Campera de jean	Campera clásica de denim con botones metálicos.	1	2.000	15.000	0	A	7790000000015	100.00	\N
6	SKT1006	Pollera plisada rosa	Pollera midi plisada de tela liviana, con cintura elástica.	1	5.000	25.000	0	A	7790000000016	100.00	\N
7	SWT1007	Sweater oversize beige	Sweater tejido de hilo grueso, corte holgado.	1	3.000	18.000	0	A	7790000000017	100.00	\N
8	TOP1008	Top de encaje negro	Top elegante de encaje con breteles finos.	1	5.000	20.000	0	A	7790000000018	100.00	\N
9	DRS1009	Vestido midi satinado	Vestido de fiesta con caída sedosa, escote cruzado.	1	2.000	10.000	0	A	7790000000019	100.00	\N
10	PNT1010	Pantalón palazzo negro	Pantalón suelto y elegante de tiro alto con pinzas.	1	5.000	30.000	0	A	7790000000020	100.00	\N
11	BLZ1011	Blazer blanco	Blazer entallado con solapa clásica y un botón.	1	2.000	12.000	0	A	7790000000021	100.00	\N
12	SHR1012	Short de lino beige	Short liviano, ideal para clima cálido. Pretina elástica.	1	8.000	40.000	0	A	7790000000022	100.00	\N
13	BOD1013	Body negro manga larga	Body ajustado con escote cuadrado. Ideal para combinar con jeans.	1	4.000	20.000	0	A	7790000000023	100.00	\N
14	TSH1014	Remera estampada	Remera de algodón con estampado “Lebana Vibes”.	1	10.000	100.000	0	A	7790000000024	100.00	\N
15	JMP1015	Enterito de verano	Mono corto con botones frontales y bolsillos laterales.	1	3.000	20.000	0	A	7790000000025	100.00	\N
16	PRD0016	Falda plisada negra	Diseño moderno y cómodo para el uso diario.	1	4.737	17.969	0	A	7790000000026	204.41	\N
17	PRD0017	Pantalón ancho beige	Tejido suave que proporciona máximo confort.	1	6.601	55.832	0	A	7790000000027	288.11	\N
18	PRD0018	Chaqueta bomber azul	Estilo contemporáneo con acabados finos.	1	5.284	33.078	0	A	7790000000028	330.53	\N
19	PRD0019	Camisa de lino celeste	Disponible en varias tallas y colores.	1	11.527	52.720	0	A	7790000000029	125.80	\N
20	PRD0020	Abrigo largo camel	Versátil y fácil de combinar con otros estilos.	1	5.715	36.948	0	A	7790000000030	227.13	\N
21	PRD0021	Top con hombros descubiertos	Estilo contemporáneo con acabados finos.	1	9.341	66.872	0	A	7790000000031	126.58	\N
22	PRD0022	Pantalón cargo beige	Versátil y fácil de combinar con otros estilos.	1	7.889	59.487	0	A	7790000000032	177.13	\N
23	PRD0023	Vestido midi rojo	Ligero y transpirable, perfecto para verano.	1	9.124	87.878	0	A	7790000000033	223.51	\N
24	PRD0024	Camisa casual verde	Tejido suave que proporciona máximo confort.	1	6.830	20.840	0	A	7790000000034	115.43	\N
25	PRD0025	Abrigo impermeable negro	Estilo contemporáneo con acabados finos.	1	7.773	29.891	0	A	7790000000035	147.92	\N
26	PRD0026	Chaqueta acolchada roja	Resistente y duradero, pensado para uso frecuente.	1	10.158	92.549	0	A	7790000000036	126.99	\N
27	PRD0027	Sweater cuello alto gris	Versátil y fácil de combinar con otros estilos.	1	7.287	70.621	0	A	7790000000037	207.76	\N
28	PRD0028	Falda corta negra	Corte clásico con detalles elegantes.	1	9.758	96.927	0	A	7790000000038	317.49	\N
29	PRD0029	Vestido largo de gasa	Resistente y duradero, pensado para uso frecuente.	1	6.193	24.341	0	A	7790000000039	170.36	\N
30	PRD0030	Camisa sin mangas blanca	Ligero y transpirable, perfecto para verano.	1	6.806	31.687	0	A	7790000000040	178.28	\N
31	PRD0031	Blusa manga larga blanca	Prenda confeccionada con materiales de alta calidad.	1	8.678	53.446	0	A	7790000000041	316.71	\N
32	PRD0032	Sweater estampado gris	Estilo contemporáneo con acabados finos.	1	10.488	55.861	0	A	7790000000042	162.84	\N
33	PRD0033	Falda acampanada verde	Ligero y transpirable, perfecto para verano.	1	5.332	27.474	0	A	7790000000043	215.65	\N
34	PRD0034	Camisa estampada flores	Ligero y transpirable, perfecto para verano.	1	10.176	79.097	0	A	7790000000044	197.74	\N
35	PRD0035	Sweater cuello redondo azul	Diseño moderno y cómodo para el uso diario.	1	11.614	55.060	0	A	7790000000045	305.86	\N
36	PRD0036	Top sin mangas azul	Disponible en varias tallas y colores.	1	7.105	65.089	0	A	7790000000046	202.12	\N
37	PRD0037	Sweater cuello alto gris	Versátil y fácil de combinar con otros estilos.	1	5.735	43.824	0	A	7790000000047	98.61	\N
38	PRD0038	Vestido camisero beige	Versátil y fácil de combinar con otros estilos.	1	6.199	32.971	0	A	7790000000048	330.14	\N
39	PRD0039	Pantalón de cuero negro	Diseño moderno y cómodo para el uso diario.	1	5.504	26.948	0	A	7790000000049	296.37	\N
40	PRD0040	Camisa estampada tropical	Versátil y fácil de combinar con otros estilos.	1	5.069	29.271	0	A	7790000000050	280.44	\N
41	PRD0041	Sweater trenzado beige	Prenda confeccionada con materiales de alta calidad.	1	8.374	63.764	0	A	7790000000051	252.14	\N
42	PRD0042	Camisa de lino celeste	Disponible en varias tallas y colores.	1	10.132	89.665	0	A	7790000000052	163.07	\N
43	PRD0043	Top de encaje rojo	Corte clásico con detalles elegantes.	1	5.597	21.873	0	A	7790000000053	157.66	\N
44	PRD0044	Blusa satinada beige	Corte clásico con detalles elegantes.	1	10.469	93.985	0	A	7790000000054	271.50	\N
45	PRD0045	Blusa satinada beige	Versátil y fácil de combinar con otros estilos.	1	11.349	109.899	0	A	7790000000055	297.69	\N
46	PRD0046	Camisa formal blanca	Diseño moderno y cómodo para el uso diario.	1	6.038	40.113	0	A	7790000000056	104.84	\N
47	PRD0047	Pantalón deportivo azul	Diseño moderno y cómodo para el uso diario.	1	7.532	33.484	0	A	7790000000057	236.23	\N
48	PRD0048	Chaleco de lana marrón	Prenda confeccionada con materiales de alta calidad.	1	11.974	106.492	0	A	7790000000058	251.94	\N
49	PRD0049	Vestido camisero beige	Diseño moderno y cómodo para el uso diario.	1	8.898	68.208	0	A	7790000000059	129.64	\N
50	PRD0050	Sudadera con capucha roja	Estilo contemporáneo con acabados finos.	1	2.680	9.151	0	A	7790000000060	210.63	\N
51	PRD0051	Sweater cropped rosa	Prenda confeccionada con materiales de alta calidad.	1	11.573	75.845	0	A	7790000000061	166.81	\N
52	PRD0052	Vestido de encaje blanco	Disponible en varias tallas y colores.	1	8.823	52.137	0	A	7790000000062	320.17	\N
53	PRD0053	Sweater cuello alto blanco	Tejido suave que proporciona máximo confort.	1	3.549	33.209	0	A	7790000000063	102.08	\N
54	PRD0054	Chaqueta bomber azul	Corte clásico con detalles elegantes.	1	8.007	28.380	0	A	7790000000064	181.97	\N
55	PRD0055	Vestido de encaje blanco	Resistente y duradero, pensado para uso frecuente.	1	2.104	20.462	0	A	7790000000065	121.88	\N
56	PRD0056	Top deportivo negro	Tejido suave que proporciona máximo confort.	1	11.050	36.490	0	A	7790000000066	234.52	\N
57	PRD0057	Pantalón jogger gris	Prenda confeccionada con materiales de alta calidad.	1	10.656	55.371	0	A	7790000000067	251.67	\N
58	PRD0058	Pantalón capri negro	Versátil y fácil de combinar con otros estilos.	1	2.871	26.775	0	A	7790000000068	114.70	\N
59	PRD0059	Pantalón de vestir azul	Versátil y fácil de combinar con otros estilos.	1	2.137	11.994	0	A	7790000000069	264.80	\N
60	PRD0060	Vestido camisero verde	Disponible en varias tallas y colores.	1	9.473	46.074	0	A	7790000000070	278.81	\N
61	PRD0061	Sudadera con capucha roja	Prenda confeccionada con materiales de alta calidad.	1	11.355	63.977	0	A	7790000000071	347.19	\N
62	PRD0062	Falda acampanada verde	Diseño moderno y cómodo para el uso diario.	1	5.727	44.771	0	A	7790000000072	125.76	\N
63	PRD0063	Top deportivo negro	Resistente y duradero, pensado para uso frecuente.	1	11.349	45.123	0	A	7790000000073	234.93	\N
64	PRD0064	Pantalón jogger negro	Resistente y duradero, pensado para uso frecuente.	1	2.876	11.830	0	A	7790000000074	224.24	\N
65	PRD0065	Vestido camisero beige	Diseño moderno y cómodo para el uso diario.	1	6.575	56.619	0	A	7790000000075	116.29	\N
66	PRD0066	Top básico blanco	Tejido suave que proporciona máximo confort.	1	6.595	49.872	0	A	7790000000076	124.45	\N
67	PRD0067	Blusa manga corta roja	Disponible en varias tallas y colores.	1	8.210	31.530	0	A	7790000000077	148.93	\N
68	PRD0068	Camisa sin mangas blanca	Prenda confeccionada con materiales de alta calidad.	1	11.679	54.365	0	A	7790000000078	138.90	\N
69	PRD0069	Pantalón chino arena	Corte clásico con detalles elegantes.	1	6.658	48.230	0	A	7790000000079	296.01	\N
70	PRD0070	Top de encaje negro	Ligero y transpirable, perfecto para verano.	1	6.351	40.373	0	A	7790000000080	90.57	\N
71	PRD0071	Abrigo acolchado azul	Ideal para ocasiones especiales o uso casual.	1	6.707	57.615	0	A	7790000000081	144.83	\N
72	PRD0072	Campera rompeviento azul	Versátil y fácil de combinar con otros estilos.	1	2.585	23.754	0	A	7790000000082	95.82	\N
73	PRD0073	Sweater estampado gris	Tejido suave que proporciona máximo confort.	1	9.336	39.615	0	A	7790000000083	99.56	\N
74	PRD0074	Top básico gris	Diseño moderno y cómodo para el uso diario.	1	6.044	55.983	0	A	7790000000084	130.10	\N
75	PRD0075	Top de encaje rojo	Resistente y duradero, pensado para uso frecuente.	1	6.949	21.144	0	A	7790000000085	122.36	\N
76	PRD0076	Vestido midi rojo	Corte clásico con detalles elegantes.	1	2.910	21.196	0	A	7790000000086	325.14	\N
77	PRD0077	Camisa vaquera azul	Disponible en varias tallas y colores.	1	6.089	57.949	0	A	7790000000087	231.65	\N
78	PRD0078	Vestido camisero azul	Ligero y transpirable, perfecto para verano.	1	8.693	54.030	0	A	7790000000088	148.22	\N
79	PRD0079	Top deportivo negro	Ligero y transpirable, perfecto para verano.	1	4.546	21.689	0	A	7790000000089	102.31	\N
80	PRD0080	Top sin mangas azul	Corte clásico con detalles elegantes.	1	11.618	77.275	0	A	7790000000090	326.53	\N
81	PRD0081	Sweater oversize verde	Ligero y transpirable, perfecto para verano.	1	4.474	43.148	0	A	7790000000091	269.42	\N
82	PRD0082	Vestido de encaje blanco	Resistente y duradero, pensado para uso frecuente.	1	4.541	35.857	0	A	7790000000092	151.46	\N
83	PRD0083	Falda corta negra	Prenda confeccionada con materiales de alta calidad.	1	3.819	25.794	0	A	7790000000093	207.46	\N
84	PRD0084	Pantalón ancho beige	Disponible en varias tallas y colores.	1	5.994	38.391	0	A	7790000000094	91.29	\N
85	PRD0085	Camisa formal blanca	Prenda confeccionada con materiales de alta calidad.	1	9.706	80.307	0	A	7790000000095	227.49	\N
86	PRD0086	Vestido largo estampado	Tejido suave que proporciona máximo confort.	1	4.319	15.195	0	A	7790000000096	294.17	\N
87	PRD0087	Sweater trenzado beige	Disponible en varias tallas y colores.	1	6.779	24.154	0	A	7790000000097	310.98	\N
88	PRD0088	Top de tirantes blanco	Ligero y transpirable, perfecto para verano.	1	5.022	46.968	0	A	7790000000098	288.18	\N
89	PRD0089	Sweater cuello alto gris	Prenda confeccionada con materiales de alta calidad.	1	7.193	60.049	0	A	7790000000099	271.14	\N
90	PRD0090	Top sin mangas azul	Prenda confeccionada con materiales de alta calidad.	1	6.931	62.721	0	A	7790000000100	303.78	\N
91	PRD0091	Chaqueta de punto gris	Ideal para ocasiones especiales o uso casual.	1	3.182	17.720	0	A	7790000000101	186.66	\N
92	PRD0092	Camisa estampada flores	Ligero y transpirable, perfecto para verano.	1	4.572	18.924	0	A	7790000000102	232.92	\N
93	PRD0093	Falda acampanada verde	Estilo contemporáneo con acabados finos.	1	3.072	10.345	0	A	7790000000103	217.69	\N
94	PRD0094	Sweater cuello alto blanco	Ligero y transpirable, perfecto para verano.	1	11.657	51.255	0	A	7790000000104	116.90	\N
95	PRD0095	Blusa boho estampada	Ideal para ocasiones especiales o uso casual.	1	11.021	58.131	0	A	7790000000105	232.87	\N
96	PRD0096	Campera de cuero marrón	Tejido suave que proporciona máximo confort.	1	5.494	27.030	0	A	7790000000106	330.45	\N
97	PRD0097	Pantalón de cuero negro	Ideal para ocasiones especiales o uso casual.	1	2.546	15.462	0	A	7790000000107	119.25	\N
98	PRD0098	Pantalón flare azul	Resistente y duradero, pensado para uso frecuente.	1	5.546	41.647	0	A	7790000000108	254.47	\N
99	PRD0099	Camisa formal blanca	Disponible en varias tallas y colores.	1	10.495	73.388	0	A	7790000000109	101.21	\N
100	PRD0100	Vestido camisero azul	Ideal para ocasiones especiales o uso casual.	1	10.866	65.730	0	A	7790000000110	250.85	\N
\.


--
-- TOC entry 4876 (class 0 OID 16399)
-- Dependencies: 220
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (userid, email, passwordhash, fullname, created_at) FROM stdin;
1	test@example.com	jlkjlkjl	Usuario Test	\N
\.


--
-- TOC entry 4902 (class 0 OID 0)
-- Dependencies: 223
-- Name: cart_items_cartitemid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cart_items_cartitemid_seq', 77, true);


--
-- TOC entry 4903 (class 0 OID 0)
-- Dependencies: 221
-- Name: carts_cartid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.carts_cartid_seq', 10, true);


--
-- TOC entry 4904 (class 0 OID 0)
-- Dependencies: 231
-- Name: mp_webhooks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mp_webhooks_id_seq', 1, false);


--
-- TOC entry 4905 (class 0 OID 0)
-- Dependencies: 227
-- Name: order_items_orderitemid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_orderitemid_seq', 77, true);


--
-- TOC entry 4906 (class 0 OID 0)
-- Dependencies: 229
-- Name: order_payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_payments_id_seq', 1, false);


--
-- TOC entry 4907 (class 0 OID 0)
-- Dependencies: 225
-- Name: orders_orderid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_orderid_seq', 8, true);


--
-- TOC entry 4908 (class 0 OID 0)
-- Dependencies: 217
-- Name: productos_productoid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.productos_productoid_seq', 15, true);


--
-- TOC entry 4909 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_userid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_userid_seq', 1, false);


--
-- TOC entry 4706 (class 2606 OID 16430)
-- Name: cart_items cart_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_pkey PRIMARY KEY (cartitemid);


--
-- TOC entry 4704 (class 2606 OID 16417)
-- Name: carts carts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carts
    ADD CONSTRAINT carts_pkey PRIMARY KEY (cartid);


--
-- TOC entry 4718 (class 2606 OID 16505)
-- Name: mp_webhooks mp_webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mp_webhooks
    ADD CONSTRAINT mp_webhooks_pkey PRIMARY KEY (id);


--
-- TOC entry 4710 (class 2606 OID 16461)
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (orderitemid);


--
-- TOC entry 4714 (class 2606 OID 16485)
-- Name: order_payments order_payments_mp_payment_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_payments
    ADD CONSTRAINT order_payments_mp_payment_id_key UNIQUE (mp_payment_id);


--
-- TOC entry 4716 (class 2606 OID 16483)
-- Name: order_payments order_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_payments
    ADD CONSTRAINT order_payments_pkey PRIMARY KEY (id);


--
-- TOC entry 4708 (class 2606 OID 16449)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (orderid);


--
-- TOC entry 4698 (class 2606 OID 16397)
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (productoid);


--
-- TOC entry 4700 (class 2606 OID 16407)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4702 (class 2606 OID 16405)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (userid);


--
-- TOC entry 4711 (class 1259 OID 16493)
-- Name: idx_order_payments_pref; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_payments_pref ON public.order_payments USING btree (mp_preference_id);


--
-- TOC entry 4712 (class 1259 OID 16494)
-- Name: idx_order_payments_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_payments_status ON public.order_payments USING btree (status);


--
-- TOC entry 4719 (class 1259 OID 16506)
-- Name: uq_mp_webhooks_type_data; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_mp_webhooks_type_data ON public.mp_webhooks USING btree (type, data_id);


--
-- TOC entry 4727 (class 2620 OID 16492)
-- Name: order_payments trg_order_payments_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_order_payments_updated_at BEFORE UPDATE ON public.order_payments FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 4721 (class 2606 OID 16431)
-- Name: cart_items cart_items_cartid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_cartid_fkey FOREIGN KEY (cartid) REFERENCES public.carts(cartid) ON DELETE CASCADE;


--
-- TOC entry 4722 (class 2606 OID 16436)
-- Name: cart_items cart_items_productid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_productid_fkey FOREIGN KEY (productid) REFERENCES public.productos(productoid);


--
-- TOC entry 4720 (class 2606 OID 16418)
-- Name: carts carts_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carts
    ADD CONSTRAINT carts_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(userid);


--
-- TOC entry 4724 (class 2606 OID 16462)
-- Name: order_items order_items_orderid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_orderid_fkey FOREIGN KEY (orderid) REFERENCES public.orders(orderid) ON DELETE CASCADE;


--
-- TOC entry 4725 (class 2606 OID 16467)
-- Name: order_items order_items_productid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_productid_fkey FOREIGN KEY (productid) REFERENCES public.productos(productoid);


--
-- TOC entry 4726 (class 2606 OID 16486)
-- Name: order_payments order_payments_orderid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_payments
    ADD CONSTRAINT order_payments_orderid_fkey FOREIGN KEY (orderid) REFERENCES public.orders(orderid) ON DELETE SET NULL;


--
-- TOC entry 4723 (class 2606 OID 16450)
-- Name: orders orders_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(userid);


-- Completed on 2025-08-25 19:28:58

--
-- PostgreSQL database dump complete
--

