-------------------
--query antiga onde cria a defasagem do horário 
--query modificada para atender a demanda do tempo médio das clínicas do ícaro
with base0 as ( 
select 
row_number () OVER(ORDER by lm.paciente_id, cast(lm.data_hora as time) ) as indice0,
lm.paciente_id as paciente, cast(lm.data_hora as time) as hora0, to_char(lm."data", 'Month') as mes, lm.procedimento_id as id_procedimento,
tcah.nome_especialidade, 
lm.status_id as status_id , sas.nome_status as nome_status,  sur.descricao as regional, u.id as id_unidade, u.nome_fantasia, lm."data" as data,
case 
	when lm.status_id = 204 then 2 --retirado status id = 1 (agendado) para efeito de limpeza
	when lm.status_id = 202 then 3
	when lm.status_id = 33 then 4
	when lm.status_id = 5 then 5
	when lm.status_id = 2 then 6
	when lm.status_id = 3 then 7
	when lm.status_id = 201 then 8
	when lm.status_id = 205 then 10
	when lm.status_id = 203 then 11
	else 0
	end as fila_status,
case when fila_status in (1,2,3,5,4) then 'Pré atendimento'
	when fila_status in (6,7) then 'Atendimento'
	when fila_status in (8,10,11) then 'Pós consulta'
	else '0'
	end as agrupamento_status
from stg_log_marcacoes lm
left join stg_unidades u on u.id = lm.unidade_id
left join stg_unidades_regioes sur on sur.id = u.regiao_id
left join stg_agendamento_status sas on sas.id = lm.status_id
left join tb_consolidacao_agendamentos_hist tcah on tcah.id_agendamento = lm.agendamento_id 
--and u.nome_fantasia = 'AmorSaúde Serrinha'
where 1=1
and lm.unidade_id is not null
and sur.descricao is not null
and sas.nome_status is not null
and lm.status_id  in (2, 3, 33, 202, 204, 5, 201, 205, 203)
and lm."data" between '2020-01-01' and current_date
and lm.paciente_id not in (-1)
--and lm.paciente_id = 65862680
and u.id not in (19865)
order by lm.paciente_id, fila_status, lm."data"),
final_objeto as (
select indice0, data, paciente, hora0, mes, status_id , nome_status, 
regional, fila_status, agrupamento_status, id_unidade, nome_fantasia, id_procedimento,nome_especialidade,
lag(hora0,1) over (order by paciente) as lag0, lag0 - hora0 as duracao
from base0
where 1=1
and id_unidade in (19932, 19935, 19728, 19462, 19830, 19855, 19957) -- filtrando as unidades do Ícaro
)
select indice0, data, paciente, hora0, lag0, mes, status_id , nome_status, 
regional, fila_status, agrupamento_status, id_unidade, nome_fantasia, id_procedimento, nome_especialidade,
duracao
from final_objeto


--Franquias Ícaro
select * from stg_unidades su
where 1=1
and su.nome_fantasia in ('AmorSaúde Arujá', 'AmorSaúde Ribeirão Pires', 'AmorSaúde Araguari', 'AmorSaúde Carapicuiba',
'AmorSaúde Fortaleza', 'AmorSaúde Uberlândia', 'AmorSaúde Macaé', 'AmorSaúde Batatais', 'AmorSaúde Mogi Guaçu')



--query salva
with objet_1 as (
select tcah.id_agendamento , tcah.datadoatendimento, su.id as id_unidade, su.nome_fantasia, cast(lm.data_hora as time) as hora0, sas.nome_status, lm.status_id,
tcah.nome_especialidade 
from tb_consolidacao_agendamentos_hist tcah 
left join stg_log_marcacoes lm on lm.agendamento_id = tcah.id_agendamento 
left join stg_agendamento_status sas on sas.id = lm.status_id
left join stg_unidades su on su.id = tcah.id_unidade
where 1=1
and tcah.datadoatendimento between '2020-01-01' and current_date
and tcah.id_unidade in (19932, 19935, 19728, 19462, 19830, 19855, 19957)
--and tcah.id_agendamento = 809853049 --paravalidar com id do agendamento
),
objet_2 as (
select distinct datadoatendimento, nome_fantasia, id_unidade, nome_especialidade, id_agendamento,
 CASE 
	 WHEN status_id = 204 THEN hora0 END AS "Chamando_pré_consulta", 
	case when status_id = 202 THEN hora0 END AS "Em_atendimento_pré_consulta",
	case when status_id = 33 THEN hora0 END AS "Em_espera",
	case when status_id = 5 THEN hora0 END AS "Chamando",
	case when status_id = 2 THEN hora0 END AS "Em_atendimento",
	case when status_id = 3 THEN hora0 END AS "Atendido",
	case when status_id = 201 THEN hora0 END AS "Aguardando_pós_Consulta",
	case when status_id = 205 THEN hora0 END AS "Chamando_pós_consulta",
	case when status_id = 203 THEN hora0 END AS "Em_atendimento_pós_consulta"
from objet_1
where 1=1),
objet_3 as (
select datadoatendimento, nome_fantasia, id_unidade, nome_especialidade, id_agendamento,
	CAST(EXTRACT(HOUR FROM Chamando_pré_consulta) AS DECIMAL(10, 2)) + CAST(EXTRACT(MINUTE FROM Chamando_pré_consulta) / 60 AS DECIMAL(10, 2)) AS Chamando_pré_consulta,
	CAST(EXTRACT(HOUR FROM Em_atendimento_pré_consulta) AS DECIMAL(10, 2)) + CAST(EXTRACT(MINUTE FROM Em_atendimento_pré_consulta) / 60 AS DECIMAL(10, 2)) AS Em_atendimento_pré_consulta,
	CAST(EXTRACT(HOUR FROM Em_espera) AS DECIMAL(10, 2)) + CAST(EXTRACT(MINUTE FROM Em_espera) / 60 AS DECIMAL(10, 2)) AS Em_espera,
	CAST(EXTRACT(HOUR FROM Chamando) AS DECIMAL(10, 2)) + CAST(EXTRACT(MINUTE FROM Chamando) / 60 AS DECIMAL(10, 2)) AS Chamando,
	CAST(EXTRACT(HOUR FROM Em_atendimento) AS DECIMAL(10, 2)) + CAST(EXTRACT(MINUTE FROM Em_atendimento) / 60 AS DECIMAL(10, 2)) AS Em_atendimento,
	CAST(EXTRACT(HOUR FROM Atendido) AS DECIMAL(10, 2)) + CAST(EXTRACT(MINUTE FROM Atendido) / 60 AS DECIMAL(10, 2)) AS Atendido,
	CAST(EXTRACT(HOUR FROM Aguardando_pós_Consulta) AS DECIMAL(10, 2)) + CAST(EXTRACT(MINUTE FROM Aguardando_pós_Consulta) / 60 AS DECIMAL(10, 2)) AS Aguardando_pós_Consulta,
	CAST(EXTRACT(HOUR FROM Chamando_pós_consulta) AS DECIMAL(10, 2)) + CAST(EXTRACT(MINUTE FROM Chamando_pós_consulta) / 60 AS DECIMAL(10, 2)) AS Chamando_pós_consulta,
	CAST(EXTRACT(HOUR FROM Em_atendimento_pós_consulta) AS DECIMAL(10, 2)) + CAST(EXTRACT(MINUTE FROM Em_atendimento_pós_consulta) / 60 AS DECIMAL(10, 2)) AS Em_atendimento_pós_consulta
FROM objet_2)
select datadoatendimento, nome_fantasia, id_unidade, nome_especialidade, id_agendamento,
	sum(Chamando_pré_consulta) as Chamando_pré_consulta,
	sum(Em_atendimento_pré_consulta) as Em_atendimento_pré_consulta,
	sum(Em_espera) as Em_espera,
	sum(Chamando) as Chamando,
	sum(Em_atendimento) as Em_atendimento,
	sum(Atendido) as Atendido,
	sum(Aguardando_pós_Consulta) as Aguardando_pós_Consulta,
	sum(Chamando_pós_consulta) as Chamando_pós_consulta,
	sum(Em_atendimento_pós_consulta) as Em_atendimento_pós_consulta
from objet_3
group by datadoatendimento, nome_fantasia, nome_especialidade, id_agendamento, id_unidade


------------------------------------------------
--objetivo era simplificar e unificar os status em três colunas
-----query agregando por coluna
with objet_1 as (
select tcah.id_agendamento , tcah.datadoatendimento, su.id as id_unidade, su.nome_fantasia, cast(lm.data_hora as time) as hora0, sas.nome_status, lm.status_id,
tcah.nome_especialidade 
from tb_consolidacao_agendamentos_hist tcah 
left join stg_log_marcacoes lm on lm.agendamento_id = tcah.id_agendamento 
left join stg_agendamento_status sas on sas.id = lm.status_id
left join stg_unidades su on su.id = tcah.id_unidade
where 1=1
and tcah.datadoatendimento between '2020-01-01' and current_date
and tcah.id_unidade in (19932, 19935, 19728, 19462, 19830, 19855, 19957) -- filtrando as unidades do Ícaro
--and tcah.id_agendamento = 809853049 --paravalidar com id do agendamento
),
objet_2 as (
select distinct datadoatendimento, nome_fantasia, id_unidade, nome_especialidade, id_agendamento,
 CASE 
	 WHEN status_id in (204,202,33,5,206,200)  THEN hora0 END AS "pre_atendimento", 
	case when status_id in (2,3) THEN hora0 END AS "Atendimento",
	case when status_id in (201,203,205,207) THEN hora0 END AS "pos_consulta" 
from objet_1
where 1=1),
objet_3 as (
select datadoatendimento, nome_fantasia, id_unidade, nome_especialidade, id_agendamento,
	CAST(EXTRACT(HOUR FROM pre_atendimento) AS DECIMAL(10, 2)) + CAST(EXTRACT(MINUTE FROM pre_atendimento) / 60 AS DECIMAL(10, 2)) AS pre_atendimento,
	CAST(EXTRACT(HOUR FROM Atendimento) AS DECIMAL(10, 2)) + CAST(EXTRACT(MINUTE FROM Atendimento) / 60 AS DECIMAL(10, 2)) AS Atendimento,
	CAST(EXTRACT(HOUR FROM pos_consulta) AS DECIMAL(10, 2)) + CAST(EXTRACT(MINUTE FROM pos_consulta) / 60 AS DECIMAL(10, 2)) AS pos_consulta
FROM objet_2)
select datadoatendimento, nome_fantasia, id_unidade, nome_especialidade, id_agendamento,
	sum(pre_atendimento) as pre_atendimento,
	sum(Atendimento) as Atendimento,
	sum(pos_consulta) as Em_espera
from objet_3
group by datadoatendimento, nome_fantasia, nome_especialidade, id_agendamento, id_unidade


----------------
--para validação
with objet as (
select tcah.datadoatendimento, tcah.nome_fantasia, cast(lm.data_hora as time) as hora0, sas.nome_status, lm.status_id
from tb_consolidacao_agendamentos_hist tcah 
left join stg_log_marcacoes lm on lm.agendamento_id = tcah.id_agendamento 
left join stg_agendamento_status sas on sas.id = lm.status_id 
where tcah.id_agendamento = 809853049),
objet_1 as (
select distinct datadoatendimento, nome_fantasia,
 CASE 
	 WHEN status_id = 204 THEN hora0 END AS "Chamando_pré_consulta", 
	case when status_id = 202 THEN hora0 END AS "Em_atendimento_pré_consulta",
	case when status_id = 33 THEN hora0 END AS "Em_espera",
	case when status_id = 5 THEN hora0 END AS "Chamando",
	case when status_id = 2 THEN hora0 END AS "Em_atendimento",
	case when status_id = 3 THEN hora0 END AS "Atendido",
	case when status_id = 201 THEN hora0 END AS "Aguardando_pós_Consulta",
	case when status_id = 205 THEN hora0 END AS "Chamando_pós_consulta",
	case when status_id = 203 THEN hora0 END AS "Em_atendimento_pós_consulta"	 
from objet
where 1=1)
select * from objet_1

select * from stg_log_marcacoes slm
left join stg_agendamento_status s on s.id = slm.status_id
where slm.unidade_id in (19932, 19935, 19728, 19462, 19830, 19855, 19957)


select sas.nome_status, lm.status_id, count(*)
from tb_consolidacao_agendamentos_hist tcah 
left join stg_log_marcacoes lm on lm.agendamento_id = tcah.id_agendamento 
left join stg_agendamento_status sas on sas.id = lm.status_id 
where 1=1
and tcah.id_unidade in (19932, 19935, 19728, 19462, 19830, 19855, 19957)
group by sas.nome_status, lm.status_id





----query com window function
select tcah.id_agendamento , tcah.datadoatendimento, su.id as id_unidade, su.nome_fantasia, cast(lm.data_hora as time) as hora0, 
sas.nome_status, lm.status_id,
tcah.nome_especialidade, 
case 
	when lm.status_id = 204 then 2 --retirado status id = 1 (agendado) para efeito de limpeza
	when lm.status_id = 202 then 3
	when lm.status_id = 33 then 4
	when lm.status_id = 5 then 5
	when lm.status_id = 2 then 6
	when lm.status_id = 3 then 7
	when lm.status_id = 201 then 8
	when lm.status_id = 205 then 10
	when lm.status_id = 203 then 11
	else 0
	end as fila_status,
lead(cast(lm.data_hora as time)) over (PARTITION BY tcah.id_agendamento ORDER BY fila_status) - cast(lm.data_hora as time) 
	as time_to_next_station
from tb_consolidacao_agendamentos_hist tcah 
left join stg_log_marcacoes lm on lm.agendamento_id = tcah.id_agendamento 
left join stg_agendamento_status sas on sas.id = lm.status_id
left join stg_unidades su on su.id = tcah.id_unidade
where 1=1
and tcah.datadoatendimento between '2020-01-01' and current_date
and tcah.id_unidade in (19932, 19935, 19728, 19462, 19830, 19855, 19957)
and lm.status_id in (2, 3, 33, 202, 204, 5, 201, 205, 203)