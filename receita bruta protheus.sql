--protheus F faturamento

with mov as (
select 
  id,
  forma_pagamento_id,
  unidade_id,
  conta_id_debito,
  tipo_movimentacao,
  credito_debito,
  associacao_conta_id_credito,
  valor,
  data
  from todos_data_lake_trusted_feegow.movimentacao
),
idesc as (
select
  id,
  pagamento_id,
  valor,
  item_id
  from todos_data_lake_trusted_feegow.pagamento_item_associacao
),
ii as (
select
  id,
  desconto,
  quantidade,
  valor_unitario,
  executante_id,
  executante_associacao_id,
  valor_custo_calculado
 from todos_data_lake_trusted_feegow.conta_itens
),
devit as (
select
  conta_itens_id,
  devolucoes_id
 from todos_data_lake_trusted_feegow.devolucoes_itens
),
dev as (
select
  id,
  totaldevolucao,
  invoiceid,
  sysdate,
  tipooperacao
 from todos_data_lake_trusted_feegow.devolucoes
),
fpm as (
select
  id,
  forma_pagamento
 from todos_data_lake_trusted_feegow.formas_pagamento
),
tef as (
select
  unidadeid,
  sellerid
 from todos_data_lake_trusted_feegow.tef_autorizacao
),
ca as (
select
  integracao_split,
  id
 from todos_data_lake_trusted_feegow.contas_correntes
),
gc as (
select
  id,
  unidadeid,
  valorprocedimento,
  dataatendimento,
  sysactive,
  guiastatus
 from todos_data_lake_trusted_feegow.tiss_guia_consulta
),
igs as (
select
  id,
  valortotal,
  data,
  guiaid
 from todos_data_lake_trusted_feegow.tiss_procedimentos_sadt
),
gs as (
select
  id,
  unidadeid,
  sysactive,
  guiastatus
from  todos_data_lake_trusted_feegow.tiss_guia_sadt
),
inv as (
select
  id,
  unidade_id
 from todos_data_lake_trusted_feegow.contas
),
movrem as (
select
  id,
  valor,
  data,
  unidade_id,
  forma_pagamento_id,
  data_remocao,
  tipo_movimentacao,
  credito_debito,
  associacao_conta_id_credito
 from todos_data_lake_trusted_feegow.movimentacao_removidos
),
forn as (
select
  id,
  recebeparcial
 from todos_data_lake_trusted_feegow.fornecedores
),
rfu as (
select
  fornecedorid
 from todos_data_lake_trusted_feegow.recebimentoparcial_fornecedores_unidades
),
und as (
select
  id,
  regiao_id,
  nome_fantasia,
  cnpj
 from todos_data_lake_trusted_feegow.unidades
),
reg as (
select
  id,
  descricao
 from todos_data_lake_trusted_feegow.unidades_regioes
)
select 
--data,
round(sum(split)/100, 2) as split,
round(sum(valorfinal), 2) as valorfinal
from
((
select 
MAX(s.valor) OVER (PARTITION BY mov.id) AS split,
concat('PART', cast(mov.id as varchar)) id, 
sum(idesc.valor) as valorfinal, 
mov.data as data, 
(case when ca.integracao_split = 'S' then 1 else 0 end) pagtodos, 
tef.sellerid, 
mov.unidade_id, fpm.forma_pagamento, idesc.pagamento_id,
'Particular' tipo, mov.forma_pagamento_id,
ii.desconto, sum(ii.quantidade * ii.valor_unitario) as valorsemdesconto
from
mov
  left join idesc on idesc.pagamento_id = mov.id -- ferra tudo
  left join ii on ii.id = idesc.item_id
  left join devit on devit.conta_itens_id = ii.id
  left join dev on dev.id = devit.devolucoes_id
  inner join fpm on mov.forma_pagamento_id = fpm.id
  left join tef on tef.unidadeid = mov.unidade_id
  left join ca on ca.id = mov.conta_id_debito
  LEFT JOIN todos_data_lake_trusted_feegow.splits s ON s.movimentacao_id = mov.id
where mov.tipo_movimentacao <> 'Bill' and mov.credito_debito = 'D' 
and mov.associacao_conta_id_credito = 3
--and mov.unidade_id = 19957
and mov.data between date('2023-12-01') and date('2023-12-16')
group by
mov.id, 
mov.data, 
ca.integracao_split, 
tef.sellerid, 
mov.unidade_id, 
fpm.forma_pagamento,
mov.forma_pagamento_id,
ii.desconto, 
idesc.pagamento_id,
s.valor
))
--where id = 'PART152246076'
--group by data
--order by data
