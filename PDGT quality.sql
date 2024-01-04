--verificar a quantidade de registro
select sci.data_execucao, count(*) 
from todos_data_lake_trusted_feegow.conta_itens sci
where sci.data_execucao between date('2023-01-01') and current_date
group by sci.data_execucao 
order by sci.data_execucao desc

select sm."data" , count(*) 
from todos_data_lake_trusted_feegow.movimentacao sm 
where sm.data between date('2023-01-01') and current_date
group by sm."data"
order by sm."data" desc


select sc.data_referencia, count(*) 
from todos_data_lake_trusted_feegow.contas sc
where sc.data_referencia between date('2023-01-01') and current_date
group by sc.data_referencia
order by sc.data_referencia desc



SELECT rb."data", sum(rb.total_recebido) as total_recebido,
sum(rb.total_royalties) as total_royalties
FROM pdgt_sandbox_gabrielguilherme.fl_receita_bruta rb
where rb."data" between date('2023-09-01') and current_date 
group by rb."data"
order by rb."data" desc

--verificando a tabela pagamento_item_associacao
select sm."data" ,count(*) 
from todos_data_lake_trusted_feegow.movimentacao sm 
left join todos_data_lake_trusted_feegow.pagamento_item_associacao spa on spa.pagamento_id = sm.id
where sm."data" between date('2023-09-01') and current_date
group by sm."data"
order by sm."data" desc

select date(a.dhup), sum(a.valor)
from todos_data_lake_trusted_feegow.pagamento_item_associacao a
where a.dhup between date('2023-09-01') and current_date 
group by date(a.dhup)
order by date(a.dhup) desc

select * from todos_data_lake_trusted_feegow.agendamento_procedimentos
limit 10

--verificando a modelagem contas a receber
select sum(r.valor_pago)  
from pdgt_sandbox_gabrielguilherme.fl_contas_a_receber r
where r.id_unidade = 19957
and r.datapagamento between date('2023-09-01') AND date('2023-09-30')
--group by r.datapagamento

select *
from pdgt_sandbox_gabrielguilherme.fl_contas_a_receber r
where r.id_unidade = 19957
and r.datapagamento between date('2023-09-01') AND date('2023-09-30')

--validação do contas a receber da VMK
select sum(t.valor_pago), t.id_unidade, t.nome_unidade
from pdgt_sandbox_gabrielguilherme.fl_contas_a_receber_vmk t
where t.datapagamento between date('2023-09-01') and date('2023-09-30')
and t.id_unidade in (19669, 19932, 19615, 19820)
group by t.id_unidade, t.nome_unidade

select * from pdgt_amorsaude_financeiro.fl_contas_a_receber 
limit 100

select * from todos_data_lake_trusted_feegow.unidades 


select count(*), cast(sap.dhup as date) 
from todos_data_lake_trusted_feegow.agendamento_procedimentos sap 
group by  cast(sap.dhup as date) 
order by cast(sap.dhup as date) DESC

--teste de snapshot
with fl_protheus_unidades as (
select
        *
    from pdgt_amorsaude_financeiro.fl_contas_a_receber
),
my_snapshot as (
    select * from fl_protheus_unidades
    where 1 = 1
    AND (
  datapagamento >= current_date - interval '1' month - day(current_date) + 1
  AND
  extract(day from current_date) <= 4
)
OR (
  datapagamento >= current_date - day(current_date) + 1
  AND
  extract(day from current_date) > 4
)
)
select * from my_snapshot

--prontuarios
select count(*) , cast (f.data_criacao as date) , cast(f.data_atualizacao as date)
from todos_data_lake_trusted_feegow.dc_pdf_assinados f
--where f.data_atualizacao = '2023-10-01'
group by cast (f.data_criacao as date) , cast(f.data_atualizacao as date)

select tcrbhf.id_unidade, sum(tcrbhf.total_recebido)  
from pdgt_amorsaude_financeiro.fl_receita_bruta tcrbhf
where tcrbhf."data" between date('2023-11-01') and date('2023-11-01')
and tcrbhf.id_unidade = 19436 --Uberaba
group by tcrbhf.id_unidade

---------------------------------------------------------------------------------
SELECT 
data,
datavencimento,
datapagamento,
cpfpaciente,
recurrence,
id_paciente,
nome_paciente,
id_procedimento,
nome_procedimento,
nomegrupo,
tipoprocedimento,
sys_active,
id_funcionario,
nome_unidade,
id_unidade,
quantidade,
sum(valor_pago) as valor_pago ,
COUNT(*) OVER (PARTITION BY id_paciente, datapagamento, id_procedimento) AS qtde, --quantidade particionada por janela do id, data e procedimento
descricaomovimentacao,
situacaoconta,
parcelas,
categoria,
subcategoria,
id_tabela,
nome_tabela_particular,
id_regional,
regional,
id_pofissional,
id_fornecedor
FROM pdgt_amorsaude_financeiro.fl_contas_a_receber v
where 1 = 1
and v.datapagamento between date('2023-11-01') and date('2023-11-25') --aqui vocês podem alterar para validação
and v.id_unidade = 19543 --aqui vocês podem alterar para validação
and v.id_paciente = 17601597 --aqui vocês podem alterar para validação
and nomegrupo in ('Exames Laboratoriais', 'Exames de Imagem', 'Procedimentos', 'Sessão', 'Cirurgia geral') -- filtrando apenas exames e procedimentos (podem retirar caso necessário)
group by 
data,
datavencimento,
datapagamento,
cpfpaciente,
recurrence,
id_paciente,
nome_paciente,
id_procedimento,
nome_procedimento,
nomegrupo,
tipoprocedimento,
sys_active,
id_funcionario,
nome_unidade,
id_unidade,
quantidade,
descricaomovimentacao,
situacaoconta,
parcelas,
categoria,
subcategoria,
id_tabela,
nome_tabela_particular,
id_regional,
regional,
id_pofissional,
id_fornecedor

select *
from pdgt_amorsaude_financeiro.fl_contas_a_receber cr
where cr.datapagamento between date('2023-11-01') and date('2023-11-25')
and cr.id_unidade = 19543
and cr.id_paciente = 57035664
and nomegrupo in ('Exames Laboratoriais', 'Exames de Imagem', 'Procedimentos', 'Sessão', 'Cirurgia geral')

select sum(quantidade), sum(qtde)
from(
SELECT 
data,
datavencimento,
datapagamento,
cpfpaciente,
recurrence,
id_paciente,
nome_paciente,
id_procedimento,
nome_procedimento,
--forma_pagamento,
nomegrupo,
tipoprocedimento,
sys_active,
id_funcionario,
nome_unidade,
id_unidade,
sum(valor_pago) as valor_pago ,
count(distinct moviid) as quantidade,
count(*) as qtde,
descricaomovimentacao,
situacaoconta,
parcelas,
categoria,
subcategoria,
id_tabela,
nome_tabela_particular,
id_regional,
regional,
id_pofissional,
id_fornecedor
FROM pdgt_sandbox_gabrielguilherme.fl_contas_a_receber v
where 1 = 1
and v.datapagamento between date('2023-11-01') and date('2023-11-25') --aqui vocês podem alterar para validação
and v.id_unidade = 19543 --aqui vocês podem alterar para validação
--and v.id_paciente = 11103511 --aqui vocês podem alterar para validação
and nomegrupo in ('Exames Laboratoriais', 'Exames de Imagem', 'Procedimentos', 'Sessão', 'Cirurgia geral') -- filtrando apenas exames e procedimentos (podem retirar caso necessário)
group by 
data,
datavencimento,
datapagamento,
cpfpaciente,
recurrence,
id_paciente,
nome_paciente,
id_procedimento,
nome_procedimento,
nomegrupo,
tipoprocedimento,
--forma_pagamento,
sys_active,
id_funcionario,
nome_unidade,
id_unidade,
descricaomovimentacao,
situacaoconta,
parcelas,
categoria,
subcategoria,
id_tabela,
nome_tabela_particular,
id_regional,
regional,
id_pofissional,
id_fornecedor)
--------------------------------------------------------------------------------


SELECT * FROM pdgt_sandbox_gabrielguilherme.fl_contas_a_receber_vmk v
where v.datapagamento between date('2023-09-01') and date('2023-09-30')
and v.id_unidade = 19457


select * from pdgt_amorsaude_financeiro.fl_contas_a_receber cr
where cr.datapagamento between date('2023-09-01') and date('2023-09-30')
and cr.id_unidade = 19457


select *
from pdgt_sandbox_gabrielguilherme.fl_contas_a_receber_presidente cr
where cr.datapagamento between date('2023-11-01') and date('2023-11-15')
and cr.id_unidade = 19340
--group by cr.datapagamento
--order by cr.datapagamento

select * from pdgt_amorsaude_operacoes.fl_agendamentos a
where a.id_agendamento = 853255799

select * from pdgt_amorsaude_financeiro.fl_contas_a_pagar 
limit 10

--contas correntes
select * from todos_data_lake_trusted_feegow.contas_correntes d
left join todos_data_lake_trusted_feegow.tipo_conta_corrente c on c.id = d.tipo_conta_corrente
limit 10

--profissionais para verificar se as especialidades estão sendo devidamente carregadas
select
	*
from
	todos_data_lake_trusted_feegow.profissionais sp
left join todos_data_lake_trusted_feegow.profissional_especialidades spe on	spe.profissional_id = sp.id
left join todos_data_lake_trusted_feegow.especialidades e on	e.id = spe.especialidade_id
where
	1 = 1
	and sp.id = 513906
	
	

SELECT sum(r.total_recebido)
FROM pdgt_amorsaude_financeiro.fl_receita_bruta r
where r."data" between date('2023-11-01') and date('2023-11-26')


select sum(valortotal) from pdgt_amorsaude_financeiro.fl_contas_a_pagar p
where p.datapagamento between date('2023-11-01') and date('2023-11-26')


select sum(valortotal) as valortotal , sum(valorvencido) as valorvencido ,
sum(valorapagar) as valorapagar , sum(valorpago) as valorpago  
from pdgt_amorsaude_financeiro.fl_contas_a_pagar 
WHERE datapagamento  BETWEEN DATE ('2023-11-01') AND DATE('2023-11-26')
--group by id_unidade, nm_unidade 

--FL_AGENDAMENTOS
select a.id_unidade , count(a.id_agendamento)
from pdgt_amorsaude_operacoes.fl_agendamentos a
where 1 = 1
--and a.id_unidade = 19309
and a.dt_agendamento between date('2023-11-01') and date ('2023-11-26')
--and id_status in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
group by a.id_unidade
order by a.id_unidade


select u.nome_fantasia, sum(total_recebido) as recebido, sum(total_royalties) as royalties  
from pdgt_amorsaude_financeiro.fl_receita_bruta rb
left join pdgt_amorsaude_backoffice.fl_unidades u on rb.id_unidade = u.id_unidade  
where "data"  BETWEEN DATE('2023-11-01') AND DATE('2023-11-26')
and rb.id_unidade = 19611
group by rb.id_unidade, u.nome_fantasia
--order by rb.id_unidade asc

SELECT nome_fantasia, current_timestamp
FROM todos_data_lake_trusted_feegow.unidades


select
dt_criacao,
dt_agendamento as datadoatendimento,
id_unidade,
id_procedimento,
id_canal,
id_tabela,
CASE
    WHEN id_status IN (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3) THEN 'Atendido'
    ELSE nm_status
    end as nome_status_bi,
id_profissional,
id_especialidade,
sexo,
id_paciente,
id_agendamento,
nascimento,
date_diff('year', CAST(nascimento AS timestamp), CURRENT_DATE) AS idade
from pdgt_amorsaude_operacoes.fl_agendamentos
where dt_agendamento >= date('2023-01-01')
limit 10


--teste para contas a quantidade em contas a receber
with teste as (
select *, 
RANK() OVER (PARTITION BY datapagamento ORDER BY id_procedimento) AS ProcedimentoRank
from pdgt_amorsaude_financeiro.fl_contas_a_receber 
where cpfpaciente = '00019029624'
and datapagamento between date('2023-11-01') and date('2023-11-30')
)
select *, MAX(ProcedimentoRank) OVER (PARTITION BY datapagamento) AS TotalProcedimentosDistintosPorData
from teste

--protheus pedidoincluir
select * from pdgt_sandbox_gabrielguilherme.fl_pedidoincluir 
limit 100

--tirar dúvida sobre qual competência o protheus irá analisar --se é a data da realização do procedimento, ou a data de pagamento do mesmo.
select sum(cr.valor_pago) 
from pdgt_amorsaude_financeiro.fl_contas_a_receber cr
where 1 = 1
and cr.id_paciente = 17601597
and datapagamento between date('2023-11-01') and date('2023-11-30')

select sum(r.total_recebido) from pdgt_amorsaude_financeiro.fl_receita_bruta r
where r.id_unidade = 19543
and r."data" = date('2023-12-14')


select * from todos_data_lake_trusted_feegow.unidades 
where nome_fantasia like 'AmorSaúde Batat%'


select *
from pdgt_sandbox_gabrielguilherme.fl_contas_a_receber_freezer r
where r.datapagamento between date('2023-11-01') and current_date


--tentativa de trazer o split para dentro do relatório de receita bruta
select --r."data", 
sum(r.total_recebido) as total_recebido, 
sum(r.total_royalties) as total_royalties
from pdgt_amorsaude_financeiro.fl_receita_bruta r
where 1 = 1
--and r.id_unidade = 19957
and r."data" between date('2023-12-01') and date('2023-12-16')
--group by  r."data"
--order by r."data"


select * from pdgt_amorsaude_financeiro.fl_


--bate os splits com a aplicação. Possibilidade de vincular ela a receita bruta
select 
m."data", sum(m.valor), round(sum(s.valor)/100,2), m.tipo_movimentacao
from todos_data_lake_trusted_feegow.movimentacao m 
left join todos_data_lake_trusted_feegow.splits s on s.movimentacao_id = m.id 
where m.tipo_movimentacao <> 'Bill'
and m.credito_debito = 'D'
and m.associacao_conta_id_credito = 3
and m.unidade_id = 19957
and m."data" between date('2023-12-01') and date('2023-12-16')
group by m.tipo_movimentacao, m."data"


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