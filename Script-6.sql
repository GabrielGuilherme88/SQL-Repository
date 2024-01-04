select 
	distinct sp.id as id_profissional_grade
from
	stg_grade_fixa sgf
left join stg_profissionais sp on sp.id = sgf.profissionalid
where
	1 = 1
	and sp.sys_active = 1
	and sp.ativo = 'on'
	and sgf.fim_vigencia between current_date -1 and date('2030-12-31')
	-- pega todas as grades com fim de vigencia (em aberto) a partir de hoje até o futuro
	and sgf.inicio_vigencia between current_date - 1 and date('2030-12-31')
		-- pega profissionais que tiveram alguma grade aberta em 60 dias com a data corrente de hoje
	and sp.id = 503578
	
	
	select 
	distinct sp.id as id_profissional_grade_periodo
from
	stg_grade_periodo sgp
left join stg_profissionais sp on	sp.id = sgp.profissional_id
where
	1 = 1
	and sp.sys_active = 1
	and sp.ativo = 'on'
	and sgp.data_de between current_date -1 and date('2030-12-31')
	--pega todas as grades com fim de vigencia (em aberto) a partir de hoje até o futuro
	and sgp.data_ate between current_date - 1 and date('2030-12-31')
	and sp.id = 503578
	
	select
	prof.id as id_profissional_futuro,
	count(*) as qtde
from
	stg_agendamento_procedimentos ap
left join stg_agendamentos ag on ap.agendamento_id = ag.id
left join stg_profissionais prof on	ag.profissional_id = prof.id
left join stg_especialidades esp on	ag.especialidade_id = esp.id
left join stg_procedimentos pro on	ap.procedimento_id = pro.id
left join stg_procedimentos_tipos sprot on	pro.tipo_procedimento_id = sprot.id
where
	1 = 1
	and ag."data" between current_date - 60 and date('2030-01-01')
		--and sprot.id in (2, 9) --retirando consulta e retorno
	and ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
	and prof.id = 503578
	group by
		prof.id
		
		
		
