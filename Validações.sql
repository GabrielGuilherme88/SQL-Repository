select valorpago ,id_unidade , nome_fantasia , grupoprocedimento , nomeprocedimento  from tb_consolidacao_contas_a_receber_hist tccarh 
where tccarh .nomeprocedimento in ('Hemoglobina Glicada',
'Vitamina B12',
'Ferro Serico',
'Acido Folico',
'Vitamina C',
'Citologia Oncótica Líquido e Secreções
')
and tccarh .grupoprocedimento is null
and tccarh .datapagamento between '2022-11-01' and '2022-11-30'

select sum(valorpago) from tb_consolidacao_contas_a_receber_hist tccarh 
where tccarh .nomeprocedimento in ('Hemoglobina Glicada',
'Vitamina B12',
'Ferro Serico',
'Acido Folico',
'Vitamina C',
'Citologia Oncótica Líquido e Secreções
')
and tccarh .grupoprocedimento is null
and tccarh .datapagamento between '2022-11-01' and '2022-11-30'

--V2
select 
	count(ip.id) as qtd_itens 
from stg_propostas_hist p
left join stg_itens_proposta_hist ip on ip.proposta_id = p.id
left join stg_unidades u on p.unidadeid = u.id
where p.dataproposta between '2022-11-01' and '2022-11-30'

select * from stg_itens_proposta_hist siph 
limit 5


--V1
select 
	count(ip.id) as qtd_itens
from stg_propostas_hist p
left join stg_itens_proposta_hist ip on ip.proposta_id = p.id
left join stg_unidades u on p.unidadeid = u.id
where p.dataproposta between '2022-11-01' and '2022-11-30'

--V2 Prontuario
with pront_assinado as (
select distinct sa.agendamento_id, 1 as assinado 
from stg_dc_pdf_assinados sdpa
left join stg_atendimentos_hist sa on sdpa.documento_id = sa.id 
where sdpa.tipo = 'ATENDIMENTO'
)
select ag."data" as data, U.id as id_unidade, prof.id as id_profissional, esp.id as id_especialidade, pac.cpf, count(agdts.agendamento_id) as atendimentos, sum(pront.assinado) as qtddocsassinados
from stg_agendamento_procedimentos agdts
      left join stg_locais L on agdts.local_id = L.id
      left join stg_unidades U on L.unidade_id = U.id
      left join stg_unidades_regioes ur on U.regiao_id = ur.id
      left join stg_procedimentos pro on agdts.procedimento_id = pro.id
      left join stg_agendamentos_hist ag on agdts.agendamento_id = ag.id
      left join stg_especialidades esp on ag.especialidade_id = esp.id
      left join stg_profissionais prof on ag.profissional_id = prof.id 
      left join stg_pacientes pac on ag.paciente_id = pac.id 
      left join pront_assinado pront on agdts.agendamento_id = pront.agendamento_id 
where ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
and pro.tipo_procedimento_id in (2, 9)
group by ag."data", U.id, prof.id, esp.id, pac.cpf

--V1
with pront_assinado as (
select distinct sa.agendamento_id, 1 as assinado 
from stg_dc_pdf_assinados sdpa
left join stg_atendimentos_hist sa on sdpa.documento_id = sa.id 
where sdpa.tipo = 'ATENDIMENTO'
)
select ag."data" as data, U.id as id_unidade, prof.id as id_profissional, esp.id as id_especialidade, pac.cpf, count(agdts.agendamento_id) as atendimentos, sum(pront.assinado) as qtddocsassinados
from stg_agendamento_procedimentos agdts
      left join stg_locais L on agdts.local_id = L.id
      left join stg_unidades U on L.unidade_id = U.id
      left join stg_unidades_regioes ur on U.regiao_id = ur.id
      left join stg_procedimentos pro on agdts.procedimento_id = pro.id
      left join stg_agendamentos_hist ag on agdts.agendamento_id = ag.id
      left join stg_especialidades esp on ag.especialidade_id = esp.id
      left join stg_profissionais prof on ag.profissional_id = prof.id 
      left join stg_pacientes pac on ag.paciente_id = pac.id 
      left join pront_assinado pront on agdts.agendamento_id = pront.agendamento_id 
where ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
and pro.tipo_procedimento_id in (2, 9)
group by ag."data", U.id, prof.id, esp.id, pac.cpf



select * from stg_unidades_regioes sur 
limit 5