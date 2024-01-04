REPLACE(REPLACE(REPLACE(REPLACE(sum(cr.valor_pago)
	::text,'$','R$ '),',','|'),'.',','),'|','.')