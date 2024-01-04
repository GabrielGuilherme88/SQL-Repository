--Agrupar a query para que o notebook consiga ler
--Base agrupada pelo CPF para realizar o agrupamento
with ultima_utilização as (
select sp.cpf as cpf1, max(tccarm.data_pagamento)
from tb_consolidacao_contas_a_receber_modelagem tccarm
left join stg_pacientes sp on sp.id = tccarm .id_paciente
left join stg_sexo ss on ss.id = sp.sexo
left join stg_paciente_endereco spe on spe.paciente_id = sp.id
where sp.cpf is not null or sp.cpf = ''
group by sp.cpf),
utilizacao as (
select sp.cpf, sp.nascimento ,  DATEDIFF(year, sp.nascimento, CURRENT_DATE) AS idade, 
ss.nomesexo , spe.cidade,
count(*) as qtde
from tb_consolidacao_contas_a_receber_modelagem tccarm
left join stg_pacientes sp on sp.id = tccarm .id_paciente
left join stg_sexo ss on ss.id = sp.sexo
left join stg_paciente_endereco spe on spe.paciente_id = sp.id
where sp.cpf is not null or sp.cpf = ''
group by sp.cpf , DATEDIFF(year, sp.nascimento, CURRENT_DATE), ss.nomesexo, sp.nascimento, spe.cidade)
select * from utilizacao
left join ultima_utilização on cpf = cpf1
where cpf = '53698662876'

with cpf_nulo as (
select count(*) as qtde
from tb_consolidacao_contas_a_receber_modelagem tccarm
left join stg_pacientes sp on sp.id = tccarm .id_paciente
left join stg_sexo ss on ss.id = sp.sexo
where sp.cpf is null),
cpf_full as (
select count(*) as qtde
from tb_consolidacao_contas_a_receber_modelagem tccarm
left join stg_pacientes sp on sp.id = tccarm .id_paciente
left join stg_sexo ss on ss.id = sp.sexo
where sp.cpf is not null)
select * from (
select * from cpf_nulo
union all
select * from cpf_full)


select count(sp.cpf) / 
	(select count(sp.cpf)
from tb_consolidacao_contas_a_receber_modelagem tccarm
left join stg_pacientes sp on sp.id = tccarm .id_paciente
left join stg_sexo ss on ss.id = sp.sexo
where sp.cpf is not null)::float*100 as percentual
from tb_consolidacao_contas_a_receber_modelagem tccarm
left join stg_pacientes sp on sp.id = tccarm .id_paciente
left join stg_sexo ss on ss.id = sp.sexo
where sp.cpf is null