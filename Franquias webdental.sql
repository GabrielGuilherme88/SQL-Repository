select ua.cd_unidade_atendimento, upper(ua.nm_unidade_atendimento) as unidade_webdental, upper(ua.cd_cidade) as cidade_webdental,
from todos_data_lake_trusted_webdental.tbl_unidade_atendimento ua
--limit 100

with amorsaude_unidades as (
SELECT upper(sf.nomefornecedor) as nomecdt_amorsaude, upper(su.nome_fantasia), upper(su.cidade), su.id 
FROM todos_data_lake_trusted_feegow.fornecedores sf
left join todos_data_lake_trusted_feegow.unidades su on su.parceiro_institucional_id = sf.id
where su.nome_fantasia is not null),
webdetal_unidades as (
select ua.cd_unidade_atendimento, upper(ua.nm_unidade_atendimento), upper(ua.cd_cidade) 
from todos_data_lake_trusted_webdental.tbl_unidade_atendimento ua),
cdt_unidades as (
select distinct upper(f.fran_cidade) as cidade_franquia, upper(f.fran_unidade_franquia) as unidade_cdt,  upper(f.fran_nome_franquia) as nome_franquia, f.id_franquia
from pdgt_cartaodetodos_filiado.fl_filiado f
where f.fran_ativo = 'SIM')
select * from cdt_unidades

select * from pdgt_cartaodetodos_filiado
limit 10