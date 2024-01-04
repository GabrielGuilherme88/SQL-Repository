select sf.id, sf.nome_funcionario , sf.sys_user , sf.ativo , sf.sys_active, sf.nascimento, sf.cpf,
sf.celular , sf.estado , sf.cidade , sf.centro_custo_id , sf.setor_colaborador , sf.cargo_colaborador_unidade,
sf.sexo_id, su.nome_fantasia, su.regiao 
from stg_funcionarios sf
left join stg_funcionarios_unidades sfu on sfu.funcionario_id = sf.id
left join stg_unidades su on su.id = sfu.unidade_id 
limit 10

--query para a Juliana do RH verificar os campos
select sf.id, sf.nome_funcionario , sf.sys_user , sf.ativo , sf.sys_active, sf.nascimento, sf.cpf,
sf.celular , sf.estado , sf.cidade , sf.centro_custo_id , sf.setor_colaborador , sf.cargo_colaborador_unidade,
sf.sexo_id, su.nome_fantasia, su.regiao 
from stg_funcionarios sf
left join stg_funcionarios_unidades sfu on sfu.funcionario_id = sf.id
left join stg_unidades su on su.id = sfu.unidade_id
group by sf.id, sf.nome_funcionario , sf.sys_user , sf.ativo , sf.sys_active, sf.nascimento, sf.cpf,
sf.celular , sf.estado , sf.cidade , sf.centro_custo_id , sf.setor_colaborador , sf.cargo_colaborador_unidade,
sf.sexo_id, su.nome_fantasia, su.regiao 
having count(sf.nome_funcionario) < 10

--query para ver o volume de registros por nome
select sf.nome_funcionario ,count(*) 
from stg_funcionarios sf
left join stg_funcionarios_unidades sfu on sfu.funcionario_id = sf.id
left join stg_unidades su on su.id = sfu.unidade_id
group by sf.nome_funcionario
having count(*) < 10
order by count(*) desc

--retirando unidades da base de funcionários para diminiur a granularidade
select * from stg_funcionarios sf
limit 10


--modelagem criada para aliemntar o metabase Funcionários Ativos Unidades
--Solicitação Marjorie
with funcionarios as (
select sf.id as func_id, sf.nome_funcionario, sf.nascimento, 
sf.cpf, sf.setor_colaborador, sf.cargo_colaborador_unidade,
su.id as unidadeid, su.nome_fantasia 
from stg_funcionarios sf
left join stg_funcionarios_unidades sfu on sfu.funcionario_id = sf.id
left join stg_unidades su on su.id = sfu.unidade_id
and sf.sys_active =1 and sf.ativo = 'on'),
funcionarios_central as (
select sf.id as profissional_id_central
from stg_funcionarios sf
left join stg_funcionarios_unidades sfu on sfu.funcionario_id = sf.id
left join stg_unidades su on su.id = sfu.unidade_id
where su.id in (0, 19774, 19793))
select * from funcionarios f
where func_id not in (select profissional_id_central
						from funcionarios_central)


--é possível normalizar o cpf retirando os pontos e traços
select 
REPLACE(REPLACE(sf.cpf, '.', ''), '-', '') AS cpf_sem_pontos from stg_funcionarios sf 
where sf.id = 169778
