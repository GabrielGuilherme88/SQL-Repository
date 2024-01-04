
select tcrbhf ."data" , sum(tcrbhf.total_recebido) as total_recebido 
from tb_consolidacao_receita_bruta_hist_final tcrbhf 
left join stg_unidades su on su.id = tcrbhf .id_unidade 
where tcrbhf ."data" between '2023-02-01' and current_date
and su.nome_fantasia = 'AmorSaúde Ribeirão Preto'
group by tcrbhf ."data"
order by tcrbhf ."data" desc



