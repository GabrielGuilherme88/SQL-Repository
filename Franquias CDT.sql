select distinct upper(f.fran_cidade) as cidade_franquia, upper(f.fran_unidade_franquia) as unidade_cdt,  
upper(f.fran_nome_franquia) as nome_franquia, f.id_franquia 
from pdgt_cartaodetodos_filiado.fl_filiado f
where f.fran_ativo = 'SIM'

select  count(distinct(f.id_franquia))
from pdgt_cartaodetodos_filiado.fl_filiado f
where f.fran_ativo = 'SIM'

select distinct upper(f.fran_cidade) as cidade_franquia, upper(f.fran_unidade_franquia) as unidade_cdt,  upper(f.fran_nome_franquia) as nome_franquia, f.id_franquia
from pdgt_cartaodetodos_filiado.fl_filiado f
--where f.fran_ativo = 'SIM'



