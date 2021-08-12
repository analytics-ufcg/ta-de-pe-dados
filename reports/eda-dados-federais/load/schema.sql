CREATE TABLE IF NOT EXISTS "empenho" (
	id BIGINT,
	codigo TEXT,
	codigo_resumido TEXT,
	data_emissao TEXT,
	codigo_tipo_documento TEXT,
	tipo_documento TEXT,
	tipo TEXT,
	especie TEXT,
	codigo_orgao_superior TEXT,
	orgao_superior TEXT,
	codigo_orgao TEXT,
	orgao TEXT,
	codigo_unidade_gestora TEXT,
	unidade_gestora TEXT,
	codigo_gestao TEXT,
	gestao TEXT,
	codigo_favorecido TEXT,
	favorecido TEXT,
	observacao TEXT,
	codigo_esfera_orcamentaria TEXT,
	esfera_orcamentaria TEXT,
	codigo_tipo_credito TEXT,
	tipo_credito TEXT,
	codigo_grupo_fonte_recurso TEXT,
	grupo_fonte_recurso TEXT,
	codigo_fonte_recurso TEXT,
	fonte_recurso TEXT,
	codigo_unidade_orcamentaria TEXT,
	unidade_orcamentaria TEXT,
	codigo_funcao TEXT,
	funcao TEXT,
	codigo_subfuncao TEXT,
	subfuncao TEXT,
	codigo_programa TEXT,
	programa TEXT,
	codigo_acao TEXT,
	acao TEXT,
	linguagem_cidada TEXT,
	codigo_subtitulo_localizador TEXT,
	subtitulo_localizador TEXT,
	codigo_plano_orcamentario TEXT,
	plano_orcamentario TEXT,
	codigo_programa_governo TEXT,
	programa_governo TEXT,
	autor_emenda TEXT,
	codigo_categoria_de_despesa TEXT,
	categoria_despesa TEXT,
	codigo_grupo_despesa TEXT,
	grupo_despesa TEXT,
	codigo_modalidade_aplicacao TEXT,
	modalidade_aplicacao TEXT,
	codigo_elemento_despesa TEXT,
	elemento_despesa TEXT,
	processo TEXT,
	modalidade_licitacao TEXT,
	inciso TEXT,
	amparo TEXT,
	referencia_dispensa_inexigibilidade TEXT,
	codigo_convenio TEXT,
	contrato_repasse_parceria_outros TEXT,
	valor_original NUMERIC,
	valor_reais NUMERIC,
	valor_conversao NUMERIC
);

CREATE TABLE IF NOT EXISTS "item_empenho" (
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
	item_processo TEXT
);
