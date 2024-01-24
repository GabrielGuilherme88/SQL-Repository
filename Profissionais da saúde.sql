select
	sp.nome_profissional ,
	sp.cpf ,
	count(*)
from
	todos_data_lake_trusted_feegow.profissionais sp
where
	sp.sys_active = 1
group by
	sp.cpf,
	sp.nome_profissional
order by
	count(*) desc
	--verificar quantos profissionais estão com CPF nulo
	
select
	*
from
	todos_data_lake_trusted_feegow.profissionais sp
where
	sp.cpf is null
	--query para buscar profissionais com cpf >2
select
	sp. id,
	sp.nome_profissional,
	sp.cpf,
	sp.documento_conselho,
	scp.descricao,
	sp.rqe,
	spe2.estado
from
	todos_data_lake_trusted_feegow.profissionais sp
	--left join todos_data_lake_trusted_feegow.profissional_especialidades spe on spe.profissional_id = sp.id
	--left join todos_data_lake_trusted_feegow.especialidades se on se.id = spe.especialidade_id
left join todos_data_lake_trusted_feegow.profissional_enderecos spe2 on
	spe2.profisional_id = sp.id
left join todos_data_lake_trusted_feegow.conselhos_profissionais scp on
	scp.id = sp.conselho_id
where
	sp.sys_active = 1
	and sp.cpf in (
	select
		sp2.cpf
	from
		todos_data_lake_trusted_feegow.profissionais sp2
	where
		sp2.sys_active = 1
	group by
		sp2.cpf
	having
		count(sp2.cpf) >= 2)
order by
	sp.cpf
	--Demais campos nulos




--modelagem criada para a Marjorie por solicitação do CREMESP
select
	sp.id as id_profissional,
	sp.nome_profissional,
	sp.cpf,
	se.nome_especialidade,
	sp.rqe,
	sp.observacoes,
	scp.descricao,
	spe.uf_conselho,
	spe.documento_conselho as CRM,
	su.id as id_unidade,
	spu.unidade_id,
	su.nome_fantasia,
	sur.descricao as regiao_franquia
from
	todos_data_lake_trusted_feegow.profissionais sp
left join todos_data_lake_trusted_feegow.profissional_enderecos spe2 on
	spe2.profisional_id = sp.id
left join todos_data_lake_trusted_feegow.conselhos_profissionais scp on
	scp.id = sp.conselho_id
left join todos_data_lake_trusted_feegow.profissional_especialidades spe on
	spe.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.especialidades se on
	se.id = spe.especialidade_id
left join todos_data_lake_trusted_feegow.profissionais_unidades spu on
	spu.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.unidades su on
	su.id = spu.unidade_id
left join todos_data_lake_trusted_feegow.unidades_regioes sur on
	sur.id = su.regiao_id
where
	1 = 1
	and sp.sys_active = 1
	--ativo banco
	and sp.ativo = 'on'
	--ativo interface
	--and sur.descricao in ('SP CAV', 'SP Interior')
	and sp.nome_profissional = 'Jesus Da Cunha Garcia'
	and su.id = 19682
	--and su.id not in (19774, 0, 19793)
	--validando o cadastro de RQE do profissional
	--query no metabase alimentando (CURITIBA) CREMESP - Profissionais Ativos Unidades
	
	
	
	
	
select
	distinct 
sp.id as id_profissional,
	sp.nome_profissional,
	sp.ativo,
	sp.sys_active,
	sp.nascimento,
	sp.conselho_id,
	sp.nascimento,
	sp.cpf,
	sp.documento_conselho,
	scp.descricao,
	spe.conselho,
	spe.uf_conselho,
	spe.documento_conselho,
	spe.rqe,
	se.nome_especialidade,
	su.nome_fantasia
from
	todos_data_lake_trusted_feegow.profissionais sp
left join todos_data_lake_trusted_feegow.profissional_especialidades spe on
	spe.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.especialidades se on
	se.id = spe.especialidade_id
left join todos_data_lake_trusted_feegow.conselhos_profissionais scp on
	scp.id = sp.conselho_id
left join todos_data_lake_trusted_feegow.profissionais_unidades spu on
	spu.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.unidades su on
	su.id = spu.unidade_id
where
	1 = 1
	and sp.sys_active <> 1 --filtro pegando inativos (só alterar)
	and sp.ativo <> 'on' --filtro pegando inativos
	and su.id = 19682
	
	
	
	
	
select
	count(*),
	spe.rqe
from
	todos_data_lake_trusted_feegow.profissional_especialidades spe
group by
	spe.rqe
	--validando se profissionais_unidades está sendo atualizada conforme profissionais_unidades
select
	distinct *
from
	todos_data_lake_trusted_feegow.profissionais sp
left join todos_data_lake_trusted_feegow.profissionais_unidades spu on
	spu.profissional_id = sp.id
where
	sp.nome_profissional = 'Maximilian Porley Hornos Dos Santos'
	--modelagem criada para a Marjorie por solicitação do CREMESP
select
	distinct sgf.inicio_vigencia,
	sgf.fim_vigencia,
	sp.id as id_profissional,
	sp.nome_profissional,
	sp.cpf,
	se.nome_especialidade,
	sgf.hora_de,
	sgf.hora_ate,
	sgf.dia_semana,
	case
		when sgf.dia_semana = 1 then 'segunda_feira'
		when sgf.dia_semana = 2 then 'terça_feira'
		when sgf.dia_semana = 3 then 'quarta_feira'
		when sgf.dia_semana = 4 then 'quinta_feira'
		when sgf.dia_semana = 5 then 'sexta_feira'
		when sgf.dia_semana = 6 then 'sabado'
		when sgf.dia_semana = 7 then 'domingo'
		else 'validar_dia'
	end as semana,
	su.id as id_unidade,
	su.nome_fantasia,
	sur.descricao as regiao_franquia
from
	todos_data_lake_trusted_feegow.grade_fixa sgf
left join todos_data_lake_trusted_feegow.locais sl on
	sl.id = sgf.localid
left join todos_data_lake_trusted_feegow.unidades su on
	su.id = sl.unidade_id
left join todos_data_lake_trusted_feegow.profissionais sp on
	sp.id = sgf.profissionalid
left join todos_data_lake_trusted_feegow.conselhos_profissionais scp on
	scp.id = sp.conselho_id
left join todos_data_lake_trusted_feegow.profissional_especialidades spe on
	spe.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.especialidades se on
	se.id = spe.especialidade_id
left join todos_data_lake_trusted_feegow.profissionais_unidades spu on
	spu.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.unidades_regioes sur on
	sur.id = su.regiao_id
where
	1 = 1
	and sgf.fim_vigencia between current_date and '2030-01-01'
	and sur.descricao in ('SP CAV', 'SP Interior')
	and su.id not in (19774, 0, 19793)
order by
	sp.nome_profissional
	
	

	
------------------------------------------------------
	--modelagem de profissionais médicos colocando a extração do dhup e hora
select
	distinct sp.id,
	sp.nome_profissional,
	sp.nascimento,
	sp.cpf,
	sp.unidade_id,
	spe.rqe,
	scp.descricao,
	spe.uf_conselho,
	spe.documento_conselho,
	date(sp.dhup) as data_atualizacao,
	TO_CHAR(sp.dhup,
	'HH24:MI:SS') as hora_atualizacao
from
	todos_data_lake_trusted_feegow.profissionais sp
left join todos_data_lake_trusted_feegow.conselhos_profissionais scp on
	scp.id = sp.conselho_id
left join todos_data_lake_trusted_feegow.profissional_especialidades spe on
	spe.profissional_id = sp.id
where
	1 = 1
	and sp.sys_active = 1
	and sp.ativo = 'on'
order by
	sp.id
limit 10


------------------------------------------
------------------------------------------
------------------------------------------
------------------------------------------
--modelagem para inativação em massa
--verificar se há agendamento para o profissional
--não pode ter uma grade aberta ->fim de vigência deve ser
--cadastro criado a menos de 15 dias
--se ele está ativo sp.ativo = 'on' and sp.sysactivate = 1
--Profissionais que não possuem pacientes agendados em datas futuras; E
--Profissionais que não possuem grade vigente aberta para datas futuras; E
--Profissionais cujos cadastros foram criados há mais de 15 dias da data de referência da pesquisa;
--objeto criado para separ uma nova base com a quantidade de id por cpf do profissional
with qtde_cpf as (
select sp.cpf as id_cpf,
	count(distinct sp.id) as id_por_cpf_sysactive1
from
	todos_data_lake_trusted_feegow.profissionais sp
where sp.sys_active = 1	
and sp.ativo = 'on'
group by
	sp.cpf
),
--Objeto separa os profissionais e suas informações, com a seguinte regra: eles tem que estar dentro de uma faixa de
--15 dias desde o seu cadastro ou atualização cadastral
profissionais_data as (
select	distinct 
	sp.id,
	sp.nome_profissional ,
	sp.nascimento,
	sp.cpf,
	sp.unidade_id,
	scp.descricao,
	spe.uf_conselho,
	e.nome_especialidade,
	spe.rqe,
	sp.sys_active,
	sp.sys_user ,
	sp.ativo,
	qc.id_por_cpf_sysactive1,
	uu.nome_fantasia ,
	ur.descricao as regional,
	date(sp.dhup) as dhup,
	sp.sys_date as sys_date,
	sf.nome_funcionario,
	su.tipo_usuario 
from
	todos_data_lake_trusted_feegow.profissionais sp
left join todos_data_lake_trusted_feegow.conselhos_profissionais scp on	scp.id = sp.conselho_id
left join todos_data_lake_trusted_feegow.profissional_especialidades spe on	spe.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.especialidades e on	e.id = spe.especialidade_id
left join todos_data_lake_trusted_feegow.profissionais_unidades puu on	puu.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.unidades uu on	uu.id = puu.unidade_id
left join todos_data_lake_trusted_feegow.unidades_regioes ur on	ur.id = uu.regiao_id
left join qtde_cpf qc on	qc.id_cpf = sp.cpf
left join todos_data_lake_trusted_feegow.usuarios su on su.id = sp.sys_user
left join todos_data_lake_trusted_feegow.funcionarios sf on sf.id = su.id_relativo
	--left join com objeto qtde_cpf para identificar quantos cpf existem por profissional
where
	1 = 1
	and sp.id not in (
						select sp.id from todos_data_lake_trusted_feegow.profissionais sp 
						WHERE sp.dhup BETWEEN date_add('day', -30, current_date) AND date_add('day', -1, current_date)
						--where sp.dhup between current_date - 30 and current_date - 1) --retirar profissionais atualziados nos últimos 15 dias (d-1)
	and sp.sys_active = 1
	and sp.ativo = 'on'
	and uu.id not in (0, 19774, 19793)
	--faixa de data de 15 dias do seu cadastro
)),
-- O objeto abaixo separa os agendamentos futuros dos profissionais contando os agendamentos ocorridos na data mais recente do banco (d-1) e
-- os futuros. Ou seja, caso o profissional tenha algum agendamento no futuro ou na data de hoje(d-1) é considerado como ativo
atendimento_60d as (
select
	prof.id as id_profissional_futuro,
	count(*) as qtde
from
	todos_data_lake_trusted_feegow.agendamento_procedimentos ap
left join todos_data_lake_trusted_feegow.agendamentos ag on ap.agendamento_id = ag.id
left join todos_data_lake_trusted_feegow.profissionais prof on	ag.profissional_id = prof.id
left join todos_data_lake_trusted_feegow.especialidades esp on	ag.especialidade_id = esp.id
left join todos_data_lake_trusted_feegow.procedimentos pro on	ap.procedimento_id = pro.id
left join todos_data_lake_trusted_feegow.procedimentos_tipos sprot on	pro.tipo_procedimento_id = sprot.id
where
	1 = 1
	--and ag."data" between current_date - 60 and date('2030-01-01')
	AND ag."data" BETWEEN date_add('day', -60, current_date) AND date '2030-01-01'
	--and sprot.id in (2, 9) --retirando consulta e retorno
and ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
	group by
		prof.id
),
agendamento_futuro as (
select
	prof.id as id_profissional_futuro_agendamento,
	count(*) as qtde
from
	todos_data_lake_trusted_feegow.agendamento_procedimentos ap
left join todos_data_lake_trusted_feegow.agendamentos ag on ap.agendamento_id = ag.id
left join todos_data_lake_trusted_feegow.profissionais prof on	ag.profissional_id = prof.id
left join todos_data_lake_trusted_feegow.especialidades esp on	ag.especialidade_id = esp.id
left join todos_data_lake_trusted_feegow.procedimentos pro on	ap.procedimento_id = pro.id
left join todos_data_lake_trusted_feegow.procedimentos_tipos sprot on	pro.tipo_procedimento_id = sprot.id
where
	1 = 1
	--and ag."data" between current_date  and date('2030-01-01')
	AND ag."data" BETWEEN current_date AND date('2030-01-01')
	and sprot.id in (2, 9) --retirando consulta e retorno
	group by
		prof.id
),
grade_futuras_fixas as (
select 
	distinct sp.id as id_profissional_grade
from
	todos_data_lake_trusted_feegow.grade_fixa sgf
left join todos_data_lake_trusted_feegow.profissionais sp on sp.id = sgf.profissionalid
where
	1 = 1
	and sp.sys_active = 1
	and sp.ativo = 'on'
	--and sgf.inicio_vigencia between current_date - 1 and date('2030-12-31')
	-- pega profissionais que tiveram alguma grade aberta em 60 dias com a data corrente de hoje
	--and sgf.fim_vigencia between current_date -1 and date('2030-12-31')
	AND sgf.fim_vigencia BETWEEN date_add('day', -1, current_date) AND date '2030-12-31'
	-- pega todas as grades com fim de vigencia (em aberto) a partir de hoje até o futuro		
),
grade_futuras_periodo as (
select 
	distinct sp.id as id_profissional_grade_periodo
from
	todos_data_lake_trusted_feegow.grade_periodo sgp
left join todos_data_lake_trusted_feegow.profissionais sp on	sp.id = sgp.profissional_id
where
	1 = 1
	and sp.sys_active = 1
	and sp.ativo = 'on'
	--and sgp.data_de between current_date -1 and date('2030-12-31')
	--pega todas as grades com fim de vigencia (em aberto) a partir de hoje até o futuro
	--and sgp.data_ate between current_date - 1 and date('2030-12-31')
	AND sgp.data_ate BETWEEN date_add('day', -1, current_date) AND date '2030-12-31'
	-- pega profissionais que tiveram alguma grade aberta em 60 dias com a data corrente de hoje
),
--O objeto abaixo consolida os objetos acima, ou seja, faz o left join e retira-se qualquer informação em comum.
--Dessa forma temos todos os profissionais que não tiveram qualquer tipo de grade aberta no passado e no futuro
--Retira também qualquer profissional que não tem agendamento futuro
--Considera também qualquer profissional que tenha sido registrado ou atualizado na feegow nos últimosd 15 dias
resultado as (
select *
from
	profissionais_data pd
left join atendimento_60d ag on	ag.id_profissional_futuro = pd.id
left join agendamento_futuro af on af.id_profissional_futuro_agendamento = pd.id 
left join grade_futuras_fixas gf on	gf.id_profissional_grade = pd.id
left join grade_futuras_periodo gfpe on	gfpe.id_profissional_grade_periodo = pd.id
where
	1 = 1
	and id_profissional_futuro is null
	--retira os null -> tudo que não tem agendamento futuro
	and id_profissional_grade is null
	--retira os null -> tudo que não tem grade futura
	and id_profissional_grade_periodo is null
	--retira os null -> que não tem grade período
	and id_profissional_futuro_agendamento is null
)
--query com o objeto final já filtrado.
select
	id,
	nome_profissional,
	nascimento,
	cpf, 
	unidade_id,
	nome_fantasia
	descricao,
	uf_conselho,
	nome_especialidade,
	rqe,
	sys_active,
	sys_user,
	ativo,
	id_por_cpf_sysactive1,
	dhup,
	sys_date,
	nome_funcionario,
	tipo_usuario 
from
	resultado
where
	1 = 1
	--separar profissional para validação. O mesmo aparece na lista pois possui dois id diferentes para o mesmo cpf e também sysuser = 0 --conversar com a marjorie sobre o sys user = 0
and id not in
( --retirando profissionais que possuem a central como unidade cadastrada
select  distinct sp.id from todos_data_lake_trusted_feegow.profissionais sp
left join todos_data_lake_trusted_feegow.profissionais_unidades puu on	puu.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.unidades uu on	uu.id = puu.unidade_id
where uu.id in (0, 19774, 19793)
)
and id not in
( --retirando profissionais que tem a especialidade 256	Biomedicina 168	Enfermagem
select sp.id from todos_data_lake_trusted_feegow.profissionais sp
left join todos_data_lake_trusted_feegow.profissional_especialidades spe on	spe.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.especialidades e on	e.id = spe.especialidade_id
where e.id in (256, 168)
)
--and id = 503578
order by
	nome_profissional
	
	

	
--para validação
select
	*
from
	todos_data_lake_trusted_feegow.profissionais sp
left join todos_data_lake_trusted_feegow.profissional_especialidades spe on	spe.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.especialidades e on	e.id = spe.especialidade_id
where
	1 = 1
and sp.id = 513906



	
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
--validação
--olhando dentro da tabela de profissionais o comportamento	

	
	
--with verifica se há grades fixas abertas
select
	*
from
	todos_data_lake_trusted_feegow.grade_fixa sgf
left join todos_data_lake_trusted_feegow.profissionais sp on
	sp.id = sgf.profissionalid
where
	1 = 1
and sp.sys_user  = 1
and sp.ativo = 'on'
	and sgf.fim_vigencia between current_date -1 and '2030-12-31'
	-- pega todas as grades com fim de vigencia (em aberto) a partir de hoje até o futuro
	and sgf.inicio_vigencia between current_date - 60 and date('2030-12-31')
	and sp.nome_profissional = 'Adriana Cardoso Gonçalves'
order by
	sgf.datahora desc

	
	
	
--with verifica se há grades abertas 
select 
	*
from
	todos_data_lake_trusted_feegow.grade_periodo sgp
left join todos_data_lake_trusted_feegow.profissionais sp on
	sp.id = sgp.profissional_id
where
	1 = 1
and sp.ativo = 'on' and sp.sys_active = 1	
	and sgp.data_de between current_date -1 and date('2030-12-31')
	--pega todas as grades com fim de vigencia (em aberto) a partir de hoje até o futuro
	and sgp.data_ate between current_date - 60 and date('2030-12-31')
	and sp.nome_profissional = 'Adriana Cardoso Gonçalves'


	

	
--with que busca se há agendamento futuro
select
	*
from
	todos_data_lake_trusted_feegow.agendamento_procedimentos ap
left join todos_data_lake_trusted_feegow.agendamentos ag on
	ap.agendamento_id = ag.id
left join todos_data_lake_trusted_feegow.profissionais prof on
	ag.profissional_id = prof.id
left join todos_data_lake_trusted_feegow.especialidades esp on
	ag.especialidade_id = esp.id
left join todos_data_lake_trusted_feegow.procedimentos pro on
	ap.procedimento_id = pro.id
left join todos_data_lake_trusted_feegow.procedimentos_tipos sprot on
	pro.tipo_procedimento_id = sprot.id
where
	1 = 1
	and ag."data" between current_date - 60 and '2030-01-01'
	--and sprot.id in (2, 9) --não utilizar apenas consulta e retorno
	and prof.nome_profissional = 'ALANA GHINZELLI'
	


	
-- wich que busca as informações dos profissionais	
select
	distinct sp.id,
	sp.nome_profissional ,
	sp.nascimento,
	sp.cpf,
	sp.unidade_id,
	uu.nome_fantasia,
	sur.descricao as unidade_regiao,
	date(sp.dhup) as data_atualizacao,
	TO_CHAR(sp.dhup,
	'HH24:MI:SS') as hora_atualizacao
from
	todos_data_lake_trusted_feegow.profissionais sp
left join todos_data_lake_trusted_feegow.conselhos_profissionais scp on
	scp.id = sp.conselho_id
left join todos_data_lake_trusted_feegow.profissional_especialidades spe on
	spe.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.especialidades e on
	e.id = spe.especialidade_id
left join todos_data_lake_trusted_feegow.profissionais_unidades puu on
	puu.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.unidades uu on
	uu.id = puu.unidade_id
left join todos_data_lake_trusted_feegow.unidades_regioes sur on
	sur.id = uu.regiao_id
where
	1 = 1
	and sp.dhup between current_date - 16 and current_date - 1
	--faixa de data de 15 dias do seu cadastro
	and sp.nome_profissional = 'Adriana Cardoso Gonçalves'
	
SELECT * FROM todos_data_lake_trusted_feegow.unidades
	
--demanda do CRM	
--para separar os profissionais por ; com a função listagg	
	select
	sp.id,
	sp.nome_profissional ,
	sp.nascimento,
	sp.cpf,
	sp.email1,
	sp.celular1, 
	spe2.cidade,
	spe2.estado,
	spe2.bairro,
	spe2.endereco,
	spe2.cep,
	spe2.numero,
	spe2.complemento, 
	listagg (distinct e.nome_especialidade , '; ') as especialidade,
	listagg(uu.id, '; ') as unidade_id,
	listagg(uu.nome_fantasia, '; ') as nome_fantasia
from
	todos_data_lake_trusted_feegow.profissionais sp
left join todos_data_lake_trusted_feegow.conselhos_profissionais scp on scp.id = sp.conselho_id
left join todos_data_lake_trusted_feegow.profissional_especialidades spe on spe.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.profissional_enderecos spe2 on spe2.profisional_id = sp.id
left join todos_data_lake_trusted_feegow.especialidades e on e.id = spe.especialidade_id
left join todos_data_lake_trusted_feegow.profissionais_unidades puu on	puu.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.unidades uu on uu.id = puu.unidade_id
left join todos_data_lake_trusted_feegow.unidades_regioes sur on sur.id = uu.regiao_id
where 1=1
and sp.sys_active = 1 and sp.ativo = 'on'
group by sp.id,
	sp.nome_profissional ,
	sp.nascimento,
	sp.cpf,
	sp.email1,
	sp.celular1,
	spe2.cidade,
	spe2.estado,
	spe2.bairro,
	spe2.endereco,
	spe2.cep,
	spe2.numero,
	spe2.complemento
order by sp.id
	
--marketing cloud salesforncement




--modelagem buscando profissionais médicos que atuam ou atuaram nas unidades do Anderson Franco: Demanda da Marjorie
with exclusao as ( --objeto criado para apontar os id de profissionais da central amor saude cujo id 19774, 19793, 0
select sp.id as id_prof 
from
	todos_data_lake_trusted_feegow.profissionais sp
left join todos_data_lake_trusted_feegow.conselhos_profissionais scp on	scp.id = sp.conselho_id
left join todos_data_lake_trusted_feegow.profissional_especialidades spe on	spe.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.especialidades e on	e.id = spe.especialidade_id
left join todos_data_lake_trusted_feegow.profissionais_unidades puu on	puu.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.unidades uu on	uu.id = puu.unidade_id
left join todos_data_lake_trusted_feegow.unidades_regioes ur on	ur.id = uu.regiao_id
where 1 = 1
and uu.id in (19774, 19793, 0)
),
profissionais as (
select	distinct 
	sp.id as id_profissional,
	sp.nome_profissional ,
	sp.nascimento,
	sp.cpf,
	sp.ativo,
	sp.sys_active,
	scp.id as id_conselho,
	scp.codigo as codigo_coselho,
	spe.uf_conselho,
	e.nome_especialidade,
	spe.rqe,
	sp.sys_active,
	sp.sys_user ,
	sp.ativo,
	sp.unidade_id,
	uu.id as id_unidade_unic,
	uu.nome_fantasia ,
	ur.descricao as regional,
	date(sp.dhup) as dhup,
	sp.sys_date as sys_date
from
	todos_data_lake_trusted_feegow.profissionais sp
left join todos_data_lake_trusted_feegow.conselhos_profissionais scp on	scp.id = sp.conselho_id
left join todos_data_lake_trusted_feegow.profissional_especialidades spe on	spe.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.especialidades e on	e.id = spe.especialidade_id
left join todos_data_lake_trusted_feegow.profissionais_unidades puu on	puu.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.unidades uu on	uu.id = puu.unidade_id
left join todos_data_lake_trusted_feegow.unidades_regioes ur on	ur.id = uu.regiao_id
where
	1 = 1
	and sp.sys_active = 1
	and sp.ativo = 'on'
	and uu.id in (19794,19889,19940,19401,19398,19770,19831,19411,19640,19352,19934,19354,19966,19524,19437,19406,19834,19947,19832,
19300,19866,19445,19293,19325,19965,19410,19349,19353,19890,19296,19873,19879,19400,19916,19696,19563,19351,19469,
19392,19312,19515,19424,19341,19447,19315,19616,19709,19913,19436,19790,19290,19538,19930,19368,19481)
)
select * from profissionais pp
where 1 = 1
and pp.id_profissional not in ( --realizando a exclusão dos profissionais do primeiro objeto
	select * from exclusao)
order by id_profissional


