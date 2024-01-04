--Verifica qtde de registros por data
select rf."data", count(*) as qtde_registro, sum(rf.total_recebido)
from tb_consolidacao_receita_bruta_hist_final rf
group by rf."data"
order by rf."data" desc

select * from tb_consolidacao_receita_bruta_hist_final tcrbhf 
limit 3

--Verifica qtde de registr por data
select rf.id_unidade, su.nome_fantasia  ,rf."data", count(*) as qtde_registro, sum(rf.total_recebido)
from tb_consolidacao_receita_bruta_hist_final rf
left join stg_unidades su on rf.id_unidade = su.id 
where rf."data" = '2023-03-06'
group by rf."data", rf.id_unidade, su.nome_fantasia
order by rf."data" desc


--alteração da query original da tabela de Faturamento Bruto da Central de Relatórios (Franqueadora)
select
	rb.datareferencia,
	u.id as id_unidade,
	rb.nome_fantasia,
	ur.descricao as regional,
	rb.formapagto,
	rb.nomegrupo,
	sum(rb.totalpago) as receitabruta,
	sum(rb.totalpago)*0.04 as totalroyalties
from tb_consolidacao_receita_bruta_hist rb
inner join stg_unidades u on rb.nome_fantasia = u.nome_fantasia
left join stg_unidades_regioes ur on u.regiao_id = ur.id
where u.nome_fantasia not in ('AmorSaúde Telemedicina', 
'Clínica de Treinamento', 'CENTRAL AMORSAÚDE', 
'AmorSaúde (Central Ribeirão Preto)')
group by rb.datareferencia, u.id, rb.nome_fantasia, ur.descricao, rb.formapagto, rb.nomegrupo

--Alterada para
select rbhf.total_recebido as receitabruta,
rbhf . total_royalties as totalroyalties,
rbhf."data" as datareferencia,
rbhf .id_unidade
from tb_consolidacao_receita_bruta_hist_final rbhf
where  rbhf.id_unidade not in (0 , 19896 , 19793 , 19774)
limit 5



--19774	Clínica de Treinamento
--19793	AmorSaúde (Central Ribeirão Preto)
--19896	AmorSaúde Telemedicina
--0	CENTRAL AMORSAÚDE

--Buscar os ID's das unidades para serem desconsiderados da Query
select id, nome_fantasia from stg_unidades u
where u.nome_fantasia in ('AmorSaúde Telemedicina', 
'Clínica de Treinamento', 'CENTRAL AMORSAÚDE', 
'AmorSaúde (Central Ribeirão Preto)')

--conferindo valores de fevereiro em relação ao BI (relatórios receita bruta no central de relatórios franqueadora)
select sum(rbhf.total_recebido) as receitabruta,
sum(rbhf.total_royalties) as totalroyalties
from tb_consolidacao_receita_bruta_hist_final rbhf
left join stg_unidades su on su.id = rbhf.id_unidade 
where  rbhf.id_unidade not in (0 , 19896 , 19793 , 19774)
and rbhf ."data" between '2023-02-01' and '2023-02-28'


--Verificar divergência 07/03/20223
select su.nome_fantasia ,sum(tcrbhf.total_recebido) from tb_consolidacao_receita_bruta_hist_final tcrbhf
left join stg_unidades su on su.id = tcrbhf .id_unidade 
where  tcrbhf.id_unidade not in (0 , 19896 , 19793 , 19774)
and tcrbhf ."data" between '2023-02-01' and '2023-02-28'
and su.nome_fantasia in ('Usisaúde Clínica Médica (Guaratinguetá)', 'Univitta (Campos dos Goytacazes)', 'Unidoctor (Penha SP)', 'Pró Saúde (Linhares 2)',
'Nossa Clínica (São Roque)', 'Mediclin (CONSELHEIRO LAFAIETE)', 'Med Odonto (Cachoeiro de Itapemirim)', 'Life Clinic (Sorocaba)', 'Instituto Médico Caucaia (Caucaia)', 'IMOCAMP (Campinas Sul)', 
'Dr. Saúde (DUQUE DE CAXIAS JARDIM)')
group by su.nome_fantasia
order by su.nome_fantasia desc

select sum(tcrbhf.total_recebido) from tb_consolidacao_receita_bruta_hist_final tcrbhf
left join stg_unidades su on su.id = tcrbhf .id_unidade 
where  tcrbhf.id_unidade not in (0 , 19896 , 19793 , 19774)
and tcrbhf ."data" between '2023-03-01' and '2023-03-6'
and su.nome_fantasia = 'AmorSaúde Baruerí'

select * from stg_unidades su 
order by su.nome_fantasia desc




