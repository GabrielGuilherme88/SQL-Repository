--Query a ser utilizada
select distinct
sp.nome_paciente, sp.cpf, sp.sexo as Binário_sexo, 
case when sp.sexo = 1 
		then 'Masculino'
	 when sp.sexo = 2 
	 	then 'Feminino' 
	end as Sexo,
case when p.nome_pacote = 'CAMPANHA DA MULHER - PARTICULAR 2022 (CONSULTA + PAPANICOLAU)' 
		and sp.sexo = 1 then 'verificar'
	when p.nome_pacote = 'CAMPANHA DA MULHER - PARTICULAR 2022 (EXAMES)' 
		and sp.sexo = 1 then 'Verificar'
	end as validando_sexo,
date(sp.nascimento) as Nascimento,
c.unidade_id, u.nome_fantasia, u.regiao, p.nome_pacote, 
date(c.data_referencia) as Data_Referência, 
date_part(year, c.data_referencia) as Ano_referência
from stg_contas c
left join stg_conta_itens ci on ci.conta_id = c.id
left join stg_pacotes p on p.id = ci.pacote_id 
left join stg_pacientes sp on sp.id = c.conta_id
left join stg_unidades u on u.id = c.unidade_id 
where p.nome_pacote in ('CAMPANHA CHECK-UP 2022 - CDT', 'CAMPANHA CHECK-UP 2022 - PARTICULAR'
, 'CAMPANHA DA MULHER - PARTICULAR 2022 (CONSULTA + PAPANICOLAU)', 'CAMPANHA DA MULHER - PARTICULAR 2022 (EXAMES)')
and c.data_referencia between '2023-03-01' and '2023-03-31'
--Para validar a quantidade de pacotes por cpf > 2 na tabela
--and sp.cpf = '54540143034'
--group by sp.nome_paciente, sp.cpf, sp.sexo, Sexo,
--date(sp.nascimento),
--c.unidade_id, u.nome_fantasia, u.regiao, p.nome_pacote, 
--date(c.data_referencia),
--c.data_referencia
--having count(sp.cpf) > 2

--Pedido mês da mulher para março 2023
select distinct
sp.nome_paciente, sp.cpf, sp.sexo as Binário_sexo, 
case when sp.sexo = 1 
		then 'Masculino'
	 when sp.sexo = 2 
	 	then 'Feminino' 
	end as Sexo,
--case when p.nome_pacote = 'CAMPANHA DA MULHER - PARTICULAR 2022 (CONSULTA + PAPANICOLAU)' 
		--and sp.sexo = 1 then 'verificar'
	--when p.nome_pacote = 'CAMPANHA DA MULHER - PARTICULAR 2022 (EXAMES)' 
		--and sp.sexo = 1 then 'Verificar'
	--end as validando_sexo,
date(sp.nascimento) as Nascimento,
c.unidade_id, u.nome_fantasia, u.regiao, p.nome_pacote, 
date(c.data_referencia) as Data_Referência, rmcrm
date_part(year, c.data_referencia) as Ano_referência
from stg_contas c
left join stg_conta_itens ci on ci.conta_id = c.id 
left join stg_pacotes p on p.id = ci.pacote_id 
left join stg_pacientes sp on sp.id = c.conta_id
left join stg_unidades u on u.id = c.unidade_id 
where p.nome_pacote in ('Campanha Dia da Mulher 2023 - CDT', 'Campanha Dia da Mulher 2023 - PARTICULAR')
and date(c.data_referencia) between '2023-03-01' and '2023-03-31'


--Verificando nulos
--cpf nulo = 93
--sexo nulo = 29
select count(*)
from stg_contas c
left join stg_conta_itens ci on ci.conta_id = c.id 
left join stg_pacotes p on ci.pacote_id = p.id
left join stg_pacientes sp on sp.id = c.conta_id
left join stg_unidades u on u.id = c.unidade_id 
where p.nome_pacote in ('CAMPANHA CHECK-UP 2022 - CDT', 'CAMPANHA CHECK-UP 2022 - PARTICULAR'
, 'CAMPANHA DA MULHER - PARTICULAR 2022 (CONSULTA + PAPANICOLAU)', 'CAMPANHA DA MULHER - PARTICULAR 2022 (EXAMES)')
and date_part(year, c.data_referencia) = 2022
and sp.cpf is null

--Conferir pelo like se há mais campanhas cadastradas
select count(*), p.nome_pacote 
from stg_pacotes p
where p.nome_pacote like 'CAMPANHA %'
group by p.nome_pacote

--AmorSaúde palmares está sem região
select * from stg_unidades su
where su.nome_fantasia = 'AmorSaúde Palmares'

-------Combo Check
--Query a ser utilizada
select distinct
sp.nome_paciente, sp.cpf, sp.sexo,
date(sp.nascimento) as Nascimento,
c.unidade_id, u.nome_fantasia, u.regiao, p.nome_pacote, 
date(c.data_referencia) as Data_Referência, 
date_part(year, c.data_referencia) as Ano_referência
from stg_contas c
left join stg_conta_itens ci on ci.conta_id = c.id 
left join stg_pacotes p on p.id = ci.pacote_id 
left join stg_pacientes sp on sp.id = c.conta_id
left join stg_unidades u on u.id = c.unidade_id 
where p.nome_pacote = 'VOUCHER SAÚDE DO HOMEM  (FRANQUEADORA AMORSAUDE)'
and c.data_referencia between '2023-04-01' and current_date
--Para validar a quantidade de pacotes por cpf > 2 na tabela
--and sp.cpf = '54540143034'
--group by sp.nome_paciente, sp.cpf, sp.sexo, Sexo,
--date(sp.nascimento),
--c.unidade_id, u.nome_fantasia, u.regiao, p.nome_pacote, 
--date(c.data_referencia),
--c.data_referencia
--having count(sp.cpf) > 2

select * from stg_pacotes sp
--where sp.nome_pacote = 'VOUCHER SAÚDE DO HOMEM (FRANQUEADORA AMORSAUDE)'

