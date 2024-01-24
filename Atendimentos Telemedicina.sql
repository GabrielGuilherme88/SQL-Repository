SELECT
	DISTINCT B."nome" || ' ' || B."sobrenome" AS NOME_PACIENTE,
	B."cpf",
	B."email",
	B."telefone",
	B."cep",
	B."endereco",
	B."numero",
	B."bairro",
	b."bairro",
	B."complemento",
	B."cidade",
	B."estado",
	C."valor" AS VALOR_PROCEDIMENTO,
	A."valor_total" AS VALOR_PAGO,
	F.VALOR_CUSTO AS VALOR_REPASSE,
	P."nome" || ' ' || P."sobrenome" AS NOME_PROF,
	TO_CHAR(t.DATA_ATENDIMENTO, 'YYYY-MM-DD') AS DATA_ATENDIMENTO,
	CVV.DESCRICAO AS NOME_VOUCHER,
	A."clinica_id" ,
	U."descricao" 
FROM
	AMEI_APP_PROD.AGENDAMENTOS A
LEFT OUTER JOIN PACIENTES B ON
	B."id" = A."paciente_id"
	AND B."ativo" = 1
LEFT OUTER JOIN AGENDAMENTOS_PROCEDIMENTOS C ON
	C."agendamento_id" = A."id"
LEFT OUTER JOIN ATENDIMENTOS T ON
	A."id" = T.FK_AGENDAMENTO
LEFT OUTER JOIN FORNECEDOR_PROCEDIMENTOS F ON
	C.FK_FORNECEDOR_PROCEDIMENTO_REPASSE = F.ID
LEFT OUTER JOIN CAMPANHA_VOUCHER_PROCEDIMENTOS V ON
	C.FK_CAMPANHA_VOUCHER_PROCEDIMENTOS = V.ID
LEFT OUTER JOIN CAMPANHA_VOUCHERS CVV ON
	V.FK_CAMPANHA_VOUCHER = CVV.ID
LEFT JOIN PROFISSIONAIS P ON
	P."id" = A."profissional_id"
LEFT JOIN UNIDADES U ON U."id" = A."clinica_id" 
WHERE
	T.DATA_ATENDIMENTO BETWEEN TO_TIMESTAMP('2023-12-01 00:00:00' , 'yyyy-MM-dd HH24:mi:ss') AND TO_TIMESTAMP('2023-12-04 00:00:00' , 'yyyy-MM-dd HH24:mi:ss')
AND A."clinica_id" = 183
--colocar o statu do agendamento para filtrar todos os atendidos nas próximas




--atendimentos com falha
SELECT
	DISTINCT t.ID AS ATENDIMENTO_ID,
	A."id" AS AGENDAMENTO_ID,
	TO_CHAR(t.DATA_ATENDIMENTO, 'YYYY-MM-DD') AS DATA_ATENDIMENTO,
	B."nome" || ' ' || B."sobrenome" AS NOME_PACIENTE,
	B."cpf",
	'DR. ' || 	P."nome" || ' ' || P."sobrenome" AS PROFISSIONAL,
	CASE
		WHEN T.FLG_FALHA = 0 THEN 'NAO'
		ELSE 'SIM'
	END AS FALHA
FROM
	AMEI_APP_PROD.AGENDAMENTOS A
LEFT JOIN PACIENTES B ON
	B."id" = A."paciente_id"
	AND B."ativo" = 1
LEFT JOIN ATENDIMENTOS T ON
	A."id" = T.FK_AGENDAMENTO
LEFT JOIN PROFISSIONAIS P ON
	P."id" = A."profissional_id"
WHERE
	1 = 1
	AND T.DATA_ATENDIMENTO BETWEEN TO_TIMESTAMP('2023-06-21 00:00:00' , 'yyyy-MM-dd HH24:mi:ss') AND CURRENT_TIMESTAMP
	--AND T.ID = 9674

--atendimentos para emição de notas --enviado ao marcos
SELECT
	DISTINCT 
	B."nome" || ' ' || B."sobrenome" AS NOME_PACIENTE,
	B."cpf",
	B."email",
	B."telefone",
	B."cep",
	B."endereco",
	B."numero",
	B."bairro",
	b."bairro",
	B."complemento",
	B."cidade",
	B."estado",
	C."valor" AS VALOR_PROCEDIMENTO,
	A."valor_total" AS VALOR_PAGO,
	F.VALOR_CUSTO AS VALOR_REPASSE,
	--P."nome" || ' ' || P."sobrenome" AS NOME_PROF,
	--TO_CHAR(t.DATA_ATENDIMENTO, 'YYYY-MM-DD') AS DATA_ATENDIMENTO,
	CVV.DESCRICAO AS NOME_VOUCHER,
	A."clinica_id" ,
	U."descricao" ,
	sa."descricao"
FROM
	AMEI_APP_PROD.AGENDAMENTOS A
LEFT OUTER JOIN PACIENTES B ON
	B."id" = A."paciente_id"
	AND B."ativo" = 1
LEFT OUTER JOIN AGENDAMENTOS_PROCEDIMENTOS C ON	C."agendamento_id" = A."id"
LEFT JOIN AMEI_APP_PROD.PROCEDIMENTOS p2 ON p2."id" = c."procedimento_id"
LEFT OUTER JOIN ATENDIMENTOS T ON A."id" = T.FK_AGENDAMENTO
LEFT OUTER JOIN FORNECEDOR_PROCEDIMENTOS F ON C.FK_FORNECEDOR_PROCEDIMENTO_REPASSE = F.ID
LEFT OUTER JOIN CAMPANHA_VOUCHER_PROCEDIMENTOS V ON	C.FK_CAMPANHA_VOUCHER_PROCEDIMENTOS = V.ID
LEFT OUTER JOIN CAMPANHA_VOUCHERS CVV ON V.FK_CAMPANHA_VOUCHER = CVV.ID
LEFT JOIN PROFISSIONAIS P ON P."id" = A."profissional_id"
LEFT JOIN UNIDADES U ON U."id" = A."clinica_id" 
LEFT JOIN STATUS_AGENDAMENTOS sa ON sa."id" = A."status_agendamento_id"
--LEFT JOIN AMEI_APP_PROD.CANAIS c2 ON c2."id" = A."canal_id" 
WHERE 1 = 1
--AND	a."data" BETWEEN TO_DATE('2024-01-02', 'yyyy-mm-dd') AND TO_DATE('2024-01-07', 'yyyy-mm-dd')
--AND A."clinica_id" = 183
--AND sa."id" IN (4, 5, 6, 7, 10, 11, 12, 13, 14, 15, 24, 40)
AND a."id" = 99306


--modelagem de agendamentos para criar os dados para cruzar com o crm
SELECT
	DISTINCT 
	B."nome" || ' ' || B."sobrenome" AS NOME_PACIENTE,
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
	FROM AMEI_APP_PROD.AGENDAMENTOS A
LEFT OUTER JOIN PACIENTES B ON	B."id" = A."paciente_id"
	AND B."ativo" = 1
LEFT OUTER JOIN AGENDAMENTOS_PROCEDIMENTOS C ON	C."agendamento_id" = A."id"
LEFT JOIN AMEI_APP_PROD.PROCEDIMENTOS p2 ON p2."id" = c."procedimento_id"
LEFT OUTER JOIN ATENDIMENTOS T ON A."id" = T.FK_AGENDAMENTO
LEFT OUTER JOIN FORNECEDOR_PROCEDIMENTOS F ON C.FK_FORNECEDOR_PROCEDIMENTO_REPASSE = F.ID
LEFT OUTER JOIN CAMPANHA_VOUCHER_PROCEDIMENTOS V ON	C.FK_CAMPANHA_VOUCHER_PROCEDIMENTOS = V.ID
LEFT OUTER JOIN CAMPANHA_VOUCHERS CVV ON V.FK_CAMPANHA_VOUCHER = CVV.ID
LEFT JOIN PROFISSIONAIS P ON P."id" = A."profissional_id"
LEFT JOIN UNIDADES U ON U."id" = A."clinica_id" 
LEFT JOIN STATUS_AGENDAMENTOS sa ON sa."id" = A."status_agendamento_id"
LEFT JOIN AMEI_APP_PROD.CANAIS c2 ON c2."id" = A."canal_id" 
WHERE 1 = 1
AND	a."data" BETWEEN TO_DATE('2024-01-02', 'yyyy-mm-dd') AND TO_DATE('2024-01-07', 'yyyy-mm-dd')
--AND A."clinica_id" = 183
--AND sa."id" IN (4, 5, 6, 7, 10, 11, 12, 13, 14, 15, 24, 40)
--AND a."id" = 99306
ORDER BY B."cpf"
