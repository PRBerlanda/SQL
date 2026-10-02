CREATE DATABASE loja;
USE loja;

SHOW TABLES;

CREATE TABLE clientes (
	id_cliente INT auto_increment KEY,
    nome varchar(100) NOT null,
    email varchar(100) NOT NULL,
    endereco varchar(255) 
);

create table produtos (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    estoque INT NOT NULL
);


insert into clientes (nome, email, endereco) values 
('Joao', 'joao@email.com', 'rua: Silva, numero 200'),
('Ana', 'ana@email.com', 'rua: Maria, numero 42');

INSERT INTO produtos (nome, descricao, preco, estoque) VALUES
('Notebook Dell', 'Notebook Dell Inspiron 15', 3500.00, 10),
('Mouse Logitech', 'Mouse sem fio Logitech M170', 80.00, 50),
('Teclado Mecânico', 'Teclado Mecânico RGB', 250.00, 20);

select * from clientes;
select * from produtos;

select * from produtos
where preco between 80 and 250;

select * from produtosclientes
where estoque > 30;

select * from produtos
where preco < 100 and estoque > 5;

SELECT * FROM produtos
WHERE nome LIKE '%Notebook%';

CREATE TABLE categorias (
    nome_categoria VARCHAR(100),
    descricao_categoria TEXT
);

CREATE TABLE fornecedores (
    nome_fornecedor VARCHAR(100),
    contato VARCHAR(100),
    cidade VARCHAR(100)
);

SELECT * FROM produtos
ORDER BY preco DESC;

INSERT INTO categorias (nome_categoria, descricao_categoria) VALUES
('Informática', 'Produtos relacionados a tecnologia'),
('Acessórios', 'Itens complementares para eletrônicos');

INSERT INTO fornecedores (nome_fornecedor, contato, cidade) VALUES
('Tech Distribuidora', 'tech@distribuidora.com', 'São Paulo'),
('Logitech BR', 'contato@logitech.com', 'Curitiba'),
('GigaTech', 'vendas@gigatech.com', 'Rio de Janeiro'),
('InfoWorld', 'suporte@infoworld.com', 'Belo Horizonte'),
('SuperTI', 'contato@superti.com', 'Porto Alegre'),
('MegaComp', 'vendas@megacomp.com', 'Salvador'),
('PC Center', 'contato@pccenter.com', 'Rio de Janeiro');

SELECT DISTINCT cidade FROM fornecedores;

create database livraria;
use livraria;

create table autores (
	id int primary key auto_increment,
	nome varchar(200)
);

create table generos (
	id int primary key auto_increment,
	nome varchar(200)
);

create table livros (
	id int primary key auto_increment,
	nome varchar(200),
    idioma varchar(100),
    ano_publicacao int,
    vendas decimal(10,2),
    autor_id int,
    genero_id int,
    foreign key (autor_id) references autores(id),
    foreign key (genero_id) references generos(id)
);

create table comentarios (
    id int primary key auto_increment,
    livro_id int,
    nome varchar(100),
    sobrenome varchar(100),
    comentario text,
    foreign key (livro_id) references livros(id)
);

select * from autores;
select * from generos;
select * from livros order by id;
select * from comentarios;
SELECT * FROM comentarios LIMIT 5000;

drop table comentarios;

-- buscar todos os livros publicados após o ano 2010 
select nome from livros
where ano_publicacao > 2010;

-- listar livros com vendas acima de 100
select nome, vendas
from livros
where vendas > 100; 

-- listar livros com nome do autor
select l.nome as livro, a.nome as autor
from livros l
join autores a on l.autor_id = a.id;

-- contar quantos livros cada autor publicou 
select autor_id, count(*) as total_livros
from livros
group by autor_id;

-- listar livro, autor e gênero
select l.nome as livro, a.nome as autor, g.nome as genero
from livros l
join autores a on l.autor_id = a.id
join generos g on l.genero_id = g.id;

-- livros cujo gênero seja exatamente 'desconhecido'
select l.*
from livros l
join generos g on l.genero_id = g.id
where g.nome = 'desconhecido';

-- resumo estatístico
select
  min(vendas) as min_vendas,
  max(vendas) as max_vendas,
  avg(vendas) as media_vendas
from livros
where vendas is not null;

-- vendas por autor
select 
    a.nome as autor, 
    sum(l.vendas) as total_vendas, 
    count(l.id) as livros_publicados
from livros l
join autores a on l.autor_id = a.id
group by a.nome
order by total_vendas desc;

-- Listar top 5 gêneros com maior faturamento total
select 
    g.nome as genero,
    sum(l.vendas) as faturamento_total
from livros l
join generos g on l.genero_id = g.id
group by g.nome
order by faturamento_total desc
limit 5;

-- total de vendas por autor e por gênero
select 
  a.nome as autor,
  g.nome as genero,
  count(l.id) as total_livros,
  sum(l.vendas) as total_vendas,
  avg(l.vendas) as media_vendas
from livros l
join autores a on l.autor_id = a.id
join generos g on l.genero_id = g.id
where l.vendas is not null
group by a.nome, g.nome
order by total_vendas desc;

use livraria;

select 
    idioma,
    count(*) as quantidade_livros
from livros
group by idioma;

-- view
-- lista a quantidade de livros por idioma.
create view livros_por_idioma as
select 
    idioma,
    count(*) as quantidade_livros
from livros
group by idioma;

select * from livros;

select * from livros
where idioma = 'Portuguese';

-- visualização dos livros com seus respectivos autores e gêneros
create view livros_detalhados as
select 
    l.id as livro_id,
    l.nome as nome_livro,
    l.idioma,
    l.ano_publicacao,
    l.vendas,
    a.nome as nome_autor,
    g.nome as nome_genero
from livros l
join autores a on l.autor_id = a.id
join generos g on l.genero_id = g.id;

select * from livros_detalhados;

-- quantos comentários cada livro recebeu.
create view comentarios_por_livro as
select 
    l.nome as nome_livro,
    count(c.id) as quantidade_comentarios
from livros l
left join comentarios c on l.id = c.livro_id
group by l.id, l.nome;

select * from comentarios_por_livro;

-- ordenado pela quantidade
select * from comentarios_por_livro
order by quantidade_comentarios desc;




create view todos_comentarios as 
select * from comentarios;

select * from todos_comentarios;

create view livros_ingles as
select * from livros
where idioma = 'English';

select * from livros_ingles;

create view livro_autor as
select l.nome as livro, a.nome as autor
from livros l
join autores a on autor_id = a.id;

select * from livro_autor;

-- drop view livro_autor;

-- atualizar as vendas de um livro
select id, nome, vendas from livros where id = 42;


-- Procedures
delimiter //

create procedure atualizar_vendas_livro(
    in p_livro_id int,
    in p_nova_venda decimal(10,2)
)
begin
    update livros
    set vendas = p_nova_venda
    where id = p_livro_id;
end;
//

delimiter ;

call atualizar_vendas_livro(42, 39.01);

delimiter //

create procedure inserir_comentario_livro(
    in p_livro_id int,
    in p_nome varchar(100),
    in p_sobrenome varchar(100),
    in p_comentario text
)
begin
    insert into comentarios (livro_id, nome, sobrenome, comentario)
    values (p_livro_id, p_nome, p_sobrenome, p_comentario);
end;
//

delimiter ;

call inserir_comentario_livro(42, 'julio', 'alcantara', 'ótimo livro, recomendo!');

select * from comentarios order by id desc;