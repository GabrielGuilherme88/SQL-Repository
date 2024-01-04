--Select original 
select p.dataproposta, 
p.unidadeid, 
p.pacienteid, 
p.tabelaid, 
ip.item_id, 
p.staid,
p.sys_user,
ip.valor_unitario
from stg_propostas_hist p
left join stg_itens_proposta_hist ip on ip.proposta_id = p.id

select p.dataproposta, 
p.unidadeid, 
p.pacienteid, 
p.tabelaid, 
ip.item_id, 
p.staid,
p.sys_user,
ip.valor_unitario
from stg_propostas_hist p
left join stg_itens_proposta_hist ip on ip.proposta_id = p.id
where p.dataproposta between '2021-01-01' and '2023-12-31'
and 
