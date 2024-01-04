--RD 30 dias - query feita pelo davi para analisar
select date(o.transacted_at) as transacted_at, o.seller_name, o.document, o.total, o.total_bonus,
	(select count(sa.id) from todos_data_lake_trusted_feegow.agendamentos sa 
	left join todos_data_lake_trusted_feegow.pacientes sp2 on sa.paciente_id = sp2.id 
	left join todos_data_lake_trusted_feegow.procedimentos sp on sa.procedimento_id = sp.id 
	where sa.status_id = 3 and sp.tipo_procedimento_id in (2, 9)
		and sp2.cpf = o.document and date(o.transacted_at) >= sa."data" and date(o.transacted_at) <= date_add('day', 10, sa."data")
	) as atendimentos,
	(select count(sp2.id) from todos_data_lake_trusted_feegow.pacientes sp2 where sp2.cpf = o.document) as pacienteAS
from todos_data_lake_trusted_ganhatodos_prod.raiadrogasil_order o
where o.transacted_at >= (current_date - interval '180' day)


--Tem compra na RD sem prescrição
--Não está nas tabelas "paciente_prescricoes"
--Teve atendimento na AmorSaúde nos últimos 10 dias?

select date(o.transacted_at) as transacted_at, o.seller_name, o.document, o.total, o.total_bonus,
	(select count(sa.id) from todos_data_lake_trusted_feegow.agendamentos sa
	left join todos_data_lake_trusted_feegow.pacientes sp2 on sa.paciente_id = sp2.id
	left join todos_data_lake_trusted_feegow.procedimentos sp on sa.procedimento_id = sp.id
	where sa.status_id = 3 and sp.tipo_procedimento_id in (2, 9)
		and sp2.cpf = o.document and date(o.transacted_at) >= sa."data" and date(o.transacted_at) <= date_add('day', 10, sa."data")
	) as atendimentos,
	(select count(sp2.id) from todos_data_lake_trusted_feegow.pacientes sp2 where sp2.cpf = o.document) as pacienteAS
from todos_data_lake_trusted_ganhatodos_prod.raiadrogasil_order o
where o.transacted_at >= (current_date - interval '10' day)

select * from todos_data_lake_trusted_feegow.agendamentos
limit 10

