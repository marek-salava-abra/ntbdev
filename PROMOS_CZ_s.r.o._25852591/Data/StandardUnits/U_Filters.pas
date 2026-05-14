(*
CREATE TABLE [dbo].[_Filters] (
  [CLSID] char(26)  COLLATE Czech_CS_AS NOT NULL, --CLSID agendy
  [User_ID] char(10)  COLLATE Czech_CS_AS NOT NULL ,
  [ID] char(10)  COLLATE Czech_CS_AS NOT NULL --ID objektu

CONSTRAINT [_FiltersPK] PRIMARY KEY CLUSTERED
(
	[Site_CLSID],[User_ID],[ID] ASC
) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
)
GO

CREATE NONCLUSTERED INDEX [_FiltersSiteUser] ON [dbo].[_Filters]
(
	[Site_ID],[User_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
*)

////////////////////////////////////////////////////////////////////////////////
//vycisti filtr dane agendy a uzivatele. Prazdny uzivatel = aktualni uzivatel
procedure FilterClear(OS: TNxCustomObjectSpace; CLSID: string; User_ID: string = '');
begin
  if(User_ID = '')then User_ID:= NxGetActualUserID(OS);
  OS.SQLExecute('DELETE _Filters where CLSID='+QuotedStr(CLSID)+' and [User_ID]='+QuotedStr(User_ID));
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vlozi jedno ID
procedure FilterInsertID(OS: TNxCustomObjectSpace; CLSID, ID: string; User_ID: string = '');
begin
  if(User_ID = '')then User_ID:= NxGetActualUserID(OS);
  OS.SQLExecute('INSERT INTO _Filters VALUES ('+QuotedStr(CLSID)+','+QuotedStr(User_ID)+','+QuotedStr(ID)+')');
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vlozi vice ID
procedure FilterInsertIDs(OS: TNxCustomObjectSpace; CLSID: string; IDs: TStringList; User_ID: string = '');
var
  s: TMemoryStream;
  i: integer;
begin
  s:= TMemoryStream.Create;
  try
    if(User_ID = '')then User_ID:= NxGetActualUserID(OS);

    //tento SQL funguje jen na MSSQL2008
    //INSERT INTO dbo._Filters VALUES ('2', 'x', 'x'),('3', 'x', 'x')

    for i:= 0 to IDs.Count-1 do begin
      if(s.Size > 0)then
        NxWriteString(s,',');
      NxWriteString(s,'('+QuotedStr(CLSID)+','+QuotedStr(User_ID)+','+QuotedStr(IDs.Strings[i])+')');

      //nasekam po velikosti sql dotazu
      if(s.Size > 10000)then begin
        OS.SQLExecute('INSERT INTO _Filters VALUES '+NxReadString(s));
        s.Size:= 0;
      end;
    end;

    if(s.Size > 0)then begin
      OS.SQLExecute('INSERT INTO _Filters VALUES '+NxReadString(s));
    end;
  finally
    s.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//otevreni ciselnikove agendy s vybranejma zaznamama podle filtru uzivatele
procedure ShowRollFormWithFilter(Form: TSiteForm; Sites_CLSID, SiteCaption: string);
var
  mParams: TNxParameters;
begin
  mParams := TNxParameters.Create;
  try
    mParams.NewFromDataType(dtString, '_SiteCaption', pkInput).AsString:= SiteCaption;
    mParams.NewFromDataType(dtBoolean, '_Rolled', pkInput).AsBoolean := False; //otevreni jako velky ciselnik
    mParams.NewFromDataType(dtBoolean, '_InOtherSlot', pkInput).AsBoolean := True;
    mParams.NewFromDataType(dtBoolean, '_WithoutDecision', pkInput).AsBoolean := True;
    mParams.GetOrCreateParam(dtBoolean, '_MultiChoice', pkInput).AsBoolean := False; //DoNotLocalize
    ShowDynForm(Sites_CLSID, Form.SiteContext, mParams, nil, true,
      'FilterByUserDynSQLCondition;'+
      'exists (select ID from _Filters where ID=A.ID AND CLSID='''+Sites_CLSID+''' and User_ID={$ActualUser});'+
      '');
  finally
    mParams.free;
  end;
end;//ShowRollFormWithFilter
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//otevreni adove agendy s vybranejma zaznamama podle filtru uzivatele
procedure ShowDynFormWithFilter(Form: TSiteForm; Sites_CLSID, SiteCaption: string);
var
  mParams: TNxParameters;
  mPar   : TNxParameter;
begin
  mParams := TNxParameters.Create;
  try
    mParams.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := SiteCaption;
    mParams.NewFromDataType(dtString, '_SiteCaption', pkInput).AsString:= SiteCaption;
    ShowDynForm(Sites_CLSID, Form.SiteContext, mParams, nil, true,
      'QueryByUserDynSQLCondition;'+
      'exists (select ID from _Filters where ID=A.ID AND CLSID='''+Sites_CLSID+''' and User_ID={$ActualUser});'+
      SiteCaption);
  finally
    mParams.free;
  end;
end;//ShowFormWithSelected
////////////////////////////////////////////////////////////////////////////////
begin
end.