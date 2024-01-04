with memed as (
select distinct id, pacienteid, date(datahora) as data 
from todos_data_lake_trusted_feegow.memed_prescricoes smp
where smp."data" >= date_add('day', -31, current_date)
),raiadrogasil as (
select distinct date(o.transacted_at) as transacted_at, o.seller_name, o.document, o.total, o.total_bonus from todos_data_lake_trusted_ganhatodos_prod.raiadrogasil_order o
where o.transacted_at >= date_add('day', -31, current_date)
)
select distinct ag."data" as data_do_atendimento, es.nome_especialidade, prof.nome_profissional, pcts.cpf as cpf_paciente_as, s.nomesexo, u.nome_fantasia, u.cidade, ur.descricao as regional, pcts.nascimento, count(distinct ag.id) as QTD_atendimento, count(distinct pp.id) as QTD_Prescricoes, count(distinct smp.id) as QTD_Prescricoes_Memed, 
	(select sum(o.total) from todos_data_lake_trusted_ganhatodos_prod.raiadrogasil_order o 
	 where pcts.cpf = o.document and date(o.transacted_at) >= ag."data" and date(o.transacted_at) <= date_add('day', 10, ag."data")) as Valor_RD,
	 (select sum(o.total_bonus) from todos_data_lake_trusted_ganhatodos_prod.raiadrogasil_order o
	 where o.document = pcts.cpf and date(o.transacted_at) >= ag."data" and date(o.transacted_at) <= date_add('day', 10, ag."data")) as Cashback
from todos_data_lake_trusted_feegow.atendimentos att
left join todos_data_lake_trusted_feegow.pacientes_prescricoes pp on pp.atendimento_id = att.id
left join todos_data_lake_trusted_feegow.agendamentos ag on att.agendamento_id = ag.id
left join todos_data_lake_trusted_feegow.profissionais prof on ag.profissional_id = prof.id
left join todos_data_lake_trusted_feegow.especialidades es on ag.especialidade_id = es.id
left join todos_data_lake_trusted_feegow.pacientes pcts on ag.paciente_id = pcts.id
left join todos_data_lake_trusted_feegow.procedimentos pro on ag.procedimento_id = pro.id
left join todos_data_lake_trusted_feegow.locais l on ag.local_id = l.id
left join todos_data_lake_trusted_feegow.unidades u on l.unidade_id = u.id
left join todos_data_lake_trusted_feegow.unidades_regioes ur on u.regiao_id = ur.id
left join memed smp on smp.pacienteid = pcts.id and smp.data = ag."data"
left join todos_data_lake_trusted_feegow.sexo s on pcts.sexo = s.id
where ag."data" >= date_add('day', -31, current_date) and ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3) 
and pro.tipo_procedimento_id in (2, 9)
group by ag."data", es.nome_especialidade, prof.nome_profissional, pcts.cpf, s.nomesexo, u.nome_fantasia, u.cidade, ur.descricao, pcts.nascimento
