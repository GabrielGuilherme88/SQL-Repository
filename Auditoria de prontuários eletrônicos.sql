SELECT
  ag.data AS Agendamentos_data,
  ur.descricao AS Regioes__descricao,
  u.nome_fantasia ,
  pa.id,
  pa.nome_paciente,
  pa.cpf,
  p.nome_procedimento,
  count(distinct ag.id) AS qtde
from todos_data_lake_trusted_feegow.dc_pdf_assinados pdf
  LEFT JOIN todos_data_lake_trusted_feegow.atendimentos a ON pdf.documento_id = a.id
  LEFT JOIN todos_data_lake_trusted_feegow.agendamento_procedimentos ap ON a.agendamento_id = ap.agendamento_id
  LEFT JOIN todos_data_lake_trusted_feegow.agendamentos ag ON ap.agendamento_id = ag.id
  LEFT JOIN todos_data_lake_trusted_feegow.agendamento_status ass ON ag.status_id = ass.id
  LEFT JOIN todos_data_lake_trusted_feegow.unidades u ON a.unidade_id = u.id
  LEFT JOIN todos_data_lake_trusted_feegow.unidades_regioes ur ON u.regiao_id = ur.id
  LEFT JOIN todos_data_lake_trusted_feegow.procedimentos p ON ap.procedimento_id = p.id
  LEFT JOIN todos_data_lake_trusted_feegow.pacientes pa ON ag.paciente_id = pa.id
WHERE
  (
    pdf.tipo = 'ATENDIMENTO'
  )
    AND (
    (
      ass.nome_status = 'Em espera pós consulta'
    )
       OR (
      ass.nome_status = 'Em espera pré consulta'
    )
    OR (
      ass.nome_status = 'Em espera'
    )
    OR (
      ass.nome_status = 'Em atendimento pós consulta'
    )
    OR (
      ass.nome_status = 'Em atendimento pré consulta'
    )
    OR (
      ass.nome_status = 'Em atendimento'
    )
    OR (
      ass.nome_status = 'Chamando pós consulta'
    )
    OR (
      ass.nome_status = 'Chamando pré consulta'
    )
    OR (
      ass.nome_status = 'Chamando'
    )
    OR (
      ass.nome_status = 'Atendido'
    )
    OR (
      ass.nome_status = 'Aguardando pós Consulta'
    )
    OR (
      ass.nome_status = 'Aguardando pré-consulta'
    )
    OR (
      ass.nome_status = 'Aguardando'
    )
    or 
      ass.nome_status = 'Aguardando pagamento'
  )
  AND (
    (p.tipo_procedimento_id = 2)
    OR (p.tipo_procedimento_id = 9)
  )
 and ag."data" between date('2023-12-01') and date('2023-12-31') --filtrando os último meses
GROUP BY
  ag.data,
  ur.descricao,
  u.nome_fantasia,
  pa.id,
  pa.nome_paciente,
  pa.cpf,
  p.nome_procedimento
ORDER BY
  ag.data ASC,
  ur.descricao ASC,
  u.nome_fantasia ASC,
  pa.id ASC,
  pa.nome_paciente ASC,
  pa.cpf ASC,
  p.nome_procedimento asc
  
  