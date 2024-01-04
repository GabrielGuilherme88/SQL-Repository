------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
--PROFISSIONAIS
--pegar profissionais que em algum momento tiveram agendamentos dentro da unidade de pirassununga
--precisa ser profissionais com a especialidade escolhida
--trazer também uma tabela apartada das especialidades desses profissionais
-- Medicina da Família e Pediatria
--modelagem que alimenta a tabela 

--AMEI.PROD.PROFISSIONAIS
--para validação do profissional com a interface
with p as (
select	distinct 
	sp.id,
	sp.nome_profissional ,
	sp.nascimento,
	sp.cpf,
	sp.unidade_id,
	scp.descricao,
	spe.uf_conselho,
	e.nome_especialidade,
	spe.rqe,
	sp.sys_active,
	sp.sys_user ,
	sp.ativo,
	sp.observacoes ,
	uu.nome_fantasia ,
	ur.descricao as regional,
	date(sp.dhup) as dhup,
	sp.sys_date as sys_date,
	sf.nome_funcionario,
	su.tipo_usuario 
from
	stg_profissionais sp
left join stg_conselhos_profissionais scp on	scp.id = sp.conselho_id
left join stg_profissional_especialidades spe on	spe.profissional_id = sp.id
left join stg_especialidades e on	e.id = spe.especialidade_id
left join stg_profissionais_unidades puu on	puu.profissional_id = sp.id
left join stg_unidades uu on	uu.id = puu.unidade_id
left join stg_unidades_regioes ur on	ur.id = uu.regiao_id
left join stg_usuarios su on su.id = sp.sys_user
left join stg_funcionarios sf on sf.id = su.id_relativo
where 1 = 1
--and sp.cpf = 37387845867
and sp.sys_active = 1
)
select 
	case when LEFT(rqe, 3) like '%COM' then rqe end as "titulo",
	case when left(rqe, 3) not like '%COM' then rqe end as "rqe"
from p

select * from stg_conselhos_profissionais
limit 1

select * from stg_profissionais sp 
limit 1

select * from profi
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------

--pesquisar sobre exibir_na_agenda

--AMEI.PROD.PROFISSIONAIS --modelagem final
with profissionais as (
select
distinct 
sp.id,
null as tratamento, -- não achei
SPLIT_PART(sp.nome_profissional , ' ', 1) AS primeiro_nome,
TRIM(BOTH ' ' FROM SUBSTRING(sp.nome_profissional FROM POSITION(' ' IN sp.nome_profissional) + 1)) AS sobrenome,
sp.cpf,
ss.nomesexo as sexo,
null as rg, -- não achei
sp.documento_conselho as registro_profissional,
TO_TIMESTAMP(sp.nascimento, 'YYYY-MM-DD HH24:MI:SS') AT TIME ZONE 'UTC' as data_nascimento,
se.nome_especialidade as area_de_atuacao,
	case --condição que busca as três primeiras letras do rqe, caso seja COM busca o rqe, caso diferente de COM busca o rqe
		when LEFT(espe.rqe, 3) like '%COM' then espe.rqe end as "titulo",
	case 
		when left(espe.rqe, 3) not like '%COM' then espe.rqe end as "rqe",
'Profissional de nível superior' as Funcao,
scp.descricao as conselho,
espe.uf_conselho,
'Médico' as Profissão,
sp.email1 as email,
sp.celular1 as telefone_1,
sp.celular2 as telefone_2,
spe.cep,
spe.endereco,
spe.numero as number,
spe.complemento,
spe.bairro,
spe.cidade,
spe.estado,
null as observacao, -- não achei
null as convenio, -- não achei
null as exibir_na_agenda, -- não achei
null as responsavel_tecnico_clinica, -- não achei
sp.observacoes as mensagem_agenda,
sp.sys_active,
null as fotografia, -- não achei
null as token_memed, -- não achei
sp.sys_user as FK_USUARIO,
sp.sys_date as 	CREAT_AT,
null as FLG_MEMED_PDF, -- não achei
null as MIG_PROFISSIONAL_ID, -- não achei
sp.dhup as UPDATE_AT,
null as CNPJ -- não achei
from stg_profissionais sp 
left join stg_conselhos_profissionais scp on	scp.id = sp.conselho_id
left join stg_profissional_especialidades espe on	espe.profissional_id = sp.id
left join stg_especialidades se on	se.id = espe.especialidade_id
left join stg_profissionais_unidades spu on	spu.profissional_id = sp.id
left join stg_unidades su on	su.id = spu.unidade_id
left join stg_unidades_regioes sur on	sur.id = su.regiao_id
left join stg_profissional_enderecos spe on spe.profisional_id = sp.id
left join stg_sexo ss on ss.id = sp.sexo_id
where 1 = 1
and sp.ativo = 'on'
and sp.sys_active = 1
),
agendamento_prof as ( --objeto criado para buscar os agendamentos dos profissionais de AmorSaúde Pirassununga
select distinct ag.profissional_id as id_profissional_agendamento 
from stg_agendamento_procedimentos ap
left join stg_agendamentos ag on ap.agendamento_id = ag.id
left join stg_pacientes p on p.id = ag.paciente_id
left join stg_sexo ss on ss.id = p.sexo
left join stg_agendamento_status ass on ag.status_id = ass.id
left join stg_especialidades es on ag.especialidade_id = es.id
left join stg_procedimentos pro on ap.procedimento_id = pro.id
left join stg_procedimentos_tipos pt on pro.tipo_procedimento_id = pt.id
left join stg_locais l on ap.local_id = l.id
left join stg_unidades u on l.unidade_id = u.id
where pt.id in (2, 9)
--and ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
--and ag."data" between  '2020-01-01' and '2023-08-31'
--and p.sys_user <> 0 --filtra usuários que estão fora da interface feegow
--and p.sys_active = 1 --filtrar usuários ativos
and u.id = 19811 -- id AmorSaúde Pirassununga
)
select 
id,
primeiro_nome,
sobrenome,
data_nascimento,
sexo,
cpf,
registro_profissional,
area_de_atuacao,
rqe,
titulo,
funcao,
'Médico' as Profissao, --criado para atender ao campo do amei. no futuro fazer depara com a especialidade, para buscar outras profissões
conselho,
uf_conselho,
email,
telefone_1,
telefone_2,
cep,
endereco,
number,
complemento,
bairro,
cidade,
estado,
observacao, -- não achei
convenio, -- não achei
exibir_na_agenda, -- não achei
responsavel_tecnico_clinica, -- não achei
mensagem_agenda,
sys_active,
fotografia, -- não achei
token_memed, -- não achei
FK_USUARIO,
CREAT_AT,
FLG_MEMED_PDF, -- não achei
MIG_PROFISSIONAL_ID, -- não achei
UPDATE_AT,
CNPJ -- não achei,
from profissionais p
inner join agendamento_prof ap on ap.id_profissional_agendamento = p.id --inner criado para buscar profisionais que tiveram alguma agenda aberta na unidade
where 1 = 1
and p.id in (508478, 260142)

select * from stg_profissionais
limit 10


----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------


--PARCEIROS
--Não encontrei a referência dessa tabela
select * from stg_fornecedores sf 
where sf.nomefornecedor like 'Cartão%'
limit 100

select * from stg_tabelas_particulares stp 
where stp.nome_tabela_particular like 'Cartão'
limit 10

select * from tabela

----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------


--FUNCIONÁRIOS
--modelagem que irá alimentar a tabela 
--AMEI.PROD.FUNCIONARIOS
with funcionarios as (
select 
sf.id,
null as FK_UNIDADES_SETORES, -- há a possibilidade, porme´m existem N unidades para 1 funcionarios (cardinalidade)
null as FK_MUNICIPIO, -- não encontrei
sf.sys_user as FK_USUARIO, --verificar se está correto
sf.sexo_id as FK_SEXO,
sf.cpf as CPF,
null as RG, -- não encontrei
case --condição apra tentar arrumar o primeiro nome como GTX
	when SPLIT_PART(sf.nome_funcionario  , ' ', 1) = 'Gtx' then SPLIT_PART(sf.nome_funcionario  , ' ', 2) 
	else SPLIT_PART(sf.nome_funcionario  , ' ', 1)
end as primeiro_nome,
TRIM(BOTH ' ' FROM SUBSTRING(sf.nome_funcionario FROM POSITION(' ' IN sf.nome_funcionario) + 1)) AS sobrenome,
TO_TIMESTAMP(sf.nascimento, 'YYYY-MM-DD HH24:MI:SS') AT TIME ZONE 'UTC' as data_nascimento,
sf.setor_colaborador as OBSERVACAO,
sf.celular as CELULAR,
sf.email as EMAIL,
sfe.cep as CEP,
sfe.endereco as ENDERECO,
sfe.numero as NUMERO,
sfe.complemento as COMPLEMENTO,
sfe.bairro as BAIRRO,
null as IP_CLIENTE,
null as CREAT_AT,
sf.dhup as UPDATE_AT,
sf.sys_active as FLG_ATIVO,
null as create_BY,
null as LAST_USER,
CASE --cria o setor a partir das informações de regra de permissão dentro da feegow
        WHEN position('(' IN srp.regra) > 0 AND position(')' IN srp.regra) > 0
        THEN trim(substring(srp.regra FROM 1 FOR position('(' IN srp.regra) - 1))
        ELSE srp.regra
    	END AS setor,
'Franquia - Recepção/Pós-Consulta' as perfil_de_acesso, 
case --cria a coluna funcao
	when sf.cargo_colaborador_unidade is null then 'analista' --foi criado
		else sf.cargo_colaborador_unidade
end as funcao,
null as FOTO,
case when 
	sf.ativo = 'on' then 'A'
	else 'I'
end as STATUS
from stg_funcionarios sf 
left join stg_funcionario_enderecos sfe on sfe.funcionario_id = sf.id 
left join stg_funcionarios_unidades sfu on sfu.funcionario_id = sf.id 
left join stg_usuarios su on su.id_relativo = sf.id
left join stg_regras_permissoes srp on srp.id = su.regra_id_geral
where 1 = 1
and sfu.unidade_id = 19811 --filtrando apenas a unidade de Pirassununga 
),
agendamento_func as (
select distinct fun.id as func_id_ag
from stg_agendamento_procedimentos ap
left join stg_agendamentos ag on ap.agendamento_id = ag.id
left join stg_pacientes p on p.id = ag.paciente_id
left join stg_sexo ss on ss.id = p.sexo
left join stg_agendamento_status ass on ag.status_id = ass.id
left join stg_especialidades es on ag.especialidade_id = es.id
left join stg_procedimentos pro on ap.procedimento_id = pro.id
left join stg_procedimentos_tipos pt on pro.tipo_procedimento_id = pt.id
left join stg_locais l on ap.local_id = l.id
left join stg_unidades u on l.unidade_id = u.id
left join stg_usuarios usu on ag.usuario_id = usu.id --adicionando o funcionario
left join stg_funcionarios fun on usu.id_relativo = fun.id --adicionando o funcionario
where pt.id in (2, 9)
--and ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
--and ag."data" between  '2020-01-01' and '2023-08-31'
--and p.sys_user <> 0 --filtra usuários que estão fora da interface feegow
--and p.sys_active = 1 --filtrar usuários ativos
and u.id = 19811 -- id AmorSaúde Pirassununga
)
select * from funcionarios f1
where 1 = 1
--and f1.id in (select func_id_ag from agendamento_func)


----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------

--CLIENTES (PACIENTES?)
--prontuário é o mesmo di do paciente? ou é o documento_id? 
--AMEI_APP_PROD.PACIENTES
with pacientes as (
select sp.id, --é o prontuário
sp.sys_active as ativo,
null as obito,
sp.id as prontuario, -- é o ID do paciente
sp.cpf,
SPLIT_PART(sp.nome_paciente  , ' ', 1) AS primeiro_nome,
TRIM(BOTH ' ' FROM SUBSTRING(sp.nome_paciente FROM POSITION(' ' IN sp.nome_paciente) + 1)) AS sobrenome,
sp.nome_paciente as nome_social,
null as rg,
TO_TIMESTAMP(sp.nascimento, 'YYYY-MM-DD HH24:MI:SS') AT TIME ZONE 'UTC' as data_nascimento,
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
sp.sys_date as created_at,
sp.dhup,
sp.sexo as sexo_id,
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
null as last_attendance_data
from stg_pacientes sp
left join stg_paciente_endereco spe on spe.paciente_id = sp.id
left join stg_paciente_convenio spc on spc.paciente_id = sp.id
left join stg_tabelas_particulares stp on stp.id = sp.tabela_id
where sp.sys_active = 1 --apenas ativos
),
agenda_paciente as ( --objeto criado para buscar os agendamentos dos  pacientes amorsaúde.
select distinct ag.paciente_id as idpaciente 
from stg_agendamento_procedimentos ap
left join stg_agendamentos ag on ap.agendamento_id = ag.id
left join stg_pacientes p on p.id = ag.paciente_id
left join stg_sexo ss on ss.id = p.sexo
left join stg_agendamento_status ass on ag.status_id = ass.id
left join stg_especialidades es on ag.especialidade_id = es.id
left join stg_procedimentos pro on ap.procedimento_id = pro.id
left join stg_procedimentos_tipos pt on pro.tipo_procedimento_id = pt.id
left join stg_locais l on ap.local_id = l.id
left join stg_unidades u on l.unidade_id = u.id
where pt.id in (2, 9)
--and ag.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
--and ag."data" between  '2020-01-01' and '2023-08-31'
--and p.sys_user <> 0 --filtra usuários que estão fora da interface feegow
and p.sys_active = 1 --filtrar usuários ativos
and u.id = 19811 -- id AmorSaúde Pirassununga
)
select *
from pacientes p
where 1 = 1
and p.id in (select idpaciente from agenda_paciente)
--and id = 67374106

--cpf para olhar na feegow 35480589814 matricula = siemaco

select * from stg_pacientes sp 
limit 1

select * from stg_tabelas_particulares stp 
limit 10




--quantidade de cartão
SELECT
  count(*) AS total_linhas,
  case
    when stp.nome_tabela_particular <> 'Cartão de TODOS*' then 'restante'
    else 'Cartão de TODOS'
  end as restante,
  (count(*) * 100.0) / sum(count(*)) OVER () AS percentual_por_linha
FROM stg_pacientes sp
LEFT JOIN stg_paciente_convenio spc ON spc.paciente_id = sp.id
LEFT JOIN stg_tabelas_particulares stp ON stp.id = sp.tabela_id
WHERE 1 = 1
and sp.sys_active = 1
group by
  case
    when stp.nome_tabela_particular <> 'Cartão de TODOS*' then 'restante'
    else 'Cartão de TODOS'
end


----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
--AMEI GRADE DOS PROFISSIONAIS
--grade fixa
--AMEI_APP_PROD.HORARIOS
with grade_fixa as (
select 
sgf.id,
sgf.dia_semana,
sgf.hora_de,
sgf.hora_ate,
sgf.profissionalid,
sgf.localid,
sgf.intervalo,
sgf.compartilhada,
sgf.especialidades,
sgf.procedimentos,
sgf.convenios,
--sgf.tipograde,
sgf.maximo_retornos,
sgf.maximo_encaixes,
sgf.inicio_vigencia,
sgf.fim_vigencia,
--sgf.frequencia_semanas ,
--sgf.horarios,
sgf.datahora,
sgf.sys_user,
sgf.mensagem,
sgf.dhup,
--sgf.observacao,
u.id as id_unidade
from
	stg_grade_fixa sgf
left join stg_profissionais sp on sp.id = sgf.profissionalid
left join stg_locais l on sgf.localid = l.id
left join stg_unidades u on l.unidade_id = u.id
where
	1 = 1
	and sp.sys_active = 1
	and sp.ativo = 'on'
	and sgf.inicio_vigencia between current_date - 30 and date('2030-12-31') --regras de janela de temp
	and sgf.fim_vigencia between current_date -30 and date('2030-12-31') --regras de janela de tempo
	and u.id = 19811 --unidade Pirassununga
	--and sp.id in (508478, 260142)
	),
consolida_grade_fixa as ( --objeto que cria condições e tratamentos para que as colunas sejam identicas ao o AMEI
select 
id,
dia_semana as dia,
case --add para criar uma condição para alterar o horário para ficar próximo ao do AMEI, que é um campo de selecionar.
	when intervalo < 10 then 5
	when intervalo = 10 then 10
	when intervalo between 10 and  15 then 15
	when intervalo between 15 and 20 then 20
	when intervalo between 20 and 25 then 25
	when intervalo between 25 and 30 then 30
	when intervalo between 30 and 35 then 35
	when intervalo between 35 and 40 then 40
	when intervalo between 40 and 45 then 45
	when intervalo between 45 and 50 then 50
	when intervalo between 50 and 55 then 55
	when intervalo = 60 then 60
end as tempo,
'Consultório' as Local,
	ROUND(EXTRACT(HOUR FROM TO_TIMESTAMP(hora_de, 'HH24:MI:SS')) +
	EXTRACT(MINUTE FROM TO_TIMESTAMP(hora_de, 'HH24:MI:SS')) / 60.0 +
	EXTRACT(SECOND FROM TO_TIMESTAMP(hora_de, 'HH24:MI:SS')) / 3600.0, 2) 
		as hora_inicio,	
	ROUND(EXTRACT(HOUR FROM TO_TIMESTAMP(hora_ate, 'HH24:MI:SS')) +
	EXTRACT(MINUTE FROM TO_TIMESTAMP(hora_ate, 'HH24:MI:SS')) / 60.0 +
	EXTRACT(SECOND FROM TO_TIMESTAMP(hora_ate, 'HH24:MI:SS')) / 3600.0, 2) 
		as hora_termino,
	TO_TIMESTAMP(inicio_vigencia, 'YYYY-MM-DD HH24:MI:SS') AT TIME ZONE 'UTC' AT TIME ZONE 'UTC'
		as dia_inicio,
	TO_TIMESTAMP(fim_vigencia, 'YYYY-MM-DD HH24:MI:SS') AT TIME ZONE 'UTC' AT TIME ZONE 'UTC'
		as dia_termino,
0 as deletado,
null as agenda_oline,
null as tempo_online,
maximo_retornos as max_retornos,
maximo_encaixes as max_encaixaes,
null as max_encaixes_dia,
null as max_encaixes_dia_hora,
null as min_tempo_encaixes,
case when compartilhada = 'S' then 1 else 0
end as compartilha_grade,
localid as local_id,
profissionalid as profissional_id,
id_unidade as clinica_id,
sys_user as usuario_id,
datahora as creat_at,
dhup as update_at
from grade_fixa
),
grade_periodo as (
select 
sgf.id,
sgf.datahora,
sgf.hora_de,
sgf.hora_ate,
sgf.profissional_id,
sgf.local_id,
sgf.intervalo,
sgf.compartilhar,
sgf.especialidades,
sgf.procedimentos,
sgf.convenios,
--sgf.tipograde,
sgf.maximo_retornos,
sgf.maximo_encaixes,
sgf.data_de,
sgf.data_ate,
--sgf.frequencia_semanas ,
--sgf.horarios,
sgf.sys_user,
sgf.mensagem,
sgf.dhup,
--sgf.observacao,
u.id as id_unidade
from
	stg_grade_periodo sgf
left join stg_profissionais sp on sp.id = sgf.profissional_id
left join stg_locais l on sgf.local_id = l.id
left join stg_unidades u on l.unidade_id = u.id
where
	1 = 1
	and sp.sys_active = 1
	and sp.ativo = 'on'
	and sgf.data_de between current_date - 30 and date('2030-12-31') --regras de janela de temp
	and sgf.data_ate between current_date -30 and date('2030-12-31') --regras de janela de tempo
	and u.id = 19811 --unidade Pirassununga
	--and sp.id in (508478, 260142) --filtrando os profissionais
), 
consolida_grade_periodo as ( --objeto que cria condições e tratamentos para que as colunas sejam identicas ao o AMEI
select 
id,
0 dia, --filtro da tabela do AMEI, coluna DIA = 0 entende-se que é uma grade_periodo
case --add para criar uma condição para alterar o horário para ficar próximo ao do AMEI, que é um campo de selecionar.
	when intervalo < 10 then 5
	when intervalo = 10 then 10
	when intervalo between 10 and  15 then 15
	when intervalo between 15 and 20 then 20
	when intervalo between 20 and 25 then 25
	when intervalo between 25 and 30 then 30
	when intervalo between 30 and 35 then 35
	when intervalo between 35 and 40 then 40
	when intervalo between 40 and 45 then 45
	when intervalo between 45 and 50 then 50
	when intervalo between 50 and 55 then 55
	when intervalo = 60 then 60
end as tempo,
'Consultório' as Local,
	ROUND(EXTRACT(HOUR FROM TO_TIMESTAMP(hora_de, 'HH24:MI:SS')) +
	EXTRACT(MINUTE FROM TO_TIMESTAMP(hora_de, 'HH24:MI:SS')) / 60.0 +
	EXTRACT(SECOND FROM TO_TIMESTAMP(hora_de, 'HH24:MI:SS')) / 3600.0, 2) 
		as hora_inicio,	
	ROUND(EXTRACT(HOUR FROM TO_TIMESTAMP(hora_ate, 'HH24:MI:SS')) +
	EXTRACT(MINUTE FROM TO_TIMESTAMP(hora_ate, 'HH24:MI:SS')) / 60.0 +
	EXTRACT(SECOND FROM TO_TIMESTAMP(hora_ate, 'HH24:MI:SS')) / 3600.0, 2) 
		as hora_termino,
	TO_TIMESTAMP(data_de, 'YYYY-MM-DD HH24:MI:SS') AT TIME ZONE 'UTC' AT TIME ZONE 'UTC'
		as dia_inicio,
	TO_TIMESTAMP(data_ate, 'YYYY-MM-DD HH24:MI:SS') AT TIME ZONE 'UTC' AT TIME ZONE 'UTC'
		as dia_termino,
0 as deletado,
null as agenda_oline,
null as tempo_online,
maximo_retornos as max_retornos,
maximo_encaixes as max_encaixaes,
null as max_encaixes_dia,
null as max_encaixes_dia_hora,
null as min_tempo_encaixes,
case when compartilhar = 'S' then 1 else 0
end as compartilha_grade,
local_id as local_id,
profissional_id as profissional_id,
id_unidade as clinica_id,
sys_user as usuario_id,
datahora as creat_at,
dhup as update_at
from grade_periodo
) 
select * from consolida_grade_fixa --informações de grade_fixa
where 1 = 1
and profissional_id in (508478, 260142) --filtrandso david e marcela
union all
select * from consolida_grade_periodo --informações de grade_periodo
where 1 = 1
and profissional_id in (508478, 260142) --filtrandso david e marcela
--consolida tudo em um union all, pois a tabela que aliemnta o AMEI é única, diferente da feegow que são duas
--entendimento da regra é que, a coluna dias = 0 entende-se que é uma grade_periodo, enquanto caso haja dias da semana, é uma grade_fixa




----verificar se é possível trazer os agendamentosa dentro da grade
--existe o id_profissional para buscar a grade
select * 
from stg_agendamento_procedimentos ap
left join stg_agendamentos ag on ap.agendamento_id = ag.id
left join stg_pacientes p on p.id = ag.paciente_id
left join stg_sexo ss on ss.id = p.sexo
left join stg_agendamento_status ass on ag.status_id = ass.id
left join stg_especialidades es on ag.especialidade_id = es.id
left join stg_procedimentos pro on ap.procedimento_id = pro.id
left join stg_procedimentos_tipos pt on pro.tipo_procedimento_id = pt.id
left join stg_locais l on ap.local_id = l.id
left join stg_unidades u on l.unidade_id = u.id
and ag.profissional_id in (508478, 260142)
limit 100




----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
--BLOQUEIO
--AMEI_APP_PROD.BLOQUEIO_AGENDA
with bloq as (
select 
sab.id,
sab.titulo,
TO_TIMESTAMP(datade, 'YYYY-MM-DD HH24:MI:SS') AT TIME ZONE 'UTC' AT TIME ZONE 'UTC'
		as data_inicio,
TO_TIMESTAMP(dataa, 'YYYY-MM-DD HH24:MI:SS') AT TIME ZONE 'UTC' AT TIME ZONE 'UTC'
		as data_fim,
ROUND(EXTRACT(HOUR FROM TO_TIMESTAMP(sab.horade, 'HH24:MI:SS')) +
	EXTRACT(MINUTE FROM TO_TIMESTAMP(sab.horade, 'HH24:MI:SS')) / 60.0 +
	EXTRACT(SECOND FROM TO_TIMESTAMP(sab.horade, 'HH24:MI:SS')) / 3600.0, 2) 
		as hora_inicio,	
	ROUND(EXTRACT(HOUR FROM TO_TIMESTAMP(sab.horaa, 'HH24:MI:SS')) +
	EXTRACT(MINUTE FROM TO_TIMESTAMP(sab.horaa, 'HH24:MI:SS')) / 60.0 +
	EXTRACT(SECOND FROM TO_TIMESTAMP(sab.horaa, 'HH24:MI:SS')) / 3600.0, 2) 
		as hora_fim,
	EXTRACT(DOW FROM TO_TIMESTAMP(sab.data, 'DD/MM/YYYY HH24:MI:SS'))
		AS dia_da_semana,
sab.descricao,
sab.dhup as data_alteracao,
null as provisorio,
sab.profissionalid as profissional_id,
sab.unidades,
TRIM(REGEXP_SUBSTR(sab.unidades, '[^|]+', 1)) as uni --criado para separar os id das unidades e retirar o ||
from stg_agenda_bloqueios sab 
)
select 
id,
data_inicio,
data_fim,
hora_inicio,
hora_fim,
dia_da_semana,
titulo,
descricao,
data_alteracao,
provisorio,
profissional_id
from bloq
where 1 = 1
and uni = '19811' --com aspa, pois o TRIM retornou como varchar0

--faltou descriminar os profissionais david e marcela
--base de agendamento na grade (não estava na planilha) quem é que está agendado?
-- abrir as grades e ver se ha agendamentos aberto
--1 linha de dados para cada parte do script
--funcionarios trazer a unidade e a regional

select * from stg_agenda_bloqueios sab
limit 10





----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
--AMEI_APP_PROD.PARCEIROS

select * 
from stg_procedimentos_tabelas_precos ptp
left join stg_procedimentos_tabelas_precos_unidades ptpu on
	ptpu.procedimento_tabela_preco_id = ptp.id
left join stg_unidades u on
	ptpu.unidade_id = u.id
--left join stg_procedimentos_tabelas_precos_valores ptpv on
	--ptpv.tabelaid = ptp.id
--left join stg_procedimentos pro on
	--ptpv.procedimentoid = pro.id
--left join stg_procedimentos_tipos spt on
	--spt.id = pro.tipo_procedimento_id
where 1 = 1
and u.id = 19811
and ptp.nometabela like 'Cartão de TODOS%'


select regexp_replace(sp.celular, '[^0-9]', '') AS numero_telefone   
from stg_pacientes sp 
--where sp.id = 16494914



----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------

--origem_id do paciente e a tabela que descreve --tabela separada
--resolvido através do datalake

--procedimento da especialidade de agenda
--criar hora_termino
with hora as ( --objeto criado para somar os minutos a mais na hora do agendamento
select sa.id as idagendamento, 
TO_CHAR(TO_TIMESTAMP(sa.hora, 'HH24:MI:SS') + INTERVAL '10 minutes', 'HH24:MI:SS') AS hora_modificada
from stg_agendamentos sa
)
select 
distinct 
ag.id,
ag."data",
ROUND(EXTRACT(HOUR FROM TO_TIMESTAMP(ag.hora, 'HH24:MI:SS')) +
	EXTRACT(MINUTE FROM TO_TIMESTAMP(ag.hora, 'HH24:MI:SS')) / 60.0 +
	EXTRACT(SECOND FROM TO_TIMESTAMP(ag.hora, 'HH24:MI:SS')) / 3600.0, 2) 
		as hora_inicio, --transformado em decimal
ROUND(EXTRACT(HOUR FROM TO_TIMESTAMP(h.hora_modificada, 'HH24:MI:SS')) +
	EXTRACT(MINUTE FROM TO_TIMESTAMP(h.hora_modificada, 'HH24:MI:SS')) / 60.0 +
	EXTRACT(SECOND FROM TO_TIMESTAMP(h.hora_modificada, 'HH24:MI:SS')) / 3600.0, 2) 
		as hora_termino, --transformado em decimal
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
--ag.especialidade_id, --retirado para o case when substituir
case 
	when ag.especialidade_id is null then 318 
	else ag.especialidade_id
	end as especialidade_id,
case 
	when se.nome_especialidade is null then 'Pediatria'
	else se.nome_especialidade
end as nome_especialidade,
--se.nome_especialidade, --retirado para incluir o case when
case --necessário realizar um depara dos status de agendamento
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
stp.id as parceria_id, --trazer o ID do cartão do AMEI
case
	when stp.nome_tabela_particular = 'Cartão de TODOS*' then 'Cartão de TODOS'
	else 'Cartão de TODOS'
end as parceria, --cartão de todos --verificar sobre possíveis alterações
ag.convenio_id,
ag.canal_id, 
sac.nome_canal, 
null as horario_id,
sp2.origem_id as canal_origem_id, --canal_id --origem_id buscar na feegow dentro da tabela de pacientes
null as canal_confirmacao_id,
ag.dhup as create_at,
ap.procedimento_id,
pro.nome_procedimento
from stg_agendamento_procedimentos ap
left join stg_agendamentos ag on ap.agendamento_id = ag.id
left join stg_pacientes sp2 on sp2.id = ag.paciente_id 
left join stg_tabelas_particulares stp on stp.id = ag.tabela_particular_id
left join stg_agendamento_status sas on sas.id = ag.status_id
left join stg_agendamento_canais sac on sac.id = ag.canal_id 
left join stg_profissionais sp on sp.id = ag.profissional_id
left join stg_profissional_especialidades spe on spe.profissional_id = sp.id
left join stg_especialidades se on se.id = ag.especialidade_id 
left join stg_pacientes p on p.id = ag.paciente_id
left join stg_sexo ss on ss.id = p.sexo
left join stg_agendamento_status ass on ag.status_id = ass.id
left join stg_especialidades es on ag.especialidade_id = es.id
left join stg_procedimentos pro on ap.procedimento_id = pro.id
left join stg_procedimentos_tipos pt on pro.tipo_procedimento_id = pt.id
left join stg_locais l on ap.local_id = l.id
left join stg_unidades u on l.unidade_id = u.id
left join hora h on idagendamento = ag.id
where 1 = 1
and ag.profissional_id in (508478, 260142) --2 profissionais selecionados
and u.id = 19811 -- unidade Pirassununga
and ag.data between '2023-12-04' and '2030-12-31'

select * from stg_agendamentos sa 
where sa.id = 866506863
limit 100




--TABELA CORRETA DA AGENDA DO PROFISSIONAL
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
from stg_procedimentos_profissional_unidade p
left join stg_profissionais pp on pp.id = p.profissional_id 
left join stg_procedimentos pro on p.procedimento_id = pro.id
left join stg_procedimentos_tipos pt on pro.tipo_procedimento_id = pt.id
left join stg_procedimentos_grupos spg on spg.id = pro.grupo_procedimento_id 
left join stg_unidades u on u.id = p.unidade_id 
where p.profissional_id in (508478, 260142)
and u.id = 19811
limit 1000

----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
