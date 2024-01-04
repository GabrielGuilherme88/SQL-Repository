--agendamentos ok
select count(*)
from stg_agendamentos ag
left join stg_locais sl on sl.id = ag.local_id
left join stg_unidades su on su.id = sl.unidade_id
where ag."data" between '2022-07-01' and current_date 


--movimentacao ok
select count(*)	from stg_movimentacao m
where m."data" between '2022-07-01' and current_date 

--contas ok
select count(*)
	from stg_contas c
	where c.data_referencia between '2022-07-01' and current_date


--proposta ok
select count(*)
from stg_propostas p
where p.dataproposta  between '2022-07-01' and current_date


--pdf_assinado ok
select count(*) 
from stg_dc_pdf_assinados pa
where pa.data_criacao between '2022-07-01' and current_date


--pedidos ok
select count(*)
from stg_pacientes_pedidos pd
where pd."data"  between '2022-07-01' and current_date


--prescricpes ok
select count(*) 
from stg_pacientes_prescricoes pp
where pp."data"  between '2022-07-01' and current_date

--bloqueios 
select count(*)
from stg_contas_bloqueios cb
where cb."data"  between '2022-07-01' and current_date


--atendimentos
select count(*)
from stg_atendimentos a
where a."data"  between '2022-07-01' and current_date



--procedimento
select count(*)
from stg_procedimentos sp

--conta itens
select count(*)
from stg_conta_itens sci
where sci.data_execucao  between '2022-07-01' and current_date

--splits
select count(*)
from stg_splits s
where s."data"  between '2022-07-01' and current_date

--royalite
select count(*)
from stg_royalties_contas rc
where rc.datareferencia  between '2022-07-01' and current_date








