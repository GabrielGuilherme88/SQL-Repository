select spd.category, spd."name", su.nome_fantasia,  count(sc.id), sum(sc.valor)
from stg_planodecontas_despesas spd 
left join stg_conta_item_tipos scit on scit.id = spd.id
left join stg_conta_itens sci on sci.conta_id  = scit.id
left join stg_contas sc on sc.conta_id = sci.conta_id 
left join stg_unidades su on su.id = sc.unidade_id 
where spd."name" like 'Acordos/Sentenças%'
or spd."name" like 'Custas%'
group by spd.category, spd."name", su.nome_fantasia

--query para buscar valores a pagr em processos judiciais para a apresentação
select tccaph .categoria , tccaph .subcategoria , tccaph .nome_fantasia, 
	tccaph.descricao, tccaph.datapagamento, count(*), sum(tccaph.valorpago)
from tb_consolidacao_contas_a_pagar_hist tccaph 
	where tccaph.subcategoria like 'Acordos/Sentenças Judiciais%'
	or tccaph.subcategoria like 'Custas%'
	group by tccaph .categoria , tccaph .subcategoria, tccaph .nome_fantasia, 
	tccaph.descricao, tccaph.datapagamento

select tccaph .nome_fantasia, count(*), sum(tccaph.valorpago)
	from tb_consolidacao_contas_a_pagar_hist tccaph 
	where tccaph.subcategoria like 'Acordos/Sentenças Judiciais%'
	or tccaph.subcategoria like 'Custas%'
	group by  tccaph .nome_fantasia
	
--veriicar a quantidade de registros acima do normal
select tccaph.nome_fantasia  ,count(*) from tb_consolidacao_contas_a_pagar_hist tccaph
where tccaph .datapagamento between '2023-05-02' and '2023-05-05'
group by tccaph.nome_fantasia

select *
from tb_consolidacao_contas_a_pagar_hist tccaph 
where tccaph.datapagamento between '2023-08-01' and '2023-08-15'
--group by tccaph.datapagamento


  select       
*
		from 
	(
	select
	m.id as idm,
	ur.descricao as regional,
	u.id,
	u.nome_fantasia,
	i.credito_debito, 
	ii.desconto Desconto,
	ii.desconto ValorUnitario,
	ii.desconto Acrescimo,
	(COALESCE((m.valor/nullif(i.valor , 0)), 1) * ( ii.Quantidade * 
	(ii.valor_unitario + 
	ii.acrescimo - ii.desconto))) * COALESCE(COALESCE(invrat.porcentagem/100,1), 
	1) ValorTotal,
	(case when current_date > m.data then (m.valor - COALESCE(m.valor_pago, 0)) 
	else 0 end) * COALESCE(COALESCE(invrat.porcentagem/100,1), 1) ValorVencido,
	(( ii.Quantidade * (ii.valor_unitario + ii.acrescimo - ii.desconto) ) - ( 
	SUM(COALESCE(idesc.valor, 0)) ) ) * 
	COALESCE(COALESCE(invrat.porcentagem/100,1), 1) ValorAPagar,
	(CASE
	WHEN m.valor - (COALESCE(m.valor_pago, 0) + 0.3) <= 0 then 'Quitado'
	WHEN m.valor - (COALESCE(m.valor_pago, 0) + 0.3) > 0 and
	COALESCE(m.valor_pago, 0) > 0 then 'Parcialmente pago'
	ELSE 'Em aberto'
	END) SituacaoConta,
	m.descricao,
	m.data, 
	( SUM(COALESCE(idesc.valor, 0)) ) * (COALESCE((invrat.porcentagem/100),1) 
	) ValorPago,
	(case when cat.id is null then null else subcat.Name end) Subcategoria,
	COALESCE(cat.Name, subcat.Name) Categoria,
	(select COUNT(id)
	from stg_movimentacao
	where conta_id = i.id) Parcelas,
	CONCAT((select COUNT(id)
	from stg_movimentacao
	where conta_id = i.id and Data <= m.data), CONCAT( '/', (select COUNT(id)
	from stg_movimentacao
	where conta_id = i.id))) Parcela,
	(select mp.data
	from stg_pagamento_associacao disc 
	INNER JOIN stg_movimentacao mp ON mp.id = disc.pagamento_id
	where disc.parcela_id = m.id
	LIMIT 1) DataPagamento
	FROM stg_movimentacao m
	INNER join stg_contas i on i.id = m.conta_id
	left join stg_unidades u on i.unidade_id = u.id
	left join stg_unidades_regioes ur on u.regiao_id = ur.id
	INNER JOIN stg_conta_associacoes ass ON ass.id = i.associacao_conta_id
	INNER JOIN stg_conta_itens ii ON ii.conta_id = i.id
	LEFT JOIN stg_produtos prod ON prod.id=ii.procedimento_id AND
	Tipo_movimentacao='M'
	LEFT JOIN stg_planodecontas_despesas subcat ON subcat.id = ii.categoria_id
	LEFT JOIN stg_invoice_rateio invrat ON invrat.conta_id = i.id
	LEFT JOIN stg_pagamento_associacao dp ON dp.parcela_id = m.id
	LEFT JOIN stg_pagamento_item_associacao idesc ON idesc.item_id = ii.id AND
	idesc.pagamento_id = dp.pagamento_id
	LEFT JOIN stg_movimentacao movpay ON movpay.id = idesc.pagamento_id
	LEFT JOIN stg_planodecontas_despesas cat ON cat.id = subcat.Category
	WHERE m.tipo_movimentacao = 'Bill' AND m.credito_debito = 'D' 
	AND
	(select mp."data"
	from stg_pagamento_associacao disc 
	INNER JOIN stg_movimentacao mp ON mp.id = disc.pagamento_id
	where disc.parcela_id = m.id
	LIMIT 1)
	BETWEEN date('2021-01-01') AND date('2030-12-31') AND i.sys_active = 1
	AND (i.associacao_conta_id IN (2,3,4,5,6,8) )
	AND (
	(CASE
	WHEN m.valor - (COALESCE(m.valor_pago, 0) + 0.3) <= 0 then 'quitado'
	WHEN m.valor - (COALESCE(m.valor_pago, 0) + 0.3) > 0 and
	COALESCE(m.valor_pago, 0) > 0 then 'parcial'
	ELSE 'aberto'
	END) IN ('parcial' , 'quitado') )
	GROUP BY ur.descricao, u.id, u.nome_fantasia, i.id, m.id, m.descricao, 
	m.data_hora, i.credito_debito, m.valor, i.valor, ii.desconto, ii.quantidade, 
	ii.valor_unitario, ii.acrescimo, invrat.porcentagem, ii.desconto, 
	m.valor_pago, idesc.valor, i.conta_id, m.data, cat.id, subcat.name,
	subcat.name, cat.name, ass.tabela_associacao
	order by m.data, m.data_hora)
	where datapagamento between '2023-08-01' and '2023-08-15'
	--group by idm
	
	
	--query para verificar a duplicidade (enviada pelo NGD)
	select tccaph.nome_fantasia, tccaph.datapagamento, tccaph.valortotal, tccaph.valorpago  
	from tb_consolidacao_contas_a_pagar_hist tccaph 
	where tccaph.datapagamento between '2023-07-01' and '2023-07-30'
	and tccaph.nome_fantasia = 'AmorSaúde Carapicuíba'
	
	--query para verificarf duplicidade agrupada 
	select tccaph.nome_fantasia, tccaph.datapagamento, sum(tccaph.valortotal), sum(tccaph.valorpago)  
	from tb_consolidacao_contas_a_pagar_hist tccaph 
	where tccaph.datapagamento between '2023-07-01' and '2023-07-30'
	and tccaph.nome_fantasia = 'AmorSaúde Carapicuíba'
	group by tccaph.nome_fantasia, tccaph.datapagamento
	
	
	

	
--total agregado
with teste as (
select * from tb_consolidacao_contas_a_pagar_hist tccaph
where tccaph.nome_fantasia like 'AmorSaúde Patos de Minas%'
and tccaph.categoria = 'Sócios'
and tccaph.data between '2023-01-01' and '2023-10-31'
)
select sum(valortotal)
from teste


--aberto granularidade
with teste as (
select * from tb_consolidacao_contas_a_pagar_hist tccaph
where tccaph.nome_fantasia like 'AmorSaúde Patos de Minas%'
and tccaph.categoria = 'Sócios'
and tccaph.data between '2023-01-01' and '2023-10-31'
)
select *
from teste


with teste as (
select * from tb_consolidacao_contas_a_pagar_hist tccaph
where tccaph.nome_fantasia like 'AmorSaúde Patos de Minas%'
and tccaph.categoria = 'Sócios'
and tccaph.subcategoria = 'Aporte'
and tccaph.data between '2023-01-01' and '2023-10-31'
)
select sum(valortotal)
from teste



with teste as (
--DDL 
select   
    regional,
	id,
	nome_fantasia,
	credito_debito, 
	Desconto,
	ValorUnitario,
	Acrescimo,
	ValorTotal,
	ValorVencido, 
	ValorAPagar,
	SituacaoConta,
	descricao,
	"data",
	ValorPago,
	Subcategoria, 
	Categoria,
	nome_funcionario, --add
	Parcelas,
	Parcela,
	DataPagamento,
	asconta_intens_descri,
	observacao
	from 	
(
	select
	ur.descricao as regional,
	u.id,
	u.nome_fantasia,
	i.credito_debito, 
	ii.desconto Desconto,
	ii.desconto ValorUnitario,
	ii.desconto Acrescimo,
	(COALESCE((m.valor/nullif(i.valor , 0)), 1) * ( ii.Quantidade * 
	(ii.valor_unitario + 
	ii.acrescimo - ii.desconto))) * COALESCE(COALESCE(invrat.porcentagem/100,1), 
	1) ValorTotal,
	(case when current_date > m.data then (m.valor - COALESCE(m.valor_pago, 0)) 
	else 0 end) * COALESCE(COALESCE(invrat.porcentagem/100,1), 1) ValorVencido,
	(( ii.Quantidade * (ii.valor_unitario + ii.acrescimo - ii.desconto) ) - ( 
	SUM(COALESCE(idesc.valor, 0)) ) ) * 
	COALESCE(COALESCE(invrat.porcentagem/100,1), 1) ValorAPagar,
	(CASE
	WHEN m.valor - (COALESCE(m.valor_pago, 0) + 0.3) <= 0 then 'Quitado'
	WHEN m.valor - (COALESCE(m.valor_pago, 0) + 0.3) > 0 and
	COALESCE(m.valor_pago, 0) > 0 then 'Parcialmente pago'
	ELSE 'Em aberto'
	END) SituacaoConta,
	m.descricao,
	ii.descricao asconta_intens_descri, --add
	scit.descricao as observacao,--add
	m.data, 
	( SUM(COALESCE(idesc.valor, 0)) ) * (COALESCE((invrat.porcentagem/100),1) 
	) ValorPago,
	(case when cat.id is null then null else subcat.Name end) Subcategoria,
	COALESCE(cat.Name, subcat.Name) Categoria,
	sf.nome_funcionario, --add 
	(select COUNT(id)
	from stg_movimentacao
	where conta_id = i.id) Parcelas,
	CONCAT((select COUNT(id)
	from stg_movimentacao
	where conta_id = i.id and Data <= m.data), CONCAT( '/', (select COUNT(id)
	from stg_movimentacao
	where conta_id = i.id))) Parcela,
	(select mp.data
	from stg_pagamento_associacao disc 
	INNER JOIN stg_movimentacao mp ON mp.id = disc.pagamento_id
	where disc.parcela_id = m.id
	LIMIT 1) DataPagamento
	FROM stg_movimentacao m
	INNER join stg_contas i on i.id = m.conta_id
	left join stg_unidades u on i.unidade_id = u.id
	left join stg_unidades_regioes ur on u.regiao_id = ur.id
	INNER JOIN stg_conta_associacoes ass ON ass.id = i.associacao_conta_id
	INNER JOIN stg_conta_itens ii ON ii.conta_id = i.id
	LEFT JOIN stg_produtos prod ON prod.id=ii.procedimento_id AND
	Tipo_movimentacao='M'
	LEFT JOIN stg_planodecontas_despesas subcat ON subcat.id = ii.categoria_id
	LEFT JOIN stg_invoice_rateio invrat ON invrat.conta_id = i.id
	LEFT JOIN stg_pagamento_associacao dp ON dp.parcela_id = m.id
	LEFT JOIN stg_pagamento_item_associacao idesc ON idesc.item_id = ii.id AND
	idesc.pagamento_id = dp.pagamento_id
	LEFT JOIN stg_movimentacao movpay ON movpay.id = idesc.pagamento_id
	LEFT JOIN stg_planodecontas_despesas cat ON cat.id = subcat.Category
	left join stg_usuarios su on su.id = m.sys_user --add
	left join stg_funcionarios sf on sf.id = su.id_relativo --add
	left join stg_conta_item_tipos scit on scit.id = ii.id --add
	WHERE m.tipo_movimentacao = 'Bill' AND m.credito_debito = 'D' 
	AND
	(select mp."data"
	from stg_pagamento_associacao disc 
	INNER JOIN stg_movimentacao mp ON mp.id = disc.pagamento_id
	where disc.parcela_id = m.id
	LIMIT 1)
	BETWEEN date('2021-01-01') AND date('2030-12-31') AND i.sys_active = 1
	AND (i.associacao_conta_id IN (2,3,4,5,6,8) )
	AND (
	(CASE
	WHEN m.valor - (COALESCE(m.valor_pago, 0) + 0.3) <= 0 then 'quitado'
	WHEN m.valor - (COALESCE(m.valor_pago, 0) + 0.3) > 0 and
	COALESCE(m.valor_pago, 0) > 0 then 'parcial'
	ELSE 'aberto'
	END) IN ('parcial' , 'quitado') )
	GROUP BY ur.descricao, u.id, u.nome_fantasia, i.id, m.id, m.descricao, 
	m.data_hora, i.credito_debito, m.valor, i.valor, ii.desconto, ii.quantidade, 
	ii.valor_unitario, ii.acrescimo, invrat.porcentagem, ii.desconto, ii.descricao, --add
	m.valor_pago, idesc.valor, i.conta_id, m.data, cat.id, subcat.name, nome_funcionario, scit.descricao, --add,
	subcat.name, cat.name, ass.tabela_associacao
	order by m.data, m.data_hora
	)
	where data between '2023-01-01' and current_date
	and nome_fantasia like 'AmorSaúde Patos de Minas%'
	and categoria = 'Sócios'
	and subcategoria = 'Aporte'
	)
	select *
	from teste

	
	SELECT sc.descricao , count(*) FROM stg_contas sc 
	group by sc.descricao
