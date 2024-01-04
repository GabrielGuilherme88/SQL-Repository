--PROFISSIONAIS
SELECT * FROM AMEI_APP_PROD.PROFISSIONAIS p
where rownum <= 1000
AND p."id" = 1478

SELECT * FROM PROFISSIONAIS_X_ESPECIALIDADES pxe 
where rownum <= 1000

SELECT * FROM ESPECIALIDADES e 
where rownum <= 1000

SELECT * FROM PROF_ESPEC_RQE per 
where rownum <= 1000

SELECT * FROM prof


--PARCEIROS
SELECT * FROM PARCEIROS p
where rownum <= 1000

SELECT * FROM parcei



--FUNCIONARIOS
SELECT * FROM FUNCIONARIOS f 
where rownum <= 1000

--CLIENTES (PACIENTES?)
SELECT * FROM AMEI_APP_PROD.PACIENTES p 
where rownum <= 1000

--GRADES
SELECT * FROM AMEI_APP_PROD.HORARIOS h 
WHERE rownum <= 1000
AND h."profissional_id" = 1528

SELECT * FROM AMEI_APP_PROD.BLOQUEIO_AGENDA ba 
where rownum <= 1000

--parceiros e tabelas de preços
SELECT * FROM AMEI_APP_PROD.PARCEIROS p 
where rownum <= 1000


SELECT * FROM AMEI_APP_PROD.PARCEIROS p 
LEFT JOIN AMEI_APP_PROD.TABELA_PRECOS tp ON tp.PARCEIRO_ID = p.ID 
LEFT JOIN AMEI_APP_PROD.TABELA_PRECO_PROCEDIMENTOS tpp  ON tpp.TABELA_PRECO_ID = tp.ID 
LEFT JOIN AMEI_APP_PROD.TABELA_PRECOS_X_UNIDADES pt ON pt.TABELA_PRECO_ID = tpp.TABELA_PRECO_ID 
LEFT JOIN AMEI_APP_PROD.UNIDADES u ON u."id" = pt.UNIDADE_ID
where rownum <= 1000
AND u.RAZAO_SOCIAL = 'Clinica AmorSaude Parobé LTDA'

SELECT pf.ID, pf.FK_PARCEIRO ID_PARCEIRO, 
         pf.FK_FORNECEDOR ID_FORNECEDOR, f.RAZAO_SOCIAL
FROM AMEI_APP_PROD.PARCEIRO_FORNECEDORES pf
INNER JOIN AMEI_APP_PROD.PARCEIROS p ON pf.FK_PARCEIRO = p.ID 
INNER JOIN AMEI_APP_PROD.FORNECEDORES f ON pf.FK_FORNECEDOR = f.ID
--WHERE pf.FLG_ATIVO = 1


----agendamento
SELECT * FROM AMEI_APP_PROD.AGENDAMENTOS a 
LEFT JOIN AMEI_APP_PROD.PACIENTES p ON p."id" = a."paciente_id" 
LEFT JOIN AMEI_APP_PROD.STATUS_AGENDAMENTOS sa ON sa."id" = a."status_agendamento_id" 
where rownum <= 1000
AND p."cpf" = '37043082854'

SELECT count(*), ID_STATUS_AGENDAMENTO, STATUS_AGENDAMENTO 
FROM AMEI_APP_PROD.VW_AGENDAMENTOS va 
GROUP BY ID_STATUS_AGENDAMENTO, STATUS_AGENDAMENTO


SELECT * FROM amei_app_prod.pacientes_arquivos
where rownum <= 1000
AND cpf = '37043082854'


--antiga modelagem para salvar
-----------------------
--AMEI_APP_PROD.AGENDAMENTOS
select 
distinct 
ag.id,
ag."data",
ROUND(EXTRACT(HOUR FROM TO_TIMESTAMP(ag.hora, 'HH24:MI:SS')) +
	EXTRACT(MINUTE FROM TO_TIMESTAMP(ag.hora, 'HH24:MI:SS')) / 60.0 +
	EXTRACT(SECOND FROM TO_TIMESTAMP(ag.hora, 'HH24:MI:SS')) / 3600.0, 2) 
		as hora_inicio, --transformado em decimal
--ag.hora_termino, --realizar o calculo com o valor da grade do médico calculado la em cima
ag.is_encaixe as encaixe,
ag.is_retorno as retorno,
null as enviar_sms,
ag.valor as valor_total,
null as repeticao,
null as repeticao_periodicidade,
null as repeticao_quantidade,
null as repeticao_data_termino,
523 as clinica_id, --no futuro verificar a questão do id da unidade, fazer um depara
ag.paciente_id,
ag.profissional_id, 
ag.especialidade_id, 
case 
	when ag.status_id = 1 then 2
	when ag.status_id = 3 then 5
	when ag.status_id = 2 then 10
	when ag.status_id = 17 then 8
	when ag.status_id = 11 then 9
	when ag.status_id = 206 then 15
	when ag.status_id = 7 then 16
	when ag.status_id = 6 then 17
	when ag.status_id = 15 then 18	
end as status_agendamento_id, --criar case when para fazer o depara dos status --falta alguns agendamentos
sas.nome_status, --criar case when para fazer o depara do nome dos status
stp.id, --id da parceria cartão de todos
case
	when nome_tabela_particular = 'Cartão de TODOS*' then 'Cartão de TODOS'
	else 'Cartão de TODOS'
end as parceria, --cartão de todos --verificar sobre possíveis alterações
ag.convenio_id,
ag.canal_id, 
null as horario_id,
null as canal_origem_id,
null as canal_confirmacao_id,
ag.dhup as create_at,
ap.procedimento_id
from stg_agendamento_procedimentos ap
left join stg_agendamentos ag on ap.agendamento_id = ag.id
left join stg_tabelas_particulares stp on stp.id = ag.tabela_particular_id
left join stg_agendamento_status sas on sas.id = ag.status_id
left join stg_profissionais sp on sp.id = ag.profissional_id
left join stg_profissional_especialidades spe on spe.profissional_id = sp.id
left join stg_especialidades se on se.id = spe.especialidade_id
left join stg_pacientes p on p.id = ag.paciente_id
left join stg_sexo ss on ss.id = p.sexo
left join stg_agendamento_status ass on ag.status_id = ass.id
left join stg_especialidades es on ag.especialidade_id = es.id
left join stg_procedimentos pro on ap.procedimento_id = pro.id
left join stg_procedimentos_tipos pt on pro.tipo_procedimento_id = pt.id
left join stg_locais l on ap.local_id = l.id
left join stg_unidades u on l.unidade_id = u.id
where 1 = 1
and ag.profissional_id in (508478, 260142) --2 profissionais selecionados
and u.id = 19811 -- unidade Pirassununga
and ag.data between DATE('2023-12-04') and DATE('2030-12-31')

SELECT * FROM AMEI_FEEGOW_MIG.PROFISSIONAIS p 
