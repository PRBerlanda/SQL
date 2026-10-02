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
