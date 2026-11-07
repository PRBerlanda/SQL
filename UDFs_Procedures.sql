-- =====================================================================================
-- UDFs e Procedures no BigQuery (dataset belleza_verde)
-- Execute cada bloco separadamente no console do BigQuery (selecione o bloco e clique em Executar).
-- Os blocos de teste ficam entre BEGIN ... END porque o BigQuery só aceita DECLARE
-- no início de um script ou de um bloco.
-- =====================================================================================

-------------------------------------------------------------------------------------
# Protótipo de procedure para inclusão de dados em tabela.
CREATE OR REPLACE PROCEDURE belleza_verde.incluiVenda(
  idVenda INT64, idProduto INT64, idCliente INT64, dataVenda DATE, quantVenda INT64, precoVenda FLOAT64)
BEGIN
  INSERT INTO belleza_verde.vendas (id_venda, id_produto, id_cliente, data, quantidade, preco)
  VALUES (idVenda, idProduto, idCliente, dataVenda, quantVenda, precoVenda);
END;

-------------------------------------------------------------------------------------
# Primeira procedure completa: inclui uma nova venda se o produto existir; o id da venda é gerado
# automaticamente. Se o produto não existir, exibe uma mensagem.
CREATE OR REPLACE PROCEDURE belleza_verde.incluiVenda1(
  idProduto INT64,
  idCliente INT64,
  dataVenda DATE,
  quantVenda INT64,
  precoVenda FLOAT64)
BEGIN
  DECLARE idVenda INT64;
  DECLARE produtoExiste BOOL DEFAULT FALSE;

  # Verifica a existência do produto antes de incluir na venda.
  SET produtoExiste = (SELECT EXISTS(SELECT 1 FROM belleza_verde.produtos WHERE id_produto = idProduto));

  IF produtoExiste THEN
    # Automatiza o ID da venda.
    SET idVenda = (SELECT IFNULL(MAX(id_venda), 0) + 1 FROM belleza_verde.vendas);
    INSERT INTO belleza_verde.vendas (id_venda, id_produto, id_cliente, data, quantidade, preco)
    VALUES (idVenda, idProduto, idCliente, dataVenda, quantVenda, precoVenda);
  ELSE
    # Caso não haja produto cadastrado, o erro é exibido.
    SELECT 'Erro: produto não existe' AS mensagem;
  END IF;
END;

CALL belleza_verde.incluiVenda1(1, 1, '2024-01-01', 10, 5);

-------------------------------------------------------------------------------------
# Remove a mensagem de texto e retorna as flags idRetornoProduto e idRetornoCliente.
# A venda só é incluída se o produto E o cliente existirem.
CREATE OR REPLACE PROCEDURE belleza_verde.incluiVenda2(
  idProduto INT64,
  idCliente INT64,
  dataVenda DATE,
  quantVenda INT64,
  precoVenda FLOAT64)
BEGIN
  DECLARE idVenda INT64;
  DECLARE produtoExiste BOOL DEFAULT FALSE;
  DECLARE clienteExiste BOOL DEFAULT FALSE;
  DECLARE idRetornoProduto INT64;
  DECLARE idRetornoCliente INT64;

  SET produtoExiste = (SELECT EXISTS(SELECT 1 FROM belleza_verde.produtos WHERE id_produto = idProduto));
  SET clienteExiste = (SELECT EXISTS(SELECT 1 FROM belleza_verde.clientes WHERE id_cliente = idCliente));

  IF produtoExiste AND clienteExiste THEN
    SET idVenda = (SELECT IFNULL(MAX(id_venda), 0) + 1 FROM belleza_verde.vendas);
    INSERT INTO belleza_verde.vendas (id_venda, id_produto, id_cliente, data, quantidade, preco)
    VALUES (idVenda, idProduto, idCliente, dataVenda, quantVenda, precoVenda);
    SET idRetornoProduto = 1;
    SET idRetornoCliente = 1;
  ELSE
    SET idRetornoProduto = IF(produtoExiste, 1, 0);
    SET idRetornoCliente = IF(clienteExiste, 1, 0);
  END IF;

  SELECT idRetornoProduto AS Produto, idRetornoCliente AS Cliente;
END;

CALL belleza_verde.incluiVenda2(100, 1, '2024-01-03', 10, 5);

-------------------------------------------------------------------------------------
# Procedure com dois parâmetros de saída (OUT): quem chama recebe idRetornoProduto e idRetornoCliente.
CREATE OR REPLACE PROCEDURE belleza_verde.incluiVenda3(
  idProduto INT64,
  idCliente INT64,
  dataVenda DATE,
  quantVenda INT64,
  precoVenda FLOAT64,
  OUT idRetornoProduto INT64,
  OUT idRetornoCliente INT64)
BEGIN
  DECLARE idVenda INT64;
  DECLARE produtoExiste BOOL DEFAULT FALSE;
  DECLARE clienteExiste BOOL DEFAULT FALSE;

  SET produtoExiste = (SELECT EXISTS(SELECT 1 FROM belleza_verde.produtos WHERE id_produto = idProduto));
  SET clienteExiste = (SELECT EXISTS(SELECT 1 FROM belleza_verde.clientes WHERE id_cliente = idCliente));

  IF produtoExiste AND clienteExiste THEN
    SET idVenda = (SELECT IFNULL(MAX(id_venda), 0) + 1 FROM belleza_verde.vendas);
    INSERT INTO belleza_verde.vendas (id_venda, id_produto, id_cliente, data, quantidade, preco)
    VALUES (idVenda, idProduto, idCliente, dataVenda, quantVenda, precoVenda);
    SET idRetornoProduto = 1;
    SET idRetornoCliente = 1;
  ELSE
    SET idRetornoProduto = IF(produtoExiste, 1, 0);
    SET idRetornoCliente = IF(clienteExiste, 1, 0);
  END IF;
END;

-------------------------------------------------------------------------------------
# Declarando as variáveis e verificando se produto e cliente existem.
BEGIN
  DECLARE idRetornoProduto INT64;
  DECLARE idRetornoCliente INT64;
  CALL belleza_verde.incluiVenda3(100, 1, '2024-01-03', 10, 5, idRetornoProduto, idRetornoCliente);
  IF idRetornoProduto = 0 AND idRetornoCliente = 0 THEN
    SELECT 'Identificador do PRODUTO e do CLIENTE inválidos' AS mensagem;
  ELSEIF idRetornoProduto = 1 AND idRetornoCliente = 0 THEN
    SELECT 'Identificador do CLIENTE inválido' AS mensagem;
  ELSEIF idRetornoProduto = 0 AND idRetornoCliente = 1 THEN
    SELECT 'Identificador do PRODUTO inválido' AS mensagem;
  ELSE
    SELECT 'Produto e Cliente incluídos com sucesso' AS mensagem;
  END IF;
END;

-------------------------------------------------------------------------------------
# Automatizando o valor pago pelo cliente: o preço vem da tabela de produtos.
CREATE OR REPLACE PROCEDURE belleza_verde.incluiVenda4(
  idProduto INT64,
  idCliente INT64,
  dataVenda DATE,
  quantVenda INT64,
  OUT idRetornoProduto INT64,
  OUT idRetornoCliente INT64)
BEGIN
  DECLARE idVenda INT64;
  DECLARE precoVenda FLOAT64;
  DECLARE produtoExiste BOOL DEFAULT FALSE;
  DECLARE clienteExiste BOOL DEFAULT FALSE;

  SET produtoExiste = (SELECT EXISTS(SELECT 1 FROM belleza_verde.produtos WHERE id_produto = idProduto));
  SET clienteExiste = (SELECT EXISTS(SELECT 1 FROM belleza_verde.clientes WHERE id_cliente = idCliente));

  IF produtoExiste AND clienteExiste THEN
    SET precoVenda = (SELECT preco FROM belleza_verde.produtos WHERE id_produto = idProduto);
    SET idVenda = (SELECT IFNULL(MAX(id_venda), 0) + 1 FROM belleza_verde.vendas);
    INSERT INTO belleza_verde.vendas (id_venda, id_produto, id_cliente, data, quantidade, preco)
    VALUES (idVenda, idProduto, idCliente, dataVenda, quantVenda, precoVenda);
    SET idRetornoProduto = 1;
    SET idRetornoCliente = 1;
  ELSE
    SET idRetornoProduto = IF(produtoExiste, 1, 0);
    SET idRetornoCliente = IF(clienteExiste, 1, 0);
  END IF;
END;

-------------------------------------------------------------------------------------
# Declarando as variáveis e verificando se produto e cliente existem.
BEGIN
  DECLARE idRetornoProduto INT64;
  DECLARE idRetornoCliente INT64;
  CALL belleza_verde.incluiVenda4(100, 1, '2024-01-03', 10, idRetornoProduto, idRetornoCliente);
  IF idRetornoProduto = 0 AND idRetornoCliente = 0 THEN
    SELECT 'Identificador do PRODUTO e do CLIENTE inválidos' AS mensagem;
  ELSEIF idRetornoProduto = 1 AND idRetornoCliente = 0 THEN
    SELECT 'Identificador do CLIENTE inválido' AS mensagem;
  ELSEIF idRetornoProduto = 0 AND idRetornoCliente = 1 THEN
    SELECT 'Identificador do PRODUTO inválido' AS mensagem;
  ELSE
    SELECT 'Produto e Cliente incluídos com sucesso' AS mensagem;
  END IF;
END;

-------------------------------------------------------------------------------------
# UDF (User Defined Function): número aleatório entre min e max (inclusive).
CREATE OR REPLACE FUNCTION belleza_verde.NumAleatorio(min INT64, max INT64)
RETURNS INT64
AS (
  CAST(FLOOR(RAND() * (max - min + 1)) AS INT64) + min
);

SELECT belleza_verde.NumAleatorio(1, 100) AS valor_aleatorio;

-------------------------------------------------------------------------------------
# UDF que retorna a data no padrão brasileiro (dd/mm/aaaa).
CREATE OR REPLACE FUNCTION belleza_verde.dataFormatada(data DATE)
RETURNS STRING
AS (
  FORMAT('%02d/%02d/%04d', EXTRACT(DAY FROM data), EXTRACT(MONTH FROM data), EXTRACT(YEAR FROM data))
);

SELECT belleza_verde.dataFormatada('2023-01-01');

-------------------------------------------------------------------------------------
# Usando a UDF para sortear produto e cliente antes de chamar a procedure.
BEGIN
  DECLARE idRetornoProduto INT64;
  DECLARE idRetornoCliente INT64;
  DECLARE minProduto INT64;
  DECLARE maxProduto INT64;
  DECLARE idProduto INT64;
  DECLARE minCliente INT64;
  DECLARE maxCliente INT64;
  DECLARE idCliente INT64;

  SET minProduto = (SELECT MIN(id_produto) FROM belleza_verde.produtos);
  SET maxProduto = (SELECT MAX(id_produto) FROM belleza_verde.produtos);
  SET idProduto = belleza_verde.NumAleatorio(minProduto, maxProduto);

  SET minCliente = (SELECT MIN(id_cliente) FROM belleza_verde.clientes);
  SET maxCliente = (SELECT MAX(id_cliente) FROM belleza_verde.clientes);
  SET idCliente = belleza_verde.NumAleatorio(minCliente, maxCliente);

  CALL belleza_verde.incluiVenda4(idProduto, idCliente, '2024-01-03', 10, idRetornoProduto, idRetornoCliente);

  IF idRetornoProduto = 0 AND idRetornoCliente = 0 THEN
    SELECT 'Identificador do PRODUTO e do CLIENTE inválidos' AS mensagem;
  ELSEIF idRetornoProduto = 1 AND idRetornoCliente = 0 THEN
    SELECT 'Identificador do CLIENTE inválido' AS mensagem;
  ELSEIF idRetornoProduto = 0 AND idRetornoCliente = 1 THEN
    SELECT 'Identificador do PRODUTO inválido' AS mensagem;
  ELSE
    SELECT 'Produto e Cliente incluídos com sucesso' AS mensagem;
  END IF;
END;

-------------------------------------------------------------------------------------
# Custo de cada produto: as colunas materiasprimas e distribuicao são arrays paralelos
# (a matéria-prima na posição i entra na composição com o percentual da posição i).
# O custo é a soma de (percentual de uso x custo da matéria-prima).
WITH index_produtos AS (
  SELECT id_produto, nome, categoria, preco,
    ARRAY(SELECT AS STRUCT mp, ROW_NUMBER() OVER() AS idx FROM UNNEST(materiasprimas) AS mp) AS materiaprima_index,
    ARRAY(SELECT AS STRUCT ds, ROW_NUMBER() OVER() AS idx FROM UNNEST(distribuicao) AS ds) AS distribuicao_index
  FROM belleza_verde.produtos
),
produtos_distribuicao_custo AS (
  SELECT ip.id_produto, mpUN.mp AS id_materia, dsUN.ds AS distribuicao_materia, M.custo
  FROM index_produtos ip
  CROSS JOIN UNNEST(ip.materiaprima_index) AS mpUN
  JOIN UNNEST(ip.distribuicao_index) AS dsUN
    ON mpUN.idx = dsUN.idx
  INNER JOIN belleza_verde.materiasprimas M
    ON CAST(mpUN.mp AS INT64) = M.id_materia
)
SELECT id_produto, SUM(distribuicao_materia * custo) AS total_preco_produto
FROM produtos_distribuicao_custo
GROUP BY id_produto
ORDER BY id_produto;

-------------------------------------------------------------------------------------
# Versão final: três procedures que automatizam a inclusão de vendas.
# 1ª Procedure: confere se o produto e o cliente existem (flags idRetornoProduto e idRetornoCliente).
# Se ambos existirem, inclui uma nova venda. O preço é o maior entre o preço de tabela e o custo de
# fabricação (matérias-primas) acrescido da margem.
CREATE OR REPLACE PROCEDURE belleza_verde.incluiVenda5(
  -- Parâmetros que serão informados na CALL
  idProduto INT64,
  idCliente INT64,
  dataVenda DATE,
  quantVenda INT64,
  margem FLOAT64,
  -- Parâmetros de saída, usados pela procedure seguinte para saber se a venda foi incluída
  OUT idRetornoProduto INT64,
  OUT idRetornoCliente INT64)
BEGIN
  DECLARE idVenda INT64;
  DECLARE produtoExiste BOOL DEFAULT FALSE;
  DECLARE clienteExiste BOOL DEFAULT FALSE;
  DECLARE precoVenda FLOAT64;
  DECLARE precoVendaMP FLOAT64;
  DECLARE precoVendaTB FLOAT64;

  -- É necessário que os ids existam nas tabelas antes de inserir os dados.
  SET produtoExiste = (SELECT EXISTS(SELECT 1 FROM belleza_verde.produtos WHERE id_produto = idProduto));
  SET clienteExiste = (SELECT EXISTS(SELECT 1 FROM belleza_verde.clientes WHERE id_cliente = idCliente));

  IF produtoExiste AND clienteExiste THEN
    -- Preço de tabela do produto
    SET precoVendaTB = (SELECT preco FROM belleza_verde.produtos WHERE id_produto = idProduto);

    -- Custo de fabricação: soma de (percentual de uso x custo) das matérias-primas do produto
    SET precoVendaMP = (
      WITH index_produtos AS (
        SELECT id_produto,
          ARRAY(SELECT AS STRUCT mp, ROW_NUMBER() OVER() AS idx FROM UNNEST(materiasprimas) AS mp) AS materiaprima_index,
          ARRAY(SELECT AS STRUCT ds, ROW_NUMBER() OVER() AS idx FROM UNNEST(distribuicao) AS ds) AS distribuicao_index
        FROM belleza_verde.produtos
        WHERE id_produto = idProduto
      ),
      produtos_distribuicao_custo AS (
        SELECT dsUN.ds AS distribuicao_materia, M.custo
        FROM index_produtos ip
        CROSS JOIN UNNEST(ip.materiaprima_index) AS mpUN
        JOIN UNNEST(ip.distribuicao_index) AS dsUN
          ON mpUN.idx = dsUN.idx
        INNER JOIN belleza_verde.materiasprimas M
          ON CAST(mpUN.mp AS INT64) = M.id_materia
      )
      SELECT SUM(distribuicao_materia * custo) FROM produtos_distribuicao_custo
    );

    -- Se o preço de tabela for menor que o custo + margem, usa o custo + margem; senão, o preço de tabela.
    SET precoVendaMP = IFNULL(precoVendaMP, 0) + margem;
    IF precoVendaMP >= precoVendaTB THEN
      SET precoVenda = precoVendaMP;
    ELSE
      SET precoVenda = precoVendaTB;
    END IF;

    -- Gera o id da nova venda e inclui a venda
    SET idVenda = (SELECT IFNULL(MAX(id_venda), 0) + 1 FROM belleza_verde.vendas);
    INSERT INTO belleza_verde.vendas (id_venda, id_produto, id_cliente, data, quantidade, preco)
    VALUES (idVenda, idProduto, idCliente, dataVenda, quantVenda, precoVenda);
    SET idRetornoProduto = 1;
    SET idRetornoCliente = 1;
  ELSE
    SET idRetornoProduto = IF(produtoExiste, 1, 0);
    SET idRetornoCliente = IF(clienteExiste, 1, 0);
  END IF;

  SELECT idRetornoProduto AS Produto, idRetornoCliente AS Cliente;
END;

-------------------------------------------------------------------------------------
# 2ª Procedure: sorteia produto e cliente (não há vendas reais) e chama a incluiVenda5,
# exibindo uma mensagem conforme as flags de retorno.
CREATE OR REPLACE PROCEDURE belleza_verde.incluiVendaFinal(
  dataVenda DATE,
  quantidade INT64,
  margemLucro INT64)
BEGIN
  DECLARE idRetornoProduto INT64;
  DECLARE idRetornoCliente INT64;
  DECLARE minProduto INT64;
  DECLARE maxProduto INT64;
  DECLARE idProduto INT64;
  DECLARE minCliente INT64;
  DECLARE maxCliente INT64;
  DECLARE idCliente INT64;

  -- Sorteia os ids de produto e cliente entre os valores mínimo e máximo existentes
  SET minProduto = (SELECT MIN(id_produto) FROM belleza_verde.produtos);
  SET maxProduto = (SELECT MAX(id_produto) FROM belleza_verde.produtos);
  SET idProduto = belleza_verde.NumAleatorio(minProduto, maxProduto);

  SET minCliente = (SELECT MIN(id_cliente) FROM belleza_verde.clientes);
  SET maxCliente = (SELECT MAX(id_cliente) FROM belleza_verde.clientes);
  SET idCliente = belleza_verde.NumAleatorio(minCliente, maxCliente);

  CALL belleza_verde.incluiVenda5(idProduto, idCliente, dataVenda, quantidade, margemLucro,
                                  idRetornoProduto, idRetornoCliente);

  -- Gera um aviso caso não exista o produto ou o cliente
  IF idRetornoProduto = 0 AND idRetornoCliente = 0 THEN
    SELECT 'Identificador do PRODUTO e do CLIENTE inválidos' AS mensagem;
  ELSEIF idRetornoProduto = 1 AND idRetornoCliente = 0 THEN
    SELECT 'Identificador do CLIENTE inválido' AS mensagem;
  ELSEIF idRetornoProduto = 0 AND idRetornoCliente = 1 THEN
    SELECT 'Identificador do PRODUTO inválido' AS mensagem;
  ELSE
    SELECT 'Produto e Cliente incluídos com sucesso' AS mensagem;
  END IF;
END;

-------------------------------------------------------------------------------------
# 3ª Procedure (principal): gera vendas aleatórias para cada dia entre dois dias atrás e hoje.
# Quantidade por venda e número de vendas por dia são sorteados; só a margem é informada.
CREATE OR REPLACE PROCEDURE belleza_verde.conjuntoVendas(
  minQuantidade INT64, maxQuantidade INT64, minVendasDia INT64, maxVendasDia INT64, margemLucro INT64)
BEGIN
  DECLARE dataVenda DATE;
  DECLARE quantidade INT64;
  DECLARE dataInicial DATE;
  DECLARE dataFinal DATE;
  DECLARE numVendasDias INT64;

  -- Insere vendas na data de hoje e nos dois dias anteriores
  SET dataInicial = DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY);
  SET dataFinal = CURRENT_DATE();

  -- FOR externo: percorre a lista de datas entre a data inicial e a final
  FOR dataCorrente IN (SELECT dia FROM UNNEST(GENERATE_DATE_ARRAY(dataInicial, dataFinal)) AS dia)
  DO
    -- Cada linha do FOR é uma STRUCT: o campo é acessado com dataCorrente.dia
    SET dataVenda = dataCorrente.dia;
    SET numVendasDias = belleza_verde.NumAleatorio(minVendasDia, maxVendasDia);

    -- FOR interno: uma iteração por venda do dia
    FOR i IN (SELECT num FROM UNNEST(GENERATE_ARRAY(1, numVendasDias)) AS num)
    DO
      -- Quantidade de itens vendidos, sorteada entre o mínimo e o máximo
      SET quantidade = belleza_verde.NumAleatorio(minQuantidade, maxQuantidade);
      CALL belleza_verde.incluiVendaFinal(dataVenda, quantidade, margemLucro);
    END FOR;
  END FOR;
END;

-- Esta CALL pode ser agendada (scheduled query) para gerar vendas periodicamente.
CALL belleza_verde.conjuntoVendas(1, 10, 1, 5, 10);
