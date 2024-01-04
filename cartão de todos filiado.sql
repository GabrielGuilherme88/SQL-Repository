select  max(cast(f.data_ultima_desfiliacao as date)), 
f.idade, f.meses_inadimplentes , f.cidade , f.motivo_desfiliacao ,
count(*) as qtde, f.matricula
from pdgt_cartaodetodos_filiado.fl_filiado f
where f.flag_desfiliado = 1
and f.flag_titular = 1
group by cast(f.data_prospeccao as date), 
f.idade, f.meses_inadimplentes , f.cidade , f.motivo_desfiliacao, f.matricula

with matricula_max_data as (
select max(cast(f.data_ultima_desfiliacao as date)) as ultima_desfiliacao , f.matricula
from pdgt_cartaodetodos_filiado.fl_filiado f
where f.flag_desfiliado = 1
and f.flag_titular = 1
group by f.matricula),
qtde_registro as (
select  f.idade, f.meses_inadimplentes , f.cidade , f.motivo_desfiliacao ,
count(*) as qtde, f.matricula as mat, f.sexo , cast(f.data_prospeccao as date) as data_prospeccao  
from pdgt_cartaodetodos_filiado.fl_filiado f
where f.flag_desfiliado = 1
and flag_titular = 1
group by cast(f.data_prospeccao as date), 
f.idade, f.meses_inadimplentes , f.cidade , f.motivo_desfiliacao, f.matricula, f.sexo , cast(f.data_prospeccao as date))
select * 
from matricula_max_data
inner join qtde_registro on mat = matricula


select max(f.data_ultima_desfiliacao) , f.cidade, count(*) as qtde
from pdgt_cartaodetodos_filiado.fl_filiado f
group by  f.cidade
order by f.cidade asc

select * 
from pdgt_cartaodetodos_filiado.fl_filiado f
--where f.flag_desfiliado = 1
where f.cpf = '08611974450'
limit 100
