select u.id, u.nome_fantasia from stg_unidades u
where u.id in (19957,
19671,
19350
)
order by u.nome_fantasia asc

select date(pp."data"), u.id as id_unidade, tp.id as id_tabela, count(pp.id) 
from stg_pacientes_pedidos_hist pp
left join stg_unidades u on pp.unidade_id = u.id
left join stg_unidades_regioes ur on u.regiao_id = ur.id
left join stg_pacientes pcts on pp.paciente_id = pcts.id
left join stg_tabelas_particulares tp on pcts.tabela_id = tp.id
group by date(pp."data"), u.id, tp.id
order by date(pp."data") desc
limit 10

