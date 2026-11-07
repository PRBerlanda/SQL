
USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_22`;

DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_22`()
BEGIN
	declare vAluguel VARCHAR(10) default 10001;
    declare vCliente varchar(10) default 1002;
    declare vHospedagem varchar(10) default 8635;
    declare vDataInicio date default '2023-03-01';
    declare vDataFinal date default '2023-03-05';
    declare vPrecoTotal decimal(10,2) default 550.23;
    insert into alugueis values( vAluguel, vCliente, vHospedagem,
    vDataInicio, vDataFinal, vPrecoTotal );
END$$

DELIMITER ;

select * from alugueis where aluguel_id = '10001';

call novoAluguel_22;

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_23`;

DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_23`
(	vAluguel VARCHAR(10),
	vCliente varchar(10),
	vHospedagem varchar(10),
	vDataInicio date,
	vDataFinal date,
	vPrecoTotal decimal(10,2))
BEGIN
    insert into alugueis values( vAluguel, vCliente, vHospedagem,
    vDataInicio, vDataFinal, vPrecoTotal );
END$$

DELIMITER ;

call novoAluguel_23('10002', '1003', '8635', '2023-03-06', '2023-03-10', 600);

select * from alugueis where aluguel_id = '10002';

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_24`;

DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_24`
(	vAluguel VARCHAR(10),
	vCliente varchar(10),
	vHospedagem varchar(10),
	vDataInicio date,
	vDataFinal date,
	vPrecoUnitario decimal(10,2))
BEGIN
	declare vDias integer default 0;
    declare vPrecoTotal decimal(10,2);
    set vDias = (select datediff(vDataFinal, vDataInicio));
    set vPrecoTotal = vDias * vPrecoUnitario;
    insert into alugueis values( vAluguel, vCliente, vHospedagem,
    vDataInicio, vDataFinal, vPrecoTotal );
END$$

DELIMITER ;

call novoAluguel_24('10004', '1004', '8635', '2023-03-13', '2023-03-16', 40);

delete from alugueis where aluguel_id = '10004';

select * from alugueis where aluguel_id = '10004';

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_25`;

DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_25`
(	vAluguel VARCHAR(10),
	vCliente varchar(10),
	vHospedagem varchar(10),
	vDataInicio date,
	vDataFinal date,
	vPrecoUnitario decimal(10,2))
BEGIN
	declare vDias integer default 0;
    declare vPrecoTotal decimal(10,2);
    declare vMensagem VARCHAR(100);
    declare exit handler for 1452
    begin
		set vMensagem = "Problema de chave estrangeira";
        select vMensagem;
    end;
    set vDias = (select datediff(vDataFinal, vDataInicio));
    set vPrecoTotal = vDias * vPrecoUnitario;
    insert into alugueis values( vAluguel, vCliente, vHospedagem,
    vDataInicio, vDataFinal, vPrecoTotal );
    set vMensagem = 'Aluguel incluso com sucesso';
    select vMensagem;
END$$

DELIMITER ;

call novoAluguel_25('10005', '1005', '8635', '2023-03-17', '2023-03-25', 40);

select * from alugueis where aluguel_id = '10005';

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_27`;

DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_27`
(	vAluguel VARCHAR(10),
	vClienteNome varchar(150),
	vHospedagem varchar(10),
	vDataInicio date,
	vDataFinal date,
	vPrecoUnitario decimal(10,2))
BEGIN
	declare vCliente varchar(10);
	declare vDias integer default 0;
    declare vNumCliente integer;
    declare vPrecoTotal decimal(10,2);
    declare vMensagem VARCHAR(100);
    declare exit handler for 1452
    begin
		set vMensagem = "Problema de chave estrangeira";
        select vMensagem;
    end;
    set vNumCliente = (select count(*) from clientes where nome = vClienteNome);
	if vNumCliente > 1 then
		set vMensagem = "Há mais de um cliente com o mesmo nome";
        select vMensagem;
	elseif vNumCliente = 0 then
		set vMensagem = "Cliente não existe na base de dados";
        select vMensagem;
    else
        set vDias = (select datediff(vDataFinal, vDataInicio));
		set vPrecoTotal = vDias * vPrecoUnitario;
		select cliente_id into vCliente from clientes where nome = vClienteNome;
		insert into alugueis values( vAluguel, vCliente, vHospedagem,
		vDataInicio, vDataFinal, vPrecoTotal );
		set vMensagem = 'Aluguel incluso com sucesso';
		select vMensagem;
    end if;
END$$
DELIMITER ;

call novoAluguel_27('10007', 'Paulo Ricardo', '8635', '2023-03-19', '2023-03-30', 120);

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_28`;

DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_28`
(	vAluguel VARCHAR(10),
	vClienteNome varchar(150),
	vHospedagem varchar(10),
	vDataInicio date,
	vDataFinal date,
	vPrecoUnitario decimal(10,2))
BEGIN
	declare vCliente varchar(10);
	declare vDias integer default 0;
    declare vNumCliente integer;
    declare vPrecoTotal decimal(10,2);
    declare vMensagem VARCHAR(100);
    declare exit handler for 1452
    begin
		set vMensagem = "Problema de chave estrangeira";
        select vMensagem;
    end;
    set vNumCliente = (select count(*) from clientes where nome = vClienteNome);
    case vNumCliente
    when 0 then
		set vMensagem = "Cliente não existe na base de dados";
        select vMensagem;
	when 1 then
        set vDias = (select datediff(vDataFinal, vDataInicio));
		set vPrecoTotal = vDias * vPrecoUnitario;
		select cliente_id into vCliente from clientes where nome = vClienteNome;
		insert into alugueis values( vAluguel, vCliente, vHospedagem,
		vDataInicio, vDataFinal, vPrecoTotal );
		set vMensagem = 'Aluguel incluso com sucesso';
		select vMensagem;
	else
		set vMensagem = "Há mais de um cliente com o mesmo nome";
        select vMensagem;
    end case;
END$$
DELIMITER ;


USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_29`;

DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_29`
(	vAluguel VARCHAR(10),
	vClienteNome varchar(150),
	vHospedagem varchar(10),
	vDataInicio date,
	vDataFinal date,
	vPrecoUnitario decimal(10,2))
BEGIN
	declare vCliente varchar(10);
	declare vDias integer default 0;
    declare vNumCliente integer;
    declare vPrecoTotal decimal(10,2);
    declare vMensagem VARCHAR(100);
    declare exit handler for 1452
    begin
		set vMensagem = "Problema de chave estrangeira";
        select vMensagem;
    end;
    set vNumCliente = (select count(*) from clientes where nome = vClienteNome);
    case 
    when vNumCliente = 0 then
		set vMensagem = "Cliente não existe na base de dados";
        select vMensagem;
	when vNumCliente > 1 then
		set vMensagem = "Há mais de um cliente com o mesmo nome";
        select vMensagem;
	when vNumCliente = 1 then
        set vDias = (select datediff(vDataFinal, vDataInicio));
		set vPrecoTotal = vDias * vPrecoUnitario;
		select cliente_id into vCliente from clientes where nome = vClienteNome;
		insert into alugueis values( vAluguel, vCliente, vHospedagem,
		vDataInicio, vDataFinal, vPrecoTotal );
		set vMensagem = 'Aluguel incluso com sucesso';
		select vMensagem;
    end case;
END$$
DELIMITER ;

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_30`;

DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_30`
(	vAluguel VARCHAR(10),
	vClienteNome varchar(150),
	vHospedagem varchar(10),
	vDataInicio date,
	vDias integer,
	vPrecoUnitario decimal(10,2))
BEGIN
	declare vCliente varchar(10);
	declare vDataFinal date;
    declare vNumCliente integer;
    declare vPrecoTotal decimal(10,2);
    declare vMensagem VARCHAR(100);
    declare exit handler for 1452
    begin
		set vMensagem = "Problema de chave estrangeira";
        select vMensagem;
    end;
    set vNumCliente = (select count(*) from clientes where nome = vClienteNome);
    case 
    when vNumCliente = 0 then
		set vMensagem = "Cliente não existe na base de dados";
        select vMensagem;
	when vNumCliente > 1 then
		set vMensagem = "Há mais de um cliente com o mesmo nome";
        select vMensagem;
	when vNumCliente = 1 then
        set vDataFinal = (select (vDataInicio + interval vDias day));
		set vPrecoTotal = vDias * vPrecoUnitario;
		select cliente_id into vCliente from clientes where nome = vClienteNome;
		insert into alugueis values( vAluguel, vCliente, vHospedagem,
		vDataInicio, vDataFinal, vPrecoTotal );
		set vMensagem = 'Aluguel incluso com sucesso';
		select vMensagem;
    end case;
END$$
DELIMITER ;

call novoAluguel_30('10008', 'Rafael Peixoto', '8635', '2023-04-01', 5, 120);
select * from alugueis where aluguel_id = '10008';

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_31`;

DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_31`
(	vAluguel VARCHAR(10),
	vClienteNome varchar(150),
	vHospedagem varchar(10),
	vDataInicio date,
	vDias integer,
	vPrecoUnitario decimal(10,2))
BEGIN
	declare vCliente varchar(10);
    declare vContador INTEGER;
    declare vDiaSemana INTEGER;
	declare vDataFinal date;
    declare vNumCliente integer;
    declare vPrecoTotal decimal(10,2);
    declare vMensagem VARCHAR(100);
    declare exit handler for 1452
    begin
		set vMensagem = "Problema de chave estrangeira";
        select vMensagem;
    end;
    set vNumCliente = (select count(*) from clientes where nome = vClienteNome);
    case 
    when vNumCliente = 0 then
		set vMensagem = "Cliente não existe na base de dados";
        select vMensagem;
	when vNumCliente > 1 then
		set vMensagem = "Há mais de um cliente com o mesmo nome";
        select vMensagem;
	when vNumCliente = 1 then
        -- set vDataFinal = (select (vDataInicio + interval vDias day));
        set vContador = 1;
        set vDataFinal = vDataInicio;
			while vContador < vDias
            do
				set vDiaSemana = (select dayofweek(str_to_date(vDataFinal, '%Y-%m-%d')));
				if vDiaSemana <> 7 and vDiaSemana <> 1 then 
					set vContador = vContador + 1;
				end if;
                set vDataFinal = (select (vDataFinal + interval 1 day));
			end while;
		set vPrecoTotal = vDias * vPrecoUnitario;
		select cliente_id into vCliente from clientes where nome = vClienteNome;
		insert into alugueis values( vAluguel, vCliente, vHospedagem,
		vDataInicio, vDataFinal, vPrecoTotal );
		set vMensagem = 'Aluguel incluso com sucesso';
		select vMensagem;
    end case;
END$$
DELIMITER ;

call novoAluguel_31('10009', 'Rafael Peixoto', '8635', '2023-04-10', 14, 120);
select * from alugueis where aluguel_id = '10009';


-- =====================================================================================
-- Procedures auxiliares usadas a partir da novoAluguel_33.
-- Elas foram criadas durante o curso, mas não estavam salvas neste arquivo; foram
-- reconstruídas a partir de como são chamadas e da lógica da novoAluguel_31.
-- =====================================================================================

-- Calcula a data final contando apenas dias úteis (segunda a sexta), a partir da data inicial.
-- Mesma lógica do loop WHILE da novoAluguel_31, agora reaproveitável: vDataFinal é parâmetro de saída.
USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`calculaDataFinal_01`;

DELIMITER $$
USE `insight_places`$$
CREATE PROCEDURE `calculaDataFinal_01`
(	vDataInicio date,
	OUT vDataFinal date,
	vDias integer)
BEGIN
	declare vContador integer;
	declare vDiaSemana integer;
	set vContador = 1;
	set vDataFinal = vDataInicio;
	while vContador < vDias
	do
		set vDiaSemana = dayofweek(vDataFinal); -- 1 = domingo, 7 = sábado
		if vDiaSemana <> 7 and vDiaSemana <> 1 then
			set vContador = vContador + 1;
		end if;
		set vDataFinal = vDataFinal + interval 1 day;
	end while;
END$$
DELIMITER ;

-- Teste: 5 diárias a partir de sábado, 01/04/2023
set @dataFinal = null;
call calculaDataFinal_01('2023-04-01', @dataFinal, 5);
select @dataFinal as data_final;

-- Calcula o preço total (diárias x preço unitário) e inclui o aluguel.
-- Não tem handler próprio: um erro de chave estrangeira (1452) sobe para o handler
-- da procedure que a chamou (novoAluguel_34 / novoAluguel_36).
USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`calcula_preco_total`;

DELIMITER $$
USE `insight_places`$$
CREATE PROCEDURE `calcula_preco_total`
(	vAluguel varchar(10),
	vCliente varchar(10),
	vHospedagem varchar(10),
	vDataInicio date,
	vDataFinal date,
	vDias integer,
	vPrecoUnitario decimal(10,2))
BEGIN
	declare vPrecoTotal decimal(10,2);
	set vPrecoTotal = vDias * vPrecoUnitario;
	insert into alugueis values (vAluguel, vCliente, vHospedagem,
		vDataInicio, vDataFinal, vPrecoTotal);
END$$
DELIMITER ;

-- Primeira versão da inclusão separada em procedure (usada pela novoAluguel_34).
-- Mesma assinatura da calcula_preco_total, para a qual apenas repassa os parâmetros.
USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`inclusao_cliente_43`;

DELIMITER $$
USE `insight_places`$$
CREATE PROCEDURE `inclusao_cliente_43`
(	vAluguel varchar(10),
	vCliente varchar(10),
	vHospedagem varchar(10),
	vDataInicio date,
	vDataFinal date,
	vDias integer,
	vPrecoUnitario decimal(10,2))
BEGIN
	call calcula_preco_total(vAluguel, vCliente, vHospedagem,
		vDataInicio, vDataFinal, vDias, vPrecoUnitario);
END$$
DELIMITER ;

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_33`;

DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_33`
(	vAluguel VARCHAR(10),
	vClienteNome varchar(150),
	vHospedagem varchar(10),
	vDataInicio date,
	vDias integer,
	vPrecoUnitario decimal(10,2))
BEGIN
	declare vCliente varchar(10);
	declare vDataFinal date;
    declare vNumCliente integer;
    declare vPrecoTotal decimal(10,2);
    declare vMensagem VARCHAR(100);
    declare exit handler for 1452
    begin
		set vMensagem = "Problema de chave estrangeira";
        select vMensagem;
    end;
    set vNumCliente = (select count(*) from clientes where nome = vClienteNome);
    case 
    when vNumCliente = 0 then
		set vMensagem = "Cliente não existe na base de dados";
        select vMensagem;
	when vNumCliente > 1 then
		set vMensagem = "Há mais de um cliente com o mesmo nome";
        select vMensagem;
	when vNumCliente = 1 then
        -- set vDataFinal = (select (vDataInicio + interval vDias day));
        call calculaDataFinal_01 (vDataInicio, vDataFinal, vDias);
		set vPrecoTotal = vDias * vPrecoUnitario;
		select cliente_id into vCliente from clientes where nome = vClienteNome;
		insert into alugueis values( vAluguel, vCliente, vHospedagem,
		vDataInicio, vDataFinal, vPrecoTotal );
		set vMensagem = 'Aluguel incluso com sucesso';
		select vMensagem;
    end case;
END$$
DELIMITER ;

call novoAluguel_33('10010', 'Rafael Peixoto', '8635', '2023-04-01', 5, 120);
select * from alugueis where aluguel_id = '10010';

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_34`;

DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_34`
(	vAluguel VARCHAR(10),
	vClienteNome varchar(150),
	vHospedagem varchar(10),
	vDataInicio date,
	vDias integer,
	vPrecoUnitario decimal(10,2))
BEGIN
	declare vCliente varchar(10);
	declare vDataFinal date;
    declare vNumCliente integer;
    declare vPrecoTotal decimal(10,2);
    declare vMensagem VARCHAR(100);
    declare exit handler for 1452
    begin
		set vMensagem = "Problema de chave estrangeira";
        select vMensagem;
    end;
    set vNumCliente = (select count(*) from clientes where nome = vClienteNome);
    case 
    when vNumCliente = 0 then
		set vMensagem = "Cliente não existe na base de dados";
        select vMensagem;
	when vNumCliente > 1 then
		set vMensagem = "Há mais de um cliente com o mesmo nome";
        select vMensagem;
	when vNumCliente = 1 then
        call calculaDataFinal_01 (vDataInicio, vDataFinal, vDias);
		select cliente_id into vCliente from clientes where nome = vClienteNome;
        call inclusao_cliente_43(vAluguel, vCliente, vHospedagem, 
        vDataInicio, vDataFinal, vDias, vPrecoUnitario);
		set vMensagem = 'Aluguel incluso com sucesso';
		select vMensagem;
    end case;
END$$
DELIMITER ;

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_36`;

DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_36`
(	vClienteNome varchar(150),
	vHospedagem varchar(10),
	vDataInicio date,
	vDias integer,
	vPrecoUnitario decimal(10,2))
BEGIN
	declare vAluguel varchar(10);
	declare vCliente varchar(10);
	declare vDataFinal date;
    declare vNumCliente integer;
    declare vPrecoTotal decimal(10,2);
    declare vMensagem VARCHAR(100);
    declare exit handler for 1452
    begin
		set vMensagem = "Problema de chave estrangeira";
        select vMensagem;
    end;
    set vNumCliente = (select count(*) from clientes where nome = vClienteNome);
    case 
    when vNumCliente = 0 then
		set vMensagem = "Cliente não existe na base de dados";
        select vMensagem;
	when vNumCliente > 1 then
		set vMensagem = "Há mais de um cliente com o mesmo nome";
        select vMensagem;
	when vNumCliente = 1 then
		select cast(max(cast(aluguel_id as UNSIGNED)) + 1 as CHAR) into vAluguel from alugueis;
        call calculaDataFinal_01 (vDataInicio, vDataFinal, vDias);
		select cliente_id into vCliente from clientes where nome = vClienteNome;
        call calcula_preco_total(vAluguel, vCliente, vHospedagem, 
        vDataInicio, vDataFinal, vDias, vPrecoUnitario);
		set vMensagem = concat('Aluguel incluso com sucesso - ID: ', vAluguel);
		select vMensagem;
    end case;
END$$
DELIMITER ;

call novoAluguel_36( 'Rafael Peixoto', '8635', '2023-04-01', 5, 120);
select * from alugueis where aluguel_id = '10011';

-- Procedures auxiliares para a inclusão em lote (reconstruídas, ver nota acima):
-- inclui_usuarios_lista separa uma lista de nomes separados por vírgula e grava cada nome
-- na tabela temporária temp_nomes (criada por quem chama); looping_cursor percorre essa
-- tabela com um cursor e exibe cada nome.
USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`inclui_usuarios_lista`;

DELIMITER $$
USE `insight_places`$$
CREATE PROCEDURE `inclui_usuarios_lista`(lista varchar(255))
BEGIN
	declare vNome varchar(255);
	declare vRestante varchar(255);
	declare vPosicao integer;
	set vRestante = lista;
	while char_length(vRestante) > 0 do
		set vPosicao = locate(',', vRestante);
		if vPosicao = 0 then
			set vNome = vRestante;
			set vRestante = '';
		else
			set vNome = substring(vRestante, 1, vPosicao - 1);
			set vRestante = substring(vRestante, vPosicao + 1);
		end if;
		if char_length(trim(vNome)) > 0 then
			insert into temp_nomes (nome) values (trim(vNome));
		end if;
	end while;
END$$
DELIMITER ;

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`looping_cursor`;

DELIMITER $$
USE `insight_places`$$
CREATE PROCEDURE `looping_cursor`()
BEGIN
	declare fimCursor integer default 0;
	declare vNome varchar(255);
	declare cursor1 cursor for select nome from temp_nomes;
	declare continue handler for not found set fimCursor = 1;
	open cursor1;
	fetch cursor1 into vNome;
	while fimCursor = 0 do
		select vNome as nome;
		fetch cursor1 into vNome;
	end while;
	close cursor1;
END$$
DELIMITER ;

-- tempo_nomes(nome)

DROP TEMPORARY TABLE IF EXISTS temp_nomes;
CREATE TEMPORARY TABLE temp_nomes(nome VARCHAR(255));
CALL inclui_usuarios_lista('Luana Moura,Enrico Correia,Paulo Vieira,Marina Nunes');
SELECT * FROM temp_nomes;
call looping_cursor();


USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novosAluguesComLoopCursor`;

DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novosAluguesComLoopCursor`(
	lista varchar(255), 
	vHospedagem varchar(10),
	vDataInicio date,
	vDias integer,
	vPrecoUnitario decimal(10,2))
BEGIN
	declare vClienteNome varchar(150);
	declare fimCursor integer default 0;
    declare vNome varchar(255);
    declare cursor1 cursor for select nome from temp_nomes;
    declare continue handler for not found set fimCursor = 1;
    DROP TEMPORARY TABLE IF EXISTS temp_nomes;
	CREATE TEMPORARY TABLE temp_nomes(nome VARCHAR(255));
    call inclui_usuarios_lista(lista);
    open cursor1;
    fetch cursor1 into vNome;
    while fimCursor = 0 do
		set vClienteNome = vNome;
        call novoAluguel_36 (vClienteNome,vHospedagem,vDataInicio,vDias,vPrecoUnitario);
        fetch cursor1 into vNome;
	end while;
    close cursor1;
	DROP TEMPORARY TABLE IF EXISTS temp_nomes;
END$$

DELIMITER ;

call novosAluguesComLoopCursor('Gabriel Carvalho,Erick Oliveira,Catarina Correia,Lorena Jesus','8635','2023-04-28',6,40);
select * from alugueis where aluguel_id IN ('10012','10013','10014','10015');
