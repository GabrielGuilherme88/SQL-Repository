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
from stg_bandeiras_cartao
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
from stg_conta_itens
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
	sys_user
from stg_movimentacao
),
fdpay as (
select 
	pagamento_id,
	parcela_id
from stg_pagamento_associacao
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
spt as ( --adicionado para atender demanda dsa Gabriela Georgete
select
	id,
	tipoprocedimento
from stg_procedimentos_tipos
),
sfdp as ( --adicionado para atender demanda dsa Gabriela Georgete
select
	id,
	forma_pagamento
from stg_formas_pagamento
),
idprof as ( --adicionado para trazer o id do profissional
select distinct
	sci.id as id_contas, 
	sp.id as id_pofissional
from stg_contas sc 
left join stg_conta_itens sci on sci.conta_id = sc.id
left join stg_conta_associacoes sca on sca.id = sci.executante_associacao_id --and sca.id = 5 --filtrando status que indica que foi um profissional que executou
left join stg_profissionais sp on sp.id = sci.executante_id
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
	i.credito_debito,
	proc.id as id_procedimento,
	proc.nome_procedimento,
	procgrup.nomegrupo,
	spt.tipoprocedimento, --add
	sfdp.forma_pagamento, --add
	i.sys_active,
	func.id as id_funcionario, --add a pedido da Gabriela Georgete
	  unit.nome_fantasia as nome_unidade,
	    unit.id as id_unidade,
	   max(ii.quantidade) as quantidade, --adicionado max (bateu com a feegow quando olhado batatais) (a antiga era uma subquery com limit 1 que não é suportado no athena)
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
	end) as Parcelas,
	cat.name as categoria,
	subcat.name as subcategoria,
	tp.id as id_tabela,
	tp.nome_tabela_particular,
	ur.id as id_regional, --add
	ur.descricao as regional,
	id_pofissional --add
from m 
left join ct on ct.movimentacao_id = m.id
left join bc on	bc.id = ct.bandeira_cartao_id
inner join i on	i.id = m.conta_id
inner join ii on ii.conta_id = i.id
left join idprof on idprof.id_contas = ii.id --relacionamento adicionado para atender demanda Gabriela Georgete
left join pii on pii.id = ii.pacote_id
left join fdpay on	fdpay.parcela_id = m.id
left join movpay on	movpay.id = fdpay.pagamento_id
left join sfdp on sfdp.id = m.forma_pagamento_id --relacionamento adicionado para atender demanda Gabriela Georgete
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
	i.credito_debito,
	sfdp.forma_pagamento, --add
	proc.nome_procedimento,
	procgrup.nomegrupo,
	proc.id,
	spt.tipoprocedimento, --add
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
	func.id, --add
	id_pofissional  --add
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
	and id_unidade = 19957 --para validação
and  DataPagamento between '2023-09-01' and '2023-09-30' --filtro de data
--group by DataPagamento


--antigo que tinha dentro da pdgt --salvo para caso haja problemas

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
    from {{ source('todos_data_lake_trusted_feegow','movimentacao') }}
),
ct as (
select 
	id,
	movimentacao_id,
	parcelas,
	bandeira_cartao_id,
	numero_transacao,
	numero_autorizacao 
    from {{ source('todos_data_lake_trusted_feegow','transacao_cartao') }}
),
bc as (
select 
	id,
	bandeira 
    from {{ source('todos_data_lake_trusted_feegow','bandeiras_cartao') }}
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
    from {{ source('todos_data_lake_trusted_feegow','contas') }}
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
    from {{ source('todos_data_lake_trusted_feegow','conta_itens') }}
),
pii as (
select 
	id
    from {{ source('todos_data_lake_trusted_feegow','pacotes') }}
),
movpay as (
select 
	id,
	"data",
	sys_user 
    from {{ source('todos_data_lake_trusted_feegow','movimentacao') }}
),
fdpay as (
select 
	pagamento_id,
	parcela_id
    from {{ source('todos_data_lake_trusted_feegow','pagamento_associacao') }}
),
idesc as (
select 
	valor,
	item_id,
	pagamento_id
    from {{ source('todos_data_lake_trusted_feegow','pagamento_item_associacao') }}
),
pacconta as(
select 
	cpf,
	id,
	nome_paciente
    from {{ source('todos_data_lake_trusted_feegow','pacientes') }}
),
subcat as (
select 
	id,
	name,
	category
    from {{ source('todos_data_lake_trusted_feegow','planodecontas_receitas') }}
),
cat as (
select 
	id,
	name
    from {{ source('todos_data_lake_trusted_feegow','planodecontas_receitas') }}
),
proc as (
select 
	id,
	nome_procedimento,
	grupo_procedimento_id,
	tipo_procedimento_id
    from {{ source('todos_data_lake_trusted_feegow','procedimentos') }}
),
prod as (
select 
	id
    from {{ source('todos_data_lake_trusted_feegow','produtos') }}
),
procgrup as (
select 
	id,
	sysactive,
	nomegrupo
    from {{ source('todos_data_lake_trusted_feegow','procedimentos_grupos') }}
),
unit as (
select 
	id, 
	nome_fantasia, 
	regiao_id 
    from {{ source('todos_data_lake_trusted_feegow','unidades') }}
),
pag3 as (
select 
	id
    from {{ source('todos_data_lake_trusted_feegow','pacientes') }}
),
pag2 as (
select 
	id 
    from {{ source('todos_data_lake_trusted_feegow','fornecedores') }}
),
pag6 as (
select 
	id 
    from {{ source('todos_data_lake_trusted_feegow','convenios') }}
),
tp as (
select 
	id,
	nome_tabela_particular
    from {{ source('todos_data_lake_trusted_feegow','tabelas_particulares') }}
),
users as (
select 
	id,
	id_relativo 
    from {{ source('todos_data_lake_trusted_feegow','usuarios') }}
),
func as (
select 
	id
    from {{ source('todos_data_lake_trusted_feegow','funcionarios') }}
),
ur as (
select 
	id,
	descricao
    from {{ source('todos_data_lake_trusted_feegow','unidades_regioes') }}
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
    unit.nome_fantasia AS nome_unidade,
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
    movpay.data
ORDER BY 
    m.Data, 
    m.id   
)
select * from final_query


--validação do contas a receber da VMK
select sum(t.valor_pago), t.id_unidade, t.nome_unidade 
from tb_consolidacao_contas_a_receber_hist_nova t
where t.datapagamento between date('2023-09-01') and date('2023-09-30')
and t.id_unidade in (19669, 19932, 19615, 19820)
group by t.id_unidade, t.nome_unidade
