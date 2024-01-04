--modelagem dentro do git
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
	nome_fantasia, 
	regiao_id 
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
	m."data" as DataVencimento,
	movpay."data" as DataPagamento,
	pacconta.CPF CPFPaciente,
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
    max(ii.quantidade) as quantidade, --não suportou a subquery da antiga contas a receber rodando dentro do redshift -- a funcao max bate com a feegow
    (CASE 
        WHEN 'S'='S' THEN (SUM(coalesce(idesc.valor, 0)))/ COALESCE(i.Recurrence, 1) 
        ELSE coalesce(m.Valor_Pago, 0) 
    END) Valor_Pago,
    m.descricao as descricaomovimentacao,
   (CASE
	WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) <= 0 then 'Quitado' 
        WHEN m.valor - (coalesce(m.valor_pago, 0) + 0.3) > 0 and coalesce(m.valor_pago, 0) > 0 then 'Parcialmente pago' 
        ELSE 'Em aberto'
    END) SituacaoConta,
     (case 
        when m.forma_pagamento_id IN (8,10) then ct.Parcelas 
        else 1 
    end) as Parcelas,
    cat.name as categoria,
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
select sum(valor_pago) 
from final_query
where id_unidade in (19457,19823,19485,19366,19812,19803,19624,19918,19848, --filtro das unidades da VMK
19670,19811,19329,19308,19850,19649,19304,19272,19457,19350,19610,19516,19409,
19431,19771,19827,19294,19292) --para validação batatais 
and  DataPagamento between date('2023-09-01') and date('2023-09-30') --filtro de data


select sum(cr.valor_pago)
from pdgt_amorsaude_financeiro.fl_contas_a_receber cr
where cr.id_unidade in (19485)
and  cr.datapagamento =  date('2023-10-13') --filtro de data

select *
from pdgt_amorsaude_financeiro.fl_contas_a_receber_vmk vmk
where vmk.datapagamento = date('2023-10-13')
and vmk.id_unidade = 19485 --AmorSaúde Passos

select *
from pdgt_amorsaude_financeiro.fl_contas_a_receber_vmk vmk
where vmk.datapagamento = date('2023-10-13')
and vmk.nome_unidade = 'AmorSaúde Araraquara'
and vmk.cpfpaciente = '45126637894'