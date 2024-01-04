--query para verificar os status 
select distinct sas.nome_status ,sah.status_id  from stg_agendamentos_hist sah 
left join stg_agendamento_status sas on sas.id = sah.status_id
where  sah.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
order by status_id 


with pront_assinado as (
select distinct sa.agendamento_id, 1 as assinado 
from stg_dc_pdf_assinados sdpa
left join stg_atendimentos sa on sdpa.documento_id = sa.id 
where sdpa.tipo = 'ATENDIMENTO'
)
select ag."data" as data, ur.descricao, U.nome_fantasia, prof.nome_profissional, esp.nome_especialidade, pac.nome_paciente, pac.cpf,
count(agdts.agendamento_id) as Atentimentos, 
sum(pront.assinado) as QTD_assinado
from stg_agendamento_procedimentos agdts
	  left join stg_locais L on agdts.local_id = L.id
      left join stg_unidades U on L.unidade_id = U.id
      left join stg_unidades_regioes ur on U.regiao_id = ur.id
      left join stg_procedimentos pro on agdts.procedimento_id = pro.id
      left join stg_agendamentos ag on agdts.agendamento_id = ag.id
      left join stg_especialidades esp on ag.especialidade_id = esp.id
      left join stg_profissionais prof on ag.profissional_id = prof.id 
      left join stg_pacientes pac on ag.paciente_id = pac.id 
      left join pront_assinado pront on agdts.agendamento_id = pront.agendamento_id 
where ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
and pro.tipo_procedimento_id in (2, 9)
and u.nome_fantasia = 'AmorSaúde Praia Grande'
and ag."data" between '2023-01-23' and '2023-01-31'
and pac.cpf in ('09318398824','19369611800','02999259433','01156725836','59423315453','32962657400',
'75061767420','14740909820','05200453860','14010662670','98701398504','61643459872','26834902830',
'01276532873','04345444853','15891873850','02547871858','01442420871','00414814703','15694106822',
'86066544853','14642629858','51159824800','42407779843','76644227872','48584099883')
group by ag."data", ur.descricao, U.nome_fantasia, prof.nome_profissional, esp.nome_especialidade, pac.nome_paciente, pac.cpf



select distinct sa.agendamento_id, 1 as assinado, sp.nome_paciente 
from stg_dc_pdf_assinados sdpa
left join stg_atendimentos sa on sdpa.documento_id = sa.id 
left join stg_pacientes sp on sp.id = sa.paciente_id 
where sdpa.tipo = 'ATENDIMENTO'
and sp.cpf  = '76644227872'

--congelada
with pront_assinado as (
select distinct sa.agendamento_id, 1 as assinado 
from stg_dc_pdf_assinados sdpa
left join stg_atendimentos_hist sa on sdpa.documento_id = sa.id 
where sdpa.tipo = 'ATENDIMENTO'
)
select ag."data" as data, ur.descricao, U.nome_fantasia, prof.nome_profissional, esp.nome_especialidade, pac.nome_paciente, pac.cpf, count(agdts.agendamento_id) as Atentimentos, sum(pront.assinado) as QTD_assinado
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
and u.nome_fantasia = 'AmorSaúde Praia Grande'
and ag."data" between '2023-02-01' and '2023-02-28'
and pac.cpf in ('09318398824','19369611800','02999259433','01156725836','59423315453','32962657400',
'75061767420','14740909820','05200453860','14010662670','98701398504','61643459872','26834902830',
'01276532873','04345444853','15891873850','02547871858','01442420871','00414814703','15694106822',
'86066544853','14642629858','51159824800','42407779843','76644227872','48584099883')
group by ag."data", ur.descricao, U.nome_fantasia, prof.nome_profissional, esp.nome_especialidade, pac.nome_paciente, pac.cpf

--Teste unidade Amor Saúde SP Capela do Socorro
with pront_assinado as (
select distinct sa.agendamento_id, 1 as assinado 
from stg_dc_pdf_assinados sdpa
left join stg_atendimentos_hist sa on sdpa.documento_id = sa.id 
where sdpa.tipo = 'ATENDIMENTO'
)
select ag."data" as data, ur.descricao, U.nome_fantasia, prof.nome_profissional, esp.nome_especialidade, pac.nome_paciente, pac.cpf, count(agdts.agendamento_id) as Atentimentos, sum(pront.assinado) as QTD_assinado
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
--and u.nome_fantasia = 'AmorSaúde SP Capela do Socorro'
and ag."data" between '2023-02-01' and '2023-02-28'
and pac.cpf in ('41539744809','21993984801','18495419300','27787374802','26187474880','26455448863',
'07437128896','17999450812','27369796809','22612950818','86072498515','61649007434','27899253802',
'35519988846','22011462843','11252592809','08935225894','18012524830','08660367847','25465306823',
'31972776860','29193441886','05029824898','40318458802','03547017890','25520632847','37500166826',
'34787994816','06557154524','06944948605','24962012819','16658784876','26905306860','26030872826',
'01672033802','25759367803','14893669893','03533070840','24286435415','00252644352','34892905852',
'22994418835','39276186832','61863831568','16410235895','05146192871','26564524811')
group by ag."data", ur.descricao, U.nome_fantasia, prof.nome_profissional, esp.nome_especialidade, pac.nome_paciente, pac.cpf


