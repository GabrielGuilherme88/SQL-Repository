select * 
from todos_data_lake_trusted_feegow.fornecedores f
left join todos_data_lake_trusted_feegow.fornecedores_unidades fu on fu.fornecedor_id = f.id
where 1=1
and f.id in (16631,148450,167751)