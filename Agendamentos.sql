--Verifica qtde de registr por data
select sah."data", count(sah.id), sum(sah.valor)  
from stg_agendamentos_hist sah
where sah."data" between '2023-02-01' and current_date -1
group by sah."data"
order by sah."data" DESC


--Agendamentos por região e unidades
select su.nome_fantasia, sur.descricao, count(sah.id) as qtde from stg_agendamentos_hist sah
left join stg_locais sl on sl.id  = sah.local_id 
left join stg_unidades su on sl.id = su.id
left join stg_unidades_regioes sur on su.regiao_id = sur.id 
where sah."data" between '2023-03-09' and '2023-03-09'
--and su.nome_fantasia is null
group by sur.descricao, su.nome_fantasia
order by qtde desc

--Quantidade de atendimento por unidade
select count(*) 
from tb_consolidacao_agendamentos_hist tca
where tca.datadoatendimento between '2023-03-09' and '2023-03-09'
and tca .nome_status = 'Atendido'
and tca.nome_fantasia = 'AmorSaúde Gravataí'
--group by tca.nome_canal
--order by tca .nome_fantasia asc

select tca.nome_status, count(*) 
from tb_consolidacao_agendamentos_hist tca
where tca.datadoatendimento = '2023-11-10'
--and tca .nome_status = 'Atendido'
and tca.id_unidade  = 19364
group by tca.nome_status


--modelagem
select count(distinct ag.id) --countar distinto os id de agendamento, o dhup está multiplicando as linhas
from stg_agendamento_procedimentos ap
left join stg_agendamentos ag on ap.agendamento_id = ag.id
left join stg_pacientes sp on sp.id = ag.paciente_id
left join stg_agendamento_status ass on ag.status_id = ass.id
left join stg_especialidades es on ag.especialidade_id = es.id
left join stg_procedimentos pro on ap.procedimento_id = pro.id
left join stg_procedimentos_tipos pt on pro.tipo_procedimento_id = pt.id
left join stg_locais l on ap.local_id = l.id
left join stg_unidades u on l.unidade_id = u.id
left join stg_agendamento_canais sac on sac.id = ag.canal_id
left join stg_agendamento_subcanais sas on sas.id = ag.subcanal_id 
where pt.id in (2, 9)
--and ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
and u.id = 19275
and ag."data" between date('2023-11-01') and date ('2023-11-26')
--group by u.id
--order by u.id

select tcah.id_unidade, count(distinct tcah.id_agendamento) 
from tb_consolidacao_agendamentos_hist tcah 
where datadoatendimento between ('2023-11-01') and ('2023-11-26')
and id_unidade = 19653
--and tcah.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
group by tcah.id_unidade
order by tcah.id_unidade ASC

SELECT * FROM stg_unidades su 
where su.id = 19653
LIMIT 10