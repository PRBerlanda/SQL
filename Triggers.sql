delimiter $$

create trigger AtualizarResumoAluguel
after insert on alugueis
for each row
begin
	declare desconto int;
    declare valorFinal decimal(10,2);
    set desconto = CalcularDescontoPorDias(new.aluguel_id);
    set valorFinal = CalcularValorComDesconto(new.cliente_id);
    
    insert into resumo_aluguel(
    aluguel_id,
	cliente_id,
	valortotal,
	descontoaplicado,
	valorfinal
    )
    values (
    new.aluguel_id,
    new.cliente_id,
    new.preco_total,
    desconto,
    valorFinal
    );
    
end $$

delimiter ;

INSERT INTO alugueis (aluguel_id, cliente_id, hospedagem_id, data_inicio, data_fim, preco_total)
VALUES (10080, 42, 15, '2024-01-01', '2024-01-08', 3000.00);

SELECT * FROM resumo_aluguel;

