uses
  'REST_SkladTerm_Special.U_Const', //nastavovane konstanty
  'StandardUnits.U_GetID';

//PEVNE KONSTANTY
const
  // nazev logu
  REST_LogName = 'REST_Term';

  // tabulka pro rozpracovane objekty
  REST_TABLE_TemporaryStorage = 'REST_TemporaryStorage';

  // fronta k tisku
  REST_TABLE_Print = 'REST_Print';

  // fronta pozadavku
  REST_TABLE_Requests = 'REST_Requests';

  // tabulka prihlasenych uzivatelu
  REST_TABLE_LoggedUsers = 'REST_LoggedUsers';

  REST_CheckTableExistenceSql_FB =
    'select sum("COUNT") from (' + nxCrLf +
    'select distinct 1 as "COUNT"' + nxCrLf +
    'from RDB$RELATION_FIELDS' + nxCrLf +
    'where' + nxCrLf +
    '  RDB$SYSTEM_FLAG = 0' + nxCrLf +
    '  and RDB$RELATION_NAME = ' + QuotedStr(REST_TABLE_Print) + nxCrLf + nxCrLf +
    'union all' + nxCrLf +
    'select distinct 1' + nxCrLf +
    'from RDB$RELATION_FIELDS' + nxCrLf +
    'where' + nxCrLf +
    '  RDB$SYSTEM_FLAG = 0' + nxCrLf +
    '  and RDB$RELATION_NAME = ' + QuotedStr(REST_TABLE_TemporaryStorage) + nxCrLf + nxCrLf +
    'union all' + nxCrLf +
    'select distinct 1' + nxCrLf +
    'from RDB$RELATION_FIELDS' + nxCrLf +
    'where' + nxCrLf +
    '  RDB$SYSTEM_FLAG = 0' + nxCrLf +
    '  and RDB$RELATION_NAME = ' + QuotedStr(REST_TABLE_Requests) + nxCrLf + nxCrLf +
    'union all' + nxCrLf +
    'select distinct 1' + nxCrLf +
    'from RDB$RELATION_FIELDS' + nxCrLf +
    'where' + nxCrLf +
    '  RDB$SYSTEM_FLAG = 0' + nxCrLf +
    '  and RDB$RELATION_NAME = ' + QuotedStr(REST_TABLE_LoggedUsers) + nxCrLf +
    ') X';

  REST_CheckTableExistenceSql_MSSQL =
    'select sum("COUNT") from (' + nxCrLf +
    'select 1 as "COUNT"' + nxCrLf +
    'from sys.tables' + nxCrLf +
    'where' + nxCrLf +
    '  name = ' + QuotedStr(REST_TABLE_Print) + nxCrLf + nxCrLf +
    'union all' + nxCrLf +
    'select 1' + nxCrLf +
    'from sys.tables' + nxCrLf +
    'where' + nxCrLf +
    '  name = ' + QuotedStr(REST_TABLE_TemporaryStorage) + nxCrLf + nxCrLf +
    'union all' + nxCrLf +
    'select 1' + nxCrLf +
    'from sys.tables' + nxCrLf +
    'where' + nxCrLf +
    '  name = ' + QuotedStr(REST_TABLE_Requests) + nxCrLf + nxCrLf +
    'union all' + nxCrLf +
    'select 1' + nxCrLf +
    'from sys.tables' + nxCrLf +
    'where' + nxCrLf +
    '  name = ' + QuotedStr(REST_TABLE_LoggedUsers) + nxCrLf +
    ') X';

  REST_CheckTableExistenceSql_ORACLE =
    '';

  REST_CreateTablesSql_FB =
    '-- tabulka tisku' + nxCrLf +
    'CREATE GENERATOR GEN_REST_PRINT_ID;' + nxCrLf + nxCrLf +
    'CREATE TABLE REST_PRINT (' + nxCrLf +
    '  ID INTEGER NOT NULL,' + nxCrLf +
    '  USER_ID ID NOT NULL,' + nxCrLf +
    '  DOCUMENT_ID TEXTBLOB NOT NULL,' + nxCrLf +
    '  DYNSOURCE_ID GUID_NULL,' + nxCrLf +
    '  REPORT_ID ID_NULL,' + nxCrLf +
    '  FILEPATH DESCRIPTION300 NOT NULL,' + nxCrLf +
    '  PRINTERNAME DESCRIPTION100 NOT NULL,' + nxCrLf +
    '  DATE$DATE DATETIME NOT NULL,' + nxCrLf +
    '  STATUS INTEGER,' + nxCrLf +
    '  ERROR DESCRIPTION300 NOT NULL,' + nxCrLf +
    '  COPIES INTEGER DEFAULT ''1'' NOT NULL,' + nxCrLf +
    '  DATEPRINT$DATE DATETIME NOT NULL,' + nxCrLf +
    '  PARAMETERS TEXTBLOB);' + nxCrLf + nxCrLf +
    'ALTER TABLE REST_PRINT ADD CONSTRAINT PK_REST_PRINT PRIMARY KEY (ID);' + nxCrLf + nxCrLf +
    'SET TERM ^ ;' + nxCrLf + nxCrLf +
    'CREATE TRIGGER REST_PRINT_BI FOR REST_PRINT' + nxCrLf +
    'ACTIVE BEFORE INSERT' + nxCrLf +
    'POSITION 0' + nxCrLf +
    'AS' + nxCrLf +
    'begin' + nxCrLf +
    '  if (new.id is null) then' + nxCrLf +
    '    new.id = gen_id(GEN_REST_Print_ID,1);' + nxCrLf +
    'end^' + nxCrLf + nxCrLf +
    'SET TERM ; ^' + nxCrLf + nxCrLf +
    '-- tabulka rozpracovanosti' + nxCrLf +
    'CREATE GENERATOR GEN_REST_TEMPORARYSTORAGE_ID;' + nxCrLf + nxCrLf +
    'CREATE TABLE REST_TEMPORARYSTORAGE (' + nxCrLf +
    '  ID INTEGER NOT NULL,' + nxCrLf +
    '  USER_ID ID NOT NULL,' + nxCrLf +
    '  DATATYPE DESCRIPTION100 NOT NULL,' + nxCrLf +
    '  STATUS INTEGER,' + nxCrLf +
    '  DATA TEXTBLOB NOT NULL,' + nxCrLf +
    '  DATE$DATE DATETIME NOT NULL,' + nxCrLf +
    '  DOCUMENT_ID ID_NULL);' + nxCrLf + nxCrLf +
    'ALTER TABLE REST_TEMPORARYSTORAGE ADD CONSTRAINT PK_REST_TEMPORARYSTORAGE PRIMARY KEY (ID);' + nxCrLf + nxCrLf +
    'CREATE INDEX I1_REST_TEMPORARYSTORAGE ON REST_TEMPORARYSTORAGE (USER_ID, DATATYPE, STATUS);' + nxCrLf +
    'CREATE INDEX I2_REST_TEMPORARYSTORAGE ON REST_TEMPORARYSTORAGE (USER_ID, DOCUMENT_ID, DATATYPE, STATUS);' + nxCrLf + nxCrLf +
    'SET TERM ^ ;' + nxCrLf + nxCrLf +
    'CREATE TRIGGER REST_TEMPORARYSTORAGE_BI FOR REST_TEMPORARYSTORAGE' + nxCrLf +
    'ACTIVE BEFORE INSERT' + nxCrLf +
    'POSITION 0' + nxCrLf +
    'AS' + nxCrLf +
    'begin' + nxCrLf +
    '  if (new.id is null) then' + nxCrLf +
    '    new.id = gen_id(GEN_REST_TEMPORARYSTORAGE_ID,1);' + nxCrLf +
    'end^' + nxCrLf + nxCrLf +
    'SET TERM ; ^' + nxCrLf + nxCrLf +
    '-- tabulka pozadavku' + nxCrLf +
    'CREATE TABLE REST_REQUESTS (' + nxCrLf +
    '    REQUEST_ID    CODE50 /* CODE50 = VARCHAR(50) DEFAULT '' '' NOT NULL */,' + nxCrLf +
    '    STATE         ENUMERATION /* ENUMERATION = INTEGER DEFAULT 0 NOT NULL */,' + nxCrLf +
    '    SCENARIOTYPE  DESCRIPTION50 /* DESCRIPTION50 = VARCHAR(50) DEFAULT '' '' NOT NULL */,' + nxCrLf +
    '    START$DATE    DATETIME /* DATETIME = DOUBLE PRECISION DEFAULT 0 NOT NULL */,' + nxCrLf +
    '    END$DATE      DATETIME /* DATETIME = DOUBLE PRECISION DEFAULT 0 NOT NULL */' + nxCrLf +
    ');' + nxCrLf + nxCrLf +
    'ALTER TABLE REST_REQUESTS ADD CONSTRAINT PK_REST_REQUESTS PRIMARY KEY (REQUEST_ID);' + nxCrLf + nxCrLf +
    '-- tabulka prihlasenych uzivatelu' + nxCrLf +
    'CREATE TABLE REST_LOGGEDUSERS (' + nxCrLf +
    '    DEVICEID      CODE50 /* CODE50 = VARCHAR(50) DEFAULT '' '' NOT NULL */,' + nxCrLf +
    '    USER_ID       ID NOT NULL,' + nxCrLf +
    '    LOGGEDSINCE$DATE      DATETIME /* DATETIME = DOUBLE PRECISION DEFAULT 0 NOT NULL */' + nxCrLf +
    ');' + nxCrLf + nxCrLf +
    'ALTER TABLE REST_LOGGEDUSERS ADD CONSTRAINT PK_REST_LOGGEDUSERS PRIMARY KEY (DEVICEID, USER_ID);' + nxCrLf;

  REST_CreateTablesSql_MSSQL =
    'begin transaction' + nxCrLf + nxCrLf +
    '-- tabulka tisku' + nxCrLf +
    'SET ANSI_NULLS ON' + nxCrLf + nxCrLf +
    'SET QUOTED_IDENTIFIER ON' + nxCrLf + nxCrLf +
    'SET ANSI_PADDING ON' + nxCrLf + nxCrLf +
    'CREATE TABLE [dbo].[' + REST_TABLE_Print + '](' + nxCrLf +
    '  [ID] [int] IDENTITY(1,1) NOT NULL,' + nxCrLf +
    '  [User_ID] [char](10) COLLATE Czech_CS_AS NOT NULL,' + nxCrLf +
    '  [Document_ID] [varchar](max) COLLATE Czech_CS_AS NOT NULL,' + nxCrLf +
    '  [DynSource_ID] [char](26) COLLATE Czech_CS_AS NOT NULL,' + nxCrLf +
    '  [Report_ID] [char](10) COLLATE Czech_CS_AS NOT NULL,' + nxCrLf +
    '  [Filepath] [varchar](300) COLLATE Czech_CS_AS NOT NULL,' + nxCrLf +
    '  [PrinterName] [varchar](100) COLLATE Czech_CS_AS NOT NULL,' + nxCrLf +
    '  [Date$DATE] [float] NOT NULL,' + nxCrLf +
    '  [Status] [int] NULL,' + nxCrLf +
    '  [Error] [varchar](300) COLLATE Czech_CS_AS NOT NULL,' + nxCrLf +
    '  [Copies] [int] NOT NULL,' + nxCrLf +
    '  [DatePrint$DATE] [float] NOT NULL,' + nxCrLf +
    '  [Parameters] [varchar](max) COLLATE Czech_CS_AS NOT NULL,' + nxCrLf +
    '  CONSTRAINT [PK_' + REST_TABLE_Print + '] PRIMARY KEY CLUSTERED' + nxCrLf +
    '  (' + nxCrLf +
    '    [ID] ASC' + nxCrLf +
    '  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]' + nxCrLf +
    ') ON [PRIMARY]' + nxCrLf +
    '' + nxCrLf + nxCrLf +
    'SET ANSI_PADDING OFF' + nxCrLf + nxCrLf +
    'ALTER TABLE [dbo].[' + REST_TABLE_Print + '] ADD  CONSTRAINT [DF_' + REST_TABLE_Print + '_Copies]  DEFAULT ((1)) FOR [Copies]' + nxCrLf + nxCrLf +
    '-- tabulka rozpracovanosti' + nxCrLf +
    'SET ANSI_PADDING ON' + nxCrLf + nxCrLf +
    'CREATE TABLE [dbo].[' + REST_TABLE_TemporaryStorage + '](' + nxCrLf +
    '  [ID] [int] IDENTITY(1,1) NOT NULL,' + nxCrLf +
    '  [User_ID] [char](10) COLLATE Czech_CS_AS NOT NULL,' + nxCrLf +
    '  [DataType] [varchar](100) COLLATE Czech_CS_AS NOT NULL,' + nxCrLf +
    '  [Status] [int] NULL,' + nxCrLf +
    '  [Data] [varchar](max) COLLATE Czech_CS_AS NOT NULL,' + nxCrLf +
    '  [Date$DATE] [float] NOT NULL,' + nxCrLf +
    '  [Document_ID] [char](10) COLLATE Czech_CS_AS NULL,' + nxCrLf +
    '  CONSTRAINT [PK_' + REST_TABLE_TemporaryStorage + '] PRIMARY KEY CLUSTERED' + nxCrLf +
    '  (' + nxCrLf +
    '    [ID] ASC' + nxCrLf +
    '  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]' + nxCrLf +
    ') ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]' + nxCrLf + nxCrLf +
    'CREATE NONCLUSTERED INDEX [IX_' + REST_TABLE_TemporaryStorage + '] ON [dbo].[' + REST_TABLE_TemporaryStorage + ']' + nxCrLf +
    '(' + nxCrLf +
    '  [User_ID] ASC,' + nxCrLf +
    '  [DataType] ASC,' + nxCrLf +
    '  [Status] ASC' + nxCrLf +
    ')WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]' + nxCrLf + nxCrLf +
    'CREATE NONCLUSTERED INDEX [IX2_' + REST_TABLE_TemporaryStorage + '] ON [dbo].[' + REST_TABLE_TemporaryStorage + ']' + nxCrLf +
    '(' + nxCrLf +
    '  [User_ID] ASC,' + nxCrLf +
    '  [Document_ID] ASC,' + nxCrLf +
    '  [DataType] ASC,' + nxCrLf +
    '  [Status] ASC' + nxCrLf +
    ')WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]' + nxCrLf + nxCrLf +
    '-- tabulka pozadavku' + nxCrLf +
    'CREATE TABLE [dbo].[' + REST_TABLE_Requests + '](' + nxCrLf +
    '  [Request_ID] [char](50) COLLATE Czech_CS_AS NOT NULL,' + nxCrLf +
    '  [State] [int] NOT NULL,' + nxCrLf +
    '  [ScenarioType] [varchar](50) COLLATE Czech_CS_AS NOT NULL,' + nxCrLf +
    '  [Start$DATE] [float] NOT NULL,' + nxCrLf +
    '  [End$DATE] [float] NOT NULL,' + nxCrLf +
    '  CONSTRAINT [PK_' + REST_TABLE_Requests + '] PRIMARY KEY CLUSTERED' + nxCrLf +
    '  (' + nxCrLf +
    '    [Request_ID] ASC' + nxCrLf +
    '  ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]' + nxCrLf +
    ') ON [PRIMARY]' + nxCrLf + nxCrLf +
    '-- tabulka prihlasenych uzivatelu' + nxCrLf +
    'CREATE TABLE [dbo].[' + REST_TABLE_LoggedUsers + '](' + nxCrLf +
    '  [DeviceID] [char](50) COLLATE Czech_CS_AS NOT NULL,' + nxCrLf +
    '  [User_ID] [char](10) COLLATE Czech_CS_AS NOT NULL,' + nxCrLf +
    '  [LoggedSince$DATE] [float] NOT NULL,' + nxCrLf +
    '  CONSTRAINT [PK_' + REST_TABLE_LoggedUsers + '] PRIMARY KEY CLUSTERED' + nxCrLf +
    '  (' + nxCrLf +
    '    [DeviceID], [User_ID] ASC' + nxCrLf +
    '  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]' + nxCrLf +
    ') ON [PRIMARY]' + nxCrLf + nxCrLf +
    'SET ANSI_PADDING OFF' + nxCrLf + nxCrLf +
    'commit transaction';

  REST_CreateTablesSql_ORACLE =
    '';

  REST_DeleteTablesSql_FB =
    '';

  REST_DeleteTablesSql_MSSQL =
    'begin transaction' + nxCrLf + nxCrLf +
    'IF OBJECT_ID(' + QuotedStr(REST_TABLE_Print) + ', ''U'') IS NOT NULL' + nxCrLf +
    'DROP TABLE ' + REST_TABLE_Print + ';' + nxCrLf + nxCrLf +
    'IF OBJECT_ID(' + QuotedStr(REST_TABLE_TemporaryStorage) + ', ''U'') IS NOT NULL' + nxCrLf +
    'DROP TABLE ' + REST_TABLE_TemporaryStorage + ';' + nxCrLf + nxCrLf +
    'IF OBJECT_ID(' + QuotedStr(REST_TABLE_Requests) + ', ''U'') IS NOT NULL' + nxCrLf +
    'DROP TABLE ' + REST_TABLE_Requests + ';' + nxCrLf + nxCrLf +
    'IF OBJECT_ID(' + QuotedStr(REST_TABLE_LoggedUsers) + ', ''U'') IS NOT NULL' + nxCrLf +
    'DROP TABLE ' + REST_TABLE_LoggedUsers + ';' + nxCrLf + nxCrLf +
    'commit transaction';

  REST_DeleteTablesSql_ORACLE =
    '';

  REST_ClearTablesSql_FB =
    '';

  REST_ClearTablesSql_MSSQL =
    'delete from ' + REST_TABLE_Print + nxCrLf +
    'where' + nxCrLf +
    '  Status <> 0' + nxCrLf +
    'delete from ' + REST_TABLE_TemporaryStorage + nxCrLf +
    'where' + nxCrLf +
    '  Status <> 0' + nxCrLf +
    'delete from ' + REST_TABLE_Requests + nxCrLf +
    'where' + nxCrLf +
    '  State <> 0';

  REST_ClearTablesSql_ORACLE =
    '';

  // fieldy v importovanem souboru
  REST_UserStatusesImportField_CLSID        = 'CLSID';
  REST_UserStatusesImportField_Stav         = 'Stav';
  REST_UserStatusesImportField_InterniStav  = 'InterniStav';
  REST_UserStatusesImportField_PrechodZ     = 'PrechodZ';
  REST_UserStatusesImportField_PrechodNa    = 'PrechodNa';
  REST_UserStatusesImportField_ID           = 'ID';
  REST_UserStatusesImportField_Varovani     = 'Varovani';

  REST_UsesStatusesImportHeader =
    REST_UserStatusesImportField_CLSID          + '=S26,' +
    REST_UserStatusesImportField_Stav           + '=S30,' +
    REST_UserStatusesImportField_InterniStav    + '=I,' +
    REST_UserStatusesImportField_PrechodZ       + '=S30,' +
    REST_UserStatusesImportField_PrechodNa      + '=S30,' +
    REST_UserStatusesImportField_ID             + '=S10,' +
    REST_UserStatusesImportField_Varovani       + '=S300';

  REST_DialogValuesDatasetHeader =
    'type=S10,label=S100,field=S50,intValue=I,stringValue=S200,rollValueId=S10,rollName=S50' { + ',decValue=F,boolValue=B};

begin
end.