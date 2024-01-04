--pelo mychesys
select c.Nm_Clinica as Nome, cast(a.[Data] as date) as Data,  count(*) as Quantidade from Mychesys.dbo.agendamento a
left join Mychesys.dbo.Clinica c on c.id_Clinica = a.Id_Clinica
left join Mychesys.dbo.Profissional p on p.id = a.ProfissionalID --especialidade pela tabela profissional
where a.[Data] BETWEEN '2020-01-01' and '2020-12-31'
and p.EspecialidadeID = 'Oftalmologia'
and a.Status in ('Atendido' , 'Em Atendimento', 'Triagem', 'Em Espera')
and a.SubtipoProcedimentoID is not null
group by c.Nm_Clinica, a.[Data]

--pela feegow ó usr tabela agendamentos

