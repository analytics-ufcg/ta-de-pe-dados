## Tests

Para os testes do repositório usamos o pacote [testthat](https://testthat.r-lib.org/).
Se você está interessado em saber mais sobre testes no R acesse esse [artigo](https://r-pkgs.org/tests.html).

### Como executar um arquivo de teste individualmente?

Pelo Rstudio
```
testthat::test_file(<caminho para o arquivo de teste>)
```

Pelo terminal
```
docker exec r-container sh -c "cd /app/ && R -e 'testthat::test_file(\"tests/testthat/test_example.R\")'"
```

### Onde criar um teste?

Crie um arquivo de teste em: `tests/testthat/`.
O nome do arquivo deve iniciar com `test_` e terminar com `.R`

### Como criar um teste?

Leia o arquivo de exemplo: `tests/testthat/test_example.R`

### CI/CD

O processo de testes contínuos do repositório ainda não está implementado.
