--Para o parâmetro external_location utilizar sempre a macro get_external_location("nome_do_schema",this.name).
--O parâmetro schema deve ser preenchido com o nome do esquema que será utilizado em produção.
--Entretando quando em fase de desenvolvimento será utilizado o esquema padrão do usuário definido no profile "dev".
{{ config(external_location =  get_external_location("pdgt_sandbox_gabrielguilherme", this.name),
          materialized = "table",
          schema = "pdgt_sandbox_gabrielguilherme") }}


with pdf as (
    select 
    *
	from {{ source('todos_data_lake_trusted_feegow','dc_pdf_assinados') }}
),
a as (
    select 
    *
	from {{ source('todos_data_lake_trusted_feegow','atendimentos') }}
),
ap as (
    select 
    *
	from {{ source('todos_data_lake_trusted_feegow','agendamento_procedimentos') }}
),
ag as (
    select 
    *
	from {{ source('todos_data_lake_trusted_feegow','agendamentos') }}
),
ass as (
    select 
    *
	from {{ source('todos_data_lake_trusted_feegow','agendamento_status') }}
),

u as (
    select 
    *
	from {{ source('todos_data_lake_trusted_feegow','unidades') }}
),
ur as (
    select 
    *
	from {{ source('todos_data_lake_trusted_feegow','unidades_regioes') }}
),
p as (
    select 
    *
	from {{ source('todos_data_lake_trusted_feegow','procedimentos') }}
),
pa as (
    select 
    *
	from {{ source('todos_data_lake_trusted_feegow','pacientes') }}
),
resultado as (
select
	ag.data as Agendamentos_data,
  ur.descricao AS Regioes__descricao,
  u.id as id_unidade,
  u.nome_fantasia,
  pa.id as paciente_id,
  pa.nome_paciente,
  pa.cpf,
  p.nome_procedimento,
  COUNT(distinct ag.id) AS qtde,
 ROW_NUMBER() OVER (PARTITION BY u.nome_fantasia ORDER BY RAND()) AS row_num
FROM  pdf
  LEFT JOIN a ON pdf.documento_id = a.id
  LEFT JOIN ap ON a.agendamento_id = ap.agendamento_id
  LEFT JOIN ag ON ap.agendamento_id = ag.id
  LEFT JOIN ass ON ag.status_id = ass.id
  LEFT JOIN u ON a.unidade_id = u.id
  LEFT JOIN ur ON u.regiao_id = ur.id
  LEFT JOIN pa ON ag.paciente_id = pa.id
  LEFT JOIN p ON ap.procedimento_id = p.id
WHERE
  pdf.tipo = 'ATENDIMENTO'
  AND ass.nome_status IN (
    'Em espera pós consulta', 'Em espera pré consulta', 'Em espera', 'Em atendimento pós consulta',
    'Em atendimento pré consulta', 'Em atendimento', 'Chamando pós consulta', 'Chamando pré consulta',
    'Chamando', 'Atendido', 'Aguardando pós Consulta', 'Aguardando pré-consulta', 'Aguardando', 'Aguardando pagamento'
  )
  AND (p.tipo_procedimento_id = 2 OR p.tipo_procedimento_id = 9)
  and ag.data between current_date - interval '30' day and current_date - interval '1' day
   --and ag."data" BETWEEN date('2024-01-01') and CURRENT_DATE
   --date_add('month', -3, current_date) AND current_date
   and u.id in 
   				(
   				select id 
   				from u
   				order by rand()
   				   				)
GROUP BY
ag.data,
  ur.descricao,
  u.nome_fantasia,
  u.id,
  pa.id,
  pa.nome_paciente,
  pa.cpf,
  p.nome_procedimento
  ORDER BY RAND(),
  u.id
)
select *
from resultado r
where 1=1
AND row_num <= 20
order by id_unidade
limit 600