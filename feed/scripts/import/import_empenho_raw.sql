SET datestyle = ymd;
\copy empenho_raw FROM '/data/tce_rs/empenhos/2018/2018.csv' WITH NULL AS '' DELIMITER ',' CSV HEADER;
\copy empenho_raw FROM '/data/tce_rs/empenhos/2019/2019.csv' WITH NULL AS '' DELIMITER ',' CSV HEADER;
\copy empenho_raw FROM '/data/tce_rs/empenhos/2020/2020.csv' WITH NULL AS '' DELIMITER ',' CSV HEADER;
\copy empenho_raw FROM '/data/tce_rs/empenhos/2021/2021.csv' WITH NULL AS '' DELIMITER ',' CSV HEADER;