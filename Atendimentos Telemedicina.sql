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
	U."descricao" ,
	sa."descricao" 
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
LEFT JOIN STATUS_AGENDAMENTOS sa ON sa."id" = A."status_agendamento_id"
WHERE
	T.DATA_ATENDIMENTO BETWEEN TO_TIMESTAMP('2023-11-01 00:00:00' , 'yyyy-MM-dd HH24:mi:ss') AND TO_TIMESTAMP('2023-12-04 00:00:00' , 'yyyy-MM-dd HH24:mi:ss')
AND A."clinica_id" = 183