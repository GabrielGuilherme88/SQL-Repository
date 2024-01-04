-- Volume de registros na tabela "stg_agendamentos"
select ag."data", count(*) from stg_agendamentos ag
where ag."data" between '2023-01-01' and current_date-1
group by ag."data"
order by ag."data" desc

-- Duplicidades de registros na tabela "stg_agendamentos"
select ag.id, count(*) from stg_agendamentos ag
group by ag.id
having count(ag.id) >1

-- Volume de registros na tabela "stg_movimentacao"
select m."data", count(*) from stg_movimentacao m
where m."data" between '2023-01-01' and current_date-1
group by m."data"
order by m."data" desc

-- Duplicidades de registros na tabela "stg_movimentacao"
select m.id, count(*) from stg_movimentacao m
group by m.id
having count(m.id) >1

-- Volume de registros na tabela "stg_contas"
select c.data_referencia, count(*) from stg_contas c
where c.data_referencia between '2023-01-01' and current_date-1
group by c.data_referencia
order by c.data_referencia desc

-- Duplicidades de registros na tabela "stg_contas"
select c.id, count(*) from stg_contas c
group by c.id
having count(c.id) >1

-- Volume de registros na tabela "stg_propostas"
select p.dataproposta, count(*) from stg_propostas p
where p.dataproposta between '2023-01-01' and current_date-1
group by p.dataproposta
order by p.dataproposta desc

-- Volume de registros na tabela -- Volume de registros na tabela "tb_consolidacao_agendamentos_hist"
select ahi.datadoatendimento, count(*) from tb_consolidacao_agendamentos_hist ahi
where ahi.datadoatendimento between '2023-01-01' and current_date-1
group by ahi.datadoatendimento
order by ahi.datadoatendimento desc

-- Volume de registros na tabela "tb_consolidacao_contas_a_receber_hist"
select cr.datapagamento, count(*) from tb_consolidacao_contas_a_receber_hist cr
where cr.datapagamento between '2023-01-01' and current_date-1
group by cr.datapagamento
order by cr.datapagamento desc

--VOlume por data da tabela "stg_memed_prescrições"
select mp."data", count(*) from stg_memed_prescricoes mp
where mp."data" between '2023-01-01' and current_date-1
group by mp."data"
order by mp."data" desc

-- Volume de nulos dentro da tabela "stg_memed_prescrições"
select mp."data", count(*) from stg_memed_prescricoes mp
where mp.agendamento_id is null
group by mp."data"
order by mp."data" desc

-- Duplicidades de registros na tabela "stg_pacientes"
select pcts.id, count(*) from stg_pacientes pcts
group by pcts.id
having count(pcts.id) >1

