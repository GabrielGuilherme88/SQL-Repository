--UNION para unir ambas as querys
select * from (select 'Funcionários' as Pertence_a_Tabela, sf.nome_funcionario , sf.cpf , sf.nascimento, su.nome_fantasia as Unidade, su.estado, su.regiao, su.nome_unidade, su.cidade
from stg_funcionarios sf 
left join stg_funcionarios_unidades sfu  on sfu.funcionario_id = sf.id
left join stg_unidades su on su.id = sfu.unidade_id 
where su.estado in ('AC','ES','PE','PB','AL','RJ','RN','DF','SE','AM','AP','BA','CE','GO','MA','MG','MS','MT','PA','PI','PR','RO','RR','RS','SC','TO','SP')
and sf.sys_active = 1
and sf.ativo = 'on'
group by sf.nome_funcionario , sf.cpf , sf.nascimento, su.nome_fantasia, su.estado, su.regiao, su.nome_unidade, su.cidade
having count(sf.cpf) >=2)
union
select * from (select 'Profissionais' as Pertence_a_Tabela, sp.nome_profissional, sp.cpf , sp.nascimento, su.nome_fantasia as Unidade, su.estado, su.regiao, su.nome_unidade, su.cidade
from stg_profissionais sp 
left join stg_profissionais_unidades spu on spu.profissional_id = sp.id
left join stg_unidades su on su.id = spu.unidade_id 
where su.estado in ('AC','ES','PE','PB','AL','RJ','RN','DF','SE','AM','AP','BA','CE','GO','MA','MG','MS','MT','PA','PI','PR','RO','RR','RS','SC','TO','SP')
group by sp.nome_profissional, sp.cpf , sp.nascimento, su.nome_fantasia, su.estado, su.regiao, su.nome_unidade, su.cidade
having count(sp.cpf) >=2)
order by cpf DESC

--query buscando funcionários
select 'Funcionários' as Pertence_a_Tabela, sf.nome_funcionario , sf.cpf , sf.nascimento, su.nome_fantasia as Unidade, su.estado, su.regiao, su.nome_unidade, su.cidade
from stg_funcionarios sf 
left join stg_funcionarios_unidades sfu  on sfu.funcionario_id = sf.id
left join stg_unidades su on su.id = sfu.unidade_id 
where su.estado in ('AC','ES','PE','PB','AL','RJ','RN','DF','SE','AM','AP','BA','CE','GO','MA','MG','MS','MT','PA','PI','PR','RO','RR','RS','SC','TO','SP')
and sf.sys_active = 1
and sf.ativo = 'on'
group by sf.nome_funcionario , sf.cpf , sf.nascimento, su.nome_fantasia, su.estado, su.regiao, su.nome_unidade, su.cidade
having count(sf.cpf) >=2
order by sf.cpf desc

--Query buscando Profissionais
select 'Profissionais' as Pertence_a_Tabela, sp.nome_profissional, sp.cpf , sp.nascimento, su.nome_fantasia as Unidade, su.estado, su.regiao, su.nome_unidade, su.cidade
from stg_profissionais sp 
left join stg_profissionais_unidades spu on spu.profissional_id = sp.id
left join stg_unidades su on su.id = spu.unidade_id 
where su.estado in ('AC','ES','PE','PB','AL','RJ','RN','DF','SE','AM','AP','BA','CE','GO','MA','MG','MS','MT','PA','PI','PR','RO','RR','RS','SC','TO','SP')
group by sp.nome_profissional, sp.cpf , sp.nascimento, su.nome_fantasia, su.estado, su.regiao, su.nome_unidade, su.cidade
having count(sp.cpf) >=2
order by sp.cpf desc
