#Protótipo de procedure para inclusão de dados em tabela.
CREATE OR REPLACE PROCEDURE
 belleza_verde.incluiVenda(idVenda INT64, idProduto INT64, idCliente INT64, dataVenda DATE, quantVenda INT64, precoVenda FLOAT64)
 BEGIN
  INSERT INTO belleza_verde.vendas(id_venda,id_produto,id_cliente, data, quantidade, preco)
  VALUES(idVenda, idProduto, idCliente, dataVenda, quantVenda, precoVenda);
 END;

-------------------------------------------------------------------------------------
# Primeira procedure completa, inclui dados de uma nova venda, testando se produto existe, existindo, é criado automaticamente uma nova linha de venda, caso não exista, é exibido uma mensagem.
CREATE OR REPLACE
  procedure
    belleza_verde.incluiVenda1(
      idProduto int64,
      idCliente int64,
      dataVenda date,
      quantVenda int64,
      precoVenda float64)
      begin
        declare idVenda int64;
        declare produtoExiste BOOL DEFAULT FALSE;
        declare messageText string;
          SET produtoExiste = (
            SELECT
              EXISTS(SELECT 1 FROM belleza_verde.produtos WHERE id_produto = idProduto) # Verifica a existência do produto antes de incluir na venda.
          );
              IF produtoExiste THEN begin
              SET
                id_venda = (
                  SELECT IFNULL(MAX(id_venda), 0) + 1 FROM belleza_verde.vendas) # Automatiza o ID da venda.
                  INSERT INTO `belleza_verde.vendas`(
                    id_venda, id_produto, id_cliente, data, quantidade, preco)
                    values(
                      idVenda, idProduto, idCliente, dataVenda, quantVenda, precoVenda);
                      END;
              ELSE
                begin
              SET messageText = 'Erro: produto não existe'; # Caso não haja produto cadastrado, o erro é exibido.
              SELECT
                messageText
                  END;
              END IF;
END;

CALL belleza_verde.incluiVenda1(1, 1, '2024-01-01', 10, 5);

-------------------------------------------------------------------------------------
# Remove a mensagem de texto e inclui o retorno do idRetornoCliente e clienteExiste. Verifica se ambas as condições são verdadeiras para a inclusão de um novo produto e cliente na base de dados.
CREATE OR REPLACE
  procedure
    belleza_verde.incluiVenda2(
      idProduto int64,
      idCliente int64,
      dataVenda date,
      quantVenda int64,
      precoVenda float64)
      begin
        declare idVenda int64;
        declare produtoExiste BOOL DEFAULT FALSE;
        declare clienteExiste BOOL DEFAULT FALSE;
        declare idRetornoProduto INT64;
        declare idRetornoCliente INT64;
          SET produtoExiste = (
            SELECT
              EXISTS(SELECT 1 FROM belleza_verde.produtos WHERE id_produto = idProduto) # Verifica a existência do produto antes de incluir na venda.
          );
          SET clienteExiste = (
            SELECT
              EXISTS(SELECT 1 FROM belleza_verde.produtos WHERE id_cliente = idCliente) # Verifica a existência do produto antes de incluir na venda.
          )
              IF produtoExiste and clienteExiste THEN begin
              SET
                idVenda = (
                  SELECT IFNULL(MAX(id_venda), 0) + 1 FROM belleza_verde.vendas) # Automatiza o ID da venda.
                  INSERT INTO `belleza_verde.vendas`(
                    id_venda, id_produto, id_cliente, data, quantidade, preco)
                    values(
                      idVenda, idProduto, idCliente, dataVenda, quantVenda, precoVenda);
                      SET idRetornoProduto = 1;
                      SET idRetornoCliente = 1;
                      END;
              ELSE
                begin
              SET idRetornoProduto = IF(produtoExiste, 1, 0);
              SET idRetornoCliente = IF(clienteExiste, 1, 0);
                  END;
              END IF;
              select idRetornoProduto as Produto, idRetornoCliente as Cliente;
END;

CALL belleza_verde.incluiVenda(100, 1, '2024-01-03', 10, 5);

-------------------------------------------------------------------------------------
# Criando a procedure com duas variáveis de referência (idRetornoProduto e idRetornoCliente)
CREATE OR REPLACE
  procedure
    belleza_verde.incluiVenda3(
      idProduto int64,
      idCliente int64,
      dataVenda date,
      quantVenda int64,
      precoVenda float64)
      OUT idRetornoProduto INT64;
      OUT idRetornoCliente INT64;
      begin
        declare idVenda int64;
        declare produtoExiste BOOL DEFAULT FALSE;
        declare clienteExiste BOOL DEFAULT FALSE;
          SET produtoExiste = (
            SELECT
              EXISTS(SELECT 1 FROM belleza_verde.produtos WHERE id_produto = idProduto) # Verifica a existência do produto antes de incluir na venda.
          );
          SET clienteExiste = (
            SELECT
              EXISTS(SELECT 1 FROM belleza_verde.produtos WHERE id_cliente = idCliente) # Verifica a existência do produto antes de incluir na venda.
          )
              IF produtoExiste and clienteExiste THEN begin
              SET
                idVenda = (
                  SELECT IFNULL(MAX(id_venda), 0) + 1 FROM belleza_verde.vendas) # Automatiza o ID da venda.
                  INSERT INTO `belleza_verde.vendas`(
                    id_venda, id_produto, id_cliente, data, quantidade, preco)
                    values(
                      idVenda, idProduto, idCliente, dataVenda, quantVenda, precoVenda);
                      SET idRetornoProduto = 1;
                      SET idRetornoCliente = 1;
                      END;
              ELSE
                begin
              SET idRetornoProduto = IF(produtoExiste, 1, 0);
              SET idRetornoCliente = IF(clienteExiste, 1, 0);
                  END;
              END IF;
              select idRetornoProduto as Produto, idRetornoCliente as Cliente;
END;

-------------------------------------------------------------------------------------
# Declarando e realizando uma condicional para verificar se produto e cliente existem.
DECLARE idRetornoProduto INT64;
DECLARE idRetornoCliente INT64;
CALL belleza_verde.incluiVenda3(100, 1, '2024-01-03', 10, 5,idRetornoProduto, idRetornoCliente);
IF idRetornoProduto = 0 AND idRetornoCliente = 0 THEN
  SELECT 'Identificador do PRODUTO e do CLIENTE inválidos' AS mensagem;
ELSEIF idRetornoProduto = 1 AND idRetornoCliente = 0 THEN
  SELECT 'Identificador do CLIENTE inválido' AS mensagem;
ELSEIF idRetornoProduto = 0 AND idRetornoCliente = 1 THEN
  SELECT 'Identificador do PRODUTO inválido' AS mensagem;
ELSE SELECT 'Produto e Cliente incluídos com sucesso';
END IF;

-------------------------------------------------------------------------------------
# Automatizando o valor pago pelo cliente no produto, não sendo mais preciso digitar manualmente
CREATE OR REPLACE
  procedure
    belleza_verde.incluiVenda4(
      idProduto int64,
      idCliente int64,
      dataVenda date,
      quantVenda int64)
      OUT idRetornoProduto INT64;
      OUT idRetornoCliente INT64;
      begin
        declare idVenda int64;
        declare precoVenda float64;
        declare produtoExiste BOOL DEFAULT FALSE;
        declare clienteExiste BOOL DEFAULT FALSE;
          SET produtoExiste = (
            SELECT
              EXISTS(SELECT 1 FROM belleza_verde.produtos WHERE id_produto = idProduto) # Verifica a existência do produto antes de incluir na venda.
          );
          SET clienteExiste = (
            SELECT
              EXISTS(SELECT 1 FROM belleza_verde.produtos WHERE id_cliente = idCliente) # Verifica a existência do produto antes de incluir na venda.
          )
            IF produtoExiste and clienteExiste THEN begin
              SET 
              precoVenda = (
                SELECT preco from belleza_verde.produtos where id_produto = idProduto)
              SET
              idVenda = (
                SELECT IFNULL(MAX(id_venda), 0) + 1 FROM belleza_verde.vendas) # Automatiza o ID da venda.
                INSERT INTO `belleza_verde.vendas`(
                  id_venda, id_produto, id_cliente, data, quantidade, preco)
                  values(
                    idVenda, idProduto, idCliente, dataVenda, quantVenda, precoVenda);
                    SET idRetornoProduto = 1;
                    SET idRetornoCliente = 1;
                    END;
              ELSE
                BEGIN
                  SET idRetornoProduto = IF(produtoExiste, 1, 0);
                  SET idRetornoCliente = IF(clienteExiste, 1, 0);
              END;
            END IF;
              select idRetornoProduto as Produto, idRetornoCliente as Cliente;
END;

-------------------------------------------------------------------------------------
# Declarando e realizando uma condicional para verificar se produto e cliente existem.
DECLARE idRetornoProduto INT64;
DECLARE idRetornoCliente INT64;
CALL belleza_verde.incluiVenda4(100, 1, '2024-01-03', 10, idRetornoProduto, idRetornoCliente);
IF idRetornoProduto = 0 AND idRetornoCliente = 0 THEN
  SELECT 'Identificador do PRODUTO e do CLIENTE inválidos' AS mensagem;
ELSEIF idRetornoProduto = 1 AND idRetornoCliente = 0 THEN
  SELECT 'Identificador do CLIENTE inválido' AS mensagem;
ELSEIF idRetornoProduto = 0 AND idRetornoCliente = 1 THEN
  SELECT 'Identificador do PRODUTO inválido' AS mensagem;
ELSE SELECT 'Produto e Cliente incluídos com sucesso';
END IF;

-------------------------------------------------------------------------------------
# UDF (User Defined Functions)
# Criando números aleatórios para cliente e produto
CREATE OR REPLACE FUNCTION belleza_verde.NumAleatorio(min iNT64, max INT64)
  RETURNS INT64
  AS (
    CAST(FLOOR(RAND() * (max - min + 1)) AS INT64) + min
  );

SELECT belleza_verde.NumAleatorio(1, 100) as valor_aleatorio;

-------------------------------------------------------------------------------------
# Criando UDF que retorna a data americana formatada para o padrão brasileiro.
CREATE OR REPLACE FUNCTION belleza_verde.dataFormatada(data DATE)
  RETURNS STRING AS(
    FORMAT('%02d/%02d/%04d',
      EXTRACT(DAY from data),
      EXTRACT(month from data),
      extract(year from data)
    )
  );
SELECT belleza_verde.dataFormatada('2023-01-01');

-------------------------------------------------------------------------------------
# Adicionando a UDF na declaração da procedure para automatizar produto e cliente (com números aleatórios)
DECLARE idRetornoProduto INT64;
DECLARE idRetornoCliente INT64;
DECLARE minProduto INT64;
DECLARE maxProduto INT64;
DECLARE idProduto INT64;
DECLARE minCliente INT64;
DECLARE maxCliente INT64;
DECLARE idCliente INT64;

SET minProduto = (select MIN(id_produto) from belleza_verde.produtos);
SET maxProduto = (select MAX(id_produto) from belleza_verde.produtos);
SET idProduto = belleza_verde.NumAleatorio(minProduto, maxProduto);

SET minCliente = (select MIN(id_cliente) from belleza_verde.clientes);
SET maxCliente = (select MAX(id_cliente) from belleza_verde.clientes);
SET idCliente = belleza_verde.NumAleatorio(minCliente, maxCliente);

CALL belleza_verde.incluiVenda4(idProduto, idCliente, '2024-01-03', 10, idRetornoProduto, idRetornoCliente);

IF idRetornoProduto = 0 AND idRetornoCliente = 0 THEN
  SELECT 'Identificador do PRODUTO e do CLIENTE inválidos' AS mensagem;
ELSEIF idRetornoProduto = 1 AND idRetornoCliente = 0 THEN
  SELECT 'Identificador do CLIENTE inválido' AS mensagem;
ELSEIF idRetornoProduto = 0 AND idRetornoCliente = 1 THEN
  SELECT 'Identificador do PRODUTO inválido' AS mensagem;
ELSE SELECT 'Produto e Cliente incluídos com sucesso';
END IF;

-------------------------------------------------------------------------------------
# Query para retornar o custo do produto, buscando na tabela de materiasprimas os arrays das colunas materiaprima e distribuicao. Para cada conjunto de array, há um percentual, faz-se a divisão do custo total pelo percentual de uso do produto.
WITH index_produtos as (
  select id_produto, nome, categoria, preco, 
  array (select as struct mp, row_number() over() as idx from unnest(materias primas) as mp) as materiaprima_index,
  array (select as struct ds, row_number() over() as idx from unnest(materiasprimas) as ds) as distribuicao_index
  from belleza_verde.produtos),
produtos_distribuicao_custo as (
  select mpUN.mp as id_materia, dsUN.ds as distribuica_materia, M.custo
  from index_produtos ip
  cross join unnest(ip.materiaprima_index) as mpUN
  cross join unnest(ip.distribuicao_index) as dsUN
  on mpUN.idx = dsUN.idx
  inner join belleza_verde.materiasprimas M
  on cast(mpUN.mp as INT64) = M.id_materia)
select sum(produtos_distribuicao_custo.distribuicao_materia * produtos_distribuicao_custo.custo) as total_preco_produto
from produtos_distribuicao_custo;

-------------------------------------------------------------------------------------
# Versão final de três procedures que automatizam a inclusão de vendas.
# 1ª Procedure seta os parâmetros pré inclusão, ao identificar se há o id do produto e do cliente na tabela. Isso é feito através de duas flags "idRetornoProduto" e "idRetornoCliente". Se ambas forem TRUE, é incluído um novo id de venda e o preço é adicionado, com a condição de que, se o preço de tabela for menor que o preço da manufatura, usa-se o preço de manufatura, se não, usará o preço de tabela.

-- Criação ou substituição da procedure
CREATE OR REPLACE
  procedure
    belleza_verde.incluiVenda5(

      -- Define quais são os parâmetros que serão inseridos na call
      idProduto int64,
      idCliente int64,
      dataVenda date,
      quantVenda int64,
      margem float64,

      -- "OUT" faz com que ambas as variáveis fiquem de fora do insert, sendo possível manipula-las na próxima função, para identificar se ambas serão TRUE.
      OUT idRetornoProduto INT64,
      OUT idRetornoCliente INT64)

      -- Início da procedure. Declara as variáveis que serão usadas dentro da procedure
      begin
        declare idVenda int64;
        declare produtoExiste BOOL DEFAULT FALSE;
        declare clienteExiste BOOL DEFAULT FALSE;
        declare precoVenda float64;
        declare precoVendaMP FLOAT64;
        declare precoVendaTB FLOAT64;

          -- Atribui às variáveis, consultas de identificação de id. É necessário que os ids existam nas tabelas antes de inserir os dados.
          SET produtoExiste = (
            SELECT
              EXISTS(SELECT 1 FROM belleza_verde.produtos WHERE id_produto = idProduto) # Verifica a existência do produto antes de incluir na venda.
          );
          SET clienteExiste = (
            SELECT
              EXISTS(SELECT 1 FROM belleza_verde.produtos WHERE id_cliente = idCliente)
          )
            -- Se o produto e o cliente forem TRUE..
            IF produtoExiste and clienteExiste THEN begin

              -- Bsuca o preço do produto na tabela, onde o id dá match
              SET 
              precoVendaTB = (
                SELECT preco from belleza_verde.produtos where id_produto = idProduto)

                -- Subquery que faz a pesquisa do do custo da matéria prima e do percentual de distribuição em uma ARRAY, que representa na composição do produto
                precoVendaMP = 
                  WITH index_produtos as (
                    select id_produto, nome, categoria, preco, 
                    array (select as struct mp, row_number() over() as idx from unnest(materiasprimas) as mp) as materiaprima_index,
                    array (select as struct ds, row_number() over() as idx from unnest(distribuicao) as ds) as distribuicao_index
                    from belleza_verde.produtos where id_produto = idProduto),

                -- Busca as materias primas e a distribuição da subquery index_produtos
                  produtos_distribuicao_custo as (
                    select mpUN.mp as id_materia, dsUN.ds as distribuica_materia, M.custo
                    from index_produtos ip

                    -- faz o join usando os index gerados na subconsulta index_produtos
                    cross join unnest(ip.materiaprima_index) as mpUN
                    cross join unnest(ip.distribuicao_index) as dsUN
                    on mpUN.idx = dsUN.idx
                    inner join belleza_verde.materiasprimas M
                    on cast(mpUN.mp as INT64) = M.id_materia)

                  -- Calcula o custo total de um produto em relação ao custo das matérias primas e seus percentuais. Caso o preço de tabela seja menor que o de
                  -- fabricação, é calculado o preço da matéria acrescido de uma margem de lucro. Caso o preço de tabela for maior que o preço da matéria prima e da margem,
                  -- então usa-se o preço de tabela.
                  select sum(produtos_distribuicao_custo.distribuicao_materia * produtos_distribuicao_custo.custo) as total_preco_produto
                  from produtos_distribuicao_custo;
                    set precoVendaMP = precoVendaMP + margem;
                    if precoVendaMP >= precoVendaTB then
                    set precoVenda = precoVendaMP;
                    else
                    set precoVenda = precoVendaTB;
                    end if;

              -- Automatiza o id da venda, incluindo na tabela vendas o valor do novo id. Mas só o faz se as variáveis idRetornoProduto e idRetornoCliente são ambas TRUE.
              SET
              idVenda = (
                SELECT IFNULL(MAX(id_venda), 0) + 1 FROM belleza_verde.vendas)
                INSERT INTO `belleza_verde.vendas`(
                  id_venda, id_produto, id_cliente, data, quantidade, preco)
                  values(
                    idVenda, idProduto, idCliente, dataVenda, quantVenda, precoVenda);
                    SET idRetornoProduto = 1;
                    SET idRetornoCliente = 1;
                    END;
              ELSE
                BEGIN
                  SET idRetornoProduto = IF(produtoExiste, 1, 0);
                  SET idRetornoCliente = IF(clienteExiste, 1, 0);
              END;
            END IF;
              select idRetornoProduto as Produto, idRetornoCliente as Cliente;
END;

-- Procedure que utilizará os idRetorno para incluir os dados de venda. Enquanto a procedure anterior calcula o preço e insere o id, esta procedure é a que fará a identificação
-- da lógica para inserção.
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

    -- Por não haver vendas reais, essa parte realiza o sorteamento dos números de produto e cliente entre os valores mínimos e máximos dos ids para inserção na tabela de vendas
    SET minProduto = (select MIN(id_produto) from belleza_verde.produtos);
    SET maxProduto = (select MAX(id_produto) from belleza_verde.produtos);
    SET idProduto = belleza_verde.NumAleatorio(minProduto, maxProduto);

    SET minCliente = (select MIN(id_cliente) from belleza_verde.clientes);
    SET maxCliente = (select MAX(id_cliente) from belleza_verde.clientes);
    SET idCliente = belleza_verde.NumAleatorio(minCliente, maxCliente);

    -- Inserção do idProduto e do idCliente automático, as próximas três ainda são inseridas manualmente, enquanto os idRetorno são usados na lógica IF
    CALL belleza_verde.incluiVenda5(idProduto, idCliente, dataVenda, quantidade, margemLucro, idRetornoProduto, idRetornoCliente);

    -- Gera um aviso caso não exista o produto ou o cliente
    IF idRetornoProduto = 0 AND idRetornoCliente = 0 THEN
      SELECT 'Identificador do PRODUTO e do CLIENTE inválidos' AS mensagem;
    ELSEIF idRetornoProduto = 1 AND idRetornoCliente = 0 THEN
      SELECT 'Identificador do CLIENTE inválido' AS mensagem;
    ELSEIF idRetornoProduto = 0 AND idRetornoCliente = 1 THEN
      SELECT 'Identificador do PRODUTO inválido' AS mensagem;
    ELSE SELECT 'Produto e Cliente incluídos com sucesso';
    END IF;
  END;

-- Procedure final, que deve ser usada como principal procedure para inserção dos dados. Automatiza todo o processo, gera quantidades e datas. Somente margem de lucro é manual.
create or replace procedure belleza_verde.conjuntoVendas (
  minQuantidade INT64, maxQuantidade INT64, minVendasDia INT64, maxVendasDia int64, margemLucro int64)
  BEGIN
    declare dataVenda date;
    declare quantidade int64;
    declare dataInicial date;
    declare dataFinal date;
    declare numVendasDias int64;

    -- Insere vendas na data de hoje ou no máximo dois dias atrás
    set dataInicial = select date_sub(current_date(), interval 2 day);
    set dataFinal = current_date();

    -- Loop FOR. O for externo faz o unnest de uma série de array de data entre a data inicial e final setada anteriormente, gerando uma lista de datas
    for dataCorrente in (select dia from unnest(generate_date_array(dataInicial,dataFinal)) as dia)
    DO
      BEGIN

        -- Como a array é um JSON, é usado o "dataCorrente.dia" para acessar as informações das datas
        SET dataVenda = dataCorrente.dia;
        set numVendasDias = (belleza_verde.NumAleatorio(minVendasDias, maxVendasDias));

        -- Agora gera um array mas para o número de vendas que serão efetuas no dia, com fator aleatório
        for i in (select num from unnest(generate_array(1, numVendasDias)) as num)
        DO
          BEGIN
            -- Aleatóriamente atribui uma quantidade de itens vendidos entre um mínimo e um máximo, de forma aleatória
            set quantidade = (belleza_verde.NumAleatorio(minQuantidade, maxQuantidade));

            -- insere as informações criadas nesta procedure, na procedure anterior, após isso, fecha-se o loop. Agora é possível configurar atualizações diárias.
            call belleza_verde.incluiVendaFinal(quantidade, dataVenda, margemLucro);
          end;
        end for;
      end;
    end for;
  end; 
  
  -- Essa call pode ser configurada para rodar em certos períodos, atualizando automaticamente.
  call belleza_verde.conjuntoVendas(1, 10, 1, 5, 10);

-------------------------------------------------------------------------------------