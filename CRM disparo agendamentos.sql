--
with feegow as (
select a.cpf, 
a.email, 
case when a.nm_canal = 'Clínica' THEN 'Agendamento feito na clinica' END AS "Canal 1",
	CASE when a.nm_canal = 'Portal do Paciente' THEN 'Agendamento Portal do Paciente' END AS "Canal 2",
	CASE WHEN a.nm_canal = 'Autoatedimento' THEN 'Agendamento feito no Autoatedimento' END AS "Canal 3",
	CASE WHEN a.nm_canal = 'App Cartão de Todos' THEN 'Agendamento App Cartão de Todos' END AS "Canal 4",
	CASE WHEN a.nm_canal = 'WhatsApp (bot)' THEN 'Agendamento WhatsApp (bot)' END AS "Canal 5",
	CASE WHEN a.nm_canal = 'Call Center Nacional' THEN 'Agendamento Call Center Nacional' END AS "Canal 6",
	CASE WHEN a.nm_canal = 'Site AmorSaúde' THEN 'Agendamento Site Cartão de Todos' END AS "Canal 7",
	'feegow' as fonte_dados
from pdgt_amorsaude_operacoes.fl_agendamentos a
where a.dt_agendamento between date('2024-01-02') AND date('2024-01-07')
and cpf is not null
),
--amei
amei as (
SELECT
	B."cpf",
	B."email",
	CASE WHEN c2."nome" = 'Clínica' THEN 'Agendamento feito na clinica' END AS "Canal 1",
	CASE WHEN c2."nome" = 'Portal do Paciente' THEN 'Agendamento Portal do Paciente' END AS "Canal 2",
	CASE WHEN c2."nome" = 'Autoatedimento' THEN 'Agendamento feito no Autoatedimento' END AS "Canal 3",
	CASE WHEN c2."nome" = 'App Cartão de Todos' THEN 'Agendamento App Cartão de Todos' END AS "Canal 4",
	CASE WHEN c2."nome" = 'WhatsApp (bot)' THEN 'Agendamento WhatsApp (bot)' END AS "Canal 5",
	CASE WHEN c2."nome" = 'Call Center Nacional' THEN 'Agendamento Call Center Nacional' END AS "Canal 6",
	CASE WHEN c2."nome" = 'Site Cartão de Todos' THEN 'Agendamento Site Cartão de Todos' END AS "Canal 7",
	'Amei!' as fonte_dados
	FROM todos_data_lake_trusted_amei.AGENDAMENTOS A
LEFT JOIN todos_data_lake_trusted_amei.PACIENTES B ON	B."id" = A."paciente_id" AND B."ativo" = 1
LEFT JOIN todos_data_lake_trusted_amei.AGENDAMENTOS_PROCEDIMENTOS C ON	C."agendamento_id" = A."id"
LEFT JOIN todos_data_lake_trusted_amei.PROCEDIMENTOS p2 ON p2."id" = c."procedimento_id"
LEFT JOIN todos_data_lake_trusted_amei.ATENDIMENTOS T ON A."id" = T.FK_AGENDAMENTO
LEFT JOIN todos_data_lake_trusted_amei.FORNECEDOR_PROCEDIMENTOS F ON C.FK_FORNECEDOR_PROCEDIMENTO_REPASSE = F.ID
LEFT JOIN todos_data_lake_trusted_amei.CAMPANHA_VOUCHER_PROCEDIMENTOS V ON	C.FK_CAMPANHA_VOUCHER_PROCEDIMENTOS = V.ID
LEFT JOIN todos_data_lake_trusted_amei.CAMPANHA_VOUCHERS CVV ON V.FK_CAMPANHA_VOUCHER = CVV.ID
LEFT JOIN todos_data_lake_trusted_amei.PROFISSIONAIS P ON P."id" = A."profissional_id"
LEFT JOIN todos_data_lake_trusted_amei.UNIDADES U ON U."id" = A."clinica_id" 
LEFT JOIN todos_data_lake_trusted_amei.STATUS_AGENDAMENTOS sa ON sa."id" = A."status_agendamento_id"
LEFT JOIN todos_data_lake_trusted_amei.CANAIS c2 ON c2."id" = A."canal_id" 
WHERE 1 = 1
AND	a."data" BETWEEN date('2024-01-02') AND date('2024-01-07')
--AND A."clinica_id" = 183
--AND sa."id" IN (4, 5, 6, 7, 10, 11, 12, 13, 14, 15, 24, 40) --status de atendimento
--AND a."id" = 99306
ORDER BY B."cpf")
select * from feegow
union all
select * from amei



select tccarhn.nome_paciente as CLIENTE, tccarhn.nome_procedimento, tccarhn.datapagamento 
from pdgt_amorsaude_financeiro.fl_contas_a_receber tccarhn
where 1=1
and tccarhn.nome_procedimento like 'Consult%'
and tccarhn.nome_unidade = 'AmorSaúde Uberlândia'