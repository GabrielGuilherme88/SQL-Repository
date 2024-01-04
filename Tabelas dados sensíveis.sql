--tabela fato com alto nível de sensibilidade.
--cadastros de pacientes (cpf, endereços etc), 
--alto nível de rastreabilidade em outras tabelas com alto nível de sensibilidade 
select * from stg_pacientes sp 
limit 10

--há rastreabilidade através do ID do paciente (sendo necessário ter a tabela de pacienes).
--É possível ver o diagnoóstico médico no campo descricao
--sensibilidade alta
select * from stg_pacientes_diagnosticos spd
where spd.descricao is not null
limit 10

--possui campo de atestado e titulo, porém não está populado.
select * from stg_pacientes_atestados spa
where spa.atestado is not null
and spa.titulo is not null
limit 10

--baixo nível de sensibilidade
select * from stg_paciente_convenio spc
left join stg_convenios_planos scp on scp.convenio_id = spc.convenio_id 
where spc.id is not null and scp.id is not null
limit 500

--tabela referente a dependentes dos pacientes
--tabela com grau de sensibilidade alta devido a informações de dependentes (podendo ser crianças) vínculados diretamente com o paciente_id 
--há cpf, telefone níveis altos de sensibilidade
select * from stg_pacientes_relativos spr 
limit 10

--nível baixo de sensibilidade. Baixo padrão de rastreabilidade
select * from stg_pacientes_pedidos spp
where spp.pedido_exame like 'A%'
or spp.nome_laboratorio is not null
limit 10

--nível de sensibilidade alta. É possível rastrear o paciente (pacientes_id) e víncular uma prescrição de medicamento a ele.
--possível ainda víncular o atendimento (quais profissionais, data e locais que aconteceu)
select * from stg_pacientes_prescricoes spp 
limit 10

--permissão negada
select * from stg_paciente_endereco pe
limit 10
---------------------------------------------------------------------------------------------------------------------------

