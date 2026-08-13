-- Int64: Inteiro cujos valores variarn de 10 (—19) e 10 (+19);
-- Float64: Equivalente ao Int64 mas para números decimais;
-- Bool: Valores lógicos (Verdadeiro ou Falso);
-- Numeric: Números com 38 dígitos de precisão e 9 dígitos decimais;
-- String: Sequências e caracteres Unicode (texto);
-- Bytes: Sequências de caracteres não Unicode (dados binários);
-- Timestamp: Representa um ponto específico no tempo;
-- Datetime: Representa uma data e hora dentro do calendário;
-- Geography: Representa pontos, linhas ou polígonos com dados geoespaciais;
-- Struc ou Array: Representa um valor em JSON.

-- Funções que alteram a caixa de texto
-- UPPER, LOWER, INITCAP
SELECT
  upper(nome) AS maiuscula,
  lower(nome) AS minuscula,
  initcap(nome) AS pri_letra_maiuscula
FROM belleza_verde.clientes2
WHERE id_cliente IN (1, 8, 15, 17);

-- Funções de extração e corte
-- Corte: LTRIM, RTRIM, TRIM
-- Extração: LEFT, RIGHT
SELECT
  localizacao,
  LEFT(localizacao, 4) AS esquerda,
  RIGHT(localizacao, 4) AS direita,
  LTRIM(localizacao) AS corte_esquerda,
  RTRIM(localizacao) AS corte_direita,
  TRIM(localizacao) AS corte_ambas,
  LTRIM(localizacao, "-") AS corte_texto_extra
FROM belleza_verde.clientes2
WHERE id_cliente IN (1, 3, 23);

-- Funções de análise e concatenação
-- CHAR_LENGTH, ENDS_WITH, STARTS_WITH, CONCAT
SELECT
  localizacao,
  CHAR_LENGTH(localizacao) AS contagem_caracteres,
  CHAR_LENGTH(TRIM(localizacao)) AS contagem_sem_espacos_extras,
  STARTS_WITH(localizacao, 'Ba') AS comeca_com_ba,
  ENDS_WITH(localizacao, 'ná') AS termina_com_na,
  concat(TRIM(nome, '-'), ' - ', localizacao) AS concatecao
FROM belleza_verde.clientes
WHERE id_cliente IN (1, 8, 15, 17);

-- Funções de busca e modificação
-- INSTR, SUBSTRING

SELECT
  nome,
  INSTR(LTRIM(nome), ' '),
  SUBSTRING(INITCAP(REPLACE(nome, '&', ' ')), 5) AS posicao_espaco
FROM belleza_verde.clientes2;

-- Expressões regulares
-- REGEX
-- [0-9]{5}-[0-9]{3}|[0-9]{8}
WITH
  subquery1 AS (
    SELECT
      cep,
      regexp_contains(cep, r'[0-9]{5}-[0-9]{3}|[0-9]{8}') AS cep_contains,
      regexp_extract(cep, r'[0-9]{5}-[0-9]{3}|[0-9]{8}') AS cep_extract
    FROM belleza_verde.clientes2
  )
SELECT
  cep,
  CASE
    WHEN regexp_contains(cep_extract, r'[0-9]{8}')
      THEN concat(substring(cep_extract, 1, 5), '-', substring(cep_extract, 6))
    ELSE cep_extract
    END AS cep_final
FROM subquery1;

-- Formatando textos e números
-- FORMAT
SELECT
  CONCAT(
    'O cliente ',
    c.nome,
    ' comprou a quantidade de ',
    format("%'d", sum(quantidade)),
    ' itens, com o valor total de ',
    replace(
      replace(
        replace(format("R$%'.*f", 2, sum(quantidade * preco)), '.', ';'),
        ',',
        '.'),
      ';',
      ',')),
  format('%d', sum(quantidade)) AS formato_num_pra_texto_inteiro,
  format('%f', sum(quantidade * preco)) AS format_num_pra_texto_decimal
FROM `belleza_verde.clientes2` c
INNER JOIN belleza_verde.vendas v
  ON c.id_cliente = v.id_cliente
GROUP BY c.nome;

SELECT
  current_date,
  current_datetime,
  current_timestamp,
  current_datetime('America/Sao_Paulo'),
  current_time;

SELECT
  date(2026, 08, 04),
  time(22, 14, 35),
  datetime(2026, 08, 04, 22, 14, 35),
  timestamp("2026-08-04 22:14:35"),
  current_datetime('UTC+3');

SELECT
  date_add(current_datetime(), INTERVAL 3 week) AS tres_semanas,
  date_add(current_timestamp, INTERVAL 5 day) AS cinco_dias_afrente,
  date_sub(current_datetime('UTC-3'), INTERVAL 50 minute) AS cinquenta_minutos,
  date_diff(current_datetime('UTC-3'), current_datetime('UTC'), minute)
    AS dias_UTC,
  date_add(date '2021-07-01', INTERVAL 30 day) AS trinta_dias;

SELECT lista_datas
FROM UNNEST(generate_date_array('2026-05-01', current_date)) AS lista_datas;

SELECT
  DATA,
  EXTRACT(YEAR FROM DATA),
  EXTRACT(QUARTER FROM DATA),
  EXTRACT(MONTH FROM DATA),
  EXTRACT(WEEK FROM DATA),
  EXTRACT(DAYOFWEEK FROM DATA),
  EXTRACT(DAY FROM DATA)
FROM UNNEST(GENERATE_DATE_ARRAY('2021-01-01', CURRENT_DATE)) AS DATA;

WITH
  LISTA_DATAS AS (
    SELECT DATA
    FROM UNNEST(GENERATE_DATE_ARRAY('2021-01-01', CURRENT_DATE())) AS DATA
  )
SELECT DISTINCT VEN.data, LISTA_DATAS.DATA
FROM belleza_verde.vendas VEN
LEFT JOIN LISTA_DATAS
  ON VEN.data = LISTA_DATAS.DATA
WHERE
  EXTRACT(YEAR FROM LISTA_DATAS.DATA) = 2022
  AND VEN.data IS NULL
ORDER BY LISTA_DATAS.DATA;

SELECT
  c.data,
  EXTRACT(DAYOFWEEK FROM c.data) AS dia_da_semana,
  CASE
    WHEN EXTRACT(DAYOFWEEK FROM c.data) = 6
      THEN DATE_ADD(c.data, INTERVAL 5 DAY)
    ELSE DATE_ADD(c.data, INTERVAL 3 DAY)
    END AS data_entrega_estimada
FROM
  belleza_verde.vendas c;

WITH
  ajuste_dias_uteis AS (
    SELECT
      id_produto,
      data,
      quantidade,
      CASE
        WHEN
          EXTRACT(
            dayofweek FROM date_trunc(date_add(data, INTERVAL 1 month), month))
          = 7
          THEN
            date_add(
              date_trunc(date_add(data, INTERVAL 1 month), month),
              INTERVAL 2 day)
        WHEN
          EXTRACT(
            dayofweek FROM date_trunc(date_add(data, INTERVAL 1 month), month))
          = 1
          THEN
            date_add(
              date_trunc(date_add(data, INTERVAL 1 month), month),
              INTERVAL 1 day)
        ELSE date_trunc(date_add(data, INTERVAL 1 month), month)
        END
        AS dias
    FROM belleza_verde.vendas
  )
SELECT *, date_add(dias, INTERVAL 21 day) AS quinze_dias_uteis
FROM ajuste_dias_uteis;

-- %A: Retorna o nome completo do dia da semana, como "Segunda-feira".
-- %a: Retorna o nome abreviado do dia da semana, como "Seg".
-- %B: Retorna o nome completo do mês, como "Janeiro".
-- %b ou %h: Retorna o nome abreviado do mês, como "Jan".
-- %C: Retorna o século como um número decimal (00-99), onde o ano é dividido por 100 e truncado.
-- %D: Retorna a data no formato MM/DD/YY.
-- %d: Retorna o dia do mês como número decimal (01-31).
-- %e: Retorna o dia do mês como número decimal (1-31), onde dígitos únicos são precedidos por um espaço.
-- %F: Retorna a data no formato YYYY-MM-DD.
-- %G: Retorna o ano ISO 8601 com século como número decimal. Este formato é útil para sistemas que seguem a semana ISO, que começa na segunda-feira da semana que contém o primeiro dia de janeiro.
-- %g: Similar ao %G, mas sem o século (00-99).
-- %j: Retorna o dia do ano como número decimal (001-366).
-- %m: Retorna o mês como número decimal (01-12).
-- %n: Insere um caractere de nova linha.
-- %Q: Retorna o trimestre do ano como um número decimal (1-4).
-- %t: Insere um caractere de tabulação.
-- %U: Retorna o número da semana do ano, considerando o domingo como o primeiro dia da semana (00-53).
-- %u: Retorna o dia da semana como número decimal (1-7), considerando a segunda-feira como o primeiro dia.
-- %V: Retorna o número da semana do ano segundo o padrão ISO 8601 (01-53).
-- %W: Retorna o número da semana do ano, considerando a segunda-feira como o primeiro dia da semana (00-53).
-- %w: Retorna o dia da semana como número decimal (0-6), com o domingo como o primeiro dia.
-- %x: Retorna a representação da data no formato MM/DD/YY.
-- %Y: Retorna o ano com século como número decimal.
-- %y: Retorna o ano sem o século como número decimal (00-99).
-- %E4Y: Retorna o ano com quatro caracteres (0001 ... 9999).
-- %H: Retorna a hora em um relógio de 24 horas como número decimal (00-23).
-- %I: Retorna a hora em um relógio de 12 horas como número decimal (01-12).
-- %M: Retorna o minuto como número decimal (00-59).
-- %P: Retorna "am" ou "pm" com base na hora do dia.
-- %p: Retorna "AM" ou "PM" com base na hora do dia.
-- %R: Retorna a hora no formato HH:MM.
-- %S: Retorna o segundo como número decimal (00-60), incluindo a possibilidade de segundos bissextos.
-- %T: Retorna a hora no formato HH:MM:SS.
-- %X: Retorna a representação da hora no formato HH:MM:SS.
-- %%: Retorna um único caractere "%".
-- %E#S: Retorna os segundos com # dígitos de precisão fracionária.
-- %E*S: Retorna os segundos com precisão fracionária total (um literal '*').

SELECT format_datetime('%d/%m/%Y', current_datetime('America/Sao_Paulo'));

SELECT id_venda, data, format_date('%A-%d-%B-%C', data)
FROM belleza_verde.vendas;

-- DATA e TEMPO UNIX - Funciona somente com TIMESTAMP por haver minutos e segundos

SELECT
  current_timestamp AS agora,
  unix_seconds(current_timestamp) AS tempo_unix,
  timestamp_seconds(unix_seconds(current_timestamp))
    AS unix_convertido_timestamp;

SELECT
  format_timestamp(
    '%Y-%m-%d %H:%M:%S', timestamp_seconds(unix_seconds(current_timestamp)));

WITH
  VENDAS_ANUAIS AS (
    SELECT
      VENDEDORES.id_vendedor,
      VENDEDORES.nome AS nome_vendedor,
      PRODUTOS.id_produto,
      PRODUTOS.nome AS nome_produto,
      EXTRACT(YEAR FROM VENDAS.data) AS ano,
      SUM(VENDAS.quantidade) AS total_vendas
    FROM
      belleza_verde.vendas VENDAS
    INNER JOIN
      belleza_verde.produtos PRODUTOS
      ON
        VENDAS.id_produto = PRODUTOS.id_produto
    INNER JOIN
      belleza_verde.clientes CLIENTES
      ON
        VENDAS.id_cliente = CLIENTES.id_cliente
    INNER JOIN
      belleza_verde.vendedores VENDEDORES
      ON
        CLIENTES.id_vendedor = VENDEDORES.id_vendedor
    GROUP BY
      VENDEDORES.id_vendedor,
      VENDEDORES.nome,
      PRODUTOS.id_produto,
      PRODUTOS.nome,
      EXTRACT(
        YEAR
        FROM
          VENDAS.data)
  ),
  VENDAS_TODOS_OS_ANOS AS (
    SELECT
      VENDEDORES.id_vendedor,
      VENDEDORES.nome AS nome_vendedor,
      PRODUTOS.id_produto,
      PRODUTOS.nome AS nome_produto,
      SUM(VENDAS.quantidade) AS total_vendas
    FROM
      belleza_verde.vendas VENDAS
    INNER JOIN
      belleza_verde.produtos PRODUTOS
      ON
        VENDAS.id_produto = PRODUTOS.id_produto
    INNER JOIN
      belleza_verde.clientes CLIENTES
      ON
        VENDAS.id_cliente = CLIENTES.id_cliente
    INNER JOIN
      belleza_verde.vendedores VENDEDORES
      ON
        CLIENTES.id_vendedor = VENDEDORES.id_vendedor
    GROUP BY
      VENDEDORES.id_vendedor,
      VENDEDORES.nome,
      PRODUTOS.id_produto,
      PRODUTOS.nome
  )
SELECT
  VENDAS_ANUAIS.nome_vendedor,
  replace(trim(VENDAS_ANUAIS.nome_produto), '-', '') AS nome_produto,
  VENDAS_ANUAIS.ano,
  VENDAS_ANUAIS.total_vendas,
  FORMAT(
    "%'.*f",
    2,
    (VENDAS_ANUAIS.total_vendas / VENDAS_TODOS_OS_ANOS.total_vendas) * 100)
    AS distribuicao_vendas,
  METAS.quantidade_meta,
  CASE
    WHEN VENDAS_ANUAIS.total_vendas >= METAS.quantidade_meta THEN 'BOM'
    ELSE
      'RUIM'
    END
    AS status_meta,
  FORMAT(
    "%'.*f",
    2,
    ((VENDAS_ANUAIS.total_vendas / METAS.quantidade_meta) - 1) * 100)
    AS performance
FROM
  VENDAS_ANUAIS
INNER JOIN
  belleza_verde.metas METAS
  ON
    VENDAS_ANUAIS.id_produto = METAS.id_produto
    AND VENDAS_ANUAIS.id_vendedor = METAS.id_vendedor
    AND VENDAS_ANUAIS.ano = METAS.ano
INNER JOIN
  VENDAS_TODOS_OS_ANOS
  ON
    VENDAS_ANUAIS.id_produto = VENDAS_TODOS_OS_ANOS.id_produto
    AND VENDAS_ANUAIS.id_vendedor = VENDAS_TODOS_OS_ANOS.id_vendedor;

-- FORMAT_DATETIME: Formata um valor DATETIME de acordo com um padrão especificado. Ex.: FORMAT_DATETIME('%d/%m/%Y %H:%M', DATETIME '2021-01-01 15:00') retorna '01/01/2021 15:00'.
-- FORMAT_DATE: Similar a FORMAT_DATETIME, mas para valores DATE. Ex.: FORMAT_DATE('%d/%m/%Y', DATE '2021-01-01') resulta em '01/01/2021'.
-- TIMESTAMP_SECONDS: Converte um valor de segundos desde a época Unix (1º de janeiro de 1970) em um TIMESTAMP. Ex.: TIMESTAMP_SECONDS(1609459200) converte para o TIMESTAMP de '2021-01-01 00:00:00 UTC'.
-- TIMESTAMP_ADD: Adiciona um intervalo específico a um TIMESTAMP. Ex.: TIMESTAMP_ADD(TIMESTAMP "2021-01-01 00:00:00 UTC", INTERVAL 1 MONTH) adiciona um mês ao TIMESTAMP, resultando em '2021-02-01 00:00:00 UTC'.
-- UNIX_SECONDS: Converte um TIMESTAMP em segundos desde a época Unix. Ex.: UNIX_SECONDS(TIMESTAMP "2021-01-01 00:00:00 UTC") retorna 1609459200, o número de segundos desde '1970-01-01 00:00:00 UTC' até o TIMESTAMP especificado.
