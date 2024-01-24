--procedimentos ativos com valor das tabelas

SELECT
  ptp.id,
  ptp.nometabela,
   p.id AS Procedimentos__id,
   p.nome_procedimento,
   ptpv.valor,
   u.id AS Unidades__id,
   u.nome_fantasia
FROM
  todos_data_lake_trusted_feegow.procedimentos_tabelas_precos ptp
  LEFT JOIN todos_data_lake_trusted_feegow.procedimentos_tabelas_precos_unidades ptpu ON ptp.id = ptpu.procedimento_tabela_preco_id
  LEFT JOIN todos_data_lake_trusted_feegow.procedimentos_tabelas_precos_valores ptpv ON ptp.id = ptpv.tabelaid
  LEFT JOIN todos_data_lake_trusted_feegow.procedimentos p ON ptpv.procedimentoid = p.id
  LEFT JOIN todos_data_lake_trusted_feegow.unidades u ON ptpu.unidade_id = u.id
  where 1=1
 and ptp.id in (3028890,3020213,700504,700502) --filtra a tabela que precifica os procedimentos
    AND (p.ativo = 'on')
ORDER BY
  ptp.nometabela desc
  
  
  
 SELECT
  ptp.id,
  ptp.nometabela,
   p.id AS Procedimentos__id,
   p.nome_procedimento,
   p.valor as valor_procedimento,
   u.id AS Unidades__id,
   u.nome_fantasia
FROM
  todos_data_lake_trusted_feegow.procedimentos_tabelas_precos ptp
  LEFT JOIN todos_data_lake_trusted_feegow.procedimentos_tabelas_precos_unidades ptpu ON ptp.id = ptpu.procedimento_tabela_preco_id
  LEFT JOIN todos_data_lake_trusted_feegow.procedimentos_tabelas_precos_valores ptpv ON ptp.id = ptpv.tabelaid
  LEFT JOIN todos_data_lake_trusted_feegow.procedimentos p ON ptpv.procedimentoid = p.id
  LEFT JOIN todos_data_lake_trusted_feegow.unidades u ON ptpu.unidade_id = u.id
  where 1=1
 --and ptp.id in (3028890,3020213,700504,700502) --filtra a tabela que precifica os procedimentos
    AND (p.ativo = 'on')
ORDER BY
  ptp.nometabela desc
  
  
  select * from todos_data_lake_trusted_feegow.procedimentos p
  where 1 = 1
  and p.ativo = 'on'
  