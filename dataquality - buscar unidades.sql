
select 'stg_agendamento' as Tipo, cast(ag."data" as date), count(*) as Registros, 0 as valortotal, su.id as unidade_id
from stg_agendamentos ag
left join stg_locais sl on sl.id = ag.local_id
left join stg_unidades su on su.id = sl.unidade_id
group by cast(ag."data" as date), su.id

select 'stg_movimentacao' as Tipo, cast(ag."data" as date), count(*) as Registros, 0 as valortotal, ag.unidade_id
	from stg_movimentacao ag
group by cast(ag."data" as date), ag.unidade_id

select 'stg_contas' as Tipo ,cast(ag.data_referencia as date) as data, count(*) as Registros, 0 as valortotal, ag.unidade_id
	from stg_contas ag
group by cast(ag.data_referencia as date), ag.unidade_id

select 'stg_propostas' as Tipo, cast(p.dataproposta as date) as data, count(*) as Registros, 0 as valortotal, p.unidadeid as unidade_id
from stg_propostas p
group by cast(p.dataproposta as date),p.unidadeid

select 'stg_memed_prescricoes mp' as Tipo, cast(mp.datahora as date) as data  , count(*) as Registros, 0 as valortotal, sa.unidade_id
from stg_memed_prescricoes mp
left join stg_atendimentos_hist sa on sa.id = mp.atendimentoid 
group by cast(mp.datahora as date), sa.unidade_id

select 'stg_dc_pdf_assinados' as Tipo, cast(pa.data_criacao as date) as data, count(*) as Registros, 0 as valortotal, ah.unidade_id 
from stg_dc_pdf_assinados pa
left join stg_atendimentos_hist ah on ah.id = pa.documento_id 
group by cast(pa.data_criacao as date), ah.unidade_id

select 'stg_pacientes_pedidos' as Tipo, cast(pd."data"  as date) as data, count(*) as Registros, 0 as valortotal, sah.unidade_id
from stg_pacientes_pedidos pd
left join stg_atendimentos_hist sah on sah.paciente_id  = pd.paciente_id  
group by cast(pd."data"  as date),sah.unidade_id

select 'stg_pacientes_prescricoes' as Tipo, cast(pp."data" as date) as data, count(*) as Registros, 0 as valortotal, sah.unidade_id 
from stg_pacientes_prescricoes pp
left join stg_atendimentos_hist sah on sah.paciente_id = pp.paciente_id 
group by cast(pp."data" as date), sah.unidade_id

select 'stg_agenda_horarios_itens' as Tipo ,cast(hi."data" as date) as data, count(*) as Registros, 0 as valortotal, hi.unidade_id 
from stg_agenda_horarios_itens hi
group by cast(hi."data" as date), hi.unidade_id

select 'stg_contas_bloqueios' as Tipo, cast(cb."data" as date)as data , count(*) as Registros, 0 as valortotal, cb.unidade_id 
from stg_contas_bloqueios cb
group by cast(cb."data" as date), cb.unidade_id

select 'stg_atendimentos' as Tipo, cast(a."data" as date) as data, count(*) as Registros, 0 as valortotal, a.unidade_id 
from stg_atendimentos a
group by cast(a."data" as date), a.unidade_id

select 'stg_agendamento_procedimentos sap' as Tipo, cast(sap.dhup as date) as data, count(*) as Registros, 0 as valortotal, su.id as unidade_id
from stg_agendamento_procedimentos sap 
left join stg_locais sl on sl.id = sap.local_id
left join stg_unidades su on su.id = sl.unidade_id 
group by cast(sap.dhup as date), su.id

select 'stg_procedimentos' as Tipo, cast(sp.dhup as date) as data ,count(*) as Registros, 0 as valortotal, su.id as unidade_id
from stg_procedimentos sp
left join stg_agendamentos_hist sah on sah.procedimento_id = sp.id
left join stg_locais sl on sl.id = sah.local_id 
left join stg_unidades su on su.id = sl.unidade_id 
group by cast(sp.dhup as date), su.id

select 'tb_consolidacao_agendamentos_hist' as Tipo, cast(ahi.datadoatendimento as date) as data, count(*) as Registro, 0 as valortotal, ahi.id_unidade as unidade_id 
from tb_consolidacao_agendamentos_hist ahi
group by cast(ahi.datadoatendimento as date), ahi.id_unidade

select 'tb_consolidacao_contas_a_receber_hi' as Tipo, cast(cr.datapagamento as date) as data, count(*) as Registros, cr.valorpago as valortotal, cr.id_unidade  as unidade_id
from tb_consolidacao_contas_a_receber_hist cr
group by cast(cr.datapagamento as date), cr.valorpago),cr.id_unidade

select 'tb_consolidacao_receita_bruta_hist_final' as Tipo, cast(tcrbhf."data" as date) as data, count(*) as Registros, tcrbhf.total_recebido as valortotal, tcrbhf .id_unidade  as unidade_idc
from tb_consolidacao_receita_bruta_hist_final tcrbhf
group by cast(tcrbhf."data" as date),tcrbhf.total_recebido, tcrbhf .id_unidade)

select 'tb_consolidacao_contas_a_pagar_hist' as Tipo, cast(cp."data" as date) as data, count(*) as Registros, cp.valortotal as valortotal, su.id as unidade_id
from tb_consolidacao_contas_a_pagar_hist cp
left join stg_unidades su on su.nome_fantasia = cp.nome_fantasia 
group by cast(cp."data" as date), cp.valortotal, su.id

select 'stg_boletos_emitidos' as Tipo, cast(be.data_hora as date), count(*) as Registros, 0 as valortotal, be.unidade_id 
from stg_boletos_emitidos be
group by cast(be.data_hora as date), be.unidade_id

select 'stg_grade_fixa' as Tipo, cast(gf.datahora as date), count(*) as Registros, 0 as valortotal, su.id as unidade_id
from stg_grade_fixa gf
left join stg_locais sl on sl.id = gf.localid
left join stg_unidades su on su.id = sl.unidade_id 
group by cast(gf.datahora as date), su.id

select 'stg_grade_fixa' as Tipo, cast(rc.datareferencia as date), count(*) as Registros, 0 as valortotal, rc.unidadeid as unidade_id
from stg_royalties_contas rc
group by cast(rc.datareferencia as date), rc.unidadeid

select 'stg_splits' as Tipo, cast(s."data" as date), count(*) as Registros, 0 as valortotal, smh.unidade_id
from stg_splits s
left join stg_movimentacao_hist smh on smh.id = s.movimentacao_id 
group by cast(s."data" as date), smh.unidade_id

select * from stg_movimentacao_hist smh 
limit 1

