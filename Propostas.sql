select especialidade_id from stg_propostas_hist sph
limit 100

select count(*)::float /
(select count(*)::float from stg_propostas_hist sph)*100
	from stg_propostas_hist sph
		where sph.especialidade_id is null
		
		select count(*)::float /
(select count(*)::float from stg_propostas sph)*100
	from stg_propostas sph
		where sph.especialidade_id is null
		
select sp.id, sp.nome_paciente, sp.cpf, sp.celular, sp.email , sp.nascimento , sp.sexo , sp.sys_active ,count(sp.id)
from stg_pacientes sp
group by sp.nome_paciente, sp.cpf, sp.celular, sp.email , sp.nascimento , sp.sexo , sp.sys_active, sp.id
having count(sp.id)  > 1

select sp.id ,count(sp.id) as qtde from stg_pacientes sp
group by sp.id
having count(sp.id)  > 1
