--query atualizada Relatórios de Contas a Receber
select distinct
	cr.datapagamento,
	cr.id_unidade,
	cr.categoria,
	cr.grupoprocedimento,
	cr.nomeprocedimento,
	cr.data_execucao,
	cr.id_paciente,
	cr.nome_funcionario,
	cr.id_tabela,
	cr.situacaoconta,
	count(cr.nomeprocedimento) as quantidade,
	sum(cr.valorpago) as valor
from tb_consolidacao_contas_a_receber_hist cr
left join stg_tabelas_particulares stp on stp.id = cr.id_tabela 
where cr.grupoprocedimento in ('Exames Laboratoriais', 'Procedimentos', 'Exame', 'Exames de Imagem', 'Mapa', 'Holter', 'Ressonância', 'Sessão')
and cr.datapagamento between '2021-01-01' and '2023-12-31'
and cr.nome_fantasia = 'AmorSaúde Ribeirão Preto'
and cr.datapagamento between '2023-02-01' and '2023-02-28'
group by cr.datapagamento, cr.id_unidade,cr.categoria, cr.grupoprocedimento,cr.nomeprocedimento,cr.data_execucao, cr.id_paciente,cr.nome_funcionario,cr.id_tabela,cr.situacaoconta


--query enviada pela feegow para testar
with teste as (
select
  m.data DataPagamento,
  m.data DataVencimento,
  pacconta.CPF CPFPaciente,
  i.recurrence, 
  pacconta.id id_paciente,
  pacconta.nome_paciente,
  unit.nome_fantasia   nome_unidade,
  unit.id as id_unidade,
  ur.descricao as regional, 
  i.credito_debito,
  tp.id as id_tabela,
  tp.nome_tabela_particular,
  proc.nome_procedimento,
  proc.id,
  (select ci.quantidade from stg_conta_itens ci where ci.conta_id = m.conta_id limit 1) as quantidade ,
  (coalesce(idesc.Valor, 0) / COALESCE(i.Recurrence, 1)) valorPago,  
  m.descricao as descricaomovimentacao,
  (CASE
WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) <= 0 then 'Quitado' 
WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) > 0 and coalesce(m.valor_pago, 0) > 0 then 'Parcialmente pago' 
ELSE 'Em aberto'
END)
 SituacaoConta,
(case when m.forma_pagamento_id IN (8,10) then ct.Parcelas else 1 end) as Parcelas,
cat.name as categoria,
subcat.name as subcategoria
FROM stg_movimentacao m
LEFT JOIN stg_transacao_cartao ct ON ct.movimentacao_id = m.id
INNER JOIN stg_contas i on i.id = m.conta_id
INNER JOIN stg_conta_itens ii ON ii.conta_id = i.id
LEFT JOIN stg_pacotes pii     ON pii.id = ii.pacote_id 
LEFT JOIN stg_pagamento_associacao fdpay ON fdpay.parcela_id = m.id 
LEFT JOIN stg_movimentacao movpay ON movpay.id = fdpay.pagamento_id
LEFT JOIN stg_pagamento_item_associacao idesc ON idesc.item_id = ii.id AND idesc.pagamento_id = movpay.id 
LEFT JOIN stg_pacientes pacconta ON pacconta.id = i.conta_id AND i.associacao_conta_id = 3 
LEFT JOIN stg_planodecontas_receitas subcat ON subcat.id = ii.categoria_id
LEFT JOIN stg_planodecontas_receitas cat ON cat.id = subcat.Category
LEFT JOIN stg_procedimentos proc ON proc.id = ii.procedimento_id AND ii.tipo_item_id = 'S'
LEFT JOIN stg_produtos prod ON prod.id = ii.procedimento_id AND ii.tipo_item_id = 'M'
LEFT JOIN stg_procedimentos_grupos procgrup ON procgrup.id = proc.grupo_procedimento_id AND procgrup.sysActive = 1
LEFT JOIN stg_unidades  unit ON  unit.id = i.unidade_id 
left join stg_unidades_regioes ur on ur.id = unit.regiao_id 
LEFT JOIN stg_pacientes pag3 ON i.associacao_conta_id = 3 AND i.conta_id = pag3.id
LEFT JOIN stg_fornecedores pag2 ON i.associacao_conta_id = 2 AND i.conta_id = pag2.id
LEFT JOIN stg_convenios pag6 ON i.associacao_conta_id = 6 AND i.conta_id = pag6.id
left join stg_formas_pagamento fp on fp.id = movpay.forma_pagamento_id
left join stg_pagamento_item_associacao pia on pia.pagamento_id = movpay.id
left join stg_transacao_cartao tc on tc.movimentacao_id = movpay.id
left join stg_tabelas_particulares tp on tp.id = i.tabela_particular_id
LEFT JOIN stg_bandeiras_cartao bc ON bc.id = ct.bandeira_cartao_id
left join stg_usuarios users on movpay.sys_user = users.id
left join stg_funcionarios func on users.id_relativo = func.id
where 
m.credito_debito = 'C' 
and m.tipo_movimentacao = 'Bill'
--and proc.tipo_procedimento_id in (3, 4) --opcional--
and i.sys_active = 1
--and i.unidade_id = 19345 --opcional--
and ((ii.is_cancelado <> '1' and ii.tipo_item_id = 'S') or (ii.tipo_item_id <> 'S'))
and ( case when 'N' = 'S' then ii.pacote_id is not null else true end) --[Apenas_Pacotes] Opcional
and m.data between '2023-01-01' and '2023-01-31'
and (
   (CASE
WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) <= 0 then 'quitado' 
WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) > 0 and coalesce(m.valor_pago, 0) > 0 then 'parcial'
when m.valor > 0 and m.valor_pago is null then 'em aberto'
END) in ('quitado', 'parcial')) 
GROUP by 
idesc.id, id_unidade,
  unit.nome_fantasia, m.data, m.forma_pagamento_id, pacconta.cpf, ct.parcelas, ur.descricao, i.credito_debito, tp.id, 	
	tp.nome_tabela_particular, m.descricao, cat.name, subcat.name, pacconta.nome_paciente, m.conta_id, m.data_hora,
	ii.Quantidade, ii.Valor_Unitario, ii.Acrescimo, ii.Desconto, i.id, pacconta.id, i.recurrence, proc.nome_procedimento, proc.id, m.valor, m.valor_pago, idesc.valor, i.valor
	order by  m.data, m.data_hora 
) 
	select nome_unidade, id_unidade, DataVencimento, nome_procedimento, CPFPaciente, nome_paciente,
	replace(replace(replace(round(sum(valorpago), 2),',','-' ),'.',','),'-','.') as valor
	from teste
	where nome_unidade = 'AmorSaúde Batatais'
	group by nome_unidade, id_unidade, DataVencimento, nome_procedimento, CPFPaciente, nome_paciente
	
		 
	 
-------------------------
select count(*)
from 
	stg_movimentacao m 
	INNER JOIN stg_contas i on i.id = m.conta_id
	inner join stg_pagamento_associacao disc on m.id = disc.pagamento_id 
where 
	m.credito_debito = 'C' 
	and tipo_movimentacao = 'Bill'
	
---------------------------
	select * from tb_consolidacao_contas_a_receber tccar
	where tccar.cpfpaciente = '31771183888'
	and tccar ."data" = '2023-02-03'
	
	----------------------------------------------
	with teste as (
select
  m.data DataPagamento,
  pacconta.CPF CPFPaciente,
  i.recurrence, 
  pacconta.id id_paciente,
  pacconta.nome_paciente,
  unit.nome_fantasia   nome_unidade,
  unit.id as id_unidade,
  ur.descricao as regional, 
  i.credito_debito,
  tp.id as id_tabela,
  tp.nome_tabela_particular,
  proc.nome_procedimento,
  proc.id,
  (select ci.quantidade from stg_conta_itens ci where ci.conta_id = m.conta_id limit 1) as quantidade ,
  (coalesce(idesc.Valor, 0) / COALESCE(i.Recurrence, 1)) valorPago,  
  m.descricao as descricaomovimentacao,
  (CASE
WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) <= 0 then 'Quitado' 
WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) > 0 and coalesce(m.valor_pago, 0) > 0 then 'Parcialmente pago' 
ELSE 'Em aberto'
END)
 SituacaoConta,
(case when m.forma_pagamento_id IN (8,10) then ct.Parcelas else 1 end) as Parcelas,
cat.name as categoria,
subcat.name as subcategoria
FROM stg_movimentacao m
LEFT JOIN stg_transacao_cartao ct ON ct.movimentacao_id = m.id
INNER JOIN stg_contas i on i.id = m.conta_id
INNER JOIN stg_conta_itens ii ON ii.conta_id = i.id
LEFT JOIN stg_pacotes pii     ON pii.id = ii.pacote_id 
LEFT JOIN stg_pagamento_associacao fdpay ON fdpay.parcela_id = m.id 
LEFT JOIN stg_movimentacao movpay ON movpay.id = fdpay.pagamento_id
LEFT JOIN stg_pagamento_item_associacao idesc ON idesc.item_id = ii.id AND idesc.pagamento_id = movpay.id 
LEFT JOIN stg_pacientes pacconta ON pacconta.id = i.conta_id AND i.associacao_conta_id = 3 
LEFT JOIN stg_planodecontas_receitas subcat ON subcat.id = ii.categoria_id
LEFT JOIN stg_planodecontas_receitas cat ON cat.id = subcat.Category
LEFT JOIN stg_procedimentos proc ON proc.id = ii.procedimento_id AND ii.tipo_item_id = 'S'
LEFT JOIN stg_produtos prod ON prod.id = ii.procedimento_id AND ii.tipo_item_id = 'M'
LEFT JOIN stg_procedimentos_grupos procgrup ON procgrup.id = proc.grupo_procedimento_id AND procgrup.sysActive = 1
LEFT JOIN stg_unidades  unit ON  unit.id = i.unidade_id 
left join stg_unidades_regioes ur on ur.id = unit.regiao_id 
LEFT JOIN stg_pacientes pag3 ON i.associacao_conta_id = 3 AND i.conta_id = pag3.id
LEFT JOIN stg_fornecedores pag2 ON i.associacao_conta_id = 2 AND i.conta_id = pag2.id
LEFT JOIN stg_convenios pag6 ON i.associacao_conta_id = 6 AND i.conta_id = pag6.id
left join stg_formas_pagamento fp on fp.id = movpay.forma_pagamento_id
left join stg_pagamento_item_associacao pia on pia.pagamento_id = movpay.id
left join stg_transacao_cartao tc on tc.movimentacao_id = movpay.id
left join stg_tabelas_particulares tp on tp.id = i.tabela_particular_id
LEFT JOIN stg_bandeiras_cartao bc ON bc.id = ct.bandeira_cartao_id
left join stg_usuarios users on movpay.sys_user = users.id
left join stg_funcionarios func on users.id_relativo = func.id
where 
m.credito_debito = 'C' 
and m.tipo_movimentacao = 'Bill'
--and proc.tipo_procedimento_id in (3, 4) --opcional--
and i.sys_active = 1
--and i.unidade_id = 19345 --opcional--
and ((ii.is_cancelado <> '1' and ii.tipo_item_id = 'S') or (ii.tipo_item_id <> 'S'))
and ( case when 'N' = 'S' then ii.pacote_id is not null else true end) --[Apenas_Pacotes] Opcional
and m.data between '2023-01-01' and '2023-01-10'
and (
   (CASE
WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) <= 0 then 'quitado' 
WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) > 0 and coalesce(m.valor_pago, 0) > 0 then 'parcial'
when m.valor > 0 and m.valor_pago is null then 'em aberto'
END) in ('quitado', 'parcial')) 
GROUP by 
idesc.id, id_unidade,
  unit.nome_fantasia, m.data, m.forma_pagamento_id, pacconta.cpf, ct.parcelas, ur.descricao, i.credito_debito, tp.id, 	
	tp.nome_tabela_particular, m.descricao, cat.name, subcat.name, pacconta.nome_paciente, m.conta_id, m.data_hora,
	ii.Quantidade, ii.Valor_Unitario, ii.Acrescimo, ii.Desconto, i.id, pacconta.id, i.recurrence, proc.nome_procedimento, proc.id, m.valor, m.valor_pago, idesc.valor, i.valor
	order by  m.data, m.data_hora 
) 
	select 	replace(replace(replace(round(sum(valorpago), 2),',','-' ),'.',','),'-','.') as valor
	from teste
	where nome_unidade = 'AmorSaúde Batatais'

