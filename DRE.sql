with periodo as (
	select date_trunc('month', p.data) as data, count(*) from stg_periodo p 
 --where p.data between date('2023-01-01') and date('2023-06-30')
	group by date_trunc('month', p.data)),	
faturamento_bruto as (
	select rb.id_unidade as id, p.data, sum(rb.total_recebido) as faturamento_bruto 
	from periodo p
	left join tb_consolidacao_receita_bruta_hist_final rb
	on p.data = date_trunc('month', rb."data")
	--where rb.id_unidade = 19398
	--and date(cr."data") between date('2023-01-01') and date('2023-05-31')
	group by rb.id_unidade, p.data), 
despesa_bruta as (
	select cp.id, p.data, case when cp.subcategoria in ('Royalties','Royalties (Split)') then 'Royalties' else cp.categoria end categoria, cp.subcategoria, sum(cp.valorpago) as despesa_bruta
	from periodo p
	left join tb_consolidacao_contas_a_pagar_hist cp
	on p.data = date_trunc('month', cp.datapagamento)
	where cp.situacaoconta <> 'Em aberto'
	and cp.id = 19398
	--and date(cp.datapagamento) between date('2023-01-01') and date('2023-05-31')
	group by cp.id, p.data, cp.categoria, cp.subcategoria),
royalties as (
	select db.id, db."data", case when sum(db.despesa_bruta) is null then 0 else sum(db.despesa_bruta) end as royalties
	from despesa_bruta db
	where db.subcategoria = 'Royalties'
	group by db.id, db."data"),
royalties_split as (
	select db.id, db."data", case when sum(db.despesa_bruta) is null then 0 else sum(db.despesa_bruta) end as royalties_split
	from despesa_bruta db
	where db.subcategoria = 'Royalties (Split)'
	group by db.id, db."data"),
repasse_consultas as (
	select db.id, db."data", sum(db.despesa_bruta) as repasse_consultas
	from despesa_bruta db
	where db.categoria = 'Repasse de Consultas'
	group by db.id, db."data"),
repasse_exames as (
	select db.id, db."data", case when sum(db.despesa_bruta) is null then 0 else sum(db.despesa_bruta) end as repasse_exames
	from despesa_bruta db
	where db.categoria = 'Repasse de Exames'
	group by db.id, db."data"),
repasse_procedimentos as (
	select p."data", db.id, nvl(sum(db.despesa_bruta), 0) as repasse_procedimentos
	from periodo p
	left join despesa_bruta db on p.data = db.data
	where db.categoria = 'Repasse De Procedimentos'
	group by db.id, p."data"),
repasses as (
	select db.id, db."data", case when sum(db.despesa_bruta) is null then 0 else sum(db.despesa_bruta) end as repasses
	from despesa_bruta db
	where db.categoria = 'Repasses'
	--and db.subcategoria is null
	group by db.id, db."data"),
repasse_profissional as (
	select distinct db.data, db.id, rc.repasse_consultas, re.repasse_exames, rp.repasse_procedimentos, rep.repasses,
	(nvl(rc.repasse_consultas, 0) + nvl(re.repasse_exames, 0) + nvl(rp.repasse_procedimentos, 0) + nvl(rep.repasses, 0)) as repasse_profissional
	from despesa_bruta db
	left join repasse_consultas rc on db.data = rc.data and db.id = rc.id
	left join repasse_exames re on db.data = re.data and db.id = re.id
	left join repasse_procedimentos rp on db.data = rp.data and db.id = rp.id
	left join repasses rep on db.data = rep.data and db.id = rep.id),
margem_op as (
	select fb.id, fb.data, nvl(fb.faturamento_bruto, 0) as faturamento_bruto, nvl(ro.royalties, 0) as royalties, nvl(rs.royalties_split, 0) as royalties_split,
		nvl(rp.repasse_profissional) as repasse_profissional,
		(nvl(fb.faturamento_bruto, 0) - nvl(ro.royalties, 0) + nvl(rs.royalties_split, 0) - nvl(rp.repasse_profissional)) as margem_op --royalties_split adicionado pois valor consta como negativo
	from faturamento_bruto fb
	left join royalties ro on fb.id = ro.id and fb.data = ro.data
	left join royalties_split rs on fb.id = rs.id and fb.data = rs.data
	left join repasse_profissional rp on fb.id = rp.id and fb.data = rp.data
	),
despesa_medicos as (
	select db.id, db."data", case when sum(db.despesa_bruta) is null then 0 else sum(db.despesa_bruta) end as despesa_medicos
	from despesa_bruta db
	where db.categoria = 'Despesas com Médicos'
	group by db.id, db."data"),
despesa_lab as (
	select db.id, db."data", case when sum(db.despesa_bruta) is null then 0 else sum(db.despesa_bruta) end as despesa_lab
	from despesa_bruta db
	where db.categoria in ('Despesas Com Laboratórios', 'Despesa com Laboratórios')
	group by db.id, db."data"),
despesa_outrosp as (
	select db.id, db."data", case when sum(db.despesa_bruta) is null then 0 else sum(db.despesa_bruta) end as despesa_outrosp
	from despesa_bruta db
	where db.categoria = 'Despesas com Outros Profissionais'
	group by db.id, db."data"),
despesa_funcionarios as (
	select db.id, db."data", case when sum(db.despesa_bruta) is null then 0 else sum(db.despesa_bruta) end as despesa_funcionarios
	from despesa_bruta db
	where db.categoria = 'Funcionários'
	group by db.id, db."data"),
despesa_impostos as (
	select db.id, db."data", case when sum(db.despesa_bruta) is null then 0 else sum(db.despesa_bruta) end as despesa_impostos
	from despesa_bruta db
	where db.categoria = 'Impostos'
	group by db.id, db."data"),
despesa_adm as (
	select db.id, db."data", case when sum(db.despesa_bruta) is null then 0 else sum(db.despesa_bruta) end as despesa_adm
	from despesa_bruta db
	where db.categoria = 'Administrativas'
	group by db.id, db."data"),
despesa_total as (
	select distinct db.data, db.id,
	nvl(dm.despesa_medicos, 0) despesa_medicos, nvl(dl.despesa_lab, 0) despesa_lab, nvl(dop.despesa_outrosp, 0) despesa_outrosp, nvl(df.despesa_funcionarios, 0) despesa_funcionarios, nvl(di.despesa_impostos, 0) despesa_impostos, nvl(da.despesa_adm, 0) despesa_adm,
	(nvl(dm.despesa_medicos, 0) + nvl(dl.despesa_lab, 0) + nvl(dop.despesa_outrosp, 0) + nvl(df.despesa_funcionarios, 0) + nvl(di.despesa_impostos, 0) + nvl(da.despesa_adm, 0)) as despesa_total
	from despesa_bruta db
	left join despesa_medicos dm on db.data = dm.data and db.id = dm.id
	left join despesa_lab dl on db.data = dl.data and db.id = dl.id
	left join despesa_outrosp dop on db.data = dop.data and db.id = dop.id
	left join despesa_funcionarios df on db.data = df.data and db.id = df.id
	left join despesa_impostos di on db.data = di.data and db.id = di.id
	left join despesa_adm da on db.data = da.data and db.id = da.id),
resultado_operacional as (
	select mo.data, mo.id, nvl(mo.margem_op, 0) margem_op, nvl(dt.despesa_total, 0) despesa_total, (nvl(mo.margem_op, 0) - nvl(dt.despesa_total, 0)) resultado_operacional 
	from margem_op mo
	left join despesa_total dt on mo.data = dt.data and mo.id = dt.id),
receita_financeira as (
	select cr.id_unidade as id, cr.nome_unidade, p.data, sum(cr.valor_pago) as receita_financeira 
	from periodo p
	left join tb_consolidacao_contas_a_receber_modelagem cr
	on p.data = date_trunc('month', cr."data")
	where cr.situacaoconta is not null
	and cr.categoria = 'Receitas Financeiras'
	--and cr.id_unidade = 19849
	--and date(cr."data") between date('2023-01-01') and date('2023-05-31')
	group by cr.id_unidade, cr.nome_unidade, p.data),
investimentos_pg as (
	select db.id, db."data", case when sum(db.despesa_bruta) is null then 0 else sum(db.despesa_bruta) end as investimentos_pg
	from despesa_bruta db
	where db.categoria = 'Investimentos'
	group by db.id, db."data"),
despesa_financeira as (
	select db.id, db."data", case when sum(db.despesa_bruta) is null then 0 else sum(db.despesa_bruta) end as despesa_financeira
	from despesa_bruta db
	where db.categoria = 'Financeiras'
	group by db.id, db."data"),
outras_despesas as (
	select db.id, db."data", case when sum(db.despesa_bruta) is null then 0 else sum(db.despesa_bruta) end as outras_despesas
	from despesa_bruta db
	where db.categoria = 'Outras Despesas'
	group by db.id, db."data"),
resultado_exercicio as (
	select fb.id, fb.data, rop.resultado_operacional, rf.receita_financeira, ipg.investimentos_pg, df.despesa_financeira, oup.outras_despesas, 
	nvl(nvl(rop.resultado_operacional, 0) - nvl(ipg.investimentos_pg, 0) + nvl(rf.receita_financeira, 0) - nvl(df.despesa_financeira, 0) - nvl(oup.outras_despesas, 0), 0) as resultado_exercicio
	from faturamento_bruto fb
	left join resultado_operacional rop on fb.id = rop.id and fb."data" = rop.data
	left join receita_financeira rf on rf.id = fb.id and rf.data = fb.data
	left join investimentos_pg ipg on ipg.id = fb.id and ipg.data = fb.data
	left join despesa_financeira df on df.id = fb.id and df.data = fb.data
	left join outras_despesas oup on oup.id = fb.id and oup.data = fb.data),
despesa_socios as (
	select db.id, db."data", case when sum(db.despesa_bruta) is null then 0 else sum(db.despesa_bruta) end as despesa_socios
	from despesa_bruta db
	where db.categoria = 'Sócios'
	group by db.id, db."data"),
receita_socios as (
	select cr.id_unidade as id, cr.nome_unidade, p.data, sum(cr.valor_pago) as receita_socios 
	from periodo p
	left join tb_consolidacao_contas_a_receber_modelagem cr
	on p.data = date_trunc('month', cr."data")
	where cr.situacaoconta is not null
	and cr.categoria = 'Sócios'
	--and cr.id_unidade = 19849
	--and date(cr."data") between date('2023-01-01') and date('2023-05-31')
	group by cr.id_unidade, cr.nome_unidade, p.data),
ajustes_entrada as (
	select cr.id_unidade as id, cr.nome_unidade, p.data, sum(cr.valor_pago) as ajustes_entrada 
	from periodo p
	left join tb_consolidacao_contas_a_receber_modelagem cr on p.data = date_trunc('month', cr."data")
	where cr.situacaoconta is not null
	and cr.subcategoria = 'Ajustes - Entradas'
	--and cr.id_unidade = 19849
	--and date(cr."data") between date('2023-01-01') and date('2023-05-31')
	group by cr.id_unidade, cr.nome_unidade, p.data),
ajustes_saida as (
	select db.id, db."data", case when sum(db.despesa_bruta) is null then 0 else sum(db.despesa_bruta) end as ajustes_saida
	from despesa_bruta db
	where db.categoria = 'Ajustes - Saídas'
	group by db.id, db."data"),
resultado_liquido as (
	select fb.id, fb.data, nvl(re.resultado_exercicio, 0) resultado_exercicio, nvl(ds.despesa_socios, 0) despesa_socios, nvl(rso.receita_socios, 0) receita_socios,
	nvl(ae.ajustes_entrada, 0) ajustes_entrada, nvl(asa.ajustes_saida, 0) ajustes_saida,
	nvl(nvl(re.resultado_exercicio, 0) - nvl(ds.despesa_socios, 0) + nvl(rso.receita_socios, 0) + nvl(ae.ajustes_entrada, 0) - nvl(asa.ajustes_saida, 0), 0) as resultado_liquido
	from faturamento_bruto fb
	left join resultado_exercicio re on re.id = fb.id and re.data = fb.data
	left join despesa_socios ds on ds.id = fb.id and ds.data = fb.data
	left join receita_socios rso on rso.id = fb.id and rso.data = fb.data
	left join ajustes_entrada ae on ae.id = fb.id and ae.data = fb.data
	left join ajustes_saida asa on asa.id = fb.id and asa.data = fb.data)
--select * from resultado_liquido --where data = date('2023-02-01') order by data--and categoria = 'Administrativas' order by subcategoria
select
	fb.data,
	fb.id as id_unidade,
	un.nome_fantasia nome_unidade,
	sue.descricao regiao,
	fb.faturamento_bruto,
	ro.royalties,
	rs.royalties_split, 
	rp.repasse_consultas,
	rp.repasse_exames,
	rp.repasse_procedimentos,
	rp.repasses,
	mo.margem_op,
	dt.despesa_medicos,
	dt.despesa_lab,
	dt.despesa_outrosp,
	dt.despesa_funcionarios,
	dt.despesa_impostos,
	dt.despesa_adm,
	dt.despesa_total,
	rop.resultado_operacional,
	ipg.investimentos_pg,
	rf.receita_financeira,
	df.despesa_financeira,
	oup.outras_despesas,
	re.resultado_exercicio,
	rso.receita_socios,
	ds.despesa_socios,
	ae.ajustes_entrada,
	asa.ajustes_saida,
	rl.resultado_liquido
from faturamento_bruto fb
left join royalties ro on fb.id = ro.id and fb."data" = ro.data
left join royalties_split rs on fb.id = rs.id and fb."data" = rs.data
left join repasse_profissional rp on fb.id = rp.id and fb."data" = rp.data
left join margem_op mo on fb.id = mo.id and fb."data" = mo.data
left join despesa_total dt on fb.id = dt.id and fb."data" = dt.data
left join resultado_operacional rop on fb.id = rop.id and fb."data" = rop.data
left join receita_financeira rf on rf.id = fb.id and rf.data = fb.data
left join investimentos_pg ipg on ipg.id = fb.id and ipg.data = fb.data
left join despesa_financeira df on df.id = fb.id and df.data = fb.data
left join outras_despesas oup on oup.id = fb.id and oup.data = fb.data
left join resultado_exercicio re on re.id = fb.id and re.data = fb.data
left join despesa_socios ds on ds.id = fb.id and ds.data = fb.data
left join receita_socios rso on rso.id = fb.id and rso.data = fb.data
left join resultado_liquido rl on rl.id = fb.id and rl.data = fb.data
left join ajustes_entrada ae on ae.id = fb.id and ae.data = fb.data
left join ajustes_saida asa on asa.id = fb.id and asa.data = fb.data
left join stg_unidades un on fb.id = un.id
left join stg_unidades_regioes sue on un.regiao_id = sue.id
order by fb.data
limit 1