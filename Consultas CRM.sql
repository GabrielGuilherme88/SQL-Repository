--Primeiro crio o objeto que separa a quantidade de consulta, com a especialidade na dimensão do cpf do paciente
	with atendimento_consulta as (
select u.nome_fantasia as nome_unidade, u.cidade as cidade, trim(p.cpf) as cpf, p.id as id_paciente, ss.nomesexo as sexo , 
	u.id, count(*) as qtde, es.nome_especialidade, ag."data" as dataagendamento
from stg_agendamento_procedimentos ap
left join stg_agendamentos ag on ap.agendamento_id = ag.id
left join stg_pacientes p on p.id = ag.paciente_id
left join stg_sexo ss on ss.id = p.sexo
left join stg_agendamento_status ass on ag.status_id = ass.id
left join stg_especialidades es on ag.especialidade_id = es.id
left join stg_procedimentos pro on ap.procedimento_id = pro.id
left join stg_procedimentos_tipos pt on pro.tipo_procedimento_id = pt.id
left join stg_locais l on ap.local_id = l.id
left join stg_unidades u on l.unidade_id = u.id
where pt.id in (2, 9)
--and ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
and ag."data" between  '2020-01-01' and '2023-08-31'
and p.sys_user <> 0 --filtra usuários que estão fora da interface feegow
and p.sys_active = 1 --filtrar usuários ativos
group by id_paciente, trim(p.cpf), u.id, u.nome_fantasia, u.cidade, es.nome_especialidade, ag."data", ss.nomesexo),
--segundo objeto é criado para transpor as coluna de data, separando-as por ano com o extract e case when	
	year_col as (
select cpf, id_paciente, sexo, dataagendamento, nome_especialidade, qtde,
CASE 
		WHEN extract (year from dataagendamento) = 2020 THEN qtde END AS "2020",
CASE
		WHEN extract (year from dataagendamento) = 2021 THEN qtde END AS "2021",
CASE
		WHEN extract (year from dataagendamento) = 2022 THEN qtde END AS "2022",
CASE
		WHEN extract (year from dataagendamento) = 2023 THEN qtde END AS "2023",
CASE
		WHEN nome_especialidade = 'Clinica Médica' THEN max(dataagendamento) END AS "Last_date_clinica_medica",
CASE
		WHEN nome_especialidade = 'Oftalmologia' THEN max(dataagendamento) END AS "Last_date_Oftalmologia",
CASE
		WHEN nome_especialidade = 'Ginecologia' THEN max(dataagendamento) END AS "Last_date_Ginecologia",
CASE
		WHEN nome_especialidade = 'Ortopedia e Traumatologia' THEN max(dataagendamento) END AS "Last_date_Ortopedia",
CASE
		WHEN nome_especialidade = 'Cardiologia' THEN max(dataagendamento) END AS "Last_date_Cardiologia"
from atendimento_consulta
where 1=1
group by  cpf, id_paciente, sexo, dataagendamento, nome_especialidade, qtde
),
--
qtde_paciente as (
select id_paciente as idp, sum(qtde) as total_consulta
from atendimento_consulta
group by id_paciente
),
--Objeto criado para trazer o máximo da data
datamax as (
select id_paciente as idp3, max(dataagendamento) as data_last_consulta
from year_col
group by id_paciente
)
--query final agrupando as informações
	select cpf, id_paciente, sexo, max(p.total_consulta) as total_consulta, d.data_last_consulta as ultima_consulta,
	current_date - d.data_last_consulta as tempo_sem_uso,
	sum("2020") as "2020",
	sum("2021") as "2021",
	sum("2022") as "2022",
	sum("2023") as "2023",
	null as "2024",
	max(Last_date_clinica_medica) as Last_date_clinica_medica,
	max(Last_date_Oftalmologia) as Last_date_Oftalmologia,
	max(Last_date_Ginecologia) as Last_date_Ginecologia,
	max(Last_date_Ortopedia) as Last_date_Ortopedia,
	max(Last_date_Cardiologia) as Last_date_Cardiologia
	from year_col
	left join qtde_paciente p on p.idp =  id_paciente
	left join datamax d on d.idp3 = id_paciente
		where 1=1
		--and cpf = '51267258829' --para validação nível cpf paciente
		--and id_paciente = 58380201 --para validação nível id paciente
		and cpf is not null and cpf not in ('') --reitrar cpf's nulos
		and cpf <> '00000000000' --limpa cpf com 0
		--and cpf = '65597982672'
	group by cpf, id_paciente,sexo, data_last_consulta
	--order by cpfem
	

--query de validação de consulta
select p.nome_paciente,  u.nome_fantasia as nome_unidade, u.cidade as cidade, p.cpf, p.id as id_paciente, u.id, count(*) as qtde, es.nome_especialidade, ag."data" as dataagendamento, p.nome_paciente 
from stg_agendamento_procedimentos ap
left join stg_agendamentos ag on ap.agendamento_id = ag.id
left join stg_pacientes p on p.id = ag.paciente_id 
left join stg_agendamento_status ass on ag.status_id = ass.id
left join stg_especialidades es on ag.especialidade_id = es.id
left join stg_procedimentos pro on ap.procedimento_id = pro.id
left join stg_procedimentos_tipos pt on pro.tipo_procedimento_id = pt.id
left join stg_locais l on ap.local_id = l.id
left join stg_unidades u on l.unidade_id = u.id
where pt.id in (2, 9)
and ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
and ag."data" between  '2020-01-01' and current_date -1
and p.id = 64000219 --para validação
group by u.nome_fantasia, u.cidade, u.id, p.cpf, es.nome_especialidade, ag."data", id_paciente, p.nome_paciente


--para validação
select * from tb_consolidacao_contas_a_receber_modelagem tccarm 
where 1=1
and tccarm.id_paciente = 64000219


select * from stg_pacientes sp 
--left join stg_pacientes_relativos spr on spr.paciente_id = sp.id
where 1=1
and sys_active = 1
and sys_user  <> 0
and sp.cpf = '51267258829'
or sp.cpf like  '	51267258829'

--para cruzar com o crm do cartao
with cpf_unico as (
select count(*) qtde, cpf from pdgt_sandbox_gabrielguilherme.fl_consultas_crm
where cpf is not null
group by cpf
having count(*) = 1
order by count(*) desc)
select crm.cpf as CPF, crm.id_paciente, crm.sexo, crm.total_consulta, crm.ultima_consulta, crm.tempo_sem_uso, crm."2020", crm."2021", crm."2022", crm."2023", crm."2024", 
crm.last_date_clinica_medica, crm.last_date_oftalmologia, crm.last_date_ginecologia ,crm.last_date_ortopedia, crm.last_date_cardiologia  
from pdgt_sandbox_gabrielguilherme.fl_consultas_crm crm
inner join cpf_unico as c on c.cpf = crm.cpf


