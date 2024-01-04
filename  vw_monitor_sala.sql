SELECT vms."data", vms.CREATE_AT, count(*) 
FROM AMEI_APP_PROD.VW_MONITOR_SALAS vms
GROUP BY vms."data", vms.CREATE_AT
--WHERE vms.PROFISSIONAL LIKE 'Alice%'

--creat_at momento que a sala foi gerada
--create_at -> a sala é gerada 1 hora antes do horário de agendamento (faltando 5 minutos, é enviada ao paciente)
sala
SELECT TRUNC(vms.CREATE_AT), count(*) 
FROM AMEI_APP_PROD.VW_MONITOR_SALAS vms
GROUP BY vms.CREATE_AT
ORDER BY vms.CREATE_AT asc
--WHERE vms.PROFISSIONAL LIKE 'Alice%'

--para validação
SELECT * FROM AMEI_APP_PROD.VW_MONITOR_SALAS vms
WHERE vms.PROFISSIONAL = 'Larissy'
AND vms.PACIENTE LIKE 'Robson%'


--modelagem antiga. A nova view de sala foi alterado a pedido do Lucas realizado pelo Felipe
SELECT AGENDAMENTOS."id", "status_agendamento_id" status, STATUS_AGENDAMENTOS."descricao", "data", "hora_inicio", "hora_termino",
       PROFISSIONAIS."nome" PROFISSIONAL, PACIENTES."nome" PACIENTE, PACIENTES."data_nascimento", PACIENTES."email", LINK, LEMBRETE_15_MIN, 
       LEMBRETE_24_H, LEMBRETE_1_HORA, LINK_EXPIRADO, AGENDAMENTOS.CREATE_AT, AUTORIZACAO, VALOR_CREDITADO 
FROM AMEI_APP_PROD.AGENDAMENTOS
INNER JOIN AMEI_APP_PROD.PROFISSIONAIS ON AGENDAMENTOS."profissional_id" = PROFISSIONAIS."id"
INNER JOIN AMEI_APP_PROD.PACIENTES ON AGENDAMENTOS."paciente_id" = PACIENTES."id"
INNER JOIN AMEI_APP_PROD.STATUS_AGENDAMENTOS ON "status_agendamento_id" = STATUS_AGENDAMENTOS."id"
LEFT JOIN AMEI_APP_PROD.TELECONSULTA ON AGENDAMENTO_ID = AGENDAMENTOS."id" 
LEFT JOIN AMEI_APP_PROD.LANCAMENTOS_FINANCEIROS ON LANCAMENTOS_FINANCEIROS.FK_AGENDAMENTO = AGENDAMENTOS."id"
--WHERE TRUNC("data") >= TRUNC(SYSDATE - 1) 
--WHERE AND "status_agendamento_id" <> 20
WHERE 1 = 1
AND "data" BETWEEN SYSDATE -60 AND SYSDATE
AND "status_agendamento_id" <> 20
ORDER BY "data", "hora_inicio"
--FETCH FIRST 10 ROWS ONLY