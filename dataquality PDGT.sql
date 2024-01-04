--Funcionando no powerBI
with agendamentos as (
select 'todos_data_lake_trusted_feegow.agendamento' as Tipo, cast(ag."data" as date), count(*) as Registros, 0 as valortotal, su.id as unidade_id
from todos_data_lake_trusted_feegow.agendamentos ag
left join todos_data_lake_trusted_feegow.locais sl on sl.id = ag.local_id
left join todos_data_lake_trusted_feegow.unidades su on su.id = sl.unidade_id
group by cast(ag."data" as date), su.id),
movimentacao as (
select 'todos_data_lake_trusted_feegow.movimentacao' as Tipo, cast(ag."data" as date), count(*) as Registros, 0 as valortotal, ag.unidade_id 
	from todos_data_lake_trusted_feegow.movimentacao ag
group by cast(ag."data" as date), ag.unidade_id),
contas as (
select 'todos_data_lake_trusted_feegow.contas' as Tipo ,cast(ag.data_referencia as date) as data, count(*) as Registros, 0 as valortotal, ag.unidade_id
	from todos_data_lake_trusted_feegow.contas ag
group by cast(ag.data_referencia as date), ag.unidade_id),
propostas as (
select 'todos_data_lake_trusted_feegow.propostas' as Tipo, cast(p.dataproposta as date) as data, count(*) as Registros, 0 as valortotal, p.unidadeid as unidade_id
from todos_data_lake_trusted_feegow.propostas p
group by cast(p.dataproposta as date),p.unidadeid),
memed_prescricoes as (
select 'todos_data_lake_trusted_feegow.memed_prescricoes mp' as Tipo, cast(mp.datahora as date) as data  , count(*) as Registros, 0 as valortotal, sa.unidade_id
from todos_data_lake_trusted_feegow.memed_prescricoes mp
left join todos_data_lake_trusted_feegow.atendimentos sa on sa.id = mp.atendimentoid 
group by cast(mp.datahora as date), sa.unidade_id),
dc_pdf_assinados as (
select 'todos_data_lake_trusted_feegow.dc_pdf_assinados' as Tipo, cast(pa.data_criacao as date) as data, count(*) as Registros, 0 as valortotal, ah.unidade_id 
from todos_data_lake_trusted_feegow.dc_pdf_assinados pa
left join todos_data_lake_trusted_feegow.atendimentos ah on ah.id = pa.documento_id 
group by cast(pa.data_criacao as date), ah.unidade_id),
pacientes_pedido as (
select 'todos_data_lake_trusted_feegow.pacientes_pedidos' as Tipo, cast(pd."data"  as date) as data, count(*) as Registros, 0 as valortotal, sah.unidade_id
from todos_data_lake_trusted_feegow.pacientes_pedidos pd
left join todos_data_lake_trusted_feegow.atendimentos sah on sah.paciente_id  = pd.paciente_id  
group by cast(pd."data"  as date),sah.unidade_id),
pacientes_prescricoes as (
select 'todos_data_lake_trusted_feegow.pacientes_prescricoes' as Tipo, cast(pp."data" as date) as data, count(*) as Registros, 0 as valortotal, sah.unidade_id 
from todos_data_lake_trusted_feegow.pacientes_prescricoes pp
left join todos_data_lake_trusted_feegow.atendimentos sah on sah.paciente_id = pp.paciente_id
group by cast(pp."data" as date), sah.unidade_id),
agenda_horarios_itens as (
select 'todos_data_lake_trusted_feegow.agenda_horarios_itens' as Tipo ,cast(hi."data" as date) as data, count(*) as Registros, 0 as valortotal, hi.unidade_id 
from todos_data_lake_trusted_feegow.agenda_horarios_itens hi
group by cast(hi."data" as date), hi.unidade_id),
contas_bloqueios as (
select 'todos_data_lake_trusted_feegow.contas_bloqueios' as Tipo, cast(cb."data" as date)as data , count(*) as Registros, 0 as valortotal, cb.unidade_id 
from todos_data_lake_trusted_feegow.contas_bloqueios cb
group by cast(cb."data" as date), cb.unidade_id),
atendimentos as (
select 'todos_data_lake_trusted_feegow.atendimentos' as Tipo, cast(a."data" as date) as data, count(*) as Registros, 0 as valortotal, a.unidade_id 
from todos_data_lake_trusted_feegow.atendimentos a
group by cast(a."data" as date), a.unidade_id),
agendamento_procedimentos as (
select 'todos_data_lake_trusted_feegow.agendamento_procedimentos sap' as Tipo, cast(sap.dhup as date) as data, count(*) as Registros, 0 as valortotal, su.id as unidade_id
from todos_data_lake_trusted_feegow.agendamento_procedimentos sap 
left join todos_data_lake_trusted_feegow.locais sl on sl.id = sap.local_id
left join todos_data_lake_trusted_feegow.unidades su on su.id = sl.unidade_id 
group by cast(sap.dhup as date), su.id),
procedimentos as (
select 'todos_data_lake_trusted_feegow.procedimentos' as Tipo, cast(sp.dhup as date) as data ,count(*) as Registros, 0 as valortotal, su.id as unidade_id
from todos_data_lake_trusted_feegow.procedimentos sp
left join todos_data_lake_trusted_feegow.agendamentos sah on sah.procedimento_id = sp.id
left join todos_data_lake_trusted_feegow.locais sl on sl.id = sah.local_id 
left join todos_data_lake_trusted_feegow.unidades su on su.id = sl.unidade_id 
group by cast(sp.dhup as date), su.id),
fl_agendamentos as (
select 'tb_consolidacao_agendamentos_hist' as Tipo, cast(ahi.dt_agendamento as date) as data, count(*) as Registro, 0 as valortotal, ahi.id_unidade as unidade_id 
from pdgt_amorsaude_operacoes.fl_agendamentos ahi
group by cast(ahi.dt_agendamento as date), ahi.id_unidade),
fl_contas_a_receber as (
select 'tb_consolidacao_contas_a_receber_hi' as Tipo, cast(cr.datavencimento  as date) as data, count(*) as Registros, cr.valor_pago as valortotal, cr.id_unidade  as unidade_id
from pdgt_amorsaude_financeiro.fl_contas_a_receber  cr
group by cast(cr.datavencimento as date), cr.valor_pago, cr.id_unidade), --problema em varchar dentro do contas a receber
fl_receita_bruta as (
select 'tb_consolidacao_receita_bruta_hist_final' as Tipo, cast(tcrbhf."data" as date) as data, count(*) as Registros, tcrbhf.total_recebido as valortotal, tcrbhf .id_unidade  as unidade_idc
from pdgt_amorsaude_financeiro.fl_receita_bruta  tcrbhf
group by cast(tcrbhf."data" as date),tcrbhf.total_recebido, tcrbhf .id_unidade),
fl_contas_a_pagar as (
select 'tb_consolidacao_contas_a_pagar_hist' as Tipo, cast(cp."data" as date) as data, count(*) as Registros, cp.valortotal as valortotal, su.id as unidade_id
from pdgt_amorsaude_financeiro.fl_contas_a_pagar cp
left join todos_data_lake_trusted_feegow.unidades su on su.nome_fantasia = cp.nm_unidade 
group by cast(cp."data" as date), cp.valortotal, su.id),
boletos_emitidos as (
select 'todos_data_lake_trusted_feegow.boletos_emitidos' as Tipo, cast(be.data_hora as date), count(*) as Registros, 0 as valortotal, be.unidade_id 
from todos_data_lake_trusted_feegow.boletos_emitidos be
group by cast(be.data_hora as date), be.unidade_id),
grade_fixa as (
select 'todos_data_lake_trusted_feegow.grade_fixa' as Tipo, cast(gf.datahora as date), count(*) as Registros, 0 as valortotal, su.id as unidade_id
from todos_data_lake_trusted_feegow.grade_fixa gf
left join todos_data_lake_trusted_feegow.locais sl on sl.id = gf.localid
left join todos_data_lake_trusted_feegow.unidades su on su.id = sl.unidade_id 
group by cast(gf.datahora as date), su.id),
royalties_contas as (
select 'todos_data_lake_trusted_feegow.grade_fixa' as Tipo, cast(rc.datareferencia as date), count(*) as Registros, 0 as valortotal, rc.unidadeid as unidade_id
from todos_data_lake_trusted_feegow.royalties_contas rc
group by cast(rc.datareferencia as date), rc.unidadeid),
splits as (
select 'todos_data_lake_trusted_feegow.splits' as Tipo, cast(s."data" as date), count(*) as Registros, 0 as valortotal, smh.unidade_id
from todos_data_lake_trusted_feegow.splits s
left join todos_data_lake_trusted_feegow.movimentacao smh on smh.id = s.movimentacao_id 
group by cast(s."data" as date), smh.unidade_id),
conta_itens as (
select 'todos_data_lake_trusted_feegow.conta_itens' as Tipo, cast(sci.data_execucao as date) as data, count(*) as Registros, 0 as valortotal, 0 as unidade_id
from todos_data_lake_trusted_feegow.conta_itens sci
--left join todos_data_lake_trusted_feegow.contas scc on scc.conta_id = sci.id
group by cast(sci.data_execucao as date))
select * from (
select * from conta_itens
union all
select * from contas sc 
union all
select * from splits ss 
union all
select * from propostas
union all
select * from grade_fixa
union all
select * from grade_fixa
union all
select * from boletos_emitidos
union all
select * from procedimentos
union all
select * from agendamento_procedimentos
union all
select * from atendimentos
union all
select * from dc_pdf_assinados
union all
select * from pacientes_pedido
union all
select * from pacientes_prescricoes
union all
select * from agenda_horarios_itens
union all
select * from contas_bloqueios
union all
select * from memed_prescricoes
union all
select * from agendamentos
union all
select * from movimentacao
union all
select * from fl_agendamentos
union all
select * from fl_contas_a_receber
union all
select * from fl_receita_bruta
union all
select * from fl_contas_a_pagar
where data BETWEEN current_date - INTERVAL '90' DAY AND current_date)



select date_format(date_add('day', -4, current_date), '%Y-%m') as snap,
       date_format(date_add('month',-1, date_add('day', -4, current_date)), '%Y-%m') as frozen
       
 --para o parâmetro external_location utilizar sempre a macro get_external_location("nome_do_schema",this.name).
--o parâmetro schema deve ser preenchido com o nome do esquema que será utilizado em produção.
--entretando quando em fase de desenvolvimento será utilizado o esquema padrão do usuário definido no profile "dev".
{{ config(external_location =  get_external_location("pdgt_sandbox_gabrielguilherme", this.name),
          materialized = "view",
          schema = "pdgt_sandbox_gabrielguilherme") }}

select * 
  FROM {{ ref('fl_contas_a_receber') }}
  where snap = date_format(date_add('month',-1, date_add('day', -4, current_date)), '%Y-%m')
  limit 100

  --criar dentro do contas a receber a colua snap
      -- date_format(date_add('day', -4, current_date), '%Y-%m') as snap

  -- depois referênciar dentro dessa view