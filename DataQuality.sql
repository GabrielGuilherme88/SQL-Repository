--Funcionando no powerBI
with stg_agendamentos as (
select 'stg_agendamento' as Tipo, cast(ag."data" as date), count(*) as Registros, 0 as valortotal, su.id as unidade_id
from stg_agendamentos ag
left join stg_locais sl on sl.id = ag.local_id
left join stg_unidades su on su.id = sl.unidade_id
group by cast(ag."data" as date), su.id),
stg_movimentacao as (
select 'stg_movimentacao' as Tipo, cast(ag."data" as date), count(*) as Registros, 0 as valortotal, ag.unidade_id 
	from stg_movimentacao ag
group by cast(ag."data" as date), ag.unidade_id),
stg_contas as (
select 'stg_contas' as Tipo ,cast(ag.data_referencia as date) as data, count(*) as Registros, 0 as valortotal, ag.unidade_id
	from stg_contas ag
group by cast(ag.data_referencia as date), ag.unidade_id),
stg_propostas as (
select 'stg_propostas' as Tipo, cast(p.dataproposta as date) as data, count(*) as Registros, 0 as valortotal, p.unidadeid as unidade_id
from stg_propostas p
group by cast(p.dataproposta as date),p.unidadeid),
stg_memed_prescricoes as (
select 'stg_memed_prescricoes mp' as Tipo, cast(mp.datahora as date) as data  , count(*) as Registros, 0 as valortotal, sa.unidade_id
from stg_memed_prescricoes mp
left join stg_atendimentos_hist sa on sa.id = mp.atendimentoid 
group by cast(mp.datahora as date), sa.unidade_id),
stg_dc_pdf_assinados as (
select 'stg_dc_pdf_assinados' as Tipo, cast(pa.data_criacao as date) as data, count(*) as Registros, 0 as valortotal, ah.unidade_id 
from stg_dc_pdf_assinados pa
left join stg_atendimentos_hist ah on ah.id = pa.documento_id 
group by cast(pa.data_criacao as date), ah.unidade_id),
stg_pacientes_pedido as (
select 'stg_pacientes_pedidos' as Tipo, cast(pd."data"  as date) as data, count(*) as Registros, 0 as valortotal, sah.unidade_id
from stg_pacientes_pedidos pd
left join stg_atendimentos_hist sah on sah.paciente_id  = pd.paciente_id  
group by cast(pd."data"  as date),sah.unidade_id),
stg_pacientes_prescricoes as (
select 'stg_pacientes_prescricoes' as Tipo, cast(pp."data" as date) as data, count(*) as Registros, 0 as valortotal, sah.unidade_id 
from stg_pacientes_prescricoes pp
left join stg_atendimentos_hist sah on sah.paciente_id = pp.paciente_id
group by cast(pp."data" as date), sah.unidade_id),
stg_agenda_horarios_itens as (
select 'stg_agenda_horarios_itens' as Tipo ,cast(hi."data" as date) as data, count(*) as Registros, 0 as valortotal, hi.unidade_id 
from stg_agenda_horarios_itens hi
group by cast(hi."data" as date), hi.unidade_id),
stg_contas_bloqueios as (
select 'stg_contas_bloqueios' as Tipo, cast(cb."data" as date)as data , count(*) as Registros, 0 as valortotal, cb.unidade_id 
from stg_contas_bloqueios cb
group by cast(cb."data" as date), cb.unidade_id),
stg_atendimentos as (
select 'stg_atendimentos' as Tipo, cast(a."data" as date) as data, count(*) as Registros, 0 as valortotal, a.unidade_id 
from stg_atendimentos a
group by cast(a."data" as date), a.unidade_id),
stg_agendamento_procedimentos as (
select 'stg_agendamento_procedimentos sap' as Tipo, cast(sap.dhup as date) as data, count(*) as Registros, 0 as valortotal, su.id as unidade_id
from stg_agendamento_procedimentos sap 
left join stg_locais sl on sl.id = sap.local_id
left join stg_unidades su on su.id = sl.unidade_id 
group by cast(sap.dhup as date), su.id),
stg_procedimentos as (
select 'stg_procedimentos' as Tipo, cast(sp.dhup as date) as data ,count(*) as Registros, 0 as valortotal, su.id as unidade_id
from stg_procedimentos sp
left join stg_agendamentos_hist sah on sah.procedimento_id = sp.id
left join stg_locais sl on sl.id = sah.local_id 
left join stg_unidades su on su.id = sl.unidade_id 
group by cast(sp.dhup as date), su.id),
tb_consolidacao_agendamentos_hist as (
select 'tb_consolidacao_agendamentos_hist' as Tipo, cast(ahi.datadoatendimento as date) as data, count(*) as Registro, 0 as valortotal, ahi.id_unidade as unidade_id 
from tb_consolidacao_agendamentos_hist ahi
group by cast(ahi.datadoatendimento as date), ahi.id_unidade),
tb_consolidacao_contas_a_receber as (
select 'tb_consolidacao_contas_a_receber_hi' as Tipo, cast(cr.datavencimento  as date) as data, count(*) as Registros, cr.valor_pago as valortotal, cr.id_unidade  as unidade_id
from tb_consolidacao_contas_a_receber_hist_nova cr
group by cast(cr.datavencimento as date), cr.valor_pago, cr.id_unidade), --problema em varchar dentro do contas a receber
tb_consolidacao_receita_bruta_hist_final as (
select 'tb_consolidacao_receita_bruta_hist_final' as Tipo, cast(tcrbhf."data" as date) as data, count(*) as Registros, tcrbhf.total_recebido as valortotal, tcrbhf .id_unidade  as unidade_idc
from tb_consolidacao_receita_bruta_hist_final tcrbhf
group by cast(tcrbhf."data" as date),tcrbhf.total_recebido, tcrbhf .id_unidade),
tb_consolidacao_contas_a_pagar_hist as (
select 'tb_consolidacao_contas_a_pagar_hist' as Tipo, cast(cp."data" as date) as data, count(*) as Registros, cp.valortotal as valortotal, su.id as unidade_id
from tb_consolidacao_contas_a_pagar_hist cp
left join stg_unidades su on su.nome_fantasia = cp.nome_fantasia 
group by cast(cp."data" as date), cp.valortotal, su.id),
stg_boletos_emitidos as (
select 'stg_boletos_emitidos' as Tipo, cast(be.data_hora as date), count(*) as Registros, 0 as valortotal, be.unidade_id 
from stg_boletos_emitidos be
group by cast(be.data_hora as date), be.unidade_id),
stg_grade_fixa as (
select 'stg_grade_fixa' as Tipo, cast(gf.datahora as date), count(*) as Registros, 0 as valortotal, su.id as unidade_id
from stg_grade_fixa gf
left join stg_locais sl on sl.id = gf.localid
left join stg_unidades su on su.id = sl.unidade_id 
group by cast(gf.datahora as date), su.id),
stg_royalties_contas as (
select 'stg_grade_fixa' as Tipo, cast(rc.datareferencia as date), count(*) as Registros, 0 as valortotal, rc.unidadeid as unidade_id
from stg_royalties_contas rc
group by cast(rc.datareferencia as date), rc.unidadeid),
stg_splits as (
select 'stg_splits' as Tipo, cast(s."data" as date), count(*) as Registros, 0 as valortotal, smh.unidade_id
from stg_splits s
left join stg_movimentacao_hist smh on smh.id = s.movimentacao_id 
group by cast(s."data" as date), smh.unidade_id),
stg_conta_itens as (
select 'stg_conta_itens' as Tipo, cast(sci.data_execucao as date) as data, count(*) as Registros, 0 as valortotal, 0 as unidade_id
from stg_conta_itens sci
--left join stg_contas scc on scc.conta_id = sci.id
group by cast(sci.data_execucao as date))
select * from (
select * from stg_conta_itens
union all
select * from stg_contas sc 
union all
select * from stg_splits ss 
union all
select * from stg_propostas
union all
select * from stg_grade_fixa
union all
select * from stg_grade_fixa
union all
select * from stg_boletos_emitidos
union all
select * from stg_procedimentos
union all
select * from stg_agendamento_procedimentos
union all
select * from stg_atendimentos
union all
select * from stg_dc_pdf_assinados
union all
select * from stg_pacientes_pedido
union all
select * from stg_pacientes_prescricoes
union all
select * from stg_agenda_horarios_itens
union all
select * from stg_contas_bloqueios
union all
select * from stg_memed_prescricoes
union all
select * from stg_agendamentos
union all
select * from stg_movimentacao
union all
select * from tb_consolidacao_agendamentos_hist
union all
select * from tb_consolidacao_contas_a_receber
union all
select * from tb_consolidacao_receita_bruta_hist_final
union all
select * from tb_consolidacao_contas_a_pagar_hist
where data between current_date - 90 and current_date)

--
select count(*), cast(t.datavencimento as date) 
from tb_consolidacao_contas_a_receber_hist_nova t
where 1=1
and t.datavencimento between current_date - 90 and current_date
group by t.datavencimento
order by t.datavencimento desc
limit 10


--------------------------------------------------------
--Antigo no power bi
--------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
with stg_agendamentos as (
select 'stg_agendamento' as Tipo, cast(ag."data" as date), count(*) as Registros, 0 as valortotal, su.id as unidade_id
from stg_agendamentos ag
left join stg_locais sl on sl.id = ag.local_id
left join stg_unidades su on su.id = sl.unidade_id
group by cast(ag."data" as date), su.id),
stg_movimentacao as (
select 'stg_movimentacao' as Tipo, cast(ag."data" as date), count(*) as Registros, 0 as valortotal, ag.unidade_id 
	from stg_movimentacao ag
group by cast(ag."data" as date), ag.unidade_id),
stg_contas as (
select 'stg_contas' as Tipo ,cast(ag.data_referencia as date) as data, count(*) as Registros, 0 as valortotal, ag.unidade_id
	from stg_contas ag
group by cast(ag.data_referencia as date), ag.unidade_id),
stg_propostas as (
select 'stg_propostas' as Tipo, cast(p.dataproposta as date) as data, count(*) as Registros, 0 as valortotal, p.unidadeid as unidade_id
from stg_propostas p
group by cast(p.dataproposta as date),p.unidadeid),
stg_memed_prescricoes as (
select 'stg_memed_prescricoes mp' as Tipo, cast(mp.datahora as date) as data  , count(*) as Registros, 0 as valortotal, sa.unidade_id
from stg_memed_prescricoes mp
left join stg_atendimentos_hist sa on sa.id = mp.atendimentoid 
group by cast(mp.datahora as date), sa.unidade_id),
stg_dc_pdf_assinados as (
select 'stg_dc_pdf_assinados' as Tipo, cast(pa.data_criacao as date) as data, count(*) as Registros, 0 as valortotal, ah.unidade_id 
from stg_dc_pdf_assinados pa
left join stg_atendimentos_hist ah on ah.id = pa.documento_id 
group by cast(pa.data_criacao as date), ah.unidade_id),
stg_pacientes_pedido as (
select 'stg_pacientes_pedidos' as Tipo, cast(pd."data"  as date) as data, count(*) as Registros, 0 as valortotal, sah.unidade_id
from stg_pacientes_pedidos pd
left join stg_atendimentos_hist sah on sah.paciente_id  = pd.paciente_id  
group by cast(pd."data"  as date),sah.unidade_id),
stg_pacientes_prescricoes as (
select 'stg_pacientes_prescricoes' as Tipo, cast(pp."data" as date) as data, count(*) as Registros, 0 as valortotal, sah.unidade_id 
from stg_pacientes_prescricoes pp
left join stg_atendimentos_hist sah on sah.paciente_id = pp.paciente_id 
group by cast(pp."data" as date), sah.unidade_id),
stg_agenda_horarios_itens as (
select 'stg_agenda_horarios_itens' as Tipo ,cast(hi."data" as date) as data, count(*) as Registros, 0 as valortotal, hi.unidade_id 
from stg_agenda_horarios_itens hi
group by cast(hi."data" as date), hi.unidade_id),
stg_contas_bloqueios as (
select 'stg_contas_bloqueios' as Tipo, cast(cb."data" as date)as data , count(*) as Registros, 0 as valortotal, cb.unidade_id 
from stg_contas_bloqueios cb
group by cast(cb."data" as date), cb.unidade_id),
stg_atendimentos as (
select 'stg_atendimentos' as Tipo, cast(a."data" as date) as data, count(*) as Registros, 0 as valortotal, a.unidade_id 
from stg_atendimentos a
group by cast(a."data" as date), a.unidade_id),
stg_agendamento_procedimentos as (
select 'stg_agendamento_procedimentos sap' as Tipo, cast(sap.dhup as date) as data, count(*) as Registros, 0 as valortotal, su.id as unidade_id
from stg_agendamento_procedimentos sap 
left join stg_locais sl on sl.id = sap.local_id
left join stg_unidades su on su.id = sl.unidade_id 
group by cast(sap.dhup as date), su.id),
stg_procedimentos as (
select 'stg_procedimentos' as Tipo, cast(sp.dhup as date) as data ,count(*) as Registros, 0 as valortotal, su.id as unidade_id
from stg_procedimentos sp
left join stg_agendamentos_hist sah on sah.procedimento_id = sp.id
left join stg_locais sl on sl.id = sah.local_id 
left join stg_unidades su on su.id = sl.unidade_id 
group by cast(sp.dhup as date), su.id),
tb_consolidacao_agendamentos_hist as (
select 'tb_consolidacao_agendamentos_hist' as Tipo, cast(ahi.datadoatendimento as date) as data, count(*) as Registro, 0 as valortotal, ahi.id_unidade as unidade_id 
from tb_consolidacao_agendamentos_hist ahi
group by cast(ahi.datadoatendimento as date), ahi.id_unidade),
tb_consolidacao_contas_a_receber_modelagem as (
select 'tb_consolidacao_contas_a_receber_modelagem' as Tipo, cast(cr.data_pagamento as date) as data, count(*) as Registros, cr.valor_pago as valortotal, cr.id_unidade as unidade_id
from tb_consolidacao_contas_a_receber_modelagem cr
group by cast(cr.data_pagamento as date), cr.valor_pago, cr.id_unidade),
tb_consolidacao_receita_bruta_hist_final as (
select 'tb_consolidacao_receita_bruta_hist_final' as Tipo, cast(tcrbhf."data" as date) as data, count(*) as Registros, tcrbhf.total_recebido as valortotal, tcrbhf .id_unidade  as unidade_idc
from tb_consolidacao_receita_bruta_hist_final tcrbhf
group by cast(tcrbhf."data" as date),tcrbhf.total_recebido, tcrbhf .id_unidade),
tb_consolidacao_contas_a_pagar_hist as (
select 'tb_consolidacao_contas_a_pagar_hist' as Tipo, cast(cp."data" as date) as data, count(*) as Registros, cp.valortotal as valortotal, su.id as unidade_id
from tb_consolidacao_contas_a_pagar_hist cp
left join stg_unidades su on su.nome_fantasia = cp.nome_fantasia 
group by cast(cp."data" as date), cp.valortotal, su.id),
stg_boletos_emitidos as (
select 'stg_boletos_emitidos' as Tipo, cast(be.data_hora as date), count(*) as Registros, 0 as valortotal, be.unidade_id 
from stg_boletos_emitidos be
group by cast(be.data_hora as date), be.unidade_id),
stg_grade_fixa as (
select 'stg_grade_fixa' as Tipo, cast(gf.datahora as date), count(*) as Registros, 0 as valortotal, su.id as unidade_id
from stg_grade_fixa gf
left join stg_locais sl on sl.id = gf.localid
left join stg_unidades su on su.id = sl.unidade_id 
group by cast(gf.datahora as date), su.id),
stg_royalties_contas as (
select 'stg_grade_fixa' as Tipo, cast(rc.datareferencia as date), count(*) as Registros, 0 as valortotal, rc.unidadeid as unidade_id
from stg_royalties_contas rc
group by cast(rc.datareferencia as date), rc.unidadeid),
stg_splits as (
select 'stg_splits' as Tipo, cast(s."data" as date), count(*) as Registros, 0 as valortotal, smh.unidade_id
from stg_splits s
left join stg_movimentacao_hist smh on smh.id = s.movimentacao_id 
group by cast(s."data" as date), smh.unidade_id),
stg_profissionais as (
select 'stg_profissionais' as Tipo, cast(sp.dhup as date) as data, count(*) as Registros, 0 as valortotal, 0 as unidade_id
from stg_profissionais sp
where sp.sys_active = 1
group by cast(sp.dhup as date), sp.unidade_id)
select * from (
select * from stg_splits ss
union all
select * from stg_contas
union all
select * from stg_propostas
union all
select * from stg_grade_fixa
union all
select * from stg_grade_fixa
union all
select * from stg_boletos_emitidos
union all
select * from stg_procedimentos
union all
select * from stg_agendamento_procedimentos
union all
select * from stg_atendimentos
union all
select * from stg_dc_pdf_assinados
union all
select * from stg_pacientes_pedido
union all
select * from stg_pacientes_prescricoes
union all
select * from stg_agenda_horarios_itens
union all
select * from stg_contas_bloqueios
union all
select * from stg_memed_prescricoes
union all
select * from stg_agendamentos
union all
select * from stg_movimentacao
union all
select * from tb_consolidacao_agendamentos_hist
union all
select * from tb_consolidacao_contas_a_receber_modelagem
union all
select * from tb_consolidacao_receita_bruta_hist_final
union all
select * from tb_consolidacao_contas_a_pagar_hist
union all
select * from stg_profissionais)
where data between current_date - 90 and current_date


--teste de window functions
select sc.unidade_id, 
sum(sc.valor) over (partition by sc.data_referencia) as cont
from stg_contas sc 
where sc.data_referencia  between '2023-03-01' and current_date -1
--order by sc.data_referencia  desc

select sc.data_referencia, 
sum(sc.valor)
from stg_contas sc 
where sc.data_referencia  between '2023-03-01' and current_date -1
group by sc.data_referencia
order by sc.data_referencia  desc

select tcrbhf ."data" , sum(tcrbhf.total_recebido) as total_recebido 
from tb_consolidacao_receita_bruta_hist_final tcrbhf 
left join stg_unidades su on su.id = tcrbhf .id_unidade 
where tcrbhf ."data" between '2023-03-01' and current_date -1
and su.nome_fantasia = 'AmorSaúde Ribeirão Preto'
group by tcrbhf ."data"
order by tcrbhf ."data" desc

--verificar a quantidade de registro
select sci.data_execucao, count(*) 
from stg_conta_itens sci
where sci.data_execucao between '2023-01-01' and current_date -1
group by sci.data_execucao 
order by sci.data_execucao desc

select sm."data" , count(*) 
from stg_movimentacao sm
where sm.data between '2023-01-01' and current_date -1
group by sm."data"
order by sm."data" desc

select count(*), tccarm.data_pagamento 
from tb_consolidacao_contas_a_receber_hist_nova tccarm 
where tccarm.data_pagamento between '2023-08-1' and current_date 
group by tccarm.data_pagamento
order by tccarm.data_pagamento desc

select count(*), tccarm.data_pagamento 
from tb_consolidacao_contas_a_receber_modelagem tccarm 
where tccarm.data_pagamento between '2023-08-1' and current_date 
group by tccarm.data_pagamento
order by tccarm.data_pagamento desc

select tcrbhf."data", count(*), sum(tcrbhf.total_recebido), sum(tcrbhf.total_royalties)  
from tb_consolidacao_receita_bruta_hist_final tcrbhf 
where tcrbhf."data" = '2023-10-03'
and tcrbhf.id_unidade = 19957
group by tcrbhf."data"
order by tcrbhf."data" desc

select sm."data" ,count(*)
from stg_movimentacao sm 
left join stg_pagamento_item_associacao spa on spa.pagamento_id = sm.id
where sm."data" between '2023-09-01' and '2023-10-01'
group by sm."data"
order by sm."data" desc

select date(a.dhup), sum(a.valor)
from stg_pagamento_item_associacao a
where a.dhup between '2023-09-01' and '2023-10-01'
group by date(a.dhup)
order by date(a.dhup) desc

select sm."data" , count(*)
from stg_movimentacao sm 
where sm."data" between '2023-09-01' and current_date
group by sm."data"
order by sm."data" desc

select sum(tccarhn.valor_pago), count(*)
from tb_consolidacao_contas_a_receber_hist_nova tccarhn 
where 1=1
and tccarhn.id_unidade = 19957
and tccarhn.datapagamento = '2023-10-13'
limit 10





select * from stg_agendamento_canais sac 
--where sys_active = 1


select --tcrbhf.id_unidade , su.nome_fantasia , 
sum(total_recebido) as recebido, sum(total_royalties) royalties
from tb_consolidacao_receita_bruta_hist_final tcrbhf 
left join stg_unidades su on tcrbhf.id_unidade = su.id 
where "data" between '2023-11-01' and '2023-11-26'
--and tcrbhf.id_unidade = 19611
--group by tcrbhf.id_unidade, su.nome_fantasia
--order by tcrbhf.id_unidade  asc


select --tccaph.id , tccaph.nome_fantasia,  
--sum(tccaph.valortotal) as valortotal , 
--sum(valorvencido) as valorvencido ,
--sum(tccaph.valorapagar) as valorapagar , 
sum(tccaph.valorpago) as valorpago  
from tb_consolidacao_contas_a_pagar_hist tccaph 
WHERE tccaph.datapagamento  BETWEEN DATE('2023-11-01') AND DATE('2023-11-26')
--group by tccaph.id, tccaph.nome_fantasia 
--order by tccaph.id



select --id_unidade, nome_unidade,nomegrupo,count(nome_procedimento) as quantidade, 
sum(valor_pago) as valor, count(*)
from tb_consolidacao_contas_a_receber_hist_nova tccarhn
where datapagamento between '2023-11-01' and '2023-11-26'
and valor_pago > 0
--group by id_unidade, nome_unidade, nomegrupo 
--order by id_unidade, nomegrupo


--contas a receber
select count(*)
from tb_consolidacao_contas_a_receber_hist_nova tccarhn
where datapagamento between '2023-11-01' and '2023-11-26'
and nomegrupo in ('Exames de Imagem', 'Exames Laboratoriais', 'Procedimentos', 
'Sessão', 'Cirurgia Geral', 'Cirurgia Oftalmológica', 'Vacinas', 'Terapias Injetaveis')
and id_unidade = 19543
--group by id_unidade, nome_unidade 
--order by id_unidade


--prescrição de medicamento
select u.id, u.nome_fantasia, count(pp.id) as qtd_presc_feegow, count(distinct pp.memed_id) as qtd_presc_memed
from stg_pacientes_prescricoes pp
inner join stg_atendimentos att on pp.atendimento_id = att.id 
left join stg_agendamentos ag on att.agendamento_id = ag.id
left join stg_locais l on ag.local_id = l.id
left join stg_unidades u on l.unidade_id = u.id
where pp."data" between '2023-11-01' and '2023-11-26'
group by  u.id, u.nome_fantasia
order by u.id


--itens orçados
select u.id as id_unidade, u.nome_fantasia, round(sum(ip.valor_unitario),2) as valor, count(ip.id) as qtd_itens 
from stg_propostas p
left join stg_itens_proposta ip on ip.proposta_id = p.id
left join stg_unidades u on p.unidadeid = u.id
where dataproposta between '2023-11-01' and '2023-11-26'
group by u.id, u.nome_fantasia
order by u.id


--prontuários
with pront_assinado as (
select distinct sa.agendamento_id, 1 as assinado
from stg_dc_pdf_assinados sdpa
left join stg_atendimentos sa on	sdpa.documento_id = sa.id
where sdpa.tipo in ('ATENDIMENTO')
group by sa.agendamento_id)
select U.id, u.nome_fantasia, sum(pront.assinado) as QTD_assinado
from stg_agendamento_procedimentos agdts
left join stg_locais L on	agdts.local_id = L.id
left join stg_unidades U on	L.unidade_id = U.id
left join stg_unidades_regioes ur on	U.regiao_id = ur.id
left join stg_procedimentos pro on	agdts.procedimento_id = pro.id
left join stg_agendamentos ag on	agdts.agendamento_id = ag.id
left join stg_especialidades esp on	ag.especialidade_id = esp.id
left join stg_profissionais prof on	ag.profissional_id = prof.id
left join stg_pacientes pac on	ag.paciente_id = pac.id
left join pront_assinado pront on	agdts.agendamento_id = pront.agendamento_id
where 1 = 1
and	ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3, 208)
and pro.tipo_procedimento_id in (2, 9)
and ag."data" between '2023-11-20' and '2023-11-28'
group by u.id, u.nome_fantasia
order by u.id

select sum(sm.meta_fat_bruto), sm.mesano 
from stg_metas sm 
group by sm.mesano 


select u.id as id_unidade, u.nome_fantasia, sum(ip.valor_unitario) as valor, count(ip.id) as qtd_itens 
from stg_propostas_hist p
left join stg_itens_proposta_hist ip on ip.proposta_id = p.id
left join stg_unidades u on p.unidadeid = u.id
where dataproposta between '2023-11-01' and '2023-11-30'
and u.nome_fantasia like 'AmorSaúde Araruama'
group by u.id, u.nome_fantasia 