SELECT lf.VALOR_TOTAL, fl.FORMA_LIQUIDACAO, lf.DESCRICAO 
FROM LANCAMENTOS_FINANCEIROS lf
LEFT JOIN CAIXA_SALDOS cs ON cs.id = lf.FK_CAIXA_SALDOS 
LEFT JOIN CLASSIFICACAO_FINANCEIRA cf ON cf.ID = lf.FK_CLASSIFICACAO_FINANCEIRA
LEFT JOIN CATEGORIA_FINANCEIRA cf2 ON cf2.ID = cf.FK_CATEGORIA_FINANCEIRA 
LEFT JOIN FORMA_LIQUIDACAO fl ON fl.ID = lf.FK_FORMA_LIQUIDACAO 
LEFT JOIN LANCAMENTOS_FINANC_WEBHOOK lfw ON lfw.FK_LANCAMENTO_FINANCEIRO = lf.ID 
WHERE rownum <= 1000

SELECT * FROM CLASSIFICACAO_FINANCEIRA cf
where rownum <= 1000

SELECT * FROM CATEGORIA_FINANCEIRA cf
where rownum <= 1000

SELECT * FROM LANCAMENTOS_FINANC_WEBHOOK lfw 
where rownum <= 1000

SELECT * FROM LANCAMENTOS_FINANCEIROS vlf
LEFT JOIN LANCAMENTOS_FINANC_WEBHOOK lfw ON lfw.FK_LANCAMENTO_FINANCEIRO = vlf.ID-- porque os lançamentos financeiros onde tem o recebimento mais todos estão em branco
where rownum <= 1000
--AND vlf.VALOR = 0

SELECT * FROM ORIGEM o
where rownum <= 1000

SELECT * FROM CAIXA_SALDOS cs
where rownum <= 1000

SELECT * FROM RECEBIMENTOS r 
WHERE rownum <= 1000

SELECT 
      *
FROM  RECEBIMENTOS_ITENS A
INNER JOIN CLASSIFICACAO_FINANCEIRA C ON C.ID = A.FK_CLASSIFICACAO_FINANCEIRA AND C.FLG_ATIVO = 1
INNER JOIN RECEBIMENTOS r ON r.ID = a.FK_RECEBIMENTO 
WHERE  A.FLG_ATIVO = 1;
 
 
 SELECT LANCAMENTOS_FINANCEIROS.ID, CAIXA_SALDOS.DATA, TIPO_OPERACAO, FORMA_LIQUIDACAO.ID ID_FORMA_LIQUIDACAO, FORMA_LIQUIDACAO, 
       USUARIOS."email" CRIADO_POR, 
       LANCAMENTOS_FINANCEIROS.VALOR, HASH, CONTA_CORRENTES.ID ID_CONTA_CORRENTE, CONTA_CORRENTES.NOME CONTA_CORRENTE, TIPO_CONTA_CORRENTE
FROM LANCAMENTOS_FINANCEIROS
INNER JOIN CAIXA_SALDOS ON FK_CAIXA_SALDOS = CAIXA_SALDOS.ID
INNER JOIN CLASSIFICACAO_FINANCEIRA ON FK_CLASSIFICACAO_FINANCEIRA = CLASSIFICACAO_FINANCEIRA.ID
INNER JOIN CATEGORIA_FINANCEIRA ON FK_CATEGORIA_FINANCEIRA = CATEGORIA_FINANCEIRA.ID
INNER JOIN TIPO_OPERACAO ON FK_TIPO_OPERACAO = TIPO_OPERACAO.ID
INNER JOIN FORMA_LIQUIDACAO ON  FK_FORMA_LIQUIDACAO = FORMA_LIQUIDACAO.ID
INNER JOIN USUARIOS ON LANCAMENTOS_FINANCEIROS.CREATE_BY = USUARIOS."id"
INNER JOIN CONTA_CORRENTES ON CAIXA_SALDOS.FK_CONTA_CORRENTE = CONTA_CORRENTES.ID
INNER JOIN TIPO_CONTA_CORRENTE ON FK_TIPO_CONTA_CORRENTE = TIPO_CONTA_CORRENTE.ID
WHERE LANCAMENTOS_FINANCEIROS.FLG_ATIVO = 1;

SELECT B.DATA_VENCIMENTO  AS DATA_COMPETENCIA,
        D."id" ID_UNIDADE,
       Cast(B.VALOR as Float(126)) AS RECEITA_BRUTA,
       Cast(0.00 as Float(126)) AS ROYALTIES,
      c."id" AS ID_AGENDAMENTO, A.ORIGEM_ID,  
       A.CREATE_AT, A.UPDATE_AT           
FROM   RECEBIMENTOS A
INNER  JOIN RECEBIMENTOS_PARCELAS B ON B.FK_RECEBIMENTO = A.ID AND B.FLG_ATIVO = 1
LEFT   OUTER JOIN AGENDAMENTOS C ON C."id" = A.ORIGEM_ID AND A.ORIGEM = 'A' --id agendamento não é igual a origem_id
LEFT   OUTER JOIN UNIDADES D ON D."id" = C."clinica_id"
LEFT   OUTER JOIN REGIOES_X_UNIDADES_CLINICAS E ON E."uNIDADESId" = D."id"
LEFT   OUTER JOIN REGIOES F ON F."id" = E."rEGIOESId"
LEFT   OUTER JOIN AGENDAMENTOS_PROCEDIMENTOS G ON G."agendamento_id" = C."id"
WHERE  A.FLG_ATIVO = 1;