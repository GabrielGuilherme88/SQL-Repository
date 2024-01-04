
select tccarh .nome_fantasia , tccarh .grupoprocedimento , count(tccarh.nomeprocedimento), sum(valorpago)  from tb_consolidacao_contas_a_receber_hist tccarh  
where tccarh.id_unidade in (19751,19888,19724,19684,19615,19611,19871,19305,19938,19328,19928,19594,19915,19802,19883)
group by tccarh .nome_fantasia , tccarh .grupoprocedimento