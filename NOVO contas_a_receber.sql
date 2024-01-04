--modelagem ok e foi colocada dentro do dw em sp_carrega_tb_consolidacao_contas_a_receber_hist_nova
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
from stg_movimentacao
),
ct as (
select 
	id,
	movimentacao_id,
	parcelas,
	bandeira_cartao_id,
	numero_transacao,
	numero_autorizacao
from	stg_transacao_cartao
),
bc as (
select 
	id,
	bandeira
from	stg_bandeiras_cartao
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
from	stg_contas
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
from	stg_conta_itens
),
pii as (
select 
	id
from
	stg_pacotes
),
movpay as (
select 
	id,
	"data",
	sys_user,
	forma_pagamento_id
from	stg_movimentacao
),
fdpay as (
select 
	pagamento_id,
	parcela_id
from	stg_pagamento_associacao
),
idesc as (
select 
	valor,
	item_id,
	pagamento_id
from	stg_pagamento_item_associacao
),
pacconta as(
select 
	cpf,
	id,
	nome_paciente
from	stg_pacientes
),
subcat as (
select 
	id,
	name,
	category
from	stg_planodecontas_receitas
),
cat as (
select 
	id,
	name
from	stg_planodecontas_receitas
),
proc as (
select 
	id,
	nome_procedimento,
	grupo_procedimento_id,
	tipo_procedimento_id
from	stg_procedimentos
),
prod as (
select 
	id
from	stg_produtos
),
procgrup as (
select 
	id,
	sysactive,
	nomegrupo
from	stg_procedimentos_grupos
),
unit as (
select 
	id, 
	nome_fantasia, 
	regiao_id
from	stg_unidades
),
pag3 as (
select 
	id
from	stg_pacientes
),
pag2 as (
select 
	id
from	stg_fornecedores
),
pag6 as (
select 
	id
from	stg_convenios
),
tp as (
select 
	id,
	nome_tabela_particular
from	stg_tabelas_particulares
),
users as (
select 
	id,
	id_relativo
from
	stg_usuarios
),
func as (
select 
	id,
	nome_funcionario
from	stg_funcionarios
),
ur as (
select 
	id,
	descricao
from	stg_unidades_regioes
),
sfdp as ( --adicionado para atender demanda dsa Gabriela Georgete
select
	id,
	forma_pagamento
from stg_formas_pagamento
),
final_query as (
select
	m."data" as data,
	m."data" as DataVencimento,
	movpay."data" as DataPagamento,
	pacconta.CPF CPFPaciente,
	i.recurrence,
	pacconta.id id_paciente,
	pacconta.nome_paciente,
	--i.credito_debito, --retirado
	bc.bandeira, --add demanda Uarlass
	sfdp.forma_pagamento, --add demanda Georgete
	proc.nome_procedimento,
	procgrup.nomegrupo,
	proc.id,
	i.sys_active,
	func.nome_funcionario, --add a pedido da Gabriela Georgete
	  unit.nome_fantasia as nome_unidade,
	    unit.id as id_unidade,
	   max(ii.quantidade) as quantidade, --adicionado max (bateu com a feegow quando olhado batatais) (a antiga era uma subquery com limit 1 que não é suportado no athena)
	    (case
		when 'S' = 'S' then (SUM(coalesce(idesc.valor, 0)))/ coalesce(i.Recurrence,	1)
		else coalesce(m.Valor_Pago,	0)	end) Valor_Pago,
		m.descricao as descricaomovimentacao,
	(case	when m.valor - (coalesce(m.valor_pago,	0) + 0.3) <= 0 then 'Quitado' when m.valor - (coalesce(m.valor_pago, 0) + 0.3) > 0
		and coalesce(m.valor_pago,
		0) > 0 then 'Parcialmente pago'
		else 'Em aberto'
	end) SituacaoConta,
	(case when m.forma_pagamento_id in (8, 10) then ct.Parcelas
		else 1
	end) as Parcelas,
	cat.name as categoria,
	subcat.name as subcategoria,
	tp.id as id_tabela,
	tp.nome_tabela_particular,
	ur.descricao as regional
from	m 
inner join i on	i.id = m.conta_id
inner join ii on	ii.conta_id = i.id
left join pii on	pii.id = ii.pacote_id
left join fdpay on	fdpay.parcela_id = m.id
left join movpay on	movpay.id = fdpay.pagamento_id
left join sfdp on sfdp.id = movpay.forma_pagamento_id --alterado m para movpay
left join idesc on	idesc.item_id = ii.id	and idesc.pagamento_id = movpay.id
left join ct on ct.movimentacao_id = movpay.id --alteração do relacionamento para buscar a bandeira -- alterado m para movpay
left join bc on	bc.id = ct.bandeira_cartao_id
left join pacconta on	pacconta.id = i.conta_id	and i.associacao_conta_id = 3
left join subcat on	subcat.id = ii.categoria_id
left join cat on	cat.id = subcat.Category
left join proc on	proc.id = ii.procedimento_id	and ii.tipo_item_id = 'S'
left join prod on	prod.id = ii.procedimento_id	and ii.tipo_item_id = 'M'
left join procgrup on	procgrup.id = proc.grupo_procedimento_id	and procgrup.sysActive = 1
left join unit on	unit.id = i.unidade_id
left join pag3 on	i.associacao_conta_id = 3	and i.conta_id = pag3.id
left join pag6 on	i.associacao_conta_id = 6	and i.conta_id = pag6.id
left join tp on	tp.id = i.tabela_particular_id
left join users on	movpay.sys_user = users.id
left join func on	users.id_relativo = func.id
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
	movpay.data,
	sfdp.forma_pagamento,
	func.nome_funcionario, --add Gorgete
	bc.bandeira--add Uarlass
order by
	m.Data,
	m.id
)
select
	*
from
	final_query
	where 1=1
	--para validação
	and id_unidade = 19957
and  DataPagamento between '2023-11-01' and current_date  --filtro de data
--and nome_paciente = 'ZULEIDE MARIA DE OLIVEIRA'
--group by forma_pagamento
--order by DataPagamento asc



--query que busca o nome do fornecedor
select * from stg_movimentacao sm 
left join stg_contas sc2 on sc2.id = sm.conta_id 
left join stg_conta_itens sci on sci.conta_id = sc2.id 
left join stg_conta_associacoes sca on sca.id = sci.executante_associacao_id 
LEFT JOIN stg_fornecedores sf ON sc2.associacao_conta_id =2 AND sc2.conta_id = sf.id
where sm.unidade_id = 19957
and sm.id = 148082676
and sm."data" between '2023-11-01' and '2023-11-16'

LEFT JOIN stg_fornecedores sf ON sc2.associacao_conta_id =2 AND sc2.conta_id = pag2.id

select * from stg_conta_itens ii
left join stg_fornecedores sf on sf. = ii.executante_id 
limit 10

select * from stg_fornecedores sf 
where sf.nomefornecedor  like 'Mr Holding de Participacao Ltda%'
limit 100

select * from stg_repasses sr 
where sr.conta_id = 405637
limit 10