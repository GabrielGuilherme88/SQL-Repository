select sum(r.total_recebido)
from pdgt_amorsaude_financeiro.fl_receita_bruta r
--where r.id_unidade = 19611
where r."data" between date('2023-11-01') and date('2023-11-26') 

select sum(Total_Recebido) as total_recebido, sum(Total_Royalties) as royalties, 
SUBSTRING(idcontas FROM 1 FOR 4) AS quatro_primeiras_letras
from (
with mov as (
select 
  id,
  forma_pagamento_id,
  unidade_id,
  conta_id_debito,
  tipo_movimentacao,
  credito_debito,
  associacao_conta_id_credito,
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
idcontas,
round(sum(x.totalrecebido), 2) as "Total_Recebido"
, round(sum(x.totalroyalties), 2) as "Total_Royalties"
, data
, id_unidade 
, forma_pagamento
from (
select
t.id as idcontas,
t.data "Data",
und.nome_fantasia,
und.id as id_unidade,
t.sellerid,
reg.descricao regiao, 
--case when t.pagtodos then 'sim' else 'não' end pagtodos, 
round(sum(t.valorfinal), 2) totalrecebido, 
round(sum(t.valorfinal * 0.04), 2) totalroyalties,
t.formapagto formapagamento,
t.tipo,
t.unidade_id,
forma_pagamento_id formapagamentoid,
forma_pagamento,
und.cnpj
from
((
select concat('PART', cast(mov.id as varchar)) id, idesc.valor valorfinal, mov.data data, (case when ca.integracao_split = 'S' then 1 else 0 end) pagtodos, tef.sellerid, mov.unidade_id, fpm.forma_pagamento formapagto, 'Particular' tipo, mov.forma_pagamento_id, ii.desconto, ii.quantidade * (ii.valor_unitario) valorsemdesconto
from
mov
  left join idesc on idesc.pagamento_id = mov.id
  left join ii on ii.id = idesc.item_id
  left join devit on devit.conta_itens_id = ii.id
  left join dev on dev.id = devit.devolucoes_id
  inner join fpm on mov.forma_pagamento_id = fpm.id
  left join tef on tef.unidadeid = mov.unidade_id
  left join ca on ca.id = mov.conta_id_debito
where
mov.data between date('2021-01-01') and current_date and mov.tipo_movimentacao <> 'Bill' and mov.credito_debito = 'D' and mov.associacao_conta_id_credito = 3
group by
idesc.id, mov.id, idesc.valor, mov.data, ca.integracao_split, tef.sellerid, mov.unidade_id, fpm.forma_pagamento, mov.forma_pagamento_id, ii.desconto, ii.quantidade, ii.valor_unitario
) 
union all 
(
select concat('GCONS', cast(gc.id as varchar)) id, gc.valorprocedimento valorfinal, gc.dataatendimento "Data", 0 pagtodos, tef.sellerid, gc.unidadeid, 'Guia Consulta' formapagto, 'Convênio' tipo, 21 paymentmethodid, 0 desconto, 0 valorsemdesconto
from
gc
  left join tef on tef.unidadeid = gc.unidadeid
where date(gc.dataatendimento) between date('2021-01-01') and current_date and gc.sysactive = 1 and (gc.guiastatus <> 4 or gc.guiastatus is null)
group by
gc.id, gc.valorprocedimento, gc.dataatendimento, gc.dataatendimento, tef.sellerid, gc.unidadeid
) 
union all 
(
select concat('GSADT', cast(igs.id as varchar)) id, igs.valortotal valorfinal, igs.data, 0 pagtodos, tef.sellerid, gs.unidadeid, 'Guia SADT' formapagto, 'Convênio' tipo, 22 paymentmethodid, 0 desconto, 0 valorsemdesconto
from
igs
  inner join gs on gs.id = igs.guiaid
  left join tef on tef.unidadeid = gs.unidadeid
where date(igs.data) between date('2021-01-01') and current_date and gs.sysactive = 1 and (gs.guiastatus <> 4 or gs.guiastatus is null)
group by
igs.id, igs.valortotal, igs.data, tef.sellerid, gs.unidadeid
) 
union all 
(
select concat('DEV', cast(dev.id as varchar)) id, - dev.totaldevolucao valorfinal, date(dev.sysdate), 0 pagtodos, tef.sellerid, inv.unidade_id, 'Devolução' formapagto, 'Cancelamento' tipo, 0 paymentmethodid, 0 desconto, 0 valorsemdesconto
from
dev
  inner join inv on inv.id = dev.invoiceid
  left join tef on tef.unidadeid = inv.unidade_id
where date(dev.sysdate) between date('2021-01-01') and current_date and dev.tipooperacao = 1
group by
dev.id, dev.totaldevolucao, dev.sysdate, tef.sellerid, inv.unidade_id
) 
union all 
(
select concat('REMOV', cast(movrem.id as varchar)) id, movrem.valor valorfinal, movrem.data data, 0 pagtodos, tef.sellerid, movrem.unidade_id, fpm.forma_pagamento formapagto, 'Particular' tipo, movrem.forma_pagamento_id, 0 desconto, 0 valorsemdesconto
from
movrem
  inner join fpm on movrem.forma_pagamento_id = fpm.id
  left join tef on tef.unidadeid = movrem.unidade_id
where date(movrem.data) between date('2021-01-01') and current_date and date(movrem.data) <> date(movrem.data_remocao) and movrem.tipo_movimentacao <> 'Bill' and movrem.credito_debito = 'D' and movrem.associacao_conta_id_credito = 3
) 
union all 
(
select concat('XPAG', cast(movrem.id as varchar)) id, - movrem.valor valorfinal, date(movrem.data_remocao) data, 0 pagtodos, tef.sellerid, movrem.unidade_id, 'Pagamento anulado' formapagto, 'Cancelamento' tipo, movrem.forma_pagamento_id, 0 desconto, 0 valorsemdesconto
from
movrem
  left join tef on tef.unidadeid = movrem.unidade_id
where date(movrem.data_remocao) between date('2021-01-01') and current_date and date(movrem.data) <> date(movrem.data_remocao) and movrem.tipo_movimentacao <> 'Bill' and movrem.credito_debito = 'D' and movrem.associacao_conta_id_credito = 3
) 
union all 
(
select concat('PEXT', cast(mov.id as varchar)) id, ii.valor_custo_calculado valorfinal, mov.data data, 0 pagtodos, tef.sellerid, mov.unidade_id, 'Pagto. Externo' formapagto, 'Pagto. Parcial' tipo, 20 paymentmethodid, 0 desconto, 0 valorsemdesconto
from
mov
  left join idesc on idesc.pagamento_id = mov.id
  left join ii on ii.id = idesc.item_id
  inner join fpm on mov.forma_pagamento_id = fpm.id
  left join tef on tef.unidadeid = mov.unidade_id
  left join ca on ca.id = mov.conta_id_debito
  left join forn on forn.id = ii.executante_id and ii.executante_associacao_id = 2
  left join rfu on forn.id = rfu.fornecedorid --inner alterado para left
where
mov.data between date('2021-01-01') and current_date and mov.tipo_movimentacao <> 'Bill' and mov.credito_debito = 'D' and mov.associacao_conta_id_credito = 3 and ii.valor_custo_calculado > 0 and forn.recebeparcial = 1 
group by
idesc.id, mov.id, ii.valor_custo_calculado, mov.data, tef.sellerid, mov.unidade_id
)) t
  inner join und on und.id = t.unidade_id
  left join reg on reg.id = und.regiao_id
  left join fpm on fpm.id = t.forma_pagamento_id
  inner join (
  select 'Convênio' tipo, 2 id union all
  select 'Cancelamento' tipo, 3 id union all
  select 'Particular' tipo, 4 id union all
  select 'Pagto. Parcial' tipo, 5 id 
  ) as tp on t.tipo = tp.tipo
--and if('[tipo]'=0, true,tp.id = '[tipo]') and if('[paymentmethod]'=0, true,t.paymentmethodid = '[paymentmethod]')
  group by
  t.id, --add
  und.id,
  t.data,
  t.unidade_id,
  t.formapagto,
  t.data,
  und.nome_fantasia,
  t.sellerid,
  reg.descricao,
  t.tipo,
  forma_pagamento_id,
  forma_pagamento,
  und.cnpj
  order by
  t.data,
  t.unidade_id,
  t.formapagto ) x group by x.id_unidade, x.data, forma_pagamento, idcontas --add
  ) rb
--where rb.id_unidade = 19611
where rb."data" between date('2023-12-01') and date('2023-12-30')
group by SUBSTRING(idcontas FROM 1 FOR 4)
--order by id_unidade asc




--modelagem referente ao pedidoincluir protheus
--MODELAGEM_contas_a_receber PROTHEUS
with m as (
select
	id,
	"data",
	conta_id,
	valor_pago,
	valor,
	descricao,
	forma_pagamento_id,
	tipo_movimentacao,
	credito_debito
    from todos_data_lake_trusted_feegow.movimentacao
),
ct as (
select 
	id,
	movimentacao_id,
	parcelas,
	bandeira_cartao_id,
	numero_transacao,
	numero_autorizacao 
    from todos_data_lake_trusted_feegow.transacao_cartao
),
bc as (
select 
	id,
	bandeira 
    from todos_data_lake_trusted_feegow.bandeiras_cartao
),
i as (
select 
	recurrence,
	credito_debito,
	sys_active,
	id,
	conta_id,
	associacao_conta_id,
	unidade_id,
	tabela_particular_id
    from todos_data_lake_trusted_feegow.contas
),
ii as (
select 
	id,
	conta_id,
	pacote_id,
	categoria_id,
	procedimento_id,
	tipo_item_id,
	quantidade,
	valor_unitario,
	acrescimo,
	desconto,
	is_executado,
	is_cancelado
    from todos_data_lake_trusted_feegow.conta_itens
),
pii as (
select 
	id
    from todos_data_lake_trusted_feegow.pacotes
),
movpay as (
select 
	id,
	"data",
	sys_user 
    from todos_data_lake_trusted_feegow.movimentacao
),
fdpay as (
select 
	pagamento_id,
	parcela_id
    from todos_data_lake_trusted_feegow.pagamento_associacao
),
idesc as (
select 
	valor,
	item_id,
	pagamento_id
    from todos_data_lake_trusted_feegow.pagamento_item_associacao
),
pacconta as(
select 
	cpf,
	id,
	nome_paciente
    from todos_data_lake_trusted_feegow.pacientes
),
subcat as (
select 
	id,
	name,
	category
    from todos_data_lake_trusted_feegow.planodecontas_receitas
),
cat as (
select 
	id,
	name
    from todos_data_lake_trusted_feegow.planodecontas_receitas
),
proc as (
select 
	id,
	nome_procedimento,
	grupo_procedimento_id,
	tipo_procedimento_id
    from todos_data_lake_trusted_feegow.procedimentos
),
prod as (
select 
	id
    from todos_data_lake_trusted_feegow.produtos
),
procgrup as (
select 
	id,
	sysactive,
	nomegrupo
    from todos_data_lake_trusted_feegow.procedimentos_grupos
),
unit as (
select
  id, 
  regiao_id,
  nome_fantasia,
  cnpj,
  nome_unidade,
  endereco,
  complemento,
  cep,
  numero,
  bairro,
  cidade,
  estado,
  tel1,
  tel2,
  cel1,
  email1
    from todos_data_lake_trusted_feegow.unidades
),
pag3 as (
select 
	id
    from todos_data_lake_trusted_feegow.pacientes
),
pag2 as (
select 
	id 
    from todos_data_lake_trusted_feegow.fornecedores
),
pag6 as (
select 
	id 
    from todos_data_lake_trusted_feegow.convenios
),
tp as (
select 
	id,
	nome_tabela_particular
    from todos_data_lake_trusted_feegow.tabelas_particulares
),
users as (
select 
	id,
	id_relativo 
    from todos_data_lake_trusted_feegow.usuarios
),
func as (
select 
	id
    from todos_data_lake_trusted_feegow.funcionarios
),
ur as (
select 
	id,
	descricao
    from todos_data_lake_trusted_feegow.unidades_regioes
),
final_query as (
select
	m."data" as data,
	m."data" as datavencimento, --alterado nomemclatura
	movpay."data" as datapagamento, --alterado nomemclatura
	pacconta.CPF cpfpaciente, --alterado nomemclatura
  	i.recurrence, 
  	pacconta.id id_paciente,
  	pacconta.nome_paciente,
  	i.credito_debito,
  	proc.nome_procedimento,
  	proc.id as id_procedimento,
    procgrup.nomegrupo,
    i.sys_active,
    unit.nome_fantasia,
    unit.cnpj,
	 unit.nome_unidade,
	  unit.endereco,
	  unit.complemento,
	  unit.cep,
	  unit.numero,
	  unit.bairro,
	  unit.cidade,
	  unit.estado,
	  unit.tel1,
	  unit.tel2,
	  unit.cel1,
	  unit.email1,
    unit.id as id_unidade,
    max(ii.quantidade) as quantidade, --não suportou a subquery da antiga contas a receber rodando dentro do redshift -- a funcao max bate com a feegow quando analisado Batatais
    (CASE 
        WHEN 'S'='S' THEN (SUM(coalesce(idesc.valor, 0)))/ COALESCE(i.Recurrence, 1) 
        ELSE coalesce(m.Valor_Pago, 0) 
    END) Valor_Pago,
    m.descricao as descricaomovimentacao,
   (CASE
	WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) <= 0 then 'Quitado' 
        WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) > 0 and coalesce(m.valor_pago, 0) > 0 then 'Parcialmente pago' 
        ELSE 'Em aberto'
    END) situacaoconta,
     (case 
        when m.forma_pagamento_id IN (8,10) then ct.Parcelas 
        else 1 
    end) as parcelas, --alterado nomemclatura
    cat.name as categoria, --alterado nomemclatura
    subcat.name as subcategoria,
    tp.id as id_tabela,
    tp.nome_tabela_particular,
    ur.descricao as regional
        from m
            LEFT JOIN ct ON ct.movimentacao_id = m.id
            LEFT JOIN bc ON bc.id = ct.bandeira_cartao_id
            INNER JOIN i ON i.id = m.conta_id
            INNER JOIN ii ON ii.conta_id = i.id
            LEFT JOIN pii ON pii.id = ii.pacote_id
            LEFT JOIN fdpay ON fdpay.parcela_id = m.id
            LEFT JOIN movpay ON movpay.id = fdpay.pagamento_id
            LEFT JOIN idesc ON idesc.item_id = ii.id AND idesc.pagamento_id = movpay.id
            LEFT JOIN pacconta ON pacconta.id = i.conta_id AND i.associacao_conta_id = 3
            LEFT JOIN subcat ON subcat.id = ii.categoria_id
            LEFT JOIN cat ON cat.id = subcat.Category
            LEFT JOIN proc ON proc.id = ii.procedimento_id AND ii.tipo_item_id = 'S'
            LEFT JOIN prod ON prod.id = ii.procedimento_id AND ii.tipo_item_id = 'M'
            LEFT JOIN procgrup ON procgrup.id = proc.grupo_procedimento_id AND procgrup.sysActive = 1
            LEFT JOIN unit ON unit.id = i.unidade_id
            LEFT JOIN pag3 ON i.associacao_conta_id = 3 AND i.conta_id = pag3.id
            LEFT JOIN pag6 ON i.associacao_conta_id = 6 AND i.conta_id = pag6.id
            LEFT JOIN tp on tp.id = i.tabela_particular_id
            LEFT JOIN users on movpay.sys_user = users.id
            LEFT JOIN func on users.id_relativo = func.id			
            LEFT JOIN ur on ur.id = unit.regiao_id			
    WHERE
        m.tipo_movimentacao = 'Bill' 	    
        AND m.credito_debito = 'C' 	    
        AND ((ii.is_cancelado <> '1' AND ii.tipo_item_id = 'S') 		
        OR (ii.tipo_item_id != 'S')) 
	            AND (i.tabela_particular_id IN (NULL) OR 1=1) 	
        AND (ii.tipo_item_id IN (NULL) OR 1=1) 	
        AND (proc.grupo_procedimento_id IN (NULL) OR 1=1) 	    
        AND (proc.tipo_procedimento_id IN (NULL) OR 1=1) 	    
        AND ((case when 'N'='S' then ii.pacote_id IS NOT null else true end)) 	    
        AND         
        ((CASE         
            WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) <= 0 THEN 'quitado' 			
            WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) > 0  AND coalesce(m.Valor_Pago, 0) > 0 THEN 'parcial' 			
            ELSE 'aberto'
        END) in ('quitado', 'parcial') OR 1=0)
GROUP BY             
    (case when 'S'='S' then CONCAT(CONCAT(cast(m.id as varchar), ', '), cast(ii.id as varchar)) else cast(m.id as varchar) end),     
    i.sys_active, 
    ii.Quantidade,    
    ii.Valor_Unitario,    
    ii.Acrescimo,     
    ii.Desconto,     
    i.Recurrence,     
    m.valor,     
    m.valor_pago,
    m.data, 
    unit.nome_fantasia, 
    unit.id,    
    unit.nome_unidade,
    pacconta.CPF,     
    pacconta.id,     
    pacconta.nome_paciente,
    unit.cnpj,
    unit.endereco,
	unit.complemento,
	unit.cep,
	unit.numero,
	unit.bairro,
	unit.cidade,
	unit.estado,
	unit.tel1,
	unit.tel2,
	unit.cel1,
	unit.email1,
    i.credito_debito,    
    proc.nome_procedimento, 
    procgrup.nomegrupo,    
    proc.id,     
    m.descricao,     
    m.forma_pagamento_id,     
    ct.parcelas,     
    cat.name,     
    subcat.name,     
    m.conta_id,	
    tp.id,     
    tp.nome_tabela_particular,     
    ur.descricao,     
    m.id,     
    movpay.data
ORDER BY 
    m.Data, 
    m.id   
)
select 
	extract (month from datapagamento) as mes_pagamento,
	extract (year from datapagamento) as ano_pagamento,
	cast(null as INTEGER) as cnpjfilial, 
	cast(null as INTEGER) as filial,
	cnpj, 
	nome_unidade as nomecliente,
	'j' as tipo,
	nome_fantasia as nomefantasia,
	endereco,
	complemento,
	bairro,
	estado,
	cast(null as INTEGER) as codigomunicipio,
	cidade as municipio,
	cep,
	COALESCE(
    CASE WHEN tel1 IS NOT NULL AND tel1 != '' THEN REGEXP_REPLACE(SUBSTRING(tel1 FROM 2 FOR 4), '[^0-9]', '') END,
    CASE WHEN tel2 IS NOT NULL AND tel2 != '' THEN REGEXP_REPLACE(SUBSTRING(tel2 FROM 2 FOR 4), '[^0-9]', '') END,
    CASE WHEN cel1 IS NOT NULL AND cel1 != '' THEN REGEXP_REPLACE(SUBSTRING(cel1 FROM 2 FOR 4), '[^0-9]', '') END
) AS ddd,
COALESCE(
    CASE WHEN tel1 IS NOT NULL AND tel1 != '' THEN REGEXP_REPLACE(SUBSTRING(tel1 FROM 6), '\\s|-', '') END,
    CASE WHEN tel2 IS NOT NULL AND tel2 != '' THEN REGEXP_REPLACE(SUBSTRING(tel2 FROM 6), '\\s|-', '') END,
    CASE WHEN cel1 IS NOT NULL AND cel1 != '' THEN REGEXP_REPLACE(SUBSTRING(cel1 FROM 6), '\\s|-', '') END
) AS telefone,
email1 as email,
nome_procedimento as descricao,
sum(valor_pago) as valor
	from final_query
	where 1=1
	and data = date('2023-01-10')
	and nome_fantasia = 'AmorSaúde Contagem'
group by
	datapagamento,
	cnpj, 
	nome_unidade,
	nome_fantasia,
	endereco,
	complemento,
	bairro,
	estado,
	cidade,
	cep,
	tel1,
    tel2,
    cel1,
	email1,
	nome_procedimento

	

--modelagem referente ao clienteincluir
--MODELAGEM CLIENTE_INCLUIR
with units as (
  select
    id,
    cnpj,
    nome_fantasia,
    nome_unidade,
    estado,
    cidade,
    bairro,
    endereco,
    cep,
    numero,
    complemento,
    regiao_id,
    tel1,
    tel2,
    cel1,
    cel2,
    parceiro_institucional_id,
    regime_tributario_id,
    exibiragendamentoonline,
    email1,
    email2,
    medico_responsavel,
    cnes,
    sys_active,
    sys_user,
    dhup,
    grupo_unidade_id,
    consultor_responsavel,
    status_unidade_id
  from todos_data_lake_trusted_feegow.unidades
),
forn as (
  select
    id,
    nomefornecedor
  from todos_data_lake_trusted_feegow.fornecedores
),
ur as (
  select
    id,
    descricao
  from todos_data_lake_trusted_feegow.unidades_regioes
),
rt as (
  select
    id,
    nomeregimetributario
  from todos_data_lake_trusted_feegow.regimes_tributarios
),
prof as (
  select
    id,
    nome_profissional
  from todos_data_lake_trusted_feegow.profissionais
),
users as (
  select
    id,
    id_relativo
  from todos_data_lake_trusted_feegow.usuarios
),
func as (
  select
    id,
    nome_funcionario
  from todos_data_lake_trusted_feegow.funcionarios
),
gu as (
  select
    id,
    sigla,
    descricao
  from todos_data_lake_trusted_feegow.grupo_unidade
),
su as (
  select
    id,
    nome_status
  from todos_data_lake_trusted_feegow.status_unidade
), final_query as (
select 
  null as cnpjfilial, 
  null as filial, 
  null as codigomunicipio,
  units.id as id_unidade,
  units.cnpj,
  units.nome_fantasia,
  units.nome_unidade,
  ur.id,
  ur.descricao,
  units.estado,
  units.cidade,
  units.bairro,
  units.endereco,
  units.cep,
  units.numero,
  units.complemento,
  units.tel1,
  units.tel2,
  units.cel1,
  units.cel2,
  units.email1,
  units.email2,
  forn.nomefornecedor as franquia_cdt,
  rt.nomeregimetributario as regime_tributario,
  prof.nome_profissional as rt_medicina,
  case
    when units.exibiragendamentoonline  =1 then 'Sim'
    else 'Não'
  end as agendas_online,
  units.cnes,
  case
    when units.sys_active =1 then 'Ativo'
    when units.sys_active =-1 then 'Inativo'
  end as status_cadastro,
  func.nome_funcionario as usuario_cadastro,
  units.dhup as dt_atualizacao,
  gu.sigla as rating,
  gu.descricao as desc_rating,
  units.consultor_responsavel,
  su.nome_status as status
from units
  inner join forn on forn.id = units.parceiro_institucional_id
  left join ur on units.regiao_id = ur.id
  left join rt on units.regime_tributario_id = rt.id
  left join prof on units.medico_responsavel = prof.id
  left join users on units.sys_user = users.id
  left join func on users.id_relativo = func.id
  left join gu on units.grupo_unidade_id = gu.id
  left join su on units.status_unidade_id = su.id
)
select 
	cnpj, 
	nome_unidade as nomecliente,
	'j' as tipo,
	nome_fantasia as nomefantasia,
	endereco,
	complemento,
	bairro,
	estado,
	cidade as municipio,
	cep,
	COALESCE(
    CASE WHEN tel1 IS NOT NULL AND tel1 != '' THEN REGEXP_REPLACE(SUBSTRING(tel1 FROM 2 FOR 4), '[^0-9]', '') END,
    CASE WHEN tel2 IS NOT NULL AND tel2 != '' THEN REGEXP_REPLACE(SUBSTRING(tel2 FROM 2 FOR 4), '[^0-9]', '') END,
    CASE WHEN cel1 IS NOT NULL AND cel1 != '' THEN REGEXP_REPLACE(SUBSTRING(cel1 FROM 2 FOR 4), '[^0-9]', '') END
) AS ddd,
COALESCE(
    CASE WHEN tel1 IS NOT NULL AND tel1 != '' THEN REGEXP_REPLACE(SUBSTRING(tel1 FROM 6), '\\s|-', '') END,
    CASE WHEN tel2 IS NOT NULL AND tel2 != '' THEN REGEXP_REPLACE(SUBSTRING(tel2 FROM 6), '\\s|-', '') END,
    CASE WHEN cel1 IS NOT NULL AND cel1 != '' THEN REGEXP_REPLACE(SUBSTRING(cel1 FROM 6), '\\s|-', '') END
) AS telefone,
email1 as email,
dt_atualizacao
from final_query

select * from todos_data_lake_trusted_feegow.unidades 

	--where c.datapagamento between date('2023-08-01') and date('2023-08-15')
		
	--para verificar se dentro do datalake há registros
	SELECT count(*), m."data" 
	FROM todos_data_lake_trusted_feegow.movimentacao m
	where m."data" between date('2023-01-01') and current_date 
	group by m."data" 
	order by m."data" desc	

	
	
	
--MODELAGEM_consultas_crm PDGT
with ap as (
    select 
    agendamento_id,
    procedimento_id,
    local_id
      from todos_data_lake_trusted_feegow.agendamento_procedimentos
),
ag as (
    select 
    id,
    paciente_id,
    especialidade_id,
    status_id,
    data
      from todos_data_lake_trusted_feegow.agendamentos
),
p as (
    select 
   id,
   cpf,
   sexo,
   sys_user,
   sys_active
      from todos_data_lake_trusted_feegow.pacientes
),
ss as (
    select 
   id,
   nomesexo
      from todos_data_lake_trusted_feegow.sexo
),
ass as (
    select 
   id
      from todos_data_lake_trusted_feegow.agendamento_status
),
es as (
    select 
   id,
   nome_especialidade
      from todos_data_lake_trusted_feegow.especialidades
),
pro as (
    select 
   id,
   tipo_procedimento_id
      from todos_data_lake_trusted_feegow.procedimentos
),
pt as (
    select 
   id
     from todos_data_lake_trusted_feegow.procedimentos_tipos
),
l as (
    select 
   id,
   unidade_id
     from todos_data_lake_trusted_feegow.locais
),
u as (
    select 
   id,
   cidade,
   nome_fantasia
      from todos_data_lake_trusted_feegow.unidades
),
atendimento_consulta as (
select u.nome_fantasia as nome_unidade, u.cidade as cidade, trim(p.cpf) as cpf, p.id as id_paciente, ss.nomesexo as sexo , 
	u.id, count(*) as qtde, es.nome_especialidade, ag."data" as dataagendamento
from ap
left join ag on ap.agendamento_id = ag.id
left join p on p.id = ag.paciente_id
left join ss on ss.id = p.sexo
left join ass on ag.status_id = ass.id
left join es on ag.especialidade_id = es.id
left join pro on ap.procedimento_id = pro.id
left join pt on pro.tipo_procedimento_id = pt.id
left join l on ap.local_id = l.id
left join u on l.unidade_id = u.id
where pt.id in (2, 9)
and ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
and ag."data" between  date('2020-01-01') and current_date 
and p.sys_user <> 0 --filtra usuários que estão fora da interface feegow
and p.sys_active = 1 --filtrar usuários ativos
group by p.id, trim(p.cpf), u.id, u.nome_fantasia, u.cidade, es.nome_especialidade, ag."data", ss.nomesexo),
--segundo objeto é criado para transpor as coluna de data, separando-as por ano com o extract e case when	
	year_col as (
select cpf, id_paciente, sexo, dataagendamento, nome_especialidade, qtde,
CASE 
		WHEN extract (year from dataagendamento) = 2020 THEN qtde END AS "2020",
CASE
		WHEN extract (year from dataagendamento) = 2021 THEN qtde END AS "2021",
CASE
		WHEN extract (year from dataagendamento) = 2022 THEN qtde END AS "2022",
CASE
		WHEN extract (year from dataagendamento) = 2023 THEN qtde END AS "2023",
CASE
		WHEN nome_especialidade = 'Clinica Médica' THEN max(dataagendamento) END AS "Last_date_clinica_medica",
CASE
		WHEN nome_especialidade = 'Oftalmologia' THEN max(dataagendamento) END AS "Last_date_Oftalmologia",
CASE
		WHEN nome_especialidade = 'Ginecologia' THEN max(dataagendamento) END AS "Last_date_Ginecologia",
CASE
		WHEN nome_especialidade = 'Ortopedia e Traumatologia' THEN max(dataagendamento) END AS "Last_date_Ortopedia",
CASE
		WHEN nome_especialidade = 'Cardiologia' THEN max(dataagendamento) END AS "Last_date_Cardiologia"
from atendimento_consulta
where 1=1
group by  cpf, id_paciente, sexo, dataagendamento, nome_especialidade, qtde
),
--
qtde_paciente as (
select id_paciente as idp, sum(qtde) as total_consulta
from atendimento_consulta
group by id_paciente
),
--Objeto criado para trazer o máximo da data
datamax as (
select id_paciente as idp3, max(dataagendamento) as data_last_consulta
from year_col
group by id_paciente
)
--query final agrupando as informações
	select cpf, id_paciente, sexo, max(p.total_consulta) as total_consulta, d.data_last_consulta as ultima_consulta,
	date_diff('day', d.data_last_consulta, current_date)  as tempo_sem_uso,
	sum("2020") as "2020",
	sum("2021") as "2021",
	sum("2022") as "2022",
	sum("2023") as "2023",
	cast(null as INTEGER) as "2024",
	max(Last_date_clinica_medica) as Last_date_clinica_medica,
	max(Last_date_Oftalmologia) as Last_date_Oftalmologia,
	max(Last_date_Ginecologia) as Last_date_Ginecologia,
	max(Last_date_Ortopedia) as Last_date_Ortopedia,
	max(Last_date_Cardiologia) as Last_date_Cardiologia
	from year_col
	left join qtde_paciente p on p.idp =  id_paciente
	left join datamax d on d.idp3 = id_paciente
		where 1=1
		--and cpf is not null and cpf not in ('') --reitrar cpf's nulos
		and cpf <> '00000000000' --limpa cpf com 0
	group by cpf, id_paciente,sexo, data_last_consulta
	--order by cpf

--validando no sandbox
select * from pdgt_sandbox_gabrielguilherme.fl_consultas_crm


select * from todos_data_lake_trusted_feegow.profissionais
limit 10

select sellerid, details
from todos_data_lake_trusted_feegow.tef_autorizacao 
group by details, sellerid

select * from todos_data_lake_trusted_feegow.tabel

------------------------------------------------------------------------
--MODELAGEM_PROFISSIONAIS_INATIVAR
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
						WHERE sp.dhup BETWEEN date_add('day', -30, current_date) AND date_add('day', -1, current_date))
						--where sp.dhup between current_date - 30 and current_date - 1) --retirar profissionais atualziados nos últimos 15 dias (d-1)
	and sp.sys_active = 1
	and sp.ativo = 'on'
	and uu.id not in (0, 19774, 19793)
	--faixa de data de 15 dias do seu cadastro
),
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
	
select * from todos_data_lake_trusted_feegow.procedimentos_tabelas_precos 
	
------------------------------------------
--modelagem_IMPORTAÇÃO_DE_PROCEDIMENTOS
select
  u.id AS Unidades_id,
  u.nome_fantasia as Unidades_nome_fantasia,
  stg_procedimentos_tabelas_precos.id AS id,
  p.id AS Procedimentos_id,
  stg_procedimentos_tabelas_precos.nometabela,
  p.nome_procedimento AS Procedimentos_nome_procedimento
FROM todos_data_lake_trusted_feegow.procedimentos_tabelas_precos as stg_procedimentos_tabelas_precos
LEFT JOIN todos_data_lake_trusted_feegow.procedimentos_tabelas_precos_unidades AS ptpu ON stg_procedimentos_tabelas_precos.id = ptpu.procedimento_tabela_preco_id
  LEFT JOIN todos_data_lake_trusted_feegow.procedimentos_tabelas_precos_valores as ptpv ON stg_procedimentos_tabelas_precos.id = ptpv.tabelaid
  LEFT JOIN todos_data_lake_trusted_feegow.procedimentos AS p ON ptpv.procedimentoid = p.id
  LEFT JOIN todos_data_lake_trusted_feegow.unidades AS u ON ptpu.unidade_id = u.id
where 1=1 
 and p.ativo = 'on'
 and stg_procedimentos_tabelas_precos.id in(3024066, 3024345, 700506)
 and u.id = 19872
ORDER BY
  stg_procedimentos_tabelas_precos.nometabela DESC

 ---------------------------------------------------------------



--MODELAGEM_contas_a_receber

--a forma de pagamento apenas tem relaiconamento com PAY, e no contas a receber é filtrado apenas BILL
select *
from todos_data_lake_trusted_feegow.movimentacao m
left join todos_data_lake_trusted_feegow.formas_pagamento f on f.id = m.forma_pagamento_id 
left join todos_data_lake_trusted_feegow.formas_recebimentos fr on fr.metodoid = f.id
limit 1000



with m as (
select
	id,
	"data",
	conta_id,
	valor_pago,
	valor,
	descricao,
	forma_pagamento_id,
	tipo_movimentacao,
	credito_debito
from todos_data_lake_trusted_feegow.movimentacao
),
ct as (
select 
	id,
	movimentacao_id,
	parcelas,
	bandeira_cartao_id,
	numero_transacao,
	numero_autorizacao
from todos_data_lake_trusted_feegow.transacao_cartao
),
bc as (
select 
	id,
	bandeira
from todos_data_lake_trusted_feegow.bandeiras_cartao
),
i as (
select 
	recurrence,
	credito_debito,
	sys_active,
	id,
	conta_id,
	associacao_conta_id,
	unidade_id,
	tabela_particular_id
from todos_data_lake_trusted_feegow.contas
),
ii as (
select 
	id,
	conta_id,
	pacote_id,
	categoria_id,
	procedimento_id,
	tipo_item_id,
	quantidade,
	valor_unitario,
	acrescimo,
	desconto,
	is_executado,
	is_cancelado,
    executante_associacao_id,
    executante_id
from todos_data_lake_trusted_feegow.conta_itens
),
iii as (
select 
	id,
	conta_id,
	pacote_id,
	categoria_id,
	procedimento_id,
	tipo_item_id,
	quantidade,
	valor_unitario,
	acrescimo,
	desconto,
	is_executado,
	is_cancelado,
    executante_associacao_id,
    executante_id
from todos_data_lake_trusted_feegow.conta_itens
),
pii as (
select 
	id
from todos_data_lake_trusted_feegow.pacotes
),
movpay as (
select 
	id,
	"data",
	sys_user,
	forma_pagamento_id
from todos_data_lake_trusted_feegow.movimentacao
),
fdpay as (
select 
	pagamento_id,
	parcela_id
from todos_data_lake_trusted_feegow.pagamento_associacao
),
idesc as (
select 
	valor,
	item_id,
	pagamento_id
from todos_data_lake_trusted_feegow.pagamento_item_associacao
),
pacconta as(
select 
	cpf,
	id,
	nome_paciente
from todos_data_lake_trusted_feegow.pacientes
),
subcat as (
select 
	id,
	name,
	category
from todos_data_lake_trusted_feegow.planodecontas_receitas
),
cat as (
select 
	id,
	name
from todos_data_lake_trusted_feegow.planodecontas_receitas
),
proc as (
select 
	id,
	nome_procedimento,
	grupo_procedimento_id,
	tipo_procedimento_id
from todos_data_lake_trusted_feegow.procedimentos
),
prod as (
select 
	id
from todos_data_lake_trusted_feegow.produtos
),
procgrup as (
select 
	id,
	sysactive,
	nomegrupo
from todos_data_lake_trusted_feegow.procedimentos_grupos
),
unit as (
select 
	id, 
	nome_fantasia, 
	regiao_id
from todos_data_lake_trusted_feegow.unidades
),
pag3 as (
select 
	id
from todos_data_lake_trusted_feegow.pacientes
),
sf as (
select 
	id
from todos_data_lake_trusted_feegow.fornecedores
),
pag6 as (
select 
	id
from todos_data_lake_trusted_feegow.convenios
),
tp as (
select 
	id,
	nome_tabela_particular
from todos_data_lake_trusted_feegow.tabelas_particulares
),
users as (
select 
	id,
	id_relativo
from todos_data_lake_trusted_feegow.usuarios
),
func as (
select 
	id,
	nome_funcionario
from todos_data_lake_trusted_feegow.funcionarios
),
ur as (
select 
	id,
	descricao
from todos_data_lake_trusted_feegow.unidades_regioes --add
),
spt as ( --adicionado para atender demanda dsa Gabriela Georgete
select
	id,
	tipoprocedimento
from todos_data_lake_trusted_feegow.procedimentos_tipos --add
),
sfdp as ( --adicionado para atender demanda dsa Gabriela Georgete
select
	id,
	forma_pagamento
from todos_data_lake_trusted_feegow.formas_pagamento --add
),
sca as ( --adicionado para atender demanda dsa Gabriela Georgete
select
	id
from todos_data_lake_trusted_feegow.conta_associacoes --add
),
prof as ( --adicionado para atender demanda dsa Gabriela Georgete
select
	id
from todos_data_lake_trusted_feegow.profissionais --add
),
idprof as ( --adicionado para trazer o id do profissional
select distinct
	ii.id as id_contas, 
	prof.id as id_pofissional
from i 
left join ii on ii.conta_id = i.id
left join sca on sca.id = ii.executante_associacao_id and sca.id = 5 --filtrando status que indica que foi um profissional que executou
left join prof on prof.id = ii.executante_id
),
forn as ( -- add para atender demanda Gabriela Georgete --busca o id do fornecedor, para buscar dados do mesmo.
select distinct ii.id as id_contas_, sf.id as id_fornecedor
from m
left join i on i.id = m.conta_id
left join ii on ii.conta_id = i.id
left join sca on sca.id = ii.executante_associacao_id
left join sf ON i.associacao_conta_id =2 AND i.conta_id = sf.id
),
final_query as (
select *,
	    (case
		when 'S' = 'S' then (SUM(coalesce(idesc.valor, 0)))/ coalesce(i.Recurrence,	1)
		else coalesce(m.Valor_Pago,	0)	end) Valor_Pago,
		m.descricao as descricaomovimentacao,
	(case	
		when m.valor - (coalesce(m.valor_pago,	0) + 0.3) <= 0 then 'Quitado' when m.valor - (coalesce(m.valor_pago, 0) + 0.3) > 0
		and coalesce(m.valor_pago,
		0) > 0 then 'Parcialmente pago'
		else 'Em aberto'
	end) SituacaoConta,
	(case when m.forma_pagamento_id in (8, 10) then ct.Parcelas
		else 1
	end) as Parcelas
from m 
inner join i on	i.id = m.conta_id
inner join ii on ii.conta_id = i.id
left join idprof on idprof.id_contas = ii.id --relacionamento adicionado para atender demanda Gabriela Georgete
left join pii on pii.id = ii.pacote_id
left join fdpay on	fdpay.parcela_id = m.id
left join movpay on	movpay.id = fdpay.pagamento_id
left join forn on forn.id_contas_ = ii.id --relacionamento adicionado para atender demanda Gabriela Georgete
left join sfdp on sfdp.id = movpay.forma_pagamento_id --relacionamento adicionado para atender demanda Gabriela Georgete
left join ct on ct.movimentacao_id = movpay.id --alterado relacionamento de m para movpay
left join bc on	bc.id = ct.bandeira_cartao_id 
left join idesc on	idesc.item_id = ii.id	and idesc.pagamento_id = movpay.id
left join pacconta on pacconta.id = i.conta_id and i.associacao_conta_id = 3
left join subcat on	subcat.id = ii.categoria_id
left join cat on cat.id = subcat.Category
left join proc on proc.id = ii.procedimento_id and ii.tipo_item_id = 'S'
left join prod on prod.id = ii.procedimento_id and ii.tipo_item_id = 'M'
left join procgrup on procgrup.id = proc.grupo_procedimento_id	and procgrup.sysActive = 1
left join spt on spt.id = proc.tipo_procedimento_id --relacionadomento adicionado para atender demanda Gabriela Georgete
left join unit on unit.id = i.unidade_id
left join pag3 on i.associacao_conta_id = 3 and i.conta_id = pag3.id
left join pag6 on i.associacao_conta_id = 6 and i.conta_id = pag6.id
left join tp on	tp.id = i.tabela_particular_id
left join users on movpay.sys_user = users.id
left join func on users.id_relativo = func.id
left join ur on	ur.id = unit.regiao_id
where m.tipo_movimentacao = 'Bill'
	and m.credito_debito = 'C'
	and ((ii.is_cancelado <> '1'
		and ii.tipo_item_id = 'S')
	or (ii.tipo_item_id != 'S'))
	and (i.tabela_particular_id in (null)
		or 1 = 1)
	and (ii.tipo_item_id in (null)
		or 1 = 1)
	and (proc.grupo_procedimento_id in (null)
		or 1 = 1)
	and (proc.tipo_procedimento_id in (null)
		or 1 = 1)
	and ((case
		when 'N' = 'S' then ii.pacote_id is not null
		else true
	end))
	and  ((case
		when m.valor - (coalesce(m.valor_pago,
		0) + 0.3) <= 0 then 'quitado'
		when m.valor - (coalesce(m.valor_pago,
		0) + 0.3) > 0
			and coalesce(m.Valor_Pago,
			0) > 0 then 'parcial'
			else 'aberto'
		end) in ('quitado', 'parcial')
		or 1 = 0)
group by
	(case
		when 'S' = 'S' then CONCAT(CONCAT(cast(m.id as varchar),
		', '),
		cast(ii.id as varchar))
		else cast(m.id as varchar)
	end),
	i.sys_active,
	ii.Quantidade,
	ii.Valor_Unitario,
	ii.Acrescimo,
	ii.Desconto,
	i.Recurrence,
	m.valor,
	m.valor_pago,
	unit.nome_fantasia,
	unit.id,
	m.data,
	pacconta.CPF,
	pacconta.id,
	pacconta.nome_paciente,
	unit.nome_fantasia,
	--i.credito_debito,
	sfdp.forma_pagamento, --add demanda Georgete
	proc.nome_procedimento,
	procgrup.nomegrupo,
	proc.id,
	spt.tipoprocedimento, --add demanda Georgete
	m.descricao,
	m.forma_pagamento_id,
	ct.parcelas,
	cat.name,
	subcat.name,
	m.conta_id,
	tp.id,
	tp.nome_tabela_particular,
	ur.id, --add
	ur.descricao,
	m.id,
	movpay.data,
	func.id, --add demanda Georgete
	idprof.id_pofissional,  --add demanda Georgete
	--bc.bandeira, --add demanda Uarlass 
	forn.id_fornecedor,
    valor_pago
order by
	m.Data,
	m.id)
select
sum(qtde_real)
	--when datapagamento >= date_add('day', 1 - extract(day from current_date), current_date) AND extract(day from current_date) >= 20
	--THEN date_format(date_add('day', -4, datapagamento), '%Y-%m')
	--end as snap
	--case
	--WHEN EXTRACT(MONTH FROM datapagamento) = EXTRACT(MONTH FROM current_date) or EXTRACT(MONTH FROM datapagamento) = EXTRACT(MONTH FROM date_add('day', -4, current_date)) 
	--THEN date_format(date_add('day', -4, datapagamento), '%Y-%m')
	--end as snap,
	--CONCAT(CAST(moviid AS VARCHAR), CAST(datapagamento AS VARCHAR), CAST(id_procedimento AS VARCHAR)) AS uniquekey
	--date_format(date_add('day', -4, current_date), '%Y-%m') as snap
from
	final_query
where 1=1
--AND datapagamento >= date_add('day', 1 - extract(day from current_date), current_date) 
and datapagamento between date('2024-01-02') and date('2024-01-02') --aqui vocês podem alterar para validação
and id_unidade =  19680--19680 --aqui vocês podem alterar para validação
--and nomegrupo in ('Exames Laboratoriais', 'Exames de Imagem', 'Procedimentos', 'Sessão', 'Cirurgia geral', 'Cirurgia Oftalmológica', 'Vacinas',' Terapias Injetaveis')




select 
* 
from pdgt_sandbox_gabrielguilherme.fl_contas_a_receber_frozen
--where  datapagamento between date('2023-11-10') and date('2023-11-13') --filtro de data

--contas a receber
SELECT --id_unidade, nome_unidade, nomegrupo, count(nomegrupo), 
sum(valor_pago) , count(*)
FROM pdgt_amorsaude_financeiro.fl_contas_a_receber
WHERE datapagamento BETWEEN DATE ('2023-11-04') AND DATE ('2023-11-04')
--group by id_unidade, nome_unidade, nomegrupo 
--order by id_unidade, nomegrupo

select * from todos_data_lake_trusted_feegow.movimentacao limit 1

select * from todos_data_lake_trusted_feegow.unidades u
where u.nome_fantasia like 'AmorSaúde BH Barreiro%'
or u.nome_fantasia like 'AmorSaúde Batatais%'

-- add para atender demanda Gabriela Georgete --busca o id do fornecedor, para buscar dados do mesmo.
select *
from todos_data_lake_trusted_feegow.movimentacao m
left join todos_data_lake_trusted_feegow.contas i on i.id = m.conta_id
left join todos_data_lake_trusted_feegow.conta_itens ii on ii.conta_id = i.id
left join todos_data_lake_trusted_feegow.conta_associacoes sca on sca.id = ii.executante_associacao_id
left join todos_data_lake_trusted_feegow.fornecedores sf ON i.associacao_conta_id =2 AND i.conta_id = sf.id
where m.unidade_id = 19957
and m.id = 148082676
and m."data" between date('2023-11-01') and date('2023-11-16')
limit 100

--MODELAGEM_unidades
--essa modelagem comporta a pasta pdgt_amorsaude_backoffice
--fl_unidades
with units as (
  select
    id,
    cnpj,
    nome_fantasia,
    nome_unidade,
    estado,
    cidade,
    bairro,
    endereco,
    cep,
    numero,
    complemento,
    regiao_id,
    tel1,
    tel2,
    cel1,
    cel2,
    parceiro_institucional_id,
    regime_tributario_id,
    exibiragendamentoonline,
    email1,
    email2,
    medico_responsavel,
    cnes,
    sys_active,
    sys_user,
    dhup,
    grupo_unidade_id,
    consultor_responsavel,
    status_unidade_id,
    dddauto, --add
    zoopsellerid --add
  from todos_data_lake_trusted_feegow.unidades
),
forn as (
  select
    id,
    nomefornecedor
  from todos_data_lake_trusted_feegow.fornecedores
),
ur as (
  select
    id,
    descricao
  from todos_data_lake_trusted_feegow.unidades_regioes
),
rt as (
  select
    id,
    nomeregimetributario
  from todos_data_lake_trusted_feegow.regimes_tributarios
),
prof as (
  select
    id,
    nome_profissional
  from todos_data_lake_trusted_feegow.profissionais
),
users as (
  select
    id,
    id_relativo
  from todos_data_lake_trusted_feegow.usuarios
),
func as (
  select
    id,
    nome_funcionario
  from todos_data_lake_trusted_feegow.funcionarios
),
gu as (
  select
    id,
    sigla,
    descricao
  from todos_data_lake_trusted_feegow.grupo_unidade
),
su as (
  select
    id,
    nome_status
  from todos_data_lake_trusted_feegow.status_unidade
)
select 
  units.id as id_unidade,
  units.cnpj,
  units.nome_fantasia,
  units.nome_unidade as razao_social,
  ur.id as id_regional,
  ur.descricao as regional,
  units.estado,
  units.cidade,
  units.bairro,
  units.endereco,
  units.cep,
  units.numero,
  units.complemento,
  units.tel1,
  units.tel2,
  units.cel1,
  units.cel2,
  units.email1,
  units.email2,
  units.dddauto, --add
  units.zoopsellerid, --add
  units.parceiro_institucional_id, --add
  forn.nomefornecedor as franquia_cdt,
  rt.nomeregimetributario as regime_tributario,
  prof.nome_profissional as rt_medicina,
  case
    when units.exibiragendamentoonline  =1 then 'Sim'
    else 'Não'
  end as agendas_online,
  units.cnes,
  case
    when units.sys_active =1 then 'Ativo'
    when units.sys_active =-1 then 'Inativo'
  end as status_cadastro,
  func.nome_funcionario as usuario_cadastro,
  units.dhup as dt_atualizacao_cadastro,
  gu.sigla as rating,
  gu.descricao as desc_rating,
  units.consultor_responsavel,
  su.nome_status as status
from units
  inner join forn on forn.id = units.parceiro_institucional_id
  left join ur on units.regiao_id = ur.id
  left join rt on units.regime_tributario_id = rt.id
  left join prof on units.medico_responsavel = prof.id --alterado por pedido do Maicom
  left join users on units.sys_user = users.id --alterado por pedido do Maicon 
  left join func on users.id_relativo = func.id
  left join gu on units.grupo_unidade_id = gu.id
  left join su on units.status_unidade_id = su.id
  
  
  select * from todos_data_lake_trusted_feegow.unidades 
  limit 1
  
  
  --MODELAGEM_contas_a_pagar
  --alteração: foram adicionados campos demandados pela acessora do presidente Altair.
  WITH ParcelaData AS (
SELECT
  disc.parcela_id,
  MIN(mp.data) AS DataPagamento
    from todos_data_lake_trusted_feegow.pagamento_associacao disc
      INNER JOIN todos_data_lake_trusted_feegow.movimentacao mp ON mp.id = disc.pagamento_id
  GROUP BY disc.parcela_id
),
ur AS (
SELECT 
	id,
	descricao
    from todos_data_lake_trusted_feegow.unidades_regioes
),
u AS (
SELECT 
	id,
	nome_fantasia,
	regiao_id
    from todos_data_lake_trusted_feegow.unidades
),
i as (
select 
	id,
	credito_debito,
	valor,
	unidade_id,
	associacao_conta_id,
	conta_id,
	sys_active
    from todos_data_lake_trusted_feegow.contas
),
ii as (
select 
	id,
	procedimento_id,
	categoria_id,
	executante_id,
	desconto,
	quantidade,
	valor_unitario,
	acrescimo,
	conta_id,
	descricao -- add
    from todos_data_lake_trusted_feegow.conta_itens
),
idesc as (
select 
	id,
	item_id,
	pagamento_id,
	valor
    from todos_data_lake_trusted_feegow.pagamento_item_associacao
),
m as (
select 
	id,
	"data",
	data_hora,
	conta_id,
	valor,
	valor_pago,
	descricao,
	tipo_movimentacao,
	credito_debito,
	sys_user, -- add
	caixa_id
  from todos_data_lake_trusted_feegow.movimentacao
),
invrat as (
select 
	conta_id, 
	porcentagem
	  from todos_data_lake_trusted_feegow.invoice_rateio
),
ass as (
select 
	id,
	tabela_associacao
    from todos_data_lake_trusted_feegow.conta_associacoes
),
prod as (
select 
	id
    from todos_data_lake_trusted_feegow.produtos
),
subcat as (
select 
	id,
	name,
	category
    from todos_data_lake_trusted_feegow.planodecontas_despesas
),
dp as (
select 
	parcela_id,
	pagamento_id 
    from todos_data_lake_trusted_feegow.pagamento_associacao
),
movpay as (
select 
  id,
  forma_pagamento_id,
  caixa_id,
  conta_id_credito
    from todos_data_lake_trusted_feegow.movimentacao
),
cat as (
select 
  id,
  name
    from todos_data_lake_trusted_feegow.planodecontas_despesas
),
su as ( -- add
select 
  id,
  id_relativo
    from todos_data_lake_trusted_feegow.usuarios
),
scit as ( -- add
select 
  id,
  descricao
    from todos_data_lake_trusted_feegow.conta_item_tipos
),
sf as ( -- add
select 
  id,
  nome_funcionario
    from todos_data_lake_trusted_feegow.funcionarios
),
sfdp as ( --adicionado para atender Uarlass
select
	id,
	forma_pagamento
from todos_data_lake_trusted_feegow.formas_pagamento --add
), 
ct as ( -- add Uarlass
select 
	id,
	movimentacao_id,
	parcelas,
	bandeira_cartao_id,
	numero_transacao,
	numero_autorizacao
from todos_data_lake_trusted_feegow.transacao_cartao
),
bc as ( -- add Uarlass
select 
	id,
	bandeira
from todos_data_lake_trusted_feegow.bandeiras_cartao
),
crr as (
select 
	distinct
	d.id,
	d.nome_conta_corrente,
	c.tipo_conta_corrente
from todos_data_lake_trusted_feegow.contas_correntes d
left join  todos_data_lake_trusted_feegow.tipo_conta_corrente c on c.id = d.tipo_conta_corrente
),
final_query as (
select
m.id,
	pd.DataPagamento,
	ur.id as id_regional,
	ur.descricao as nm_regional,
	u.id as id_unidade,
	u.nome_fantasia as nm_unidade,
	i.credito_debito,
	ii.valor_unitario,
	ii.desconto as desconto,
	ii.acrescimo,
	(COALESCE((m.valor / NULLIF(i.valor, 0)), 1) * (ii.Quantidade * (ii.valor_unitario + ii.acrescimo - ii.desconto))) * COALESCE(COALESCE(invrat.porcentagem / 100, 1), 1) AS ValorTotal,
	(CASE WHEN current_date > m.data THEN (m.valor - COALESCE(m.valor_pago, 0)) ELSE 0 END) * COALESCE(COALESCE(invrat.porcentagem / 100, 1), 1) AS ValorVencido,
	((ii.Quantidade * (ii.valor_unitario + ii.acrescimo - ii.desconto)) - (SUM(COALESCE(idesc.valor, 0)))) * COALESCE(COALESCE(invrat.porcentagem / 100, 1), 1) AS ValorAPagar,
    (CASE 
      WHEN m.valor - (COALESCE(m.valor_pago, 0) + 0.3) <= 0 THEN 'Quitado'
      WHEN m.valor - (COALESCE(m.valor_pago, 0) + 0.3) > 0 AND COALESCE(m.valor_pago, 0) > 0 THEN 'Parcialmente pago'    
      ELSE 'Em aberto'       
    END) AS SituacaoConta,
    m.descricao,
    m.data,
    (SUM(COALESCE(idesc.valor, 0))) * (COALESCE((invrat.porcentagem / 100), 1)) AS ValorPago,
    CASE     
      WHEN cat.id IS NULL THEN NULL       
      ELSE subcat.Name       
    END AS Subcategoria,
    COALESCE(cat.Name, subcat.Name) AS Categoria,
    bc.bandeira, --add demanda Uarlass
	sfdp.forma_pagamento, --add demanda Georgete
    sf.nome_funcionario, -- add
      (SELECT COUNT(id)
        FROM todos_data_lake_trusted_feegow.movimentacao
        WHERE conta_id = i.id      
      ) AS Parcelas,
    CONCAT(CAST((SELECT COUNT(id)
        FROM todos_data_lake_trusted_feegow.movimentacao
            WHERE conta_id = i.id AND Data <= m.data) AS VARCHAR), '/', 													
						CAST((SELECT COUNT(id)
                    	FROM todos_data_lake_trusted_feegow.movimentacao
                        WHERE conta_id = i.id) AS VARCHAR)															 
	) AS Parcela,
	 ii.descricao as conta_intens_descricao, -- add
	   crr.nome_conta_corrente,
	   crr.tipo_conta_corrente
	FROM m 
	INNER JOIN i on i.id = m.conta_id
	LEFT JOIN u on i.unidade_id = u.id
	LEFT JOIN ur on u.regiao_id = ur.id
	JOIN ass ON ass.id = i.associacao_conta_id
	INNER JOIN ii ON ii.conta_id = i.id
	LEFT JOIN prod ON prod.id = ii.procedimento_id AND Tipo_movimentacao = 'M'
	LEFT JOIN subcat ON subcat.id = ii.categoria_id
	LEFT JOIN invrat ON invrat.conta_id = i.id
	LEFT JOIN dp ON dp.parcela_id = m.id
	LEFT JOIN idesc ON idesc.item_id = ii.id AND idesc.pagamento_id = dp.pagamento_id
	LEFT JOIN movpay ON movpay.id = idesc.pagamento_id
	LEFT JOIN cat ON cat.id = subcat.Category
	LEFT JOIN ParcelaData pd ON pd.parcela_id = m.id
	left join su on su.id = m.sys_user --add
	left join sf on sf.id = su.id_relativo --add
	left join scit on scit.id = ii.id --add
	left join sfdp on sfdp.id = movpay.forma_pagamento_id -- add Uarlass
	left join ct on ct.movimentacao_id = movpay.id -- add Uarlas
	left join bc on	bc.id = ct.bandeira_cartao_id -- add Uarlas
	left join crr on crr.id = movpay.conta_id_credito --add Uarlas --teve que ser adicionado o distinct, gerava cardinalidade
	WHERE m.tipo_movimentacao = 'Bill'
	AND m.credito_debito = 'D'
	AND pd.DataPagamento BETWEEN date('2021-01-01') AND current_date
	AND i.sys_active = 1
    AND (i.associacao_conta_id IN (2, 3, 4, 5, 6, 8))
    AND 	
		(CASE 		
			WHEN m.valor - (COALESCE(m.valor_pago, 0) + 0.3) <= 0 THEN 'quitado'
            WHEN m.valor - (COALESCE(m.valor_pago, 0) + 0.3) > 0 AND COALESCE(m.valor_pago, 0) > 0 THEN 'parcial'
            ELSE 'aberto' 			
		END) IN ('parcial', 'quitado')
GROUP BY 
	pd.DataPagamento,
	ur.id,
	ur.descricao,
	u.id,
	u.nome_fantasia,
	i.id,
	m.id,
	m.descricao,
	m.data_hora,
	i.credito_debito,
	m.valor,
	i.valor,
	ii.desconto,
	ii.quantidade,
	ii.valor_unitario,
	ii.acrescimo,
	invrat.porcentagem,
	ii.desconto,
	m.valor_pago,
	idesc.valor,
	i.conta_id,
	m.data,
	cat.id,
	subcat.name,
	subcat.name,
	cat.name,
	ass.tabela_associacao,
	sf.nome_funcionario, --add a pedido do Uarlas
	ii.descricao, -- add  a pedido do Uarlas
	bc.bandeira, --add demanda Uarlass
	sfdp.forma_pagamento, --add demanda Georgete-- add a pedido do Uarlas
	crr.nome_conta_corrente,
	crr.tipo_conta_corrente
ORDER BY 
	m.data, 
	m.data_hora	
)
select sum(valorpago) as valorpago, sum(valor_unitario) as valor_unitario, sum(ValorTotal) as ValorTotal,
sum(ValorVencido) as ValorVencido, sum(ValorAPagar) as ValorAPagar
from final_query
where DataPagamento between date('2023-11-01') and date('2023-11-26')
--and nm_unidade like 'AmorSaúde Patos de Minas%'
	--and categoria = 'Sócios'
	--and subcategoria = 'Aporte'
	--group by nome_conta_corrente
limit 1000


select --sum(valortotal) as valortotal , 
--sum(valorvencido) as valorvencido ,
--sum(valorapagar) as valorapagar , 
sum(valorpago) as valorpago  
from pdgt_amorsaude_financeiro.fl_contas_a_pagar 
WHERE datapagamento  BETWEEN DATE ('2023-11-01') AND DATE('2023-11-26')
--group by id_unidade, nm_unidade 


select sum(valortotal) as valortotal , sum(valorvencido) as valorvencido ,
sum(valorapagar) as valorapagar , sum(valorpago) as valorpago  
from pdgt_sandbox_gabrielguilherme.fl_contas_a_pagar 
WHERE datapagamento  BETWEEN DATE ('2023-11-01') AND DATE('2023-11-26')
--group by id_unidade, nm_unidade 


select id_unidade, nm_unidade, sum(valortotal) as valortotal , sum(valorvencido) as valorvencido ,
sum(valorapagar) as valorapagar , sum(valorpago) as valorpago  
from pdgt_amorsaude_financeiro.fl_contas_a_pagar 
WHERE datapagamento  BETWEEN DATE('2023-11-01') AND DATE('2023-11-26')
group by id_unidade, nm_unidade 
order by id_unidade


-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
--MODELAGEM_PROFISSIONAIS PDGT_BACKOFFICE
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
    sys_date,
    centro_custo_id,
    observacoes
      from todos_data_lake_trusted_feegow.profissionais
),
cp as (
  select 
    id,
    descricao
      from todos_data_lake_trusted_feegow.conselhos_profissionais
),
pu as (
  select 
  profissional_id,
  unidade_id
from todos_data_lake_trusted_feegow.profissionais_unidades
),
u as (
  select 
  id,
  regiao_id,
  nome_fantasia
from todos_data_lake_trusted_feegow.unidades
),
spe as (
  select 
  profissional_id,
  especialidade_id,
  conselho,
  uf_conselho,
  documento_conselho,
  rqe
from todos_data_lake_trusted_feegow.profissional_especialidades
),
esp as (
  select 
  id,
  nome_especialidade
from todos_data_lake_trusted_feegow.especialidades
)
select
prof.id as id_profissional,
prof.nome_profissional as nm_profissional,
cp.id as id_conselho,
cp.descricao as conselho,
prof.documento_conselho as nro_conselho,
prof.nascimento,
prof.cpf,
spe.rqe,
esp.nome_especialidade,
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
prof.centro_custo_id,
prof.observacoes,
case
when prof.sys_active = -1 then 'Inativo'
when prof.sys_active = 1 then 'Ativo'
end as status_cadastro
from prof
left join cp on prof.conselho_id = cp.id
left join pu on prof.id = pu.profissional_id
left join spe on	spe.profissional_id = prof.id
left join u on pu.unidade_id = u.id
left join esp on esp.id = spe.especialidade_id



------------------------------------------------------
--MODELAGEM_funcionários

select * from todos_data_lake_trusted_feegow.funcionarios_unidades 
limit 10

from todos_data_lake_trusted_feegow.funcionarios sf 
left join todos_data_lake_trusted_feegow.funcionario_enderecos sfe on sfe.funcionario_id = sf.id 
left join todos_data_lake_trusted_feegow.funcionarios_unidades sfu on sfu.funcionario_id = sf.id 

with func as (
select
    id as id_func,
	nome_funcionario,
	sys_user,
	ativo,
	sys_active,
	nascimento,
	cpf,
	sexo_id,
	celular,
	estado,
	cidade,
	email,
	unidade_id,
	centro_custo_id,
	dhup,
	setor_colaborador,
	cargo_colaborador_unidade
    from todos_data_lake_trusted_feegow.funcionarios
	),
	func_end as (
	select
	id as id_func_end,
	nome_funcionario,
	funcionario_id,
	cidade,
	estado,
	bairro,
	endereco,
	cep,
	numero,
	complemento
	from todos_data_lake_trusted_feegow.funcionario_enderecos
	),
	func_uni as (
	select
	funcionario_id,
	unidade_id
	from todos_data_lake_trusted_feegow.funcionarios_unidades
	)
	select * from func
	left join  func_end on func_end.funcionario_id = func.id_func 
	left join  func_uni on func_uni.funcionario_id = func.id_func 
	
	
	--MODELAGEM_contas_bloqueio
	with bloq as (
	select 
id,
data,
sysuser_bloqueios,
sysuser_confirmacao,
vl_entrada,
vl_saida,
vl_saldo,
unidade_id,
sys_active,
dhup,
conta_bloqueio_status_id 
from todos_data_lake_trusted_feegow.contas_bloqueios
)
select * from bloq
	

	--MODELAGEM_LOG_MARCACOES
with log_m as (
select
    id,
    paciente_id,
    profissional_id,
    procedimento_id,
    datahora_feito,
    data_hora,
    data,
    hora,
    status_id,
    usuario,
    motivo,
    obs,
    arx,
    agendamento_id,
    unidade_id,
    dhup
    from todos_data_lake_trusted_feegow.log_marcacoes
)
select 
* 
from log_m
	
	--MODELAGEM_PROPOSTAS
with prop as (
select
  	id,
	pacienteid,
	tabelaid,
	valor,
	unidadeid,
	staid,
	tituloitens,
	titulooutros,
	titulopagamento,
	sys_active,
	sys_user,
	dataproposta,
	internas,
	observacoesproposta,
	cabecalho,
	contaid,
	desconto,
	dhup,
	voucher,
	profissionalid,
	profissionalexecutanteid,
	proposta_origem_id,
	especialidade_id
    from todos_data_lake_trusted_feegow.propostas
)
select 
 *
 from prop
 limit 1
 
 
 --MODELAGEM_PRONTUARIOS
 with l as (
 select
 id,
 unidade_id
 from todos_data_lake_trusted_feegow.locais
 ),
 u as (
 select
 id,
 regiao_id
 from todos_data_lake_trusted_feegow.unidades
 ),
 ur as (
 select
 id
 from todos_data_lake_trusted_feegow.unidades_regioes
 ),
 pro as (
 select
 id,
 tipo_procedimento_id
 from todos_data_lake_trusted_feegow.procedimentos
 ),
 ag as (
 select
 id,
 paciente_id,
 profissional_id,
 especialidade_id,
 status_id,
 data
 from todos_data_lake_trusted_feegow.agendamentos
 ),
 agdts as (
 select
 local_id,
 procedimento_id,
 agendamento_id
 from todos_data_lake_trusted_feegow.agendamento_procedimentos
 ),
 esp as (
 select 
 id
 from todos_data_lake_trusted_feegow.especialidades
 ),
 prof as ( 
 select
 id
 from todos_data_lake_trusted_feegow.profissionais
 ),
 pac as (
 select
 id,
 cpf
 from todos_data_lake_trusted_feegow.pacientes
 ),
 sa as (
 select
 id,
 agendamento_id
 from todos_data_lake_trusted_feegow.atendimentos
 ),
sdpa as (
select 
	documento_id,
	tipo
from todos_data_lake_trusted_feegow.dc_pdf_assinados
),
 pront as (
select
	distinct sa.agendamento_id,	1 as assinado
from sdpa
left join sa on	sdpa.documento_id = sa.id
where sdpa.tipo in ('ATENDIMENTO')
group by sa.agendamento_id
)
select --ag."data" as data, 
U.id as id_unidade, 
--prof.id as id_profissional, esp.id as id_especialidade, 
--pac.cpf, 
count(agdts.agendamento_id) as atendimentos, sum(pront.assinado) as qtddocsassinados
from agdts
left join l on agdts.local_id = L.id
left join u on	l.unidade_id = u.id
left join ur on	U.regiao_id = ur.id
left join pro on	agdts.procedimento_id = pro.id
left join ag on	agdts.agendamento_id = ag.id
left join esp on ag.especialidade_id = esp.id
left join prof on ag.profissional_id = prof.id
left join pac on ag.paciente_id = pac.id
left join pront on agdts.agendamento_id = pront.agendamento_id
where 1 = 1
and	ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3, 208)
and pro.tipo_procedimento_id in (2, 9)
and ag."data" between date('2023-11-20') and date('2023-11-28')
group by --ag."data", 
U.id
--prof.id, esp.id, pac.cpf
order by id_unidade





--MODELAGEM_PROCEDIMENTOS
with pro as (
select 
    id,
    nome_procedimento,
    grupo_procedimento_id,
    tipo_procedimento_id,
    codigo_tuss,
    sys_active,
    dhup,
    ativo,
    dias_retorno, -- add
    valor
from todos_data_lake_trusted_feegow.procedimentos
),
pg as (
select 
    id,
    nomegrupo
from todos_data_lake_trusted_feegow.procedimentos_grupos
),
pt as (
select
    id,
    tipoprocedimento
from todos_data_lake_trusted_feegow.procedimentos_tipos
),
l as (
select
    id,
    nome_laboratorio
from todos_data_lake_trusted_feegow.labs
),
le as (
select
    id,
    lab_id,
    cod_exame,
    desc,
    cod_recipiente,
    nome_recipiente,
    tipo_material,
    dias_resultado,
    dias_adicionais,
    metodologia
from todos_data_lake_trusted_feegow.labs_exames 
),
lp as (
select 
    id,
    procedimento_id,
    lab_exame_id
from todos_data_lake_trusted_feegow.labs_exames_procedimentos  
)
select
    pro.id as id_procedimento,
    pro.nome_procedimento,
    pro.codigo_tuss,
    pro.tipo_procedimento_id,
    pro.grupo_procedimento_id,
    pro.valor,
    pro.dias_retorno,
    pg.nomegrupo,
    pt.tipoprocedimento,
    l.nome_laboratorio,
    le.cod_exame,
    le.desc,
    le.cod_recipiente,
    le.nome_recipiente,
    le.tipo_material,
    le.dias_resultado,
    le.dias_adicionais,
    le.metodologia,
    case
        when pro.sys_active =-1 then 'Inativo'
        when pro.sys_active =1 then 'Inativo'
        when pro.sys_active =0 then 'Importação'
    end as status_cadastro,
    case
        when pro.ativo = 'on' then 'Ativo'
        else 'Inativo'
    end as status_interface,
    pro.dhup as dt_atualizacao
from pro
left join pg on pro.grupo_procedimento_id = pg.id
left join pt on pro.tipo_procedimento_id = pt.id
left join lp on lp.procedimento_id = pro.id
left join le on lp.lab_exame_id = le.id
left join l on le.lab_id = l.id



--MODELAGEM_FORNECEDORES
with forn as (
select 
    id,
    cpf,
    nomefornecedor,
    estado,
    cidade,
    bairro,
    endereco,
    numero,
    complemento,
    cep,
    tel1,
    tel2,
    cel1,
    cel2,
    email1,
    email2,
    sysuser,
    sysactive,
    dhup,
    ativo,
    tipoprestadorid,
    recebeparcial,
    planocontaid, -- add
    limitarplanocontas,-- add
    autoplanocontas, --add
    grupoid, -- add
    login, -- add
    senha, -- add
    codigointerno --add
    from todos_data_lake_trusted_feegow.fornecedores
),
fu as (
select 
    unidade_id,
    fornecedor_id
    from todos_data_lake_trusted_feegow.fornecedores_unidades
),
u as (
select
    id,
    nome_fantasia,
    regiao_id
    from todos_data_lake_trusted_feegow.unidades
),
ur as (
select
    id,
    descricao
    from todos_data_lake_trusted_feegow.unidades_regioes
), 
tps as (
select
    id,
    descricao
    from todos_data_lake_trusted_feegow.tipo_prestador_servico
),
users as (
select
    id,
    id_relativo
    from todos_data_lake_trusted_feegow.usuarios
),
func as (
select
    id,
    nome_funcionario
    from todos_data_lake_trusted_feegow.funcionarios 
)
select 
    forn.id as id_fornecedor,
    forn.cpf as cnpj,
    forn.nomefornecedor as nm_fornecedor,
    ur.id as id_regional,
    ur.descricao as regional,
    u.id as id_unidade,
    u.nome_fantasia as unidade,
    tps.descricao as tipo_fornecedor,
    forn.estado,
    forn.cidade,
    forn.bairro,
    forn.endereco,
    forn.numero,
    forn.complemento,
    forn.cep,
    forn.tel1,
    forn.tel2,
    forn.cel1,
    forn.cel2,
    forn.email1,
    forn.email2,
    forn.planocontaid, -- add
    forn.limitarplanocontas,-- add
    forn.autoplanocontas, --add
    forn.grupoid, -- add
    forn.login, -- add
    forn.senha, -- add
    forn.codigointerno, --add
    case
        when forn.sysactive = 1 then 'Ativo'
        when forn.sysactive = -1 then 'Inativo'
        when forn.sysactive = 0 then 'Importação'
    end as status_cadastro,
    case
        when forn.ativo = 'on' then 'Ativo'
        else 'Inativo'
    end as status_interface, 
    func.nome_funcionario as usuario_cadastro,
    case
        when forn.recebeparcial =1 then 'Ativo'
    else 'Inativo'
    end as recebimento_parcial
from forn
left join fu on fu.fornecedor_id = forn.id
left join u on fu.unidade_id = u.id
left join ur on u.regiao_id = ur.id
left join tps on forn.tipoprestadorid = tps.id
inner join users on forn.sysuser = users.id
left join func on users.id_relativo = func.id


--MODELAGENS_MEDICAMENTOS
select 
id_unidade, count(feegow) as qtd_presc_feegow, 
count (distinct memed) as qtd_presc_memed
from (
with p as (
select
    id,
    memed_id,
    paciente_id,
    data,
    sys_user,
    sys_active,
    dhup,
    atendimento_id
from todos_data_lake_trusted_feegow.pacientes_prescricoes
),
att as (
select
	id,
	paciente_id,
	agendamento_id,
	data,
	profissional_id
	unidade_id,
	tabela_id
from todos_data_lake_trusted_feegow.atendimentos 
),
u as (
select 
	id,
	nome_fantasia
from todos_data_lake_trusted_feegow.unidades
),
ag as (
select 
id,
data,
status_id,
canal_id,
tabela_particular_id,
usuario_id,
convenio_id,
local_id,
subcanal_id,
especialidade_id,
profissional_id
 from todos_data_lake_trusted_feegow.agendamentos
),
l as (
select 
	id,
	unidade_id
from todos_data_lake_trusted_feegow.locais 
),
prof as (
select
	id,
	nome_profissional,
	sys_active,
	documento_conselho,
	ativo
from todos_data_lake_trusted_feegow.profissionais
),
esp as(
select
	id,
	nome_especialidade
from todos_data_lake_trusted_feegow.especialidades 
)
select 
    p.data as dt_prescricao,
    p.id as id_feegow,
    p.memed_id as id_memed,
    ag.id as agendamento_id,
    att.id as atendimento_id,
    att.data as dataatendimento,
    ag.data as dataagendamento,
    ag.status_id,
    ag.canal_id,
    prof.id as profissional_id,
    prof.nome_profissional,
    esp.nome_especialidade,
    u.id as id_unidade,
    u.nome_fantasia
from p
--inner join pcts on p.paciente_id = pcts.id_paciente
inner join att on att.id = p.atendimento_id
left join ag on ag.id = att.agendamento_id
left join l on l.id = ag.local_id
left join u on u.id = l.unidade_id
left join prof on prof.id = ag.profissional_id
left join esp on esp.id = ag.especialidade_id

	)
	where dt_prescricao between date('2023-11-01') and date('2023-11-26')
	group by id_unidade
	order by id_unidade

select count(id) as feegow, count ( distinct memed_id) as memed
from todos_data_lake_trusted_feegow.pacientes_prescricoes
	
--MODELAGENS_TABELAS_PARTICULARES
with tp as (	
select 
id,
nome_tabela_particular,
sys_active,
sys_user,
sys_date,
dhup,
ativo 
from todos_data_lake_trusted_feegow.tabelas_particulares 
)
select * from tp




--MODELAGEM_AGENDAMENTOS
select id_unidade, count( id_agendamento)
from (
with ap as (
    select 
    agendamento_id,
    local_id,
    procedimento_id
      from todos_data_lake_trusted_feegow.agendamento_procedimentos
),
ag as (
    select 
    id,
    data,
    sys_date,
    paciente_id,
    status_id,
    canal_id,
    tabela_particular_id,
    profissional_id,
    especialidade_id,
    procedimento_id,
    valor
      from todos_data_lake_trusted_feegow.agendamentos
),
l as (
  select 
    id,
    unidade_id
      from todos_data_lake_trusted_feegow.locais
),
units as (
  select 
  id,
  nome_fantasia,
  regiao_id
        from todos_data_lake_trusted_feegow.unidades
),
ur as (
select
  id,
  descricao
        from todos_data_lake_trusted_feegow.unidades_regioes
),
tp as ( 
    select
    id,
    nome_tabela_particular
      from todos_data_lake_trusted_feegow.tabelas_particulares
),
pro as (
    select
    id,
    nome_procedimento,
    tipo_procedimento_id,
    grupo_procedimento_id
      from todos_data_lake_trusted_feegow.procedimentos
),
pt as (
    select 
    id,
    tipoprocedimento
      from todos_data_lake_trusted_feegow.procedimentos_tipos
),
pg as (
    select
    id,
    nomegrupo
      from todos_data_lake_trusted_feegow.procedimentos_grupos
),
prof as (
    select
    id,
    nome_profissional
      from todos_data_lake_trusted_feegow.profissionais
),
esp as (
    select  
    id,
    nome_especialidade
      from todos_data_lake_trusted_feegow.especialidades
),
c as (
  select
    id,
    nome_canal
      from todos_data_lake_trusted_feegow.agendamento_canais
),
s as (
    select
    id,
    nome_status
      from todos_data_lake_trusted_feegow.agendamento_status
),
pcts as (
    select 
    id,
    nome_paciente,
    cpf,
    celular,
    email,
    nascimento,
    sexo
      from todos_data_lake_trusted_feegow.pacientes
),
pe as (
    select 
    paciente_id,
    estado,
    cidade,
    bairro,
    logradouro,
    numero,
    complemento,
    cep
      from todos_data_lake_trusted_feegow.paciente_endereco
)
select distinct 
ag.id as id_agendamento,
ur.id as id_regional,
ur.descricao as regional,
units.id as id_unidade,
units.nome_fantasia as unidade,
ag.data as dt_agendamento,
ag.sys_date as dt_criacao,
ag.paciente_id as id_paciente,
pcts.nome_paciente as nm_paciente,
pcts.cpf,
pcts.celular,
pcts.email,
pcts.nascimento,
case
  when pcts.sexo =1 then 'Masculino'
  when pcts.sexo =2 then 'Feminino'
  when pcts.sexo =3 then 'Indefinido'
  else 'Não informado'
end as sexo,
pe.estado,
pe.cidade,
pe.bairro,
pe.logradouro,
pe.numero,
pe.complemento,
pe.cep,
s.id as id_status,
s.nome_status as nm_status,
c.id as id_canal,
c.nome_canal as nm_canal,
prof.id as id_profissional,
prof.nome_profissional as nm_profissional,
esp.id as id_especialidade,
esp.nome_especialidade as nm_especialidade,
pro.id as id_procedimento,
pro.nome_procedimento as nm_procedimento,
pt.id as id_tipoprocedimento,
pt.tipoprocedimento,
pg.id as id_grupoprocedimento,
pg.nomegrupo as nm_grupo,
tp.id as id_tabela,
tp.nome_tabela_particular as nm_tabela,
ag.especialidade_id,
sum(ag.valor) as valor
from ap
left join ag on ap.agendamento_id = ag.id
left join l on ap.local_id = l.id
left join units on l.unidade_id = units.id
left join ur on units.regiao_id = ur.id --
left join pro on pro.id = ap.procedimento_id --
left join pt on pro.tipo_procedimento_id = pt.id --
left join s on ag.status_id = s.id --
left join c on ag.canal_id = c.id --
left join pcts on ag.paciente_id = pcts.id --alterado de inner para left
left join pe on pcts.id = pe.paciente_id
left join tp on ag.tabela_particular_id = tp.id
left join prof on ag.profissional_id = prof.id
left join esp on ag.especialidade_id = esp.id
left join pg on pro.grupo_procedimento_id= pg.id
where pt.id in (2,9)
group by 
ag.id,
ur.id,
ur.descricao, 
units.id,
units.nome_fantasia,
ag.data,
ag.sys_date,
ag.paciente_id,
pcts.nome_paciente,
pcts.cpf,
pcts.celular,
pcts.email,
pcts.nascimento,
pe.estado,
pe.cidade,
pe.bairro,
pe.logradouro,
pe.numero,
pe.complemento,
pe.cep,
s.id,
s.nome_status,
c.id,
c.nome_canal,
prof.id,
prof.nome_profissional,
esp.id,
pro.id, 
pro.nome_procedimento,
pt.id,
pt.tipoprocedimento,
pg.id,
pg.nomegrupo,
tp.id,
tp.nome_tabela_particular,
ag.especialidade_id,
pcts.sexo,
esp.nome_especialidade)
where 1 = 1
and id_unidade = 19653
and dt_agendamento between date ('2023-11-01') and date ('2023-11-26')
--and id_status in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
group by id_unidade
order by id_unidade asc




-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
--MODELAGEM ITENS_ORÇADOS OU EXAMES_ORÇADOS

select id_unidade, sum(valor_unitario) as valor, count(ipid) as qtd_itens
from (
with p as (
select 
    id,
    dataproposta,
    tabelaid,
    unidadeid,
    staid,
    pacienteid,
    dhup,
    profissionalid,
    especialidade_id
from todos_data_lake_trusted_feegow.propostas
),
tp as (
select 
    id,
    nome_tabela_particular
from todos_data_lake_trusted_feegow.tabelas_particulares
),
units as (
select 
    id,
    nome_fantasia,
    regiao_id
from todos_data_lake_trusted_feegow.unidades
),
ur as (
select
    id,
    descricao
from todos_data_lake_trusted_feegow.unidades_regioes
),
ps as (
select
    id,
    nome_status
from todos_data_lake_trusted_feegow.propostas_status
),
pcts as (
select 
    id_paciente,
    nome_paciente,
    cpf,
    celular,
    email,
    nascimento,
    nomesexo,
    estado,
    cidade,
    bairro,
    logradouro,
    numero,
    cep,
    complemento
    FROM pdgt_sandbox_gabrielguilherme.fl_pacientes 
),
prof as (
select 
    id,
    nome_profissional
from todos_data_lake_trusted_feegow.profissionais
),
ip as (
select 
	id,
    proposta_id,
    item_id,
    valor_unitario,
    desconto,
    pacote_id
from todos_data_lake_trusted_feegow.itens_proposta  
),
pro as (
select 
    id,
    nome_procedimento,
    tipo_procedimento_id,
    grupo_procedimento_id
from todos_data_lake_trusted_feegow.procedimentos   
),
pg as (
select
    id,
    nomegrupo
from todos_data_lake_trusted_feegow.procedimentos_grupos    
),
pt as (
select
    id,
    tipoprocedimento
from todos_data_lake_trusted_feegow.procedimentos_tipos     
),
esp as (
select 
    id,
    nome_especialidade
from todos_data_lake_trusted_feegow.especialidades   
)
select 
	ip.id as ipid,
    p.id as id_proposta,
    p.dataproposta,
    tp.id as id_convenio,
    tp.nome_tabela_particular as convenio,
    ur.id as id_regional,
    ur.descricao as regional,
    units.id as id_unidade,
    units.nome_fantasia as unidade,
    ps.nome_status as status_proposta,
    pcts.id_paciente,
    pcts.nome_paciente,
    pcts.cpf,
    pcts.celular,
    pcts.email,
    pcts.nascimento,
    pcts.nomesexo as genero,
    pcts.estado,
    pcts.cidade,
    pcts.bairro,
    pcts.logradouro,
    pcts.numero,
    pcts.cep,
    pcts.complemento,
    p.dhup as dt_atualizacao,
    pro.id as id_procedimento,
    pro.nome_procedimento,
    pg.nomegrupo as grupo_procedimento,
    pt.tipoprocedimento as tipo_procedimento,
    ip.valor_unitario,
    ip.desconto,
    prof.id as id_profissional,
    prof.nome_profissional as profissional_solicitante,
    esp.id as id_especialidade,
    esp.nome_especialidade as especialidade_proposta
from p
left join ip on ip.proposta_id = p.id
left join pro on ip.item_id = pro.id
left join pg on pro.grupo_procedimento_id = pg.id
left join pt on pro.tipo_procedimento_id = pt.id
left join tp on p.tabelaid = tp.id
left join units on p.unidadeid = units.id
left join ur on units.regiao_id = ur.id
left join ps on p.staid = ps.id
left join pcts on p.pacienteid = pcts.id_paciente
left join prof on p.profissionalid = prof.id
left join esp on p.especialidade_id = esp.id
) 
where dataproposta between date('2023-11-01') and date('2023-11-26')
group by id_unidade
order by id_unidade


--MODELAGEM DATAQUALITY

with stg_agendamentos as (
select 'todos_data_lake_trusted_feegow.agendamento' as Tipo, cast(ag."data" as date), count(*) as Registros, 0 as valortotal, su.id as unidade_id
from todos_data_lake_trusted_feegow.agendamentos ag
left join todos_data_lake_trusted_feegow.locais sl on sl.id = ag.local_id
left join todos_data_lake_trusted_feegow.unidades su on su.id = sl.unidade_id
group by cast(ag."data" as date), su.id),
stg_movimentacao as (
select 'todos_data_lake_trusted_feegow.movimentacao' as Tipo, cast(ag."data" as date), count(*) as Registros, 0 as valortotal, ag.unidade_id 
	from todos_data_lake_trusted_feegow.movimentacao ag
group by cast(ag."data" as date), ag.unidade_id),
stg_contas as (
select 'todos_data_lake_trusted_feegow.contas' as Tipo ,cast(ag.data_referencia as date) as data, count(*) as Registros, 0 as valortotal, ag.unidade_id
	from todos_data_lake_trusted_feegow.contas ag
group by cast(ag.data_referencia as date), ag.unidade_id),
stg_propostas as (
select 'todos_data_lake_trusted_feegow.propostas' as Tipo, cast(p.dataproposta as date) as data, count(*) as Registros, 0 as valortotal, p.unidadeid as unidade_id
from todos_data_lake_trusted_feegow.propostas p
group by cast(p.dataproposta as date),p.unidadeid),
stg_memed_prescricoes as (
select 'todos_data_lake_trusted_feegow.memed_prescricoes mp' as Tipo, cast(mp.datahora as date) as data  , count(*) as Registros, 0 as valortotal, sa.unidade_id
from todos_data_lake_trusted_feegow.memed_prescricoes mp
left join todos_data_lake_trusted_feegow.atendimentos sa on sa.id = mp.atendimentoid 
group by cast(mp.datahora as date), sa.unidade_id),
stg_dc_pdf_assinados as (
select 'todos_data_lake_trusted_feegow.dc_pdf_assinados' as Tipo, cast(pa.data_criacao as date) as data, count(*) as Registros, 0 as valortotal, ah.unidade_id 
from todos_data_lake_trusted_feegow.dc_pdf_assinados pa
left join todos_data_lake_trusted_feegow.atendimentos ah on ah.id = pa.documento_id 
group by cast(pa.data_criacao as date), ah.unidade_id),
stg_pacientes_pedido as (
select 'todos_data_lake_trusted_feegow.pacientes_pedidos' as Tipo, cast(pd."data"  as date) as data, count(*) as Registros, 0 as valortotal, sah.unidade_id
from todos_data_lake_trusted_feegow.pacientes_pedidos pd
left join todos_data_lake_trusted_feegow.atendimentos sah on sah.paciente_id  = pd.paciente_id  
group by cast(pd."data"  as date),sah.unidade_id),
stg_pacientes_prescricoes as (
select 'todos_data_lake_trusted_feegow.pacientes_prescricoes' as Tipo, cast(pp."data" as date) as data, count(*) as Registros, 0 as valortotal, sah.unidade_id 
from todos_data_lake_trusted_feegow.pacientes_prescricoes pp
left join todos_data_lake_trusted_feegow.atendimentos sah on sah.paciente_id = pp.paciente_id
group by cast(pp."data" as date), sah.unidade_id),
stg_agenda_horarios_itens as (
select 'todos_data_lake_trusted_feegow.agenda_horarios_itens' as Tipo ,cast(hi."data" as date) as data, count(*) as Registros, 0 as valortotal, hi.unidade_id 
from todos_data_lake_trusted_feegow.agenda_horarios_itens hi
group by cast(hi."data" as date), hi.unidade_id),
stg_contas_bloqueios as (
select 'todos_data_lake_trusted_feegow.contas_bloqueios' as Tipo, cast(cb."data" as date)as data , count(*) as Registros, 0 as valortotal, cb.unidade_id 
from todos_data_lake_trusted_feegow.contas_bloqueios cb
group by cast(cb."data" as date), cb.unidade_id),
stg_atendimentos as (
select 'todos_data_lake_trusted_feegow.atendimentos' as Tipo, cast(a."data" as date) as data, count(*) as Registros, 0 as valortotal, a.unidade_id 
from todos_data_lake_trusted_feegow.atendimentos a
group by cast(a."data" as date), a.unidade_id),
stg_agendamento_procedimentos as (
select 'todos_data_lake_trusted_feegow.agendamento_procedimentos sap' as Tipo, cast(sap.dhup as date) as data, count(*) as Registros, 0 as valortotal, su.id as unidade_id
from todos_data_lake_trusted_feegow.agendamento_procedimentos sap 
left join todos_data_lake_trusted_feegow.locais sl on sl.id = sap.local_id
left join todos_data_lake_trusted_feegow.unidades su on su.id = sl.unidade_id 
group by cast(sap.dhup as date), su.id),
stg_procedimentos as (
select 'todos_data_lake_trusted_feegow.procedimentos' as Tipo, cast(sp.dhup as date) as data ,count(*) as Registros, 0 as valortotal, su.id as unidade_id
from todos_data_lake_trusted_feegow.procedimentos sp
left join todos_data_lake_trusted_feegow.agendamentos sah on sah.procedimento_id = sp.id
left join todos_data_lake_trusted_feegow.locais sl on sl.id = sah.local_id 
left join todos_data_lake_trusted_feegow.unidades su on su.id = sl.unidade_id 
group by cast(sp.dhup as date), su.id),
tb_consolidacao_agendamentos_hist as (
select 'tb_consolidacao_agendamentos_hist' as Tipo, cast(ahi.dt_agendamento as date) as data, count(*) as Registro, 0 as valortotal, ahi.id_unidade as unidade_id 
from pdgt_amorsaude_operacoes.fl_agendamentos ahi
group by cast(ahi.dt_agendamento as date), ahi.id_unidade),
tb_consolidacao_contas_a_receber as (
select 'tb_consolidacao_contas_a_receber_hi' as Tipo, cast(cr.datavencimento  as date) as data, count(*) as Registros, cr.valor_pago as valortotal, cr.id_unidade  as unidade_id
from pdgt_amorsaude_financeiro.fl_contas_a_receber cr
group by cast(cr.datavencimento as date), cr.valor_pago, cr.id_unidade), --problema em varchar dentro do contas a receber
tb_consolidacao_receita_bruta_hist_final as (
select 'tb_consolidacao_receita_bruta_hist_final' as Tipo, cast(tcrbhf."data" as date) as data, count(*) as Registros, tcrbhf.total_recebido as valortotal, tcrbhf .id_unidade  as unidade_idc
from pdgt_amorsaude_financeiro.fl_receita_bruta tcrbhf
group by cast(tcrbhf."data" as date),tcrbhf.total_recebido, tcrbhf .id_unidade),
tb_consolidacao_contas_a_pagar_hist as (
select 'tb_consolidacao_contas_a_pagar_hist' as Tipo, cast(cp."data" as date) as data, count(*) as Registros, cp.valortotal as valortotal, su.id as unidade_id
from pdgt_amorsaude_financeiro.fl_contas_a_pagar cp
left join todos_data_lake_trusted_feegow.unidades su on su.nome_fantasia = cp.nm_unidade 
group by cast(cp."data" as date), cp.valortotal, su.id),
stg_boletos_emitidos as (
select 'todos_data_lake_trusted_feegow.boletos_emitidos' as Tipo, cast(be.data_hora as date), count(*) as Registros, 0 as valortotal, be.unidade_id 
from todos_data_lake_trusted_feegow.boletos_emitidos be
group by cast(be.data_hora as date), be.unidade_id),
stg_grade_fixa as (
select 'todos_data_lake_trusted_feegow.grade_fixa' as Tipo, cast(gf.datahora as date), count(*) as Registros, 0 as valortotal, su.id as unidade_id
from todos_data_lake_trusted_feegow.grade_fixa gf
left join todos_data_lake_trusted_feegow.locais sl on sl.id = gf.localid
left join todos_data_lake_trusted_feegow.unidades su on su.id = sl.unidade_id 
group by cast(gf.datahora as date), su.id),
stg_royalties_contas as (
select 'todos_data_lake_trusted_feegow.grade_fixa' as Tipo, cast(rc.datareferencia as date), count(*) as Registros, 0 as valortotal, rc.unidadeid as unidade_id
from todos_data_lake_trusted_feegow.royalties_contas rc
group by cast(rc.datareferencia as date), rc.unidadeid),
stg_splits as (
select 'todos_data_lake_trusted_feegow.splits' as Tipo, cast(s."data" as date), count(*) as Registros, 0 as valortotal, smh.unidade_id
from todos_data_lake_trusted_feegow.splits s
left join todos_data_lake_trusted_feegow.movimentacao smh on smh.id = s.movimentacao_id 
group by cast(s."data" as date), smh.unidade_id),
stg_conta_itens as (
select 'todos_data_lake_trusted_feegow.conta_itens' as Tipo, cast(sci.data_execucao as date) as data, count(*) as Registros, 0 as valortotal, 0 as unidade_id
from todos_data_lake_trusted_feegow.conta_itens sci
--left join todos_data_lake_trusted_feegow.contas scc on scc.conta_id = sci.id
group by cast(sci.data_execucao as date))
select * from (
select * from stg_conta_itens
union all
select * from stg_contas sc 
union all
select * from stg_splits ss 
union all
select * from stg_propostas
union all
select * from stg_grade_fixa
union all
select * from stg_grade_fixa
union all
select * from stg_boletos_emitidos
union all
select * from stg_procedimentos
union all
select * from stg_agendamento_procedimentos
union all
select * from stg_atendimentos
union all
select * from stg_dc_pdf_assinados
union all
select * from stg_pacientes_pedido
union all
select * from stg_pacientes_prescricoes
union all
select * from stg_agenda_horarios_itens
union all
select * from stg_contas_bloqueios
union all
select * from stg_memed_prescricoes
union all
select * from stg_agendamentos
union all
select * from stg_movimentacao
union all
select * from tb_consolidacao_agendamentos_hist
union all
select * from tb_consolidacao_contas_a_receber
union all
select * from tb_consolidacao_receita_bruta_hist_final
union all
select * from tb_consolidacao_contas_a_pagar_hist
WHERE data BETWEEN date_add('day', -90, current_date) AND current_date --fazer a carga histórica, e depois fazer diário em current_date -1
and data <= current_date
order by data desc
)




--MODELAGEM AGENDAMENTOS AMEI
SELECT
	CONCAT(B.nome, ' ', B.sobrenome) AS NOME_PACIENTE,
	B.cpf,
	B.email,
	c2.nome AS nome_canal
from todos_data_lake_trusted_amei.AGENDAMENTOS A
LEFT  JOIN todos_data_lake_trusted_amei.PACIENTES B ON	B.id = A.paciente_id AND B.ativo = 1
LEFT  JOIN todos_data_lake_trusted_amei.AGENDAMENTOS_PROCEDIMENTOS C ON	C.agendamento_id = A.id
LEFT  JOIN todos_data_lake_trusted_amei.ATENDIMENTOS T ON A.id = T.FK_AGENDAMENTO
LEFT  JOIN todos_data_lake_trusted_amei.FORNECEDOR_PROCEDIMENTOS F ON C.FK_FORNECEDOR_PROCEDIMENTO_REPASSE = F.ID
LEFT  JOIN todos_data_lake_trusted_amei.CAMPANHA_VOUCHER_PROCEDIMENTOS V ON	C.FK_CAMPANHA_VOUCHER_PROCEDIMENTOS = V.ID
LEFT  JOIN todos_data_lake_trusted_amei.CAMPANHA_VOUCHERS CVV ON V.FK_CAMPANHA_VOUCHER = CVV.ID
LEFT JOIN todos_data_lake_trusted_amei.PROFISSIONAIS P ON P.id = A.profissional_id
LEFT JOIN todos_data_lake_trusted_amei.UNIDADES U ON U.id = A.clinica_id 
LEFT JOIN todos_data_lake_trusted_amei.STATUS_AGENDAMENTOS sa ON sa.id = A.status_agendamento_id
LEFT JOIN todos_data_lake_trusted_amei.CANAIS c2 ON c2.id = A.canal_id 
WHERE 1 = 1
AND	A.data BETWEEN date('2024-01-02') AND date('2024-01-07')
--AND A.clinica_id = 183
--AND sa.id IN (4, 5, 6, 7, 10, 11, 12, 13, 14, 15, 24, 40)




-----------------------------------------------------------
--MODELAGEM PROTHEUS WEBDENTAL CLIENTE INCLUIR
--modelagem final 
with units as (
  select
    id,
    cnpj,
    nome_fantasia,
    nome_unidade,
    estado,
    cidade,
    bairro,
    endereco,
    cep,
    numero,
    complemento,
    regiao_id,
    tel1,
    tel2,
    cel1,
    cel2,
    parceiro_institucional_id,
    regime_tributario_id,
    exibiragendamentoonline,
    email1,
    email2,
    medico_responsavel,
    cnes,
    sys_active,
    sys_user,
    dhup,
    grupo_unidade_id,
    consultor_responsavel,
    status_unidade_id
  from todos_data_lake_trusted_feegow.unidades
),
forn as (
  select
    id,
    nomefornecedor
  from todos_data_lake_trusted_feegow.fornecedores
),
ur as (
  select
    id,
    descricao
  from todos_data_lake_trusted_feegow.unidades_regioes
),
rt as (
  select
    id,
    nomeregimetributario
  from todos_data_lake_trusted_feegow.regimes_tributarios
),
prof as (
  select
    id,
    nome_profissional
  from todos_data_lake_trusted_feegow.profissionais
),
users as (
  select
    id,
    id_relativo
  from todos_data_lake_trusted_feegow.usuarios
),
func as (
  select
    id,
    nome_funcionario
  from todos_data_lake_trusted_feegow.funcionarios
),
gu as (
  select
    id,
    sigla,
    descricao
  from todos_data_lake_trusted_feegow.grupo_unidade
),
su as (
  select
    id,
    nome_status
  from todos_data_lake_trusted_feegow.status_unidade
), 
final_query_feegow as ( 
select 
  cast(27602235000100 AS VARCHAR) AS cnpjfilial, --adicionado cnpj filial franqueadora amorsaude nos dados da feegow a pedido do time de projetos
  cast(01001 AS VARCHAR) AS filial,  
  null as codigomunicipio,
  units.id as id_unidade,
  units.cnpj as cnpjcliente,
  units.nome_fantasia,
  units.nome_unidade,
  ur.id,
  ur.descricao,
  units.estado,
  units.cidade,
  units.bairro,
  units.endereco,
  units.cep,
  units.numero,
  units.complemento,
  units.tel1,
  units.tel2,
  units.cel1,
  units.cel2,
  units.email1,
  units.email2,
  forn.nomefornecedor as franquia_cdt,
  rt.nomeregimetributario as regime_tributario,
  prof.nome_profissional as rt_medicina,
  case
    when units.exibiragendamentoonline  =1 then 'Sim'
    else 'Não'
  end as agendas_online,
  units.cnes,
  case
    when units.sys_active =1 then 'Ativo'
    when units.sys_active =-1 then 'Inativo'
  end as status_cadastro,
  func.nome_funcionario as usuario_cadastro,
  units.dhup as dt_atualizacao,
  gu.sigla as rating,
  gu.descricao as desc_rating,
  units.consultor_responsavel,
  su.nome_status as status
from units
  inner join forn on forn.id = units.parceiro_institucional_id
  left join ur on units.regiao_id = ur.id
  left join rt on units.regime_tributario_id = rt.id
  left join prof on units.medico_responsavel = prof.id
  left join users on units.sys_user = users.id
  left join func on users.id_relativo = func.id
  left join gu on units.grupo_unidade_id = gu.id
  left join su on units.status_unidade_id = su.id
),
units_feegow as ( ----------------------- feegow
select 
cnpjfilial,
	filial,
	cnpjcliente,
	nome_unidade as nomecliente,
	'j' as tipo,
	nome_fantasia as nomefantasia,
	endereco,
	complemento,
	bairro,
	estado,
	codigomunicipio,
	cidade as municipio,
	cep,
	COALESCE(
    CASE WHEN tel1 IS NOT NULL AND tel1 != '' THEN REGEXP_REPLACE(SUBSTRING(tel1 FROM 2 FOR 4), '[^0-9]', '') END,
    CASE WHEN tel2 IS NOT NULL AND tel2 != '' THEN REGEXP_REPLACE(SUBSTRING(tel2 FROM 2 FOR 4), '[^0-9]', '') END,
    CASE WHEN cel1 IS NOT NULL AND cel1 != '' THEN REGEXP_REPLACE(SUBSTRING(cel1 FROM 2 FOR 4), '[^0-9]', '') END
) AS ddd,
COALESCE(
    CASE WHEN tel1 IS NOT NULL AND tel1 != '' THEN REGEXP_REPLACE(SUBSTRING(tel1 FROM 6), '\\s|-', '') END,
    CASE WHEN tel2 IS NOT NULL AND tel2 != '' THEN REGEXP_REPLACE(SUBSTRING(tel2 FROM 6), '\\s|-', '') END,
    CASE WHEN cel1 IS NOT NULL AND cel1 != '' THEN REGEXP_REPLACE(SUBSTRING(cel1 FROM 6), '\\s|-', '') END
) AS telefone,
email1 as email,
dt_atualizacao,
'Feegow' as sistema_origem 
from final_query_feegow
),
ua as ( --aqui começa as tabelas da webdental
  select
    *
  FROM todos_data_lake_trusted_webdental.tbl_unidade_atendimento
), 
units_webdental as ( -----------------------  webdental
  SELECT     
   cast(27602235000100 AS VARCHAR) AS cnpjfilial, --adicionado cnpj filial franqueadora amorsaude nos dados da feegow a pedido do time de projetos
  cast(01001 AS VARCHAR) AS filial,
    REGEXP_REPLACE(ua.cnpj, '[./-]', '') AS cnpjcliente,
    ua.nm_unidade_atendimento AS nomecliente,
    'J' AS tipo,
    COALESCE(NULLIF(ua.nome_fantasia, ''), ua.nm_unidade_atendimento) AS nomefantasia,
    CONCAT(ua.rua, ', ', ua.numero) AS endereco,
    ua.complemento,
    ua.cd_bairro AS bairro,
    ua.estado,
    '?' AS codigomunicipio,
    ua.cd_cidade AS municipio,
    REPLACE(ua.cep, '-', '') AS cep,
   CASE 
        WHEN num_telefone_1 IS NOT NULL AND num_telefone_1 != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(num_telefone_1, '[^0-9]', ''), 1, 2) AS varchar)
        WHEN num_telefone_2 IS NOT NULL AND num_telefone_2 != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(num_telefone_2, '[^0-9]', ''), 1, 2) AS varchar)
        WHEN num_telefone_3 IS NOT NULL AND num_telefone_3 != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(num_telefone_3, '[^0-9]', ''), 1, 2) AS varchar)
    END AS ddd,
    COALESCE(
    CASE WHEN num_telefone_1 IS NOT NULL AND num_telefone_1 != '' THEN REGEXP_REPLACE(SUBSTRING(num_telefone_1 FROM 4), '\\s|-', '') END,
    CASE WHEN num_telefone_2 IS NOT NULL AND num_telefone_2 != '' THEN REGEXP_REPLACE(SUBSTRING(num_telefone_2 FROM 4), '\\s|-', '') END,
    CASE WHEN num_telefone_3 IS NOT NULL AND num_telefone_3 != '' THEN REGEXP_REPLACE(SUBSTRING(num_telefone_3 FROM 4), '\\s|-', '') END
) AS telefone,
LOWER(ua.email) AS email,
dt_ultima_edicao as dt_atualizacao,
'webdental' as sistema_origem
FROM ua
WHERE ua.unidade_teste = 'N'
),
pes as ( --aqui começa as tabelas da webvidas
  select
    id_cliente,
    tipo_pessoa,
    cnpj,
    nome,
    cpf,
    data_hora_ultima_edicao,
    data_efetivacao_cliente,
    nome_fantasia,
    telefone,
    telefone2,
    celular
  FROM todos_data_lake_trusted_webvidas.db_pessoa pes
), 
ender as ( 
  select
    id_cliente,
    tipo_logradouro,
    endereco,
    numero_endereco,
    endereco_complemento,
    bairro,
    cod_cidade,
    cep,
    cod_municipio_ans
  FROM todos_data_lake_trusted_webvidas.db_endereco ender
), 
cid as ( 
  select
    cod_cidades,
    estados_cod_estados,
    nome
  FROM todos_data_lake_trusted_webvidas.db_cidades cid
), 
ope as ( 
  select
    id_cliente,
    id_empresa
  FROM todos_data_lake_trusted_webvidas.db_operacao_plano ope
), 
est as ( 
  select
    sigla,
    cod_estados
  FROM todos_data_lake_trusted_webvidas.db_estados est
), 
units_webvidas as ( ----------------------- webvidas
SELECT  cast(05983170000157 as varchar) as cnpjfilial,
	    cast(07001 as varchar) as filial,
REGEXP_REPLACE((case when pes.tipo_pessoa = 'FISICA' then pes.cpf ELSE pes.cnpj END), '[./-]', '') AS cnpjcliente,
		pes.nome AS nomecliente,
		(case when pes.tipo_pessoa = 'FISICA' then 'F' ELSE 'J' END) AS tipo,
	CASE 
    WHEN pes.tipo_pessoa = 'FISICA' THEN pes.nome 
    ELSE COALESCE(pes.nome_fantasia, pes.nome)
		END AS nomefantasia,
TRIM(CONCAT(COALESCE(ender.tipo_logradouro, ''), ' ', ender.endereco, ', ', ender.numero_endereco)) AS endereco,
ender.endereco_complemento AS complemento, 
ender.bairro,
ender.bairro, est.sigla AS estado,
SUBSTRING(CAST(ender.cod_municipio_ans AS VARCHAR) FROM 3 FOR 10) AS codigomunicipio,
cid.nome AS municipio,
REPLACE(ender.cep, '-', '') AS cep,
CASE 
        WHEN pes.telefone IS NOT NULL AND pes.telefone != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(pes.telefone, '[^0-9]', ''), 1, 2) AS varchar)
        WHEN pes.telefone2 IS NOT NULL AND pes.telefone2 != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(pes.telefone2, '[^0-9]', ''), 1, 2) AS varchar)
        WHEN pes.celular IS NOT NULL AND pes.celular != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(pes.celular, '[^0-9]', ''), 1, 2) AS varchar)
    END AS ddd,
    REPLACE
		   (
				REPLACE
				(
					REPLACE
					(
						REPLACE
						(
							REPLACE
							(
								COALESCE(NULLIF(pes.celular, ''), NULLIF(pes.telefone, ''), coalesce(pes.telefone2, '')), '(', ''
							), ')', ''
						), '-', ''
					), ' ', ''
				), '_', ''
			) AS telefone,
pes.data_hora_ultima_edicao as dt_atualizacao,
'webvidas' as sistema_origem
FROM pes
	INNER JOIN ender ON pes.id_cliente = ender.id_cliente
	LEFT JOIN ope ON pes.id_cliente = ope.id_cliente
	LEFT JOIN cid ON cid.cod_cidades = ender.cod_cidade
	LEFT JOIN est ON est.cod_estados = cid.estados_cod_estados
WHERE (case when pes.tipo_pessoa = 'FISICA' then pes.data_efetivacao_cliente IS NOT NULL ELSE 1 = 1 END)
AND ope.id_empresa IS null
),
u as ( --------- dados do amei
select 
*
from todos_data_lake_trusted_amei.unidades 
),
m as (
select 
*
from todos_data_lake_trusted_amei.municipios 
),
e as (
select 
*
from todos_data_lake_trusted_amei.estados  
),
units_amei as ( ----------------------- AMEI
SELECT  
case when u.id = 183 then cast(44905730000107 as varchar) else cast(27602235000100 as varchar)
	end as cnpjfilial,
case when u.id = 183 then cast(02001 as varchar) else cast(01001 as varchar)
	end as filial,
u.cnpj as cnpjcliente,
u.razao_social as nomecliente,
'j' as tipo,
u.descricao as nome_fantasia,
u.endereco,
u.complemento,
u.bairro,
e.uf as estado,
null as codigomunicipio,
m.municipio as cidade,
u.cep,
	COALESCE(
    CASE WHEN u.telefone_principal IS NOT NULL AND u.telefone_principal != '' THEN REGEXP_REPLACE(SUBSTRING(u.telefone_principal FROM 1 FOR 2), '[^0-9]', '') END,
    CASE WHEN u.telefone_secundario IS NOT NULL AND u.telefone_secundario != '' THEN REGEXP_REPLACE(SUBSTRING(u.telefone_secundario FROM 1 FOR 2), '[^0-9]', '') END
) AS ddd,
COALESCE(
    CASE WHEN u.telefone_principal IS NOT NULL AND u.telefone_principal != '' THEN REGEXP_REPLACE(SUBSTRING(u.telefone_principal FROM 3), '\\s|-', '') END,
    CASE WHEN u.telefone_secundario IS NOT NULL AND u.telefone_secundario != '' THEN REGEXP_REPLACE(SUBSTRING(u.telefone_secundario FROM 3), '\\s|-', '') END
) AS telefone,
u.email_principal as email,
u.update_at as dt_atualizacao,
'Amei!' as sistema_origem
FROM u
left join m ON m.id = u.FK_MUNICIPIO 
left join e on e.id = m.fk_estados
WHERE u.RAZAO_SOCIAL IS NOT null
)
select* from (
select * from units_feegow
union all
select * from units_webdental
union all
select * from units_webvidas
union all
select * from units_amei
)



--modelagem referente ao pedidoincluir
with m as (
select
	id,
	"data",
	conta_id,
	valor_pago,
	valor,
	descricao,
	forma_pagamento_id,
	tipo_movimentacao,
	credito_debito
    from todos_data_lake_trusted_feegow.movimentacao
),
ct as (
select 
	id,
	movimentacao_id,
	parcelas,
	bandeira_cartao_id,
	numero_transacao,
	numero_autorizacao 
    from todos_data_lake_trusted_feegow.transacao_cartao
),
bc as (
select 
	id,
	bandeira 
    from todos_data_lake_trusted_feegow.bandeiras_cartao
),
i as (
select 
	recurrence,
	credito_debito,
	sys_active,
	id,
	conta_id,
	associacao_conta_id,
	unidade_id,
	tabela_particular_id
    from todos_data_lake_trusted_feegow.contas
),
ii as (
select 
	id,
	conta_id,
	pacote_id,
	categoria_id,
	procedimento_id,
	tipo_item_id,
	quantidade,
	valor_unitario,
	acrescimo,
	desconto,
	is_executado,
	is_cancelado
    from todos_data_lake_trusted_feegow.conta_itens
),
pii as (
select 
	id
    from todos_data_lake_trusted_feegow.pacotes
),
movpay as (
select 
	id,
	"data",
	sys_user 
    from todos_data_lake_trusted_feegow.movimentacao
),
fdpay as (
select 
	pagamento_id,
	parcela_id
    from todos_data_lake_trusted_feegow.pagamento_associacao
),
idesc as (
select 
	valor,
	item_id,
	pagamento_id
    from todos_data_lake_trusted_feegow.pagamento_item_associacao
),
pacconta as(
select 
	cpf,
	id,
	nome_paciente
    from todos_data_lake_trusted_feegow.pacientes
),
subcat as (
select 
	id,
	name,
	category
    from todos_data_lake_trusted_feegow.planodecontas_receitas
),
cat as (
select 
	id,
	name
    from todos_data_lake_trusted_feegow.planodecontas_receitas
),
proc as (
select 
	id,
	nome_procedimento,
	grupo_procedimento_id,
	tipo_procedimento_id
    from todos_data_lake_trusted_feegow.procedimentos
),
prod as (
select 
	id
    from todos_data_lake_trusted_feegow.produtos
),
procgrup as (
select 
	id,
	sysactive,
	nomegrupo
    from todos_data_lake_trusted_feegow.procedimentos_grupos
),
unit as (
select 
  id, 
  regiao_id,
  nome_fantasia,
  cnpj,
  nome_unidade,
  endereco,
  complemento,
  cep,
  numero,
  bairro,
  cidade,
  estado,
  tel1,
  tel2,
  cel1,
  email1
    from todos_data_lake_trusted_feegow.unidades
),
pag3 as (
select 
	id
    from todos_data_lake_trusted_feegow.pacientes
),
pag2 as (
select 
	id 
    from todos_data_lake_trusted_feegow.fornecedores
),
pag6 as (
select 
	id 
    from todos_data_lake_trusted_feegow.convenios
),
tp as (
select 
	id,
	nome_tabela_particular
    from todos_data_lake_trusted_feegow.tabelas_particulares
),
users as (
select 
	id,
	id_relativo 
    from todos_data_lake_trusted_feegow.usuarios
),
func as (
select 
	id
    from todos_data_lake_trusted_feegow.funcionarios
),
ur as (
select 
	id,
	descricao
    from todos_data_lake_trusted_feegow.unidades_regioes
),
final_query as (
select
	m."data" as data,
	m."data" as datavencimento, --alterado nomemclatura
	movpay."data" as datapagamento, --alterado nomemclatura
	pacconta.CPF cpfpaciente, --alterado nomemclatura
  	i.recurrence, 
  	pacconta.id id_paciente,
  	pacconta.nome_paciente,
  	i.credito_debito,
  	proc.nome_procedimento,
  	proc.id as id_procedimento,
    procgrup.nomegrupo,
    i.sys_active,
    unit.nome_fantasia,
    unit.cnpj,
	 unit.nome_unidade,
	  unit.endereco,
	  unit.complemento,
	  unit.cep,
	  unit.numero,
	  unit.bairro,
	  unit.cidade,
	  unit.estado,
	  unit.tel1,
	  unit.tel2,
	  unit.cel1,
	  unit.email1,
    unit.id as id_unidade,
    max(ii.quantidade) as quantidade, --não suportou a subquery da antiga contas a receber rodando dentro do redshift -- a funcao max bate com a feegow quando analisado Batatais
    (CASE 
        WHEN 'S'='S' THEN (SUM(coalesce(idesc.valor, 0)))/ COALESCE(i.Recurrence, 1) 
        ELSE coalesce(m.Valor_Pago, 0) 
    END) Valor_Pago,
    m.descricao as descricaomovimentacao,
   (CASE
	WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) <= 0 then 'Quitado' 
        WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) > 0 and coalesce(m.valor_pago, 0) > 0 then 'Parcialmente pago' 
        ELSE 'Em aberto'
    END) situacaoconta,
     (case 
        when m.forma_pagamento_id IN (8,10) then ct.Parcelas 
        else 1 
    end) as parcelas, --alterado nomemclatura
    cat.name as categoria, --alterado nomemclatura
    subcat.name as subcategoria,
    tp.id as id_tabela,
    tp.nome_tabela_particular,
    ur.descricao as regional
        from m
            LEFT JOIN ct ON ct.movimentacao_id = m.id
            LEFT JOIN bc ON bc.id = ct.bandeira_cartao_id
            INNER JOIN i ON i.id = m.conta_id
            INNER JOIN ii ON ii.conta_id = i.id
            LEFT JOIN pii ON pii.id = ii.pacote_id
            LEFT JOIN fdpay ON fdpay.parcela_id = m.id
            LEFT JOIN movpay ON movpay.id = fdpay.pagamento_id
            LEFT JOIN idesc ON idesc.item_id = ii.id AND idesc.pagamento_id = movpay.id
            LEFT JOIN pacconta ON pacconta.id = i.conta_id AND i.associacao_conta_id = 3
            LEFT JOIN subcat ON subcat.id = ii.categoria_id
            LEFT JOIN cat ON cat.id = subcat.Category
            LEFT JOIN proc ON proc.id = ii.procedimento_id AND ii.tipo_item_id = 'S'
            LEFT JOIN prod ON prod.id = ii.procedimento_id AND ii.tipo_item_id = 'M'
            LEFT JOIN procgrup ON procgrup.id = proc.grupo_procedimento_id AND procgrup.sysActive = 1
            LEFT JOIN unit ON unit.id = i.unidade_id
            LEFT JOIN pag3 ON i.associacao_conta_id = 3 AND i.conta_id = pag3.id
            LEFT JOIN pag6 ON i.associacao_conta_id = 6 AND i.conta_id = pag6.id
            LEFT JOIN tp on tp.id = i.tabela_particular_id
            LEFT JOIN users on movpay.sys_user = users.id
            LEFT JOIN func on users.id_relativo = func.id			
            LEFT JOIN ur on ur.id = unit.regiao_id			
    WHERE
        m.tipo_movimentacao = 'Bill' 	    
        AND m.credito_debito = 'C' 	    
        AND ((ii.is_cancelado <> '1' AND ii.tipo_item_id = 'S') 		
        OR (ii.tipo_item_id != 'S')) 
	            AND (i.tabela_particular_id IN (NULL) OR 1=1) 	
        AND (ii.tipo_item_id IN (NULL) OR 1=1) 	
        AND (proc.grupo_procedimento_id IN (NULL) OR 1=1) 	    
        AND (proc.tipo_procedimento_id IN (NULL) OR 1=1) 	    
        AND ((case when 'N'='S' then ii.pacote_id IS NOT null else true end)) 	    
        AND         
        ((CASE         
            WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) <= 0 THEN 'quitado' 			
            WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) > 0  AND coalesce(m.Valor_Pago, 0) > 0 THEN 'parcial' 			
            ELSE 'aberto'
        END) in ('quitado', 'parcial') OR 1=0)
GROUP BY             
    (case when 'S'='S' then CONCAT(CONCAT(cast(m.id as varchar), ', '), cast(ii.id as varchar)) else cast(m.id as varchar) end),     
    i.sys_active, 
    ii.Quantidade,    
    ii.Valor_Unitario,    
    ii.Acrescimo,     
    ii.Desconto,     
    i.Recurrence,     
    m.valor,     
    m.valor_pago,
    m.data, 
    unit.nome_fantasia, 
    unit.id,    
    unit.nome_unidade,
    pacconta.CPF,     
    pacconta.id,     
    pacconta.nome_paciente,
    unit.cnpj,
    unit.endereco,
	unit.complemento,
	unit.cep,
	unit.numero,
	unit.bairro,
	unit.cidade,
	unit.estado,
	unit.tel1,
	unit.tel2,
	unit.cel1,
	unit.email1,
    i.credito_debito,    
    proc.nome_procedimento, 
    procgrup.nomegrupo,    
    proc.id,     
    m.descricao,     
    m.forma_pagamento_id,     
    ct.parcelas,     
    cat.name,     
    subcat.name,     
    m.conta_id,	
    tp.id,     
    tp.nome_tabela_particular,     
    ur.descricao,     
    m.id,     
    movpay.data
ORDER BY 
    m.Data, 
    m.id   
), feegow as (
select 
	datapagamento,
	extract (month from datapagamento) as mes_pagamento,
	extract (year from datapagamento) as ano_pagamento,
	cast(27602235000100 as varchar) as cnpjfilial, 
	cast(01001 as varchar) as filial,
	cnpj, 
	nome_unidade as nomecliente,
	'j' as tipo,
	nome_fantasia as nomefantasia,
	endereco,
	complemento,
	bairro,
	estado,
	null as codigomunicipio,
	cidade as municipio,
	cep,
	COALESCE(
    CASE WHEN tel1 IS NOT NULL AND tel1 != '' THEN REGEXP_REPLACE(SUBSTRING(tel1 FROM 2 FOR 4), '[^0-9]', '') END,
    CASE WHEN tel2 IS NOT NULL AND tel2 != '' THEN REGEXP_REPLACE(SUBSTRING(tel2 FROM 2 FOR 4), '[^0-9]', '') END,
    CASE WHEN cel1 IS NOT NULL AND cel1 != '' THEN REGEXP_REPLACE(SUBSTRING(cel1 FROM 2 FOR 4), '[^0-9]', '') END
) AS ddd,
COALESCE(
    CASE WHEN tel1 IS NOT NULL AND tel1 != '' THEN REGEXP_REPLACE(SUBSTRING(tel1 FROM 6), '\\s|-', '') END,
    CASE WHEN tel2 IS NOT NULL AND tel2 != '' THEN REGEXP_REPLACE(SUBSTRING(tel2 FROM 6), '\\s|-', '') END,
    CASE WHEN cel1 IS NOT NULL AND cel1 != '' THEN REGEXP_REPLACE(SUBSTRING(cel1 FROM 6), '\\s|-', '') END
) AS telefone,
email1 as email,
nome_procedimento as descricao,
sum(valor_pago) as valor,
CONCAT('L', CAST(EXTRACT(MONTH FROM datapagamento) AS VARCHAR), CAST(EXTRACT(YEAR FROM datapagamento) AS VARCHAR)) AS lote
	from final_query
	where 1=1
	--and data = date('2023-01-10') --filtro
	--and nome_fantasia = 'AmorSaúde Contagem' -- filtro
group by
	datapagamento,
	cnpj, 
	nome_unidade,
	nome_fantasia,
	endereco,
	complemento,
	bairro,
	estado,
	cidade,
	cep,
	tel1,
    tel2,
    cel1,
	email1,
	nome_procedimento
	), 
    --WEBDENTAL
    fcp as (
select 
	*
    from todos_data_lake_trusted_webdental.tbl_financeiro_clinica_parcelas
),
ua as (
select 
	*
    from todos_data_lake_trusted_webdental.tbl_unidade_atendimento
),
cpc as (
select 
    *
    from todos_data_lake_trusted_webdental.tbl_categoria_plano_conta
),
gf as (
select 
	*
    from todos_data_lake_trusted_webdental.tbl_grupo_financeiro
),
	webdental as ( -- aqui começa webdental	
	SELECT 
	cast(sub.dt_baixa as date) as datapagamento,
	extract (month from cast(sub.dt_baixa as date)) AS mes_pagamento,
	extract (year from cast(sub.dt_baixa as date)) AS ano_pagamento,	
	cast(27602235000100 AS VARCHAR) AS cnpjfilial,
	cast(01001 AS VARCHAR) AS filial,
	REGEXP_REPLACE(sub.cnpj, '[^0-9]', '') AS cnpjcliente,
	sub.nm_unidade_atendimento AS nomecliente, 
	'J' AS tipo,	
		case 
			when sub.nome_fantasia = '' or sub.nome_fantasia is null 
				then sub.nm_unidade_atendimento else sub.nome_fantasia 
				end AS nomefantasia,	
	(sub.rua || ', '|| sub.numero) AS endereco,
	sub.complemento, 
	sub.cd_bairro AS bairro,
	sub.estado, 
	null AS codigomunicipio, 
	sub.cd_cidade AS municipio, 
	REPLACE(sub.cep, '-', '') AS cep,
	CASE 
        WHEN sub.num_telefone_1 IS NOT NULL and sub.num_telefone_1 != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(sub.num_telefone_1, '[^0-9]', ''), 1, 2) AS varchar)
        WHEN sub.num_telefone_2 IS NOT NULL AND sub.num_telefone_2 != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(sub.num_telefone_2, '[^0-9]', ''), 1, 2) AS varchar)
        WHEN sub.num_telefone_3 IS NOT NULL AND sub.num_telefone_3 != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(sub.num_telefone_3, '[^0-9]', ''), 1, 2) AS varchar)
    END AS ddd,
	COALESCE(
   		CASE WHEN sub.num_telefone_1 IS NOT NULL AND sub.num_telefone_1 != '' THEN REGEXP_REPLACE(SUBSTRING(sub.num_telefone_1 FROM 3), '\\s|-', '') END,
    	CASE WHEN sub.num_telefone_2 IS NOT NULL AND sub.num_telefone_2 != '' THEN REGEXP_REPLACE(SUBSTRING(sub.num_telefone_2 FROM 3), '\\s|-', '') END,
    	CASE WHEN sub.num_telefone_3 IS NOT NULL AND sub.num_telefone_3 != '' THEN REGEXP_REPLACE(SUBSTRING(sub.num_telefone_3 FROM 3), '\\s|-', '') END
	) AS telefone,
	sub.email AS email, 
	'Base de calculo royalties' AS descricao, 
	sum(sub.valor_credito) AS valor, 
	CONCAT('L', CAST(EXTRACT(MONTH FROM cast(sub.dt_baixa as date)) AS VARCHAR), CAST(EXTRACT(YEAR FROM cast(sub.dt_baixa as date)) AS VARCHAR)) AS lote
FROM
(
	SELECT 
	    ua.chave AS chave_unidade, ua.cnpj, ua.nm_unidade_atendimento, ua.nome_fantasia, ua.rua,
		 ua.numero, ua.complemento, ua.cd_bairro, ua.estado, ua.cd_cidade, ua.cep, ua.num_telefone_1,
		 ua.num_telefone_2,  ua.num_telefone_3, ua.email, fcp.chave, fcp.valor_credito, fcp.dt_baixa
	FROM  fcp
	    inner join ua on(ua.cd_unidade_atendimento = fcp.cd_filial)
	    left join cpc on (fcp.plano_contas = cpc.chave) 
	    left join gf on(gf.chave = cpc.cd_grupo_plano_conta)
	WHERE 1=1 
		and (gf.saldoanterior is null or gf.saldoanterior = 'N')  
	    and (gf.nm_grupo_financeiro is null or (gf.nm_grupo_financeiro not like 'CR Funcionários' 
	    and gf.nm_grupo_financeiro not like 'CR - Dental Vidas (Repasse GTOs Próprio)' 
	    and gf.nm_grupo_financeiro not like 'CR - Resgate aplicações'
	    and gf.nm_grupo_financeiro not like 'DB%' 
	    and gf.nm_grupo_financeiro not like 'CR - Transação Bancária' 
	    and gf.nm_grupo_financeiro not like 'CR ADM%' 
	    and /* gf.nm_grupo_financeiro not like 'CR OP - ERRO%' and */ gf.nm_grupo_financeiro not like 'CR FIN - Emprestimo' 
	    and gf.nm_grupo_financeiro not like 'CR FIN - Juros%' 
	    and gf.nm_grupo_financeiro not like 'CR COM - Venda de Imp%'
	    and gf.nm_grupo_financeiro not like 'USO%' 
	    and gf.nm_grupo_financeiro not like 'Retirada%' 
	    and cpc.nm_categoria_plano_conta not like '%Vale de funcion%'))
	    and 
	    (
  (
    CAST(fcp.dt_vencimento AS DATE) >= DATE('2020-09-01') 
    AND fcp.tipo_movimento = 'D'
  ) 
  OR 
  (
    CAST(fcp.dt_baixa AS DATE) >= DATE('2020-09-01') 
    AND fcp.tipo_movimento = 'C'
  )
) 
	    AND (
  (
    CAST(fcp.dt_vencimento AS DATE) <= DATE('2020-09-30') 
    AND fcp.tipo_movimento = 'D'
  ) 
  OR 
  (
    CAST(fcp.dt_baixa AS DATE) <= DATE('2020-09-30') 
    AND fcp.tipo_movimento = 'C'
  )
)
	    and ua.chave IN ('L03300020200917101258' , 'L00200020130130174652')
	    and cpc.tipo_movimento = 'E'
		 AND ua.unidade_teste = 'N' 
	UNION
	SELECT
	    ua.chave AS chave_unidade, ua.cnpj, ua.nm_unidade_atendimento, ua.nome_fantasia, ua.rua,
		 ua.numero, ua.complemento, ua.cd_bairro, ua.estado, ua.cd_cidade, ua.cep, ua.num_telefone_1,
		 ua.num_telefone_2,  ua.num_telefone_3, ua.email, fcp.chave, fcp.valor_credito, fcp.dt_baixa
	FROM todos_data_lake_trusted_webdental.tbl_financeiro_clinica_parcelas as fcp
	    inner join todos_data_lake_trusted_webdental.tbl_unidade_atendimento as ua on(ua.cd_unidade_atendimento = fcp.cd_filial)
	    left join todos_data_lake_trusted_webdental.tbl_categoria_plano_conta as cpc on (fcp.plano_contas = cpc.chave) 
	    left join todos_data_lake_trusted_webdental.tbl_grupo_financeiro as gf  on(gf.chave = cpc.cd_grupo_plano_conta)
	WHERE 1=1 
		and (gf.saldoanterior is null or gf.saldoanterior = 'N')  
	   and (gf.nm_grupo_financeiro is null or (gf.nm_grupo_financeiro not like 'CR Funcionários' 
	   and gf.nm_grupo_financeiro not like 'CR - Dental Vidas (Repasse GTOs Próprio)' 
	   and gf.nm_grupo_financeiro not like 'CR - Resgate aplicações'
	   and gf.nm_grupo_financeiro not like 'DB%' 
	   and gf.nm_grupo_financeiro not like 'CR - Transação Bancária' 
	   and gf.nm_grupo_financeiro not like 'CR ADM%' 
	   and gf.nm_grupo_financeiro not like 'CR OP - ERRO%' 
	   and gf.nm_grupo_financeiro not like 'CR FIN - Juros%' 
	   and gf.nm_grupo_financeiro not like 'CR COM - Venda de Imp%' 
	   and gf.nm_grupo_financeiro not like 'CR FIN - Emprestimo' 
	   and gf.nm_grupo_financeiro not like 'USO%' 
	   and gf.nm_grupo_financeiro not like 'Retirada%' 
	   and cpc.nm_categoria_plano_conta not like '%Vale de funcion%'))
	  AND (
  (
    CAST(fcp.dt_vencimento AS DATE) >= DATE '2020-09-01' 
    AND fcp.tipo_movimento = 'D'
  ) 
  OR 
  (
    CAST(fcp.dt_baixa AS DATE) >= DATE '2020-09-01' 
    AND fcp.tipo_movimento = 'C'
  )
) 
	   AND (
  (
    CAST(fcp.dt_vencimento AS DATE) <= DATE '2020-09-30' 
    AND fcp.tipo_movimento = 'D'
  ) 
  OR 
  (
    CAST(fcp.dt_baixa AS DATE) <= DATE '2020-09-30' 
    AND fcp.tipo_movimento = 'C'
  )
)
	   and ua.chave IN ('L03300020200917101258' , 'L00200020130130174652')
	   and fcp.plano_contas =''
	   AND ua.unidade_teste = 'N'
) AS sub
group by 
sub.chave_unidade, 
sub.nm_unidade_atendimento,
sub.cnpj,
sub.nome_fantasia,
sub.nm_unidade_atendimento,
(sub.rua || ', '|| sub.numero),
sub.complemento, 
sub.cd_bairro,
sub.estado, 
sub.cd_cidade, 
sub.cep,
sub.num_telefone_1, sub.num_telefone_2, num_telefone_3,
sub.email,
sub.dt_baixa
),
    pes as (
select 
	*
    from todos_data_lake_trusted_webvidas.db_pessoa
),
  emp as (
select 
	*
    from todos_data_lake_trusted_webvidas.db_pessoa
),
doph as (
select 
	*
    from todos_data_lake_trusted_webvidas.db_operacao_plano_historico
),
dop as (
select 
    *
    from todos_data_lake_trusted_webvidas.db_operacao_plano
),
par as (
select 
	*
    from todos_data_lake_trusted_webvidas.db_parcelas
),
uni as (
select 
	*
    from todos_data_lake_trusted_webvidas.db_unidade
),
cid as (
select 
	*
    from todos_data_lake_trusted_webvidas.db_cidades
),
est as (
select 
	*
    from todos_data_lake_trusted_webvidas.db_estados
),
ender as (
select 
	*
    from todos_data_lake_trusted_webvidas.db_endereco
),
ende as (
select 
	*
    from todos_data_lake_trusted_webvidas.db_endereco
),
u as (
select 
	*
    from todos_data_lake_trusted_webvidas.db_unidade
),
fpp as (
select 
	*
    from todos_data_lake_trusted_webvidas.db_financeiro_pj_parcelas
),
fpj as (
select 
	*
    from todos_data_lake_trusted_webvidas.db_financeiro_pj
),
webvidaspj as ( --aqui começa webvidas PJ
SELECT 
cast(par.data_pagamento as date) as datapagamento, --add data de pagamento a pedido da consultoria totvs
    extract (month from cast(par.data_pagamento as date)) AS mes_pagamento,
	extract (year from cast(par.data_pagamento as date)) AS ano_pagamento,
    cast(05983170000157 AS VARCHAR) AS cnpjfilial, --adicionado cnpj filial franqueadora amorsaude nos dados da feegow a pedido do time de projetos
	cast(07001 AS VARCHAR) AS filial,
REGEXP_REPLACE(pes.cpf, '[^0-9]', '') AS cnpj,
pes.nome AS nomecliente, 
(case when pes.tipo_pessoa = 'FISICA' then 'F' ELSE 'J' END) AS tipo,
case when pes.tipo_pessoa = 'FISICA' then pes.nome  END AS nomefantasia,
TRIM(COALESCE(ender.tipo_logradouro || ' ', '') || ender.endereco || ', ' || ender.numero_endereco) AS endereco,
ender.endereco_complemento AS complemento, 
ender.bairro, 
est.sigla AS estado, 
SUBSTRING(CAST(ender.cod_municipio_ans AS VARCHAR) FROM 3 FOR 10) AS codigomunicipio,
cid.nome AS municipio, 
REPLACE(ender.cep, '-', '') AS cep,
CASE 
        WHEN pes.telefone IS NOT NULL AND pes.telefone != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(pes.telefone, '[^0-9]', ''), 1, 2) AS varchar)
        WHEN pes.telefone2 IS NOT NULL AND pes.telefone2 != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(pes.telefone2, '[^0-9]', ''), 1, 2) AS varchar)
        WHEN pes.celular IS NOT NULL AND pes.celular != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(pes.celular, '[^0-9]', ''), 1, 2) AS varchar)
    END AS ddd,
REPLACE
		   (
				REPLACE
				(
					REPLACE
					(
						REPLACE
						(
							REPLACE
							(
								COALESCE(NULLIF(pes.celular, ''), NULLIF(pes.telefone, ''), coalesce(pes.telefone2, '')), '(', ''
							), ')', ''
						), '-', ''
					), ' ', ''
				), '_', ''
			) AS telefone,
lower(pes.email) AS email,
'Mensalidade plano odontológico' AS descricao, 
sum(par.valor_projetado) AS valor, 
CONCAT('L', CAST(EXTRACT(MONTH FROM cast(par.data_pagamento as date)) AS VARCHAR), CAST(EXTRACT(YEAR FROM cast(par.data_pagamento as date)) AS VARCHAR)) AS lote
FROM pes
    INNER JOIN (
        SELECT id_titular, id_cliente, id_operacao, id_unidade_venda, id_empresa
        FROM dop
        UNION 
		  SELECT id_titular, id_cliente, id_operacao, id_unidade_venda, id_empresa
        FROM doph
    ) ope ON pes.id_cliente = ope.id_cliente
    INNER JOIN par ON ope.id_operacao = par.id_operacao
    INNER JOIN ender ON ender.id_cliente = pes.id_cliente
    INNER JOIN uni ON uni.id_unidade = ope.id_unidade_venda
    LEFT JOIN cid ON cid.cod_cidades = ender.cod_cidade
    LEFT JOIN est ON est.cod_estados = cid.estados_cod_estados
WHERE
    	(
		 	(par.data_vencimento_parcela BETWEEN '2023-09-01' AND '2023-09-30' AND (par.data_pagamento IS NULL OR par.data_pagamento >= '2023-09-01'))
         or
			(par.data_vencimento_parcela > '2023-09-30' AND par.data_pagamento BETWEEN '2023-09-01' AND '2023-09-30')
		)
    AND par.parcela_cancelada = 0
    AND (ope.id_empresa IS NULL OR ope.id_empresa = 0)
    AND par.valor_projetado > 0
    AND pes.data_efetivacao_cliente IS NOT NULL
    AND uni.unidade_teste = 0
GROUP BY 
par.data_pagamento,
ope.id_titular, 
pes.id_cliente, 
pes.cpf,
pes.tipo_pessoa,
pes.cnpj,
pes.nome,
TRIM(COALESCE(ender.tipo_logradouro || ' ', '') || ender.endereco || ', ' || ender.numero_endereco),
ender.endereco_complemento, 
ender.bairro, 
est.sigla, 
ender.cod_municipio_ans,
CASE 
        WHEN pes.telefone IS NOT NULL AND pes.telefone != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(pes.telefone, '[^0-9]', ''), 1, 2) AS varchar)
        WHEN pes.telefone2 IS NOT NULL AND pes.telefone2 != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(pes.telefone2, '[^0-9]', ''), 1, 2) AS varchar)
        WHEN pes.celular IS NOT NULL AND pes.celular != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(pes.celular, '[^0-9]', ''), 1, 2) AS varchar)
    end,
cid.nome, 
ender.cep,
REPLACE
		   (
				REPLACE
				(
					REPLACE
					(
						REPLACE
						(
							REPLACE
							(
								COALESCE(NULLIF(pes.celular, ''), NULLIF(pes.telefone, ''), coalesce(pes.telefone2, '')), '(', ''
							), ')', ''
						), '-', ''
					), ' ', ''
				), '_', ''
			),
pes.email
),
webvidaspf as ( -- aqui começa webvidas PF
--# Faturamento PF
SELECT   
cast(fpj.data_pagamento as date) as datapagamento, --add data de pagamento a pedido da consultoria totvs
extract (month from cast(fpj.data_pagamento as date)) AS mes_pagamento,
extract (year from cast(fpj.data_pagamento as date)) AS ano_pagamento,
cast(05983170000157 AS VARCHAR) AS cnpjfilial, --adicionado cnpj filial franqueadora amorsaude nos dados da feegow a pedido do time de projetos
cast(07001 AS VARCHAR) AS filial,
REGEXP_REPLACE(emp.cnpj, '[^0-9]', '') AS cnpj,
pes.nome AS nomecliente, 
'J' AS tipo,
COALESCE(pes.nome_fantasia, pes.nome) AS nomefantasia,
TRIM(COALESCE(ender.tipo_logradouro || ' ', '') || ender.endereco || ', ' || ender.numero_endereco) as endereco,
ender.endereco_complemento AS complemento, 
ender.bairro, 
est.sigla AS estado, 
SUBSTRING(CAST(ender.cod_municipio_ans AS VARCHAR) FROM 3 FOR 10) AS codigomunicipio,
cid.nome AS municipio, 
REPLACE(ender.cep, '-', '') AS cep,
CASE 
        WHEN pes.telefone IS NOT NULL AND pes.telefone != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(pes.telefone, '[^0-9]', ''), 1, 2) AS varchar)
        WHEN pes.telefone2 IS NOT NULL AND pes.telefone2 != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(pes.telefone2, '[^0-9]', ''), 1, 2) AS varchar)
        WHEN pes.celular IS NOT NULL AND pes.celular != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(pes.celular, '[^0-9]', ''), 1, 2) AS varchar)
    END AS ddd,
		   REPLACE
		   (
				REPLACE
				(
					REPLACE
					(
						REPLACE
						(
							REPLACE
							(
								COALESCE(NULLIF(pes.celular, ''), NULLIF(pes.telefone, ''), coalesce(pes.telefone2, '')), '(', ''
							), ')', ''
						), '-', ''
					), ' ', ''
				), '_', ''
			) AS telefone,
lower(pes.email) AS email,
'Mensalidade plano odontológico empresa' AS descricao, 
sum(fpj.valor_pagar) AS valor, 
CONCAT('L', CAST(EXTRACT(MONTH FROM cast(fpj.data_pagamento as date)) AS VARCHAR), CAST(EXTRACT(YEAR FROM cast(fpj.data_pagamento as date)) AS VARCHAR)) AS lote
from par
    INNER JOIN
	 (
        select id_operacao, id_cliente, id_unidade_venda, id_empresa
        from dop
        union
        select id_operacao, id_cliente, id_unidade_venda, id_empresa
        from doph
    ) ope ON par.id_operacao = ope.id_operacao 
    INNER JOIN pes on pes.id_cliente = ope.id_cliente
    INNER JOIN u on u.id_unidade = ope.id_unidade_venda
    INNER JOIN emp on ope.id_empresa = emp.id_cliente
    INNER JOIN ender ON emp.id_cliente = ender.id_cliente
    INNER JOIN fpp on fpp.id_operacao = par.id_operacao and fpp.num_parcela = par.num_parcela
    INNER JOIN fpj on fpj.id = fpp.id_financeiro_pj
    INNER JOIN ende ON ende.id_cliente = emp.id_cliente
    LEFT JOIN cid ON ende.cod_cidade = cid.cod_cidades
    LEFT JOIN est ON est.cod_estados = cid.estados_cod_estados
where par.parcela_cancelada = 0
	and u.unidade_teste = 0
	and extract(month from cast(fpj.data_vencimento as date)) = 9
	and extract (year from cast(fpj.data_vencimento as date)) = 2023
GROUP BY emp.id_cliente,
emp.cnpj,
fpj.data_pagamento,
pes.nome,
COALESCE(pes.nome_fantasia, pes.nome),
TRIM(COALESCE(ender.tipo_logradouro || ' ', '') || ender.endereco || ', ' || ender.numero_endereco),
SUBSTRING(CAST(ender.cod_municipio_ans AS VARCHAR) FROM 3 FOR 10),
ender.endereco_complemento, 
ender.bairro, 
est.sigla,
cid.nome, 
REPLACE(ender.cep, '-', ''),
CASE 
        WHEN pes.telefone IS NOT NULL AND pes.telefone != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(pes.telefone, '[^0-9]', ''), 1, 2) AS varchar)
        WHEN pes.telefone2 IS NOT NULL AND pes.telefone2 != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(pes.telefone2, '[^0-9]', ''), 1, 2) AS varchar)
        WHEN pes.celular IS NOT NULL AND pes.celular != '' 
            THEN CAST(SUBSTRING(REGEXP_REPLACE(pes.celular, '[^0-9]', ''), 1, 2) AS varchar)
    end,
 REPLACE
		   (
				REPLACE
				(
					REPLACE
					(
						REPLACE
						(
							REPLACE
							(
								COALESCE(NULLIF(pes.celular, ''), NULLIF(pes.telefone, ''), coalesce(pes.telefone2, '')), '(', ''
							), ')', ''
						), '-', ''
					), ' ', ''
				), '_', ''
			),
lower(pes.email)
)
select * from (
select * from feegow
union all
select * from webdental
union all
select * from webvidaspj
union all
select * from webvidaspf
) limit 100



--MODELAGEM_FL_SPLIT
with m as (
select 
  *
  from todos_data_lake_trusted_feegow.movimentacao
),
s as (
select 
  *
  from todos_data_lake_trusted_feegow.splits
),
u as (
select 
  *
  from todos_data_lake_trusted_feegow.unidades
),
tef as (
select 
  *
  from todos_data_lake_trusted_feegow.tef_autorizacao
),
fp as (
select 
  *
  from todos_data_lake_trusted_feegow.formas_pagamento
), teste as (
select 
s."data", 
sum(m.valor) as valor_conta, round(sum(s.valor/100),2) as valor_split, 
u.id as unidade_id, u.nome_fantasia , 
fp.forma_pagamento, tef.sellerid 
from m
--left join todos_data_lake_trusted_feegow.contas i on i.id = m.conta_id 
inner join s on s.movimentacao_id = m.id 
left join u on u.id = m.unidade_id
left join tef on tef.unidadeid = u.id 
left join fp on fp.id = m.forma_pagamento_id 
--left join todos_data_lake_trusted_feegow.microtef_logs ml on ml.conta_id = i.id
--left join pdgt_maistodos_adquirencia.fl_transacao t on t.id_transacao = ml.administrativecode
--left join todos_data_lake_trusted_feegow.split_recebedores sr on sr.split_code = s.split_key
--left join pdgt_maistodos_adquirencia.fl_transacao at on at.id_seller = tef.sellerid 
where 1 = 1
and s.isroyalties = 1
--and s.id is not null
--and m.id = 158538273
and u.id in (19457,19823,19485,19366,19812,19803,19624,19918,19848,
19670,19811,19329,19308,19850,19649,19304,19272,19457,19350,19610,19516,19409,
19431,19771,19827,19294,19292, 19669, 19932, 19615, 19820)
and cast(s."data" as date) between date('2024-01-01') and date('2024-01-18')
--and s.split_key = 'bf94a7d4c63f40ab8ebc655844330260'
group by u.id, u.nome_fantasia , 
fp.forma_pagamento, 
tef.sellerid , s."data"
order by s."data" 
)
select sum(valor_conta), sum(valor_split) 
from teste
where unidade_id = 19329


select sum(valor_conta), sum(valor_split)  
from pdgt_sandbox_gabrielguilherme.fl_split_vmk 
where unidade_id = 19329
and "data" between date('2024-01-01') and date('2024-01-18')



select t.dt_transacao, 
sum(t.vlr_venda_liquida) vlr_venda_liquida,
sum(t.vlr_bruto_receber) vlr_bruto_receber, 
sum(t.vlr_receber) vlr_receber
from pdgt_maistodos_adquirencia.fl_transacao t
where 1=1
--and t.id_transacao  = 'e3d6ae7f055248a69a7afef62f44f429'
and t.id_seller = '33eac67255da4c1f93f48331c8e84ac5'
and cast(t.dt_transacao as date) between date('2024-01-01') and date('2024-01-18')
and t.flag_status = 1
group by t.dt_transacao 
limit 100

select * from pdgt_maistodos_adquirencia.fl_transacao a
limit 100

select * from pdgt_amorsaude_projetos.fl_clienteincluir 
limit 10

--modelagem receita bruta com royalties e splits
with receitabruta as (
select round(sum(x.TotalRecebido), 2) as "Total_Recebido", round(sum(x.TotalRoyalties), 2) as "Total_Royalties", Data, id_unidade from (
SELECT
	t.Data "Data",
	und.Nome_Fantasia,
	und.id as id_unidade,
	t.SellerID,
	reg.descricao Regiao, 
        --CASE WHEN t.PagTODOS THEN 'Sim' ELSE 'Não' END PagTodos, 
        ROUND(SUM(t.ValorFinal), 2) TotalRecebido, 
        ROUND(SUM(t.ValorFinal * 0.04), 2) TotalRoyalties,
	t.FormaPagto FormaPagamento,
	t.Tipo,
	t.Unidade_ID,
	forma_pagamento_id FormaPagamentoID,
	forma_pagamento,
	und.CNPJ
FROM
((
	SELECT CONCAT('PART', cast(mov.id as varchar)) id, idesc.Valor ValorFinal, mov.Data DATA, (case when ca.Integracao_SPLIT = 'S' then 1 else 0 end) PagTODOS, tef.SellerID, mov.Unidade_ID, fpm.forma_pagamento FormaPagto, 'Particular' Tipo, mov.forma_pagamento_id, ii.Desconto, ii.Quantidade * (ii.Valor_Unitario) ValorSemDesconto
	FROM
			todos_data_lake_trusted_feegow.movimentacao mov
	LEFT JOIN todos_data_lake_trusted_feegow.pagamento_item_associacao idesc ON idesc.pagamento_id = mov.id
	LEFT JOIN todos_data_lake_trusted_feegow.conta_itens ii ON ii.id = idesc.Item_ID
	LEFT JOIN todos_data_lake_trusted_feegow.devolucoes_itens devit ON devit.conta_itens_id = ii.id
	LEFT JOIN todos_data_lake_trusted_feegow.devolucoes dev ON dev.id = devit.devolucoes_ID
	INNER JOIN todos_data_lake_trusted_feegow.formas_pagamento fpm ON mov.forma_pagamento_id = fpm.id
	LEFT JOIN todos_data_lake_trusted_feegow.tef_autorizacao tef ON tef.UnidadeID = mov.Unidade_ID
	LEFT JOIN todos_data_lake_trusted_feegow.contas_correntes ca ON ca.id = mov.conta_id_debito
	WHERE
			mov.Data BETWEEN date('2022-01-01') AND current_date AND mov.tipo_movimentacao <> 'Bill' AND mov.credito_debito = 'D' AND mov.associacao_conta_id_credito = 3
	GROUP BY
        idesc.id, mov.id, idesc.Valor, mov.data, ca.Integracao_SPLIT, tef.SellerID, mov.Unidade_ID, fpm.forma_pagamento, mov.forma_pagamento_id, ii.Desconto, ii.Quantidade, ii.Valor_Unitario
) 
UNION ALL 
(
	SELECT CONCAT('GCONS', cast(gc.id as varchar)) id, gc.ValorProcedimento ValorFinal, gc.DataAtendimento "Data", 0 PagTODOS, tef.SellerID, gc.UnidadeID, 'Guia Consulta' FormaPagto, 'Convênio' Tipo, 21 PaymentMethodID, 0 Desconto, 0 ValorSemDesconto
	FROM
		todos_data_lake_trusted_feegow.tiss_guia_consulta gc
	LEFT JOIN todos_data_lake_trusted_feegow.tef_autorizacao tef ON tef.UnidadeID = gc.UnidadeID
	WHERE DATE(gc.DataAtendimento) BETWEEN date('2022-01-01') AND current_date AND gc.sysActive = 1 AND (gc.GuiaStatus <> 4 OR gc.GuiaStatus IS null)
	GROUP BY
        gc.id, gc.ValorProcedimento, gc.DataAtendimento, gc.DataAtendimento, tef.SellerID, gc.UnidadeID
) 
UNION ALL 
(
	SELECT CONCAT('GSADT', cast(igs.id as varchar)) id, igs.ValorTotal ValorFinal, igs.Data, 0 PagTODOS, tef.SellerID, gs.UnidadeID, 'Guia SADT' FormaPagto, 'Convênio' Tipo, 22 PaymentMethodID, 0 Desconto, 0 ValorSemDesconto
	FROM
	todos_data_lake_trusted_feegow.tiss_procedimentos_sadt igs
	INNER JOIN todos_data_lake_trusted_feegow.tiss_guia_sadt gs ON gs.id = igs.GuiaID
	LEFT JOIN todos_data_lake_trusted_feegow.tef_autorizacao tef ON tef.UnidadeID = gs.UnidadeID
	WHERE DATE(igs.Data) BETWEEN date('2022-01-01') AND current_date AND gs.sysActive = 1 AND (gs.GuiaStatus <> 4 OR gs.GuiaStatus IS NULL)
	GROUP BY
        igs.id, igs.ValorTotal, igs.Data, tef.SellerID, gs.UnidadeID
) 
UNION ALL 
(
	SELECT CONCAT('DEV', cast(dev.id as varchar)) id, - dev.totalDevolucao ValorFinal, DATE(dev.sysDate), 0 PagTODOS, tef.SellerID, inv.unidade_id, 'Devolução' FormaPagto, 'Cancelamento' Tipo, 0 PaymentMethodID, 0 Desconto, 0 ValorSemDesconto
	FROM
	todos_data_lake_trusted_feegow.devolucoes dev
	INNER JOIN todos_data_lake_trusted_feegow.contas inv ON inv.id = dev.InvoiceID
	LEFT JOIN todos_data_lake_trusted_feegow.tef_autorizacao tef ON tef.UnidadeID = inv.unidade_id
	WHERE DATE(dev.sysDate) BETWEEN date('2022-01-01') AND current_date AND tipoOperacao = 1
	GROUP BY
	dev.id, dev.totalDevolucao, dev.sysDate, tef.SellerID, inv.unidade_id
) 
UNION ALL 
(
	SELECT CONCAT('REMOV', cast(movrem.id as varchar)) id, movrem.Valor ValorFinal, movrem.Data DATA, 0 PagTODOS, tef.SellerID, movrem.Unidade_ID, fpm.forma_pagamento FormaPagto, 'Particular' Tipo, movrem.forma_pagamento_id, 0 Desconto, 0 ValorSemDesconto
	FROM
	todos_data_lake_trusted_feegow.movimentacao_removidos movrem
	INNER JOIN todos_data_lake_trusted_feegow.formas_pagamento fpm ON movrem.forma_pagamento_id = fpm.id
	LEFT JOIN todos_data_lake_trusted_feegow.tef_autorizacao tef ON tef.UnidadeID = movrem.Unidade_ID
	WHERE DATE(movrem.Data) BETWEEN date('2022-01-01') AND current_date AND DATE(movrem.Data) <> DATE(movrem.Data_Remocao) AND movrem.tipo_movimentacao <> 'Bill' AND movrem.credito_debito = 'D' AND movrem.associacao_conta_id_credito = 3
) 
UNION ALL 
(
	SELECT CONCAT('XPAG', cast(movrem.id as varchar)) id, - movrem.Valor ValorFinal, DATE(movrem.Data_Remocao) DATA, 0 PagTODOS, tef.SellerID, movrem.Unidade_ID, 'Pagamento anulado' FormaPagto, 'Cancelamento' Tipo, movrem.forma_pagamento_id, 0 Desconto, 0 ValorSemDesconto
	FROM
	todos_data_lake_trusted_feegow.movimentacao_removidos movrem
	LEFT JOIN todos_data_lake_trusted_feegow.tef_autorizacao tef ON tef.UnidadeID = movrem.Unidade_ID
	WHERE DATE(movrem.Data_Remocao) BETWEEN date('2022-01-01') AND current_date AND DATE(movrem.Data) <> DATE(movrem.Data_Remocao) AND movrem.tipo_movimentacao <> 'Bill' AND movrem.credito_debito = 'D' AND movrem.associacao_conta_id_credito = 3
) 
UNION ALL 
(
	SELECT CONCAT('PEXT', cast(mov.id as varchar)) id, ii.Valor_Custo_Calculado ValorFinal, mov.Data DATA, 0 PagTODOS, tef.SellerID, mov.Unidade_ID, 'Pagto. Externo' FormaPagto, 'Pagto. Parcial' Tipo, 20 PaymentMethodID, 0 Desconto, 0 ValorSemDesconto
	FROM
	todos_data_lake_trusted_feegow.movimentacao mov
	LEFT JOIN todos_data_lake_trusted_feegow.pagamento_item_associacao idesc ON idesc.Pagamento_ID = mov.id
	LEFT JOIN todos_data_lake_trusted_feegow.conta_itens ii ON ii.id = idesc.Item_ID
	INNER JOIN todos_data_lake_trusted_feegow.formas_pagamento fpm ON mov.forma_pagamento_id = fpm.id
	LEFT JOIN todos_data_lake_trusted_feegow.tef_autorizacao tef ON tef.UnidadeID = mov.Unidade_ID
	LEFT JOIN todos_data_lake_trusted_feegow.contas_correntes ca ON ca.id = mov.conta_id_debito
	LEFT JOIN todos_data_lake_trusted_feegow.fornecedores forn ON forn.id = ii.executante_id AND ii.executante_associacao_id = 2
	INNER JOIN todos_data_lake_trusted_feegow.recebimentoparcial_fornecedores_unidades rfu ON forn.id = rfu.fornecedorid
	WHERE
	mov.Data BETWEEN date('2022-01-01') and current_date  AND mov.tipo_movimentacao <> 'Bill' AND mov.credito_debito = 'D' AND mov.associacao_conta_id_credito = 3 AND ii.Valor_Custo_Calculado > 0 AND forn.RecebeParcial = 1 
	GROUP BY
	idesc.id, mov.id, ii.Valor_Custo_Calculado,  mov.Data, tef.SellerID, mov.Unidade_ID
)) t
INNER JOIN todos_data_lake_trusted_feegow.unidades und ON und.id = t.Unidade_ID
LEFT JOIN todos_data_lake_trusted_feegow.unidades_regioes reg ON reg.id = und.regiao_id
LEFT JOIN todos_data_lake_trusted_feegow.formas_pagamento ON todos_data_lake_trusted_feegow.formas_pagamento.id = t.forma_pagamento_id
INNER JOIN (
	SELECT 'Convênio' tipo, 2 id UNION ALL
	SELECT 'Cancelamento' tipo, 3 id UNION ALL
	SELECT 'Particular' tipo, 4 id UNION ALL
	SELECT 'Pagto. Parcial' tipo, 5 id 
) AS tp ON t.tipo = tp.tipo
 --AND if('[Tipo]'=0, TRUE,tp.id = '[Tipo]') AND if('[PaymentMethod]'=0, TRUE,t.PaymentMethodID = '[PaymentMethod]')
GROUP by
	und.id,
	t.data,
	t.Unidade_ID,
	t.FormaPagto,
	t.Data,
	und.Nome_Fantasia,
	t.SellerID,
	reg.descricao,
	t.Tipo,
	forma_pagamento_id,
	forma_pagamento,
	und.CNPJ
ORDER BY
	t.Data,
	t.Unidade_ID,
	t.FormaPagto ) x group by x.id_unidade, x.data),
	royalties as (
	select 
	ry.datareferencia as data, 
	u.id as id_unidade,
	sum(ry.valortotalvendas) as TotalRoyalties,
	sum(ry.valorsplittotal) as ValorSplitado, 
	sum(ry.valortotalvendas) - sum(ry.valorsplittotal) as APagar, 
	ry.status as Status 
	from todos_data_lake_trusted_feegow.royalties_contas ry
left join todos_data_lake_trusted_feegow.unidades u on ry.unidadeid = u.id
left join todos_data_lake_trusted_feegow.unidades_regioes ur on u.regiao_id = ur.id
group by ry.datareferencia, u.id, ry.status)
select royalties.data as data_transacao, royalties.id_unidade, receitabruta.total_recebido as receitabruta, receitabruta.total_royalties as 
royalties, royalties.valorsplitado,
royalties.apagar as boletos, 
royalties.status from royalties
left join receitabruta on royalties.id_unidade = receitabruta.id_unidade and receitabruta.data = royalties.data
where receitabruta.id_unidade is not null 
and royalties.id_unidade = 19329
and royalties.data between date('2024-01-01') and date('2024-01-18')





--MODELAGEM FL_FL_TRANSACAO TITULOINCLUIR
select * from todos_data_lake_trusted_feegow.unidades 
where nome_fantasia  in ('AmorSaúde Ribeirão Preto', 'AmorSaúde Araraquara')
limit 10

select count(*), r.sistema_origem 
from pdgt_amorsaude_projetos.fl_clienteincluir r
group by r.sistema_origem

select * from pdgt_maistodos_adquirencia.fl_transacao 
where status_transacao = 'succeeded'
--and id_transacao = 'e13863cebfc148bba1a234d84b7f655c'
order by dt_transacao desc


select * from todos_data_lake_trusted_feegow.microtef_logs l
inner join pdgt_maistodos_adquirencia.fl_transacao t on t.id_transacao = l.administrativecode 
--left join todos_data_lake_trusted_feegow.movimentacao m on m.id = l.movimento_id 
--left join todos_data_lake_trusted_feegow.contas i on i.id = m.conta_id 
--left join todos_data_lake_trusted_feegow.conta_itens ii on ii.conta_id = i.id
--left join todos_data_lake_trusted_feegow.procedimentos p on p.id = ii.procedimento_id 
where t.id_seller = '086885024f8d4c1b9a3daaf4c2f6b6a7'
and t.id_transacao = 'c6d2a0f4a26c443da223ba98576a8c62'
