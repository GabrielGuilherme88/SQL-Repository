--Tabela de propostas, verificando a qtde de especialidades com id null
select count(*)::float /
(select count(*)::float from stg_propostas sp
	where sp.dataproposta between '2023-03-01' and '2023-03-14')*100
	from stg_propostas sp
		where sp.especialidade_id is null
			and sp.dataproposta between '2023-03-01' and '2023-03-14'

select sp2.nome_paciente , sp2.cpf , sp.tituloitens , sp.dataproposta, su.nome_fantasia, se.nome_especialidade, spo.origem, sum(sp.valor) as valor  from stg_propostas sp
left join stg_pacientes sp2 on sp2.id  = sp.pacienteid
left join stg_unidades su on su.id = sp.unidadeid
left join stg_especialidades se on se.id = sp.especialidade_id
left join stg_propostas_origem spo on spo.id = sp.proposta_origem_id 
where sp.dataproposta between '2023-02-01' and '2023-03-14'
and sp.especialidade_id is null 
--and sp2.nome_paciente = 'Isabel Cristina Paschoalino'
group by sp2.nome_paciente , sp2.cpf , sp.tituloitens , sp.dataproposta, su.nome_fantasia, se.nome_especialidade, spo.origem
order by sp2.nome_paciente asc




