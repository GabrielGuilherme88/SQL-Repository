select sta.sellerid, sta.details, su.nome_fantasia, su.id, su.regiao 
from stg_tef_autorizacao sta
left join stg_unidades su on su.id = sta.unidadeid
where su.nome_fantasia = 'AmorSaúde SP Capela do Socorro'

