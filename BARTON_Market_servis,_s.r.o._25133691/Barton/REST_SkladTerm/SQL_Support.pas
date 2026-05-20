(*
Co udelat pri nasazeni:
- vytvorit tabulky nize
- vytvorit pole X_IsAux (Pomocna pozice) (Ano/Ne) v LogStorePositions
- vytvorit pole X_PostNumber_EAN (Podací číslo EAN) (Znaky 20) v Odeslana posta, nezapomenout zaskrtnout Vytvorit index (potreba jen pro scenar Predani baliku dopravci)
- vytvorit pole X_Password na uzivatelich - pouzije se pro prihlasovani do ctecky v pripade zapnuteho domenoveho prihlasovani do Floresu (v te chvili nefunguje NxVerifyUser)
- nahrat a rozchodit skripty REST_SkladTerm, REST_SkladTerm_Special a Correct_CreatedCorrected_User
- pokud se pouziva tisk ze ctecek, pak vytvorit naplanovanou ulohu spousteni skriptu REST_SkladTerm.PA.PA_PrintReports se spustenim kazdou minutu
- nastavit spravne hodnoty vsem konstantam v REST_SkladTerm_Special.U_Const
- vytvorit webove sluzby a operace:
  Nazev: SkladTerm
  Druh sluzby: REST
  Operace:
    get  REST_SkladTerm/U_Get.get
    put  REST_SkladTerm/U_Put.put
    post REST_SkladTerm/U_Post.post

===================================================================
============================ Firebird =============================
===================================================================
-- tabulka tisku
CREATE GENERATOR GEN_REST_PRINT_ID;

CREATE TABLE REST_PRINT (
  ID INTEGER NOT NULL,
  USER_ID ID NOT NULL,
  DOCUMENT_ID TEXTBLOB,
  DYNSOURCE_ID GUID_NULL,
  REPORT_ID ID_NULL,
  FILEPATH DESCRIPTION300,
  PRINTERNAME DESCRIPTION100,
  DATE$DATE DATETIME NOT NULL,
  STATUS INTEGER,
  ERROR DESCRIPTION300,
  COPIES INTEGER DEFAULT '1' NOT NULL,
  DATEPRINT$DATE DATETIME NOT NULL,
  PARAMETERS TEXTBLOB);

ALTER TABLE REST_PRINT ADD CONSTRAINT PK_REST_PRINT PRIMARY KEY (ID);

SET TERM ^ ;

CREATE TRIGGER REST_PRINT_BI FOR REST_PRINT
ACTIVE BEFORE INSERT
POSITION 0
AS
begin
  if (new.id is null) then
    new.id = gen_id(GEN_REST_Print_ID,1);
end^

SET TERM ; ^

-- tabulka rozpracovanych dokladu
CREATE GENERATOR GEN_REST_TEMPORARYSTORAGE_ID;

CREATE TABLE REST_TEMPORARYSTORAGE (
  ID INTEGER NOT NULL,
  USER_ID ID NOT NULL,
  DATATYPE DESCRIPTION100 NOT NULL,
  STATUS INTEGER,
    DATA TEXTBLOB NOT NULL,
  DATE$DATE DATETIME NOT NULL,
  DOCUMENT_ID ID_NULL);

ALTER TABLE REST_TEMPORARYSTORAGE ADD CONSTRAINT PK_REST_TEMPORARYSTORAGE PRIMARY KEY (ID);

CREATE INDEX IX1_REST_TEMPORARYSTORAGE ON REST_TEMPORARYSTORAGE (USER_ID, DATATYPE, STATUS);
CREATE INDEX IX2_REST_TEMPORARYSTORAGE ON REST_TEMPORARYSTORAGE (USER_ID, DOCUMENT_ID, DATATYPE, STATUS);

SET TERM ^ ;

CREATE TRIGGER REST_TEMPORARYSTORAGE_BI FOR REST_TEMPORARYSTORAGE
ACTIVE BEFORE INSERT
POSITION 0
AS
begin
  if (new.id is null) then
    new.id = gen_id(GEN_REST_TEMPORARYSTORAGE_ID,1);
end^

SET TERM ; ^

-- tabulka pozadavku ze ctecky
CREATE TABLE REST_REQUESTS (
    REQUEST_ID CODE50 NOT NULL,
    STATE ENUMERATION  NOT NULL,
    SCENARIOTYPE DESCRIPTION50 NOT NULL,
    START$DATE DATETIME NOT NULL,
    END$DATE DATETIME NOT NULL
);

ALTER TABLE REST_REQUESTS ADD CONSTRAINT PK_REST_REQUESTS PRIMARY KEY (REQUEST_ID);

-- tabulka prihlasenych uzivatelu
CREATE TABLE REST_LOGGEDUSERS (
    DEVICEID CODE50 NOT NULL,
    USER_ID ID NOT NULL,
    LOGGEDSINCE$DATE DATETIME NOT NULL
);

ALTER TABLE REST_LOGGEDUSERS ADD CONSTRAINT PK_REST_LOGGEDUSERS PRIMARY KEY (DEVICEID, USER_ID);

===================================================================
============================== MSSQL ==============================
===================================================================
-- tabulka tisku
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[REST_Print](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[User_ID] [char](10) COLLATE Czech_CS_AS NOT NULL,
	[Document_ID] [varchar](max) COLLATE Czech_CS_AS,
	[DynSource_ID] [char](26) COLLATE Czech_CS_AS,
	[Report_ID] [char](10) COLLATE Czech_CS_AS,
	[Filepath] [varchar](300) COLLATE Czech_CS_AS,
	[PrinterName] [varchar](100) COLLATE Czech_CS_AS,
	[Date$DATE] [float] NOT NULL,
	[Status] [int] NULL,
	[Error] [varchar](300) COLLATE Czech_CS_AS,
	[Copies] [int] NOT NULL,
	[DatePrint$DATE] [float] NOT NULL,
    [Parameters] [varchar](max) COLLATE Czech_CS_AS,
 CONSTRAINT [PK_REST_Print] PRIMARY KEY CLUSTERED
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[REST_Print] ADD  CONSTRAINT [DF_REST_Print_Copies]  DEFAULT ((1)) FOR [Copies]
GO

-- tabulka rozpracovanych dokladu
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[REST_TemporaryStorage](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[User_ID] [char](10) COLLATE Czech_CS_AS NOT NULL,
	[DataType] [varchar](100) COLLATE Czech_CS_AS NOT NULL,
	[Status] [int] NULL,
	[Data] [varchar](max) COLLATE Czech_CS_AS NOT NULL,
	[Date$DATE] [float] NOT NULL,
	[Document_ID] [char](10) COLLATE Czech_CS_AS NULL,
 CONSTRAINT [PK_REST_TemporaryStorage] PRIMARY KEY CLUSTERED
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [IX_REST_TemporaryStorage] ON [dbo].[REST_TemporaryStorage]
(
	[User_ID] ASC,
	[DataType] ASC,
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX2_REST_TemporaryStorage] ON [dbo].[REST_TemporaryStorage]
(
	[User_ID] ASC,
    [Document_ID] ASC,
	[DataType] ASC,
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

-- tabulka pozadavku ze ctecky
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[REST_Requests](
	[Request_ID] [char](50) COLLATE Czech_CS_AS NOT NULL,
	[State] [int] NOT NULL,
	[ScenarioType] [varchar](50) COLLATE Czech_CS_AS NOT NULL,
	[Start$DATE] [float] NOT NULL,
	[End$DATE] [float] NOT NULL,
 CONSTRAINT [PK_REST_Requests] PRIMARY KEY CLUSTERED
(
	[Request_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

-- tabulka prihlasenych uzivatelu
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[REST_LoggedUsers](
	[DeviceID] [char](50) COLLATE Czech_CS_AS NOT NULL,
	[User_ID] [char](10) COLLATE Czech_CS_AS NOT NULL,
	[LoggedSince$DATE] [float] NOT NULL,
 CONSTRAINT [PK_REST_LoggedUsers] PRIMARY KEY CLUSTERED
(
	[DeviceID], [User_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
===================================================================

datove struktury pro ORACLE 11 ===================================================================

===================================================================
// tabulka tisku
CREATE TABLE REST_PRINT (
  ID INTEGER PRIMARY KEY NOT NULL,
  USER_ID CHAR(10) NOT NULL,
  DOCUMENT_ID CLOB NOT NULL,
  DYNSOURCE_ID CHAR(26) NOT NULL,
  REPORT_ID CHAR(10) NOT NULL,
  FILEPATH VARCHAR(300) NOT NULL,
  PRINTERNAME VARCHAR(100) NOT NULL,
  DATE$DATE FLOAT NOT NULL,
  STATUS INTEGER,
  ERROR VARCHAR(300) NOT NULL,
  COPIES INTEGER DEFAULT '1' NOT NULL,
  DATEPRINT$DATE FLOAT NOT NULL,
  PARAMETERS CLOB);

CREATE SEQUENCE REST_PRINT_seq START WITH 1;
CREATE OR REPLACE TRIGGER REST_PRINT_ID_gen
BEFORE INSERT ON REST_PRINT
FOR EACH ROW
BEGIN
  SELECT REST_PRINT_seq.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
===================================================================

===================================================================
// tabulka rozpracovanych dokladu
CREATE TABLE REST_TEMPORARYSTORAGE (
  ID INTEGER PRIMARY KEY NOT NULL,
  USER_ID CHAR(10) NOT NULL,
  DATATYPE VARCHAR(100) NOT NULL,
  STATUS INTEGER,
  DATA CLOB NULL,
  DATE$DATE FLOAT NOT NULL,
  DOCUMENT_ID CHAR(10) NULL);

CREATE SEQUENCE REST_TEMPORARYSTORAGE_seq START WITH 1;
CREATE OR REPLACE TRIGGER REST_TEMPORARYSTORAGE_ID_gen
BEFORE INSERT ON REST_TEMPORARYSTORAGE
FOR EACH ROW
BEGIN
  SELECT REST_TEMPORARYSTORAGE_seq.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
===================================================================

===================================================================
// tabulka pozadavku ze ctecky
CREATE TABLE REST_REQUESTS (
    REQUEST_ID    VARCHAR(50) DEFAULT ' ' PRIMARY KEY NOT NULL,
    STATE         INTEGER DEFAULT 0 NOT NULL,
    SCENARIOTYPE  VARCHAR(50) DEFAULT ' ' NOT NULL,
    START$DATE    FLOAT DEFAULT 0 NOT NULL,
    END$DATE      FLOAT DEFAULT 0 NOT NULL
);
===================================================================

===================================================================
// tabulka prihlasenych uzivatelu
CREATE TABLE REST_LOGGEDUSERS (
    DEVICEID           VARCHAR(50) DEFAULT ' ' NOT NULL,
    USER_ID            CHAR(10) NOT NULL,
    LOGGEDSINCE$DATE   FLOAT DEFAULT 0 NOT NULL
);
===================================================================

===================================================================
====================== ORACLE 12c, Oracle 19 ======================
===================================================================
-- tabulka tisku
CREATE TABLE REST_PRINT (
  ID INTEGER GENERATED ALWAYS AS IDENTITY(START WITH 1 NOCYCLE) PRIMARY KEY NOT NULL,
  USER_ID CHAR(10) NOT NULL,
  DOCUMENT_ID CLOB,
  DYNSOURCE_ID CHAR(26),
  REPORT_ID CHAR(10),
  FILEPATH VARCHAR(300),
  PRINTERNAME VARCHAR(100),
  DATE$DATE FLOAT NOT NULL,
  STATUS INTEGER,
  ERROR VARCHAR(300),
  COPIES INTEGER DEFAULT '1' NOT NULL,
  DATEPRINT$DATE FLOAT NOT NULL,
  PARAMETERS CLOB);
);

-- tabulka rozpracovanych dokladu
CREATE TABLE REST_TEMPORARYSTORAGE (
  ID INTEGER GENERATED ALWAYS AS IDENTITY(START WITH 1 NOCYCLE) PRIMARY KEY NOT NULL,
  USER_ID CHAR(10) NOT NULL,
  DOCUMENT_ID CHAR(10) NULL,
  DATATYPE VARCHAR(100) NOT NULL,
  STATUS INTEGER,
  DATA CLOB NULL,
  DATE$DATE FLOAT NOT NULL);

CREATE INDEX IX_REST_TEMPORARYSTORAGE ON REST_TEMPORARYSTORAGE(USER_ID, DATATYPE, STATUS);
CREATE INDEX IX2_REST_TEMPORARYSTORAGE ON REST_TEMPORARYSTORAGE(USER_ID, DOCUMENT_ID, DATATYPE, STATUS);

-- tabulka pozadavku ze ctecky
CREATE TABLE REST_REQUESTS (
    REQUEST_ID    VARCHAR(50) DEFAULT ' ' PRIMARY KEY NOT NULL,
    STATE         INTEGER DEFAULT 0 NOT NULL,
    SCENARIOTYPE  VARCHAR(50) DEFAULT ' ' NOT NULL,
    START$DATE    FLOAT DEFAULT 0 NOT NULL,
    END$DATE      FLOAT DEFAULT 0 NOT NULL
);

-- tabulka prihlasenych uzivatelu
CREATE TABLE REST_LOGGEDUSERS (
    DEVICEID            VARCHAR(50) DEFAULT ' ' NOT NULL,
    USER_ID             CHAR(10) NOT NULL,
    LOGGEDSINCE$DATE    FLOAT DEFAULT 0 NOT NULL
);
*)

begin
end.