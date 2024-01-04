--Base de pacientes para envio ao Cartão de TODOS
select p.nome_paciente,p.nascimento, p.cpf, p.email, p.celular, spe.cidade, spe.bairro, spe.estado, spe.logradouro,
spe.cep, spe.numero, spe.complemento
from stg_pacientes p
left join stg_paciente_endereco spe on spe.paciente_id  = p.id


select count(*)::float /
(select count(*)::float from stg_pacientes p)*100
	from stg_pacientes p
		where p.cpf is null
		
--Verificando duplicidade de ID's
select sp.id,count(sp.id) from stg_pacientes sp 
group by sp.id 
having count(sp.id) >1
		
select distinct * from stg_pacientes sp
where sp.id in (62931374, 64950571, 64950570)
order by sp.id asc

select * from stg_pacientes sp 
limit 1

