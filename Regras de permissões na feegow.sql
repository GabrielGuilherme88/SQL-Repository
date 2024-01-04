--S (GTX)** ID srp.id = 22 perfil geral do usuário
--Call Center (Com TISS)** srp.id = 19 excelção de aplicação_perfil
--Query a ser utilizada
with exceção_de_aplicação_perfil as (
	select distinct su.id as id_usuario, sf.nome_funcionario, sf.cpf,
	u.nome_fantasia, u.regiao,
	srp.id as id_exceção_de_aplicação_perfil
	, srp.regra as exceção_de_aplicação_perfil, su.permissoes,
		case when srp.id = 19 then 'Call Center (Com TISS)**'
			when srp.id = 22 then 'S (GTX)**'
			else 'nulo'
		end as exceção_de_aplicação_perfil_asterisco__exceção_de_aplicação_perfil
	from stg_funcionarios sf
	left join stg_funcionarios_unidades sfu on sfu.funcionario_id = sf.id
	left join stg_unidades u on u.id = sfu.unidade_id
	left join stg_usuarios su on su.id_relativo = sf.id
	left join stg_usuarios_regras sur on sur.usuario = su.id
	left join stg_regras_permissoes srp on srp.id = sur.regra
	where sf.ativo = 'on' 
	--and sf.nome_funcionario = 'Gg Teste Callcenter'
),
perfil_geral_usuario as (
	select distinct  srp.id as id_perfil_geral_usuario, 
	su.id as id_usuario1, srp.regra as perfil_geral_usuario, 
	case when srp.id = 22 then 'S (GTX)**'
		when srp.id = 19 then 'Call Center (Com TISS)**'
		else 'nulo'
		end as exceção_de_aplicação_perfil_asterisco_perfil_geral_usuario
	from stg_funcionarios sf
	left join stg_usuarios su on su.id_relativo = sf.id
	left join stg_regras_permissoes srp on srp.id = su.regra_id_geral
	where sf.ativo = 'on'
	)
select * from exceção_de_aplicação_perfil
left join perfil_geral_usuario on id_usuario1 = id_usuario
where perfil_geral_usuario is not null
or exceção_de_aplicação_perfil is not null
--where perfil_geral_usuario in ('Gerente da Unidade (Com TISS)', 'Gerente da Unidade')
--where nome_funcionario = 'Gg Teste Callcenter'



--Agrupamento para veirifar as permissões existentes 
select count(*), srp.regra from stg_funcionarios sf
	left join stg_usuarios su on su.id_relativo = sf.id
	left join stg_regras_permissoes srp on srp.id = su.regra_id_geral
	where sf.ativo = 'on'
	group by srp.regra
	
select srp.regra, count(*)
	from stg_funcionarios sf
	left join stg_funcionarios_unidades sfu on sfu.funcionario_id = sf.id
	left join stg_unidades u on u.id = sfu.unidade_id
	left join stg_usuarios su on su.id_relativo = sf.id
	left join stg_usuarios_regras sur on sur.usuario = su.id
	left join stg_regras_permissoes srp on srp.id = sur.regra
	--where sf.ativo = 'on'
	group by srp.regra
	
	select regra, id,count(*) from stg_regras_permissoes
	group by regra, id
	
	select * from stg_unidades su 
	where su.email1 = ''