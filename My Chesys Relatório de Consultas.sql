select c.Nm_Clinica,  p2.NomePaciente, p2.CPF, a.[Data], p.VL_PROCEDIMENTO, p.VL_REPASSE, p.DS_PROCEDIMENTO
from Mychesys.dbo.procedimento p
left join Mychesys.dbo.agendamento a on a.ProcedimentoID = p.ID_PROCEDIMENTO
left join Mychesys.dbo.Paciente p2 on p2.id = a.PacienteID
left join Mychesys.dbo.Clinica c on c.id_Clinica = p.id_Clinica
left join Mychesys.dbo.Marcacao_Exame me on me.CodigoProcedimento = p.ID_PROCEDIMENTO 
left join Mychesys.dbo.LANCAMENTO l on l.ID_LANCAMENTO = me.CodigoLancamento
where c.Nm_Clinica = 'AmorSaúde Baruerí'
--group by c.Nm_Clinica,  p2.NomePaciente, p2.CPF, a.[Data], p.VL_PROCEDIMENTO, p.VL_REPASSE, p.DS_PROCEDIMENTO
--having count(p.ID_PROCEDIMENTO) < =  60;



select c.Nm_Clinica,  p2.NomePaciente, p2.CPF, l.VALOR_ORIGINAL_SERVICO ,l.VALOR_BAIXADO ,l.VALOR_DESCONTO 
from Mychesys.dbo.LANCAMENTO l
left join Mychesys.dbo.Marcacao_Exame me on me.CodigoLancamento = l.ID_LANCAMENTO
left join Mychesys.dbo.procedimento p on p.ID_PROCEDIMENTO = me.CodigoProcedimento
left join Mychesys.dbo.Clinica c on c.id_Clinica = l.ID_CLINICA 
left join Mychesys.dbo.Paciente p2 on p2.id = me.CodigoPaciente 
where c.Nm_Clinica = 'AmorSaúde Baruerí'
and p.DS_PROCEDIMENTO like 'Consul%'



