CREATE TABLE IF NOT EXISTS "itens_historico_raw_federais" (
	id_empenho BIGINT,
	codigo_empenho TEXT,
	sequencial BIGINT,
    tipo_operacao VARCHAR(64),
	data_emissao TEXT,
	quantidade NUMERIC,
	valor_unitario NUMERIC,
	valor_total NUMERIC
);