SELECT
    (SELECT COUNT(*) FROM proprietarios) AS total_proprietarios,
    (SELECT COUNT(*) FROM clientes) AS total_clientes,
    (SELECT COUNT(*) FROM enderecos) AS total_enderecos,
    (SELECT COUNT(*) FROM hospedagens) AS total_hospedagens,
    (SELECT COUNT(*) FROM alugueis) AS total_alugueis,
    (SELECT COUNT(*) FROM avaliacoes) AS total_avaliacoes;
    
select hospedagem_id,
	MIN(data_inicio) as primeira_data,
    MAX(data_fim) as ultima_data,
	sum(datediff(data_fim, data_inicio)) as dias_ocupados,
	datediff(max(data_fim), min(data_inicio)) as total_dias,
    round(sum(datediff(data_fim, data_inicio)) / datediff(max(data_fim), min(data_inicio)), 2) as taxa_ocupacao
from alugueis
group by hospedagem_id
order by taxa_ocupacao asc;

select * from proprietarios;

select * from hospedagens;

USE insight_places;

SELECT p.nome AS proprietarios, 
COUNT(DISTINCT h.hospedagem_id) AS hospedagens 
from hospedagens h
join proprietarios p
on h.proprietario_id = p.proprietario_id
group by p.nome
order by hospedagens desc;


SELECT 
p.nome AS proprietarios, 
min(primeira_data) as primeira_data,
sum(total_dias) as total_dias,
sum(dias_ocupados) as dias_ocupados,
round((sum(dias_ocupados) / sum(total_dias)) * 100, 2) as taxa_ocupacao
	from(
		select 
        hospedagem_id,
		MIN(data_inicio) as primeira_data,
		sum(datediff(data_fim, data_inicio)) as dias_ocupados,
		datediff(max(data_fim), min(data_inicio)) as total_dias
		from 
			alugueis
		group by 
			hospedagem_id
    ) tabela_taxa_ocupacao
join 
	hospedagens h on tabela_taxa_ocupacao.hospedagem_id = h.hospedagem_id
join 
	proprietarios p on h.proprietario_id = p.proprietario_id
group by 
	p.proprietario_id
order by 
	taxa_ocupacao desc;
    
select 
p.nome as proprietario,
round(
	sum(
		datediff(a.data_fim, a.data_inicio)) / 
        datediff(max(a.data_fim), min(a.data_inicio)),
	2) as taxa_ocupacao,
round(
	avg(a.preco_total / 
    datediff(a.data_fim, a.data_inicio)), 
    2) as preco_medio
from 
	proprietarios p
join
	hospedagens h on p.proprietario_id = h.proprietario_id
join
	alugueis a on h.hospedagem_id = a.hospedagem_id
group by
	p.proprietario_id;
    
select
	year(data_inicio) as ano,
    month(data_inicio) as mês,
    count(*) as total_alugueis
from
	alugueis
group by
	ano, mês
order by ano, mês asc;

select * from enderecos;
select * from alugueis;
select * from hospedagens;

select
	distinct(en.estado) as estados,
    round(
		avg(a.preco_total / 
        datediff(a.data_fim, a.data_inicio)) * 100) as media_preco
from 
	enderecos en
join 
	hospedagens h on h.endereco_id = en.endereco_id
join
	alugueis a on a.hospedagem_id = h.hospedagem_id
group by estados
order by media_preco desc;


select
	distinct(e.estado) as estados,
    round(
		avg(a.preco_total / 
        datediff(a.data_fim, a.data_inicio)), 2) as media_preco,
    round(
		max(a.preco_total / 
        datediff(a.data_fim, a.data_inicio)), 2) as preco_maximo,
    round(
		min(a.preco_total / 
        datediff(a.data_fim, a.data_inicio)), 2) as preco_minimo
from 
	alugueis a
join 
	hospedagens h on a.hospedagem_id = h.hospedagem_id
join
	enderecos e on h.endereco_id = e.endereco_id
group by estados
order by media_preco desc;

select * from alugueis;

select
	month(data_inicio) as mês,
    avg(datediff(data_fim, data_inicio)) as dias_alugado
from
	alugueis
group by mês;

SELECT
    year(data_inicio) as ano,
    month(data_inicio) as mes,
    count(*) as total_alugueis
FROM
    alugueis a
JOIN
    hospedagens h ON a.hospedagem_id = h.hospedagem_id
JOIN
    enderecos e ON h.endereco_id = e.endereco_id
JOIN 
    regioes_geograficas r ON r.estado = e.estado
WHERE
	r.regiao = "Sudeste"
GROUP BY
    ano, mes
order by ano, mes asc;

delimiter $$
drop procedure if exists alugueis_por_regiao;
create procedure alugueis_por_regiao(nome_regiao varchar(255))
begin
SELECT
    year(data_inicio) as ano,
    month(data_inicio) as mes,
    count(*) as total_alugueis
FROM
    alugueis a
JOIN
    hospedagens h ON a.hospedagem_id = h.hospedagem_id
JOIN
    enderecos e ON h.endereco_id = e.endereco_id
JOIN 
    regioes_geograficas r ON r.estado = e.estado
WHERE
	r.regiao = nome_regiao
GROUP BY
    ano, mes
order by 
	ano, mes asc;

end $$
delimiter ;

call alugueis_por_regiao("Sudeste");

drop procedure if exists taxa_ocupacao;

delimiter $$
create procedure taxa_ocupacao(ID varchar(255))
begin
	SELECT 
	p.nome AS proprietarios, 
	min(primeira_data) as primeira_data,
	sum(total_dias) as total_dias,
	sum(dias_ocupados) as dias_ocupados,
	round((sum(dias_ocupados) / sum(total_dias)) * 100, 2) as taxa_ocupacao
		from(
			select 
			hospedagem_id,
			MIN(data_inicio) as primeira_data,
			sum(datediff(data_fim, data_inicio)) as dias_ocupados,
			datediff(max(data_fim), min(data_inicio)) as total_dias
			from 
				alugueis
			group by 
				hospedagem_id
		) tabela_taxa_ocupacao
	join 
		hospedagens h on tabela_taxa_ocupacao.hospedagem_id = h.hospedagem_id
	join 
		proprietarios p on h.proprietario_id = p.proprietario_id
	where
		p.proprietario_id = ID
	group by 
		p.proprietario_id
	order by 
		total_dias desc;
end $$
delimiter ;

call taxa_ocupacao("21");

create view metricas_proprietario as
	SELECT 
	p.nome AS proprietarios, 
	min(primeira_data) as primeira_data,
	sum(total_dias) as total_dias,
	sum(dias_ocupados) as dias_ocupados,
	round((sum(dias_ocupados) / sum(total_dias)) * 100, 2) as taxa_ocupacao
		from(
			select 
			hospedagem_id,
			MIN(data_inicio) as primeira_data,
			sum(datediff(data_fim, data_inicio)) as dias_ocupados,
			datediff(max(data_fim), min(data_inicio)) as total_dias
			from 
				alugueis
			group by 
				hospedagem_id
		) tabela_taxa_ocupacao
	join 
		hospedagens h on tabela_taxa_ocupacao.hospedagem_id = h.hospedagem_id
	join 
		proprietarios p on h.proprietario_id = p.proprietario_id
	group by 
		p.proprietario_id
	order by 
		total_dias desc;
        
select * from metricas_proprietario;