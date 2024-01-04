select ur.id as id_regional,
u.id as id_unidade,
ag."data" as dataatendimento,
ass.nome_status,
es.nome_especialidade,
count(ag.id) as quantidadeagendamentos
from stg_agendamentos ag 
left join stg_locais l on ag.local_id = l.id
left join stg_unidades u on l.unidade_id = u.id
left join stg_unidades_regioes ur on u.regiao_id = ur.id
left join stg_agendamento_status ass on ag.status_id = ass.id
left join stg_especialidades es on ag.especialidade_id = es.id
left join stg_procedimentos pro on ag.procedimento_id = pro.id 
where pro.tipo_procedimento_id in (2, 9)
group by ur.id, u.id, ag."data", ass.nome_status, es.nome_especialidade