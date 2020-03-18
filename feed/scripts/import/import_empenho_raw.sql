SET datestyle = ymd;
ALTER TABLE empenho_raw DROP CONSTRAINT empenho_raw_pkey;
\copy empenho_raw FROM '/data/empenhos/2018/2018.csv' WITH NULL AS '' DELIMITER ',' CSV HEADER;
\copy empenho_raw FROM '/data/empenhos/2019/2019.csv' WITH NULL AS '' DELIMITER ',' CSV HEADER;