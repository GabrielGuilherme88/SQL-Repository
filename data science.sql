select sum(tcrbhf.total_recebido) from tb_consolidacao_receita_bruta_hist_final tcrbhf 
	where tcrbhf."data" between '2023-07-01' and '2023-07-31'

with agendamentos_status as (
	select date_trunc('month', ag.datadoatendimento) data, ag.id_unidade, 
	case when ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3) then 'Atendido' else 'Não compareceu' end status, 
	sum(ag.totalagendamentos) as qtd_agendamentos 
	from tb_consolidacao_agendamentos_hist ag
	group by date_trunc('month', ag.datadoatendimento), ag.id_unidade, status),
agendamentos as (
	select ags.data, ags.id_unidade, sum(ags.qtd_agendamentos) qtd_agendamentos
	from agendamentos_status ags
	group by ags.data, ags.id_unidade),
atendimentos as (
	select ags.data, ags.id_unidade, ags.qtd_agendamentos as qtd_atendimentos 
	from agendamentos_status ags
	where ags.status = 'Atendido'),
meses_inauguracao as (
	select ag.data, ag.id_unidade, months_between(ag.data, date_trunc('month', su.data_inauguracao)) as meses_inauguracao
	from agendamentos ag
	left join stg_unidades su on ag.id_unidade = su.id)
select cast(ag.data as date), cast(ag.id_unidade as int), ag.qtd_agendamentos, atd.qtd_atendimentos, mi.meses_inauguracao
from agendamentos ag
left join atendimentos atd on ag.data = atd.data and ag.id_unidade = atd.id_unidade
left join meses_inauguracao mi on mi.data = ag.data and mi.id_unidade = ag.id_unidade
where ag.data between '2021-01-01' and '2023-06-30'
order by ag.data
limit 10


with pront_assinado as (
select distinct sa.agendamento_id, 1 as assinado 
from stg_dc_pdf_assinados sdpa
left join stg_atendimentos_hist sa on sdpa.documento_id = sa.id 
where sdpa.tipo = 'ATENDIMENTO'
)
select ag."data" as data, U.id as id_unidade, prof.id as id_profissional, esp.id as id_especialidade, pac.cpf, count(agdts.agendamento_id) as atendimentos, sum(pront.assinado) as qtddocsassinados
from stg_agendamento_procedimentos agdts
      left join stg_locais L on agdts.local_id = L.id
      left join stg_unidades U on L.unidade_id = U.id
      left join stg_unidades_regioes ur on U.regiao_id = ur.id
      left join stg_procedimentos pro on agdts.procedimento_id = pro.id
      left join stg_agendamentos_hist ag on agdts.agendamento_id = ag.id
      left join stg_especialidades esp on ag.especialidade_id = esp.id
      left join stg_profissionais prof on ag.profissional_id = prof.id 
      left join stg_pacientes pac on ag.paciente_id = pac.id 
      left join pront_assinado pront on agdts.agendamento_id = pront.agendamento_id 
where ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
and pro.tipo_procedimento_id in (2, 9)
and ag.data between '2022-01-01' and current_date
group by ag."data", U.id, prof.id, esp.id, pac.cpf
limit 10


--BASE DE PROFISSIONAIS MÉDICOS PARA ANÁLISE DE PERFIL
with atendimento as (
	select 
		ag.id_profissional,
		ag.id_unidade,
		count(ag.id_agendamento) as qtd_atendimentos 
	from tb_consolidacao_agendamentos  ag 
	--where ag.datadoatendimento between '2023-04-01' and '2023-06-30'
	where ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
	and ag.id_especialidade = 96
	--and ag.id_unidade = 19794
	group by ag.id_profissional, ag.id_unidade),
propostas as (
	select 
		pp.profissionalid as id_profissional,
		pp.unidadeid id_unidade,
		count(pp.id) as qtd_propostas
	from stg_propostas pp
	--where dataproposta between '2023-04-01' and '2023-06-30'
	where pp.especialidade_id = 96
	group by pp.profissionalid, pp.unidadeid),
propostas_executadas as (
	select 
		pp.profissionalid as id_profissional,
		pp.unidadeid id_unidade,
		count(pp.id) as qtd_propostas_executadas
	from stg_propostas pp
	--where dataproposta between '2023-04-01' and '2023-06-30'
	where pp.especialidade_id = 96
	and pp.staid = 5
	group by pp.profissionalid, pp.unidadeid),
infos_profissionais as (
	select 
		spu.profissional_id as id_profissional,
		count( distinct spu.unidade_id) as qtd_unidades,
		case when count(spu.unidade_id) > 1 then 1 else 0 end multiplas_unidades,
		spe.qtd_especialidades,
		spe.multiplas_especialidades
	from stg_profissionais_unidades spu
	join (select 
			spe.profissional_id as id_profissional,
			count( distinct spe.especialidade_id) as qtd_especialidades,
			case when count(spe.especialidade_id) > 1 then 1 else 0 end multiplas_especialidades
		  from stg_profissional_especialidades spe
		  where spe.especialidade_id = 96 --filtrando apenas cardio
		  group by spe.profissional_id) spe on spu.profissional_id = spe.id_profissional
	group by spu.profissional_id, spe.qtd_especialidades, spe.multiplas_especialidades)
select
	sp.id as id_profissional,
	--spu.unidade_id, --retirado para diminuir a granularidade da analise num primeiro momento
	--su.nome_fantasia nome_unidade, --retirado para diminuir a granularidade da analise num primeiro momento
	sr.descricao,
	sp.nome_profissional,
	datediff(year, sp.nascimento, getdate()) as idade,
	datediff(year, sp.sys_date, getdate()) as anos_empresa,
	datediff(month, sp.sys_date, getdate()) as meses_empresa,
	sp.sexo_id,
	ss.nomesexo sexo,
	sp.sys_active,
	sum(att.qtd_atendimentos) as total_atendimentos,
	sum(pp.qtd_propostas) as total_propostas,
	sum(pe.qtd_propostas_executadas) as total_executada,
	sum(pe.qtd_propostas_executadas) / sum(pp.qtd_propostas)::float as conversao_propostas,
	sum(pp.qtd_propostas)/ sum(att.qtd_atendimentos)::float as conversao_atendimento
from stg_profissionais sp
join stg_profissionais_unidades spu on spu.profissional_id = sp.id
join stg_unidades su on su.id = spu.unidade_id 
join stg_sexo ss on sp.sexo_id = ss.id
join atendimento att on att.id_profissional = sp.id and spu.unidade_id = att.id_unidade
join propostas pp on pp.id_profissional = sp.id and spu.unidade_id = pp.id_unidade
join propostas_executadas pe on pe.id_profissional = sp.id and spu.unidade_id = pe.id_unidade
join stg_unidades_regioes sr on sr.id = su.regiao_id 
join infos_profissionais ip on sp.id = ip.id_profissional
group by 
sp.id,
	--spu.unidade_id, --retirado para diminuir a granularidade da analise num primeiro momento
	--su.nome_fantasia nome_unidade, --retirado para diminuir a granularidade da analise num primeiro momento
	sr.descricao,
	sp.nome_profissional,
	datediff(year, sp.nascimento, getdate()),
	datediff(year, sp.sys_date, getdate()) ,
	datediff(month, sp.sys_date, getdate()),
	sp.sexo_id,
	ss.nomesexo,
	sp.sys_active
	
select * from stg_propostas pp
	--where dataproposta between '2023-04-01' and '2023-06-30'
	where pp.especialidade_id = 96
	and pp.staid = 5
	limit 10
	
select sp.profissionalid, spg.nomegrupo, sum(sp.valor), count(*),  
sum(sp.valor)/count(*) as ticket_propostas
from stg_propostas sp 
left join stg_itens_proposta sip on sip.proposta_id = sp.id 
left join stg_procedimentos sp2 on sp2.id = sip.item_id
left join stg_procedimentos_grupos spg on spg.id = sp2.grupo_procedimento_id
where sip.item_id > 0
and sp.staid = 5
and sp.profissionalid > 0
group by sp.profissionalid, spg.nomegrupo


select * from stg_unidades su