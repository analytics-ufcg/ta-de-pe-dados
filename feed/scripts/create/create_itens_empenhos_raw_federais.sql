CREATE TABLE IF NOT EXISTS "itens_empenhos_raw_federais" (
	categoria_despesa TEXT,
	codigo_categoria_despesa TEXT,
	codigo_elemento_despesa NUMERIC,
	codigo_empenho TEXT,
	codigo_grupo_despesa TEXT,
	codigo_modalidade_aplicacao BIGINT,
	codigo_subelemento_despesa NUMERIC,
	descricao TEXT,
	elemento_despesa TEXT,
	em_sigilo TEXT,
	grupo_despesa TEXT,
	id_empenho BIGINT,
	modalidade_aplicacao TEXT,
	quantidade NUMERIC,
	subelemento_despesa TEXT,
	valor_total NUMERIC,
	valor_unitario NUMERIC,
	sequencial BIGINT,
	valor_atual NUMERIC,
	item_material TEXT,
	unidade TEXT,
	item TEXT,
	marca TEXT,
	item_processo TEXT,
	descricao_restante TEXT,
	valor_itens_empenhos_relacionados NUMERIC,
	FOREIGN KEY (id_empenho) REFERENCES empenhos_raw_federais(id)
);