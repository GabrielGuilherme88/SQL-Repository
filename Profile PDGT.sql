select * from pdgt_sandbox_gabrielguilherme.fl_especialidades

select * from pdgt_sandbox_gabrielguilherme.fl_fornecedores

select * from pdgt_sandbox_gabrielguilherme.fl_regionais 

select * from pdgt_sandbox_gabrielguilherme.fl_unidades 

select fp.id_profissional, fp.nm_profissional, fp.id_conselho, fp.nro_conselho, fp.nascimento, fp.cpf, fp.genero, fp.id_unidade, fp.unidade, fp.email1 , fp.email2, fp.telefone1, fp.telefone2, fp.celular1, fp.celular2, fp.dt_atualizacao, fp.dt_criacao, fp.status_cadastro from pdgt_sandbox_gabrielguilherme.fl_profissionais fp

select a.id_agendamento, a.id_regional, a.regional, a.id_unidade, a.unidade, a.dt_agendamento, a.dt_criacao, a.id_paciente, a.nm_paciente, a.cpf, a.celular, a.email, a.sexo, a.estado,a.cidade ,a.bairro ,a.bairro ,a.logradouro ,a.numero ,a.id_status ,a.nm_status ,a.id_profissional ,a.nm_profissional ,a.id_especialidade ,a.nm_especialidade ,a.id_procedimento ,a.nm_procedimento ,a.id_tipoprocedimento ,a.tipoprocedimento ,a.tipoprocedimento ,a.id_grupoprocedimento ,a.nm_grupo ,a.id_tabela ,a.nm_tabela ,a.valor  from pdgt_sandbox_gabrielguilherme.fl_agendamentos a limit 1000000

select * from pdgt_sandbox_gabrielguilherme.fl_canais limit 10

select * from pdgt_sandbox_gabrielguilherme.fl_indicadores limit 10

select * from pdgt_sandbox_gabrielguilherme.fl_pacientes limit 10

select * from pdgt_sandbox_gabrielguilherme.fl

select * from pdgt_sandbox_gabrielguilherme.fl_re

select sum(b.total_recebido), sum(b.total_royalties), b.forma_pagamento  
from pdgt_sandbox_gabrielguilherme.fl_receita_bruta b
where b.id_unidade = 19440
and b."data" between date('2023-08-01') and date('2023-08-10')
group by b.forma_pagamentdata

SELECT count(*), c.data_referencia  
FROM todos_data_lake_trusted_feegow.contas c
where c.data_referencia between date('2023-08-01') and date('2023-08-15')
group by c.data_referencia
order by c.data_referencia desc
limit 10

--TESTE TABELA PARA VERIFICAR QUANTIDADE
select * from todos_data_lake_trusted_feegow.tabelas_particulares stp
left join todos_data_lake_trusted_feegow.tabelas_particulares_unidades stpu on stpu.tabela_particular_id = stp.id 
left join todos_data_lake_trusted_feegow.unidades su on su.id = stpu.unidade_id
where 1=1
and stp.nome_tabela_particular  like 'Pacote Pré-Operatório - Cirurgia Geral - CDT'

--registros ok dentro do lake
select count(*) from todos_data_lake_trusted_feegow.tabelas_particulares_unidades tu
--where tu.tabela_particular_id = 830081

--agendamentos ok
select count(*)
from todos_data_lake_trusted_feegow.agendamentos ag
left join todos_data_lake_trusted_feegow.locais sl on sl.id = ag.local_id
left join todos_data_lake_trusted_feegow.unidades su on su.id = sl.unidade_id
where ag."data" between date('2022-07-01') and current_date 

--movimentacao ok 
select count(*)	from todos_data_lake_trusted_feegow.movimentacao m
where m."data" between date('2022-07-01') and current_date 

--contas ok 
select count(*)
	from todos_data_lake_trusted_feegow.contas c
	where c.data_referencia between date('2022-07-01') and current_date 
	
--proposta ok
select count(*)
from todos_data_lake_trusted_feegow.propostas p
where p.dataproposta between date('2022-07-01') and current_date 


--pdf_assinado ok
select count(*) 
from todos_data_lake_trusted_feegow.dc_pdf_assinados pa
where pa.data_criacao between date('2022-07-01') and current_date 

--pedidos ok
select count(*)
from todos_data_lake_trusted_feegow.pacientes_pedidos pd
where pd."data"  between date('2022-07-01') and current_date 

--prescricpes ok
select count(*)
from todos_data_lake_trusted_feegow.pacientes_prescricoes pp
where pp."data"  between date('2022-07-01') and current_date


--bloqueios ok
select count(*)
from todos_data_lake_trusted_feegow.contas_bloqueios cb
where cb."data"  between date('2022-07-01') and current_date

--atendimentos ok
select count(*)
from todos_data_lake_trusted_feegow.atendimentos a
where a."data"  between date('2022-07-01') and current_date


--procedimento ok
select count(*)
from todos_data_lake_trusted_feegow.procedimentos sp

--conta itens ok
select count(*)
from todos_data_lake_trusted_feegow.conta_itens sci
where sci.data_execucao  between date('2022-07-01') and current_date

--splits
select count(*)
from todos_data_lake_trusted_feegow.splits s
where s."data"  between date('2022-07-01') and current_date

--royalite
select count(*)
from todos_data_lake_trusted_feegow.royalties_contas rc
where rc.datareferencia between date('2022-07-01') and current_date

--verificar se está sendo atualizada as tabelas de profissionais_unidades
select distinct *
from todos_data_lake_trusted_feegow.profissionais sp
left join todos_data_lake_trusted_feegow.profissionais_unidades spu on spu.profissional_id = sp.id
where sp.nome_profissional = 'Maximilian Porley Hornos Dos Santos'