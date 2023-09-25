alter procedure its.sp_insertJson 
@colore varchar(20)
,@animaleNome   varchar(20) = NULL
,@animaleSpecie varchar(20) = NULL
as

IF (@colore is null)
BEGIN
	raiserror('Il parametro @colore non pu� essere NULL', -1, -1, 'sp_insertJson')
END
ELSE
BEGIN

	declare @id int = (select max(id) + 1 from its.JSON )
	declare @j nvarchar(max)


    set @j = JSON_MODIFY('{}', '$.id', @id)
	set @j = JSON_MODIFY(@j , '$.colore', @colore)
	
	--select @jAnimali, JSON_QUERY(@jAnimali)

	

	--select @j
	insert into its.JSON values (@j)
	PRINT 'La registrazione del JSON � andata a buon fine
	
Per verifica:
	SELECT TOP 100 * 
	FROM its.JSON
	ORDER BY id desc
	'
END

EXEC its.sp_insertJson @colore = 'amaranto'

-- {"id":4,"colore":"pippo","animali":["{}"]}
-- {"id":4,"colore":"pippo","animali":["{\"nome\":\"pluto\"}"]}
-- {"id":4,"colore":"pippo","animali":[{"nome":"pluto"}]}

SELECT TOP 100 * 
	FROM its.JSON
	ORDER BY id desc

/*set @jAnimali = 
		JSON_MODIFY(
			JSON_MODIFY('{}', '$.nome', @animaleNome),
			'$.specie',
			@animaleSpecie
			) */

            