select
cb."data",
u.nome_fantasia as unidade,
ur.descricao as regionalm,
cb.conta_bloqueio_status_id as status
from stg_contas_bloqueios cb
left join stg_unidades u on cb.unidade_id = u.id
left join stg_unidades_regioes ur on u.regiao_id = ur.id
where u.nome_fantasia not in ('AmorSaúde Telemedicina', 
'Clínica de Treinamento', 'CENTRAL AMORSAÚDE', 
'AmorSaúde (Central Ribeirão Preto)')
and cb."data" between '2023-03-01' and '2023-03-06'
order by cb."data" desc

select
max(cb."data"),
count(cb.asasaselect) 
from stg_contas_bloqueios cb
left join stg_unidades u on cb.unidade_id = u.id
left join stg_unidades_regioes ur on u.regiao_id = ur.id
where u.nome_fantasia not in ('AmorSaúde Telemedicina', 
'Clínica de Treinamento', 'CENTRAL AMORSAÚDE', 
'AmorSaúde (Central Ribeirão Preto)')
and cb."data" between '2023-03-01' and '2023-03-06'
group by cb."data" 
order by cb."data" desc