select
	u.id as id_unidade, 
	u.nome_fantasia as NomeFantasia, 
	ptp.id as id_tabela, 
	ptp.nometabela as nometabela,
	ptp .tipo,
	pro.id as id_procedimento, 
	pro.nome_procedimento as nome_procedimento,
	REPLACE(REPLACE(REPLACE(REPLACE(sum(ptpv.valor)
	::text,'$','R$ '),',','|'),'.',','),'|','.')
from stg_procedimentos_tabelas_precos ptp
left join stg_procedimentos_tabelas_precos_unidades ptpu on ptpu.procedimento_tabela_preco_id = ptp.id
left join stg_unidades u on ptpu.unidade_id = u.id
left join stg_procedimentos_tabelas_precos_valores ptpv on ptpv.tabelaid = ptp.id
left join stg_procedimentos pro on ptpv.procedimentoid = pro.id
where u.id = (19476)
and ptp.id in (3047162,3044301,3022796,3022264,3049803,3049804,3048686,3041776,
	3048687,918024,818024,3044991,3050900,3041800,3030299,3023279)
group by u.id, 
	u.nome_fantasia, 
	ptp.id,
	ptp.nometabela,
	ptp .tipo,
	pro.id, 
	pro.nome_procedimento

select distinct 
ptp.id,
	ptp.nometabela as nometabela
from stg_procedimentos_tabelas_precos ptp
left join stg_procedimentos_tabelas_precos_unidades ptpu on ptpu.procedimento_tabela_preco_id = ptp.id
left join stg_unidades u on ptpu.unidade_id = u.id
left join stg_procedimentos_tabelas_precos_valores ptpv on ptpv.tabelaid = ptp.id
left join stg_procedimentos pro on ptpv.procedimentoid = pro.id
where u.id = (19476)
and ptp.nometabela SIMILAR to '(CADIVA|CADIVA|Cartão de TODOS|cartao de todos|Cartão de TODOS (Cópia)|Cartão de TODOS (Custo)|
Cartão de TODOS (Custo) (Cópia)|cristiano us|GARANTIA DE SAUDE|GARANTIA DE SAUDE|MATERCLIN|MATERCLIN|MEDQUEST|MEDQUEST|
MEDQUEST CUSTO|PARTICULAR|PARTICULAR|PRO TG|PRO TG (Cópia)|REPASSE 18|REPASSES|RX)%'



