select su.nome_fantasia , src.datareferencia  , round(sum(src.valorsplittotal),2) as totalsplit  from stg_royalties_contas src
left join stg_unidades su on src.unidadeid = su.id 
where su.nome_fantasia = 'AmorSaúde Franca'
and src.datareferencia between '2023-02-01' and '2023-02-16'
group by su.nome_fantasia , src.datareferencia
order by src.datareferencia asc