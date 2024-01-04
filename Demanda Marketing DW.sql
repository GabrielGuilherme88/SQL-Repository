select * from stg_agendamento_canais sac
limit 5

select * from tb_consolidacao_agendamentos_hist tcah 
where tcah .datacriacaoagdt between '2022-08-01' and '2023-02-28'
and tcah .nome_canal = 'Portal do Paciente'


select * from stg_tabelas_particulares tp
where sys_active = 1


