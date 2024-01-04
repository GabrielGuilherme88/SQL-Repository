SELECT 
	c.Nm_Clinica as franquia_amorsaude, 
	pcts.id as id_paciente, 
	pcts.NomePaciente, 
	pcts.Nascimento as data_nascimento, 
	pcts.Sexo, 
	p.modelo as modelo_prontuario, 
	p.Texto as conteudo_prontuario,
	p.DataHora
FROM Mychesys.dbo.Prontuario p
left join Mychesys.dbo.Paciente pcts on p.PacienteID = pcts.id
left join Mychesys.dbo.Clinica c on p.Id_Clinica = c.id_Clinica
where 1=1
and TRIM(pcts.CPF) = '03466995760'
--and pcts.NomePaciente = 'Vanessa Coelho Lemões'
--and p.DataHora BETWEEN '2020-12-01 00:00:00' and '2020-12-31 23:59:00'



SELECT 
*
FROM Mychesys.dbo.Prontuario p
left join Mychesys.dbo.Paciente pcts on p.PacienteID = pcts.id
left join Mychesys.dbo.Clinica c on p.Id_Clinica = c.id_Clinica
where 1=1
and pcts.CPF = '03466995760'

--1																																																																																																																																																																																																			
--verificando lançamento financeiro realizado
select *
from Mychesys.dbo.LANCAMENTO l
left join Mychesys.dbo.agendamento a on a.id = l.ID_AGENDA 
left join Mychesys.dbo.Paciente p on p.id = a.PacienteID
left join Mychesys.dbo.procedimento p2 on p2.ID_PROCEDIMENTO = a.ProcedimentoID
left join Mychesys.dbo.Profissional pp2 on pp2.id = a.ProfissionalID  
where 1=1
and p.CPF = '03466995760'


--2
select l.FORMA_PGTO, l.SUB_CATEGORIA , l.DT_APROVACAO, l.STATUS_LANCAMENTO, l.DT_BAIXA, l.DT_CRIACAO, a.Status, a.NomePaciente 
from Mychesys.dbo.LANCAMENTO l
left join Mychesys.dbo.agendamento a on a.id = l.ID_AGENDA 
left join Mychesys.dbo.Paciente p on p.id = a.PacienteID
left join Mychesys.dbo.Profissional p2 on p2.id = l.ID_PROFISSIONAL
--left join Mychesys.dbo.procedimento p2 on p2.ID_PROCEDIMENTO = a.ProcedimentoID
where 1=1
and p.CPF = '03183283050'
--and l.DT_APROVACAO BETWEEN '2020-12-01 00:00:00' and '2020-12-31 23:59:00'


--3
select me.DataAgenda, me.NomePaciente, me.NomeProfissional, me.DescricaoProcedimento,
me.DataBaixa, me.StatusAgendaDescricao, me.CPF 
from Mychesys.dbo.Marcacao_Exame me 
left join Mychesys.dbo.Paciente p on p.id = me.CodigoPaciente 
where 1=1
and p.CPF = '03183283050'
--and me.DataAgenda BETWEEN '2020-12-01 00:00:00' and '2020-12-31 23:59:00'

select * from Paciente p 
--where TRIM(p.CPF) = '03183283050'
where p.NomePaciente like 'Vanessa Coelho%'
