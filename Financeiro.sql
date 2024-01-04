
--top (2)
--query para buscar todos os valores acima de 0, que seria o recebiveis
select * from Mychesys.dbo.LANCAMENTO l
where 1=1
and l.ID_CLINICA = 19626
and l.VALOR_BAIXADO > 0
and l.STATUS_LANCAMENTO not in ('Cancelado', 'Não Baixado')
AND CAST(L.DT_BAIXA AS DATE) BETWEEN '2019-01-01' AND '2019-12-30'

--para agrupar
select sum(l.VALOR_BAIXADO), 
cast(l.DT_BAIXA as date) as BAIXA, 
cast(l.DT_CRIACAO as date) AS CRIACAO, 
cast(l.DT_VENCIMENTO  as date) AS VENCIMENTO, 
cast(l.DT_FECHAMENTO  as date) AS FECHAMENTO, 
cast(l.DT_APROVACAO  as date) AS APROVACAO
from Mychesys.dbo.LANCAMENTO l
where 1=1
and l.ID_CLINICA = 19626
and l.VALOR_BAIXADO > 0
and l.STATUS_LANCAMENTO not in ('Cancelado', 'Não Baixado')
AND CAST(L.DT_BAIXA AS DATE) BETWEEN '2019-01-01' AND '2019-12-31'
group by cast(l.DT_BAIXA as date), cast(l.DT_CRIACAO as date), cast(l.DT_VENCIMENTO  as date), cast(l.DT_FECHAMENTO  as date), cast(l.DT_APROVACAO  as date)


--buscar a unidade
select * from Mychesys.dbo.Clinica c 
where c.Nm_Clinica = 'AmorSaúde Porto Velho'