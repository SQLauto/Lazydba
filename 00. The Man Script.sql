PRINT 'SQL server evaluation script @ 11 July 2017 adrian.sullivan@lexel.co.nz ' + NCHAR(65021)

SET NOCOUNT ON
SET ANSI_WARNINGS ON
SET QUOTED_IDENTIFIER ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @TopQueries TINYINT = 50  /*How many queries need to be looked at, TOP xx*/
DECLARE @FTECost MONEY = 60000/*Average price in $$$ that you pay someone at your company*/
DECLARE @MinExecutionCount TINYINT = 1 /*This can go to 0 for more details, but first attend to often used queries. Run this with 0 before making any big decisions*/
DECLARE @ShowQueryPlan TINYINT = 1 /*Set to 1 to include the Query plan in the output*/
DECLARE @PrepForExport TINYINT = 1 /*When the intent of this script is to use this for some type of hocus-pocus magic metrics, set this to 1*/

DECLARE @License NVARCHAR(4000)
SET @License = '----------------
MIT License
Copyright (c) ' + CONVERT(VARCHAR(4),DATEPART(YEAR,GETDATE())) + ' Adrian Sullivan

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
----------------
'
/* Reference sources. There are tons of folk out there who have contributed to this in some form or another. Attempts have been made to quote sources and authors where available.*/

DECLARE @References TABLE(Authors VARCHAR(250), [Source] VARCHAR(250) , Detail VARCHAR(500))
INSERT INTO @References VALUES ('Brent Ozar Unlimited','http://FirstResponderKit.org', 'Default Server Configuration values')
,('Talha, Johann','http://stackoverflow.com/questions/10577676/how-to-obtain-failed-jobs-from-sql-server-agent-through-script','')
,('Gregory Larsen','http://www.databasejournal.com/features/mssql/daily-dba-monitoring-tasks.html', '')
,('Leonid Sheinkman','http://www.databasejournal.com/scripts/all-database-space-used-and-free.html', '')
,('Unn Known','http://www.sqlserverspecialists.com/2012/10/script-to-monitor-sql-server-cpu-usage.html','')
,('Uday Arumilli','http://udayarumilli.com/monitor-cpu-utilization-io-usage-and-memory-usage-in-sql-server/','')
,('Peter Scharlock','https://blogs.msdn.microsoft.com/mssqlisv/2009/06/29/interesting-issue-with-filtered-indexes/','')
,('Stijn, Sanath Kumar','http://stackoverflow.com/questions/9235527/incorrect-set-options-error-when-building-database-project','')
,('Julian Kuiters','http://www.julian-kuiters.id.au/article.php/set-options-have-incorrect-settings','')
,('Basit A Masood-Al-Farooq','https://basitaalishan.com/2014/01/22/get-sql-server-physical-cores-physical-and-virtual-cpus-and-processor-type-information-using-t-sql-script/','')
,('Paul Randal','http://www.sqlskills.com/blogs/paul/wait-statistics-or-please-tell-me-where-it-hurts/','')
,('wikiHow','http://www.wikihow.com/Calculate-Confidence-Interval','')
,('Periscope Data','https://www.periscopedata.com/blog/how-to-calculate-confidence-intervals-in-sql','')
,('Jon M Crawford','https://www.sqlservercentral.com/Forums/Topic922290-338-1.aspx','')
,('Robert L Davis','http://www.sqlsoldier.com/wp/sqlserver/breakingdowntempdbcontentionpart2','')
/* Guidelines:
	1. Each declare on a new line
	2. Each column on a new line
	3. "," in from of new lines
	4. All (table columns) have ( and ) in new lines with tab indent
	5. All ends with ";"
	6. All comments in / * * / not --
	7. All descriptive comments above DECLAREs
		Comments can also be in SET @comment = ''
	8. All Switches are 0=off and 1=on and TINYINT type
	9. SELECT -option- <first column>
	, <column>
	FROM.. where more than 1 column is returned, or whatever reads better
	OPTION (RECOMPILE)
	Section:
	DECLARE section variables
	--------
	Do stuff
*/
	DECLARE @matrixthis BIGINT = 0
	DECLARE @matrixthisline INT = 0
	DECLARE @sliverofawesome NVARCHAR(200)
	DECLARE @thischar NVARCHAR(1)

	WHILE @matrixthis < 100
	BEGIN
		SET @matrixthisline = 0
		SET @sliverofawesome = ''

		WHILE @matrixthisline < 180
		BEGIN
			SET @thischar = NCHAR(CONVERT(INT,RAND() *  1252))
			IF LEN(@thischar) = 0 OR RAND() < 0.8
				SET @thischar = ' '
			SET @sliverofawesome = @sliverofawesome + @thischar
			SET @matrixthisline = @matrixthisline + 1
		END
		PRINT (@sliverofawesome) 
		SET @matrixthis = @matrixthis + 1
		WAITFOR DELAY '00:00:00.011'
	END

	DECLARE @c_r AS CHAR(2) 
	SET @c_r = CHAR(13) + CHAR(10)
	PRINT REPLACE(REPLACE(REPLACE(REPLACE(''+@c_r+'	[   ....,,:,,....[[ '+@c_r+'[   ,???????????????????:.[   '+@c_r+'[ .???????????????????????,[  '+@c_r+'s=.  ??????&&&$$??????. .7s '+@c_r+'s~$.. ...&&&&&... ..7Is '+@c_r+'s~&$+....[[.. =7777Is '+@c_r+'s~&&&&$$7I777Iv7777I[[  '+@c_r+'s~&&&&$$Ivv7777Is '+@c_r+'s~&$$... &$.. ..777?..vIs '+@c_r+'s~&$  &$$.  77?..77? .vIs '+@c_r+'s~&$. .&$  $I77=  7? .vIs '+@c_r+'s~&$$,. .$$ .$I777..7? .vIs '+@c_r+'s~&&$+ .$  ~I77. ,7? .vIs '+@c_r+'s~&$..   & ...  :77? ....77Is '+@c_r+'s~&&&&$$I:..vv7I[ '+@c_r+'s~&&&&$$Ivv7777Is '+@c_r+'s.&&&&$$Ivv7777.s '+@c_r+'s .&&&&$Ivv777.['+@c_r+'[ ..7&&&Ivv..[  '+@c_r+'[[........... ..[[ ', '&','$$$'),'v', '77777'),'[', '      '),'s','    ')
	PRINT REPLACE(REPLACE(REPLACE(REPLACE('.m__._. _.m__. __.__.. _.. _. _. m_..m_.m_. m.m_.m__ '+@c_r+' |_. _|g g| m_g.\/.i / \. | \ g / mi/ m|i_ \ |_ _|i_ \|_. _|'+@c_r+'. g.g_gi_i g\/g./ _ \.i\g \m \ g..g_) g g |_) g i'+@c_r+'. g.i_.|gm.g.g / m \ g\.im) |gm i_ <.g i__/.g.'+@c_r+'. |_i|_g_||m__g_i|_|/_/. \_\|_| \_gm_/.\m_||_| \_\|m||_i. |_i'+@c_r+'........................................... ','i','|.'),'.','  '),'m','___'),'g','| |')
	PRINT @License
	PRINT 'Let''s begin..'
	
	/*@ShowWarnings = 0 > Only show warnings */
	DECLARE @ShowWarnings TINYINT 
	SET @ShowWarnings = 0;

	/*Script wide variables*/
	DECLARE @DaysUptime NUMERIC(23,2);
	DECLARE @dynamicSQL NVARCHAR(4000) ;
	SET @dynamicSQL = N'';
	DECLARE @MinWorkerTime BIGINT ;
	SET @MinWorkerTime = 0.01 * 1000000;
	DECLARE @MinChangePercentage MONEY
	DECLARE @DoStatistics MONEY
	SET @MinChangePercentage = 0.1
	DECLARE @LeftText INT ;
	SET @LeftText = 50; /*The lengh that you want to trim text*/
	DECLARE @oldestcachequery DATETIME ;
	DECLARE @minutesSinceRestart BIGINT;
	DECLARE @CPUcount INT;
	DECLARE @lastservericerestart DATETIME;
	DECLARE @DaysOldestCachedQuery MONEY;
	DECLARE @CachevsUpdate MONEY;
	DECLARE @Databasei_Count INT;
	DECLARE @Databasei_Max INT;
	DECLARE @DatabaseName SYSNAME;
	DECLARE @DatabaseState TINYINT;
	DECLARE @RecoveryModel TINYINT;
	DECLARE @comment NVARCHAR(MAX);
	DECLARE @StartTest DATETIME 
	DECLARE @EndTest DATETIME; 
	DECLARE @ThisistoStandardisemyOperatorCostMate INT;
	DECLARE @secondsperoperator FLOAT;
	DECLARE @totalMemoryGB MONEY, @AvailableMemoryGB MONEY, @UsedMemory MONEY
	DECLARE @VMType VARCHAR(200), @ServerType VARCHAR(20)
	DECLARE @MaxRamServer INT,@SQLVersion tinyint
	DECLARE @ts BIGINT;
	DECLARE @Kb FLOAT;
	DECLARE @PageSize FLOAT;
	DECLARE @VLFcount INT;
	DECLARE @starttime DATETIME;
	DECLARE @ErrorSeverity int;
	DECLARE @ErrorState int;
	DECLARE @ErrorMessage NVARCHAR(4000);

	/*Performance section variables*/
	DECLARE @cnt INT;
	DECLARE @record_count INT;
	DECLARE @dbid INT;
	DECLARE @objectid INT;
	DECLARE @cmd nvarchar(MAX);
	DECLARE @grand_total_worker_time FLOAT ; 
	DECLARE @grand_total_IO FLOAT ; 
	DECLARE @evaldate DATETIME;
	DECLARE @TotalIODailyWorkload MONEY;
	SET @evaldate = GETDATE();

	SET @starttime = GETDATE()

	SELECT @SQLVersion = @@MicrosoftVersion / 0x01000000  OPTION (RECOMPILE)-- Get major version
	DECLARE @sqlrun NVARCHAR(4000), @rebuildonline VARCHAR(30), @isEnterprise INT, @i_Count INT, @i_Max INT;

	

	DECLARE @FileSize TABLE
	(  
		DatabaseName sysname 
		, [FileName] VARCHAR(MAX) NULL
		, FileSize BIGINT NULL
		, FileGroupName VARCHAR(MAX) NULL
		, LogicalName VARCHAR(MAX) NULL
		, maxsize MONEY NULL
		, growth MONEY NULL
	);
	DECLARE @FileStats TABLE 
	(  
		FileID INT
		, FileGroup INT  NULL
		, TotalExtents INT  NULL
		, UsedExtents INT  NULL
		, LogicalName VARCHAR(MAX)  NULL
		, FileName VARCHAR(MAX)  NULL
	);
	DECLARE @LogSpace TABLE 
	( 
		DatabaseName sysname NULL
		, LogSize FLOAT NULL
		, SpaceUsedPercent FLOAT NULL
		, Status bit NULL
	);

	IF OBJECT_ID('tempdb..#NeverUsedIndex') IS NOT NULL
				DROP TABLE #NeverUsedIndex;
			CREATE TABLE #NeverUsedIndex 
			(
				DB VARCHAR(250)
				,Consideration VARCHAR(50)
				,TableName VARCHAR(50)
				,TypeDesc VARCHAR(50)
				,IndexName VARCHAR(250)
				,Updates BIGINT
				,last_user_scan DATETIME
				,last_user_seek DATETIME
				,Pages BIGINT
			)

	IF OBJECT_ID('tempdb..#HeapTable') IS NOT NULL
				DROP TABLE #HeapTable;
			CREATE TABLE #HeapTable 
			( 
				DB VARCHAR(250)
				, [schema] VARCHAR(250)
				, [table] VARCHAR(250)
				, [rows] BIGINT
				, user_seeks BIGINT
				, user_scans BIGINT
				, user_lookups BIGINT
				, user_updates BIGINT
				, last_user_seek DATETIME
				, last_user_scan DATETIME
				, last_user_lookup DATETIME
			);

	IF OBJECT_ID('tempdb..#LogSpace') IS NOT NULL
				DROP TABLE #LogSpace;
			CREATE TABLE #LogSpace  
			( 
				DatabaseName sysname NULL
				, LogSize FLOAT NULL
				, SpaceUsedPercent FLOAT NULL
				, Status bit NULL
				, VLFCount INT NULL
			);
	IF OBJECT_ID('tempdb..#Action_Statistics') IS NOT NULL
				DROP TABLE #Action_Statistics;
			CREATE TABLE #Action_Statistics 
			(
				Id INT IDENTITY(1,1)
				, DBname VARCHAR(100)
				, TableName VARCHAR(100)
				, StatsID TINYINT
				, StatisticsName VARCHAR(500)
				, SchemaName VARCHAR(100)
				, ModificationCount BIGINT
				, LastUpdated DATETIME
				, [Rows] BIGINT
				, [Mod%] MONEY
			);
	IF OBJECT_ID('tempdb..#MissingIndex') IS NOT NULL
				DROP TABLE #MissingIndex;
			CREATE TABLE #MissingIndex 
			(
				DB VARCHAR(250)
				, magic_benefit_number FLOAT
				, [Table] VARCHAR(2000)
				, ChangeIndexStatement VARCHAR(4000)
				, equality_columns VARCHAR(4000)
				, inequality_columns VARCHAR(4000)
				, included_columns VARCHAR(4000)
				, [BeingClever] NVARCHAR(4000)
			);

	IF OBJECT_ID('tempdb..#output_man_script') IS NOT NULL
				DROP TABLE #output_man_script;
			CREATE TABLE #output_man_script 
			(
				evaldate DATETIME DEFAULT GETDATE()
				, domain VARCHAR(50) DEFAULT DEFAULT_DOMAIN()
				, SQLInstance VARCHAR(50) DEFAULT @@SERVERNAME
				, SectionID TINYINT NULL
				, Section VARCHAR(MAX)
				, Summary VARCHAR(MAX)
				, Details VARCHAR(MAX)
				, QueryPlan XML NULL
				, HoursToResolveWithTesting MONEY NULL
				, ID INT IDENTITY(1,1)
			)
	IF OBJECT_ID('tempdb..#ConfigurationDefaults') IS NOT NULL
				DROP TABLE #ConfigurationDefaults;
			CREATE TABLE #ConfigurationDefaults
				(
				  name NVARCHAR(128) ,
				  DefaultValue BIGINT,
				  CheckID INT
				);
	IF OBJECT_ID('tempdb..#db_sps') IS NOT NULL
				DROP TABLE #db_sps;
	CREATE TABLE #db_sps 
				(
					[dbname] VARCHAR(500)
					, [SP Name] NVARCHAR(4000)
					, [TotalLogicalWrites] BIGINT
					, [AvgLogicalWrites] BIGINT
					, execution_count BIGINT
					, [Calls/Second] INT
					, [total_elapsed_time] BIGINT
					, [avg_elapsed_time] BIGINT
					, cached_time DATETIME
				);
	IF OBJECT_ID('tempdb..#querystats') IS NOT NULL
				DROP TABLE #querystats
	CREATE TABLE #querystats
				(
					 Id INT IDENTITY(1,1)
					, [execution_count] [bigint] NOT NULL
					, [total_logical_reads] [bigint] NOT NULL
					, [Total_MBsRead] [money] NULL
					, [total_logical_writes] [bigint] NOT NULL
					, [Total_MBsWrite] [money] NULL
					, [total_worker_time] [bigint] NOT NULL
					, [total_elapsed_time_in_S] [money] NULL
					, [total_elapsed_time] [money] NULL
					, [last_execution_time] [datetime] NOT NULL
					, [plan_handle] [varbinary](64) NOT NULL
					, [sql_handle] [varbinary](64) NOT NULL
				);

	IF OBJECT_ID('tempdb..#notrust') IS NOT NULL
				DROP TABLE #notrust
	CREATE TABLE #notrust
				(
				KeyType VARCHAR(20)
				, Tablename VARCHAR(500)
				, KeyName VARCHAR(500)
				, DBCCcommand VARCHAR(2000)
				, Fix VARCHAR(2000)
				)
	IF OBJECT_ID('tempdb..#whatsets') IS NOT NULL
				DROP TABLE #whatsets
	CREATE TABLE #whatsets
				(
				  DBname VARCHAR(500)
				, [SETs] VARCHAR(500)
				)	

	IF OBJECT_ID('tempdb..#dbccloginfo') IS NOT NULL
				DROP TABLE #dbccloginfo
	CREATE TABLE #dbccloginfo  
			(id INT IDENTITY(1,1) 
			)

	IF CONVERT(TINYINT,@SQLVersion) >= 11 -- post-SQL2012 
	BEGIN
		SET @dynamicSQL =  'Alter table #dbccloginfo Add [RecoveryUnitId] int'
		EXEC sp_executesql @dynamicSQL;
	END

	Alter table #dbccloginfo Add fileid smallint 
	Alter table #dbccloginfo Add file_size BIGINT
	Alter table #dbccloginfo Add start_offset BIGINT  
	Alter table #dbccloginfo Add fseqno int
	Alter table #dbccloginfo Add [status] tinyint
	Alter table #dbccloginfo Add parity tinyint
	Alter table #dbccloginfo Add create_lsn numeric(25,0)  

	DECLARE @msversion TABLE([Index] INT, Name VARCHAR(50), [Internal_Value] VARCHAR(50), [Character_Value] VARCHAR(250))
	INSERT @msversion
	EXEC xp_msver /*Rather useful this one*/

	--SELECT CONVERT(MONEY,LEFT(Character_Value,3)) FROM @msversion WHERE Name = 'WindowsVersion'

	DECLARE @value VARCHAR(64);
	DECLARE @key VARCHAR(512); 
	DECLARE @WindowsVersion VARCHAR(50);
	DECLARE @PowerPlan VARCHAR(20)
	SET @key = 'SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes';
	SELECT @WindowsVersion = CONVERT(MONEY,LEFT(Character_Value,3)) FROM @msversion WHERE Name = 'WindowsVersion'

	/*CASE WHEN windows_release IN ('6.3','10.0') AND (@@VERSION LIKE '%Build 10586%' OR @@VERSION LIKE '%Build 14393%')THEN '10.0' ELSE CONVERT(VARCHAR(5),windows_release) END 
	FROM sys.dm_os_windows_info (NOLOCK);*/


	IF CONVERT(DECIMAL(3,1), @WindowsVersion) >= 6.0
	BEGIN
		EXEC master..xp_regread 
		@rootkey = 'HKEY_LOCAL_MACHINE',
		@key = @key,
		@value_name = 'ActivePowerScheme',
		@value = @value OUTPUT;

		IF @value = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
		SET @PowerPlan = 'High-Performance'
		IF @value <> '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
		SET @PowerPlan =  '!Not Optimal! Check Power Options' 
		RAISERROR (N'Power Options checked',0,1) WITH NOWAIT;
		PRINT @PowerPlan
	END
	

	SET @rebuildonline = 'OFF';				/* Assume this is not Enterprise, we will test in the next line and if it is , woohoo. */
	SELECT @isEnterprise = PATINDEX('%enterprise%',@@Version) OPTION (RECOMPILE);
	IF (@isEnterprise > 0) 
	BEGIN 
		SET @rebuildonline = 'ON'; /*Can also use CAST(SERVERPROPERTY('EngineEdition') AS INT), thanks http://www.brentozar.com/ */
	END

	INSERT #output_man_script (SectionID,Section,Summary, Details) SELECT 0,'@' + CONVERT(VARCHAR(20),GETDATE(),120),'------','------'
	INSERT #output_man_script (SectionID,Section,Summary)
	SELECT 0,'Domain',DEFAULT_DOMAIN()
	UNION ALL SELECT 0,'Server', @@SERVERNAME
	UNION ALL SELECT 0,'User',CURRENT_USER
	UNION ALL SELECT 0,'Logged in', SYSTEM_USER
	UNION ALL SELECT 0, 'Power Plan', @PowerPlan
	UNION ALL SELECT 0, 'Bad CPU balance', '['+REPLICATE('#', CONVERT(MONEY,([cpu_count] / [hyperthread_ratio]))) +'] Sockets ['+REPLICATE('+', CONVERT(MONEY,([cpu_count]))) +'] CPUs'
			FROM [sys].[dm_os_sys_info] 
			WHERE 0 = CASE WHEN [hyperthread_ratio] <> cpu_count THEN 0 ELSE 1 END
		


				/*----------------------------------------
			--Check for any pages marked suspect for corruption
			----------------------------------------*/
	IF EXISTS(select 1 from msdb.dbo.suspect_pages)
	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 0, 'SUSPECT PAGES !! WARNING !!','------','------'
	INSERT #output_man_script (SectionID, Section,Summary, Details)
	SELECT 0,
	'DB: ' + db_name(database_id)
	+ '; FileID: ' + CONVERT(VARCHAR(20),file_id)
	+ '; PageID: ' + CONVERT(VARCHAR(20), page_id)
	, 'Event Type: ' + CONVERT(VARCHAR(20),event_type)
	+ '; Count: ' + CONVERT(VARCHAR(20),error_count)
	, 'Last Update: ' + CONVERT(VARCHAR(20),last_update_date,120)

	FROM msdb.dbo.suspect_pages
	OPTION (RECOMPILE)

	RAISERROR (N'Included Suspect Pages, if any',0,1) WITH NOWAIT;


			/*----------------------------------------
			--Before anything else, look for things that might point to breaking behaviour. Look for out of support SQL bits floating around
			--WORKAROUND - create all indexes using the deafult SET settings of the applications connecting into the server
			--DANGER WILL ROBINSON

			----------------------------------------*/

	IF EXISTS(SELECT 1 FROM sys.dm_exec_sessions T 
	WHERE ((
	quoted_identifier = 0 
	OR ansi_nulls = 0
	OR ansi_padding= 0
	OR ansi_warnings= 0
	OR arithabort= 0
	OR concat_null_yields_null= 0
	) AND LEN(T.nt_user_name) > 1 AND T.program_name NOT LIKE 'SQLAgent - %' ) OR T.client_version < 6)
	BEGIN

		INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 1,'!!! WARNING - CHECK SET !!!','------','------'
		INSERT #output_man_script (SectionID, Section,Summary, Details)
		SELECT DISTINCT 1
		, CASE 
		WHEN T.client_version < 3 THEN '!!! WARNING !!! Pre SQL 7'
		WHEN T.client_version = 3 THEN '!!! WARNING !!! SQL 7'
		WHEN T.client_version = 4 THEN '!!! WARNING !!! SQL 2000'
		WHEN T.client_version = 5 THEN '!!! WARNING !!! SQL 2005'
		WHEN T.client_version = 6 THEN 'SQL 2008'
		WHEN T.client_version = 7 THEN 'SQL 2012'
		ELSE 'SQL 2014+'
		END [Section]
		, CASE 
		WHEN T.client_version < 6 THEN 'SQL Stick and clay tablets'
		WHEN T.client_version = 6 THEN 'SQL 2008'
		WHEN T.client_version = 7 THEN 'SQL 2012'
		ELSE 'SQL 2014+'
		END
		+ 'App: [' + T.program_name
		+ ']; Driver: [' +
		CASE SUBSTRING(CAST(C.protocol_version AS BINARY(4)), 1,1)
		WHEN 0x04 THEN 'Pre-version SQL Server 7.0 - DBLibrary/ ISQL'
		WHEN 0x70 THEN 'SQL Server 7.0'
		WHEN 0x71 THEN 'SQL Server 2000'
		WHEN 0x72 THEN 'SQL Server 2005'
		WHEN 0x73 THEN 'SQL Server 2008'
		WHEN 0x74 THEN 'SQL Server 2012/14/16'
		ELSE 'Unknown driver'
		END 
		+ ']; Interface: '+ T.client_interface_name
		+ '; User: ' + T.nt_user_name
		+ '; Host: ' + T.host_name [Summary]
		, '' + CASE WHEN quoted_identifier = 0 THEN ';quoted_identifier = OFF' ELSE '' END
		+ ''+  CASE WHEN ansi_nulls = 0 THEN ';ansi_nulls = OFF' ELSE '' END
		+ ''+  CASE WHEN ansi_padding = 0 THEN ';ansi_padding = OFF' ELSE '' END
		+ ''+  CASE WHEN ansi_warnings = 0 THEN ';ansi_warnings = OFF' ELSE '' END
		+ ''+  CASE WHEN arithabort = 0 THEN ';arithabort = OFF' ELSE '' END
		+ ''+  CASE WHEN concat_null_yields_null = 0 THEN ';concat_null_yields_null = OFF' ELSE '' END
		FROM sys.dm_exec_sessions T
		INNER JOIN sys.dm_exec_connections C ON C.session_id = T.session_id
		WHERE ((
	quoted_identifier = 0 
	OR ansi_nulls = 0
	OR ansi_padding= 0
	OR ansi_warnings= 0
	OR arithabort= 0
	OR concat_null_yields_null= 0
	)
		AND LEN(T.nt_user_name) > 1
		AND T.program_name NOT LIKE 'SQLAgent - %' )
		OR T.client_version < 6 
		ORDER BY Section, [Summary];
		PRINT N'WARNING! You have SET options that might break stuff on SQL 2005+. DANGER WILL ROBINSON';
	END
	RAISERROR (N'Done checking for possible breaking SQL 2000 things',0,1) WITH NOWAIT;

			/*----------------------------------------
			--Before anything else, look for things that might point to breaking behaviour. Like databse with bad default settings
			----------------------------------------*/

	IF EXISTS(SELECT 1
		FROM sys.databases
		WHERE is_ansi_nulls_on = 0
		OR is_ansi_padding_on= 0
		OR is_ansi_warnings_on= 0
		OR is_arithabort_on= 0
		OR is_concat_null_yields_null_on= 0
		OR is_numeric_roundabort_on= 0
		OR is_quoted_identifier_on= 1)
	BEGIN

	
		INSERT INTO #whatsets(DBname, [SETs])
		SELECT name
		, ''+  CASE WHEN is_quoted_identifier_on = 0 THEN '; SET quoted_identifier OFF' ELSE '' END
		+ ''+  CASE WHEN is_ansi_nulls_on = 0 THEN '; SET ansi_nulls OFF' ELSE '' END
		+ ''+  CASE WHEN is_ansi_padding_on = 0 THEN '; SET ansi_padding OFF' ELSE '' END
		+ ''+  CASE WHEN is_ansi_warnings_on = 0 THEN '; SET ansi_warnings OFF' ELSE '' END
		+ ''+  CASE WHEN is_arithabort_on = 0 THEN '; SET arithabort OFF' ELSE '' END
		+ ''+  CASE WHEN is_concat_null_yields_null_on = 0 THEN '; SET concat_null_yields_null OFF' ELSE '' END
		+ ''+  CASE WHEN is_numeric_roundabort_on = 1 THEN '; SET is_numeric_roundabort_on ON' ELSE '' END
		FROM sys.databases
		WHERE is_ansi_nulls_on = 0
		OR is_ansi_padding_on= 0
		OR is_ansi_warnings_on= 0
		OR is_arithabort_on= 0
		OR is_concat_null_yields_null_on= 0
		OR is_numeric_roundabort_on= 1
		OR is_quoted_identifier_on= 0
	END

	IF EXISTS(SELECT * FROM #whatsets)
	BEGIN
		INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 1,'!!! WARNING - POTENTIALLY BREAKING DEFAULT DB SETTINGS!!!','------','------'
		INSERT #output_man_script (SectionID, Section,Summary)
		SELECT 1
		, DBname
		, [SETs]
		FROM #whatsets
		ORDER BY DBname DESC

	END

	RAISERROR (N'Done checking for possible breaking SQL 2000 things',0,1) WITH NOWAIT;
			/*----------------------------------------
			--Benchmark, not for anything else besides getting a number
			----------------------------------------*/


	SET @StartTest = GETDATE();
	
	WITH  E00(N)	AS (SELECT 1 UNION ALL SELECT 1)
		, E02(N)	AS (SELECT 1 FROM E00 a, E00 b)
		, E04(N)	AS (SELECT 1 FROM E02 a, E02 b)
		, E08(N)	AS (SELECT 1 FROM E04 a, E04 b)
		, E16(N)	AS (SELECT 1 FROM E08 a, E08 b)
		, cteTally(N) AS (SELECT ROW_NUMBER() OVER (ORDER BY N) FROM E16)
	SELECT 
		@ThisistoStandardisemyOperatorCostMate = count(N) 
	FROM cteTally OPTION (RECOMPILE);
	SET @EndTest = GETDATE();
	SELECT TOP 1  
		@secondsperoperator = (qs.total_worker_time/qs.execution_count/1000)/0.7248/1000  
	FROM sys.dm_exec_query_stats qs
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
	WHERE qs.total_logical_reads = 0 
	AND qs.last_execution_time BETWEEN @StartTest AND @EndTest
	AND PATINDEX('%ThisistoStandardisemyOperatorCostMate%',CAST(qt.TEXT AS VARCHAR(MAX))) > 0
	--OPTION (RECOMPILE);
	PRINT N'Your cost (in seconds) per operator roughly equates to around '+ CONVERT(VARCHAR(20),ISNULL(@secondsperoperator,0)) + ' seconds' ;
	RAISERROR (N'Benchmarking done',0,1) WITH NOWAIT;

			/*----------------------------------------
			--Build database table to use throughout this script
			----------------------------------------*/

	DECLARE @Databases TABLE
	(
		id INT IDENTITY(1,1)
		, databasename VARCHAR(250)
		, [compatibility_level] BIGINT
		, user_access BIGINT
		, user_access_desc VARCHAR(50)
		, [state] BIGINT
		, state_desc  VARCHAR(50)
		, recovery_model BIGINT
		, recovery_model_desc  VARCHAR(50)
		, create_date DATETIME
	);
	SET @dynamicSQL = 'SELECT 
	db.name
	, db.compatibility_level
	, db.user_access
	, db.user_access_desc
	, db.state
	, db.state_desc
	, db.recovery_model
	, db.recovery_model_desc
	, db.create_date
	FROM sys.databases db ';
	IF 'Yes please dont do the system databases' IS NOT NULL
	BEGIN
		SET @dynamicSQL = @dynamicSQL + ' WHERE database_id > 4 AND state NOT IN (1,2,3,6) AND user_access = 0';
	END
	SET @dynamicSQL = @dynamicSQL + ' OPTION (RECOMPILE)'
	INSERT INTO @Databases 

	EXEC sp_executesql @dynamicSQL ;
	SET @Databasei_Max = (SELECT MAX(id) FROM @Databases );

			/*----------------------------------------
			--Get uptime and cache age
			----------------------------------------*/

	SET @oldestcachequery = (SELECT ISNULL(  MIN(creation_time),0.1) FROM sys.dm_exec_query_stats WITH (NOLOCK));
	SET @lastservericerestart = (SELECT create_date FROM sys.databases WHERE name = 'tempdb');
	SET @minutesSinceRestart = (SELECT DATEDIFF(MINUTE,@lastservericerestart,GETDATE()));
	SET @CPUcount = (SELECT cpu_count FROM sys.dm_os_sys_info);
	SELECT @DaysUptime = CAST(DATEDIFF(hh,@lastservericerestart,GETDATE())/24. AS NUMERIC (23,2)) OPTION (RECOMPILE);
	SELECT @DaysOldestCachedQuery = CAST(DATEDIFF(hh,@oldestcachequery,GETDATE())/24. AS NUMERIC (23,2)) OPTION (RECOMPILE);


	IF @DaysUptime = 0 
		SET @DaysUptime = .1;
	IF @DaysOldestCachedQuery = 0 
		SET @DaysOldestCachedQuery = .1;

	SET @CachevsUpdate = @DaysOldestCachedQuery*100/@DaysUptime
	IF @CachevsUpdate < 1
		SET @CachevsUpdate = 1
	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 2,'CACHE - Cache Age As portion of Overall Uptime','------','------'
	INSERT #output_man_script (SectionID, Section,Summary,HoursToResolveWithTesting )
	SELECT 2,'['+REPLICATE('|', @CachevsUpdate) + REPLICATE('''',100-@CachevsUpdate ) +']'
	, 'Uptime:'
	+ CONVERT(VARCHAR(20),@DaysUptime)
	+ '; Oldest Cache:'
	+ CONVERT(VARCHAR(20),@DaysOldestCachedQuery )
	+ '; Cache Timestamp:'
	+ CONVERT(VARCHAR(20),@oldestcachequery,120)
	, CASE WHEN @CachevsUpdate > 50 AND @DaysUptime > 1 THEN 0.5 ELSE 2 END 


	RAISERROR (N'Server uptime and cache age established',0,1) WITH NOWAIT;



	   /*----------------------------------------
			--Internals and Memory usage
			----------------------------------------*/

	SELECT @UsedMemory = CONVERT(MONEY,physical_memory_in_use_kb)/1024 /1000
	FROM sys.dm_os_process_memory WITH (NOLOCK) OPTION (RECOMPILE)
	SELECT @totalMemoryGB = CONVERT(MONEY,total_physical_memory_kb)/1024/1000
	, @AvailableMemoryGB =  CONVERT(MONEY,available_physical_memory_kb)/1024/1000 
	FROM sys.dm_os_sys_memory WITH (NOLOCK) OPTION (RECOMPILE);
	SELECT @VMType = RIGHT(@@version,CHARINDEX('(',REVERSE(@@version)))




	IF @SQLVersion = 11
	BEGIN
		EXEC sp_executesql N'set @_MaxRamServer= (select physical_memory_kb/1024 from sys.dm_os_sys_info);', N'@_MaxRamServer INT OUTPUT', @_MaxRamServer = @MaxRamServer OUTPUT
	END
	ELSE
	IF @SQLVersion in (10,9)
	BEGIN
		EXEC sp_executesql N'set @_MaxRamServer= (select physical_memory_in_bytes/1024/1024 from sys.dm_os_sys_info) ;', N'@_MaxRamServer INT OUTPUT', @_MaxRamServer = @MaxRamServer OUTPUT
	END

	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 3,'MEMORY - SQL Memory usage of total allocated','------','------'
	INSERT #output_man_script (SectionID, Section,Summary ,Details )

 
	SELECT 3,'['+REPLICATE('|', CONVERT(MONEY,CONVERT(FLOAT,@UsedMemory)/CONVERT(FLOAT,@totalMemoryGB)) * 100) + REPLICATE('''',100-(CONVERT(MONEY,CONVERT(FLOAT,@UsedMemory)/CONVERT(FLOAT,@totalMemoryGB)) * 100) ) +']' 
	, 'Sockets:' +  ISNULL(replace(replace(replace(replace(CONVERT(NVARCHAR,CONVERT(VARCHAR(20),([cpu_count] / [hyperthread_ratio]) )), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), '  ',' '),'')
	+'; Virtual CPUs:' +  ISNULL(replace(replace(replace(replace(CONVERT(NVARCHAR,CONVERT(VARCHAR(20),[cpu_count]  )), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), '  ',' ') ,'')
	+'; VM Type:' +  ISNULL(replace(replace(replace(replace(CONVERT(NVARCHAR,ISNULL(@VMType,'')), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), '  ',' ') ,'')
	+'; CPU Affinity:'+  ISNULL(replace(replace(replace(replace(CONVERT(NVARCHAR,ISNULL([affinity_type_desc],'')), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), '  ',' ') ,'')
	+'; MemoryGB:' + ISNULL(CONVERT(VARCHAR(20), CONVERT(MONEY,CONVERT(FLOAT,@totalMemoryGB))),'')
	+'; SQL Allocated:' +ISNULL(CONVERT(VARCHAR(20), CONVERT(MONEY,CONVERT(FLOAT,@UsedMemory))) ,'')
	+'; Suggested MAX:' + ISNULL( CONVERT(VARCHAR(20), CASE 
	 WHEN @MaxRamServer < = 1024*2 THEN @MaxRamServer - 512  /*When the RAM is Less than or equal to 2GB*/
	 WHEN @MaxRamServer < = 1024*4 THEN @MaxRamServer - 1024 /*When the RAM is Less than or equal to 4GB*/
	 WHEN @MaxRamServer < = 1024*16 THEN @MaxRamServer - 1024 - Ceiling((@MaxRamServer-4096) / (4.0*1024))*1024 /*When the RAM is Less than or equal to 16GB*/

		-- My machines memory calculation
		-- RAM= 16GB
		-- Case 3 as above:- 16384 RAM-> MaxMem= 16384-1024-[(16384-4096)/4096] *1024
		-- MaxMem= 12106

		WHEN @MaxRamServer > 1024*16 THEN @MaxRamServer - 4096 - Ceiling((@MaxRamServer-1024*16) / (8.0*1024))*1024 /*When the RAM is Greater than or equal to 16GB*/
		END) ,'')
	+'; Used by SQL:'+ ISNULL(CONVERT(VARCHAR(20), CONVERT(FLOAT,@UsedMemory)),'')
	+'; Memory State:' + ISNULL((SELECT system_memory_state_desc from  sys.dm_os_sys_memory),'')  [Internals: Details] 
	, ('ServerName:'+ ISNULL(replace(replace(replace(replace(CONVERT(NVARCHAR,SERVERPROPERTY('ServerName')), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), '  ',' ') ,'')
		+'; Version:'+ ISNULL(replace(replace(replace(replace(CONVERT(NVARCHAR,LEFT( @@version, PATINDEX('%-%',( @@version))-2) ), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), '  ',' ') ,'')
		+'; VersionNr:'+ ISNULL(replace(replace(replace(replace(CONVERT(NVARCHAR,SERVERPROPERTY('ProductVersion')), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), '  ',' ') ,'')
		+'; OS:'+  ISNULL(replace(replace(replace(replace(CONVERT(NVARCHAR,RIGHT( @@version, LEN(@@version) - PATINDEX('% on %',( @@version))-3) ), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), '  ',' ') ,'')
		+'; Edition:'+ ISNULL(replace(replace(replace(replace(CONVERT(NVARCHAR,SERVERPROPERTY('Edition')), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), '  ',' ') ,'')
		+'; HADR:'+ ISNULL(replace(replace(replace(replace(CONVERT(NVARCHAR,SERVERPROPERTY('IsHadrEnabled')), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), '  ',' ') ,'')
		+'; SA:'+ ISNULL(replace(replace(replace(replace(CONVERT(NVARCHAR,SERVERPROPERTY('IsIntegratedSecurityOnly' )), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), '  ',' '),'')
		+'; Licenses:'+ ISNULL(replace(replace(replace(replace(CONVERT(NVARCHAR,SERVERPROPERTY('NumLicenses' )), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), '  ',' ') ,'')
		+'; Level:'+ ISNULL(replace(replace(replace(replace(CONVERT(NVARCHAR,SERVERPROPERTY('ProductLevel')), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), '  ',' '),''))  [More Details] 
		
		FROM [sys].[dm_os_sys_info] OPTION (RECOMPILE);


			/*----------------------------------------
			--Get some CPU history
			----------------------------------------*/

	SELECT @ts =(
	SELECT cpu_ticks/(cpu_ticks/ms_ticks)
	FROM sys.dm_os_sys_info 
	) OPTION (RECOMPILE)

	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 4,'CPU - Average CPU usage of SQL process as % of total CPU usage','------','------'
	INSERT #output_man_script (SectionID, Section,Summary, HoursToResolveWithTesting  )
	SELECT 4, '['+REPLICATE('|', AVG(CONVERT(MONEY,SQLProcessUtilization))) + REPLICATE('''',100-(AVG(CONVERT(MONEY,SQLProcessUtilization)) )) +']'
	,('Avg CPU:'+ CONVERT(VARCHAR(20),AVG(SQLProcessUtilization))
	+'%; CPU Idle:' + CONVERT(VARCHAR(20),AVG(SystemIdle))
	+ '%; Other:'+ CONVERT(VARCHAR(20), 100 - AVG(SQLProcessUtilization) - AVG(SystemIdle))
	+'%; From:'+ CONVERT(VARCHAR(20), MIN([Event_Time]),120)
	+'; To:' + CONVERT(VARCHAR(20), MAX([Event_Time]),120)) 
	, CASE WHEN AVG(SQLProcessUtilization) > 50 THEN 2 ELSE 0 END 
	FROM 
	(
		SELECT SQLProcessUtilization
		, SystemIdle
		, DATEADD(ms,-1 *(@ts - [timestamp])
		, GETDATE())AS [Event_Time]
		FROM 
		(
			SELECT 
			record.value('(./Record/@id)[1]','int') AS record_id
			, record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]','int') AS [SystemIdle]
			, record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]','int') AS [SQLProcessUtilization]
			, [timestamp]
			FROM 
			(
				SELECT
				[timestamp]
				, convert(xml, record) AS [record] 
				FROM sys.dm_os_ring_buffers 
				WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
				AND record LIKE'%%'
			)AS x
		) as y
	) T1
	HAVING AVG(T1.SQLProcessUtilization) >= (CASE WHEN @ShowWarnings = 1 THEN 20 ELSE 0 END)
	OPTION (RECOMPILE)

	RAISERROR (N'Checked CPU usage for the last 5 minutes',0,1) WITH NOWAIT;


			/*----------------------------------------
			--Failed logins on the server
			----------------------------------------*/

	DECLARE @LoginLog TABLE( LogDate DATETIME, ProcessInfo VARCHAR(200), [Text] VARCHAR(MAX))
	IF  @ShowWarnings = 0 
	BEGIN
		SET @dynamicSQL = 'EXEC sp_readerrorlog 0, 1, ''Login failed'' '
		INSERT @LoginLog
		EXEC sp_executesql @dynamicSQL
		IF EXISTS (SELECT 1 FROM @LoginLog)
		BEGIN
			INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 5, 'LOGINS - Failed Logins','------','------'
			INSERT #output_man_script (SectionID, Section,Summary, HoursToResolveWithTesting  )
			SELECT TOP 15 5, 'Date:'
			+ CONVERT(VARCHAR(20),LogDate,120)
			,replace(replace(replace(replace(CONVERT(NVARCHAR(500),Text), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), '  ',' ')  
			, 0.25
			FROM @LoginLog ORDER BY LogDate DESC
			OPTION (RECOMPILE)
		END
	END
	RAISERROR (N'Server logins have been checked from the log',0,1) WITH NOWAIT;

			/*----------------------------------------
			--Agent log for errors
			----------------------------------------*/

	DECLARE @Errorlog TABLE( LogDate DATETIME, ErrorLevel INT, [Text] VARCHAR(4000))
	/*Ignore the agent logs if you cannot find it, else errors will come*/
	BEGIN TRY

		IF DATEADD(MINUTE,5,@lastservericerestart) <  (SELECT MIN(Login_time) FROM master.dbo.sysprocesses WHERE LEFT(program_name, 8) = 'SQLAgent')
		BEGIN
			PRINT 'Agent started much later than Service. Might point to Agent never being restarted before. If you see the following error, just restart the agent and run this script again >>'
			RAISERROR (N'Msg 0, Level 11, State 0, Line 2032
			A severe error occurred on the current command.  The results, if any, should be discarded.',0,1) WITH NOWAIT;
		END

		IF EXISTS (SELECT 1,* FROM master.dbo.sysprocesses WHERE LEFT(program_name, 8) = 'SQLAgent')
		BEGIN   
			SET @dynamicSQL = 'EXEC sp_readerrorlog 1, 2, ''Error:'' '
			INSERT @Errorlog
			EXEC sp_executesql @dynamicSQL
		END  
		BEGIN   
			SET @dynamicSQL = 'EXEC sp_readerrorlog 1, 1, ''Error:'' '
			INSERT @Errorlog
			EXEC sp_executesql @dynamicSQL
		END
		IF EXISTS (SELECT * FROM @Errorlog)
		BEGIN
			INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 6,'AGENT LOG Errors','------','------'
			INSERT #output_man_script (SectionID, Section,Summary, Details,HoursToResolveWithTesting  )
			SELECT 6, 'Date:'+ CONVERT(VARCHAR(20),LogDate ,120)
			, 'ErrorLevel:'+ CONVERT(VARCHAR(20),ErrorLevel)
			,[Text], 1  FROM @Errorlog ORDER BY LogDate DESC
			
			OPTION (RECOMPILE)
		END  
	END TRY
	BEGIN CATCH
		RAISERROR (N'Error reading agent log',0,1) WITH NOWAIT;
	END CATCH
	RAISERROR (N'Agent log parsed for errors',0,1) WITH NOWAIT;

			/*----------------------------------------
			--Look for failed agent jobs
			----------------------------------------*/
	IF EXISTS (
	SELECT *  
	FROM msdb.dbo.sysjobhistory DBSysJobHistory
		JOIN (
			SELECT DBSysJobHistory.job_id
				, DBSysJobHistory.step_id
				, MAX(DBSysJobHistory.instance_id) as instance_id
			FROM msdb.dbo.sysjobhistory DBSysJobHistory
			GROUP BY DBSysJobHistory.job_id
				, DBSysJobHistory.step_id
		) AS Instance ON DBSysJobHistory.instance_id = Instance.instance_id
	WHERE DBSysJobHistory.run_status <> 1
	)
	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 7, 'FAILED AGENT JOBS','------','------'
	INSERT #output_man_script (SectionID, Section,Summary, Details,HoursToResolveWithTesting  )
	SELECT  7,'Job Name:' + SysJobs.name
		+'; Step:'+ SysJobSteps.step_name 
		+ ' - '+ Job.run_status
		, 'MessageId: ' +CONVERT(VARCHAR(20),Job.sql_message_id)
		+ '; Severity:'+ CONVERT(VARCHAR(20),Job.sql_severity)
		, 'Message:'+ Job.message
		+'; Date:' + CONVERT(VARCHAR(20), Job.exec_date,120)
		, 2
		/*, Job.run_duration
		, Job.server
		, SysJobSteps.output_file_name
		*/
	FROM
	(
		SELECT Instance.instance_id
			,DBSysJobHistory.job_id
			,DBSysJobHistory.step_id
			,DBSysJobHistory.sql_message_id
			,DBSysJobHistory.sql_severity
			,DBSysJobHistory.message
			,(CASE DBSysJobHistory.run_status 
				WHEN 0 THEN 'Failed' 
				WHEN 1 THEN 'Succeeded' 
				WHEN 2 THEN 'Retry' 
				WHEN 3 THEN 'Canceled' 
				WHEN 4 THEN 'In progress'
			  END
			) as run_status
			,((SUBSTRING(CAST(DBSysJobHistory.run_date AS VARCHAR(8)), 5, 2) + '/'
			  + SUBSTRING(CAST(DBSysJobHistory.run_date AS VARCHAR(8)), 7, 2) + '/'
			  + SUBSTRING(CAST(DBSysJobHistory.run_date AS VARCHAR(8)), 1, 4) + ' '
			  + SUBSTRING((REPLICATE('0',6-LEN(CAST(DBSysJobHistory.run_time AS VARCHAR)))
			  + CAST(DBSysJobHistory.run_time AS VARCHAR)), 1, 2) + ':'
			  + SUBSTRING((REPLICATE('0',6-LEN(CAST(DBSysJobHistory.run_time AS VARCHAR)))
			  + CAST(DBSysJobHistory.run_time AS VARCHAR)), 3, 2) + ':'
			  + SUBSTRING((REPLICATE('0',6-LEN(CAST(DBSysJobHistory.run_time as VARCHAR)))
			  + CAST(DBSysJobHistory.run_time AS VARCHAR)), 5, 2))) [exec_date]
			,DBSysJobHistory.run_duration
			,DBSysJobHistory.retries_attempted
			,DBSysJobHistory.server
		FROM msdb.dbo.sysjobhistory DBSysJobHistory
		JOIN (
			SELECT DBSysJobHistory.job_id
				, DBSysJobHistory.step_id
				, MAX(DBSysJobHistory.instance_id) as instance_id
			FROM msdb.dbo.sysjobhistory DBSysJobHistory
			GROUP BY DBSysJobHistory.job_id
				, DBSysJobHistory.step_id
		) AS Instance ON DBSysJobHistory.instance_id = Instance.instance_id
		WHERE DBSysJobHistory.run_status <> 1
	) AS Job
	JOIN msdb.dbo.sysjobs SysJobs
		   ON (Job.job_id = SysJobs.job_id)
	JOIN msdb.dbo.sysjobsteps SysJobSteps
		   ON (Job.job_id = SysJobSteps.job_id 
		   AND Job.step_id = SysJobSteps.step_id)
	OPTION (RECOMPILE);
	RAISERROR (N'Checked for failed agent jobs',0,1) WITH NOWAIT;

			/*----------------------------------------
			--Look for failed backups
			----------------------------------------*/
	IF EXISTS
	(
		SELECT *
		FROM (
			SELECT *
			FROM msdb.dbo.backupset x  
			WHERE backup_finish_date = (
				SELECT max(backup_finish_date) 
				FROM msdb.dbo.backupset 
				WHERE database_name =   x.database_name 
			)    
		) a  
		RIGHT OUTER JOIN sys.databases b  ON a.database_name =   b.name  
		WHERE b.name <> 'tempdb' /*Exclude tempdb*/
		AND (backup_finish_date < DATEADD(d,-1,GETDATE())  
		OR backup_finish_date IS NULL) 
	)
	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 8,'DATABASE - No recent Backups','------','------'
	INSERT #output_man_script (SectionID, Section,Summary, HoursToResolveWithTesting  )

	SELECT 8, name [Section] , ('; Backup Finish Date:' + ISNULL(CONVERT(VARCHAR(20),backup_finish_date,120),'')
		+ '; Type:' +coalesce(type,'NO BACKUP')) [Summary]
		, 2
	FROM (
		SELECT database_name
			, backup_finish_date
			, CASE WHEN  type = 'D' THEN 'Full'    
			  WHEN  type = 'I' THEN 'Differential'                
			  WHEN  type = 'L' THEN 'Transaction Log'                
			  WHEN  type = 'F' THEN 'File'                
			  WHEN  type = 'G' THEN 'Differential File'                
			  WHEN  type = 'P' THEN 'Partial'                
			  WHEN  type = 'Q' THEN 'Differential partial'   
			  END AS type 
		FROM msdb.dbo.backupset x  
		WHERE backup_finish_date = (
			SELECT max(backup_finish_date) 
			FROM msdb.dbo.backupset 
			WHERE database_name =   x.database_name 
		)    
	) a  
	RIGHT OUTER JOIN sys.databases b  ON a.database_name =   b.name  
	WHERE b.name <> 'tempdb' /*Exclude tempdb*/
	AND (backup_finish_date < DATEADD(d,-1,GETDATE())  
	OR backup_finish_date IS NULL)
	OPTION (RECOMPILE);
	RAISERROR (N'Checked for failed backups',0,1) WITH NOWAIT;

			/*----------------------------------------
			--Look for backups and recovery model information
			----------------------------------------*/
	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 9, 'DATABASE - RPO in minutes and RTO in 15 min slices','------','MM:SS'
	INSERT #output_man_script (SectionID, Section,Summary, HoursToResolveWithTesting )
	SELECT 9,  REPLICATE('|',DATEDIFF(MINUTE,CASE 
	WHEN recovery_model = 'FULL' AND x.[Last Transaction Log] > x.[Last Full] THEN x.[Last Transaction Log]
	WHEN recovery_model = 'FULL' AND x.[Last Transaction Log] <= x.[Last Full] THEN [Last Full]
	ELSE x.[Last Full] END, GETDATE())/15) +' ' + 
	CONVERT(VARCHAR(20),DATEDIFF(MINUTE,CASE 
	WHEN recovery_model = 'FULL' AND x.[Last Transaction Log] > x.[Last Full] THEN x.[Last Transaction Log]
	WHEN recovery_model = 'FULL' AND x.[Last Transaction Log] <= x.[Last Full] THEN [Last Full]
	ELSE x.[Last Full] END, GETDATE())) + ' minutes'
	, ('DB:'
	+ database_name
	+ ' - '
	+ recovery_model
	+ ';Last Full:'
	+ CONVERT(VARCHAR(20),x.[Last Full],120)
	+ '; Last TL:'
	+ CONVERT(VARCHAR(20),x.[Last Transaction Log],120)
	+';Best RTO:'
	+ LEFT(CONVERT(VARCHAR(20),DATEADD(SECOND,x.Timetaken,0) ,114),8)
	)
	, 
	CONVERT(VARCHAR(20),CASE 
	WHEN 
	DATEDIFF(HOUR,CASE 
	WHEN recovery_model = 'FULL' AND x.[Last Transaction Log] > x.[Last Full] THEN x.[Last Transaction Log]
	WHEN recovery_model = 'FULL' AND x.[Last Transaction Log] <= x.[Last Full] THEN [Last Full]
	ELSE x.[Last Full] END, GETDATE()) < 1 THEN 0
	WHEN 
	DATEDIFF(HOUR,CASE 
	WHEN recovery_model = 'FULL' AND x.[Last Transaction Log] > x.[Last Full] THEN x.[Last Transaction Log]
	WHEN recovery_model = 'FULL' AND x.[Last Transaction Log] <= x.[Last Full] THEN [Last Full]
	ELSE x.[Last Full] END, GETDATE()) BETWEEN 1 AND 2 THEN 2
	WHEN 
	DATEDIFF(HOUR,CASE 
	WHEN recovery_model = 'FULL' AND x.[Last Transaction Log] > x.[Last Full] THEN x.[Last Transaction Log]
	WHEN recovery_model = 'FULL' AND x.[Last Transaction Log] <= x.[Last Full] THEN [Last Full]
	ELSE x.[Last Full] END, GETDATE()) BETWEEN 2 AND 8 THEN 4
	WHEN 
	DATEDIFF(HOUR,CASE 
	WHEN recovery_model = 'FULL' AND x.[Last Transaction Log] > x.[Last Full] THEN x.[Last Transaction Log]
	WHEN recovery_model = 'FULL' AND x.[Last Transaction Log] <= x.[Last Full] THEN [Last Full]
	ELSE x.[Last Full] END, GETDATE()) BETWEEN 8 AND 24 THEN 6

	ELSE 8 END
	) 

	FROM 
	(
		SELECT  database_name, bs.recovery_model
		, MAX(DATEDIFF(SECOND,backup_start_date, backup_finish_date)) 'Timetaken'
		, MAX(CASE WHEN  type = 'D' THEN backup_finish_date ELSE 0 END) 'Last Full'   
		, MIN(CASE WHEN  type = 'D' THEN backup_start_date ELSE 0 END) 'First Full'             
		, MAX(CASE WHEN  type = 'L' THEN backup_finish_date ELSE 0 END) 'Last Transaction Log'  
		, MIN(CASE WHEN  type = 'L' THEN backup_start_date ELSE 0 END) 'First Transaction Log'  
		FROM  msdb.sys.databases dbs
		LEFT OUTER JOIN  msdb.dbo.backupset bs ON dbs.name = bs.database_name  
		AND dbs.recovery_model_desc COLLATE DATABASE_DEFAULT = bs.recovery_model COLLATE DATABASE_DEFAULT
		WHERE type IN ('D', 'L')
		AND database_name NOT IN ('model','master','msdb')
		GROUP BY database_name, bs.recovery_model
	) x 
	ORDER BY [Last Full] ASC
	OPTION (RECOMPILE);
	RAISERROR (N'Recovery Model information matched with backups',0,1) WITH NOWAIT;

			/*----------------------------------------
			--Check for disk space and latency on the server
			----------------------------------------*/

	DECLARE @fixeddrives TABLE(drive VARCHAR(5), FreeSpaceMB MONEY)
	INSERT @fixeddrives
	EXEC master..xp_fixeddrives 

	/* more useful info
	SELECT * FROM sys.dm_os_sys_info 
	EXEC xp_msver
	*/
	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 10, 'Disk Latency and Space','------','------'
	INSERT #output_man_script (SectionID, Section,Summary,HoursToResolveWithTesting  )

	SELECT 10, UPPER([Drive]) + '\ ' + REPLICATE('|',CASE WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 ELSE (io_stall/(num_of_reads + num_of_writes)) END) +' '+ CONVERT(VARCHAR(20), CASE WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 ELSE (io_stall/(num_of_reads + num_of_writes)) END) + ' ms' 
	, 'FreeSpace:'+ CONVERT(VARCHAR(20),[AvailableGBs]) + 'GB'
	+ '; Read:' + CONVERT(VARCHAR(20),CASE WHEN num_of_reads = 0 THEN 0 ELSE (io_stall_read_ms/num_of_reads) END )
	+ '; Write:' + CONVERT(VARCHAR(20), CASE WHEN io_stall_write_ms = 0 THEN 0 ELSE (io_stall_write_ms/num_of_writes) END )
	+ '; Total:' + CONVERT(VARCHAR(20), CASE WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 ELSE (io_stall/(num_of_reads + num_of_writes)) END) 
	+ ' (Latency in ms)'
	, CASE WHEN CASE WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 ELSE (io_stall/(num_of_reads + num_of_writes)) END > 25 THEN 0.4 * (io_stall/(num_of_reads + num_of_writes))/5  ELSE 0 END
	/*
	, CASE WHEN num_of_reads = 0 THEN 0 ELSE (num_of_bytes_read/num_of_reads) END AS [Avg Bytes/Read]
	, CASE WHEN io_stall_write_ms = 0 THEN 0 ELSE (num_of_bytes_written/num_of_writes) END AS [Avg Bytes/Write]
	, CASE WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 ELSE ((num_of_bytes_read + num_of_bytes_written)/(num_of_reads + num_of_writes)) END AS [Avg Bytes/Transfer]
	*/
	FROM (
	SELECT LEFT(mf.physical_name, 2) AS Drive
		, MAX(CAST(fd.FreeSpaceMB / 1024 as decimal(20,2))) [AvailableGBs]
		, SUM(num_of_reads) AS num_of_reads
		, SUM(io_stall_read_ms) AS io_stall_read_ms
		, SUM(num_of_writes) AS num_of_writes
		, SUM(io_stall_write_ms) AS io_stall_write_ms
		, SUM(num_of_bytes_read) AS num_of_bytes_read
		, SUM(num_of_bytes_written) AS num_of_bytes_written
		, SUM(io_stall) AS io_stall
		  FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
		  INNER JOIN sys.master_files AS mf WITH (NOLOCK)
		  ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
		  INNER JOIN @fixeddrives fd ON fd.drive COLLATE DATABASE_DEFAULT = LEFT(mf.physical_name, 1) COLLATE DATABASE_DEFAULT
	  
		  GROUP BY LEFT(mf.physical_name, 2)) AS tab
	ORDER BY CASE WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 ELSE (io_stall/(num_of_reads + num_of_writes)) END OPTION (RECOMPILE);
	RAISERROR (N'Checked for disk latency and space',0,1) WITH NOWAIT;

			/*----------------------------------------
			--Check for disk space on the server
			----------------------------------------*/



	SELECT @Kb = 1024.0;
	SELECT @PageSize=v.low/@Kb 
	FROM master..spt_values v 
	WHERE v.number=1 AND v.type='E';

	INSERT @LogSpace 
	EXEC sp_executesql N'DBCC sqlperf(logspace) WITH NO_INFOMSGS';
	INSERT #LogSpace
	SELECT DatabaseName
	, LogSize
	, SpaceUsedPercent
	, Status 
	, NULL
	FROM @LogSpace 
	OPTION (RECOMPILE)

	SET @Databasei_Count = 1; 
	WHILE @Databasei_Count <= @Databasei_Max 
	BEGIN 
		SELECT @DatabaseName = d.databasename, @DatabaseState = d.state FROM @Databases d WHERE id = @Databasei_Count AND d.state NOT IN (2,6)
		IF EXISTS( SELECT @DatabaseName)
		BEGIN
			SET @dynamicSQL = 'USE [' + @DatabaseName + '];
			DBCC showfilestats WITH NO_INFOMSGS;'
			INSERT @FileStats
			EXEC sp_executesql @dynamicSQL;
			SET @dynamicSQL = 'USE [' + @DatabaseName + '];
			SELECT ''' +@DatabaseName + ''', filename, size, ISNULL(FILEGROUP_NAME(groupid),''LOG''), [name] ,maxsize, growth  FROM dbo.sysfiles sf ; '
			
			INSERT @FileSize 
			EXEC sp_executesql @dynamicSQL;
			SET @dynamicSQL = 'USE [' + @DatabaseName + '];
			DBCC loginfo WITH NO_INFOMSGS;'

			INSERT #dbccloginfo
			EXEC sp_executesql @dynamicSQL;

			SELECT @VLFcount = COUNT(*) FROM #dbccloginfo 
			DELETE FROM #dbccloginfo
			UPDATE #LogSpace SET VLFCount =  @VLFcount WHERE DatabaseName = @DatabaseName
		END
		SET @Databasei_Count = @Databasei_Count + 1
	END

	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 11, 'DATABASE FILES - Disk Usage Ordered by largest','------','------'
	INSERT #output_man_script (SectionID, Section,Summary, Details)

	SELECT 11,
	REPLICATE('|',100-[FreeSpace %]) + REPLICATE('''',[FreeSpace %]) +' ('+ CONVERT(VARCHAR(20),CONVERT(INT,ROUND(100-[FreeSpace %],0))) + '% of ' + CONVERT(VARCHAR(20),CONVERT(MONEY,FileSize/1024)) + ')'
	, (
	+ 'DB size:'
	+ CONVERT(VARCHAR(20),CONVERT(MONEY,TotalSize/1024))
	+ ' GB; DB:'
	+ DatabaseName 
	+ '; SizeGB:'
	+ CONVERT(VARCHAR(20),CONVERT(MONEY,FileSize/1024))
	+ '; Growth:'
	+ CASE WHEN growth <= 100 THEN CONVERT(VARCHAR(20),growth) + '%' ELSE CONVERT(VARCHAR(20),growth/128) + 'MB' END 
	)
	,(UPPER(DriveLetter)
	+' FG:'
	+ FileGroupName 
	+ CASE WHEN FileGroupName = 'LOG' THEN '(' + CONVERT(VARCHAR(20),VLFCount) + 'vlfs)' ELSE '' END
	--, LogicalName  
	+ '; MAX:'
	+ CONVERT(VARCHAR(20),maxsize)
	+ '; Used:' 
	+ CONVERT(VARCHAR(20),100-[FreeSpace %] )
	+'%'
	+'; Path:'
	+ [FileName] 
	)
 

	FROM (
	SELECT
	 DatabaseName = fsi.DatabaseName
	 , fs2.TotalSize
	 , FileGroupName = fsi.FileGroupName
	 , maxsize
	 , growth
	 , LogicalName = RTRIM(fsi.LogicalName)
	 , [FileName] = RTRIM(fsi.FileName)
	 , DriveLetter = LEFT(RTRIM(fsi.FileName),2)
	 , FileSize = CAST(fsi.FileSize*@PageSize/@Kb as decimal(15,2))
	 , UsedSpace = CAST(ISNULL((fs.UsedExtents*@PageSize*8.0/@Kb), fsi.FileSize*@PageSize/@Kb * ls.SpaceUsedPercent/100.0) as MONEY)
	 , FreeSpace = CAST(ISNULL(((fsi.FileSize - UsedExtents*8.0)*@PageSize/@Kb), (100.0-ls.SpaceUsedPercent)/100.0 * fsi.FileSize*@PageSize/@Kb) as MONEY)
	 ,[FreeSpace %] = CAST(ISNULL(((fsi.FileSize - UsedExtents*8.0) / fsi.FileSize * 100.0), 100-ls.SpaceUsedPercent) as MONEY) 
	 , VLFCount 
	FROM @FileSize fsi  
	LEFT JOIN @FileStats fs ON fs.FileName = fsi.FileName  
	LEFT JOIN #LogSpace ls ON ls.DatabaseName COLLATE DATABASE_DEFAULT = fsi.DatabaseName   COLLATE DATABASE_DEFAULT
	LEFT OUTER JOIN  (SELECT DatabaseName, SUM(CAST(FileSize*@PageSize/@Kb as decimal(15,2))) TotalSize FROM @FileSize F1 GROUP BY DatabaseName) fs2 ON  fs2.DatabaseName COLLATE DATABASE_DEFAULT =  fsi.DatabaseName COLLATE DATABASE_DEFAULT
	 ) T1
	WHERE T1.[FreeSpace %] < (CASE WHEN @ShowWarnings = 1 THEN 20 ELSE 100 END)
	ORDER BY TotalSize DESC, DatabaseName ASC, FileSize DESC
	OPTION (RECOMPILE)
	RAISERROR (N'Checked free space',0,1) WITH NOWAIT;


			/*----------------------------------------
			--Look at caching plans,  size matters here
			----------------------------------------*/
	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 12, 'CACHING PLANS - as % of total memory used by SQL','------','------'
	INSERT #output_man_script (SectionID, Section,Summary ,Details )
	SELECT 12, REPLICATE('|',[1 use size]/[Size MB]*100) + REPLICATE('''',100- [1 use size]/[Size MB]*100) +' '+ CONVERT(VARCHAR(20),CONVERT(INT,[1 use size]/[Size MB]*100)) +'% of '
	+CONVERT(VARCHAR(20),CONVERT(BIGINT,[Size MB])) +'MB is 1 use' 
	, objtype 
	+'; Plans:'+ CONVERT(VARCHAR(20),[Total Use])
	+'; Total Refs:'+ CONVERT(VARCHAR(20),[Total Rfs])
	+'; Avg Use:'+ CONVERT(VARCHAR(20),[Avg Use])
	, CONVERT(VARCHAR(20),[Size MB]) + 'MB'
	+'; Single use:'+ CONVERT(VARCHAR(20),[1 use size]*100/[Size MB]) + '%'
	+'; Single plans:'+ CONVERT(VARCHAR(20),[1 use count])

	FROM (
	SELECT objtype
	, SUM(refcounts)[Total Rfs]
	, AVG(refcounts) [Avg Refs]
	, SUM(usecounts) [Total Use]
	, AVG(usecounts) [Avg Use]
	, CONVERT(MONEY,SUM(size_in_bytes*0.000000953613)) [Size MB]
	, SUM(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) [1 use count]
	, SUM(CASE WHEN usecounts = 1 THEN CONVERT(MONEY,size_in_bytes*0.000000953613) ELSE 0 END) [1 use size]
	FROM sys.dm_exec_cached_plans GROUP BY objtype
	) TCP
	OPTION (RECOMPILE)

	RAISERROR (N'Got cached plan statistics',0,1) WITH NOWAIT;

			/*----------------------------------------
			--Get the top 10 query plan bloaters for single use queries
			----------------------------------------*/

	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 13,'CACHING PLANS - TOP 10 single use plans','------','------'
	INSERT #output_man_script (SectionID, Section,Summary ,Details )
	SELECT TOP(10) 13, REPLICATE('|',cp.size_in_bytes/1024/1000) + ' ' + CONVERT(VARCHAR(20),CONVERT(MONEY,cp.size_in_bytes)/1024) + 'KB'
	, cp.cacheobjtype
	+ ' '+ cp.objtype
	+ '; SizeMB:' + CONVERT(VARCHAR(20),CONVERT(MONEY,cp.size_in_bytes)/1024/1000)
	, replace(replace(replace(replace(LEFT(CONVERT(NVARCHAR(4000),[text]),@LeftText), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), '  ',' ') AS [QueryText]
	FROM sys.dm_exec_cached_plans AS cp WITH (NOLOCK)
	CROSS APPLY sys.dm_exec_sql_text(plan_handle) 
	WHERE cp.cacheobjtype = N'Compiled Plan' 
	AND cp.objtype IN (N'Adhoc', N'Prepared') 
	AND cp.usecounts = 1
	ORDER BY cp.size_in_bytes DESC OPTION (RECOMPILE);

	RAISERROR (N'Got cached plan statistics - Biggest single use plans',0,1) WITH NOWAIT;

			/*----------------------------------------
			--Find cpu load, io and memory per DB
			----------------------------------------*/

	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 14, 'CPU IO Memory','------','------'
	INSERT #output_man_script (SectionID, Section,Summary ,Details )

	SELECT 14,  REPLICATE('|',CONVERT(MONEY,T2.[TotalIO])/ SUM(T2.[TotalIO]) OVER()* 100.0) 
	+ REPLICATE('''',100 - CONVERT(MONEY,T2.[TotalIO])/ SUM(T2.[TotalIO]) OVER()* 100.0) + '' + CONVERT(VARCHAR(20), CONVERT(INT,ROUND(CONVERT(MONEY,T2.[TotalIO])/ SUM(T2.[TotalIO]) OVER()* 100.0,0))) +'% IO '
	, T1.DatabaseName
	+ '; CPU: ' + ISNULL(CONVERT(VARCHAR(20),CONVERT(INT,ROUND([CPU_Time(Ms)]/1000 * 1.0 /SUM([CPU_Time(Ms)]/1000) OVER()* 100.0,0))),'0') +'%'
	+ '; IO:' +  ISNULL(CONVERT(VARCHAR(20),CONVERT(INT,ROUND(CONVERT(MONEY,T2.[TotalIO])/ SUM(T2.[TotalIO]) OVER()* 100.0 ,0))) ,'0')+'%'
	+ '; Buffer:' +  ISNULL(CONVERT(VARCHAR(20),CONVERT(INT,ROUND(CONVERT(MONEY,src.db_buffer_pages )/ SUM(src.db_buffer_pages ) OVER()* 100.0 ,0))),'0')+'%'
	+ '; Disk GB:' +  + ISNULL(CONVERT(VARCHAR(20),CONVERT(MONEY,TotalSize/1024)),'')

	, ' CPU time(s):' + ISNULL(CONVERT(VARCHAR(20),[CPU_Time(Ms)]) + ' (' + CONVERT(VARCHAR(20),CAST([CPU_Time(Ms)]/1000 * 1.0 /SUM([CPU_Time(Ms)]/1000) OVER()* 100.0 AS DECIMAL(5, 2))) + '%)','') 
	+ '; Total IO: ' +  ISNULL(CONVERT(VARCHAR(20),[TotalIO]) + ' ; Reads: ' + CONVERT(VARCHAR(20),T2.[Number of Reads]) +' ; Writes: '+ CONVERT(VARCHAR(20),T2.[Number of Writes]),'')
	+ '; Buffer Pages:' +  ISNULL(CONVERT(VARCHAR(20),src.db_buffer_pages),'')
	+ '; Buffer MB:'+ CONVERT(VARCHAR(20),src.db_buffer_pages / 128) 
	

	FROM(
		SELECT TOP 100 PERCENT
		DatabaseID
		,DB_Name(DatabaseID)AS [DatabaseName]
		,SUM(total_worker_time)AS [CPU_Time(Ms)]
		FROM sys.dm_exec_query_stats AS qs
		CROSS APPLY
		(
			SELECT CONVERT(int, value)AS [DatabaseID]
			FROM sys.dm_exec_plan_attributes(qs.plan_handle)
			WHERE attribute =N'dbid'
		)AS epa
		GROUP BY DatabaseID
		ORDER BY SUM(total_worker_time) DESC
	) T1
	LEFT OUTER JOIN (
	SELECT
		Name AS 'DatabaseName'
		, SUM(num_of_reads) AS'Number of Reads'
		, SUM(num_of_writes) AS'Number of Writes'
		, SUM(num_of_writes) +  SUM(num_of_reads) [TotalIO]
		FROM sys.dm_io_virtual_file_stats(NULL,NULL) I
		INNER JOIN sys.databases d ON I.database_id = d.database_id
		GROUP BY Name
	) T2 ON T1.DatabaseName = T2.DatabaseName
	LEFT OUTER JOIN 
	(
		SELECT database_id,
		db_buffer_pages =COUNT_BIG(*)
		FROM sys.dm_os_buffer_descriptors
		GROUP BY database_id
	) src ON src.database_id = T1.DatabaseID
	LEFT OUTER JOIN  (SELECT DatabaseName, SUM(CAST(FileSize*@PageSize/@Kb as decimal(15,2))) TotalSize FROM @FileSize F1 GROUP BY DatabaseName) fs2 ON  fs2.DatabaseName COLLATE DATABASE_DEFAULT =  T2.DatabaseName COLLATE DATABASE_DEFAULT

	WHERE T1.DatabaseName IS NOT NULL
	ORDER BY [TotalIO] DESC,[CPU_Time(Ms)] DESC
	OPTION (RECOMPILE) ;

	RAISERROR (N'Checked CPU, IO  and memory usage',0,1) WITH NOWAIT;

			/*----------------------------------------
			--Get to wait types, the TOP 10 would be good for now
			----------------------------------------*/

	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 15, 'TOP 10 WAIT STATS','------','------'
	
	--INSERT @Waits 
	INSERT #output_man_script (SectionID, Section,Summary,HoursToResolveWithTesting  )
	SELECT TOP 10 15,
	REPLICATE ('|', 100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER())+ REPLICATE ('''', 100- 100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER()) + CONVERT(VARCHAR(20), CONVERT(INT,ROUND(100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER(),0))) + '%'
	, [wait_type] + ':' 
	+ ';HH:' + CONVERT(VARCHAR(20),CONVERT(MONEY,SUM(wait_time_ms / 1000.0 / 60 / 60) OVER (PARTITION BY wait_type)))
	+ ':MM/HH/VCPU:' + CONVERT(VARCHAR(20),CONVERT(MONEY,SUM(60.0 * wait_time_ms) OVER (PARTITION BY wait_type) / @minutesSinceRestart /60000/@CPUcount))
	+'; Wait(s):'+ CONVERT(VARCHAR(20),CONVERT(BIGINT,[wait_time_ms] / 1000.0)) + '(s)'
	+'; Wait count:' + CONVERT(VARCHAR(20),[waiting_tasks_count])
	, CASE 
		WHEN [wait_type] = 'CXPACKET' THEN 5
		WHEN [wait_type] LIKE 'PAGEIOLATCH%' THEN 8
		ELSE 0
	END
	FROM sys.dm_os_wait_stats
	WHERE 
	[wait_type] NOT IN (
			N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR',
			N'BROKER_TASK_STOP', N'BROKER_TO_FLUSH',
			N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
			N'CHKPT', N'CLR_AUTO_EVENT',
			N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
 
			-- Maybe uncomment these four if you have mirroring issues
	 --       N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE',
	 --       N'DBMIRROR_WORKER_QUEUE', N'DBMIRRORING_CMD',

			N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
			N'EXECSYNC', N'FSAGENT',
			N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
 
			-- Maybe uncomment these six if you have AG issues
			N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
			N'HADR_LOGCAPTURE_WAIT', N'HADR_NOTIFICATION_DEQUEUE',
			N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
 
			N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP',
			N'LOGMGR_QUEUE', N'MEMORY_ALLOCATION_EXT',
			N'ONDEMAND_TASK_QUEUE',
			N'PREEMPTIVE_XE_GETTARGETSTATE',
			N'PWAIT_ALL_COMPONENTS_INITIALIZED',
			N'PWAIT_DIRECTLOGCONSUMER_GETNEXT',
			N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', N'QDS_ASYNC_QUEUE',
			N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
			N'QDS_SHUTDOWN_QUEUE', N'REDO_THREAD_PENDING_WORK',
			N'REQUEST_FOR_DEADLOCK_SEARCH', N'RESOURCE_QUEUE',
			N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH',
			N'SLEEP_DBSTARTUP', N'SLEEP_DCOMSTARTUP',
			N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
			N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP',
			N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
			N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT',
			N'SP_SERVER_DIAGNOSTICS_SLEEP', N'SQLTRACE_BUFFER_FLUSH',
			N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
			N'SQLTRACE_WAIT_ENTRIES', N'WAIT_FOR_RESULTS',
			N'WAITFOR', N'WAITFOR_TASKSHUTDOWN',
			N'WAIT_XTP_RECOVERY',
			N'WAIT_XTP_HOST_WAIT', N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
			N'WAIT_XTP_CKPT_CLOSE', N'XE_DISPATCHER_JOIN',
			N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT')
		AND [waiting_tasks_count] > 0
	ORDER BY [wait_time_ms] DESC
	OPTION (RECOMPILE)

	RAISERROR (N'Filtered wait stats have been prepared',0,1) WITH NOWAIT;

	RAISERROR (N'Looking at query stats.. this might take a wee while',0,1) WITH NOWAIT;
			/*----------------------------------------
			--Look at Plan Cache and DMV to find missing index impacts
			----------------------------------------*/

	INSERT #querystats
		SELECT
			qs.execution_count
			, qs.total_logical_reads
			,  CONVERT(MONEY,qs.total_logical_reads)/1000 [Total_MBsRead]
			, qs.total_logical_writes
			,  CONVERT(MONEY,qs.total_logical_writes)/1000 [Total_MBsWrite]
			, qs.total_worker_time,  CONVERT(MONEY,qs.total_elapsed_time)/1000000 total_elapsed_time_in_S
			, qs.total_elapsed_time
			, qs.last_execution_time
			, qs.plan_handle
			, qs.sql_handle
			FROM sys.dm_exec_query_stats qs WITH (NOLOCK)
			ORDER BY [Total_MBsRead] DESC, qs.total_elapsed_time, qs.execution_count
	INSERT #output_man_script (SectionID, Section,Summary, Details, QueryPlan) SELECT 16, 'PLAN INSIGHT - MISSING INDEX','------','------',NULL
	;WITH XMLNAMESPACES  
		   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
	INSERT #output_man_script (SectionID, Section,Summary, Details, QueryPlan,HoursToResolveWithTesting)
	SELECT 16,
		REPLICATE('|',TFF.[SecondsSavedPerDay]/28800*100) + ' $' + CONVERT(VARCHAR(20),CONVERT(MONEY,TFF.[SecondsSavedPerDay]/28800) * @FTECost) + 'pa ('+CONVERT(VARCHAR(20),CONVERT(MONEY,TFF.[SecondsSavedPerDay]/28800) )+ 'FTE)' [Section]
		,CONVERT(VARCHAR(20),TFF.execution_count) + ' executions'
		+ '; Cost:' + CONVERT(VARCHAR(20),TFF.SubTreeCost)
		+ '; GuessingCost(s):' + CONVERT(VARCHAR(20),(ISNULL(TFF.SubTreeCost * @secondsperoperator * TFF.execution_count * (100-TFF.impact),0)))
		+ '; Impact:' +CONVERT(VARCHAR(20), TFF.impact)
		+ '; EstRows:' + CONVERT(VARCHAR(20),TFF.estRows)
		+ '; Magic:' + CONVERT(VARCHAR(20),TFF.Magic)
		+ '; ' + CONVERT(VARCHAR(20), TFF.SecondsSavedPerDay) + '(s)'
		+ '; Total time:' + CONVERT(VARCHAR(20),TFF.total_elapsed_time/1000/1000) + '(s)' [Summary]
		, ';'+TFF.[statement] 
		+ ISNULL(':EQ:'+ TFF.equality_columns,'')
		+ ISNULL(':INEQ:'+ TFF.inequality_columns,'')
		+ ISNULL(':INC:'+ TFF.include_columns,'') [Details]
		, tp.query_plan
		, CONVERT(VARCHAR(20),CONVERT(MONEY,TFF.[SecondsSavedPerDay]/28800 * 8 * 3))
		FROM (
		SELECT 
		 SUM(TF.SubTreeCost) SubTreeCost
		, SUM(CONVERT(FLOAT,TF.estRows )) estRows
		, SUM(ISNULL([Magic],0)) [Magic]
		, SUM(TF.impact/100 * TF.total_elapsed_time )/1000000/@DaysOldestCachedQuery  [SecondsSavedPerDay]
		, TF.impact	
		, TF.execution_count	
		, TF.total_elapsed_time	
		, TF.database_id	
		, TF.OBJECT_ID	
		, TF.statement	
		, TF.equality_columns	
		, TF.inequality_columns	
		, TF.include_columns
		, TF.plan_handle
	
		FROM
		(
		SELECT 
		--, query_plan
		--, n.value('(@StatementText)[1]', 'VARCHAR(4000)') AS sql_text
		  CONVERT(FLOAT,n.value('(@StatementSubTreeCost)', 'VARCHAR(4000)')) AS SubTreeCost
		, n.value('(@StatementEstRows)', 'VARCHAR(4000)') AS estRows
		, CONVERT(FLOAT,n.value('(//MissingIndexGroup/@Impact)[1]', 'FLOAT')) AS impact
		, tab.execution_count
		, tab.total_elapsed_time
		, tab.plan_handle
		, DB_ID(REPLACE(REPLACE(n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)'),'[',''),']','')) AS database_id
		, OBJECT_ID(n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)') + '.' + 
				   n.value('(//MissingIndex/@Schema)[1]', 'VARCHAR(128)') + '.' + 
				   n.value('(//MissingIndex/@Table)[1]', 'VARCHAR(128)')) AS OBJECT_ID, 
			   n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)') + '.' + 
				   n.value('(//MissingIndex/@Schema)[1]', 'VARCHAR(128)') + '.' + 
				   n.value('(//MissingIndex/@Table)[1]', 'VARCHAR(128)')  
			   AS statement, 
			   (   SELECT DISTINCT c.value('(@Name)[1]', 'VARCHAR(128)') + ', ' 
				   FROM n.nodes('//ColumnGroup') AS t(cg) 
				   CROSS APPLY cg.nodes('Column') AS r(c) 
				   WHERE cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'EQUALITY' 
				   FOR  XML PATH('') 
			   ) AS equality_columns, 
				(  SELECT DISTINCT c.value('(@Name)[1]', 'VARCHAR(128)') + ', ' 
				   FROM n.nodes('//ColumnGroup') AS t(cg) 
				   CROSS APPLY cg.nodes('Column') AS r(c) 
				   WHERE cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'INEQUALITY' 
				   FOR  XML PATH('') 
			   ) AS inequality_columns, 
			   (   SELECT DISTINCT c.value('(@Name)[1]', 'VARCHAR(128)') + ', ' 
				   FROM n.nodes('//ColumnGroup') AS t(cg) 
				   CROSS APPLY cg.nodes('Column') AS r(c) 
				   WHERE cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'INCLUDE' 
				   FOR  XML PATH('') 
			   ) AS include_columns 

		FROM  
		( 
		   SELECT query_plan
		   , qs.*
		   FROM (    
					SELECT plan_handle
					,SUM(qs.execution_count			)execution_count
					,MAX(qs.total_elapsed_time		)total_elapsed_time
				   FROM #querystats qs WITH(NOLOCK)
				   WHERE qs.Id <= @TopQueries  
				   GROUP BY  plan_handle
				   HAVING SUM(qs.total_elapsed_time ) > @MinWorkerTime
				 ) AS qs 
			OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) tp  
		--	WHERE tp.query_plan.exist('//MissingIndex')=1 
				--AND qs.execution_count > @MinExecutionCount   
		) AS tab 
		CROSS APPLY query_plan.nodes('//StmtSimple') AS q(n) 
		) TF
		LEFT OUTER JOIN (
		SELECT TOP 100 PERCENT (( ISNULL(user_seeks,0) + ISNULL(user_scans,0 ) * avg_total_user_cost * avg_user_impact)/1) [Magic]
		,user_seeks 
		,user_scans
		,user_seeks + user_scans AllScans
		,avg_total_user_cost
		,avg_user_impact
		, mid.object_id
		, [statement]
		, equality_columns
		, inequality_columns
		, included_columns
		FROM sys.dm_db_missing_index_group_stats AS migs 
				INNER JOIN sys.dm_db_missing_index_groups AS mig ON migs.group_handle = mig.index_group_handle 
				INNER JOIN sys.dm_db_missing_index_details AS mid ON mig.index_handle = mid.index_handle 
				LEFT OUTER JOIN sys.objects WITH (nolock) ON mid.OBJECT_ID = sys.objects.OBJECT_ID 
				ORDER BY [Magic] DESC
		) TStats ON TStats.object_id = TF.OBJECT_ID
		AND TStats.statement = TF.statement
		AND ISNULL(TStats.equality_columns +', ',0) = ISNULL(TF.equality_columns ,0)
		AND ISNULL(TStats.inequality_columns +', ',0) = ISNULL(TF.inequality_columns,0)
		AND ISNULL(TStats.included_columns +', ',0) = ISNULL(TF.include_columns,0)

		GROUP BY  TF.impact	
		, TF.execution_count
		, TF.total_elapsed_time	
		, TF.database_id	
		, TF.OBJECT_ID	
		, TF.statement	
		, TF.equality_columns	
		, TF.inequality_columns	
		, TF.include_columns
		, TF.plan_handle
		) TFF
		OUTER APPLY sys.dm_exec_query_plan(TFF.plan_handle) tp  
		WHERE [statement] <> '[msdb].[dbo].[backupset]'
		ORDER BY  [SecondsSavedPerDay] DESC, total_elapsed_time DESC OPTION (RECOMPILE);

	INSERT #output_man_script (SectionID, Section,Summary, Details, QueryPlan) SELECT 17,'PLAN INSIGHT - EVERYTHING','------','------',NULL
	INSERT #output_man_script (SectionID, Section,Summary, Details, QueryPlan) 

	SELECT  17,
	 /*Bismillah, Find most intensive query*/
	REPLICATE ('|', CASE WHEN [Total_GBsRead]*[Impact%] = 0 THEN 0 ELSE 100.0 * [Total_GBsRead]*[Impact%]  / SUM ([Total_GBsRead]*[Impact%]) OVER() END)   
	+ CASE WHEN [Impact%] > 0 THEN CONVERT(VARCHAR(20),CONVERT(INT,ROUND(100.0 * [Total_GBsRead]*[Impact%]  / SUM ([Total_GBsRead]*[Impact%]) OVER(),0))) + '%' ELSE '' END [Section]

		, CONVERT(VARCHAR(20),[execution_count])
		+' events'
		+CASE 
			WHEN [Impact%] > 0 AND [ImpactType] = 'Missing Index'   THEN ' Impacted by: Missing Index (' + CONVERT(VARCHAR(20),[Impact%]) + '%)'
			WHEN [Impact%] > 0 AND [ImpactType] ='CONVERT_IMPLICIT' THEN ' Impacted by: CONVERT_IMPLICIT' 
			ELSE '' END  
		+ '; ' + CONVERT(VARCHAR(20),[Total_GBsRead]) +'GBs of I/O'
		+ '(' + CONVERT(VARCHAR(20),[total_logical_reads]) + ' pages)'
		+' took:' + CONVERT(VARCHAR(20),[total_elapsed_time_in_S]) +'(seconds)' [Summary]
		, ISNULL([Database] +':','')
		+ CASE WHEN [Impact%] > 0
		THEN 'Could reduce to: ' + CONVERT(VARCHAR(20), [Total_GBsRead] -([Impact%]/100 * [Total_GBsRead])) + 'GB'+ ' in ' + CONVERT(VARCHAR(20), CONVERT(INT,[total_elapsed_time_in_S] -([Impact%]/100) * [total_elapsed_time_in_S])) +'(s)'
		ELSE ''
		END
		+ '; Writes:'+ CONVERT(VARCHAR(20),[total_logical_writes])
		+ '(' + CONVERT(VARCHAR(20),[Total_GBsWrite]) + 'GB)' [Details]
		--, T1.[total_worker_time], T1.[last_execution_time]
		, [query_plan] /*This makes the query crawl, only add back when you have time or need to see the full plans, but you dont want this for 10k rows*/
		FROM (
	
		SELECT TOP 100 PERCENT
		CASE 
		WHEN PATINDEX('%MissingIndexes%',CAST(qp.query_plan AS NVARCHAR(MAX))) > 0 THEN 'Missing Index' 
		WHEN PATINDEX('%PlanAffectingConvert%',CAST(qp.query_plan AS NVARCHAR(MAX))) > 0 THEN 'CONVERT_IMPLICIT' ELSE NULL END  [ImpactType]
		, CASE 
		WHEN PATINDEX('%MissingIndexGroup Impact%',CAST(qp.query_plan AS NVARCHAR(MAX))) > 0  
			THEN CONVERT(MONEY,REPLACE(REPLACE(REPLACE(SUBSTRING(CONVERT(NVARCHAR(MAX),qp.query_plan),PATINDEX('%MissingIndexGroup Impact%',CAST(qp.query_plan AS NVARCHAR(MAX)))+26,6),'"><',''),'"',''),'>',''))
		ELSE NULL 
		END [Impact%]
		, T1.[execution_count], T1.[total_logical_reads], T1.[total_logical_writes]
		, [Total_MBsRead]/1000 [Total_GBsRead]
		, [Total_MBsWrite]/1000 [Total_GBsWrite]
		, T1.[total_worker_time], T1.[total_elapsed_time_in_S],  T1.[last_execution_time]
		, replace(replace(replace(qt.[Text],CHAR(10),' '), CHAR(13), ' '), '  ',' ') [QueryText]
		, qp.[query_plan]
		, DB_NAME(qp.dbid) [Database]
		, OBJECT_NAME(qp.objectid) [Object]
		FROM 
		#querystats T1
		CROSS APPLY sys.dm_exec_query_plan(T1.plan_handle) qp
		CROSS APPLY sys.dm_exec_sql_text(T1.sql_handle) qt
		WHERE T1.Id <= @TopQueries
		--WHERE PATINDEX('%MissingIndex%',CAST(query_plan AS VARCHAR(MAX))) > 0
		ORDER BY CASE WHEN  PATINDEX('%MissingIndexes%',CAST(qp.query_plan AS NVARCHAR(MAX)))  > 0 THEN 1 ELSE 0 END DESC
		,CASE WHEN  PATINDEX('%MissingIndexes%',CAST(qp.query_plan AS NVARCHAR(MAX))) > 0 
		 THEN  PATINDEX('%MissingIndexes%',CAST(qp.query_plan AS NVARCHAR(MAX))) * [Total_MBsRead]  ELSE 0 END DESC 
	
		) q 
		ORDER BY CASE WHEN [Impact%] > 0 THEN 1 ELSE 0 END DESC, [Total_GBsRead]*[Impact%] DESC OPTION (RECOMPILE);


	RAISERROR	  (N'Evaluated execution plans for missing indexes',0,1) WITH NOWAIT;

			/*----------------------------------------
			--Loop all the user databases to run database specific commands against them
			----------------------------------------*/

	SET @dynamicSQL = ''
	SET @Databasei_Count = 1; 
	WHILE @Databasei_Count <= @Databasei_Max 
	BEGIN 
			/*----------------------------------------
			--Get missing index information for each database
			----------------------------------------*/
		
		SELECT @DatabaseName = d.databasename, @DatabaseState = d.state FROM @Databases d WHERE id = @Databasei_Count AND d.state NOT IN (2,6) OPTION (RECOMPILE)
		SET @ErrorMessage = 'Looping Database ' + CONVERT(VARCHAR(4),@Databasei_Count) +' of ' + CONVERT(VARCHAR(4),@Databasei_Max ) + ': [' + @DatabaseName + '] ';
		RAISERROR (@ErrorMessage,0,1) WITH NOWAIT;
		IF EXISTS( SELECT @DatabaseName)
		BEGIN  
			RAISERROR	  (N'Looking for missing indexes in DMVs',0,1) WITH NOWAIT;
			SET @dynamicSQL = '
			USE ['+@DatabaseName +']
			SELECT '''+@DatabaseName+'''
			,  (( user_seeks + user_scans ) * avg_total_user_cost * avg_user_impact)/' + CONVERT(NVARCHAR,@DaysOldestCachedQuery) + ' daily_magic_benefit_number
			, [Table] = [statement]
			
			
			, [CreateIndexStatement] = ''CREATE NONCLUSTERED INDEX IX_LEXEL_'' + REPLACE(ISNULL(sys.objects.name COLLATE DATABASE_DEFAULT 	+ ''_'' ,''''),'' '',''_'')
			+ REPLACE(REPLACE(REPLACE(LEFT(ISNULL(mid.equality_columns,'''')+ISNULL(mid.inequality_columns,''''),15), ''['', ''''), '']'',''''), '', '',''_'') + ''_''+ REPLACE(CONVERT(VARCHAR(20),GETDATE(),102),''.'',''_'') + ''T''  + REPLACE(CONVERT(VARCHAR(20),GETDATE(),108),'':'',''_'') + '' ON '' + [statement] 
			+ CHAR(13) + CHAR(10) + '' ( '' 
			+ CHAR(13) + CHAR(10) +''< be clever here > ''
			+ CHAR(13) + CHAR(10) + '')''
			+ CHAR(13) + CHAR(10) + ISNULL(''INCLUDE ('' + mid.included_columns + '')'','''')
			+ CHAR(13) + CHAR(10) + ''WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = '+@rebuildonline+', ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON,FILLFACTOR = 98) ON [PRIMARY];''
			, mid.equality_columns
			, mid.inequality_columns
			, mid.included_columns
			, ''SELECT STUFF(( SELECT '''', '''' + [Columns] FROM ( SELECT TOP 25 c1.[id], [Columns], [Count] FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY [Columns]) [id], LTRIM([Columns]) [Columns] FROM (VALUES('''''' + REPLACE(ISNULL(mid.equality_columns + ISNULL('',''+ mid.inequality_columns,''''),ISNULL(mid.inequality_columns,'''')) ,'','',''''''),('''''') 
			+''''''))t ([Columns]) ) c1 '' 
			+ '' LEFT OUTER JOIN (
			SELECT ROW_NUMBER() OVER(ORDER BY [Count]) [id] ,LTRIM([Count]) [Count] FROM (VALUES((SELECT COUNT (DISTINCT '' + REPLACE(ISNULL(mid.equality_columns + ISNULL('',''+ mid.inequality_columns,''''),ISNULL(mid.inequality_columns,'''')) ,'',''
			,'') FROM '' + [statement] +'')),((SELECT COUNT (DISTINCT '') 
			+'') FROM '' + [statement] +'')))t ([Count]) )c2 ON c2.id = c1.id 
			ORDER BY c2.[Count] * 1 DESC
			) t1 FOR XML PATH('''''''')),1,1,'''''''') AS NameValues'' [BeingClever]
			FROM sys.dm_db_missing_index_group_stats AS migs 
			INNER JOIN sys.dm_db_missing_index_groups AS mig ON migs.group_handle = mig.index_group_handle 
			INNER JOIN sys.dm_db_missing_index_details AS mid ON mig.index_handle = mid.index_handle 
			LEFT OUTER JOIN sys.objects WITH (nolock) ON mid.OBJECT_ID = sys.objects.OBJECT_ID 
			WHERE (migs.group_handle IN (SELECT TOP 100 PERCENT group_handle FROM sys.dm_db_missing_index_group_stats WITH (nolock) ORDER BY (avg_total_user_cost * avg_user_impact) * (user_seeks + user_scans) DESC))  
			AND OBJECTPROPERTY(sys.objects.OBJECT_ID, ''isusertable'') = 1 
			ORDER BY daily_magic_benefit_number DESC, [CreateIndexStatement] DESC OPTION (RECOMPILE);'
			INSERT #MissingIndex
			EXEC sp_executesql @dynamicSQL;
		
	
		/*13. Find idle indexes*/
			/*---------------------------------------Shows Indexes that have never been used---------------------------------------*/
			RAISERROR	  (N'Skipping never used indexes',0,1) WITH NOWAIT;
			SET ANSI_WARNINGS OFF
			SET @dynamicSQL = '
			USE ['+@DatabaseName +']
			DECLARE @DaysAgo INT, @TheDate DATETIME
			SET @DaysAgo = 15
			SET @TheDate =  CONVERT(DATETIME,CONVERT(INT,DATEADD(DAY,-@DaysAgo,GETDATE())))
			DECLARE @db_id smallint, @tab_id INT 
			SET @db_id=db_id()
			SET @tab_id=object_id(''Production.Product'')
			SELECT '''+@DatabaseName+''',
			CASE WHEN b.type_desc = ''CLUSTERED'' THEN ''Consider Carefully'' ELSE ''May remove'' END Consideration
			, t.name TableName, b.type_desc TypeDesc, b.name IndexName, a.user_updates Updates, a.last_user_scan, a.last_user_seek, SUM(aa.page_count) Pages
			FROM sys.dm_db_index_usage_stats as a
			JOIN sys.indexes AS b ON a.object_id = b.object_id AND a.index_id = b.index_id
			LEFT OUTER JOIN sys.tables AS t ON b.[object_id] = t.[object_id]
			LEFT OUTER JOIN INFORMATION_SCHEMA.TABLES isc ON isc.TABLE_NAME = t.name
			LEFT OUTER JOIN sys.dm_db_index_physical_stats (@db_id,@tab_id,NULL, NULL, NULL) AS aa ON aa.object_id = a.object_id
			WHERE a.user_seeks + a.user_scans + a.system_scans + a.user_lookups = 0
			AND (DATEDIFF(DAY,a.last_user_scan,GETDATE()) > @DaysAgo AND DATEDIFF(DAY,a.last_user_seek,GETDATE()) > @DaysAgo)
			AND t.name NOT LIKE ''sys%''
			GROUP BY t.name, b.type_desc, b.name, a.user_updates, a.last_user_scan, a.last_user_seek
			HAVING SUM(aa.page_count) > 500
			ORDER BY Pages DESC OPTION (RECOMPILE)
			'
			--INSERT #NeverUsedIndex
			--EXEC sp_executesql @dynamicSQL;
			SET ANSI_WARNINGS ON
		/*14. Find heaps*/
			/*---------------------------------------Shows tables without primary key. Heaps---------------------------------------*/
			RAISERROR	  (N'Looking for heap tables',0,1) WITH NOWAIT;
			SET @dynamicSQL = '
			USE ['+@DatabaseName +']
			SELECT DISTINCT '''+@DatabaseName +''', SCHEMA_NAME(o.schema_id) AS [schema],object_name(i.object_id ) AS [table],p.rows,user_seeks,user_scans,user_lookups,user_updates,last_user_seek,last_user_scan,last_user_lookup
			FROM sys.indexes i 
				INNER JOIN sys.objects o ON i.object_id = o.object_id
				INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
				LEFT OUTER JOIN sys.dm_db_index_usage_stats ius ON i.object_id = ius.object_id AND i.index_id = ius.index_id
			WHERE i.type_desc = ''HEAP'' AND SCHEMA_NAME(o.schema_id) NOT LIKE ''sys'' AND rows > 100
			ORDER BY rows desc OPTION (RECOMPILE);'
			INSERT #HeapTable
			EXEC sp_executesql @dynamicSQL;

			RAISERROR	  (N'Looking for stale statistics',0,1) WITH NOWAIT;
			SET @dynamicSQL = 'SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
			USE ['+@DatabaseName+'];
			SELECT 
				'''+@DatabaseName+''' [DbName]
				, ObjectNm
				, StatsID
				, StatsName
				, SchemaName
				, ModificationCount
				, [LastUpdated] 
				, Rows
				, CONVERT(MONEY,ModificationCount)*100/Rows [Mod%]
			FROM (
				SELECT 
					OBJECT_NAME(p.object_id) ObjectNm
						, p.index_id StatsID
						, s.name StatsName
						, MAX(p.rows) Rows
						, sce.name SchemaName
						, sum(pc.modified_count) ModificationCount
						, MAX(
								STATS_DATE(s.object_id, s.stats_id)
							 ) AS [LastUpdated]
				FROM sys.system_internals_partition_columns pc
				INNER JOIN sys.partitions p ON pc.partition_id = p.partition_id
				INNER JOIN sys.stats s ON s.object_id = p.object_id AND s.stats_id = p.index_id
				INNER JOIN sys.stats_columns sc ON sc.object_id = s.object_id AND sc.stats_id = s.stats_id AND sc.stats_column_id = pc.partition_column_id
				INNER JOIN sys.tables t ON t.object_id = s.object_id
				INNER JOIN sys.schemas sce ON sce.schema_id = t.schema_id
				WHERE p.rows > 500
				AND pc.modified_count > 0
				GROUP BY p.object_id, p.index_id, s.name,sce.name
			) stats
			WHERE ObjectNm NOT LIKE ''sys%'' AND ModificationCount != 0
			AND ObjectNm NOT LIKE ''ifts_comp_fragment%''
			AND ObjectNm NOT LIKE ''fulltext_%''
			AND ObjectNm NOT LIKE ''filestream_%''
			AND ObjectNm NOT LIKE ''queue_messages_%''
			AND Rows > 500
			AND  CASE WHEN Rows = 0 THEN 0 ELSE CONVERT(MONEY,ModificationCount)*100/Rows END >= '+CONVERT(VARCHAR(20),@MinChangePercentage)+ '
			AND LastUpdated < DATEADD(DAY, - 1, GETDATE())
			ORDER BY ObjectNm, StatsName OPTION (RECOMPILE);
			';
			INSERT #Action_Statistics
			EXEC sp_executesql @dynamicSQL;
		
			RAISERROR	  (N'Skipping bad NC Indexes tables',0,1) WITH NOWAIT;
		   SET @dynamicSQL = 'SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
			USE ['+@DatabaseName+'];
		   -- Possible Bad NC Indexes (writes > reads)  (Query 52) (Bad NC Indexes)
			SELECT OBJECT_NAME(s.[object_id]) AS [Table Name], i.name AS [Index Name], i.index_id, 
			i.is_disabled, i.is_hypothetical, i.has_filter, i.fill_factor,
			user_updates AS [Total Writes], user_seeks + user_scans + user_lookups AS [Total Reads],
			user_updates - (user_seeks + user_scans + user_lookups) AS [Difference]
			FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
			INNER JOIN sys.indexes AS i WITH (NOLOCK)
			ON s.[object_id] = i.[object_id]
			AND i.index_id = s.index_id
			WHERE OBJECTPROPERTY(s.[object_id],''IsUserTable'') = 1
			AND s.database_id = DB_ID()
			AND user_updates > (user_seeks + user_scans + user_lookups)
			AND i.index_id > 1
			ORDER BY [Difference] DESC, [Total Writes] DESC, [Total Reads] ASC OPTION (RECOMPILE);
			'
			--EXEC sp_executesql @dynamicSQL;

			/*----------------------------------------
			--Find badly behaving constraints
			----------------------------------------*/

		/* Constraints behaving badly*/
		RAISERROR	  (N'Looking for bad constraints',0,1) WITH NOWAIT;
		SET @dynamicSQL = 'SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
			USE ['+@DatabaseName+'];
		IF EXISTS(
		SELECT 1
		from sys.check_constraints i 
		WHERE i.is_not_trusted = 1 AND i.is_not_for_replication = 0 AND i.is_disabled = 0 
		)
		INSERT  #notrust (KeyType, Tablename, KeyName, DBCCcommand, Fix)
		SELECT ''Check'' as [KeyType], ''['+@DatabaseName+'].['' + s.name + ''].['' + o.name + '']'' [tablename]
		, ''['+@DatabaseName+'].['' + s.name + ''].['' + o.name + ''].['' + i.name + '']'' AS keyname
		, ''DBCC CHECKCONSTRAINTS (['' + i.name + '']) WITH ALL_ERRORMSGS'' [DBCC]
		, ''ALTER TABLE ['+@DatabaseName+'].['' + s.name + ''].'' + ''['' + o.name + ''] WITH CHECK CHECK CONSTRAINT ['' + i.name + '']'' [Fix]
		from sys.check_constraints i
		INNER JOIN sys.objects o ON i.parent_object_id = o.object_id
		INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
		WHERE i.is_not_trusted = 1 AND i.is_not_for_replication = 0 AND i.is_disabled = 0
		OPTION (RECOMPILE)
		;

		IF EXISTS(
		SELECT 1
		from sys.foreign_keys i
					INNER JOIN sys.objects o ON i.parent_object_id = o.OBJECT_ID
					INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
		WHERE   i.is_not_trusted = 1
				   AND i.is_not_for_replication = 0
				   AND i.is_disabled = 0 
			   
		)
		INSERT  #notrust (KeyType, Tablename, KeyName, DBCCcommand, Fix)
		SELECT ''FK'' as[ KeyType],  ''['+@DatabaseName+'].['' + s.name + ''].'' + ''['' + o.name + '']'' AS TableName
				   , ''['+@DatabaseName+'].['' + s.name + ''].['' + o.name + ''].['' + i.name + '']'' AS FKName
				   ,''DBCC CHECKCONSTRAINTS (['' + i.name + '']) WITH ALL_ERRORMSGS'' [DBCC]
				   , ''ALTER TABLE ['+@DatabaseName+'].['' + s.name + ''].'' + ''['' + o.name + ''] WITH CHECK CHECK CONSTRAINT ['' + i.name + '']'' [Fix]

		FROM    sys.foreign_keys i
					INNER JOIN sys.objects o ON i.parent_object_id = o.OBJECT_ID
					INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
		WHERE   i.is_not_trusted = 1
					AND i.is_not_for_replication = 0
					AND i.is_disabled = 0
	   ORDER BY o.name  
	   OPTION (RECOMPILE)
	   '
	   --PRINT @dynamicSQL
		EXEC sp_executesql @dynamicSQL;


			RAISERROR	  (N'Looking for connected users',0,1) WITH NOWAIT;
			SET @dynamicSQL = 'SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
			USE ['+@DatabaseName+'];
			SELECT '''+@DatabaseName+''', p.name AS [SP Name], qs.total_logical_writes AS [TotalLogicalWrites], 
			qs.total_logical_writes/qs.execution_count AS [AvgLogicalWrites], qs.execution_count,
			ISNULL(qs.execution_count/DATEDIFF(Second, qs.cached_time, GETDATE()), 0) AS [Calls/Second],
			qs.total_elapsed_time, qs.total_elapsed_time/qs.execution_count AS [avg_elapsed_time], 
			qs.cached_time
			FROM sys.procedures AS p WITH (NOLOCK)
			INNER JOIN sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
			ON p.[object_id] = qs.[object_id]
			WHERE qs.database_id = DB_ID()
			AND qs.total_logical_writes > 0
			ORDER BY qs.total_logical_writes DESC OPTION (RECOMPILE);
			'
			INSERT #db_sps
			EXEC sp_executesql @dynamicSQL;

		END 
		SET @Databasei_Count = @Databasei_Count + 1; 
	END
	RAISERROR (N'Evaluated all databases',0,1) WITH NOWAIT;

			/*----------------------------------------
			--Output results from all databases into results table
			----------------------------------------*/


	IF EXISTS (SELECT 1 FROM #MissingIndex ) 
	BEGIN
		INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 18, 'MISSING INDEXES - !Benefit > 1mm!','------','------'
		INSERT #output_man_script (SectionID, Section,Summary ,Details,HoursToResolveWithTesting )
			SELECT 18, REPLICATE('|',ROUND(LOG(T1.magic_benefit_number),0)) + ' ' + CONVERT(VARCHAR(20),LOG(T1.magic_benefit_number)) + '' 
			+ CASE WHEN LOG(T1.magic_benefit_number) < 10 THEN ' \(",)/'
			WHEN LOG(T1.magic_benefit_number) >= 10 AND LOG(T1.magic_benefit_number) < 12 THEN ' (".)/'
			WHEN LOG(T1.magic_benefit_number) >= 12 AND LOG(T1.magic_benefit_number) < 14 THEN ' ("o)'
			WHEN LOG(T1.magic_benefit_number) >= 14 AND LOG(T1.magic_benefit_number) < 16 THEN ' (**.)'
			WHEN LOG(T1.magic_benefit_number) >= 16 AND LOG(T1.magic_benefit_number) < 20 THEN ' WTF - really'
			WHEN LOG(T1.magic_benefit_number) >= 20 AND LOG(T1.magic_benefit_number) < 25  THEN ' You server SUCKS ROCKS man, SUCKS ROCKS'
			WHEN LOG(T1.magic_benefit_number) > 25  THEN ' No way. Send me a screenshot, adrian.sullivan@lexel.co.nz'
			END
			, 'Benefit:'+  CONVERT(VARCHAR(20),CONVERT(BIGINT,T1.magic_benefit_number),0)
			+ '; ' + T1.[Table]
			+ '; Eq:' + ISNULL(T1.equality_columns,'')
			+ '; Ineq:' +  ISNULL(T1.inequality_columns,'')
			+ '; Incl:' +  ISNULL(T1.included_columns,'')
			, T2.[SETs] + '; ' + CHAR(13) + CHAR(10)  +'SELECT '''  + CHAR(13) + CHAR(10) + REPLACE(T1.ChangeIndexStatement,'< be clever here >', ' ''+ ('+  BeingClever + ') + '' ') + ''' '
			, CASE 
			WHEN LOG(T1.magic_benefit_number) >= 10 AND LOG(T1.magic_benefit_number) < 12 THEN 1
			WHEN LOG(T1.magic_benefit_number) >= 12 AND LOG(T1.magic_benefit_number) < 14 THEN 2
			WHEN LOG(T1.magic_benefit_number) >= 14 AND LOG(T1.magic_benefit_number) < 16 THEN 4
			WHEN LOG(T1.magic_benefit_number) >= 16 AND LOG(T1.magic_benefit_number) < 20 THEN 6
			WHEN LOG(T1.magic_benefit_number) >= 20 AND LOG(T1.magic_benefit_number) < 25  THEN 8
			WHEN LOG(T1.magic_benefit_number) > 25  THEN 12
			END
			FROM #MissingIndex T1 
			INNER JOIN #whatsets T2 ON T1.DB = T2.DBname
			WHERE '[' + T1.DB + ']' = LEFT(T1.[Table],LEN(T1.DB)+2)  AND T1.magic_benefit_number > 10
			ORDER BY magic_benefit_number DESC OPTION (RECOMPILE)

			

	END
	RAISERROR (N'Completed missing index details',0,1) WITH NOWAIT;

		IF EXISTS (SELECT 1 FROM #HeapTable ) 
	BEGIN
		INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 19, 'HEAP TABLES - Bad news','------','------'
		INSERT #output_man_script (SectionID, Section,Summary ,Details,HoursToResolveWithTesting )
			SELECT 19, REPLICATE('|', (ISNULL(user_scans,0)+ ISNULL(user_seeks,0) + ISNULL(user_lookups,0) + ISNULL(user_updates,0))/100) + CONVERT(VARCHAR(20),(ISNULL(user_scans,0)+ ISNULL(user_seeks,0) + ISNULL(user_lookups,0) + ISNULL(user_updates,0))/100) 
			, 'Rows:' + CONVERT(VARCHAR(20),T1.rows)
			+ ';'+ '['+T1.DB+'].' + '['+T1.[schema]+'].' + '['+T1.[table]+']' 
			+ '; Scan:' + CONVERT(VARCHAR(20),ISNULL(T1.last_user_scan,0) ,120)
			+ '; Seek:' + CONVERT(VARCHAR(20),ISNULL(T1.last_user_seek,0) ,120)
			+ '; Lookup:' + CONVERT(VARCHAR(20),ISNULL(T1.last_user_lookup,0) ,120)
			, '/*DIRTY FIX, assuming forwarded records*/ALTER TABLE ['+T1.DB+'].' + '['+T1.[schema]+'].' + '['+T1.[table]+'] REBUILD '
			, 3
			/*SELECT
			OBJECT_NAME(ps.object_id) as TableName,
			i.name as IndexName,
			ps.index_type_desc,
			ps.page_count,
			ps.avg_fragmentation_in_percent,
			ps.forwarded_record_count
		FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, 'DETAILED') AS ps
		INNER JOIN sys.indexes AS i
			ON ps.OBJECT_ID = i.OBJECT_ID  
			AND ps.index_id = i.index_id
		WHERE forwarded_record_count > 0*/
			FROM #HeapTable T1  
			WHERE T1.rows > 500
			ORDER BY (ISNULL(user_scans,0)+ ISNULL(user_seeks,0) + ISNULL(user_lookups,0) + ISNULL(user_updates,0)) DESC,  DB OPTION (RECOMPILE);
	END
	RAISERROR (N'Found heap tables',0,1) WITH NOWAIT;

		IF EXISTS (SELECT 1 FROM #NeverUsedIndex ) 
	BEGIN
		INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 20, 'STALE INDEXES - Consider removing them at some stage','------','------'
		INSERT #output_man_script (SectionID, Section,Summary ,Details )

			SELECT 20, REPLICATE('|', DATEDIFF(DAY,last_user_scan,GETDATE()))
			, 'Updates: '+  CONVERT(VARCHAR(20),Updates)
			+ '; ' +TypeDesc + ':' 
			+ IndexName 
			, CONVERT(VARCHAR(20),Pages) + ' pages'
			+ '; DB:' + DB
			+ '; Table:' + TableName
			FROM #NeverUsedIndex /*They are like little time capsules.. just sitting there.. waiting*/
			ORDER BY  DATEDIFF(DAY,last_user_scan,GETDATE()) DESC OPTION (RECOMPILE)
	END
		IF EXISTS (SELECT 1 FROM #Action_Statistics ) 
	BEGIN
		INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 21,'STALE STATS - Worst news','------','------'
		INSERT #output_man_script (SectionID, Section,Summary ,Details,HoursToResolveWithTesting )
			SELECT  21,
			REPLICATE('|',DATEDIFF(DAY,s.LastUpdated,GETDATE())) + CONVERT(VARCHAR(20),DATEDIFF(DAY,s.LastUpdated,GETDATE())) +' days old'
			, '%Change:' + CONVERT(VARCHAR(15),[Mod%]) +'%; Rows:' + CONVERT(VARCHAR(15),Rows) + ';Modifications:' + CONVERT(VARCHAR(20),s.ModificationCount) +'; ['+ DBname + '].['+SchemaName+'].['+TableName+']:['+StatisticsName+']'
			, 'UPDATE STATISTICS [' + DBname + '].['+SchemaName+'].['+TableName+'] ['+StatisticsName+'] WITH FULLSCAN; PRINT ''[' + DBname + '].['+SchemaName+'].['+TableName+'] ['+StatisticsName+'] Done ''' [UpdateStats]
			, 0.15
			 FROM #Action_Statistics s 
			 ORDER BY [Mod%] DESC OPTION (RECOMPILE);/*They are like little time capsules.. just sitting there.. waiting*/

	END
	RAISERROR (N'Listed state stats',0,1) WITH NOWAIT;

		 /*----------------------------------------
			--Most used database stored procedures
			----------------------------------------*/
		IF EXISTS( SELECT 1 FROM #db_sps)
	BEGIN
		INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 22, 'STORED PROCEDURE WORKLOAD - TOP 10','------','------'
		INSERT #output_man_script (SectionID, Section,Summary ,Details )

		SELECT TOP 10 22, REPLICATE('|', CONVERT(MONEY,execution_count*100) / SUM (execution_count) OVER() ) + ' '+ CONVERT(VARCHAR(20),CONVERT(INT,ROUND(CONVERT(MONEY,execution_count*100) / SUM (execution_count) OVER(),0))) + '%'
		,  [SP Name] + '; Executions:'+ CONVERT(VARCHAR(20),execution_count)
		+ '; Per second:' + CONVERT(VARCHAR(20),[Calls/Second])
		, dbname
		+ '; Avg Time:' + CONVERT(VARCHAR(20), avg_elapsed_time/1000/1000 ) + '(s)'
		+ '; Total time:' + CONVERT(VARCHAR(20), total_elapsed_time/1000/1000 ) + '(s)'
		+ '; Overall time:' + CONVERT(VARCHAR(20),CONVERT(MONEY,total_elapsed_time*100) / SUM (total_elapsed_time) OVER()) +'%'
		FROM #db_sps
		ORDER BY execution_count DESC OPTION (RECOMPILE)

	END
	RAISERROR (N'Database stored procedure details',0,1) WITH NOWAIT;
			/*----------------------------------------
			--General server settings and items of note
			----------------------------------------*/

	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 24, 'Server details','------','------'
	INSERT #output_man_script (SectionID, Section, Summary  )
	SELECT 24,  @@SERVERNAME AS [Server Name]
	,'Evauation date: ' + CONVERT(VARCHAR(20),GETDATE(),120)
	INSERT #output_man_script (SectionID, Section, Summary  )
	SELECT 24,  @@SERVERNAME AS [Server Name]
	,'' +  replace(replace(replace(replace(CONVERT(NVARCHAR(500),@@VERSION  ), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), '  ',' ')

	INSERT #output_man_script (SectionID,Summary,HoursToResolveWithTesting  )
	SELECT 24, 'Page Life Expectancy: ' + CONVERT(VARCHAR(20), cntr_value)
	, CASE WHEN cntr_value < 100 THEN 4 ELSE NULL END
	FROM sys.dm_os_performance_counters WITH (NOLOCK)
	WHERE [object_name] LIKE N'%Buffer Node%' -- Handles named instances
	AND counter_name = N'Page life expectancy'  OPTION (RECOMPILE)


	INSERT #output_man_script (SectionID,Summary  )
	SELECT 24, 'Memory Grants Pending:' + CONVERT(VARCHAR(20), cntr_value)                                                                                                    
	FROM sys.dm_os_performance_counters WITH (NOLOCK)
	WHERE [object_name] LIKE N'%Memory Manager%' -- Handles named instances
	AND counter_name = N'Memory Grants Pending' OPTION (RECOMPILE);

	RAISERROR (N'Listed general instance stats',0,1) WITH NOWAIT;


	/* The default settings have been copied from sp_Blitz from http://FirstResponderKit.org
	Believe it or not, SQL Server doesn't track the default values
	for sp_configure options! We'll make our own list here.*/

	INSERT  INTO #ConfigurationDefaults
	VALUES 
	( 'access check cache bucket count', 0, 1001 )
	, ( 'access check cache quota', 0, 1002 )
	, ( 'Ad Hoc Distributed Queries', 0, 1003 )
	, ( 'affinity I/O mask', 0, 1004 )
	, ( 'affinity mask', 0, 1005 )
	, ( 'affinity64 mask', 0, 1066 )
	, ( 'affinity64 I/O mask', 0, 1067 )
	, ( 'Agent XPs', 0, 1071 )
	, ( 'allow updates', 0, 1007 )
	, ( 'awe enabled', 0, 1008 )
	, ( 'backup checksum default', 0, 1070 )
	, ( 'backup compression default', 0, 1073 )
	, ( 'blocked process threshold', 0, 1009 )
	, ( 'blocked process threshold (s)', 0, 1009 )
	, ( 'c2 audit mode', 0, 1010 )
	, ( 'clr enabled', 0, 1011 )
	, ( 'common criteria compliance enabled', 0, 1074 )
	, ( 'contained database authentication', 0, 1068 )
	, ( 'cost threshold for parallelism', 5, 1012 )
	, ( 'cross db ownership chaining', 0, 1013 )
	, ( 'cursor threshold', -1, 1014 )
	, ( 'Database Mail XPs', 0, 1072 )
	, ( 'default full-text language', 1033, 1016 )
	, ( 'default language', 0, 1017 )
	, ( 'default trace enabled', 1, 1018 )
	, ( 'disallow results from triggers', 0, 1019 )
	, ( 'EKM provider enabled', 0, 1075 )
	, ( 'filestream access level', 0, 1076 )
	, ( 'fill factor (%)', 0, 1020 )
	, ( 'ft crawl bandwidth (max)', 100, 1021 )
	, ( 'ft crawl bandwidth (min)', 0, 1022 )
	, ( 'ft notify bandwidth (max)', 100, 1023 )
	, ( 'ft notify bandwidth (min)', 0, 1024 )
	, ( 'index create memory (KB)', 0, 1025 )
	, ( 'in-doubt xact resolution', 0, 1026 )
	, ( 'lightweight pooling', 0, 1027 )
	, ( 'locks', 0, 1028 )
	, ( 'max degree of parallelism', 0, 1029 )
	, ( 'max full-text crawl range', 4, 1030 )
	, ( 'max server memory (MB)', 2147483647, 1031 )
	, ( 'max text repl size (B)', 65536, 1032 )
	, ( 'max worker threads', 0, 1033 )
	, ( 'media retention', 0, 1034 )
	, ( 'min memory per query (KB)', 1024, 1035 );
	/* Accepting both 0 and 16 below because both have been seen in the wild as defaults. */
	IF EXISTS ( SELECT  *
				FROM    sys.configurations
				WHERE   name = 'min server memory (MB)'
						AND value_in_use IN ( 0, 16 ) )
		INSERT  INTO #ConfigurationDefaults
				SELECT  'min server memory (MB)' ,
						CAST(value_in_use AS BIGINT), 1036
				FROM    sys.configurations
				WHERE   name = 'min server memory (MB)'
	ELSE
		INSERT  INTO #ConfigurationDefaults
		VALUES  ( 'min server memory (MB)', 0, 1036 );

	INSERT  INTO #ConfigurationDefaults
	VALUES  ( 'nested triggers', 1, 1037 )

	, ( 'network packet size (B)', 4096, 1038 )
	, ( 'Ole Automation Procedures', 0, 1039 )
	, ( 'open objects', 0, 1040 )
	, ( 'optimize for ad hoc workloads', 0, 1041 )
	, ( 'PH timeout (s)', 60, 1042 )
	, ( 'precompute rank', 0, 1043 )
	, ( 'priority boost', 0, 1044 )
	, ( 'query governor cost limit', 0, 1045 )
	, ( 'query wait (s)', -1, 1046 )
	, ( 'recovery interval (min)', 0, 1047 )
	, ( 'remote access', 1, 1048 )
	, ( 'remote admin connections', 0, 1049 )
	/* SQL Server 2012 changes a configuration default */
	IF @@VERSION LIKE '%Microsoft SQL Server 2005%'
		OR @@VERSION LIKE '%Microsoft SQL Server 2008%'
		BEGIN
			INSERT  INTO #ConfigurationDefaults
			VALUES  ( 'remote login timeout (s)', 20, 1069 );
		END
	ELSE
		BEGIN
			INSERT  INTO #ConfigurationDefaults
			VALUES  ( 'remote login timeout (s)', 10, 1069 );
		END
	INSERT  INTO #ConfigurationDefaults
	VALUES  
	( 'remote proc trans', 0, 1050 )
	, ( 'remote query timeout (s)', 600, 1051 )
	, ( 'Replication XPs', 0, 1052 )
	, ( 'RPC parameter data validation', 0, 1053 )
	, ( 'scan for startup procs', 0, 1054 )
	, ( 'server trigger recursion', 1, 1055 )
	, ( 'set working set size', 0, 1056 )
	, ( 'show advanced options', 0, 1057 )
	, ( 'SMO and DMO XPs', 1, 1058 )
	, ( 'SQL Mail XPs', 0, 1059 )
	, ( 'transform noise words', 0, 1060 )
	, ( 'two digit year cutoff', 2049, 1061 )
	, ( 'user connections', 0, 1062 )
	, ( 'user options', 0, 1063 )
	, ( 'Web Assistant Procedures', 0, 1064 )
	, ( 'xp_cmdshell', 0, 1065 );


	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 25, 'Server details - Non default settings','------','------'
	INSERT #output_man_script (SectionID, Section,Summary,Details)
	SELECT 25, [description] name
	, '['+CONVERT(VARCHAR(20),cd.[DefaultValue]) + '] changed to [' + CONVERT(VARCHAR(20),value_in_use) + ']'
	, 'Blitz CheckID:' +  CONVERT(VARCHAR(20),cd.CheckID)
	+ '; MIN:' + CONVERT(VARCHAR(20),minimum)
	+ '; MAX:' + CONVERT(VARCHAR(20),maximum)
	+ '; IsDynamic:' + CONVERT(VARCHAR(20),is_dynamic)
	+ '; IsAdvanced:' + CONVERT(VARCHAR(20),is_advanced)
	FROM sys.configurations cr WITH (NOLOCK)
	INNER JOIN #ConfigurationDefaults cd ON cd.name = cr.name
	LEFT OUTER JOIN #ConfigurationDefaults cdUsed ON cdUsed.name = cr.name AND cdUsed.DefaultValue = cr.value_in_use
	WHERE cdUsed.name IS NULL
	OPTION (RECOMPILE);
	RAISERROR (N'Listed non-default settings',0,1) WITH NOWAIT;

			/*----------------------------------------
			--Current active logins on this instance
			----------------------------------------*/

	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 26,'CURRENT ACTIVE USERS - TOP 10','------','------'
	INSERT #output_man_script (SectionID, Section,Summary)
	SELECT TOP 10 26, 'User: ' + login_name
	, '[' + CONVERT(VARCHAR(20), COUNT(session_id) ) + '] sessions using: ' + [program_name]
	FROM sys.dm_exec_sessions WITH (NOLOCK)
	GROUP BY login_name, [program_name]
	ORDER BY COUNT(session_id) DESC OPTION (RECOMPILE);

	RAISERROR (N'Connections listed',0,1) WITH NOWAIT;

			/*----------------------------------------
			--Insert trust issues into output table
			----------------------------------------*/
	IF EXISTS(SELECT 1 FROM #notrust )
	BEGIN
	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 27,'TRUST ISSUES','------','------'
	INSERT #output_man_script (SectionID, Section,Summary, Details)

	SELECT 27, KeyType + '; Table: '+ Tablename
	+ '; KeyName: ' + KeyName
	, DBCCcommand
	, Fix
	FROM #notrust 
	OPTION (RECOMPILE)
	END

	RAISERROR (N'Included Constraint trust issues',0,1) WITH NOWAIT;


			/*----------------------------------------
			--Current active connections on each database
			----------------------------------------*/
			
	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 29,'DATABASE CONNECTED USERS','------','------'
	INSERT #output_man_script (SectionID, Section,Summary,Details)
	SELECT  29, dtb.name
	, 'Active: ' + CONVERT(VARCHAR(20),(select count(*) from master.dbo.sysprocesses p where dtb.database_id=p.dbid))
	+ '; LastActivity:' +CONVERT(VARCHAR, ISNULL(lastactive.LastActivity,lastactive.create_date),120)
	, 'Updatable: ' + ( case LOWER(convert( nvarchar(128), DATABASEPROPERTYEX(dtb.name, 'Updateability'))) when 'read_write'then 'Yes' else 'No' end)
	+ '; ReplicationOptions:' + CONVERT(VARCHAR(20),(dtb.is_published*1+dtb.is_subscribed*2+dtb.is_merge_published*4))
	FROM master.sys.databases AS dtb 

	INNER JOIN (
			SELECT d.name
			, MAX(d.create_date) create_date
			, [LastActivity] =
			(select X1= max(bb.xx) 
			from (
				select xx = max(last_user_seek) 
					where max(last_user_seek) is not null 
				union all 
				select xx = max(last_user_scan) 
					where max(last_user_scan) is not null 
				union all 
				select xx = max(last_user_lookup) 
					where max(last_user_lookup) is not null 
				union all 
					select xx = max(last_user_update) 
					where max(last_user_update) is not null) bb) 
			, last_user_seek = MAX(last_user_seek)
			, last_user_scan = MAX(last_user_scan)
			, last_user_lookup = MAX(last_user_lookup)
			, last_user_update = MAX(last_user_update)
			FROM sys.dm_db_index_usage_stats AS i
			JOIN sys.databases AS d ON i.database_id=d.database_id
			GROUP BY d.name
	) lastactive ON lastactive.name = dtb.name
	
	
	OPTION (RECOMPILE);

	RAISERROR (N'Database Connections counted',0,1) WITH NOWAIT;


			/*----------------------------------------
			--Current likely active databases
			----------------------------------------*/
	

DECLARE @confidence TABLE (DBName VARCHAR(500), EstHoursSinceActive BIGINT)
DECLARE @ConfidenceLevel TABLE ( Bionmial MONEY, ConfidenceLevel VARCHAR(10))
INSERT INTO @ConfidenceLevel VALUES(1.96,'95%')

SET @lastservericerestart = (SELECT create_date FROM sys.databases WHERE name = 'tempdb');

INSERT INTO @confidence
select d.name, [LastSomethingHours] = DATEDIFF(HOUR,ISNULL(
(select X1= max(bb.xx) 
from (
    select xx = max(last_user_seek) 
        where max(last_user_seek) is not null 
    union all 
    select xx = max(last_user_scan) 
        where max(last_user_scan) is not null 
    union all 
    select xx = max(last_user_lookup) 
        where max(last_user_lookup) is not null 
    union all 
        select xx = max(last_user_update) 
        where max(last_user_update) is not null) bb) ,@lastservericerestart),GETDATE())
FROM master.dbo.sysdatabases d 
left outer join sys.dm_db_index_usage_stats s on d.dbid= s.database_id 
WHERE database_id > 4
group by d.name


PRINT 'Probability of a read data event occurring in the next hour, based on activity since the last restart with a 95% confidence'

INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 30, 'Database usage likelyhood','------','------'
INSERT #output_man_script (SectionID, Section,Summary,Details)
SELECT  30 [SectionID]
, base.name [Section]
,ISNULL(CONVERT(VARCHAR(10),CASE
	WHEN pages.[TotalPages in MB] > 0 THEN 100
	WHEN con.number_of_connections > 0 THEN confidence.low 
	ELSE confidence.high  
END),'')  + '% likely'    
+  '; Connections: ' + CONVERT(VARCHAR(10),con.number_of_connections )
+ '; HoursActive: '+ CONVERT(VARCHAR(10),DATEDIFF(HOUR,@lastservericerestart,GETDATE())) 
+ '; Pages(MB) in memory' + CONVERT(VARCHAR(10), ISNULL(pages.[TotalPages in MB],0)) 
 [Summary]
 
,  'DB Created: ' + CONVERT(VARCHAR,base.DBcreatedate,120)
+ 'Last seek: ' + CONVERT(VARCHAR,base.[last_user_seek],120)
+ '; Last scan:' + CONVERT(VARCHAR,base.[last_user_scan],120)
+ '; Last lookup' + CONVERT(VARCHAR,base.[last_user_lookup],120)
+ '; Last update' + CONVERT(VARCHAR,base.[last_user_update],120) [Details]

FROM (
SELECT db.name, db.database_id
, MAX(db.create_date) [DBcreatedate]
, MAX(o.modify_date) [ObjectModifyDate]
, MAX(ius.last_user_seek)    [last_user_seek]
, MAX(ius.last_user_scan)   [last_user_scan]
, MAX(ius.last_user_lookup) [last_user_lookup]
, MAX(ius.last_user_update) [last_user_update]
FROM
	sys.databases db
	LEFT OUTER JOIN sys.dm_db_index_usage_stats ius  ON db.database_id = ius.database_id
	LEFT OUTER JOIN  sys.all_objects o ON o.object_id = ius.object_id AND o.type = 'U'
WHERE 
	db.database_id > 4 AND state NOT IN (1,2,3,6) AND user_access = 0
GROUP BY 
	db.name, db.database_id
) base

LEFT OUTER JOIN (
	SELECT name AS dbname
	 ,COUNT(status) AS number_of_connections
	FROM master.sys.databases sd
	LEFT JOIN master.sys.sysprocesses sp ON sd.database_id = sp.dbid
	WHERE database_id > 4
	GROUP BY name
) con ON con.dbname = base.name
LEFT OUTER JOIN (
SELECT DB_NAME (database_id) AS 'Database Name'
,  COUNT(*) *8/1024 AS [TotalPages in MB]
FROM sys.dm_os_buffer_descriptors
GROUP BY database_id
) pages ON pages.[Database Name] = base.name

LEFT OUTER JOIN (
select DBName
  , intervals.n as [Hours]
  , intervals.x as [TargetActiveHours]
  , CONVERT(MONEY,(p - se * 1.96)*100) as low
  , CONVERT(MONEY,(intervals.p * 100)) as mid
  , CONVERT(MONEY,(p + se * 1.96)*100) as high 
from (
  select 
    rates.*, 
    sqrt(p * (1 - p) / n) as se -- calculate se
  from (
    select 
      conversions.*, 
      (CASE WHEN x = 0 THEN 1 ELSE x END + 1.92) / CONVERT(FLOAT,(n + 3.84)) as p -- calculate p
    from ( 
      -- Our conversion rate table from above
      select DBName
       , DATEDIFF(HOUR,@lastservericerestart,GETDATE()) as n 
       , DATEDIFF(HOUR,@lastservericerestart,GETDATE()) - EstHoursSinceActive as x
	   FROM @confidence
    ) conversions
  ) rates
) intervals
) confidence ON confidence.DBName = base.name
LEFT OUTER JOIN sys.databases dbs ON dbs.database_id = base.database_id

ORDER BY base.name

	RAISERROR (N'Database usage likelyhood measured',0,1) WITH NOWAIT;

			/*----------------------------------------
			--Calculate daily IO workload
			----------------------------------------*/
/*
INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 31, 'Possible TempDB Slowness','------','------'

With Tasks
As (Select session_id,
        wait_type,
        wait_duration_ms,
        blocking_session_id,
        resource_description,
        PageID = Cast(Right(resource_description, Len(resource_description)
                - Charindex(':', resource_description, 3)) As Int)
    From sys.dm_os_waiting_tasks
    Where wait_type Like 'PAGE%LATCH_%'
    And resource_description Like '2:%')
INSERT #output_man_script (SectionID, Section,Summary,Details)
Select session_id,
        wait_type,
        wait_duration_ms,
        blocking_session_id,
        resource_description,
    ResourceType = Case
        When PageID = 1 Or PageID % 8088 = 0 Then 'Is PFS Page'
        When PageID = 2 Or PageID % 511232 = 0 Then 'Is GAM Page'
        When PageID = 3 Or (PageID - 1) % 511232 = 0 Then 'Is SGAM Page'
        Else 'Is Not PFS, GAM, or SGAM page'
    End
From Tasks;

	RAISERROR (N'Slow TempDB checked',0,1) WITH NOWAIT;
*/
			/*----------------------------------------
			--Calculate daily IO workload
			----------------------------------------*/

	BEGIN TRY
		IF OBJECT_ID('tempdb.dbo.#LEXEL_OES_stats_sql_handle_convert_table', 'U') IS NOT NULL
		EXEC ('DROP TABLE #LEXEL_OES_stats_sql_handle_convert_table;')
		CREATE TABLE #LEXEL_OES_stats_sql_handle_convert_table (
				 row_id INT identity 
				, t_sql_handle varbinary(64)
				, t_display_option varchar(140) collate database_default
				, t_display_optionIO varchar(140) collate database_default
				, t_sql_handle_text varchar(140) collate database_default
				, t_SPRank INT
				, t_dbid INT
				, t_objectid INT
				, t_SQLStatement varchar(max) collate database_default
				, t_execution_count INT
				, t_plan_generation_num INT
				, t_last_execution_time datetime
				, t_avg_worker_time FLOAT
				, t_total_worker_time FLOAT
				, t_last_worker_time FLOAT
				, t_min_worker_time FLOAT
				, t_max_worker_time FLOAT
				, t_avg_logical_reads FLOAT
				, t_total_logical_reads BIGINT
				, t_last_logical_reads BIGINT
				, t_min_logical_reads BIGINT
				, t_max_logical_reads BIGINT
				, t_avg_logical_writes FLOAT
				, t_total_logical_writes BIGINT
				, t_last_logical_writes BIGINT
				, t_min_logical_writes BIGINT
				, t_max_logical_writes BIGINT
				, t_avg_logical_IO FLOAT
				, t_total_logical_IO BIGINT
				, t_last_logical_IO BIGINT
				, t_min_logical_IO BIGINT
				, t_max_logical_IO BIGINT 
				);
		IF OBJECT_ID('tempdb.dbo.#LEXEL_OES_stats_objects', 'U') IS NOT NULL
		 EXEC ('DROP TABLE #LEXEL_OES_stats_objects;')
		CREATE TABLE #LEXEL_OES_stats_objects (
				 obj_rank INT
				, total_cpu BIGINT
				, total_logical_reads BIGINT
				, total_logical_writes BIGINT
				, total_logical_io BIGINT
				, avg_cpu BIGINT
				, avg_reads BIGINT
				, avg_writes BIGINT
				, avg_io BIGINT
				, cpu_rank INT
				, total_cpu_rank INT
				, logical_read_rank INT
				, logical_write_rank INT
				, logical_io_rank INT
				);
		IF OBJECT_ID('tempdb.dbo.#LEXEL_OES_stats_object_name', 'U') IS NOT NULL
		 EXEC ('DROP TABLE #LEXEL_OES_stats_object_name;')
		CREATE TABLE #LEXEL_OES_stats_object_name (
				 dbId INT
				, objectId INT
				, dbName sysname collate database_default null
				, objectName sysname collate database_default null
				, objectType nvarchar(5) collate database_default null
				, schemaName sysname collate database_default null
				)

		IF OBJECT_ID('tempdb.dbo.#LEXEL_OES_stats_output', 'U') IS NOT NULL
		 EXEC ('DROP TABLE #LEXEL_OES_stats_output;')
		CREATE TABLE #LEXEL_OES_stats_output(
			ID INT IDENTITY(1,1)
			, evaldate DATETIME DEFAULT GETDATE()
			, domain VARCHAR(50) DEFAULT DEFAULT_DOMAIN()
			, SQLInstance VARCHAR(50) DEFAULT @@SERVERNAME
			, [Type] varchar(25) NOT NULL
			, l1 INT NULL
			, l2 BIGINT NULL
			, row_id INT NOT NULL
			, t_obj_name VARCHAR(250)  NULL
			, t_obj_type VARCHAR(250)  NULL
			, [schema_name] VARCHAR(250)  NULL
			, t_db_name VARCHAR(250) NULL
			, t_sql_handle varbinary(64) NULL
			, t_SPRank INT NULL
			, t_SPRank2 INT NULL
			, t_SQLStatement varchar(max) NULL
			, t_execution_count INT NULL
			, t_plan_generation_num INT NULL
			, t_last_execution_time datetime NULL
			, t_avg_worker_time float NULL
			, t_total_worker_time BIGINT NULL
			, t_last_worker_time BIGINT NULL
			, t_min_worker_time BIGINT NULL
			, t_max_worker_time BIGINT NULL
			, t_avg_logical_reads float NULL
			, t_total_logical_reads BIGINT NULL
			, t_last_logical_reads BIGINT NULL
			, t_min_logical_reads BIGINT NULL
			, t_max_logical_reads BIGINT NULL
			, t_avg_logical_writes float NULL
			, t_total_logical_writes BIGINT NULL
			, t_last_logical_writes BIGINT NULL
			, t_min_logical_writes BIGINT NULL
			, t_max_logical_writes BIGINT NULL
			, t_avg_IO float NULL
			, t_total_IO BIGINT NULL
			, t_last_IO BIGINT NULL
			, t_min_IO BIGINT NULL
			, t_max_IO BIGINT NULL
			, t_CPURank INT NULL
			, t_ReadRank INT NULL
			, t_WriteRank INT NULL
		) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]



		INSERT INTO #LEXEL_OES_stats_sql_handle_convert_table 
		SELECT
		sql_handle
		, sql_handle AS chart_display_option 
		, sql_handle AS chart_display_optionIO 
		, master.dbo.fn_varbintohexstr(sql_handle)
		, dense_RANK() over (order by s2.dbid,s2.objectid) AS SPRank 
		, s2.dbid
		, s2.objectid
		, (SELECT top 1 substring(text,(s1.statement_start_offset+2)/2, (CASE WHEN s1.statement_end_offset = -1 then len(convert(nvarchar(max),text))*2 else s1.statement_end_offset end - s1.statement_start_offset) /2 ) FROM sys.dm_exec_sql_text(s1.sql_handle)) AS [SQL Statement]
		, execution_count
		, plan_generation_num
		, last_execution_time
		, ((total_worker_time+0.0)/execution_count)/1000 AS [avg_worker_time]
		, total_worker_time/1000.0
		, last_worker_time/1000.0
		, min_worker_time/1000.0
		, max_worker_time/1000.0
		, ((total_logical_reads+0.0)/execution_count) AS [avg_logical_reads]
		, total_logical_reads
		, last_logical_reads
		, min_logical_reads
		, max_logical_reads
		, ((total_logical_writes+0.0)/execution_count) AS [avg_logical_writes]
		, total_logical_writes
		, last_logical_writes
		, min_logical_writes
		, max_logical_writes
		, ((total_logical_writes+0.0)/execution_count + (total_logical_reads+0.0)/execution_count) AS [avg_logical_IO]
		, total_logical_writes + total_logical_reads
		, last_logical_writes +last_logical_reads
		, min_logical_writes +min_logical_reads
		, max_logical_writes + max_logical_reads 
		FROM sys.dm_exec_query_stats s1 
		CROSS APPLY sys.dm_exec_sql_text(sql_handle) s2 
		WHERE s2.objectid IS NOT NULL AND db_name(s2.dbid) IS NOT NULL
		AND (execution_count >= @MinExecutionCount OR (total_worker_time/1000.0) > 10)
		ORDER BY s1.sql_handle; 

		SELECT @grand_total_worker_time = SUM(t_total_worker_time)
		, @grand_total_IO = SUM(t_total_logical_reads + t_total_logical_writes) 
		from #LEXEL_OES_stats_sql_handle_convert_table; 
		SELECT @grand_total_worker_time = CASE WHEN @grand_total_worker_time > 0 THEN @grand_total_worker_time ELSE 1.0 END ; 
		SELECT @grand_total_IO = CASE WHEN @grand_total_IO > 0 THEN @grand_total_IO ELSE 1.0 END ; 

		set @cnt = 1; 
		SELECT @record_count = count(*) FROM #LEXEL_OES_stats_sql_handle_convert_table ; 
		WHILE (@cnt <= @record_count) 
		BEGIN 
		 SELECT @dbid = t_dbid
		 , @objectid = t_objectid 
		 FROM #LEXEL_OES_stats_sql_handle_convert_table WHERE row_id = @cnt; 
		 if not exists (SELECT 1 FROM #LEXEL_OES_stats_object_name WHERE objectId = @objectid AND dbId = @dbid )
		 BEGIN
		 SET @cmd = 'SELECT '+convert(nvarchar(10),@dbid)+','+convert(nvarchar(100),@objectid)+','''+db_name(@dbid)+'''
					 , obj.name,obj.type
					 , CASE WHEN sch.name IS NULL THEN '''' ELSE sch.name END 
		 FROM ['+db_name(@dbid)+'].sys.objects obj 
					 LEFT OUTER JOIN ['+db_name(@dbid)+'].sys.schemas sch on(obj.schema_id = sch.schema_id) 
		 WHERE obj.object_id = '+convert(nvarchar(100),@objectid)+ ';'
		 INSERT INTO #LEXEL_OES_stats_object_name
		 EXEC(@cmd)
				END
		 SET @cnt = @cnt + 1 ; 
		END ; 

		INSERT INTO #LEXEL_OES_stats_objects 
		SELECT t_SPRank
		, SUM(t_total_worker_time)
		, SUM(t_total_logical_reads)
		, SUM(t_total_logical_writes)
		, SUM(t_total_logical_IO)
		, SUM(t_avg_worker_time) AS avg_cpu
		, SUM(t_avg_logical_reads)
		, SUM(t_avg_logical_writes)
		, SUM(t_avg_logical_IO)
		, RANK()OVER (ORDER BY SUM(t_avg_worker_time) DESC)
		, RANK()OVER (ORDER BY SUM(t_total_worker_time) DESC)
		, RANK()OVER (ORDER BY SUM(t_avg_logical_reads) DESC)
		, RANK()OVER (ORDER BY SUM(t_avg_logical_writes) DESC)
		, RANK()OVER (ORDER BY SUM(t_total_logical_IO) DESC)
		FROM #LEXEL_OES_stats_sql_handle_convert_table 
		GROUP BY t_SPRank ; 

		UPDATE #LEXEL_OES_stats_sql_handle_convert_table SET t_display_option = 'show_total' 
		WHERE t_SPRank IN (SELECT obj_rank FROM #LEXEL_OES_stats_objects WHERE (total_cpu+0.0)/@grand_total_worker_time < 0.05) ; 

		UPDATE #LEXEL_OES_stats_sql_handle_convert_table SET t_display_option = t_sql_handle_text 
		WHERE t_SPRank IN (SELECT obj_rank FROM #LEXEL_OES_stats_objects WHERE total_cpu_rank <= 5) ; 

		UPDATE #LEXEL_OES_stats_sql_handle_convert_table SET t_display_option = 'show_total' 
		WHERE t_SPRank IN (SELECT obj_rank FROM #LEXEL_OES_stats_objects WHERE (total_cpu+0.0)/@grand_total_worker_time < 0.005); 

		UPDATE #LEXEL_OES_stats_sql_handle_convert_table SET t_display_optionIO = 'show_total' 
		WHERE t_SPRank IN (SELECT obj_rank FROM #LEXEL_OES_stats_objects WHERE (total_logical_io+0.0)/@grand_total_IO < 0.05); 

		UPDATE #LEXEL_OES_stats_sql_handle_convert_table SET t_display_optionIO = t_sql_handle_text 
		WHERE t_SPRank IN (SELECT obj_rank FROM #LEXEL_OES_stats_objects WHERE logical_io_rank <= 5) ; 

		UPDATE #LEXEL_OES_stats_sql_handle_convert_table SET t_display_optionIO = 'show_total' 
		WHERE t_SPRank IN (SELECT obj_rank FROM #LEXEL_OES_stats_objects WHERE (total_logical_io+0.0)/@grand_total_IO < 0.005); 


	END TRY
	BEGIN CATCH 
		SELECT -100 AS l1
		, ERROR_NUMBER() AS l2
		, ERROR_SEVERITY() AS row_id
		, ERROR_STATE() AS t_sql_handle
		, ERROR_MESSAGE() AS t_display_option
		, 1 AS t_display_optionIO, 1 AS t_sql_handle_text,1 AS t_SPRank,1 AS t_dbid ,1 AS t_objectid ,1 AS t_SQLStatement,1 AS t_execution_count,1 AS t_plan_generation_num,1 AS t_last_execution_time, 1 AS t_avg_worker_time, 1 AS t_total_worker_time, 1 AS t_last_worker_time, 1 AS t_min_worker_time, 1 AS t_max_worker_time, 1 AS t_avg_logical_reads, 1 AS t_total_logical_reads, 1 AS t_last_logical_reads, 1 AS t_min_logical_reads, 1 AS t_max_logical_reads, 1 AS t_avg_logical_writes, 1 AS t_total_logical_writes, 1 AS t_last_logical_writes, 1 AS t_min_logical_writes, 1 AS t_max_logical_writes, 1 AS t_avg_logical_IO, 1 AS t_total_logical_IO, 1 AS t_last_logical_IO, 1 AS t_min_logical_IO, 1 AS t_max_logical_IO, 1 AS t_CPURank, 1 AS t_logical_ReadRank, 1 AS t_logical_WriteRank, 1 AS t_obj_name, 1 AS t_obj_type, 1 AS schama_name, 1 AS t_db_name 
	END CATCH

	BEGIN TRY
	set @dbid = db_id(); 
	SET @cnt = 0; 
	SET @record_count = 0; 
	declare @sql_handle varbinary(64); 
	declare @sql_handle_string varchar(130); 
	SET @grand_total_worker_time = 0 ; 
	SET @grand_total_IO = 0 ; 

	IF OBJECT_ID('tempdb..#sql_handle_convert_table') IS NOT NULL
				DROP TABLE #sql_handle_convert_table;
	CREATE TABLE #sql_handle_convert_table (
	 row_id INT identity 
	, t_sql_handle varbinary(64)
	, t_display_option varchar(140) collate database_default
	, t_display_optionIO varchar(140) collate database_default
	, t_sql_handle_text varchar(140) collate database_default
	, t_SPRank INT
	, t_SPRank2 INT
	, t_SQLStatement varchar(max) collate database_default
	, t_execution_count INT 
	, t_plan_generation_num INT
	, t_last_execution_time datetime
	, t_avg_worker_time FLOAT
	, t_total_worker_time BIGINT
	, t_last_worker_time BIGINT
	, t_min_worker_time BIGINT
	, t_max_worker_time BIGINT 
	, t_avg_logical_reads FLOAT
	, t_total_logical_reads BIGINT
	, t_last_logical_reads BIGINT
	, t_min_logical_reads BIGINT 
	, t_max_logical_reads BIGINT
	, t_avg_logical_writes FLOAT
	, t_total_logical_writes BIGINT
	, t_last_logical_writes BIGINT
	, t_min_logical_writes BIGINT
	, t_max_logical_writes BIGINT
	, t_avg_IO FLOAT
	, t_total_IO BIGINT
	, t_last_IO BIGINT
	, t_min_IO BIGINT
	, t_max_IO BIGINT
	);

	IF OBJECT_ID('tempdb..#perf_report_objects') IS NOT NULL
				DROP TABLE #perf_report_objects;
	CREATE TABLE #perf_report_objects (
	 obj_rank INT
	, total_cpu BIGINT 
	, total_reads BIGINT
	, total_writes BIGINT
	, total_io BIGINT
	, avg_cpu BIGINT 
	, avg_reads BIGINT
	, avg_writes BIGINT
	, avg_io BIGINT
	, cpu_rank INT
	, total_cpu_rank INT
	, read_rank INT
	, write_rank INT
	, io_rank INT
	); 

	INSERT INTO #sql_handle_convert_table
	SELECT sql_handle
	, sql_handle AS chart_display_option 
	, sql_handle AS chart_display_optionIO 
	, master.dbo.fn_varbintohexstr(sql_handle)
	, dense_RANK() over (order by s1.sql_handle) AS SPRank 
	, dense_RANK() over (partition by s1.sql_handle order by s1.statement_start_offset) AS SPRank2
	, replace(replace(replace(replace(CONVERT(NVARCHAR(MAX),(SELECT top 1 substring(text,(s1.statement_start_offset+2)/2, (CASE WHEN s1.statement_end_offset = -1 then len(convert(nvarchar(max),text))*2 else s1.statement_end_offset end - s1.statement_start_offset) /2 ) FROM sys.dm_exec_sql_text(s1.sql_handle))), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), ' ',' ') AS [SQL Statement]
	, execution_count
	, plan_generation_num
	, last_execution_time
	, ((total_worker_time+0.0)/execution_count)/1000 AS [avg_worker_time]
	, total_worker_time/1000
	, last_worker_time/1000
	, min_worker_time/1000
	, max_worker_time/1000
	, ((total_logical_reads+0.0)/execution_count) AS [avg_logical_reads]
	, total_logical_reads
	, last_logical_reads
	, min_logical_reads
	, max_logical_reads
	, ((total_logical_writes+0.0)/execution_count) AS [avg_logical_writes]
	, total_logical_writes
	, last_logical_writes
	, min_logical_writes
	, max_logical_writes
	, ((total_logical_writes+0.0)/execution_count + (total_logical_reads+0.0)/execution_count) AS [avg_IO]
	, total_logical_writes + total_logical_reads
	, last_logical_writes +last_logical_reads
	, min_logical_writes +min_logical_reads
	, max_logical_writes + max_logical_reads 
	from sys.dm_exec_query_stats s1 
	cross apply sys.dm_exec_sql_text(sql_handle) AS s2 
	WHERE s2.objectid is null
	AND (execution_count >= @MinExecutionCount OR (total_worker_time/1000.0) > 10)
	order by s1.sql_handle; 

	SELECT @grand_total_worker_time = SUM(t_total_worker_time) 
	, @grand_total_IO = SUM(t_total_logical_reads + t_total_logical_writes) 
	from #sql_handle_convert_table; 

	SELECT @grand_total_worker_time = CASE WHEN @grand_total_worker_time > 0 then @grand_total_worker_time else 1.0 end ; 
	SELECT @grand_total_IO = CASE WHEN @grand_total_IO > 0 then @grand_total_IO else 1.0 end ; 

	Insert INTo #perf_report_objects 
	SELECT t_SPRank
	, SUM(t_total_worker_time)
	, SUM(t_total_logical_reads)
	, SUM(t_total_logical_writes)
	, SUM(t_total_IO)
	, SUM(t_avg_worker_time) AS avg_cpu
	, SUM(t_avg_logical_reads)
	, SUM(t_avg_logical_writes)
	, SUM(t_avg_IO)
	, RANK() OVER(ORDER BY SUM(t_avg_worker_time) DESC)
	, ROW_NUMBER() OVER(ORDER BY SUM(t_total_worker_time) DESC)
	, ROW_NUMBER() OVER(ORDER BY SUM(t_avg_logical_reads) DESC)
	, ROW_NUMBER() OVER(ORDER BY SUM(t_avg_logical_writes) DESC)
	, ROW_NUMBER() OVER(ORDER BY SUM(t_total_IO) DESC)
	from #sql_handle_convert_table
	group by t_SPRank ; 

	UPDATE #sql_handle_convert_table SET t_display_option = 'show_total'
	WHERE t_SPRank IN (SELECT obj_rank FROM #perf_report_objects WHERE (total_cpu+0.0)/@grand_total_worker_time < 0.05) ; 

	UPDATE #sql_handle_convert_table SET t_display_option = t_sql_handle_text 
	WHERE t_SPRank IN (SELECT obj_rank FROM #perf_report_objects WHERE total_cpu_rank <= 5) ; 

	UPDATE #sql_handle_convert_table SET t_display_option = 'show_total' 
	WHERE t_SPRank IN (SELECT obj_rank FROM #perf_report_objects WHERE (total_cpu+0.0)/@grand_total_worker_time < 0.005); 

	UPDATE #sql_handle_convert_table SET t_display_optionIO = 'show_total' 
	WHERE t_SPRank IN (SELECT obj_rank FROM #perf_report_objects WHERE (total_io+0.0)/@grand_total_IO < 0.05); 

	UPDATE #sql_handle_convert_table SET t_display_optionIO = t_sql_handle_text 
	WHERE t_SPRank IN (SELECT obj_rank FROM #perf_report_objects WHERE io_rank <= 5) ; 

	UPDATE #sql_handle_convert_table SET t_display_optionIO = 'show_total' 
	WHERE t_SPRank IN (SELECT obj_rank FROM #perf_report_objects WHERE (total_io+0.0)/@grand_total_IO < 0.005); 


	END TRY
	begin catch
	SELECT -100 AS l1
	, ERROR_NUMBER() AS l2
	, ERROR_SEVERITY() AS row_id
	, ERROR_STATE() AS t_sql_handle
	, ERROR_MESSAGE() AS t_display_option
	, 1 AS t_display_optionIO, 1 AS t_sql_handle_text, 1 AS t_SPRank, 1 AS t_SPRank2, 1 AS t_SQLStatement, 1 AS t_execution_count , 1 AS t_plan_generation_num, 1 AS t_last_execution_time, 1 AS t_avg_worker_time, 1 AS t_total_worker_time, 1 AS t_last_worker_time, 1 AS t_min_worker_time, 1 AS t_max_worker_time, 1 AS t_avg_logical_reads 
	, 1 AS t_total_logical_reads, 1 AS t_last_logical_reads, 1 AS t_min_logical_reads, 1 AS t_max_logical_reads, 1 AS t_avg_logical_writes, 1 AS t_total_logical_writes, 1 AS t_last_logical_writes, 1 AS t_min_logical_writes, 1 AS t_max_logical_writes, 1 AS t_avg_IO, 1 AS t_total_IO, 1 AS t_last_IO, 1 AS t_min_IO, 1 AS t_max_IO, 1 AS t_CPURank, 1 AS t_ReadRank, 1 AS t_WriteRank
	end catch



	INSERT INTO #LEXEL_OES_stats_output
	(evaldate, [Type], l1, l2, row_id, t_obj_name, t_obj_type, [schema_name], t_db_name, t_sql_handle, t_SPRank, t_SPRank2, t_SQLStatement
	, t_execution_count, t_plan_generation_num, t_last_execution_time, t_avg_worker_time, t_total_worker_time, t_last_worker_time, t_min_worker_time, t_max_worker_time, t_avg_logical_reads
	, t_total_logical_reads, t_last_logical_reads, t_min_logical_reads, t_max_logical_reads, t_avg_logical_writes, t_total_logical_writes, t_last_logical_writes, t_min_logical_writes
	, t_max_logical_writes, t_avg_IO, t_total_IO, t_last_IO, t_min_IO, t_max_IO, t_CPURank, t_ReadRank, t_WriteRank)
	SELECT @evaldate
	, 'OBJECT' [Type]
	, (s.t_SPRank)%2 AS l1
	, (DENSE_RANK() OVER(ORDER BY s.t_SPRank,s.row_id))%2 AS l2
	, row_id
	, objname.objectName AS t_obj_name
	, objname.objectType AS [t_obj_type]
	, objname.schemaName AS schema_name
	, objname.dbName AS t_db_name
	, s.t_sql_handle
	--, s.t_display_option
	--, s.t_display_optionIO
	--,s.t_sql_handle_text
	, s.t_SPRank 
	, NULL t_SPRank2 
	, replace(replace(replace(replace(CONVERT(NVARCHAR(MAX),s.t_SQLStatement), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), ' ',' ') t_SQLStatement 
	, s.t_execution_count 
	, s.t_plan_generation_num 
	, s.t_last_execution_time 
	, s.t_avg_worker_time 
	, s.t_total_worker_time 
	, s.t_last_worker_time 
	, s.t_min_worker_time 
	, s.t_max_worker_time 
	, s.t_avg_logical_reads 
	, s.t_total_logical_reads
	, s.t_last_logical_reads 
	, s.t_min_logical_reads 
	, s.t_max_logical_reads 
	, s.t_avg_logical_writes 
	, s.t_total_logical_writes 
	, s.t_last_logical_writes 
	, s.t_min_logical_writes 
	, s.t_max_logical_writes 
	, t_avg_logical_IO t_avg_IO 
	, t_total_logical_IO t_total_IO 
	, t_last_logical_IO t_last_IO 
	, t_min_logical_IO t_min_IO 
	, t_max_logical_IO t_max_IO
	, ob.cpu_rank AS t_CPURank 
	, ob.logical_read_rank t_ReadRank 
	, ob.logical_write_rank t_WriteRank 

	FROM #LEXEL_OES_stats_sql_handle_convert_table s 
	JOIN #LEXEL_OES_stats_objects ob on (s.t_SPRank = ob.obj_rank)
	JOIN #LEXEL_OES_stats_object_name AS objname on (objname.dbId = s.t_dbid and objname.objectId = s.t_objectid )


	INSERT INTO #LEXEL_OES_stats_output
	(evaldate, [Type], l1, l2, row_id, t_obj_name, t_obj_type, [schema_name], t_db_name, t_sql_handle, t_SPRank, t_SPRank2, t_SQLStatement
	, t_execution_count, t_plan_generation_num, t_last_execution_time, t_avg_worker_time, t_total_worker_time, t_last_worker_time, t_min_worker_time, t_max_worker_time, t_avg_logical_reads
	, t_total_logical_reads, t_last_logical_reads, t_min_logical_reads, t_max_logical_reads, t_avg_logical_writes, t_total_logical_writes, t_last_logical_writes, t_min_logical_writes
	, t_max_logical_writes, t_avg_IO, t_total_IO, t_last_IO, t_min_IO, t_max_IO, t_CPURank, t_ReadRank, t_WriteRank)
	SELECT 
	  @evaldate
	, 'BATCH' [Type]
	, (s.t_SPRank)%2 AS l1
	, (dense_RANK() OVER(ORDER BY s.t_SPRank,s.row_id))%2 AS l2
	, row_id
	, NULL t_obj_name
	, NULL [t_obj_type]
	, NULL schema_name
	, NULL t_db_name
	, s.t_sql_handle
	--, s. t_display_option
	--, s.t_display_optionIO 
	--, s.t_sql_handle_text 
	, s.t_SPRank 
	, s.t_SPRank2 
	, replace(replace(replace(replace(replace(CONVERT(NVARCHAR(MAX),t_SQLStatement), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), ' ',' '),'  ', ' ') t_SQLStatement 
	, s.t_execution_count 
	, s.t_plan_generation_num 
	, s.t_last_execution_time 
	, s.t_avg_worker_time 
	, s.t_total_worker_time 
	, s.t_last_worker_time 
	, s.t_min_worker_time 
	, s.t_max_worker_time 
	, s.t_avg_logical_reads 
	, s.t_total_logical_reads
	, s.t_last_logical_reads 
	, s.t_min_logical_reads 
	, s.t_max_logical_reads 
	, s.t_avg_logical_writes 
	, s.t_total_logical_writes 
	, s.t_last_logical_writes 
	, s.t_min_logical_writes 
	, s.t_max_logical_writes 
	, s.t_avg_IO 
	, s.t_total_IO 
	, s.t_last_IO 
	, s.t_min_IO 
	, s.t_max_IO
	, ob.cpu_rank AS t_CPURank 
	, ob.read_rank AS t_ReadRank 
	, ob.write_rank AS t_WriteRank 
	FROM  #sql_handle_convert_table s join #perf_report_objects ob on (s.t_SPRank = ob.obj_rank)


	SELECT @TotalIODailyWorkload = SUM(CONVERT(MONEY,CONVERT(FLOAT,t_total_IO) * 8 /*KB*/ /1024/*MB*//1024)/@DaysOldestCachedQuery)  
	FROM #LEXEL_OES_stats_output

	INSERT #output_man_script (SectionID, Section,Summary, Details) SELECT 99, 'Workload details I/O','------','------'
	INSERT #output_man_script (SectionID, Section,Summary,Details)
	SELECT  99 [SectionID]
	, 'Oldest Cache: ' + CONVERT(VARCHAR(15), @DaysOldestCachedQuery) + '; Days Uptime: ' + CONVERT(VARCHAR(15),@DaysUptime) [Section]
	, CONVERT(VARCHAR(15),SUM(CONVERT(MONEY,CONVERT(FLOAT,t_total_IO) * 8 /*KB*/ /1024/*MB*//1024)/@DaysOldestCachedQuery)  )
	+ 'GB/day; ' + CONVERT(VARCHAR(15),SUM(CASE WHEN t_execution_count = 1 THEN 1 ELSE CONVERT(MONEY,t_execution_count)/@DaysOldestCachedQuery END) ) 
	+ ' executions/day; ' +  CONVERT(VARCHAR(15),SUM(CONVERT(MONEY,t_avg_worker_time)/1000 ))
	+ ' s(avg) *[DailyGB; DailyExecutions; AverageTime(s)]' Summary
	, 'Total' [Details]
	FROM #LEXEL_OES_stats_output
	GROUP BY domain, SQLInstance

	INSERT #output_man_script (SectionID, Section,Summary,Details)
	SELECT
	 99 [SectionID]
	, REPLICATE('|', CONVERT(INT,(CONVERT(MONEY,t_total_IO * 8 /*KB*/ /1024/*MB*//1024)/@DaysOldestCachedQuery )/@TotalIODailyWorkload *100)) + ' ' + CONVERT(VARCHAR(10),(CONVERT(MONEY,CONVERT(FLOAT,t_total_IO) * 8 /*KB*/ /1024/*MB*//1024)/@DaysOldestCachedQuery )/@TotalIODailyWorkload *100) + '%' [Section]
	, CONVERT(VARCHAR(15),(CONVERT(MONEY,CONVERT(FLOAT,t_total_IO) * 8 /*KB*/ /1024/*MB*//1024)/@DaysOldestCachedQuery) )
	+ 'GB/day; ' + CONVERT(VARCHAR(15),(CASE WHEN t_execution_count = 1 THEN 1 ELSE CONVERT(MONEY,t_execution_count)/@DaysOldestCachedQuery END) ) 
	+ ' executions/day; ' +  CONVERT(VARCHAR(15),(CONVERT(MONEY,t_avg_worker_time_S)))
	+ ' s(avg) *[DailyGB; DailyExecutions; AverageTime(s)]' [Summary]
	, '/*' + [Type] + '; '+ t_obj_name + ' [' + t_db_name + '].[' + schema_name + '] > */' + t_SQLStatement [Details] 
	FROM (

	SELECT TOP 10 ID
		, @evaldate [evaldate]
		, domain
		, SQLInstance
		, [Type]
		, row_id
		, t_obj_name
		, t_obj_type
		, [schema_name]
		, t_db_name
		, replace(replace(replace(replace(replace(CONVERT(NVARCHAR(MAX),t_SQLStatement), CHAR(9), ' '),CHAR(10),' '), CHAR(13), ' '), ' ',' '),'  ', ' ') t_SQLStatement
		, t_execution_count
		, CASE WHEN t_execution_count = 1 THEN 1 ELSE CONVERT(MONEY,t_execution_count)/@DaysOldestCachedQuery END AS [t_execution_count_Daily]
		, t_plan_generation_num
		, CONVERT(MONEY,CONVERT(FLOAT,t_avg_worker_time)/1000) t_avg_worker_time_S
		, CONVERT(MONEY,CONVERT(FLOAT,t_total_worker_time)/1000)  t_total_worker_time_S
		, CONVERT(MONEY,t_avg_logical_reads) t_avg_logical_reads
		, t_total_logical_reads
		, CONVERT(MONEY,t_avg_logical_writes) t_avg_logical_writes
		, t_total_logical_writes
		,  CONVERT(MONEY,t_avg_IO) t_avg_IO
		, t_total_IO
		, CONVERT(MONEY,CONVERT(FLOAT,t_avg_IO) * 8 /*KB*/ /1024/*MB*//1024) [Average Workload GB]
		, CONVERT(MONEY,CONVERT(FLOAT,t_total_IO) * 8 /*KB*/ /1024/*MB*//1024) [Total Workload GB]
		, CONVERT(MONEY,CONVERT(FLOAT,t_total_IO) * 8 /*KB*/ /1024/*MB*//1024)/@DaysOldestCachedQuery [Daily Workload GB]
	FROM #LEXEL_OES_stats_output
	ORDER BY t_total_IO DESC
	) T1
	OPTION (RECOMPILE);

	RAISERROR (N'Daily workload calculated',0,1) WITH NOWAIT;

			/*----------------------------------------
			--select output
			----------------------------------------*/
     
	SELECT T1.ID
	,  evaldate
	, T1.domain
	, T1.SQLInstance
	, T1.SectionID
	, T1.Section
	, T1.Summary
	, T1.Details
	, T1.HoursToResolveWithTesting
	, CASE WHEN  @ShowQueryPlan = 1 THEN QueryPlan ELSE NULL END QueryPlan
	FROM #output_man_script T1
	ORDER BY ID ASC
	OPTION (RECOMPILE)

	IF OBJECT_ID('tempdb.#output_man_script') IS NOT NULL
		DROP TABLE #output_man_script  
	IF OBJECT_ID('tempdb.#Action_Statistics') IS NOT NULL
		DROP TABLE #Action_Statistics
	IF OBJECT_ID('tempdb.#db_sps') IS NOT NULL
		DROP TABLE #db_sps
	IF OBJECT_ID('tempdb.#ConfigurationDefaults') IS NOT NULL
		DROP TABLE #ConfigurationDefaults
	IF OBJECT_ID('tempdb..#querystats') IS NOT NULL
		DROP TABLE #querystats
	IF OBJECT_ID('tempdb..#dbccloginfo') IS NOT NULL
		DROP TABLE #dbccloginfo
	IF OBJECT_ID('tempdb..#notrust') IS NOT NULL
		DROP TABLE #notrust
	IF OBJECT_ID('tempdb..#MissingIndex') IS NOT NULL
		DROP TABLE #MissingIndex;
	IF OBJECT_ID('tempdb..#HeapTable') IS NOT NULL
		DROP TABLE #HeapTable;
	IF OBJECT_ID('tempdb..#whatsets') IS NOT NULL
		DROP TABLE #whatsets
	
	IF OBJECT_ID('tempdb.dbo.#LEXEL_OES_stats_sql_handle_convert_table', 'U') IS NOT NULL
		DROP TABLE #LEXEL_OES_stats_sql_handle_convert_table;
	IF OBJECT_ID('tempdb.dbo.#LEXEL_OES_stats_objects', 'U') IS NOT NULL
		DROP TABLE #LEXEL_OES_stats_objects;
	IF OBJECT_ID('tempdb.dbo.#LEXEL_OES_stats_object_name', 'U') IS NOT NULL
		DROP TABLE #LEXEL_OES_stats_object_name;
	IF OBJECT_ID('tempdb..#sql_handle_convert_table') IS NOT NULL
		DROP TABLE #sql_handle_convert_table;
	IF OBJECT_ID('tempdb..#perf_report_objects') IS NOT NULL
		DROP TABLE #perf_report_objects;
	IF OBJECT_ID('tempdb.dbo.#LEXEL_OES_stats_output', 'U') IS NOT NULL
		DROP TABLE #LEXEL_OES_stats_output;

	/*
	SELECT TOP 10
	qs.plan_generation_num,
	qs.execution_count,
	DB_NAME(st.dbid) AS DbName,
	st.objectid,
	st.TEXT
	FROM sys.dm_exec_query_stats qs
	CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS st
	ORDER BY plan_generation_num DESC
	OPTION (RECOMPILE)
	*/

	/* Get current connection details
	SELECT 
	T.program_name
	, T.database_id
	, CASE 
	WHEN T.client_version = 4 THEN 'SQL 2000'
	WHEN T.client_version = 5 THEN 'SQL 2005'
	WHEN T.client_version = 6 THEN 'SQL 2008'
	WHEN T.client_version = 7 THEN 'SQL 2012'
	ELSE 'SQL 2014+'
	END
	, T.client_interface_name
	, T.text_size
	, T.date_format
	, T.date_first
	, T.quoted_identifier
	, T.arithabort
	, T.ansi_null_dflt_on
	, T.ansi_defaults
	, T.ansi_warnings
	, T.ansi_nulls
	, T.concat_null_yields_null
	, T.transaction_isolation_level
	, T.lock_timeout
	, T.deadlock_priority
	, T.prev_error
	 FROM sys.dm_exec_sessions T
	 WHERE T.program_name IS NOT NULL

	 */
    SET NOCOUNT OFF;

--GO
--Sample execution call with the most common parameters:
