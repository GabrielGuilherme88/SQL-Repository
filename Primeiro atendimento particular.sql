--Solicitação Paula - Primeiro atendimento com gasto em exames e procedimentos
select cr.nome_unidade, count(*)
--REPLACE(REPLACE(REPLACE(REPLACE(sum(cr.valor_pago)
	--::text,'$','R$ '),',','|'),'.',','),'|','.')  
from stg_agendamento_procedimentos ap
left join stg_agendamentos_hist ag on ap.agendamento_id = ag.id
left join stg_agendamento_status ass on ag.status_id = ass.id
left join stg_especialidades es on ag.especialidade_id = es.id
left join stg_procedimentos pro on ap.procedimento_id = pro.id
left join stg_procedimentos_tipos pt on pro.tipo_procedimento_id = pt.id
left join stg_locais l on ap.local_id = l.id
left join stg_unidades u on l.unidade_id = u.id
--left join tb_consolidacao_contas_a_receber_modelagem cr on cr.id_paciente = ag.paciente_id 
	and cr."data" = ag."data" 
--where ag.valor in (40, 50)
--and ag.tabela_particular_id in (820797, 820798, 820799, 821244, 20485, 821110, 820817)
where pt.id in (2, 9)
and ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
and ag."data" between '2022-01-01' and '2022-12-31'
--and cr.nomegrupo in ('Exames Laboratoriais', 'Procedimentos', 
--'Exames de Imagem', 'Mapa', 'Holter', 'Ressonância', 'Sessão')
and cr.nome_unidade is not null
group by cr.nome_unidade

--busca o total de contas a receber no ano de 2022
select cr.nome_unidade , REPLACE(REPLACE(REPLACE(REPLACE(sum(cr.valor_pago)
	::text,'$','R$ '),',','|'),'.',','),'|','.')
from tb_consolidacao_contas_a_receber_modelagem cr 
--where cr.nome_unidade = 'AmorSaúde Manaus Norte'
where cr."data" between '2022-01-01' and '2022-12-31'
group by cr.nome_unidade