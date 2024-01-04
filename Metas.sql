
select * from stg_metas sm 
where sm.mesano = 'Março2023'

--busca o mês ano mais recente do ano de 2023. ->para verificar se subiu a planilha de metas
select sm.mesano , sum(sm."meta de exames e procedimentos")  
from stg_metas sm
where sm.ano = '2023.0'
group by sm.mesano
order by sm.mesano asc