-----------


select * from tb_consolidacao_contas_a_receber_modelagem tccarm
left join tb_consolidacao_agendamentos_hist tcah on tcah.id_unidade = tccarm .id_unidade 
	and cast(tcah.datadoatendimento as date) = tccarm .data_pagamento 
limit 10


-------------

select tcah .nome_status ,  count(*) from tb_consolidacao_agendamentos_hist tcah
group by tcah .nome_status

select * from tb_consolidacao_agendamentos_hist tcah 
where tcah .nome_status = 'Atendido'



limit 10
