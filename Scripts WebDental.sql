with orcamento as (
SELECT ind.nm_indice, --pr.nm_prestador, 
 ot.manutencao,
       fp.dt_aprovacao AS dt_aprovacao, 
       CASE 
	       WHEN ot.manutencao <> 'N' THEN oi.receber_paciente 
	       		ELSE 0 
	   END AS valor_parcela, 
	   fp.valor_corrigido
FROM todos_data_lake_trusted_webdental.tbl_indicacoes_prestador AS ip
INNER JOIN todos_data_lake_trusted_webdental.tbl_paciente AS p ON ip.cd_paciente = p.chave
--INNER JOIN todos_data_lake_trusted_webdental.tbl_prestador AS pr ON ip.cd_prestador = pr.chave
INNER JOIN todos_data_lake_trusted_webdental.tbl_odonto_tratamento AS ot ON ip.cd_paciente = ot.cd_paciente
INNER JOIN todos_data_lake_trusted_webdental.tbl_financeiro_paciente AS fp ON ot.chave = fp.cd_tratamento
INNER JOIN todos_data_lake_trusted_webdental.tbl_odonto_intervencoes AS oi ON ot.chave = oi.cd_tratamento
INNER JOIN todos_data_lake_trusted_webdental.tbl_intervencao AS i ON oi.cd_intervencao = i.chave
INNER JOIN todos_data_lake_trusted_webdental.tbl_procedimento_generico AS pg ON i.cd_procedimento_generico = pg.chave
INNER JOIN todos_data_lake_trusted_webdental.tbl_indicespg AS ind ON pg.indicepg = ind.chave AND ip.cd_indice = ind.chave
WHERE fp.dt_aprovacao BETWEEN date('2023-01-01') AND date('2023-01-31')
  AND ip.cd_filial = 005 
  AND ip.cd_filial = ot.cd_filial 
  --AND ip.dt_cadastro <= ot.dtinicio
GROUP BY ot.chave, ip.cd_indice, ind.nm_indice, ot.manutencao, fp.dt_aprovacao, CASE WHEN ot.manutencao <> 'N' THEN oi.receber_paciente ELSE 0 end,
fp.valor_corrigido, nm_paciente
ORDER BY nm_paciente)
,
media_manutencao as (
select s.manutencoes_media as qtde_manutencao
from todos_data_lake_trusted_webdental.tbl_sistema s)
select 20 * sum(valor_parcela) from orcamento
	


--tabela onde busca a média de manutenções
--tabela modelada - pedir a modelagem dessa tabela
select * from todos_data_lake_trusted_webdental.tbl_sistema s
limit 1




--buscar o código de cd.filial para realizar filtragem nos códigos    
select * from todos_data_lake_trusted_webdental.tbl_unidade_atendimento a
--where a.nm_unidade_atendimento = 'AmorSaúde Ribeirão Preto'
limit 10

select *  
from todos_data_lake_trusted_webdental.tbl_unidade_atendimento a
where a.nm_unidade_atendimento = 'AmorSaúde Ribeirão Preto'
--where a.chave = 'L05200020170928161828'




with primeira as (
SELECT sum(oi.receber_paciente) as total
                from todos_data_lake_trusted_webdental.tbl_odonto_tratamento as ot
                inner join todos_data_lake_trusted_webdental.tbl_odonto_intervencoes as oi on ot.chave = oi.cd_tratamento
                where CAST(ot.dtinicio AS DATE) BETWEEN date('2023-06-01') AND date('2023-06-30')
                and ot.cd_tabela = 'L00500020140627134514' and ot.manutencao = 'N'),
segunda as (
SELECT sum(oi.receber_paciente) * 20 as total
                from todos_data_lake_trusted_webdental.tbl_odonto_tratamento as ot
                inner join todos_data_lake_trusted_webdental.tbl_odonto_intervencoes as oi on ot.chave = oi.cd_tratamento
                where CAST(ot.dtinicio AS DATE) BETWEEN date('2023-06-01') AND date('2023-06-30')
                and ot.cd_tabela  = 'L00500020140627134514' and ot.manutencao = 's'
                group by oi.receber_paciente)
select * from primeira
union ALL
select * from segunda


select *  
from todos_data_lake_trusted_webdental.tbl_odonto_tratamento as ot
limit 100

select * from todos_data_lake_trusted_webdental.tbl_odonto_intervencoes oi
limit 10

select * from todos_data_lake_trusted_webdental.tbl_desempenho_mensal



SHOW TABLES in todos_data_lake_trusted_webdental