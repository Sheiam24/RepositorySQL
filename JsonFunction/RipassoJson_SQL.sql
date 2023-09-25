/* ASSOLUTAMENTE DA RIVEDERE*/

DECLARE @j nvarchar(max) = '{
  "id" : 1, 
  "colore": "verde",
  "animale": [
    "nome": "azzurro",
    "specie": "pesce"
  ]
}'

alter view its.animali as
select 
id = JSON_VALUE(j, '$.id'),
colore = JSON_VALUE(j, '$.colore'),
animalenome = JSON_VALUE(a.value, '$.animale.nome'),
animalespecie = JSON_VALUE(a.value, '$.animale.specie')
from its.json cross apply openjson (j, '$animale') a

select * from its.animali 



declare @j nvarchar(max) = '{
  "id" : 2, 
  "colore": "arancione",
  "animale": [
  {
    "nome": "maya",
    "specie": "cane"
  }
  ]
}'

insert into its.json values (@j)

select * from its.json

/*CREATE schema its 
create table its.json (
id int identity (1,1),
j varchar(max))

alter table its.json
alter column j nvarchar (max) not null*/

select @j, isjson(@j),
	json_value(@j, '$.colore') as Colore,
	json_query(@j, '$.animali') as Animali,
	animalinome = json_value(@j, '$.animali[0].nome') 
from its.json 

--idjson colore, animalenome, animalespecie

select 
	id = JSON_VALUE (j, '$.id')
	, colore = JSON_VALUE(j, '$.colore')
	,A.*
	, animalenome = JSON_VALUE(j, '$.nome')
	, animalespecie = JSON_VALUE(j, '$.specie')
	from its.json
	cross apply openjson (j, '$.animali') A

	select * from openjson (j)


--voglio modificare il valore all'interno del json
update its.json
set j = json_modify(j, 'strinct $.animali[1].specie', 'pappagallo')  --STRINCT: se trova la chiave aggiorna il valore richiesto, altrimenti dà errore
where id = 2

/*store precedure che fa questa operazione automaticamente
deve inserire un json nella tabella its.json*/
create procedure its.sp_insertJson 
@colore varchar(20)
,@animaleNome   varchar(20) = NULL
,@animaleSpecie varchar(20) = NULL
as

IF (@colore is null)
BEGIN
    raiserror('Il parametro @colore non può essere NULL', -1, -1, 'sp_insertJson')
END
ELSE
BEGIN

    declare @id int = (select max(id) + 1 from its.JSON )

    declare @j nvarchar(max), @jAnimali nvarchar(max)

    set @jAnimali = 
        JSON_MODIFY(
            JSON_MODIFY('{}', '$.nome', @animaleNome),
            '$.specie',
            @animaleSpecie
            )

    set @j = JSON_MODIFY('{}', '$.id', @id)
    set @j = JSON_MODIFY(
                JSON_MODIFY(@j , '$.colore', @colore),
                'append $.animali',
                @jAnimali
                )

END

--PS: variabili si possono usare in una store procedure!

EXEC its.sp_insertJson @colore = 'pippo'


--ERRORE! "{}" riconosciuto come stringa
--CARATTERI DI ESCAPE


alter procedure its.sp_insertJson 
@colore varchar(20)
,@animaleNome   varchar(20) = NULL
,@animaleSpecie varchar(20) = NULL
as

IF (@colore is null)
BEGIN
    raiserror('Il parametro @colore non può essere NULL', -1, -1, 'sp_insertJson')
END
ELSE
BEGIN

    declare @id int = (select max(id) + 1 from its.JSON )

    declare @j nvarchar(max), @jAnimali nvarchar(max)

    set @jAnimali = 
        JSON_MODIFY(
            JSON_MODIFY('{}', '$.nome', @animaleNome),
            '$.specie',
            @animaleSpecie
            )
			--SELECT @JaNIMALI, json_QUERY(@Janimali)
    select @jAnimali, JSON_QUERY(@jAnimali)--json query deve contenere il json originale senza leggerlo
    set @j = JSON_MODIFY('{}', '$.id', @id)
    set @j = JSON_MODIFY(
                JSON_MODIFY(@j , '$.colore', @colore),
                'append $.animali',
                @jAnimali
                )
	insert into its.json values (@j)
	print ('La registrazione del JSON è andata a buon fine
	Per verifica:
	SELECT TOP 100*
	FROM its.JSON
	ORDER BY ID desc')
   -- select @j
END
EXEC its.sp_insertJson @colore= 'rosa', @animaleNome='pluto'

/* store procedure 2 per 