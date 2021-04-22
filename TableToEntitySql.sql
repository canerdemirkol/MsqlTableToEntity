-- MSSQL için aktif veritabanının C# Entity Class'larınızı oluşturur

declare @tableName nvarchar(200)
declare @columnName nvarchar(200)
declare @datatype nvarchar(50)
declare @sType nvarchar(50)
declare @sProperty nvarchar(200)
declare @isNullable nvarchar(5)

DECLARE table_cursor CURSOR FOR 
SELECT TABLE_NAME
FROM [INFORMATION_SCHEMA].[TABLES]

OPEN table_cursor

FETCH NEXT FROM table_cursor 
INTO @tableName

WHILE @@FETCH_STATUS = 0
BEGIN

--PRINT 'public class ' + LEFT(@tableName, LEN(@tableName) - 1) + ' : IEntity
PRINT 'public class ' + REPLACE(REPLACE(REPLACE(@tableName,'LAR',''),'LERI','') ,'LER','')  +' : IEntity
{'

    DECLARE column_cursor CURSOR FOR 
    SELECT COLUMN_NAME, DATA_TYPE,IS_NULLABLE
    from [INFORMATION_SCHEMA].[COLUMNS] 
	WHERE [TABLE_NAME] = @tableName
	order by [ORDINAL_POSITION]

    OPEN column_cursor
    FETCH NEXT FROM column_cursor INTO @columnName, @datatype,@isNullable

    WHILE @@FETCH_STATUS = 0
    BEGIN

	-- datatype
	select @sType = case @datatype
	when 'int' then 'int'
	when 'bigint' then 'Int64'
	when 'decimal' then 'decimal'
	when 'money' then 'decimal'
	when 'char' then 'string'
	when 'nchar' then 'string'
	when 'varchar' then 'string'
	when 'nvarchar' then 'string'
	when 'uniqueidentifier' then 'Guid'
	when 'datetime' then 'DateTime'
	when 'bit' then 'bool'
	when 'varbinary' then 'byte[]'
	when 'binary' then 'byte[]'
	else 'string'
	END


	-- is_nullable
	select @sType = case @isNullable
	when 'NO' then @sType
	when 'YES' then (case @sType when 'string' then @sType else 'Nullable<'+@sType+'>' end)      
	END



		SELECT @sProperty = '	public ' + @sType + ' ' + @columnName + ' { get; set;}'
		PRINT @sProperty
		FETCH NEXT FROM column_cursor INTO @columnName, @datatype,@isNullable


	END
    CLOSE column_cursor
    DEALLOCATE column_cursor

	print '}'
	print ''
    FETCH NEXT FROM table_cursor 
    INTO @tableName
END
CLOSE table_cursor
DEALLOCATE table_cursor



