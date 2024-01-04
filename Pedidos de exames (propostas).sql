--Query buscando a profissional que fez o preenchimento do pedido de exames da paciente Silmara Nunes Da Silva De Jesus
select p.dataproposta, ur.descricao, u.nome_fantasia, pcts.nome_paciente, pcts.cpf, pcts.celular as Contato, tp.nome_tabela_particular, prof.nome_profissional, ps.nome_status, func.nome_funcionario, po.origem as origem 
from stg_propostas p
left join stg_unidades u on p.unidadeid = u.id
left join stg_unidades_regioes ur on u.regiao_id = ur.id
left join stg_pacientes pcts on p.pacienteid = pcts.id
left join stg_tabelas_particulares tp on p.tabelaid = tp.id
left join stg_profissionais prof on p.profissionalid = prof.id
left join stg_propostas_status ps on p.staid = ps.id
left join stg_usuarios users on p.sys_user = users.id
left join stg_funcionarios func on users.id_relativo = func.id
left join stg_propostas_origem po on p.proposta_origem_id = po.id
where prof.nome_profissional  = 'Bruna Stefane Sampaio De Freitas'
and p.dataproposta = '2023-01-12'

--Query abaixo busca a paciente Silmara Nunes Da Silva De Jesus da Bruna Stefane Sampaio de Freitas na tabela de Pacientes Pedidos
select spp."data" , sp.nome_paciente, sp.cpf  from stg_pacientes_pedidos spp
left join stg_pacientes sp on spp.paciente_id = sp.id 
where sp.cpf = '03739839562'
limit 10

--teste com o usuário da Gabi, onde foi montado pedidos de exames para ver se estão entrando corretamente
select p.dataproposta, ur.descricao, u.nome_fantasia, pcts.nome_paciente, pcts.cpf, pcts.celular as Contato, tp.nome_tabela_particular, prof.nome_profissional, ps.nome_status, func.nome_funcionario, po.origem as origem 
from stg_propostas p
left join stg_unidades u on p.unidadeid = u.id
left join stg_unidades_regioes ur on u.regiao_id = ur.id
left join stg_pacientes pcts on p.pacienteid = pcts.id
left join stg_tabelas_particulares tp on p.tabelaid = tp.id
left join stg_profissionais prof on p.profissionalid = prof.id
left join stg_propostas_status ps on p.staid = ps.id
left join stg_usuarios users on p.sys_user = users.id
left join stg_funcionarios func on users.id_relativo = func.id
left join stg_propostas_origem po on p.proposta_origem_id = po.id
where prof.nome_profissional  = 'Médica Gabriela Bouchabki'
and p.dataproposta = '2023-02-06'

-- Jamila Rosa Rui Salazar
select p.dataproposta, ur.descricao, u.nome_fantasia, pcts.nome_paciente, pcts.cpf, pcts.celular as Contato, tp.nome_tabela_particular, prof.nome_profissional, ps.nome_status, func.nome_funcionario, po.origem as origem 
from stg_propostas p
left join stg_unidades u on p.unidadeid = u.id
left join stg_unidades_regioes ur on u.regiao_id = ur.id
left join stg_pacientes pcts on p.pacienteid = pcts.id
left join stg_tabelas_particulares tp on p.tabelaid = tp.id
left join stg_profissionais prof on p.profissionalid = prof.id
left join stg_propostas_status ps on p.staid = ps.id
left join stg_usuarios users on p.sys_user = users.id
left join stg_funcionarios func on users.id_relativo = func.id
left join stg_propostas_origem po on p.proposta_origem_id = po.id
where p.dataproposta = '2023-02-06'
and pcts .cpf = '10781971721'
limit 100

select sum(tcrbh.totalpago)  from tb_consolidacao_receita_bruta_hist tcrbh 
where tcrbh .datapagamento between '2023-01-01' and '2023-01-31'
