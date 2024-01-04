--Querys para testar um dashbaord de qualidade de dados
tb_consolidacao_receita_bruta_hist_final

--tb_consolidacao_receita_bruta_hist_final
select "data"  as data, count(*) as qtde from tb_consolidacao_receita_bruta_hist_final
where data between current_date  -7 and current_date -1
group by data

select * from tb_consolidacao_receita_bruta_hist_final a
where a."data"  between '2023-02-10' and '2023-02-16'
order by "data" desc


--tb_consolidacao_agendamentos_hist
select datadoatendimento as data, count(*) as qtde from tb_consolidacao_agendamentos_hist
where datadoatendimento between current_date  -7 and current_date -1
group by data

--stg_agendamentos_hist
select "data" as data, count(*) as qtde from stg_agendamentos_hist
where data between current_date  -7 and current_date -1
group by data

--stg_propostas 
select dataproposta  as data, count(*) as qtde from stg_propostas
where data between current_date  -7 and current_date -1
group by data

--stg_pacientes_prescricoes
select "data"  as data, count(*) as qtde from stg_pacientes_prescricoes
where data between current_date  -7 and current_date -1
group by data

--stg_atendimentos_hist
select "data"  as data, count(*) as qtde from stg_atendimentos_hist
where data between current_date  -7 and current_date -1
group by data

--stg_propostas_hist
select dataproposta  as data, count(*) as qtde from stg_propostas_hist
where data between current_date  -7 and current_date -1
group by data

--tb_consolidacao_receita_bruta_hist
select datapagamento as data, count(*) as qtde from tb_consolidacao_receita_bruta_hist
where data between current_date  -7 and current_date -1
group by data

--stg_contas
select data_referencia as data, count(*) as qtde from stg_contas
where data between current_date  -7 and current_date -1
group by data


--tb_consolidacao_contas_a_receber_hist
select "data"  as data, count(*) as qtde from tb_consolidacao_contas_a_receber_hist
where data between current_date  -7 and current_date -1
group by data


--stg_log_marcacoes 
select "data"  as data, count(*) as qtde from stg_log_marcacoes
where data between current_date  -7 and current_date -1
group by data
------------------------------------------------------------------------------------







--Verificação da volumetria de Contas
select c.data_referencia, count(c.id) from stg_contas c
where c.data_referencia between current_date -7 and current_date -1
group by c.data_referencia 
order by c.data_referencia desc

select * from stg_conta_itens sci 
limit 1

--Gera uma query automatizada que busca a quantidade de linha de todas as tabelas
select ' select   '''|| tablename  ||''', count(*) from ' || tablename ||' 
union' from pg_tables where schemaname='public';
--    
    
--Teste  
select ' select '' dhup  '''|| tablename  ||''', count(*) from ' || tablename ||' 
union' from pg_tables where schemaname='public'
' where dhup between current_date -7 and current_date -1'




 
  select  'stg_pacientes_relativos', count(*) from stg_pacientes_relativos 
union
 select  'stg_labs_exames', count(*) from stg_labs_exames 
union
 select  'stg_tabelas_particulares', count(*) from stg_tabelas_particulares 
union
 select  'stg_agendamento_matricula_status', count(*) from stg_agendamento_matricula_status 
union
 select  'stg_equipamentos', count(*) from stg_equipamentos 
union
 select  'stg_funcionario_enderecos', count(*) from stg_funcionario_enderecos 
union
 select  'stg_paciente_convenio', count(*) from stg_paciente_convenio 
union
 select  'stg_transacao_cartao', count(*) from stg_transacao_cartao 
union
 select  'stg_agenda_bloqueios', count(*) from stg_agenda_bloqueios 
union
 select  'stg_atendimento_online', count(*) from stg_atendimento_online 
union
 select  'stg_central', count(*) from stg_central 
union
 select  'stg_procedimentos_tabelas_precos_unidades', count(*) from stg_procedimentos_tabelas_precos_unidades 
union
 select  'stg_repasses', count(*) from stg_repasses 
union
 select  'stg_splits', count(*) from stg_splits 
union
 select  'stg_pagamento_item_associacao', count(*) from stg_pagamento_item_associacao 
union
 select  'stg_paciente_endereco', count(*) from stg_paciente_endereco 
union
 select  'stg_agendamento_procedimentos', count(*) from stg_agendamento_procedimentos 
union
 select  'stg_profissional_enderecos', count(*) from stg_profissional_enderecos 
union
 select  'stg_profissionais', count(*) from stg_profissionais 
union
 select  'stg_contas', count(*) from stg_contas 
union
 select  'stg_tiss_guia_consulta', count(*) from stg_tiss_guia_consulta 
union
 select  'stg_fornecedores', count(*) from stg_fornecedores 
union
 select  'stg_locais', count(*) from stg_locais 
union
 select  'stg_formularios_preenchidos', count(*) from stg_formularios_preenchidos 
union
 select  'stg_pacientes', count(*) from stg_pacientes 
union
 select  'stg_atendimentos_procedimentos', count(*) from stg_atendimentos_procedimentos 
union
 select  'stg_atendimentos', count(*) from stg_atendimentos 
union
 select  'stg_propostas', count(*) from stg_propostas 
union
 select  'stg_agendamentos', count(*) from stg_agendamentos 
union
 select  'stg_pagamento_associacao', count(*) from stg_pagamento_associacao 
union
 select  'stg_unidades', count(*) from stg_unidades 
union
 select  'stg_convenios_procedimentos_valores', count(*) from stg_convenios_procedimentos_valores 
union
 select  'stg_dc_pdf_assinados', count(*) from stg_dc_pdf_assinados 
union
 select  'stg_conta_item_tipos', count(*) from stg_conta_item_tipos 
union
 select  'stg_split_recebedores', count(*) from stg_split_recebedores 
union
 select  'stg_tiss_procedimentos_sadt', count(*) from stg_tiss_procedimentos_sadt 
union
 select  'stg_form_9752', count(*) from stg_form_9752 
union
 select  'stg_agendamentos_hist', count(*) from stg_agendamentos_hist 
union
 select  'tb_consolidacao_contas_a_pagar', count(*) from tb_consolidacao_contas_a_pagar 
union
 select  'stg_formularios', count(*) from stg_formularios 
union
 select  'stg_agenda_ocupacoes', count(*) from stg_agenda_ocupacoes 
union
 select  'stg_especialidades', count(*) from stg_especialidades 
union
 select  'stg_estados', count(*) from stg_estados 
union
 select  'stg_estoque_requisicao_status', count(*) from stg_estoque_requisicao_status 
union
 select  'stg_nfse_status', count(*) from stg_nfse_status 
union
 select  'stg_formularios_tipos', count(*) from stg_formularios_tipos 
union
 select  'stg_bandeiras_cartao', count(*) from stg_bandeiras_cartao 
union
 select  'stg_motivo_devolucao', count(*) from stg_motivo_devolucao 
union
 select  'stg_motivo_status', count(*) from stg_motivo_status 
union
 select  'stg_cid10', count(*) from stg_cid10 
union
 select  'stg_conselhos_profissionais', count(*) from stg_conselhos_profissionais 
union
 select  'stg_conta_associacoes', count(*) from stg_conta_associacoes 
union
 select  'stg_cor_pele', count(*) from stg_cor_pele 
union
 select  'stg_estadocivil', count(*) from stg_estadocivil 
union
 select  'stg_boletos_status', count(*) from stg_boletos_status 
union
 select  'stg_grupo_unidade', count(*) from stg_grupo_unidade 
union
 select  'stg_produtos_localizacoes', count(*) from stg_produtos_localizacoes 
union
 select  'stg_produtos_unidade_medida', count(*) from stg_produtos_unidade_medida 
union
 select  'stg_pacientes_prioridades', count(*) from stg_pacientes_prioridades 
union
 select  'stg_produtos_categorias', count(*) from stg_produtos_categorias 
union
 select  'stg_produtos_do_kit', count(*) from stg_produtos_do_kit 
union
 select  'stg_produtos_fabricantes', count(*) from stg_produtos_fabricantes 
union
 select  'stg_tipo_conta_corrente', count(*) from stg_tipo_conta_corrente 
union
 select  'stg_tipo_prestador_servico', count(*) from stg_tipo_prestador_servico 
union
 select  'stg_tiss_tecnica', count(*) from stg_tiss_tecnica 
union
 select  'stg_propostas_status', count(*) from stg_propostas_status 
union
 select  'stg_regimes_tributarios', count(*) from stg_regimes_tributarios 
union
 select  'stg_sexo', count(*) from stg_sexo 
union
 select  'stg_tabelas_completas', count(*) from stg_tabelas_completas 
union
 select  'stg_parentesco', count(*) from stg_parentesco 
union
 select  'stg_voucher_motivos', count(*) from stg_voucher_motivos 
union
 select  'stg_voucher_agendamento', count(*) from stg_voucher_agendamento 
union
 select  'stg_status_unidade', count(*) from stg_status_unidade 
union
 select  'stg_agenda_ocupacoes_homolog', count(*) from stg_agenda_ocupacoes_homolog 
union
 select  'stg_boletos_emitidos', count(*) from stg_boletos_emitidos 
union
 select  'stg_invoice_rateio', count(*) from stg_invoice_rateio 
union
 select  'stg_auditoria_eventos', count(*) from stg_auditoria_eventos 
union
 select  'stg_auditoria_status', count(*) from stg_auditoria_status 
union
 select  'stg_estoque_requisicao_produtos', count(*) from stg_estoque_requisicao_produtos 
union
 select  'stg_cartao_credito_recibo', count(*) from stg_cartao_credito_recibo 
union
 select  'origem_paciente', count(*) from origem_paciente 
union
 select  'destino_paciente', count(*) from destino_paciente 
union
 select  'stg_tabelas_particulares_unidades', count(*) from stg_tabelas_particulares_unidades 
union
 select  'stg_origens', count(*) from stg_origens 
union
 select  'stg_feriados', count(*) from stg_feriados 
union
 select  'stg_acoes_comerciais', count(*) from stg_acoes_comerciais 
union
 select  'stg_planodecontas_despesas', count(*) from stg_planodecontas_despesas 
union
 select  'stg_labs', count(*) from stg_labs 
union
 select  'stg_agendamento_canais', count(*) from stg_agendamento_canais 
union
 select  'stg_metas_acoes_comerciais', count(*) from stg_metas_acoes_comerciais 
union
 select  'tb_teste', count(*) from tb_teste 
union
 select  'tb_teste2', count(*) from tb_teste2 
union
 select  'stg_ao_usuarios', count(*) from stg_ao_usuarios 
union
 select  'tb_consolidacao_agendamentos', count(*) from tb_consolidacao_agendamentos 
union
 select  'tb_consolidacao_itens_orcados', count(*) from tb_consolidacao_itens_orcados 
union
 select  'tb_consolidacao_faturamento_exames', count(*) from tb_consolidacao_faturamento_exames 
union
 select  'tb_consolidacao_exame_procedimento', count(*) from tb_consolidacao_exame_procedimento 
union
 select  'stg_formas_recebimentos', count(*) from stg_formas_recebimentos 
union
 select  'qtd_temp', count(*) from qtd_temp 
union
 select  'bck_tb_consolidacao_contas_a_receber_hist', count(*) from bck_tb_consolidacao_contas_a_receber_hist 
union
 select  'stg_procedimentos_grupos', count(*) from stg_procedimentos_grupos 
union
 select  'stg_tiss_lotes', count(*) from stg_tiss_lotes 
union
 select  'stg_periodo', count(*) from stg_periodo 
union
 select  'qtd_stg', count(*) from qtd_stg 
union
 select  'stg_royalties_unidade', count(*) from stg_royalties_unidade 
union
 select  'tableteste1', count(*) from tableteste1 
union
 select  'tableteste2', count(*) from tableteste2 
union
 select  'tableteste3', count(*) from tableteste3 
union
 select  'stg_form_9826', count(*) from stg_form_9826 
union
 select  'stg_convenios_unidades', count(*) from stg_convenios_unidades 
union
 select  'stg_agendamento_status', count(*) from stg_agendamento_status 
union
 select  'stg_pacotes', count(*) from stg_pacotes 
union
 select  'stg_voucher', count(*) from stg_voucher 
union
 select  'stg_centro_custo', count(*) from stg_centro_custo 
union
 select  'stg_estoque_lancamentos', count(*) from stg_estoque_lancamentos 
union
 select  'stg_estoque_posicao', count(*) from stg_estoque_posicao 
union
 select  'stg_estoque_requisicao', count(*) from stg_estoque_requisicao 
union
 select  'stg_procedimentos_tipos', count(*) from stg_procedimentos_tipos 
union
 select  'stg_regras_permissoes', count(*) from stg_regras_permissoes 
union
 select  'tb_consolidacao_receita_bruta_hist', count(*) from tb_consolidacao_receita_bruta_hist 
union
 select  'tb_consolidacao_contas_a_receber_hist', count(*) from tb_consolidacao_contas_a_receber_hist 
union
 select  'stg_tiss_guia_sadt', count(*) from stg_tiss_guia_sadt 
union
 select  'stg_agenda_horarios_itens', count(*) from stg_agenda_horarios_itens 
union
 select  'stg_convenios_planos', count(*) from stg_convenios_planos 
union
 select  'stg_agendamentos_homolog', count(*) from stg_agendamentos_homolog 
union
 select  'stg_metas', count(*) from stg_metas 
union
 select  'stg_unidades_regioes', count(*) from stg_unidades_regioes 
union
 select  'stg_produtos', count(*) from stg_produtos 
union
 select  'tb_consolidacao_receita_bruta_hist_bkp', count(*) from tb_consolidacao_receita_bruta_hist_bkp 
union
 select  'tb_consolidacao_receita_bruta_hist_new', count(*) from tb_consolidacao_receita_bruta_hist_new 
union
 select  'stg_formas_pagamento', count(*) from stg_formas_pagamento 
union
 select  'stg_planodecontas_receitas', count(*) from stg_planodecontas_receitas 
union
 select  'stg_recebimentoparcial_fornecedores_unidades', count(*) from stg_recebimentoparcial_fornecedores_unidades 
union
 select  'receitabruta_bi', count(*) from receitabruta_bi 
union
 select  'stg_atendimento_online_hist', count(*) from stg_atendimento_online_hist 
union
 select  'stg_convenios_procedimentos_tabela', count(*) from stg_convenios_procedimentos_tabela 
union
 select  'stg_convenios', count(*) from stg_convenios 
union
 select  'stg_log_marcacoes', count(*) from stg_log_marcacoes 
union
 select  'stg_funcionarios_unidades', count(*) from stg_funcionarios_unidades 
union
 select  'stg_pacotes_itens', count(*) from stg_pacotes_itens 
union
 select  'stg_contas_correntes', count(*) from stg_contas_correntes 
union
 select  'stg_pacientes_pedidos', count(*) from stg_pacientes_pedidos 
union
 select  'stg_pacientes_prescricoes', count(*) from stg_pacientes_prescricoes 
union
 select  'stg_contas_bloqueios', count(*) from stg_contas_bloqueios 
union
 select  'tb_consolidacao_contas_a_receber', count(*) from tb_consolidacao_contas_a_receber 
union
 select  'stg_movimentacao_hist', count(*) from stg_movimentacao_hist 
union
 select  'tb_consolidacao_exame_procedimento_hist', count(*) from tb_consolidacao_exame_procedimento_hist 
union
 select  'stg_itens_proposta_hist', count(*) from stg_itens_proposta_hist 
union
 select  'stg_movimentacao', count(*) from stg_movimentacao 
union
 select  'stg_itens_proposta', count(*) from stg_itens_proposta 
union
 select  'stg_conta_itens', count(*) from stg_conta_itens 
union
 select  'stg_repasses_hist', count(*) from stg_repasses_hist 
union
 select  'stg_contas_hist', count(*) from stg_contas_hist 
union
 select  'stg_conta_itens_hist', count(*) from stg_conta_itens_hist 
union
 select  'stg_atendimentos_hist', count(*) from stg_atendimentos_hist 
union
 select  'tb_consolidacao_agendamentos_hist', count(*) from tb_consolidacao_agendamentos_hist 
union
 select  'tb_consolidacao_receita_bruta_hist_final', count(*) from tb_consolidacao_receita_bruta_hist_final 
union
 select  'stg_procedimentos_tabelas_precos_valores', count(*) from stg_procedimentos_tabelas_precos_valores 
union
 select  'stg_caixas', count(*) from stg_caixas 
union
 select  'stg_funcionarios', count(*) from stg_funcionarios 
union
 select  'stg_grade_fixa', count(*) from stg_grade_fixa 
union
 select  'stg_royalties_contas', count(*) from stg_royalties_contas 
union
 select  'stg_grade_periodo_procedimentos', count(*) from stg_grade_periodo_procedimentos 
union
 select  'stg_pacientes_diagnosticos', count(*) from stg_pacientes_diagnosticos 
union
 select  'stg_pacientes_atestados', count(*) from stg_pacientes_atestados 
union
 select  'stg_convenios_procedimentos_valores_planos', count(*) from stg_convenios_procedimentos_valores_planos 
union
 select  'stg_auditoria_itens', count(*) from stg_auditoria_itens 
union
 select  'stg_procedimentos', count(*) from stg_procedimentos 
union
 select  'stg_procedimentos_tabelas_precos', count(*) from stg_procedimentos_tabelas_precos 
union
 select  'stg_memed_prescricoes', count(*) from stg_memed_prescricoes 
union
 select  'stg_grade_fixa_especialidades', count(*) from stg_grade_fixa_especialidades 
union
 select  'stg_form_9783', count(*) from stg_form_9783 
union
 select  'stg_fechamento_caixa', count(*) from stg_fechamento_caixa 
union
 select  'stg_fila_espera', count(*) from stg_fila_espera 
union
 select  'stg_memed_tokens', count(*) from stg_memed_tokens 
union
 select  'stg_movimentacao_removidos', count(*) from stg_movimentacao_removidos 
union
 select  'stg_devolucoes', count(*) from stg_devolucoes 
union
 select  'stg_devolucoes_itens', count(*) from stg_devolucoes_itens 
union
 select  'stg_propostas_origem', count(*) from stg_propostas_origem 
union
 select  'stg_profissional_externo', count(*) from stg_profissional_externo 
union
 select  'stg_profissional_especialidades', count(*) from stg_profissional_especialidades 
union
 select  'stg_tef_autorizacao', count(*) from stg_tef_autorizacao 
union
 select  'stg_usuarios', count(*) from stg_usuarios 
union
 select  'tb_consolidacao_propostasitens_isalab', count(*) from tb_consolidacao_propostasitens_isalab 
union
 select  'tb_consolidacao_receita_bruta', count(*) from tb_consolidacao_receita_bruta 
union
 select  'stg_profissionais_unidades', count(*) from stg_profissionais_unidades 
union
 select  'stg_grade_periodo_convenios', count(*) from stg_grade_periodo_convenios 
union
 select  'stg_grade_fixa_procedimentos', count(*) from stg_grade_fixa_procedimentos 
union
 select  'stg_nfse_emitidas', count(*) from stg_nfse_emitidas 
union
 select  'stg_labs_exames_procedimentos', count(*) from stg_labs_exames_procedimentos 
union
 select  'stg_usuarios_regras', count(*) from stg_usuarios_regras 
union
 select  'stg_tiss_guia_consulta_hist', count(*) from stg_tiss_guia_consulta_hist 
union
 select  'stg_pacientes_pedidos_hist', count(*) from stg_pacientes_pedidos_hist 
union
 select  'stg_tiss_procedimentos_sadt_hist', count(*) from stg_tiss_procedimentos_sadt_hist 
union
 select  'stg_pacientes_prescricoes_hist', count(*) from stg_pacientes_prescricoes_hist 
union
 select  'stg_fornecedores_unidades', count(*) from stg_fornecedores_unidades 
union
 select  'stg_grade_periodo', count(*) from stg_grade_periodo 
union
 select  'stg_grade_periodo_especialidades', count(*) from stg_grade_periodo_especialidades 
union
 select  'stg_grade_fixa_convenios', count(*) from stg_grade_fixa_convenios 
union
 select  'stg_devolucoes_hist', count(*) from stg_devolucoes_hist 
union
 select  'tb_consolidacao_itens_orcados_hist', count(*) from tb_consolidacao_itens_orcados_hist 
union
 select  'tb_consolidacao_faturamento_exames_hist', count(*) from tb_consolidacao_faturamento_exames_hist 
union
 select  'stg_propostas_hist', count(*) from stg_propostas_hist 
union
 select  'tb_consolidacao_procedimentos_isalab', count(*) from tb_consolidacao_procedimentos_isalab 
union
 select  'tb_consolidacao_propostas_isalab', count(*) from tb_consolidacao_propostas_isalab 
union
 select  'stg_contas_bloqueios_logs', count(*) from stg_contas_bloqueios_logs 
union
 select  'tb_consolidacao_contas_a_pagar_hist', count(*) from tb_consolidacao_contas_a_pagar_hist 
