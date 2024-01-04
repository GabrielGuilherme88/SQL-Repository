--
select sp3.nome_paciente , sp2.id , sp.profissionalid ,sp2.nome_profissional , su.nome_fantasia, sp.dataproposta as data, su.id as id_unidade, 
sp.profissionalid as id_profissional, sp.tabelaid as id_tabela, spo.origem, 
count(distinct sp.id) as TotalPedidos, sum(sp.valor) as ValorTotalPedidos 
from stg_propostas sp
left join stg_unidades su on sp.unidadeid = su.id
left join stg_propostas_origem spo on sp.proposta_origem_id = spo.id
left join stg_profissionais sp2  on sp.profissionalid = sp2.id
left join stg_pacientes sp3  on sp.pacienteid = sp3.id 
where sp.valor < 5000
and su.nome_fantasia = 'AmorSaúde Nossa Senhora do Socorro'
and sp.dataproposta between '2023-02-01' and '2023-02-08'
and sp3.cpf = '26510162504'
group by sp.dataproposta, su.id, sp.profissionalid, sp.tabelaid, spo.origem, sp2.nome_profissional, su.nome_fantasia, sp3.nome_paciente, sp2.id , sp.profissionalid
--and sp2.nome_profissional = 'Marcos Hernani Silva Santos'

--Busca os pacientes com propostas de exames que o nome profissional está em branco
select sp2.nome_profissional, spo.origem, sp3.nome_paciente , sp3.cpf ,
count(distinct sp.id) as TotalPedidos, sum(sp.valor) as ValorTotalPedidos 
from stg_propostas sp
left join stg_unidades su on sp.unidadeid = su.id
left join stg_propostas_origem spo on sp.proposta_origem_id = spo.id
left join stg_profissionais sp2  on sp.profissionalid = sp2.id
left join stg_pacientes sp3 on sp.pacienteid = sp3.id
where sp.valor < 5000
and su.nome_fantasia = 'AmorSaúde Nossa Senhora do Socorro'
and sp.dataproposta between '2023-02-01' and '2023-02-08'
and sp2.nome_profissional is null
group by sp2.nome_profissional, spo.origem, sp3.nome_paciente , sp3.cpf
order by sp3.nome_paciente

--and sp2.nome_profissional = 'Marcos Hernani Silva Santos'


--conta o total de profissionais com mais de 1 ids
select prof.nome_profissional, count(prof.id) 
from stg_profissionais prof
left join stg_profissional_especialidades pe on pe.profissional_id = prof.id
left join stg_especialidades es on pe.especialidade_id = es.id
left join stg_profissionais_unidades pu on pu.profissional_id = prof.id
left join stg_unidades u on pu.unidade_id = u.id
where prof.sys_active = 1
and prof.ativo = 'on'
group by prof.nome_profissional
order by count(prof.id) desc

-- Query Original dw_pedidos_de_exames_propostas
select sp.dataproposta as data, su.id as id_unidade, sp.profissionalid as id_profissional, sp.tabelaid as id_tabela, spo.origem, count(distinct sp.id) as TotalPedidos, sum(sp.valor) as ValorTotalPedidos 
from stg_propostas sp
left join stg_unidades su on sp.unidadeid = su.id
left join stg_propostas_origem spo on sp.proposta_origem_id = spo.id
where sp.valor < 5000
group by sp.dataproposta, su.id, sp.profissionalid, sp.tabelaid, spo.origem

--modificada para trazer o profissional
select sp.dataproposta as date, sp2.nome_profissional, su.id as id_unidade, 
sp.profissionalid as id_profissional, sp.tabelaid as id_tabela, spo.origem, 
count(distinct sp.id) as TotalPedidos, sum(sp.valor) as ValorTotalPedidos 
from stg_propostas sp
left join stg_unidades su on sp.unidadeid = su.id
left join stg_propostas_origem spo on sp.proposta_origem_id = spo.id
left join stg_profissionais sp2  on sp.profissionalid = sp2.id
where sp.valor < 5000
group by sp.dataproposta, su.id, sp.profissionalid, sp.tabelaid, spo.origem, sp2.nome_profissional
limit 5

--query original tb_pedidos_exames_propostas
select sp.dataproposta as data, su.id as id_unidade, sp.profissionalid as id_profissional, sp.tabelaid as id_tabela, spo.origem, count(distinct sp.id) as TotalPedidos, sum(sp.valor) as ValorTotalPedidos 
from stg_propostas sp
left join stg_unidades su on sp.unidadeid = su.id
left join stg_propostas_origem spo on sp.proposta_origem_id = spo.id
where sp.valor < 5000
group by sp.dataproposta, su.id, sp.profissionalid, sp.tabelaid, spo.origem

--query modificada para trazer o funcionário tb_pedidos_exames_propostas
select sp.dataproposta as data, su.id as id_unidade, sp.profissionalid as id_profissional, sp.tabelaid as id_tabela, spo.origem, 
sp2.nome_profissional as Profissional,
count(distinct sp.id) as TotalPedidos, sum(sp.valor) as ValorTotalPedidos 
from stg_propostas sp
left join stg_unidades su on sp.unidadeid = su.id
left join stg_propostas_origem spo on sp.proposta_origem_id = spo.id
left join stg_profissionais sp2 on sp.profissionalid = sp2.id 
where sp.valor < 5000
group by sp.dataproposta, su.id, sp.profissionalid, sp.tabelaid, spo.origem, sp2.nome_profissional