select avg(nota), tipo
from avaliacoes a
join hospedagens h
on h.hospedagem_id = a.hospedagem_id
group by tipo;

select sum(preco_total) valorTotal, max(preco_total) valorMaximo, 
min(preco_total) valorMinimo, avg(preco_total) mediaPrecos 
from alugueis a
join hospedagens h
on h.hospedagem_id = a.hospedagem_id
group by tipo;

select concat(trim(nome), ' - ', contato) nome_contato from clientes;

select nome, concat(
	substring(cpf, 1, 3), '.', 
    substring(cpf, 4, 3), '.', 
    substring(cpf, 7, 3), '-', 
    substring(cpf, 10, 2)) CPF 
    from clientes;

select 
	upper(e.cidade) as Cidade,
	count(a.avaliacao_id) as TotalAvaliacoes,
    avg (a.nota) as MediaNotas
from avaliacoes a
join hospedagens h on a.hospedagem_id = h.hospedagem_id
join enderecos e on e.endereco_id = h.endereco_id
group by e.cidade
order by MediaNotas desc, totalAvaliacoes desc;

select now() hoje;

select tipo, sum(datediff(data_fim, data_inicio)) dias from 
alugueis a
join hospedagens h
on a.hospedagem_id = h.hospedagem_id
group by tipo;

select hospedagem_id, nota,
case nota
	when 5 then 'excelente'
    when 4 then 'ótimo'
    when 3 then 'médio'
    when 2 then 'ruim'
    when 1 then 'péssimo'
    when 0 then 'reprovado'
end as StatusNota
from avaliacoes;

-- Criar novas funções customizaveis

delimiter $$
create function retornoConstante()
returns varchar(200) deterministic
begin 

return 'Seja bem-vindo(a)';

end $$
delimiter ;

select retornoConstante();

drop function insight_places.MediaAvaliacoes;

delimiter $$
create function MediaAvaliacoes()
returns float deterministic
begin
declare media float;

select round(avg(nota), 2) mediaNotas
into media
from avaliacoes;

return media;
end $$
delimiter ;

select MediaAvaliacoes();

delimiter $$
create function calcularOcupacaoMedia() -- Cria função com algum nome
returns decimal(5,2) deterministic -- Decide qual será o tipo de retorno da função
begin -- inicia a função
	-- declara as variáveis
	declare totalHospedagens int;
    declare totalOcupadas int;
    declare ocupacaoMedia decimal(5,2);
    -- faz os selects para realizar a divisão dos valores
	select count(*) into totalHospedagens from hospedagens;
	select count(*) into totalOcupadas from alugueis;
	set ocupacaoMedia = (totalOcupadas / totalHospedagens) * 100;
-- retorna o valor
return ocupacaoMedia;
end $$
delimiter ;

select calcularOcupacaoMedia();

delimiter $$
create function FormatandoCPF(clienteID int)
returns varchar(50) deterministic

begin
declare novoCPF varchar(50);

	set novoCPF = (
		select concat(
			substring(cpf, 1, 3), '.', 
			substring(cpf, 4, 3), '.', 
			substring(cpf, 7, 3), '-', 
			substring(cpf, 10, 2)) CPF 
			from clientes
            where cliente_id = clienteID
            );
            
return novoCPF;
end $$
delimiter ;

select trim(nome), cpf, formatandoCPF(1) as cpf from clientes where cliente_id = 1;

delimiter $$ -- Entrada do novo delimitador
create function InfoAluguel(idAluguel int) -- nome da função e o input que é o aluguel_id
returns varchar(50) deterministic -- retorna um texto
begin -- inicia a função

declare nomeCliente varchar(100); -- atribui a variável o output c.nome do select
declare precoTotal decimal(10,2); -- atribui a variável o output a.preco_total do select
declare dias int; -- int do datediff entre as datas
declare valorDiaria decimal(10,2); -- Divisão do precoTotal e dias
declare resultado varchar(55); -- Variável Output da função (concatenação dos valores)
    
    -- Serve para buscar as informações do aluguel_id que será dado como input
    select c.nome, a.preco_total, datediff(data_fim, data_inicio)
    into nomeCliente, precoTotal, dias
    from alugueis a
    join clientes c
    on a.cliente_id = c.cliente_id
    where aluguel_id = idAluguel;
    
set valorDiaria = precoTotal / dias;

set resultado = 
concat('Nome: ', nomeCliente, ', Valor Diário R$ ', format(valorDiaria, 2));

return resultado;
end $$
delimiter ;

select InfoAluguel(10000);

drop function insight_places.tipoHospedagem
delimiter $$
create function TipoHospedagem(tipoHospedagem varchar(50))
returns varchar(50) deterministic
begin
declare tipoImovel varchar(50);
declare ImoveisAtivos int;

select tipo, count(tipo) 
into tipoImovel, ImoveisAtivos 
from hospedagens 
where ativo = 1 and tipo = tipoHospedagem
group by tipo;

return concat('O tipo: ', tipoImovel, ' Tem atualmente: ',ImoveisAtivos, ' imóveis ativos');
end$$
delimiter ;

select TipoHospedagem('Casa');

DELIMITER $$
CREATE FUNCTION nome_da_funcao (-- parametro1 tipo, parametro2 tipo, ... )
RETURNS tipo
BEGIN
DECLARE nome_variavel tipo;
DECLARE nome_variavel tipo DEFAULT valor_inicial;
    -- Corpo da função: instruções SQL e lógica da função
    RETURN valor;
END$$
DELIMITER;

CREATE FUNCTION funcao (parametro1 int, parametro2 varchar)
RETURNS float
	BEGIN
		DECLARE variavel INT DEFAULT valor
	RETURN expressao;
END;

delimiter $$
create function CalcularDescontoPorDias (AluguelID int)
returns int deterministic
begin
	declare desconto INT;
    select
		case
			when datediff(data_fim, data_inicio) BETWEEN 4 and 5 then 5
			when datediff(data_fim, data_inicio) BETWEEN 7 and 9 then 10
			when datediff(data_fim, data_inicio) >= 10 then 15
			else 0
		end
        into desconto
	from alugueis
	where aluguel_id = AluguelID;
    return desconto;
end $$
delimiter ;

select CalcularDescontoPorDias(1);

DELIMITER $$

CREATE FUNCTION CalcularValorFinalComDesconto()
RETURNS DECIMAL(10,2) DETERMINISTIC

BEGIN
DECLARE ValorTotal DECIMAL(10,2);
DECLARE Desconto INT;
DECLARE ValorFinal DECIMAL(10,2);

SELECT preco_total INTO ValorTotal FROM alugueis WHERE aluguel_id = AluguelID;
SET Desconto = CalcularDescontoPorDias(AluguelID);
SET ValorFinal = ValorTotal - (ValorTotal * Desconto / 100);
RETURN ValorFinal;
END$$

DELIMITER ;

select CalcularValorFinalComDesconto(77);

delimiter $$
create function calculaMediaEstadia()
returns int deterministic
begin
	declare media float;
    select round(avg(datediff(data_fim, data_inicio))) into media from alugueis;
    return media;
end $$
delimiter ;

select calculaMediaEstadia();

delimiter $$
create function CalcularValorComDesconto(aluguelID int)
returns decimal(10,2) deterministic
begin

	declare valorAluguel decimal(10,2);
    declare desconto int;
    declare valorFinal decimal(10,2);
    
	select preco_total into valorAluguel from alugueis where aluguel_id = aluguelID;
	
    set desconto = CalcularDescontoPorDias(aluguelID);
    
    set valorFinal = valorAluguel - ((valorAluguel * desconto) / 100);

return valorFinal;

end $$

delimiter ;

select CalcularValorComDesconto(1);

create table resumo_aluguel (
aluguel_id varchar(255),
cliente_id varchar(255),
valortotal decimal(10,2),
descontoaplicado decimal(10,2),
valorfinal decimal(10,2),
primary key (aluguel_id, cliente_id),
foreign key (aluguel_id) references alugueis(aluguel_id),
foreign key (cliente_id) references clientes(cliente_id)
);

SELECT InfoAluguel(1);
