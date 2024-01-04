--tentando agregar datas para a análise
with atendimento_consulta as (
--atendimentos em consulta
select 'atendimento_consulta' as categoria, extract(year from ag."data") as ano, extract(month from ag."data") as mes,
u.nome_fantasia as nome_unidade, u.cidade as cidade
, u.id,  count(*) as qtde
from stg_agendamento_procedimentos ap
left join stg_agendamentos ag on ap.agendamento_id = ag.id
left join stg_agendamento_status ass on ag.status_id = ass.id
left join stg_especialidades es on ag.especialidade_id = es.id
left join stg_procedimentos pro on ap.procedimento_id = pro.id
left join stg_procedimentos_tipos pt on pro.tipo_procedimento_id = pt.id
left join stg_locais l on ap.local_id = l.id
left join stg_unidades u on l.unidade_id = u.id
where pt.id in (2, 9)
and ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
and ag."data" between  '2020-01-01' and '2023-06-30'
group by u.nome_fantasia, u.cidade, u.id, 
extract(year from ag."data"), extract(month from ag."data")),
prontuarios as (
--prontuarios exames
select 'prontuarios_exames' as categoria,  
extract(year from pp."data") as ano, extract(month from pp."data") as mes,
u.nome_fantasia as nome_unidade, u.cidade, u.id, count(pp.id) as qtde
from stg_pacientes_pedidos pp
left join stg_unidades u on pp.unidade_id = u.id
left join stg_unidades_regioes ur on u.regiao_id = ur.id
left join stg_pacientes pcts on pp.paciente_id = pcts.id
left join stg_tabelas_particulares tp on pcts.tabela_id = tp.id
where pp."data" between  '2020-01-01' and '2023-06-30'
group by u.nome_fantasia, u.cidade, u.id, extract(year from pp."data"), extract(month from pp."data")),
--prontuarios exames
formularios_preenchidos as (
select 'prontuarios_preenchidos_consulta' as categoria, 
extract(year from sfp.sys_date) as ano, extract(month from sfp.sys_date) as mes,
su.nome_fantasia as nome_unidade, su.cidade, su.id, count(distinct sfp.atendimento_id) as qtde 
from stg_formularios_preenchidos sfp
left join stg_atendimentos sa on sa.id = sfp.atendimento_id
left join stg_unidades su on su.id = sa.unidade_id
where sfp.sys_date  between '2020-01-01' and '2023-06-30'
group by su.nome_fantasia, su.cidade, su.id, extract(year from sfp.sys_date), extract(month from sfp.sys_date)),
pacientes_unicos_clinica as (
select * from atendimento_consulta
where atendimento_consulta.nome_unidade is not null
union all
select * from prontuarios
where prontuarios.nome_unidade is not null
union all)
select * from formularios_preenchidos
where formularios_preenchidos.nome_unidade is not null

--essa foi a query enviada ao pedro
with ano_2020 as (
select extract(year from sa.data) as ano, 
su.nome_fantasia as nome_unidade, su.cidade, su.id as id_clinica, count(distinct sa.paciente_id) as qtde 
from stg_atendimentos sa 
left join stg_unidades su on su.id = sa.unidade_id
where su.nome_fantasia not in ('CENTRAL AMORSAÚDE', 'Clínica de Treinamento')
--and sa.paciente_id = 16535354 --para validação
and extract(year from sa.data) = 2020
group by extract(year from sa.data), su.nome_fantasia, su.cidade, su.id),
ano_2021 as (
--ano 2021
select extract(year from sa.data) as ano, 
su.nome_fantasia as nome_unidade, su.cidade, su.id as id_clinica, count(distinct sa.paciente_id) as qtde 
from stg_atendimentos sa 
left join stg_unidades su on su.id = sa.unidade_id
where su.nome_fantasia not in ('CENTRAL AMORSAÚDE', 'Clínica de Treinamento')
--and sa.paciente_id = 16535354 --para validação
and extract(year from sa.data) = 2021
group by extract(year from sa.data), su.nome_fantasia, su.cidade, su.id),
--ano 2022
ano_2022 as (
select extract(year from sa.data) as ano, 
su.nome_fantasia as nome_unidade, su.cidade, su.id as id_clinica, count(distinct sa.paciente_id) as qtde 
from stg_atendimentos sa 
left join stg_unidades su on su.id = sa.unidade_id
where su.nome_fantasia not in ('CENTRAL AMORSAÚDE', 'Clínica de Treinamento')
--and sa.paciente_id = 16535354 --para validação
and extract(year from sa.data) = 2022
group by extract(year from sa.data), su.nome_fantasia, su.cidade, su.id),
--ano 2023
ano_2023 as (
select extract(year from sa.data) as ano,
su.nome_fantasia as nome_unidade, su.cidade, su.id as id_clinica, count(distinct sa.paciente_id) as qtde 
from stg_atendimentos sa 
left join stg_unidades su on su.id = sa.unidade_id
where su.nome_fantasia not in ('CENTRAL AMORSAÚDE', 'Clínica de Treinamento')
--and sa.paciente_id = 16535354 --para validação
and extract(year from sa.data) = 2023
group by extract(year from sa.data), su.nome_fantasia, su.cidade, su.id)
select ano, nome_unidade, cidade, id_clinica, sum(qtde) as qtde from (
select * from ano_2020
union all
select * from ano_2021
union all
select * from ano_2022
union all
select * from ano_2023)
group by ano, nome_unidade, cidade, id_clinica




--agregando por case when
with ano_2020 as (
select 'ano_2020' as categoria, sa.paciente_id as paciente_id_2020, extract(year from sa.data) as ano,
su.nome_fantasia as nome_unidade, su.cidade, su.id as id_clinica, count(distinct sa.paciente_id) as qtde 
from stg_atendimentos sa 
left join stg_unidades su on su.id = sa.unidade_id
where su.nome_fantasia not in ('CENTRAL AMORSAÚDE', 'Clínica de Treinamento')
--and sa.paciente_id = 16535354
and extract(year from sa.data) = 2020
group by extract(year from sa.data), sa.paciente_id,
su.nome_fantasia, su.cidade, su.id),
ano_2021 as (
--ano 2021
select 'ano_2021' as categoria, sa.paciente_id as paciente_id_2021, extract(year from sa.data) as ano,
su.nome_fantasia as nome_unidade, su.cidade, su.id as id_clinica, count(distinct sa.paciente_id) as qtde 
from stg_atendimentos sa 
left join stg_unidades su on su.id = sa.unidade_id
where su.nome_fantasia not in ('CENTRAL AMORSAÚDE', 'Clínica de Treinamento')
--and sa.paciente_id = 16535354
and extract(year from sa.data) = 2021
group by extract(year from sa.data),sa.paciente_id,
su.nome_fantasia, su.cidade, su.id),
--ano 2022
ano_2022 as (
select 'ano_2022' as categoria, sa.paciente_id as paciente_id_2022, extract(year from sa.data) as ano,
su.nome_fantasia as nome_unidade, su.cidade, su.id as id_clinica, count(distinct sa.paciente_id) as qtde 
from stg_atendimentos sa 
left join stg_unidades su on su.id = sa.unidade_id
where su.nome_fantasia not in ('CENTRAL AMORSAÚDE', 'Clínica de Treinamento')
--and sa.paciente_id = 16535354
and extract(year from sa.data) = 2022
group by extract(year from sa.data), sa.paciente_id,
su.nome_fantasia, su.cidade, su.id),
--ano 2023
ano_2023 as (
select 'ano_2023' as categoria, sa.paciente_id as paciente_id_2023, extract(year from sa.data) as ano,
su.nome_fantasia as nome_unidade, su.cidade, su.id as id_clinica, count(distinct sa.paciente_id) as qtde 
from stg_atendimentos sa 
left join stg_unidades su on su.id = sa.unidade_id
where su.nome_fantasia not in ('CENTRAL AMORSAÚDE', 'Clínica de Treinamento')
--and sa.paciente_id = 16535354
and extract(year from sa.data) = 2023
group by extract(year from sa.data), sa.paciente_id,
su.nome_fantasia, su.cidade, su.id)
select case when ano = 2020 then qtde else 0 end as qtde_ano_2020,
case when ano = 2021 then qtde else 0 end as qtde_ano_2021,
case when ano = 2022 then qtde else 0 end as qtde_ano_2022,
case when ano = 2023 then qtde else 0 end as qtde_ano_2023,
nome_unidade, cidade
from (
select ano, nome_unidade, cidade, id_clinica , sum(qtde) as qtde
from ano_2020
group by nome_unidade, cidade, id_clinica, ano
union all
select ano, nome_unidade, cidade, id_clinica , sum(qtde) as qtde
from ano_2021
group by nome_unidade, cidade, id_clinica, ano
union all
select ano, nome_unidade, cidade, id_clinica , sum(qtde) as qtde
from ano_2022
group by nome_unidade, cidade, id_clinica,  ano
union all
select ano, nome_unidade, cidade, id_clinica , sum(qtde) as qtde
from ano_2023
group by nome_unidade, cidade, id_clinica, ano
)
group by qtde_ano_2020, qtde_ano_2021, qtde_ano_2022, qtde_ano_2023, nome_unidade, cidade


--Para salvar
with ano_2020 as (
select 'ano_2020' as categoria,
extract(year from sa.data) as ano, extract(month from sa.data) as mes,
su.nome_fantasia as nome_unidade, su.cidade, su.id as id_clinica, count(distinct sa.paciente_id) as qtde 
from stg_atendimentos sa 
left join stg_unidades su on su.id = sa.unidade_id
where su.nome_fantasia not in ('CENTRAL AMORSAÚDE', 'Clínica de Treinamento')
--and sa.paciente_id = 41
and extract(year from sa.data) = 2020
group by extract(year from sa.data), extract(month from sa.data), sa.paciente_id,
su.nome_fantasia, su.cidade, su.id),
ano_2021 as (
--ano 2021
select 'ano_2021' as categoria,
extract(year from sa.data) as ano, extract(month from sa.data) as mes,
su.nome_fantasia as nome_unidade, su.cidade, su.id as id_clinica, count(distinct sa.paciente_id) as qtde 
from stg_atendimentos sa 
left join stg_unidades su on su.id = sa.unidade_id
where su.nome_fantasia not in ('CENTRAL AMORSAÚDE', 'Clínica de Treinamento')
--and sa.paciente_id = 41
and extract(year from sa.data) = 2021
group by extract(year from sa.data), extract(month from sa.data),sa.paciente_id,
su.nome_fantasia, su.cidade, su.id),
--ano 2022
ano_2022 as (
select 'ano_2022' as categoria,
extract(year from sa.data) as ano, extract(month from sa.data) as mes,
su.nome_fantasia as nome_unidade, su.cidade, su.id as id_clinica, count(distinct sa.paciente_id) as qtde 
from stg_atendimentos sa 
left join stg_unidades su on su.id = sa.unidade_id
where su.nome_fantasia not in ('CENTRAL AMORSAÚDE', 'Clínica de Treinamento')
--and sa.paciente_id = 41
and extract(year from sa.data) = 2022
group by extract(year from sa.data), extract(month from sa.data), sa.paciente_id,
su.nome_fantasia, su.cidade, su.id),
--ano 2023
ano_2023 as (
select 'ano_2023' as categoria,
extract(year from sa.data) as ano, extract(month from sa.data) as mes,
su.nome_fantasia as nome_unidade, su.cidade, su.id as id_clinica, count(distinct sa.paciente_id) as qtde 
from stg_atendimentos sa 
left join stg_unidades su on su.id = sa.unidade_id
where su.nome_fantasia not in ('CENTRAL AMORSAÚDE', 'Clínica de Treinamento')
--and sa.paciente_id = 41
and extract(year from sa.data) = 2023
group by extract(year from sa.data), extract(month from sa.data), sa.paciente_id,
su.nome_fantasia, su.cidade, su.id)
select * from ano_2020
union all
select * from ano_2021
union all
select * from ano_2022
union all
select * from ano_2023


--buscar paciente para validação junto a feegow de prontuários preenchidos na consulta
select distinct 'prontuarios_preenchidos_consulta' as categoria, extract(year from sfp.sys_date) as ano, extract(month from sfp.sys_date) as mes,
su.nome_fantasia as nome_unidade, su.cidade, su.id, count(distinct sfp.atendimento_id) as qtde 
from stg_formularios_preenchidos sfp
left join stg_atendimentos sa on sa.id = sfp.atendimento_id
left join stg_unidades su on su.id = sa.unidade_id
where sfp.sys_date  between '2020-01-01' and '2023-06-30'
and sfp.paciente_id = 16535354
group by su.nome_fantasia, su.cidade, su.id, extract(year from sfp.sys_date), extract(month from sfp.sys_date)