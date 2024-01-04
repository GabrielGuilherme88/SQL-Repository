 select count(*) from (
 select
	                            distinct tabela_leads.* from
	                            (
			                            select
                                            regexp_replace(upper(trim(p.nome_paciente)), '\s*[^a-zA-Z -]+\s*', '') as Nome_Paciente,
                                            case 
                                                when 
                                                (
                                                    regexp_like(replace(regexp_replace(lower(p.email),'([\p{Punct}&&[^@._-]])',''),' ',''),
                                                                 '(?:[a-z0-9!#$%&''*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&''*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])')
                                                and lower(p.email) like '%@%.%'
                                                and lower(p.email) not like '%---%'
                                                and lower(p.email) not like '%...%'
                                                and lower(p.email) not like '%hhh%'
                                                and lower(p.email) not like '%xxx%'
                                                and lower(p.email) not like '%wwww%'        
                                                and lower(p.email) not like '%123@.com%'
                                                and lower(p.email) not like '%n%o%soube%'
                                                and lower(p.email) not like '%n%o%tem%'
                                                and lower(p.email) not like '%n%o%existe%'
                                                and lower(p.email) not like '%sem@sem%'
                                                and lower(p.email) not like '%n%o@tem%'
                                                and lower(p.email) not like '%@n%otem%'
                                                and lower(p.email) not like '%0@0%'
                                                and lower(p.email) not like '%nao@nao%'
                                                and lower(p.email) not like '%naaotem%'
                                                and lower(p.email) not like '%nada%nada%'
                                                and lower(p.email) not like '%nada%gmail%'
                                                and lower(p.email) not like '%gmail%gmail%'
                                                and lower(p.email) not like '%nao tem%'
                                                and lower(p.email) not like '%nao.tem%'
                                                and lower(p.email) not like '%sem%email%'
                                                and lower(p.email) not like '%n@n.com%'
                                                and lower(p.email) not like '%n%o%tenho%'
                                                and lower(p.email) not like '%n%o%inform%'
                                                and lower(p.email) not like '%email%'
                                                and lower(p.email) not like '%n%o%possui%'
                                                and lower(p.email) not like '%sem%email%'
                                                and lower(p.email) not like '%nao@%'
                                                and lower(p.email) not like '%@nao%'
                                                and lower(p.email) not like '%n@n%'
                                                and lower(p.email) not like '%@.com%'
                                                and lower(p.email) not like '%informado%'
                                                and lower(p.email) not like '%informou%'
                                                and lower(p.email) not like '%0000%'
                                                and lower(p.email) not like '%ni.com.br%'
                                                )
                                                then
                    	                            replace(regexp_replace(lower(p.email),'([\p{Punct}&&[^@._-]])',''),' ','')
                                                else
                    	                            null
                                            end                           
                                            as Email, 
                                            case
                                                when 
                                                (
                                                    length( replace(replace(replace(replace(replace(replace(p.celular, '(', ''), ')', ''), ' ', ''), '-', ''), '+', ''), '_', '') ) >= 10
                                                and p.celular not like '%000%000%'
                                                and p.celular not like '%111%111%'
                                                and p.celular not like '%222%222%'
                                                and p.celular not like '%333%333%'
                                                and p.celular not like '%444%444%'
                                                and p.celular not like '%555%555%'
                                                and p.celular not like '%666%666%'
                                                and p.celular not like '%777%777%'
                                                and p.celular not like '%888%888%'
                                                and p.celular not like '%999%999%'
                                                and p.celular not like '%0123456%'
                                                and p.celular not like '%1234567%'
                                                and p.celular not like '%2345678%'
                                                and p.celular not like '%3456789%'
                                                )
                                                then
	                                                replace(replace(replace(replace(replace(replace(p.celular, '(', ''), ')', ''), ' ', ''), '-', ''), '+', ''), '_', '') 
                                                else
	                                                null
                                            end    
                                            as Celular,
                                            case 
                                                when 
                                                    p.cpf <> '99199299394' or p.cpf not like '%00000000%' 
                                                then 
                                                    p.cpf
                                                else
                                                    null
                                            end               
                                            as CPF,
                                            p.nascimento as Nascimento,
                                            case 
                                                when p.estado_civil_id = 1 then 'Casado'
                                                when p.estado_civil_id = 2 then 'Solteiro'
                                                when p.estado_civil_id = 3 then 'Divorciado'
                                                when p.estado_civil_id = 4 then 'Viúvo'
                                                else null
                                            end as EstadoCivil,
                                            p.sexo as Genero,
                                            case 
                                                when replace(pe.cep,'-','') <> '00000000'
                                                then replace(pe.cep,'-','')
                                                else null
                                            end                                         
                                            as Cep,
                                            case
                                            	when    regexp_replace(replace(pe.logradouro,' ',''), '\s*[^0-9]+\s*', '') like '0%' 
                                            	     or regexp_replace(replace(pe.logradouro,' ',''), '\s*[^0-9]+\s*', '') like '11%' 
                                            	     or upper(trim(pe.logradouro)) like '%AAA%'
                                            	     or upper(trim(pe.logradouro)) like '%XXX%'
                                            	     or upper(trim(pe.logradouro)) like '%ZZZ%'
                                            	     or upper(trim(pe.logradouro)) like '%TTT%'
                                            	     or upper(trim(pe.logradouro)) like '%WWW%'
                                            	     or upper(trim(pe.logradouro)) like '%FFF%'
                                            	     or length(trim(pe.logradouro)) < 4 
                                            	     or length(regexp_replace(replace(pe.logradouro,' ',''), '\s*[^a-zA-Z]+\s*', '')) = 0
                                            	then ''
                                            	else upper(trim(pe.logradouro))
                                            end                                        
                                            as Logradouro,
                                            case
                                            	when    
                                            			regexp_replace(replace(pe.bairro,' ',''), '\s*[^0-9]+\s*', '') like '0%' 
                                            	     or regexp_replace(replace(pe.bairro,' ',''), '\s*[^0-9]+\s*', '') like '11%' 
                                            	     or upper(trim(pe.bairro)) like '%AAA%'
                                            	     or upper(trim(pe.bairro)) like '%XXX%'
                                            	     or upper(trim(pe.bairro)) like '%ZZZ%'
                                            	     or upper(trim(pe.bairro)) like '%TTT%'
                                            	     or upper(trim(pe.bairro)) like '%WWW%'
                                            	     or upper(trim(pe.bairro)) like '%FFF%'
                                            	     or length(trim(pe.bairro)) < 3
                                            	     or length(regexp_replace(replace(pe.bairro,' ',''), '\s*[^a-zA-Z]+\s*', '')) = 0
                                            	then ''
                                            	else upper(trim(pe.bairro))
                                            end                                        
                                            as Bairro,
                                            case 
                                                when 
	                                                length(regexp_replace(replace(pe.numero,' ',''), '\s*[^0-9]+\s*', '')) = 0 or length(regexp_replace(replace(pe.numero,' ',''), '\s*[0-9]+\s*', '')) > 1 or length(regexp_replace(replace(pe.numero,' ',''), '\s*[^0-9]+\s*', '')) > 6
                                                then ''
                                                else 
                                                	case 
                                                		when cast(regexp_replace(replace(pe.numero,' ',''), '\s*[^0-9]+\s*', '') as bigint) <= 1 
                                                		then ''
                                                		else replace(pe.numero,' ','') 
                                                	end
                                            end                                      
                                            as Numero,
                                            case 
	                                            when 
	                                            	length(regexp_replace(replace(pe.complemento,' ',''), '\s*[^a-zA-Z]+\s*', '')) = 0
	                                            	or length(trim(pe.complemento)) < 4
                                            	then ''
                                            	else upper(trim(pe.complemento)) 
                                            end                                        
                                            as Complemento,
                                            case 
                                                when 
                                                	length(upper(pe.cidade)) <= 3 and pe.cidade not in ('AÇU', 'ACU', 'EXU', 'ICO', 'ICÓ', 'IPE', 'IPÊ', 'IPU', 'ITA', 'ITÁ', 'ITU', 'JAU', 'JAÚ', 'LUZ', 'POA', 'POÁ', 'UBA', 'UBÁ', 'UNA', 'URU')
                                                	or upper(trim(pe.cidade)) like '%AAA%'
                                            	    or upper(trim(pe.cidade)) like '%XXX%'
                                            	    or upper(trim(pe.cidade)) like '%ZZZ%'
                                            	    or upper(trim(pe.cidade)) like '%TTT%'
                                            	    or upper(trim(pe.cidade)) like '%WWW%'
                                            	    or upper(trim(pe.cidade)) like '%FFF%'
                                                	or length(regexp_replace(replace(pe.cidade,' ',''), '\s*[^a-zA-Z]+\s*', '')) = 0
                                                then ''
                                                else upper(pe.cidade)
                                            end                                       
                                            as Cidade,
                                            case 
                                                when upper(pe.estado) not in ('AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO')
                                                then '' 
                                                else upper(pe.estado)
                                            end                                
                                            as Estado,
                                            a.sys_date as DataAgendamento,
                                            a.data as DataMarcacao,  	
                                            l.unidade_id as idClinica, 
                                            u.nome_unidade as NomeClinica, 
                                            tp.nome_tabela_particular as Convenio,
                                            ast.nome_status as StatusAgenda,
                                            a.id as IdAgendamento,
                                            u.cep as CepClinica,
                                            u.cidade as CidadeClinica,
                                            u.estado as EstadoClinica
                                            from 
                                                todos_data_lake_trusted_feegow.agendamentos a
                	                        join
	                	                        (--alteração dos atendidos
													select a.id
													from todos_data_lake_trusted_feegow.agendamento_procedimentos ap
												left join todos_data_lake_trusted_feegow.agendamentos a on ap.agendamento_id = a.id
												left join todos_data_lake_trusted_feegow.agendamento_status ass on a.status_id = ass.id
												left join todos_data_lake_trusted_feegow.especialidades es on a.especialidade_id = es.id
												left join todos_data_lake_trusted_feegow.procedimentos pro on ap.procedimento_id = pro.id
												left join todos_data_lake_trusted_feegow.procedimentos_tipos pt on pro.tipo_procedimento_id = pt.id
												left join todos_data_lake_trusted_feegow.tabelas_particulares tp on a.tabela_particular_id = tp.id and (upper(tp.nome_tabela_particular) not like 'CART%O%DE%TODOS%' and upper(tp.nome_tabela_particular) not like '%TUTTI%')
													where pt.id in (2, 9)
													--and a.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
													and a."data" between date('2023-07-01') and date('2023-07-31')
													) atendidos										
											on atendidos.id = a.id --ambos os joins com regra de negócio batem --53212 registros
                                            join
                	                            (
                		                            select max(id) as id, paciente_id 
                		                            from todos_data_lake_trusted_feegow.agendamentos a
                		                            where 
                                                        --year(date("data")) = {ano} and month(date("data")) = {mes}
                		                         a."data" between date('2023-07-01') and date('2023-07-31')
                		                          group by paciente_id
                	                            ) pa
                	                            on pa.id = a.id --aproximadamente 20 mil registros a menos com esse join
                	                        join
                	                        	todos_data_lake_trusted_feegow.agendamento_status ast 
                	                        	on ast.id = a.status_id 
                                            join
                                                todos_data_lake_trusted_feegow.tabelas_particulares tp
                                                on a.tabela_particular_id = tp.id
                                                and (upper(tp.nome_tabela_particular) not like 'CART%O%DE%TODOS%' and upper(tp.nome_tabela_particular) not like '%TUTTI%')
                                            join
                                                todos_data_lake_trusted_feegow.pacientes p
                                                on a.paciente_id = p.id
                                            left join
                                                todos_data_lake_trusted_feegow.paciente_endereco pe
                                                on p.id = pe.paciente_id
                                            join
                	                            todos_data_lake_trusted_feegow.locais l
                	                            on l.id = a.local_id 
                                            join 
					                            todos_data_lake_trusted_feegow.unidades u 
					                            on u.id = l.unidade_id 
                                            where
                                                --year(date(a."data")) = {ano} and month(date(a."data")) = {mes}
                                            a."data" between date('2023-07-01') and date('2023-07-31')
                                            order by a.id desc
	                            ) tabela_leads
                            where
                                (Nascimento is not null and (year(current_date) - year(Nascimento) >= 18 and year(current_date) - year(Nascimento) < 120) )
                                and
                                (Cpf <> '' and Cpf is not null)
                                and
                                (
	                                (Email <> '' and Email is not null) or 
	                                (Celular <> '' and Celular is not null)      
                                ))
 
                                
                                
                                
select count(*) from ( select
	                            distinct tabela_leads.* from
	                            (
			                            select
                                            regexp_replace(upper(trim(p.nome_paciente)), '\s*[^a-zA-Z -]+\s*', '') as Nome_Paciente, 
                                            case 
                                                when 
                                                (
                                                    regexp_like(replace(regexp_replace(lower(p.email),'([\p{Punct}&&[^@._-]])',''),' ',''),
                                                                 '(?:[a-z0-9!#$%&''*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&''*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])')
                                                and lower(p.email) like '%@%.%'
                                                and lower(p.email) not like '%---%'
                                                and lower(p.email) not like '%...%'
                                                and lower(p.email) not like '%hhh%'
                                                and lower(p.email) not like '%xxx%'
                                                and lower(p.email) not like '%wwww%'        
                                                and lower(p.email) not like '%123@.com%'
                                                and lower(p.email) not like '%n%o%soube%'
                                                and lower(p.email) not like '%n%o%tem%'
                                                and lower(p.email) not like '%n%o%existe%'
                                                and lower(p.email) not like '%sem@sem%'
                                                and lower(p.email) not like '%n%o@tem%'
                                                and lower(p.email) not like '%@n%otem%'
                                                and lower(p.email) not like '%0@0%'
                                                and lower(p.email) not like '%nao@nao%'
                                                and lower(p.email) not like '%naaotem%'
                                                and lower(p.email) not like '%nada%nada%'
                                                and lower(p.email) not like '%nada%gmail%'
                                                and lower(p.email) not like '%gmail%gmail%'
                                                and lower(p.email) not like '%nao tem%'
                                                and lower(p.email) not like '%nao.tem%'
                                                and lower(p.email) not like '%sem%email%'
                                                and lower(p.email) not like '%n@n.com%'
                                                and lower(p.email) not like '%n%o%tenho%'
                                                and lower(p.email) not like '%n%o%inform%'
                                                and lower(p.email) not like '%email%'
                                                and lower(p.email) not like '%n%o%possui%'
                                                and lower(p.email) not like '%sem%email%'
                                                and lower(p.email) not like '%nao@%'
                                                and lower(p.email) not like '%@nao%'
                                                and lower(p.email) not like '%n@n%'
                                                and lower(p.email) not like '%@.com%'
                                                and lower(p.email) not like '%informado%'
                                                and lower(p.email) not like '%informou%'
                                                and lower(p.email) not like '%0000%'
                                                and lower(p.email) not like '%ni.com.br%'
                                                )
                                                then
                    	                            replace(regexp_replace(lower(p.email),'([\p{Punct}&&[^@._-]])',''),' ','')
                                                else
                    	                            null
                                            end                           
                                            as Email, 
                                            case
                                                when 
                                                (
                                                    length( replace(replace(replace(replace(replace(replace(p.celular, '(', ''), ')', ''), ' ', ''), '-', ''), '+', ''), '_', '') ) >= 10
                                                and p.celular not like '%000%000%'
                                                and p.celular not like '%111%111%'
                                                and p.celular not like '%222%222%'
                                                and p.celular not like '%333%333%'
                                                and p.celular not like '%444%444%'
                                                and p.celular not like '%555%555%'
                                                and p.celular not like '%666%666%'
                                                and p.celular not like '%777%777%'
                                                and p.celular not like '%888%888%'
                                                and p.celular not like '%999%999%'
                                                and p.celular not like '%0123456%'
                                                and p.celular not like '%1234567%'
                                                and p.celular not like '%2345678%'
                                                and p.celular not like '%3456789%'
                                                )
                                                then
	                                                replace(replace(replace(replace(replace(replace(p.celular, '(', ''), ')', ''), ' ', ''), '-', ''), '+', ''), '_', '') 
                                                else
	                                                null
                                            end    
                                            as Celular,
                                            case 
                                                when 
                                                    p.cpf <> '99199299394' or p.cpf not like '%00000000%' 
                                                then 
                                                    p.cpf
                                                else
                                                    null
                                            end               
                                            as CPF,
                                            p.nascimento as Nascimento,
                                            case 
                                                when p.estado_civil_id = 1 then 'Casado'
                                                when p.estado_civil_id = 2 then 'Solteiro'
                                                when p.estado_civil_id = 3 then 'Divorciado'
                                                when p.estado_civil_id = 4 then 'Viúvo'
                                                else null
                                            end as EstadoCivil,
                                            p.sexo as Genero,
                                            case 
                                                when replace(pe.cep,'-','') <> '00000000'
                                                then replace(pe.cep,'-','')
                                                else null
                                            end                                         
                                            as Cep,
                                            case
                                            	when    regexp_replace(replace(pe.logradouro,' ',''), '\s*[^0-9]+\s*', '') like '0%' 
                                            	     or regexp_replace(replace(pe.logradouro,' ',''), '\s*[^0-9]+\s*', '') like '11%' 
                                            	     or upper(trim(pe.logradouro)) like '%AAA%'
                                            	     or upper(trim(pe.logradouro)) like '%XXX%'
                                            	     or upper(trim(pe.logradouro)) like '%ZZZ%'
                                            	     or upper(trim(pe.logradouro)) like '%TTT%'
                                            	     or upper(trim(pe.logradouro)) like '%WWW%'
                                            	     or upper(trim(pe.logradouro)) like '%FFF%'
                                            	     or length(trim(pe.logradouro)) < 4 
                                            	     or length(regexp_replace(replace(pe.logradouro,' ',''), '\s*[^a-zA-Z]+\s*', '')) = 0
                                            	then ''
                                            	else upper(trim(pe.logradouro))
                                            end                                        
                                            as Logradouro,
                                            case
                                            	when    
                                            			regexp_replace(replace(pe.bairro,' ',''), '\s*[^0-9]+\s*', '') like '0%' 
                                            	     or regexp_replace(replace(pe.bairro,' ',''), '\s*[^0-9]+\s*', '') like '11%' 
                                            	     or upper(trim(pe.bairro)) like '%AAA%'
                                            	     or upper(trim(pe.bairro)) like '%XXX%'
                                            	     or upper(trim(pe.bairro)) like '%ZZZ%'
                                            	     or upper(trim(pe.bairro)) like '%TTT%'
                                            	     or upper(trim(pe.bairro)) like '%WWW%'
                                            	     or upper(trim(pe.bairro)) like '%FFF%'
                                            	     or length(trim(pe.bairro)) < 3
                                            	     or length(regexp_replace(replace(pe.bairro,' ',''), '\s*[^a-zA-Z]+\s*', '')) = 0
                                            	then ''
                                            	else upper(trim(pe.bairro))
                                            end                                        
                                            as Bairro,
                                            case 
                                                when 
	                                                length(regexp_replace(replace(pe.numero,' ',''), '\s*[^0-9]+\s*', '')) = 0 or length(regexp_replace(replace(pe.numero,' ',''), '\s*[0-9]+\s*', '')) > 1 or length(regexp_replace(replace(pe.numero,' ',''), '\s*[^0-9]+\s*', '')) > 6
                                                then ''
                                                else 
                                                	case 
                                                		when cast(regexp_replace(replace(pe.numero,' ',''), '\s*[^0-9]+\s*', '') as bigint) <= 1 
                                                		then ''
                                                		else replace(pe.numero,' ','') 
                                                	end
                                            end                                      
                                            as Numero,
                                            case 
	                                            when 
	                                            	length(regexp_replace(replace(pe.complemento,' ',''), '\s*[^a-zA-Z]+\s*', '')) = 0
	                                            	or length(trim(pe.complemento)) < 4
                                            	then ''
                                            	else upper(trim(pe.complemento)) 
                                            end                                        
                                            as Complemento,
                                            case 
                                                when 
                                                	length(upper(pe.cidade)) <= 3 and pe.cidade not in ('AÇU', 'ACU', 'EXU', 'ICO', 'ICÓ', 'IPE', 'IPÊ', 'IPU', 'ITA', 'ITÁ', 'ITU', 'JAU', 'JAÚ', 'LUZ', 'POA', 'POÁ', 'UBA', 'UBÁ', 'UNA', 'URU')
                                                	or upper(trim(pe.cidade)) like '%AAA%'
                                            	    or upper(trim(pe.cidade)) like '%XXX%'
                                            	    or upper(trim(pe.cidade)) like '%ZZZ%'
                                            	    or upper(trim(pe.cidade)) like '%TTT%'
                                            	    or upper(trim(pe.cidade)) like '%WWW%'
                                            	    or upper(trim(pe.cidade)) like '%FFF%'
                                                	or length(regexp_replace(replace(pe.cidade,' ',''), '\s*[^a-zA-Z]+\s*', '')) = 0
                                                then ''
                                                else upper(pe.cidade)
                                            end                                       
                                            as Cidade,
                                            case 
                                                when upper(pe.estado) not in ('AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO')
                                                then '' 
                                                else upper(pe.estado)
                                            end                                
                                            as Estado,
                                            a.sys_date as DataAgendamento,
                                            a.data as DataMarcacao,  	
                                            l.unidade_id as idClinica, 
                                            u.nome_unidade as NomeClinica, 
                                            tp.nome_tabela_particular as Convenio,
                                            ast.nome_status as StatusAgenda,
                                            a.id as IdAgendamento,
                                            u.cep as CepClinica,
                                            u.cidade as CidadeClinica,
                                            u.estado as EstadoClinica
                                            from 
                                                todos_data_lake_trusted_feegow.agendamentos a
                	                        join
	                	                        (
													select 
														 a.id as id
													from 
														 todos_data_lake_trusted_feegow.agendamentos a
													join todos_data_lake_trusted_feegow.procedimentos pr on pr.id = a.procedimento_id and pr.tipo_procedimento_id in (2,9)
													join todos_data_lake_trusted_feegow.tabelas_particulares tp on a.tabela_particular_id = tp.id and (upper(tp.nome_tabela_particular) not like 'CART%O%DE%TODOS%' and upper(tp.nome_tabela_particular) not like '%TUTTI%')
													where 
														-- a.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3) and
														 --year(date("data")) = {ano} and month(date("data")) = {mes} 
													a."data" between date('2023-07-01') and date('2023-07-31')
													union
													select 
														a.id as id
													from 
														todos_data_lake_trusted_feegow.agendamentos a
													join todos_data_lake_trusted_feegow.agendamento_procedimentos ap on a.id  = ap.agendamento_id 
													join todos_data_lake_trusted_feegow.procedimentos pr on pr.id = ap.procedimento_id and pr.tipo_procedimento_id in (2,9)
													join todos_data_lake_trusted_feegow.tabelas_particulares tp on a.tabela_particular_id = tp.id and (upper(tp.nome_tabela_particular) not like 'CART%O%DE%TODOS%' and upper(tp.nome_tabela_particular) not like '%TUTTI%')
													where 
														 --a.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3) and
														 --year(date("data")) = {ano} and month(date("data")) = {mes}  
													a."data" between date('2023-07-01') and date('2023-07-31')														
												) atendidos --ambos os joins com regra de negócio batem --53212 registros
												on atendidos.id = a.id
                                            join
                	                            (
                		                          select max(id) as id, paciente_id 
                		                            from todos_data_lake_trusted_feegow.agendamentos a
                		                            where 
                                                        --year(date("data")) = {ano} and month(date("data")) = {mes}
                		                            a."data" between date('2023-07-01') and date('2023-07-31')
                		                            group by paciente_id
                	                            ) pa
                	                            on pa.id = a.id --aproximadamente 20 mil registros a menos com esse join
                	                        join
                	                        	todos_data_lake_trusted_feegow.agendamento_status ast 
                	                        	on ast.id = a.status_id 
                                            join
                                                todos_data_lake_trusted_feegow.tabelas_particulares tp
                                                on a.tabela_particular_id = tp.id
                                                and (upper(tp.nome_tabela_particular) not like 'CART%O%DE%TODOS%' and upper(tp.nome_tabela_particular) not like '%TUTTI%')
                                            join
                                                todos_data_lake_trusted_feegow.pacientes p
                                                on a.paciente_id = p.id
                                            left join
                                                todos_data_lake_trusted_feegow.paciente_endereco pe
                                                on p.id = pe.paciente_id
                                            join
                	                            todos_data_lake_trusted_feegow.locais l
                	                            on l.id = a.local_id 
                                            join 
					                            todos_data_lake_trusted_feegow.unidades u 
					                            on u.id = l.unidade_id 
                                            where
                                            --year(date(a."data")) = {ano} and month(date(a."data")) = {mes}
                                            a."data" between date('2023-07-01') and date('2023-07-31')
                                            order by a.id desc
	                            ) tabela_leads                            
	                            where --o where retira aproximandamente 13 mil registros
                                (Nascimento is not null and (year(current_date) - year(Nascimento) >= 18 and year(current_date) - year(Nascimento) < 120) )
                                and
                                (Cpf <> '' and Cpf is not null)
                                and
                                (
	                                (Email <> '' and Email is not null) or 
	                                (Celular <> '' and Celular is not null)      
                                ) 
                                )
                                
                                              
                                
                                
                                
                                
                                
                                select count(*) from (
select a.id
													from todos_data_lake_trusted_feegow.agendamento_procedimentos ap
												left join todos_data_lake_trusted_feegow.agendamentos a on ap.agendamento_id = a.id
												left join todos_data_lake_trusted_feegow.agendamento_status ass on a.status_id = ass.id
												left join todos_data_lake_trusted_feegow.especialidades es on a.especialidade_id = es.id
												left join todos_data_lake_trusted_feegow.procedimentos pro on ap.procedimento_id = pro.id
												left join todos_data_lake_trusted_feegow.procedimentos_tipos pt on pro.tipo_procedimento_id = pt.id
												left join todos_data_lake_trusted_feegow.tabelas_particulares tp on a.tabela_particular_id = tp.id and (upper(tp.nome_tabela_particular) not like 'CART%O%DE%TODOS%' and upper(tp.nome_tabela_particular) not like '%TUTTI%')
													where pt.id in (2, 9)
													and a.status_id in (33, 207, 202, 2, 200, 203, 5, 204, 201, 205, 4, 206, 3)
													and a."data" between date('2023-07-01') and date('2023-07-31')
													)
                                
													
													
													
												
select count(a.id), a.paciente_id
from todos_data_lake_trusted_feegow.agendamentos a
where 
--year(date("data")) = {ano} and month(date("data")) = {mes}
a."data" between date('2023-07-01') and date('2023-07-31')
group by a.paciente_id