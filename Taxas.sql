--query final no metabase
select sur.id as id_regional, sur.descricao as regional, 
su.id as id_unidade, su.nome_fantasia as unidade,
scc.id as id_conta_corrente, scc.nome_conta_corrente as nome_identificacao,
stcc.tipo_conta_corrente, 
sccp.minimo as qtde_minima_parcelas, sccp.maximo as qtde_maxima_parcelas,
replace(sccp.acrescimo_percentual,'.',',') as taxa_adm,
sbc.id as id_bandeira, sbc.bandeira
from stg_contas_correntes scc 
left join stg_contas_correntes_percentual sccp on sccp.contas_corrente_id = scc.id 
left join stg_bandeiras_cartao sbc on sbc.id = sccp.bandeira
left join stg_tipo_conta_corrente stcc on stcc.id = scc.tipo_conta_corrente 
left join stg_unidades su on su.id = scc.unidade_id
left join stg_unidades_regioes sur on sur.id = su.regiao_id
where 1=1
and scc.id = 3043 --validando com a interface

--3043 id conta corrente


select * from stg_contas_correntes scc
LIMIT 10



select * from stg_tabelas_particulares stp
left join stg_tabelas_particulares_unidades stpu on stpu.tabela_particular_id = stp.id 
left join stg_unidades su on su.id = stpu.unidade_id
where 1=1
and stp.nome_tabela_particular  like 'Pacote Pré-Operatório - Cirurgia Geral - CDT'


select count(*) from stg_tabelas_particulares_unidades tu
where tu.tabela_particular_id = 830081


select p.nometabela, p.tabelasparticulares,  p.inicio , p.fim, p.sys_date, p.dhup, pu.procedimento_tabela_preco_id, su.id as id_unidade
, su.nome_fantasia 
from stg_procedimentos_tabelas_precos p
left join stg_procedimentos_tabelas_precos_unidades pu on pu.procedimento_tabela_preco_id = p.id 
left join stg_unidades su on su.id = pu.unidade_id
where 1=1
--and p.nometabela like 'Pacote Pré-Operatório - Cirurgia Geral - CDT'
and p.tabelasparticulares is not null
and p.tabelasparticulares not in ('')

select * from stg_procedimentos_tabelas_precos sptp 