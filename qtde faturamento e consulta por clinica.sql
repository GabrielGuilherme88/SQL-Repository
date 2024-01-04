--modelagem criada para atender a demanda da Laura, utilizando tabelas hist
--validado com a clínica de AmorSaúde Abaetetuba bateu com o B.I da amorsaúde
with qtde_consultas as (
select tcah.id_unidade , tcah.nome_fantasia as nome_unidade, sur.descricao as regional,
count(*) as qtde_consulta, extract (month from tcah.datadoatendimento) as mesconsulta
from tb_consolidacao_agendamentos_hist tcah 
left join stg_unidades su on su.id = tcah.id_unidade 
left join stg_unidades_regioes sur on sur.id = su.regiao_id 
where 1=1
and tcah.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3, 208)
and tcah.datadoatendimento between date('2022-01-01') and date('2022-12-31')
group by tcah.id_unidade , tcah.nome_fantasia, sur.descricao, extract (month from tcah.datadoatendimento)
),
qtde_consulta1 as (
select id_unidade, nome_unidade, regional, mesconsulta, qtde_consulta, 
	case when mesconsulta = 1 then 'Janeiro'
	when mesconsulta = 2 then 'Fevereiro'
	when mesconsulta = 3 then 'Março'
	when mesconsulta = 4 then 'Abril'
	when mesconsulta = 5 then 'Maio'
	when mesconsulta = 6 then 'Junho'
	when mesconsulta = 7 then 'Julho'
	when mesconsulta = 8 then 'Agosto'
	when mesconsulta = 9 then 'Setembo'
	when mesconsulta = 10 then 'Outubro'
	when mesconsulta = 11 then 'Novembro'
	when mesconsulta = 12 then 'Dezembbro'
end as mes_case
from qtde_consultas
),
receita_bruta as (
select rb.id_unidade as idunidade,  sum(rb.total_recebido) as faturamento_bruto, 
extract (month from rb.data) as mesfaturamento
from tb_consolidacao_receita_bruta_hist_final rb
where 1=1
and rb.data between date('2022-01-01') and date('2022-12-31')
group by rb.id_unidade, extract (month from rb.data)
)
select  idunidade, nome_unidade, 
REPLACE(REPLACE(REPLACE(REPLACE(sum(faturamento_bruto)
	::text,'$','R$ '),',','|'),'.',','),'|','.') as faturamento_bruto,
mesfaturamento, mes_case, qtde_consulta
from qtde_consulta1 qc
left join receita_bruta rb on rb.idunidade = qc.id_unidade and rb.mesfaturamento = qc.mesconsulta
group by idunidade, nome_unidade, mesfaturamento, mes_case, qtde_consulta




--demanda qtde de pacientes por faixa etária por clinica a pedido da Laura Paschoin
with agendamento as (
select tcah.id_unidade, tcah.nome_fantasia, tcah.id_paciente, tcah.data_nascimento, tcah.nome_especialidade
from tb_consolidacao_agendamentos_hist tcah
where 1 = 1
and tcah.nome_especialidade in ('Cirurgia Vascular','Ortopedia e Traumatologia', 'Endocrinologia')
and tcah.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3, 208)
and tcah.id_tipoprocedimento in (2, 9)
and tcah.datadoatendimento between '2023-01-01' and '2023-09-30' 
),
unidades as (
select su.id, su.cidade 
from stg_unidades su
),
faixas as (
select id_unidade, nome_fantasia, 
count (distinct id_paciente) as qtde_pacientes_distinct,
count (id_paciente) as qtde_atendimentos,
nome_especialidade,
CASE
    WHEN DATE_PART('year', current_date) - DATE_PART('year', data_nascimento) <= 17 THEN '0 a 17 anos'
    WHEN DATE_PART('year', current_date) - DATE_PART('year', data_nascimento) <= 29 THEN '18 a 29 anos'
    WHEN DATE_PART('year', current_date) - DATE_PART('year', data_nascimento) <= 39 THEN '30 a 39 anos'
    WHEN DATE_PART('year', current_date) - DATE_PART('year', data_nascimento) <= 49 THEN '40 a 49 anos'
    WHEN DATE_PART('year', current_date) - DATE_PART('year', data_nascimento) <= 59 THEN '50 a 59 anos'
    WHEN DATE_PART('year', current_date) - DATE_PART('year', data_nascimento) <= 69 THEN '60 a 69 anos'
    ELSE '70 anos ou mais'
  END AS faixa_etaria
from agendamento a
left join unidades u on u.id = a.id_unidade
group by  id_unidade, nome_fantasia, data_nascimento, nome_especialidade
)
select f.id_unidade, f.nome_fantasia, f.faixa_etaria, nome_especialidade, 
sum(qtde_pacientes_distinct) as qtde_pacientes_distinct,
sum(qtde_atendimentos) as qtde_atendimentos,
ROUND(1 - sum(qtde_pacientes_distinct)/sum(qtde_atendimentos)::float,2) as prob_retorno
from faixas f
group by f.id_unidade, f.nome_fantasia, f.faixa_etaria, nome_especialidade
order by id_unidade, faixa_etaria, nome_especialidade asc
--limit 100


--demanda qtde de pacientes por faixa etária por clinica a pedido da Laura Paschoin
with agendamento as (
select tcah.id_unidade, tcah.nome_fantasia, u.cidade as cidade_unidade, tcah.id_paciente, tcah.data_nascimento
from tb_consolidacao_agendamentos_hist tcah
--left join unidades uu on uu.idunidade = tcah.id_unidade  
left join stg_unidades u on u.id = tcah.id_unidade 
where 1 = 1
--and tcah.nome_especialidade in ('Cirurgia Vascular','Ortopedia e Traumatologia', 'Endocrinologia')
and tcah.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3, 208)
and tcah.id_tipoprocedimento in (2, 9)
and tcah.datadoatendimento between '2023-01-01' and '2023-09-30' 
),
faixas as (
select id_paciente, id_unidade, nome_fantasia, cidade_unidade,
CASE
    WHEN DATE_PART('year', current_date) - DATE_PART('year', data_nascimento) <= 17 THEN '0 a 17 anos'
    WHEN DATE_PART('year', current_date) - DATE_PART('year', data_nascimento) <= 29 THEN '18 a 29 anos'
    WHEN DATE_PART('year', current_date) - DATE_PART('year', data_nascimento) <= 39 THEN '30 a 39 anos'
    WHEN DATE_PART('year', current_date) - DATE_PART('year', data_nascimento) <= 49 THEN '40 a 49 anos'
    WHEN DATE_PART('year', current_date) - DATE_PART('year', data_nascimento) <= 59 THEN '50 a 59 anos'
    WHEN DATE_PART('year', current_date) - DATE_PART('year', data_nascimento) <= 69 THEN '60 a 69 anos'
    ELSE '70 anos ou mais'
  END AS faixa_etaria 
from agendamento a
inner join (select distinct tcah.id_unidade as idunidade --para pegar fazer o join com unidades que tenham as três especialidades
			from tb_consolidacao_agendamentos_hist tcah
			where 1 = 1
			and tcah.nome_especialidade in ('Cirurgia Vascular','Ortopedia e Traumatologia', 'Endocrinologia')
			and tcah.datadoatendimento between '2023-01-01' and '2023-09-30' 
			and tcah.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3, 208)) as unis
on unis.idunidade = a.id_unidade		
--group by  id_unidade, nome_fantasia, cidade_unidade, data_nascimento
)
select f.id_unidade, f.nome_fantasia,  f.faixa_etaria, 
count (distinct id_paciente) as qtde_pacientes_distinct,
count (id_paciente) as qtde_atendimentos,
ROUND(1 - count(distinct id_paciente) / count(id_paciente)::float, 2) as prob_retorno
from faixas f
group by f.id_unidade, f.nome_fantasia, cidade_unidade,  f.faixa_etaria
order by id_unidade, faixa_etaria asc
--limit 10