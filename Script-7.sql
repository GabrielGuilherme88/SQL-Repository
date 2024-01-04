select id_unidade, count(id_agendamento) from (
select
      ag.data as DataDoAtendimento,
      ag.sys_date as DataCriacaoAgdt,
      l.nomelocal as Nome_Local,
      U.id as id_unidade,
      U.nome_fantasia as Nome_Fantasia,
      U.nome_unidade as Nome_Unidade,
      ur.id as id_regional,
      ur.descricao as Descricao_Unidades_Regioes,
      pro.id as id_procedimento,
      pro.nome_procedimento as Nome_Procedimento,
      sprot.id as id_tipoprocedimento,
      sprot.tipoprocedimento as Tipo_procedimento,
      ag.paciente_id as Id_Paciente,
      paci.nome_paciente as Nome_Paciente,
      paci.nascimento as Data_Nascimento,
      ag.profissional_id as id_profissional,
      prof.nome_profissional as Nome_profissionais,
      ag.especialidade_id as id_especialidade,
      esp.nome_especialidade as Nome_especialidade,
      ac.id as id_canal,
      ac.nome_canal as Nome_canal,
      ag.status_id as status_id,
      s.nome_status as Nome_status,
      ag.tabela_particular_id as tabela_id,
      tp.nome_tabela_particular as Nome_tabela_particular,
      ag.usuario_id as id_usuario,
      usu.tipo_usuario as Tipo_usuario,
      l.sys_active as Locais_Ativos,
      U.sys_active as Unidades_Ativas,
      UR.sysactive as Unidades_Regioes_Ativas,
      PRO.sys_active as Procedimentos_Ativos,
      AG.sys_active as Agendamentos_Ativos,
      AC.sys_active as Agendamentos_Canais_Ativos,
      PACI.sys_active as Pacientes_Ativos,
      TP.sys_active as Tabelas_Particulares_Ativas,
      ESP.sys_active as Especialidades_Ativas,
      PROF.sys_active as Profissionais_Ativos,
      fun.id as id_funcionario,
      sx.id as id_sexo,
      ag.id as id_agendamento
from todos_data_lake_trusted_feegow.agendamento_procedimentos ap
      left join todos_data_lake_trusted_feegow.agendamentos ag on ap.agendamento_id = ag.id
      left join todos_data_lake_trusted_feegow.locais l on ap.local_id = l.id
      left join todos_data_lake_trusted_feegow.unidades u on l.unidade_id = u.id
      left join todos_data_lake_trusted_feegow.unidades_regioes ur on u.regiao_id = ur.id
      left join todos_data_lake_trusted_feegow.procedimentos pro on ap.procedimento_id = pro.id
      left join todos_data_lake_trusted_feegow.procedimentos_tipos sprot on pro.tipo_procedimento_id = sprot.id
      left join todos_data_lake_trusted_feegow.agendamento_status s on ag.status_id = s.id
      left join todos_data_lake_trusted_feegow.agendamento_canais ac on ac.id = ag.canal_id
      left join todos_data_lake_trusted_feegow.pacientes paci on ag.paciente_id = paci.id
      left join todos_data_lake_trusted_feegow.sexo sx on paci.sexo = sx.id --não tem
      left join todos_data_lake_trusted_feegow.tabelas_particulares tp on ag.tabela_particular_id = tp.id
      left join todos_data_lake_trusted_feegow.usuarios usu on ag.usuario_id = usu.id -- não tem
      left join todos_data_lake_trusted_feegow.funcionarios fun on usu.id_relativo = fun.id -- mão tem
      left join todos_data_lake_trusted_feegow.profissionais prof on ag.profissional_id = prof.id
      left join todos_data_lake_trusted_feegow.especialidades esp on ag.especialidade_id = esp.id
      left join todos_data_lake_trusted_feegow.convenios conv on ag.convenio_id = conv.id --não tem
where 1 = 1
 and sprot.id in (2,9)
 )
 where 1 = 1
 and DataDoAtendimento between date('2023-11-01') and date('2023-11-26')
 group by id_unidade
 order by id_unidade