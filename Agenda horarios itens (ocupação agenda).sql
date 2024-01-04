select sahi."data" as data, count(*) as qtde  from stg_agenda_horarios_itens sahi
group by  data
order by data desc

