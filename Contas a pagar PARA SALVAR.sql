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
    from {{ source('todos_data_lake_trusted_feegow','unidades_regioes') }}
),
u AS (
SELECT 
	id,
	nome_fantasia,
	regiao_id
    from {{ source('todos_data_lake_trusted_feegow','unidades') }}
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
    from {{ source('todos_data_lake_trusted_feegow','contas') }}
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
	conta_id
    from {{ source('todos_data_lake_trusted_feegow','conta_itens') }}
),
idesc as (
select 
	id,
	item_id,
	pagamento_id,
	valor
    from {{ source('todos_data_lake_trusted_feegow','pagamento_item_associacao') }}
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
	credito_debito
  from {{ source('todos_data_lake_trusted_feegow','movimentacao') }}
),
invrat as (
select 
	conta_id, 
	porcentagem
	  from {{ source('todos_data_lake_trusted_feegow','invoice_rateio') }}
),
ass as (
select 
	id,
	tabela_associacao
    from {{ source('todos_data_lake_trusted_feegow','conta_associacoes') }}
),
prod as (
select 
	id
    from {{ source('todos_data_lake_trusted_feegow','produtos') }}
),
subcat as (
select 
	id,
	name,
	category
    from {{ source('todos_data_lake_trusted_feegow','planodecontas_despesas') }}
),
dp as (
select 
	parcela_id,
	pagamento_id 
    from {{ source('todos_data_lake_trusted_feegow','pagamento_associacao') }}
),
movpay as (
select 
  id 
    from {{ source('todos_data_lake_trusted_feegow','movimentacao') }}
),
cat as (
select 
  id,
  name
    from {{ source('todos_data_lake_trusted_feegow','planodecontas_despesas') }}
),
final_query as (
select
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
	) AS Parcela                  
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
	ass.tabela_associacao
ORDER BY 
	m.data, 
	m.data_hora	
)
select * from final_query