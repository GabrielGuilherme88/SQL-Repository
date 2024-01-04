--modelagem criada para atender demanda da Gabriela Georgete com o Cheade
--criar os forms em um unico union all
with form_union as (
select * from stg_form_9843
union all
select * from stg_form_9823
union all
select * from stg_form_9816
union all
select * from stg_form_9864
union all
select * from stg_form_9849
union all
select * from stg_form_9824
union all
select * from stg_form_9859
union all
select * from stg_form_13
union all
select * from stg_form_15
union all
select * from stg_form_9
),
atendimento as ( --objeto que buscar o id do atendimento, para relacionar com as clínicas que foi feito o atendimento
select sa.id, su.nome_fantasia, sur.descricao as regional , sa.agendamento_id as agendamento_id_
from stg_atendimentos sa 
left join stg_unidades su on su.id = sa.unidade_id
left join stg_unidades_regioes sur on sur.id = su.regiao_id
),
formulario as (
select cast(sfp.sys_date as date) as data, sfp.paciente_id, sfp.atendimento_id, a.agendamento_id_,
sf2.este_atendimento_gerou_uma_prescricao_cirurgica as cirurgia_ou_nao,
sf.nome as nome_formulario, a.nome_fantasia, a.regional, sp.nome_profissional,
p.nome_paciente, trim(p.cpf) as cpf
from stg_formularios_preenchidos sfp
left join form_union sf2 on sf2.id = sfp.id
left join stg_formularios sf on sf.id = sfp.modelo_id 
left join stg_formularios_tipos sft on sf.id = sf.tipo
left join stg_usuarios su on su.id = sfp.sys_user
left join stg_profissionais sp on sp.id = su.id_relativo
left join atendimento a on a.id = sfp.atendimento_id --left join com o objeto criado
left join stg_pacientes p on p.id = sfp.paciente_id 
where 1=1
and p.sys_active <> 0
and sf2.id is not null
and sfp.atendimento_id is not null
),
consulta_realizadas as ( --objeto que busca aumentar a granularidade caso necessário 
select ap.agendamento_id as id_agendamento, ag."data" as dataagendamento --só escolher as colunas necessárias e vincular com o agendamento_idda do objeto formulario
from stg_agendamento_procedimentos ap
left join stg_agendamentos ag on ap.agendamento_id = ag.id
left join stg_agendamento_status ass on ag.status_id = ass.id
left join stg_especialidades es on ag.especialidade_id = es.id
left join stg_procedimentos pro on ap.procedimento_id = pro.id
left join stg_procedimentos_tipos pt on pro.tipo_procedimento_id = pt.id
where 1=1
--and pt.id in (2, 9) --consulta re retorno
--nd ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3) --status de atenidmento
--and p.sys_user <> 0 --filtra usuários que estão fora da interface feegow
--and p.sys_active = 1 --filtrar usuários ativos
)
select distinct data, paciente_id, nome_paciente, cpf, atendimento_id, agendamento_id_, cirurgia_ou_nao, nome_formulario, nome_fantasia
, regional, nome_profissional
from formulario f
left join consulta_realizadas cr on cr.id_agendamento = f.agendamento_id_
where 1=1
order by paciente_id
limit 1000


select * from stg_memed_prescricoes smp 
where smp.pacienteid = 18558114
limit 100

select * from stg_pacientes_prescricoes spp 
where spp.paciente_id = 18558114
limit 100

select * from stg_formularios_preenchidos sfp 
where sfp.paciente_id = 18558114

select * from stg_dc_pdf_assinados sdpa 
where sdpa.arquivo  = '62cdd4153767a_ATENDIMENTO_20018807_assinado.pdf'

with form_union as (
select * from stg_form_9843
union all
select * from stg_form_9823
union all
select * from stg_form_9816
union all
select * from stg_form_9864
union all
select * from stg_form_9849
union all
select * from stg_form_9824
union all
select * from stg_form_9859
union all
select * from stg_form_13
union all
select * from stg_form_15
union all
select * from stg_form_9
)
select * 
from form_union
--where paciente_id = 18558114
limit 100





select * from stg_atendimentos sa 
limit 10

--modelagem criada para atender demanda da Gabriela Georgete com o Cheade
select *
from stg_formularios_preenchidos sfp 
left join stg_form_9843 sf2 on sf2.id = sfp.id
left join stg_formularios sf on sf.id = sfp.modelo_id 
left join stg_formularios_tipos sft on sf.id = sf.tipo
left join stg_usuarios su on su.id = sfp.sys_user
left join stg_profissionais sp on sp.id = su.id_relativo
where 1=1
and sf2.id is not null
limit 10

with atendimento as (
select sa.id, su.nome_fantasia, sur.descricao as regional 
from stg_agendamentos sa 
left join stg_locais sl on sl.id = sa.local_id 
left join stg_unidades su on su.id = sl.unidade_id
left join stg_unidades_regioes sur on sur.id = su.regiao_id
)
select * 
from atendimento
limit 10


--tabela de formulários
select * from stg_form_9752 sf 
where sf.paciente_id  = 15093121
limit 10

select * from stg_form_9783 sf 
where sf.paciente_id = 15093121

select * from stg_form_9826 sf 
where sf.paciente_id = 15093121

select * from stg_form_9843 
limit 100


select * from tb_consolidacao_agendamentos_hist tcah 
where tcah.id_paciente = 10448450
and tcah.datadoatendimento between current_date and '2024-01-30'






