with vendas_arredondadas as (
  with vendas_comparativas as (
    select p.nome, 
    sum(v.quantidade * v.preco) as faturamento,
    sum(v.quantidade * p.preco) as faturamento_tabela
    from belleza_verde.vendas v
    inner join belleza_verde.produtos p
    on v.id_produto = p.id_produto
    where extract(year from v.data) = 2022
    and v.id_produto <> 11
    and v.id_produto not in (12, 13, 14)
    group by p.nome)
  select nome, 
  (((ieee_divide(faturamento, faturamento_tabela)) -1) * 100) as percentual 
  from vendas_comparativas)
select nome, 
percentual as percent_raw, 
round(percentual, 2) as percent_round_2,
round(percentual, 0) as percent_round_0,
trunc(percentual, 2) as percent_trunc,
floor(percentual) as percent_floor,
ceil(percentual) as percent_ceil
from vendas_arredondadas;

-------------------------------------------------------------
SELECT IEEE_DIVIDE(10, 2) as result1, -- Retorna 5
       IEEE_DIVIDE(10, 0) as result2, -- Retorna Infinity
       IEEE_DIVIDE(0, 0) as result3,  -- Retorna NaN
       IEEE_DIVIDE(0, 10) as result4; -- Retorna 0
-------------------------------------------------------------

select sqrt(144);
select sqrt(-144); -- 
select safe.sqrt(-144); -- Usar o "SAFE" para retornar nan quando a raiz é negativa.
-------------------------------------------------------------
WITH data AS (
  SELECT [1, 2, 3, 4] AS numbers UNION ALL
  SELECT [5, 6] AS numbers)
SELECT numbers, numbers[SAFE_OFFSET(2)] AS third_element
FROM data; --  A função SAFE_OFFSET no BigQuery é uma função de manipulação de arrays que permite acessar um elemento de um array com base em sua posição (índice) de forma segura. A segurança, neste contexto, refere-se à capacidade da função de evitar erros quando o índice especificado está fora dos limites do array, retornando NULL em vez de um erro.
-------------------------------------------------------------


select 
resultado[safe_offset(0)].array_faturamento as first_element,
resultado[safe_offset(1)].array_faturamento as second_element,
resultado[safe_offset(2)].array_faturamento as third_element
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
            AS array_faturamento),
        STRUCT(
          1 AS produto,
          2 AS cliente,
          [4565.0000000000005, 7847.4099999999994]
            AS array_faturamento)] AS resultado
  );

----------------------------------------------------------------
SELECT 
  (1000.00) + (NUMERIC '10.00' / NUMERIC '3.00' * NUMERIC '3.00') AS saldoe_numeric,
  (1000.00) + (CAST(10.00 AS FLOAT64) / CAST(3.00 AS FLOAT64) * CAST(3.00 AS FLOAT64)) AS saldo_float;
----------------------------------------------------------------

select 
  produto,
  faturamento,
  sign(faturamento) as sinal
FROM UNNEST(
  (
    SELECT
      [
        STRUCT(
          1 AS produto,
          1 AS cliente,
          3443 as faturamento),
        STRUCT(
          2 AS produto,
          2 AS cliente,
          -3855 as faturamento),
        STRUCT(
          3 AS produto,
          3 AS cliente,
          0 as faturamento)]
  )
);
----------------------------------------------------------
SELECT SIGN(-10) AS ResultadoNegativo, -- Retorna -1
       SIGN(0) AS ResultadoZero,      -- Retorna 0
       SIGN(15.5) AS ResultadoPositivo; -- Retorna 1
----------------------------------------------------------

select * 
from belleza_verde.vendas 
where rand() <= 0.1; -- Retorna 10% dos dados da tabela

select * 
from belleza_verde.vendas 
order by rand(); -- Obtem um resultado da tabela de forma aleatória
select rand() as aleatorio_0_1; -- Retorna um valor aleatório entre 0 e 1.

-- Potenciação e Raiz
select pow (2, 2); -- 2 elevado à segunda potência
select sqrt(12);
-- Ângulo
select radians(10); -- converte de graus para radianos
select degrees(10); -- converte de radianos para graus
-- Trigonometria
select sin(radians(10)); -- Retorna o seno do ângulo x, onde x está em radianos.
select cos(radians(10)); -- Retorna o cosseno do ângulo x, onde x está em radianos.
select tan(radians(10)); -- Retorna a tangente do ângulo x, onde x está em radianos.
select asin(10); -- Retorna o arco seno de x, em radianos.
select acos(10); -- Retorna o arco cosseno de x, em radianos.
select atan(10); -- Retorna o arco tangente de x, em radianos.
-- Logarítmicas
select ln(10); -- Retorna o logaritmo natural de x
select log(10, 2); -- Retorna o logaritmo de x na base especificada ou 10 como padrão
-- Comparação
select greatest(1,2,3,4,5); -- Retorna o maior valor de uma série
select least(1,2,3,4,5); -- Retorna o menor valor de uma série
-- Módulo
select mod(10, 6); -- Retorna o resto da divisão
-- Multiplicação segura
select safe_multiply(10, 20); -- Multiplica retornando null se o resultado der erro.

