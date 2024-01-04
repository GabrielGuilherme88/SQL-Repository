--Query Original tabela ft_exames_vendidos
select distinct
	cr.datapagamento,
	cr.id_unidade,
	cr.id_paciente,
	pro.id as id_procedimento,
	cr.id_tabela as id_tabela,
	cr.situacaoconta,
	cr.nome_funcionario, 
	sum(cr.valorpago) as valorpago 
from tb_consolidacao_contas_a_receber_hist cr
left join stg_procedimentos pro on cr.procedimento = pro.nome_procedimento
where cr.grupoprocedimento in ('Exames Laboratoriais', 'Procedimentos', 'Exame', 'Exames de Imagem', 'Mapa', 'Holter', 'Ressonância', 'Sessão')
and cr.datapagamento between '2021-01-01' and '2023-12-31'
group by cr.datapagamento, cr.id_unidade, cr.id_paciente, pro.id, cr.id_tabela, cr.situacaoconta, cr.nome_funcionario

--transsacional
select 
cr.nome_fantasia,
Sum(cr.valorpago) as valorpago1,
sum(cr.valor) as valor1
from tb_consolidacao_contas_a_receber cr
where cr.datapagamento between '2023-02-01' and '2023-02-28'
and cr.grupoprocedimento in ('Vacinas','Mapa','Holter','Procedimentos',
'Exames de Imagem','Exames Laboratoriais','Sessão', 'Ressonância', 'Terapias Injetáveis')
group by cr.nome_fantasia

--hist
select 
cr.nome_fantasia,
Sum(cr.valorpago) as valorpago1,
sum(cr.valor) as valor1
from tb_consolidacao_contas_a_receber_hist cr
where cr.datapagamento between '2023-02-01' and '2023-02-28'
and cr.grupoprocedimento in ('Vacinas','Mapa','Holter','Procedimentos',
'Exames de Imagem','Exames Laboratoriais','Sessão', 'Ressonância', 'Terapias Injetáveis')
group by cr.nome_fantasia




--validando dados  10/03/2023
--query abaixo: Referente a exames vendidos
select distinct
sum(cr.valorpago) as valorpago 
from tb_consolidacao_contas_a_receber_hist cr
left join stg_procedimentos pro on cr.procedimento = pro.nome_procedimento
where cr.grupoprocedimento in ('Exames Laboratoriais', 'Procedimentos', 'Exame', 'Exames de Imagem', 'Mapa', 'Holter', 'Ressonância', 'Sessão')
and cr.nome_fantasia = 'AmorSaúde Ribeirão Preto'
and cr.datapagamento between '2023-02-01' and '2023-02-28'


--query abaixo: Fonte de Dados que alimenta a tabela Contas a Receber
--o que diferencia a query abaixo da de cima, é exatamente o left join com stg_procedimentos, que aparentemente está com problemas
SELECT sum(tccar.valorpago) as valorpago,
count(*)
FROM tb_consolidacao_contas_a_receber_hist tccar
where tccar.grupoprocedimento in ('Exames Laboratoriais', 'Procedimentos', 'Exame', 'Exames de Imagem', 'Mapa', 'Holter', 'Ressonância', 'Sessão')
and tccar.nome_fantasia = 'AmorSaúde Ribeirão Preto'
and tccar.datapagamento between '2023-02-01' and '2023-02-28'



--nova query exames vendidos
select distinct
	cr.datapagamento,
	cr.id_unidade,
	cr.id_paciente,
	cr.id_tabela as id_tabela,
	cr.situacaoconta,
	cr.nome_funcionario, 
	cr.nomeprocedimento,
	cr.grupoprocedimento,
	sum(cr.valorpago) as valorpago 
from tb_consolidacao_contas_a_receber_hist cr
where cr.grupoprocedimento in ('Exames Laboratoriais', 'Procedimentos', 'Exame', 'Exames de Imagem', 'Mapa', 'Holter', 'Ressonância', 'Sessão')
and cr.datapagamento between '2021-01-01' and '2023-12-31'
group by cr.datapagamento, cr.id_unidade, cr.id_paciente, cr.id_tabela, cr.situacaoconta, cr.nome_funcionario, cr.nomeprocedimento, cr.grupoprocedimento

--Contas a receber:








