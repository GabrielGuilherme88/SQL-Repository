select sahi."data" , count(*)  from stg_agenda_horarios_itens sahi 
group by sahi."data"
order by sahi."data" desc

select * from stg_agenda_horarios_itens sahi
--where sahi .nome_fantasia = 'AmorSaúde Ribeirão Preto'



