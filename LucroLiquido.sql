  
--validar
	SELECT sum(tccar.valor_pago)
	FROM public.tb_consolidacao_contas_a_receber_modelagem as tccar
	where tccar .nome_unidadatade = 'AmorSaúde Petrolina'
	and tccar ."data" between '2022-10-01' and '2023-03-31'
	
	SELECT *
	FROM public.tb_consolidacao_contas_a_pagar_hist as tccar
	where tccar .nome_fantasia  = 'AmorSaúde Taboão da Serra'
	and tccar ."data" between '2023-01-01' and current_date

	--percentuais
with receita as (
	select cr.id_unidade, cr.nome_unidade,  
	sum(cr.valor_pago) as Receita 
	from tb_consolidacao_contas_a_receber_modelagem cr
	where cr."data" between '2023-01-01' and current_date 
	group by cr.id_unidade, cr.nome_unidade),
despesa as (
	select cp.id, cp.nome_fantasia, 
	sum(cp.valortotal) 
	as Despesa from tb_consolidacao_contas_a_pagar_hist cp
	where cp."data" between '2023-01-01' and current_date
	group by cp.id, cp.nome_fantasia),
Resultado as(
select r.id_unidade, r.nome_unidade, r.Receita, d.id, d.nome_fantasia, d.Despesa, 
r.Receita - d.Despesa as Resultado_em_valor,
case when r.Receita - d.Despesa > 0 then 'Lucro' else 'Prejuízo' end as Resultado
from receita r
left join despesa d on d.id = r.id_unidade
group by r.id_unidade, r.nome_unidade, r.Receita, d.id, d.nome_fantasia, d.Despesa)
select count(re.Resultado)::float / (select count(re.Resultado)::float
from Resultado re),
	(select count(re.Resultado)::float / (select count(re.Resultado)::float
from Resultado re) from Resultado re
where re.Resultado = 'Lucro') as lucro
from Resultado re
where re.Resultado = 'Prejuízo'

--tabular
with receita as (
	select cr.id_unidade, cr.nome_unidade, extract (month from cr."data") as mescr,
	sum(cr.valor_pago) as Receita 
	from tb_consolidacao_contas_a_receber_modelagem cr
	where cr."data" between '2023-01-01' and current_date 
	group by cr.id_unidade, cr.nome_unidade, extract (month from cr."data")),
despesa as (
	select cp.id, cp.nome_fantasia, extract (month from cp."data") as mescp,
	sum(cp.valortotal) 
	as Despesa from tb_consolidacao_contas_a_pagar_hist cp
	where cp."data" between '2023-01-01' and current_date
	group by cp.id, cp.nome_fantasia, extract (month from cp."data"))
select r.mescr , d.mescp ,r.id_unidade, r.nome_unidade, r.Receita, d.id, d.nome_fantasia, d.Despesa, 
r.Receita - d.Despesa as Resultado_em_valor,
case when r.Receita - d.Despesa > 0 then 'Lucro' else 'Prejuízo' end as Resultado
from receita r
left join despesa d on d.id = r.id_unidade and d.mescp = r.mescr
group by r.id_unidade, r.nome_unidade, 
r.Receita, d.id, d.nome_fantasia, d.Despesa, r.mescr , d.mescp


----tabular com data aberta
with receita as (
	select cr.id_unidade, cr.nome_unidade, cr."data",
	sum(cr.valor_pago) as Receita 
	from tb_consolidacao_contas_a_receber_modelagem cr
	--where cr."data" between '2022-01-01' and '2023-03-31' 
	group by cr.id_unidade, cr.nome_unidade, cr."data"),
despesa as (
	select cp.id, cp.nome_fantasia, cp."data",
	sum(cp.valortotal) 
	as Despesa from tb_consolidacao_contas_a_pagar_hist cp
	--where cp."data" between '2022-01-01' and '2023-03-31'
	group by cp.id, cp.nome_fantasia, cp."data")
select r.data , d.data ,r.id_unidade, r.nome_unidade, r.Receita, d.id, d.nome_fantasia, d.Despesa, 
r.Receita - d.Despesa as Resultado_em_valor,
case when r.Receita - d.Despesa > 0 then 'Lucro' else 'Prejuízo' end as Resultado
from receita r
left join despesa d on d.id = r.id_unidade and d.data = r.data
group by r.id_unidade, r.nome_unidade, 
r.Receita, d.id, d.nome_fantasia, d.Despesa, r.data , d.data

--Tabular sem data 
with receita as (
	select cr.id_unidade, cr.nome_unidade, cr."data",
	sum(cr.valor_pago) as Receita 
	from tb_consolidacao_contas_a_receber_modelagem cr
	--where cr."data" between '2022-04-01' and '2023-03-31' 
	group by cr.id_unidade, cr.nome_unidade, cr."data"),
despesa as (
	select cp.id, cp.nome_fantasia, cp."data",
	sum(cp.valortotal) 
	as Despesa from tb_consolidacao_contas_a_pagar_hist cp
	--where cp."data" between '2022-04-01' and '2023-03-31'
	group by cp.id, cp.nome_fantasia, cp."data")
select r.id_unidade, r.nome_unidade,
sum(r.Receita) - sum(d.Despesa) as Resultado_em_valor
from receita r
left join despesa d on d.id = r.id_unidade and d.data = r.data
group by r.id_unidade, r.nome_unidade


