--modelagens antigas
--profissionais
with prof as (
    select 
    id,
    nome_profissional,
    conselho_id,
    documento_conselho,
    sys_active,
    nascimento,
    cpf,
    sexo_id,
    email1,
    email2,
    telefone1,
    telefone2,
    celular1,
    celular2,
    dhup,
    sys_date
      from {{ source('todos_data_lake_trusted_feegow','profissionais') }}
),
cp as (
  select 
    id,
    descricao
      from {{ source('todos_data_lake_trusted_feegow','conselhos_profissionais') }}
),
pu as (
  select 
  profissional_id,
  unidade_id
from {{ source('todos_data_lake_trusted_feegow','profissionais_unidades') }}
),
u as (
  select 
  id,
  regiao_id,
  nome_fantasia
from {{ source('todos_data_lake_trusted_feegow','unidades') }}
)
select
prof.id as id_profissional,
prof.nome_profissional as nm_profissional,
cp.id as id_conselho,
cp.descricao as conselho,
prof.documento_conselho as nro_conselho,
prof.nascimento,
prof.cpf,
case
when prof.sexo_id = 1 then 'Masculino'
when prof.sexo_id = 2 then 'Feminino'
when prof.sexo_id = 0 then 'Indefinido'
end as genero,
u.id as id_unidade,
u.nome_fantasia as unidade,
prof.email1,
prof.email2,
prof.telefone1,
prof.telefone2,
prof.celular1,
prof.celular2,
prof.dhup as dt_atualizacao,
prof.sys_date as dt_criacao,
case
when prof.sys_active = -1 then 'Inativo'
when prof.sys_active = 1 then 'Ativo'
end as status_cadastro
from prof
left join cp on prof.conselho_id = cp.id
left join pu on prof.id = pu.profissional_id
left join u on pu.unidade_id = u.id



select * from pdgt_amorsaude_financeiro.fl_contas_a_receber_vmk v
where v.datapagamento between date('2024-01-07') and date('2024-01-13')

























