--movimentação
select count(*) 
from stg_movimentacao sm
left join stg_unidades su on su.id = sm.unidade_id
left join stg_contas sc on sc.id = sm.conta_id
where sm."data" between '2023-05-01' and '2023-05-31'
and sm.unidade_id = 19301
and sm.tipo_movimentacao = 'Bill'
--and sm.credito_debito = 'C'

--CONTAS
select count(*) from stg_contas sc 
left join stg_conta_itens sci on sci.conta_id = sc.id
where sc.unidade_id = 19301
and sc.data_referencia between '2023-05-01' and '2023-05-31'

--contas a receber
select count(*), sum(cr.valor_pago) 
from tb_consolidacao_contas_a_receber_modelagem cr 
--where tccarh.procedimento like 'Consult%'
where cr .data_pagamento between '2023-05-01' and '2023-05-10'
and cr.nome_unidade = 'AmorSaúde Caxias do Sul'
and cr.nomegrupo not in ('Consultas')
--group by cr.nomegrupo
--order by cr.nomegrupo asc

select tccarh.data from tb_consolidacao_contas_a_receber_hist tccarh 
limit 10