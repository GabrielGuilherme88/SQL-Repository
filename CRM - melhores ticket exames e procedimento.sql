----------------------
--query a ser utilizada
with ticket as (
select tccarm.id_paciente as paciente_id, 
	sum(tccarm.valor_pago)
	/count(*) as ticket_exames_procedimentos
from tb_consolidacao_contas_a_receber_modelagem tccarm
left join stg_pacientes sp on sp.id = tccarm .id_paciente
where tccarm.data_pagamento between  current_date - 360 and current_date -1
and tccarm.nomegrupo not in ('Consultas', 'Retorno') --ticket médio considera apenas exames e procedimentos 
group by tccarm.id_paciente),
--separando os pacientes com atendimento maior que 3 e com atendimento nos últimos 3 meses.
pacientes as ( 
select sa.paciente_id as paciente_id1, sp.cpf as cpf , sp.email as email, sp.nascimento as data_nascimento, sp.nome_paciente, sp.celular,  
DATEDIFF(year, sp.nascimento, CURRENT_DATE) AS idade,
count(sa.id) as qtde_atendimento, (max(sa."data") - current_date)*-1 as teste
from stg_atendimentos sa
left join stg_pacientes sp on sp.id = sa.paciente_id
where sa."data" between current_date - 360 and current_date -1
group by sa.paciente_id, sp.nome_paciente, sp.celular, 
	sp.cpf , sp.email, sp.nascimento, DATEDIFF(year, sp.nascimento, CURRENT_DATE)
having count(sa.id) >=3
and (max(sa."data") - current_date)*-1 <=90
and DATEDIFF(year, sp.nascimento, CURRENT_DATE) >=18),
resultado as ( --agrupando e transformando os resultados 
select paciente_id1, cpf, email, nome_paciente, celular,  qtde_atendimento,  REPLACE(REPLACE(REPLACE(REPLACE(sum(ticket_exames_procedimentos)
	::text,'$','R$ '),',','|'),'.',','),'|','.') as ticket
from pacientes
inner join ticket on paciente_id = paciente_id1
where email is not null
	and cpf not in (
	select sf.cpf  
	from stg_usuarios su 
inner join stg_funcionarios sf on sf.id = su.id_relativo
where su.id in (119268,121109,121110,121113,121118,121121,121127,123518, --retirando os funcionários amorsaúde da lista
123886,162551,175414,178492,178590,184316,186510,149995324,149995326,149995330,
149995331,149995333,149998556,149999312,150000265,150000266,150000430,150000916,
150003574,150007761,150011688,150013014,150013015,150014695,150015275,150018241,
150018335,150018427,150018429,150018486,150020671,150024965,150025618,150026304,
160028819,160029416,160030289,160030950,160033339,160033362,160034917,160034918,
160035878,160038304,160038315,160038356,160039962,160040036,160042001,160042002,
160043459,160043690,160043943,160045111,160045792,160045795,160047148,160047566,
160047958,160049338,160049340,160049343,160049531,160052055,160052135,160054093,
160054100,160054107,160055826,160061181,160061189,160062661,160065149,160065987,
160067193,160070254,160070255,160072031,160075916,160077331,160078580,160079583,
160083281,160083403,160084850,160085294,160085356,160085783,160086297,160086575,
160086933,160090033,160090436,160090486,160090504,160090755,160090763,160092141,
160092143,160092546,160092547,160092548,160092549,160094957,160094965,160094969,
160095249,160101568,160102076,160103282,160104753,160106893,160109783,160109784,160109786))
--and cpf = '29542346875' --validação por paciente
group by paciente_id1, cpf, email, qtde_atendimento, ticket_exames_procedimentos, nome_paciente, celular
--having qtde_atendimento > 5
)
select distinct * from resultado
	order by ticket desc
	limit 150000 --limitando os 150000 primeiras linhas
	
select tccarm.id_paciente, sum(tccarm.valor_pago)/count(*) 
from tb_consolidacao_contas_a_receber_modelagem tccarm 
where tccarm.cpfpaciente = '00361511574'
group by tccarm.id_paciente





and cpf not in (
	select sf.cpf  
	from stg_usuarios su 
left join stg_funcionarios sf on sf.id = su.id_relativo
where su.id in (119268,121109,121110,121113,121118,121121,121127,123518,
123886,162551,175414,178492,178590,184316,186510,149995324,149995326,149995330,
149995331,149995333,149998556,149999312,150000265,150000266,150000430,150000916,
150003574,150007761,150011688,150013014,150013015,150014695,150015275,150018241,
150018335,150018427,150018429,150018486,150020671,150024965,150025618,150026304,
160028819,160029416,160030289,160030950,160033339,160033362,160034917,160034918,
160035878,160038304,160038315,160038356,160039962,160040036,160042001,160042002,
160043459,160043690,160043943,160045111,160045792,160045795,160047148,160047566,
160047958,160049338,160049340,160049343,160049531,160052055,160052135,160054093,
160054100,160054107,160055826,160061181,160061189,160062661,160065149,160065987,
160067193,160070254,160070255,160072031,160075916,160077331,160078580,160079583,
160083281,160083403,160084850,160085294,160085356,160085783,160086297,160086575,
160086933,160090033,160090436,160090486,160090504,160090755,160090763,160092141,
160092143,160092546,160092547,160092548,160092549,160094957,160094965,160094969,
160095249,160101568,160102076,160103282,160104753,160106893,160109783,160109784,160109786))


select tccarm.cpfpaciente as cpf, sp.email, tccarm.nome_unidade, count(*)
from tb_consolidacao_contas_a_receber_modelagem tccarm 
left join stg_pacientes sp on sp.id = tccarm.id_paciente
left join stg_unidades su on su.id = tccarm.id_unidade
where su.nome_fantasia in ('AmorSaúde Fortaleza Regional V',
'AmorSaúde Mogi das Cruzes',
'AmorSaúde São José',
'AmorSaúde Piracicaba')
and tccarm.data_pagamento between current_date-360 and current_date
and sp.email is not null and sp.email <> ''
--and tccarm.nomegrupo like 'Consulta%'
group by tccarm.cpfpaciente, tccarm.nome_unidade, sp.email

select tccarm.cpfpaciente as cpf, sp.email, tccarm.nome_unidade, count(*)
from tb_consolidacao_contas_a_receber_modelagem tccarm 
left join stg_pacientes sp on sp.id = tccarm.id_paciente
left join stg_unidades su on su.id = tccarm.id_unidade
where tccarm.data_pagamento between current_date-360 and current_date
and sp.email is not null and sp.email <> ''
--and tccarm.nomegrupo like 'Consulta%'
and tccarm.cpfpaciente = '10681638877'
group by tccarm.cpfpaciente, tccarm.nome_unidade, sp.email
