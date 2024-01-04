select 
distinct 
f.cpf
from pdgt_cartaodetodos_filiado.fl_filiado f
where f.matricula = 'MG543007498'
group by f.cpf
having max(f.dt_filiacao)  = max(f.dt_filiacao)
limit 10


select *
from pdgt_cartaodetodos_filiado.fl_filiado f
where f.cpf = '13695389605'


--VERIFICAR REGRA PARA NÃO TRAZER DUPLICADO OS CPF QUANDO FAZER O LEFT JOIN COM O FL_FILIADO
---CLIENTES (PACIENTES?)
with filiados as ( --objeto para caçar titularidade
select 
distinct 
trim(f.cpf) as cpfcdt,
--f.matricula,
max(f.flag_titular),
case 
	when max(f.flag_titular) = 1 then 'Titular'
	else 'Dependente'
	end as Titular
from pdgt_cartaodetodos_filiado.fl_filiado f
where 1 = 1
and f.status_atual = 1 --adicionado
group by f.cpf, f.matricula
having max(f.dt_filiacao)  = max(f.dt_filiacao)
),
pacientes as (
select sp.id, --é o prontuário
sp.sys_active as ativo,
null as obito,
sp.id as prontuario, -- é o ID do paciente
trim(sp.cpf) as cpf,
  CASE 
    WHEN POSITION(' ' IN sp.nome_paciente) > 0 
    THEN SUBSTRING(sp.nome_paciente FROM 1 FOR POSITION(' ' IN sp.nome_paciente) - 1)
    ELSE sp.nome_paciente
  END AS nome,
  CASE 
    WHEN POSITION(' ' IN sp.nome_paciente) > 0 
    THEN SUBSTRING(sp.nome_paciente FROM POSITION(' ' IN sp.nome_paciente) + 1)
    ELSE NULL
  END AS sobrenome,
sp.nome_paciente as nome_social,
null as rg,
sp.nascimento AS data_nascimento,
null as nome_mae, -- não achei
null as naturalidade,
sp.profissao,
null as restricoes_trat_medico,
null as telefone,
REGEXP_REPLACE(sp.celular, '[ "()-]', '') AS celular,
'' as celular_alternativo,
sp.email,
spe.cep,
spe.logradouro as endereco,
spe.numero,
spe.complemento,
spe.bairro,
spe.cidade,
spe.estado,
null as fotografia,
null as observacoes,
null as cns,
sp.sysdate as created_at,
sp.dhup,
sp.sexo as sexo_id,
s.nomesexo as sexo,
'2024-12-31' as validade,
case --condição criada para verificar se há matricula e trazer Cartão de TODOS
    WHEN stp.nome_tabela_particular = 'Cartão de TODOS*' THEN 'Cartão de TODOS'
    WHEN spc.matricula is not null and stp.nome_tabela_particular is null THEN 'Cartão de TODOS'
    when spc.matricula is not null and stp.nome_tabela_particular = 'PARTICULAR*' then 'Cartão de TODOS'
    ELSE stp.nome_tabela_particular
    end as parceria,
null as etnia_id,
null as genero_id,
sp.origem_id,
null as prioridades_id,
null as est_civil_id,
null as mig_prontuario_id,
spc.matricula as CDT_MATRICULA,
null as last_attendance_data,
f.Titular,
sp.unidade_id as unidadefeegow_desconsiderar --criado para filtrar a unidade de pirassununga
	from todos_data_lake_trusted_feegow.pacientes sp
left join todos_data_lake_trusted_feegow.paciente_endereco spe on spe.paciente_id = sp.id
left join todos_data_lake_trusted_feegow.paciente_convenio spc on spc.paciente_id = sp.id
left join todos_data_lake_trusted_feegow.tabelas_particulares stp on stp.id = sp.tabela_id
left join todos_data_lake_trusted_feegow.sexo s on s.id = sp.sexo
left join filiados f on trim(f.cpfcdt) = trim(sp.cpf)  --or f.matricula = spc.matricula --busca o cpf ou a matricula --retirado por causa de performance
where sp.sys_active = 1 --apenas ativos
--and cpf not in ('13695389605') --ESTUDAR CASO DE DUPLICIDADE PARA RETIRAR no FUTURO
),
agenda_paciente as ( --objeto criado para buscar os agendamentos dos  pacientes amorsaúde.
select distinct ag.paciente_id as idpaciente 
from todos_data_lake_trusted_feegow.agendamento_procedimentos ap
left join todos_data_lake_trusted_feegow.agendamentos ag on ap.agendamento_id = ag.id
left join todos_data_lake_trusted_feegow.pacientes p on p.id = ag.paciente_id
left join todos_data_lake_trusted_feegow.procedimentos pro on ap.procedimento_id = pro.id
left join todos_data_lake_trusted_feegow.procedimentos_tipos pt on pro.tipo_procedimento_id = pt.id
left join todos_data_lake_trusted_feegow.locais l on ap.local_id = l.id
left join todos_data_lake_trusted_feegow.unidades u on l.unidade_id = u.id
where pt.id in (2, 9)
--and ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
--and ag."data" between  '2020-01-01' and '2023-08-31'
--and p.sys_user <> 0 --filtra usuários que estão fora da interface feegow
and p.sys_active = 1 --filtrar usuários ativos
and u.id = 19811 -- id AmorSaúde Pirassununga
)
select distinct
id, --é o prontuário (igual ao prontuario)
ativo,
obito,
prontuario, -- é o ID do paciente (igual ao ID)
trim(cpf) as cpf,
nome,
sobrenome,
nome_social,
rg,
data_nascimento,
nome_mae, -- não achei
naturalidade,
profissao,
restricoes_trat_medico,
telefone,
celular,
celular_alternativo,
email,
cep,
endereco,
numero,
complemento,
bairro,
cidade,
estado,
fotografia,
observacoes,
cns,
created_at,
dhup,
sexo_id,
sexo,
parceria,
etnia_id,
genero_id,
origem_id,
prioridades_id,
est_civil_id,
mig_prontuario_id,
CDT_MATRICULA,
last_attendance_data,
titular, --no futuro validar
validade --dez 2024 não há informações sobre validade
from pacientes p
where 1 = 1
and unidadefeegow_desconsiderar = 19811
or p.id in (select idpaciente from agenda_paciente)




--PROCEDIMENTOS_AGENDA DO PROFISSIONAL
select pp.id as id_profissional,
pp.nome_profissional,
case when spg.nomegrupo is null then 'Consultas'
else spg.nomegrupo
end as grupo_procedimentos,
523 as id_clinica,
u.nome_fantasia,
pro.nome_procedimento,
pro.id 
from todos_data_lake_trusted_feegow.procedimento_profissional_unidade p
left join todos_data_lake_trusted_feegow.profissionais pp on pp.id = p.profissional_id 
left join todos_data_lake_trusted_feegow.procedimentos pro on p.procedimento_id = pro.id
left join todos_data_lake_trusted_feegow.procedimentos_tipos pt on pro.tipo_procedimento_id = pt.id
left join todos_data_lake_trusted_feegow.procedimentos_grupos spg on spg.id = pro.grupo_procedimento_id 
left join todos_data_lake_trusted_feegow.unidades u on u.id = p.unidade_id 
where p.profissional_id in (508478, 260142)
and u.id = 19811

select * from todos_data_lake_trusted_feegow.pacientes
where cpf = '41042979847'


--------------------------------------------------------------------------------------------
-----------------------
--AMEI_APP_PROD.AGENDAMENTOS
select 
distinct 
ag.id,
ag."data",
ROUND(EXTRACT(HOUR FROM TO_TIMESTAMP(ag.hora, 'HH24:MI:SS')) +
	EXTRACT(MINUTE FROM TO_TIMESTAMP(ag.hora, 'HH24:MI:SS')) / 60.0 +
	EXTRACT(SECOND FROM TO_TIMESTAMP(ag.hora, 'HH24:MI:SS')) / 3600.0, 2) 
		as hora_inicio, --transformado em decimal
--ag.hora_termino, --realizar o calculo com o valor da grade do médico calculado la em cima
ag.is_encaixe as encaixe,
ag.is_retorno as retorno,
null as enviar_sms,
ag.valor as valor_total,
null as repeticao,
null as repeticao_periodicidade,
null as repeticao_quantidade,
null as repeticao_data_termino,
523 as clinica_id, --no futuro verificar a questão do id da unidade, fazer um depara
ag.paciente_id,
ag.profissional_id, 
ag.especialidade_id, 
case 
	when ag.status_id = 1 then 2
	when ag.status_id = 3 then 5
	when ag.status_id = 2 then 10
	when ag.status_id = 17 then 8
	when ag.status_id = 11 then 9
	when ag.status_id = 206 then 15
	when ag.status_id = 7 then 16
	when ag.status_id = 6 then 17
	when ag.status_id = 15 then 18	
end as status_agendamento_id, --criar case when para fazer o depara dos status --falta alguns agendamentos
sas.nome_status, --criar case when para fazer o depara do nome dos status
stp.id, --id da parceria cartão de todos
case
	when nome_tabela_particular = 'Cartão de TODOS*' then 'Cartão de TODOS'
	else 'Cartão de TODOS'
end as parceria, --cartão de todos --verificar sobre possíveis alterações
ag.convenio_id,
ag.canal_id, 
null as horario_id,
null as canal_origem_id,
null as canal_confirmacao_id,
ag.dhup as create_at,
ap.procedimento_id
from stg_agendamento_procedimentos ap
left join stg_agendamentos ag on ap.agendamento_id = ag.id
left join stg_tabelas_particulares stp on stp.id = ag.tabela_particular_id
left join stg_agendamento_status sas on sas.id = ag.status_id
left join stg_profissionais sp on sp.id = ag.profissional_id
left join stg_profissional_especialidades spe on spe.profissional_id = sp.id
left join stg_especialidades se on se.id = spe.especialidade_id
left join stg_pacientes p on p.id = ag.paciente_id
left join stg_sexo ss on ss.id = p.sexo
left join stg_agendamento_status ass on ag.status_id = ass.id
left join stg_especialidades es on ag.especialidade_id = es.id
left join stg_procedimentos pro on ap.procedimento_id = pro.id
left join stg_procedimentos_tipos pt on pro.tipo_procedimento_id = pt.id
left join stg_locais l on ap.local_id = l.id
left join stg_unidades u on l.unidade_id = u.id
where 1 = 1
and ag.profissional_id in (508478, 260142) --2 profissionais selecionados
and u.id = 19811 -- unidade Pirassununga
and ag.data between DATE('2023-12-04') and DATE('2030-12-31')
