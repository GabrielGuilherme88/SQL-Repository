select tccarh .grupoprocedimento, count(nomeprocedimento)  from tb_consolidacao_contas_a_receber_hist tccarh 
group by tccarh .grupoprocedimento