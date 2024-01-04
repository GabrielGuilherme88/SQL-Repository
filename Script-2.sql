select round(sum(x.valorpago), 2) as valor_pago, x.nome_unidade from (
select
  m.data Data,
  m.data DataVencimento,
  listagg( distinct movpay.data , ', ') as "Data_Pagamento",
  pacconta.CPF CPFPaciente,
  i.recurrence, 
  pacconta.id id_paciente,
  pacconta.nome_paciente,
  unit.nome_fantasia   nome_unidade,
  ur.descricao as regional, 
  i.credito_debito,
  tp.id as id_tabela,
  tp.nome_tabela_particular,
  proc.nome_procedimento,
  proc.id,
  (select ci.quantidade from conta_itens ci where ci.conta_id = m.conta_id limit 1) as quantidade ,
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
FROM movimentacao m
LEFT JOIN transacao_cartao ct ON ct.movimentacao_id = m.id
INNER JOIN contas i on i.id = m.conta_id
INNER JOIN conta_itens ii ON ii.conta_id = i.id
LEFT JOIN pacotes pii     ON pii.id = ii.pacote_id --
LEFT JOIN pagamento_associacao fdpay ON fdpay.parcela_id = m.id 
LEFT JOIN movimentacao movpay ON movpay.id = fdpay.pagamento_id
LEFT JOIN pagamento_item_associacao idesc ON idesc.item_id = ii.id AND idesc.pagamento_id = movpay.id 
LEFT JOIN pacientes pacconta ON pacconta.id = i.conta_id AND i.associacao_conta_id = 3 
LEFT JOIN planodecontas_receitas subcat ON subcat.id = ii.categoria_id
LEFT JOIN planodecontas_receitas cat ON cat.id = subcat.Category
LEFT JOIN procedimentos proc ON proc.id = ii.procedimento_id AND ii.tipo_item_id = 'S'
LEFT JOIN produtos prod ON prod.id = ii.procedimento_id AND ii.tipo_item_id = 'M'
LEFT JOIN procedimentos_grupos procgrup ON procgrup.id = proc.grupo_procedimento_id AND procgrup.sysActive = 1
LEFT JOIN unidades  unit ON  unit.id = i.unidade_id 
left join unidades_regioes ur on ur.id = unit.regiao_id 
LEFT JOIN pacientes pag3 ON i.associacao_conta_id = 3 AND i.conta_id = pag3.id
LEFT JOIN fornecedores pag2 ON i.associacao_conta_id = 2 AND i.conta_id = pag2.id
LEFT JOIN convenios pag6 ON i.associacao_conta_id = 6 AND i.conta_id = pag6.id
left join formas_pagamento fp on fp.id = movpay.forma_pagamento_id
left join pagamento_item_associacao pia on pia.pagamento_id = movpay.id
left join transacao_cartao tc on tc.movimentacao_id = movpay.id
left join tabelas_particulares tp on tp.id = i.tabela_particular_id
LEFT JOIN bandeiras_cartao bc ON bc.id = ct.bandeira_cartao_id
left join usuarios users on movpay.sys_user = users.id
left join funcionarios func on users.id_relativo = func.id
where 
m.credito_debito = 'C' 
and m.tipo_movimentacao = 'Bill'
--and proc.tipo_procedimento_id in (3, 4) --opcional--
and i.sys_active = 1
--and i.unidade_id =  --opcional--
and ((ii.is_cancelado <> '1' and ii.tipo_item_id = 'S') or (ii.tipo_item_id <> 'S'))
and ( case when 'N' = 'S' then ii.pacote_id is not null else true end) --[Apenas_Pacotes] Opcional
--and 
--(case when 'Pagamento' = 'Vencimento' then m.data BETWEEN '2023-01-01' AND '2023-01-10'
--     when 'Pagamento' = 'Competencia' then i.data_referencia BETWEEN '2023-01-01' AND '2023-01-10'     
--	when 'Pagamento' = 'Pagamento' AND fdpay.id IS NOT NULL then (  m.Data BETWEEN '2023-01-01' AND '2023-01-10') end--inserir periodo desejado*/
--)
and (
   (CASE
WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) <= 0 then 'quitado' 
WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) > 0 and coalesce(m.valor_pago, 0) > 0 then 'parcial'
when m.valor > 0 and m.valor_pago is null then 'em aberto'
END) in ('quitado', 'parcial'))
GROUP by 
 concat(concat(cast(m.id as varchar), ', '), cast(ii.id as varchar)),
  unit.nome_fantasia, m.data, m.forma_pagamento_id, pacconta.cpf, ct.parcelas, ur.descricao, i.credito_debito, tp.id, 	
	tp.nome_tabela_particular, m.descricao, cat.name, subcat.name, pacconta.nome_paciente, m.conta_id, m.data_hora,	
	ii.Quantidade, ii.Valor_Unitario, ii.Acrescimo, ii.Desconto, i.id, pacconta.id, i.recurrence, proc.nome_procedimento, proc.id, m.valor, m.valor_pago, idesc.valor, i.valor
	order by  m.data, m.data_hora 
	) x   	
	group by x.nome_unidade;
	