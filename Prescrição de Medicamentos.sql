
select cast(data as date), count(*) from (
with memed as (
	select u.id as id_unidade,
		mp."data", 		
		1 as qtd_prescricoes,	
		'Memed' as origem,		
		es.id as id_especialidade,		
		prof.id as id_profissional		
from stg_memed_prescricoes mp
		inner join stg_agendamentos ag on mp.agendamento_id = ag.id		
		left join stg_profissionais prof on ag.profissional_id = prof.id		
		left join stg_especialidades es on ag.especialidade_id = es.id		
		left join stg_locais l on ag.local_id = l.id		
		left join stg_unidades u on l.unidade_id = u.id		
where mp."data" is not null
and es.id not in (201, 193, 167, 188, 192, 234)
group by u.id, mp."data", origem, es.id, prof.id),
feegow as (	
	select 
		u.id as unidade_id, 		
		pph."data", 		
		count(pph.id) as qtd_prescricoes, 
		'Feegow' as origem,		
		es.id as id_especialidade,		
		prof.id as id_profissional		
from stg_pacientes_prescricoes_hist pph
		inner join stg_atendimentos att on pph.atendimento_id = att.id		
		inner join stg_agendamentos ag on att.agendamento_id = ag.id		
		left join stg_unidades u on att.unidade_id = u.id		
		left join stg_profissionais prof on ag.profissional_id = prof.id		
		left join stg_especialidades es on ag.especialidade_id = es.id
where es.id not in (201, 193, 167, 188, 192, 234)
group by u.id, pph."data", origem, es.id, prof.id)
select * from memed
union all
select * from feegow)
where data between '2023-07-01' and current_date
group by cast(data as date)



select count(*), cast(data as date) from (
select u.id as id_unidade,
		mp."data", 		
		1 as qtd_prescricoes,	
		'Memed' as origem,		
		es.id as id_especialidade,		
		prof.id as id_profissional		
from stg_memed_prescricoes mp
		inner join stg_agendamentos ag on mp.agendamento_id = ag.id		
		left join stg_profissionais prof on ag.profissional_id = prof.id		
		left join stg_especialidades es on ag.especialidade_id = es.id		
		left join stg_locais l on ag.local_id = l.id		
		left join stg_unidades u on l.unidade_id = u.id	)
	group by cast(data as date)
	
	
--contagem da quantidade de registro onde há id de memed	
select count(*), cast(spp.data as date)
from stg_pacientes_prescricoes spp
where spp.memed_id is not null
and cast(spp.data as date) between '2023-07-01' and current_date 
group by cast(spp.data as date)
	
	
	