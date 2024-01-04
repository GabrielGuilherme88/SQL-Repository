------------------------------------------------------------------------------------------------
with tabela_precos as (
select
	u.id as id_unidade, 
	u.nome_fantasia as NomeFantasia, 
	ptp.inicio, 
	ptp.id as id_tabela, 
	ptp.nometabela as nometabela,
	ptp .tipo,
	pro.codigo_tuss, 
	pro.id as id_procedimento,
	pro.nome_procedimento as nome_procedimento,
	spt.tipoprocedimento,
	replace(replace(replace(replace(sum(ptpv.valor)
	::text,
	'$',
	'R$ '),
	',',
	'|'),
	'.',
	','),
	'|',
	'.') as valor,
	case
		when ptp.id in ('3050136', '3050134', '3050135', '3051815', '3023632', '3028892', '3030382', '3028615', '3020213', '3020213',
'3028890', '700502', '3051203', '3024345', '3047762', '3047952', '3046512', '3043505', '3024346', '3047763', '3022407', '3046039', '3041857',
'3041856', '3041858', '3049105', '3049108', '3024068', '3047745', '3046847', '3024347', '3029627', '3047458', '3047731', '3024062', '3047728',
'3024065', '3047736', '3024066', '3047737', '3029797', '3029798', '3029799', '3029796', '3029773', '3045309', '3024067', '3049110', '3047742',
'700506', '3051347', '3046715', '3046689', '3046716', '3024064', '3024063', '3047733', '3049411', '3051345', '3051344', '3051346', '3047744', '3026558',
'3049109', '3046844', '3046846', '3046845', '3047956', '3051249', '3051248', '3044214', '3045812', '3045813', '3045740', '3046326', '3046328', '3046327') 
then 'Tabela Nacional'
		else ''
	end as tabela_nacional
from
	stg_procedimentos_tabelas_precos ptp
left join stg_procedimentos_tabelas_precos_unidades ptpu on
	ptpu.procedimento_tabela_preco_id = ptp.id
left join stg_unidades u on
	ptpu.unidade_id = u.id
left join stg_procedimentos_tabelas_precos_valores ptpv on
	ptpv.tabelaid = ptp.id
left join stg_procedimentos pro on
	ptpv.procedimentoid = pro.id
left join stg_procedimentos_tipos spt on
	spt.id = pro.tipo_procedimento_id
group by
	u.id, 
	u.nome_fantasia, 
	ptp.id,
	ptp.nometabela,
	ptp .tipo,
	pro.codigo_tuss,
	pro.id,
	pro.nome_procedimento,
	ptp.inicio,
	spt.tipoprocedimento)
select
	*
from
	tabela_precos t
where
	1 = 1
	and id_unidade = 19543
	--filtra a unidade
	--and inicio > '2023-01-02' --filtra o inicio da tabela
	and nome_procedimento like 'Coleta Externa'
	
--buscar os id's das tabelas
	select
	ptp.id as id_tabela, 
	ptp.nometabela,
	ptp.tipo,
	pro.id as id_procedimento,
	pro.codigo_tuss,
	pro.nome_procedimento as nome_procedimento,
	spt.tipoprocedimento,
	replace(replace(replace(replace(sum(ptpv.valor)
	::text,
	'$',
	'R$ '),
	',',
	'|'),
	'.',
	','),
	'|',
	'.') as valor
from
	stg_procedimentos_tabelas_precos ptp
left join stg_procedimentos_tabelas_precos_unidades ptpu on
	ptpu.procedimento_tabela_preco_id = ptp.id
left join stg_unidades u on
	ptpu.unidade_id = u.id
left join stg_procedimentos_tabelas_precos_valores ptpv on
	ptpv.tabelaid = ptp.id
left join stg_procedimentos pro on
	ptpv.procedimentoid = pro.id
left join stg_procedimentos_tipos spt on
	spt.id = pro.tipo_procedimento_id
where
	u.id = (19438)
group by
	ptp.id, 
	ptp.nometabela,
	ptp.tipo,
	pro.id,
	pro.codigo_tuss,
	pro.nome_procedimento,
	spt.tipoprocedimento
	--and ptp.nometabela like 'Pacote Pré-Operatório - Cirurgia Oftalmológica%' #Use para validar alguns itens



-- tabela particulares para a modelaqgem no metabase time de backoffice
--filtrando apenas as tabelas de amorcirurgia
select * from stg_tabelas_particulares stp
left join stg_tabelas_particulares_unidades stpu on stpu.tabela_particular_id = stp.id 
left join stg_unidades su on su.id = stpu.unidade_id
where 1=1
and stp.id in ('830081', '830080', '830082', '830079')


--830081 Pacote Pré-Operatório - Cirurgia Geral - CDT
--830080 Pacote Pré-Operatório - Cirurgia Geral - PARTICULAR
--830082 Pacote Pré-Operatório - Cirurgia Oftalmológica - CDT
--830079 Pacote Pré-Operatório - Cirurgia Oftalmológica - PARTICULAR


select sum(tccaph.valorpago) from tb_consolidacao_contas_a_pagar_hist tccaph 
where tccaph.datapagamento  between  date('2023-11-01') and date('2023-11-26')
--and tccaph.nome_fantasia  like 'AmorSaúde Patos de Minas%'

