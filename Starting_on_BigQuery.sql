SELECT * FROM belleza_verde.clientes;

SELECT id_venda, id_produto, id_cliente, data, faturamento
FROM
  (
    SELECT
      id_venda,
      id_produto,
      id_cliente,
      data,
      (quantidade * preco) AS faturamento
    FROM belleza_verde.vendas
  )
WHERE faturamento >= 600
LIMIT 10;

-- Usando With
WITH
  vendas_faturamento AS (
    SELECT
      id_venda,
      id_produto,
      id_cliente,
      data,
      (quantidade * preco) AS faturamento
    FROM belleza_verde.vendas
  )
SELECT id_venda, id_produto, id_cliente, data, faturamento
FROM vendas_faturamento
WHERE faturamento >= 600
LIMIT 10;

-- Usando Extract
SELECT
  id_produto AS produto,
  id_cliente AS cliente,
  EXTRACT(year FROM data) AS ano,
  SUM(quantidade * preco) AS total_faturamento,
  MAX(quantidade * preco) AS maior_faturamento,
  min(quantidade * preco) AS menor_faturamento,
  avg(quantidade * preco) AS media_faturamento,
  COUNT(*) AS num_vendas
FROM belleza_verde.vendas
GROUP BY id_produto, id_cliente, EXTRACT(year FROM data);

SELECT
  id_produto AS produto,
  id_cliente AS cliente,
  EXTRACT(year FROM data) AS ano,
  SUM(quantidade * preco) AS total_faturamento,
  MAX(quantidade * preco) AS maior_faturamento,
  min(quantidade * preco) AS menor_faturamento,
  avg(quantidade * preco) AS media_faturamento,
  COUNT(*) AS num_vendas
FROM belleza_verde.vendas
GROUP BY id_produto, id_cliente, ano
HAVING total_faturamento >= 3000 AND menor_faturamento <= 60;

-- Usando arrays
SELECT produto, cliente, array_agg(faturamento) AS array_faturamento
FROM
  (
    SELECT
      id_produto AS produto,
      id_cliente AS cliente,
      sum(quantidade * preco) AS faturamento,
      EXTRACT(year FROM data) AS ano
    FROM belleza_verde.vendas
    WHERE id_produto = 3 AND id_cliente = 3
    GROUP BY id_produto, id_cliente, ano
  )
GROUP BY produto, cliente;

-- Usando struct
SELECT array_length(resultado)
FROM
  (
    SELECT
      [
        STRUCT(
          1 AS produto,
          1 AS cliente,
          [3443.7999999999993, 1562.2299999999998, 776.86]
            AS array_faturamento),
        STRUCT(
          1 AS produto,
          2 AS cliente,
          [3855.0000000000005, 2316.4099999999994, 1331.76]
            AS array_faturamento)] AS resultado
  );

SELECT
  resultado[OFFSET(0)].produto AS pri_prod,
  resultado[OFFSET(0)].cliente AS pri_cliente,
  resultado[OFFSET(1)].cliente AS sec_cliente,
  resultado[OFFSET(1)].array_faturamento[OFFSET(2)] AS fat_sec_linha_terc_valor
FROM
  (
    SELECT
      [
        STRUCT(
          1 AS produto,
          1 AS cliente,
          [3443.7999999999993, 1562.2299999999998, 776.86]
            AS array_faturamento),
        STRUCT(
          1 AS produto,
          2 AS cliente,
          [3855.0000000000005, 2316.4099999999994, 1331.76]
            AS array_faturamento)] AS resultado
  );

-- usando unnest, fazendo com que o array se comporte como coluna, criando uma tabela novamente.
WITH
  estrutura_array AS (
    SELECT * FROM UNNEST(
      [
        STRUCT(
          1 AS produto,
          1 AS cliente,
          [3443.7999999999993, 1562.2299999999998, 776.86]
            AS array_Faturamento),
        STRUCT(
          1 AS produto,
          2 AS cliente,
          [3855.0000000000005, 2316.4099999999994, 1331.76]
            AS array_Faturamento)])
  )
SELECT
  produto,
  cliente,
  sum(faturamento) AS faturamento_calculado,
  MAX(Faturamento) AS Faturamento_Maior,
  MIN(Faturamento) AS Faturamento_Menor,
  AVG(Faturamento) AS Faturamento_Media,
  COUNT(*) AS Num_Array
FROM estrutura_array, UNNEST(array_faturamento) AS faturamento
GROUP BY produto, cliente;

-- Essa consulta fornecerá, para cada id_produto, o tamanho dos arrays distribuicao e materiasprimas, além do último elemento de cada um desses arrays. Isso permitirá uma análise detalhada dos dados mais recentes ou finais relacionados à distribuição e às matérias-primas dos produtos da Belleza Verde.
SELECT
  id_produto,
  array_length(materiasprimas) AS tamanho_materias_primas,
  distribuicao[OFFSET(array_length(materiasprimas) - 1)] AS ultimo_elemento
FROM belleza_verde.produtos;

SELECT row_number() OVER () AS NUM, * FROM belleza_verde.vendas;

WITH
  resultado_produto AS (
    WITH
      index_produtos AS (
        SELECT
          id_produto,
          nome,
          categoria,
          preco,
          ARRAY(
            SELECT AS STRUCT mat_pri, row_number() OVER () AS indexador
            FROM UNNEST(materiasprimas) AS mat_pri
          ) AS materiaprima_index,
          ARRAY(
            SELECT AS STRUCT distr, row_number() OVER () AS indexador
            FROM UNNEST(distribuicao) AS distr
          ) AS distribuicao_index,
        FROM belleza_verde.produtos
      )
    SELECT
      ip.id_produto,
      ip.nome,
      ip.categoria,
      ip.preco,
      mat_pri_unnest.mat_pri,
      mat_pri_unnest.indexador,
      distr_unnest.distr,
      distr_unnest.indexador
    FROM index_produtos AS idx_prod
    CROSS JOIN UNNEST(idx_prod.materiaprima_index) AS mat_pri_unnest
    CROSS JOIN UNNEST(idx_prod.distribuicao_index) AS distr_unnest
  )
SELECT
  rp.id_produto,
  rp.nome,
  rp.categoria,
  rp.preco,
  rp.id_materia,
  mp.nome AS nome_materia
FROM resultado_produto rp
INNER JOIN belleza_verde.materiasprimas mp
  ON CAST(rp.id_materia AS int64) = mp.id_materia;

SELECT STRUCT("ALICE" AS NAME, 30 AS AGE) AS user_info;

WITH
  query_1 AS (
    SELECT * FROM UNNEST(
      [
        STRUCT(
          1 AS produto,
          1 AS cliente,
          [3443.7999999999993, 1562.2299999999998, 776.86]
            AS array_faturamento),
        STRUCT(
          1 AS produto,
          2 AS cliente,
          [3855.0000000000005, 2316.4099999999994, 1331.76]
            AS array_faturamento)])
  )
SELECT produto, cliente, sum(faturamento), row_number() OVER () AS indexador
FROM query_1, UNNEST(array_faturamento) AS faturamento
GROUP BY produto, cliente;

-- Trabalhando com JOINS

WITH
  CIDADES AS (
    SELECT 'RECIFE' AS CIDADE, 'PE' AS ESTADO
    UNION ALL
    SELECT 'SÃO PAULO' AS CITY, 'SP' AS STATE
    UNION ALL
    SELECT 'SANTOS' AS CITY, 'SP' AS STATE
    UNION ALL
    SELECT 'PORTO ALEGRE' AS CITY, 'RS' AS STATE
    UNION ALL
    SELECT 'BELEM' AS CITY, 'PA' AS STATE
  ),
  REGIOES AS (
    SELECT 'SP' AS ESTADO, 'SUDESTE' AS REGIAO
    UNION ALL
    SELECT 'PE' AS ESTADO, 'NORDESTE' AS REGIAO
    UNION ALL
    SELECT 'MT' AS ESTADO, 'CENTRO OESTE' AS REGIAO
    UNION ALL
    SELECT 'AM' AS ESTADO, 'NORTE' AS REGIAO
    UNION ALL
    SELECT 'RJ' AS ESTADO, 'SUDESTE' AS REGIAO
  )
SELECT CIDADES.*, REGIOES.*
FROM CIDADES
INNER JOIN REGIOES
  ON CIDADES.ESTADO = REGIOES.ESTADO;

SELECT
  ve.id_produto,
  pr.nome AS nome_produto,
  ve.id_cliente,
  cl.nome AS nome_cliente,
  ve.data,
  ve.quantidade
FROM belleza_verde.vendas ve
INNER JOIN belleza_verde.produtos pr
  ON ve.id_produto = pr.id_produto
INNER JOIN belleza_verde.clientes cl
  ON cl.id_cliente = ve.id_cliente
LIMIT 10;

SELECT c.nome AS nome_cliente, p.data_pedido, pr.nome_produto
FROM
  clientes c
LEFT JOIN pedidos p
  ON c.id_cliente = p.id_cliente
INNER JOIN produtos pr
  ON pr.id_produto = p.id_produto;

SELECT
  vend.nome AS nome_vendedor,
  prod.nome AS nome_produto,
  EXTRACT(year FROM ve.data) AS ano,
  sum(ve.quantidade) AS total_vendas
FROM belleza_verde.vendas ve
INNER JOIN belleza_verde.produtos prod
  ON prod.id_produto = ve.id_produto
INNER JOIN belleza_verde.clientes cl
  ON cl.id_cliente = ve.id_cliente
INNER JOIN belleza_verde.vendedores AS vend
  ON vend.id_vendedor = cl.id_vendedor
GROUP BY vend.nome, prod.nome, EXTRACT(year FROM ve.data);

WITH
  total_vendas AS (
    SELECT cl.nome, sum(ve.quantidade * ve.preco) AS total_faturamento
    FROM belleza_verde.vendas ve
    INNER JOIN belleza_verde.clientes cl
      ON ve.id_cliente = CAST(cl.id_cliente AS int64)
    WHERE EXTRACT(year FROM data) = 2021
    GROUP BY cl.nome
  ),
  faturamento_rank AS (
    SELECT
      nome,
      total_faturamento,
      rank() OVER (ORDER BY total_faturamento DESC) AS ranking,
      sum(total_faturamento) OVER () AS faturamento_geral,
      total_faturamento / sum(total_faturamento)
        OVER () * 100 AS percentual_distribuicao
    FROM total_vendas
    GROUP BY nome, total_faturamento
  ),
  dist_cumulativa AS (
    SELECT
      *,
      COUNT(*) OVER () AS total_produtos,
      sum(percentual_distribuicao)
        OVER (
          ORDER BY ranking ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS percentual_acumulado
    FROM faturamento_rank
  )
SELECT
  nome,
  round(total_faturamento, 2) AS faturamento_total,
  round(percentual_acumulado, 2) AS distribuicao_faturamento,
  round(((ranking / total_produtos) * 100), 2) AS distribuicao_produtos
FROM dist_cumulativa
ORDER BY ranking;

WITH
  vendas_anuais AS (
    SELECT
      vend.id_vendedor,
      vend.nome AS nome_vendedor,
      prod.id_produto,
      prod.nome AS nome_produto,
      EXTRACT(year FROM ve.data) AS ano,
      sum(ve.quantidade) AS total_vendas
    FROM belleza_verde.vendas ve
    INNER JOIN belleza_verde.produtos prod
      ON prod.id_produto = ve.id_produto
    INNER JOIN belleza_verde.clientes cl
      ON cl.id_cliente = ve.id_cliente
    INNER JOIN belleza_verde.vendedores AS vend
      ON vend.id_vendedor = cl.id_vendedor
    GROUP BY
      vend.nome, prod.nome, prod.id_produto, vend.id_vendedor,
      EXTRACT(year FROM ve.data)
  ),
  vendas_todos_anos AS (
    SELECT
      vend.id_vendedor,
      vend.nome AS nome_vendedor,
      prod.id_produto,
      prod.nome AS nome_produto,
      sum(ve.quantidade) AS total_vendas
    FROM belleza_verde.vendas ve
    INNER JOIN belleza_verde.produtos prod
      ON prod.id_produto = ve.id_produto
    INNER JOIN belleza_verde.clientes cl
      ON cl.id_cliente = ve.id_cliente
    INNER JOIN belleza_verde.vendedores AS vend
      ON vend.id_vendedor = cl.id_vendedor
    GROUP BY vend.nome, prod.nome, prod.id_produto, vend.id_vendedor
  )
SELECT
  vendas_anuais.nome_vendedor,
  vendas_anuais.nome_produto,
  vendas_anuais.ano,
  vendas_anuais.total_vendas,
  vendas_todos_anos.total_vendas AS vendas_todos_anos,
  ((vendas_anuais.total_vendas / vendas_todos_anos.total_vendas) * 100)
    AS distribuicao_vendas,
  mt.quantidade_meta,
  CASE
    WHEN vendas_anuais.total_vendas >= mt.quantidade_meta THEN 'Acima da meta'
    ELSE 'Abaixo da meta'
    END AS status_meta,
  ((vendas_anuais.total_vendas / mt.quantidade_meta) - 1) * 100
    AS percentual_atingido
FROM vendas_anuais
INNER JOIN belleza_verde.metas mt
  ON
    vendas_anuais.id_produto = mt.id_produto
    AND vendas_anuais.id_vendedor = mt.id_vendedor
    AND vendas_anuais.ano = mt.ano
INNER JOIN vendas_todos_anos
  ON
    vendas_todos_anos.id_produto = vendas_anuais.id_produto
    AND vendas_todos_anos.id_vendedor = vendas_anuais.id_vendedor;
