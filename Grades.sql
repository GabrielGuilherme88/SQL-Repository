select
	min(hi.data) as data_grade,	
	u.id as id_unidade,	
	es.id as id_especialidade,	
	case		
		when es.id = 89 then 'Clínica médica'		
		when es.id in (128, 271, 96, 126, 129, 318) then 'Especialidades básicas'
				else 'Demais especialidades'		
	end grupo_especialidade,	
	case		
		when es.id = 89 then 2		
		when es.id in (128, 271, 96, 126, 129, 318) then 5		
		when es.id not in (89, 128, 271, 96, 126, 129, 318) then 7		
		else 7		
	end as meta_abertura_agenda,
	case
		when hi.data >= current_date then 
			(select min(hi.data) as dataf from stg_agenda_horarios_itens hi)
		end as datamaior,
	min(hi.data) - current_date dias_ate_prox_grade,	
	case 		
		when es.id = 89 and dias_ate_prox_grade >2 then 'Acima da meta'		
		when es.id in (128, 271, 96, 126, 129, 318) and dias_ate_prox_grade >5 then 'Acima da meta'		
		when es.id not in (89, 128, 271, 96, 126, 129, 318) and dias_ate_prox_grade >7 then 'Acima da meta'		
		else 'Dentro da meta'		
	end as classificacao	
	from stg_agenda_horarios_itens hi		
		left join stg_unidades u on hi.unidade_id = u.id		
		left join stg_unidades_regioes ur on u.regiao_id = ur.id		
		left join stg_agenda_horarios_itens_especialidades hie on hie.agenda_horarios_item_id = hi.ahcid		
		left join stg_especialidades es on hie.especialidade_id = es.id		
	where hi.hlivres >1	
	and hi."data" >= current_date	
	and hi."data" <= current_date+30	
	and es.nome_especialidade is not null	
	group by u.id, es.id, grupo_especialidade, meta_abertura_agenda, hi."data" 
	
	