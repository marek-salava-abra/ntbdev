uses '.fce';

procedure PrintIssuedOrderMovements(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mLogs, mPMList, mPrintList:TStringList;
 mReport_ID, mHorizontalSplitter, mSQLPM, mSQLOV:string;
 i,j,k:integer;
 mBO:TNxCustomBusinessObject;
begin
  mReport_ID:='I700000001';
  mSQLPM:='SELECT  distinct(A.x_ProductM) FROM '#13#10 +
          '  StoreCards A'#13#10 +
          'WHERE A.x_productM is not null and (A.Hidden = ''N'' ) AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000034 AND CLSID=''C3V5QDVZ5BDL342M01C0CX3FCC'' AND ID = A.ID AND (  ( STRINGFIELDVALUE = ''1''  OR STRINGFIELDVALUE = ''2''  OR STRINGFIELDVALUE = ''3'' ) '#13#10 +
          ')))';
  mPMList:=TStringList.Create;
  mLogs:=TStringList.Create;
  mHorizontalSplitter:=GetHorizontalSplitter(50);
  mLogs.Add(mHorizontalSplitter);
  mLogs.add(DateTimeToStr(Now)+' Začátek');
  mLogs.Add(mHorizontalSplitter);
  OS.SQLSelect(mSQLPM, mPMList);
  if mPMList.count>0 then begin
    for i:=0 to mPMList.count-1 do begin

     if not(NxIsEmptyOID(mPMList.Strings[i])) then begin
        mBO:=OS.CreateObject(Class_UserRollBusinessObject_TFFZQGYK1VYO3FIZAYJOKAAN5S);
        mBO.Load(mPMList.Strings[i],nil);
        mLogs.Add(DateTimeToStr(now)+' '+mBO.DisplayName+' cílový email: '+mbo.GetFieldValueAsString('U_ProductManEmail'));
        mSQLOV:=    'SELECT'#13#10 +
                    '  B.ID'#13#10 +
                    'FROM'#13#10 +
                    '  IssuedOrders2 B'#13#10 +
                    '  JOIN IssuedOrders C ON C.id = B.Parent_ID'#13#10 +
                    'WHERE'#13#10 +
                    '  C.docdate$date >= '+NxFloatToIBStr(date-7)+' AND EXISTS (SELECT 1 FROM StoreCards A WHERE A.ID = B.StoreCard_ID AND A.x_productM = '+QuotedStr(mBO.OID)+' ' +
                    'AND A.Hidden = ''N'' AND '#13#10 +
                    '  EXISTS (SELECT 1 FROM USERDATA WHERE FIELDCODE = 2000034 AND CLSID = ''C3V5QDVZ5BDL342M01C0CX3FCC'' AND ID = A.ID AND ('#13#10 +
                    '          STRINGFIELDVALUE = ''1'' OR STRINGFIELDVALUE = ''2'' OR STRINGFIELDVALUE = ''3'')))';
        mPrintList:=TStringList.Create;
        OS.SQLSelect(mSQLOV, mPrintList);
        mLogs.add(DateTimeToStr(now)+' Počet pohybů: '+IntToStr(mPrintList.count));
        if mPrintList.Count>0 then begin
          CFxReportManager.PrintByIDs(NxCreateContext(OS),mPrintList,GetDynSource(OS, mReport_ID),mReport_ID,rtoFile,pekPDF,NxGetTempDir,'objednavky.pdf');

          SendInternalMail(OS, mbo.GetFieldValueAsString('U_ProductManEmail'),'','',
                         'Blbé pohyby','tělo blbých pohybů ',
                         NxGetTempDir+'\objednavky.pdf','','4100000101','');
          deletefile(NxGetTempDir+'\objednavky.pdf');
        end;
     end;
    end;
  end;
  mLogs.Add(mHorizontalSplitter);
  mLogs.add(DateTimeToStr(Now)+' Konec');
  mLogs.Add(mHorizontalSplitter);
  Success := True;
  LogInfoStr := ''+NxCrlF+mLogs.Text;
end;

procedure HideNotConfirmedAndNotOrderdSC(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mLogs:TStringList;
 i:integer;
 mSQL, mHorizontalSplitter,mOrder_ID:string;
 mBO:TNxCustomBusinessObject;
 mCreatedDate:Extended;
begin
  mList:=TStringList.Create;
  mLogs:=TStringList.Create;
  mHorizontalSplitter:=GetHorizontalSplitter(50);
  mCreatedDate:=GetWorkingDaysAgo(Date,3,OS);
  mSQL:='SELECT a.id FROM StoreCards A WHERE (A.Hidden = ''N'' ) AND (A.AuthorizedAt$DATE = 0) and A.CreatedAt$Date<'+NxFloatToIBStr(mCreatedDate)+
        ' AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000039 AND CLSID=''C3V5QDVZ5BDL342M01C0CX3FCC'' AND ID = A.ID AND ((STRINGFIELDVALUE = ''2'')))) ';
  OS.SQLSelect(mSQL,mList);
  mLogs.Add(mHorizontalSplitter);
  mLogs.add(DateTimeToStr(Now)+' Začátek');
  mLogs.Add(mHorizontalSplitter);
  //mlogs.add(mSQL);
  mLogs.Add(DateTimeToStr(Now)+' Rozhodné datum vytvoření pro neschválené karty '+DateToStr(mCreatedDate));
  if mList.count>0 then begin
    mLogs.Add(DateTimeToStr(Now)+' Počet karet celkem: '+IntToStr(mList.count));
    mBO:=OS.CreateObject(Class_StoreCard);
    for i:=0 to mList.count-1 do begin
       mBO.Load(mList.Strings[i],nil);
       mLogs.add(DateTimeToStr(Now)+' '+mBO.DisplayName);
       mBO.SetFieldValueAsBoolean('Hidden',true);
       mBo.Save;
    end;
    mBO.free
  end else mLogs.Add(DateTimeToStr(Now)+' Nebyl nalezen žádný záznam');
  mLogs.Add(mHorizontalSplitter);
  mLogs.add(DateTimeToStr(Now)+' Konec');
  mLogs.Add(mHorizontalSplitter);
  Success := True;
  LogInfoStr := ''+NxCrLF+mLogs.Text;
end;

procedure CheckNotConfirmedSCFromOrders(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mLogs:TStringList;
 i:integer;
 mSQL, mHorizontalSplitter,mOrder_ID:string;
 mBO:TNxCustomBusinessObject;
begin
  mList:=TStringList.Create;
  mLogs:=TStringList.Create;
  mHorizontalSplitter:=GetHorizontalSplitter(50);
  mSQL:='SELECT a.id FROM StoreCards A WHERE (A.Hidden = ''N'' ) AND (A.AuthorizedAt$DATE = 0) ';
  OS.SQLSelect(mSQL,mList);
  mLogs.Add(mHorizontalSplitter);
  mLogs.add(DateTimeToStr(Now)+' Začátek');
  mLogs.Add(mHorizontalSplitter);
  if mList.count>0 then begin
    mBO:=OS.CreateObject(Class_StoreCard);
    for i:=0 to mList.count-1 do begin
       mBO.Load(mList.Strings[i],nil);
       mLogs.add(DateTimeToStr(Now)+' '+mBO.DisplayName);
       mOrder_ID:=OS.SQLSelectFirstAsString('SELECT  distinct(B.ID) FROM ReceivedOrders2 B JOIN ReceivedOrders C ON C.id = B.Parent_ID'#13#10 +
                                            'WHERE'#13#10 +
                                            '  ('#13#10 +
                                            '    ((''A'' = ''A'') AND ((C.IsAvailableForDelivery = ''A'') AND (C.Closed = ''N'')))'#13#10 +
                                            '    OR'#13#10 +
                                            '    ((''A'' = ''N'') AND ((C.IsAvailableForDelivery = ''N'') OR (C.Closed = ''A'')))'#13#10 +
                                            '  )'#13#10 +
                                            '  AND ('#13#10 +
                                            '    (''N'' = ''A'')'#13#10 +
                                            '    OR'#13#10 +
                                            '    ((''N'' = ''N'') AND (C.Revided_ID IS NULL))'#13#10 +
                                            '  )'#13#10 +
                                            '  AND B.StoreCard_ID='+QuotedStr(mBO.OID),'');
      if NxIsEmptyOID(mOrder_ID) then begin
        mLogs.add(DateTimeToStr(Now)+' Nemá objednávku');
        mBO.SetFieldValueAsInteger('U_ReceivedOrderExists',2);
      end else begin
        mLogs.add(DateTimeToStr(Now)+' Má objednávku');
        mBO.SetFieldValueAsInteger('U_ReceivedOrderExists',1);
      end;
      mBo.Save;
    end;
    mBO.free
  end;
  mLogs.Add(mHorizontalSplitter);
  mLogs.add(DateTimeToStr(Now)+' Konec');
  mLogs.Add(mHorizontalSplitter);
  Success := True;
  LogInfoStr := ''+NxCrLF+mLogs.Text;
end;

procedure DeleteProposedExCode(OS: TNxCustomObjectSpace;var Success: Boolean; var LogInfoStr: String);
var
 mList, mLogs:TStringList;
 i:integer;
 mSQL, mHorizontalSplitter:string;
 mBO:TNxCustomBusinessObject;
 mQuantity, mReservedQuantity, mIssuedOrderQuantity:Extended;
begin
  mList:=TStringList.Create;
  mLogs:=TStringList.Create;
  mHorizontalSplitter:=GetHorizontalSplitter(50);
  mSQL:='SELECT a.ID FROM '#13#10 +
        '  StoreCards A'#13#10 +
        '   '#13#10 +
        'WHERE A.AuthorizedAt$Date>='+NxFloatToIBStr(date-7)+
        ' AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000040 AND CLSID=''C3V5QDVZ5BDL342M01C0CX3FCC'' AND ID = A.ID AND (STRINGFIELDVALUE LIKE N''%'' ESCAPE ''~'')))';
  mLogs.Add(mHorizontalSplitter);
  mLogs.add(DateTimeToStr(Now)+' Začátek');
  mLogs.Add(mHorizontalSplitter);
  mLogs.add(mSQL);
  mLogs.Add(mHorizontalSplitter);
  OS.SQLSelect(mSQL,mList);
  if mList.count>0 then begin
    mLogs.Add(DateTimeToStr(Now)+' Počet karet: '+IntToStr(mlist.Count));
    mBO:=OS.CreateObject(Class_storecard);
    for i:=0 to mlist.count-1 do begin
      mBO.Load(mlist.Strings[i],nil);
      mBO.SetFieldValueAsString('U_ProposedExCode','');
      mLogs.Add(DateTimeToStr(now)+' Karta: '+mBO.DisplayName);
      mLogs.Add(GetHorizontalSplitter(30));
      mBO.Save;
    end;
    mBO.free;
  end else mLogs.Add(DateTimeToStr(Now)+' Nebyl nalezen žádný záznam');
  mLogs.Add(mHorizontalSplitter);
  mLogs.add(DateTimeToStr(Now)+' Konec');
  mLogs.Add(mHorizontalSplitter);
  Success := True;
  LogInfoStr := ''+NxCrLf+mLogs.text;
end;

procedure SetHidden(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mLogs:TStringList;
 i:integer;
 mSQL, mHorizontalSplitter:string;
 mBO:TNxCustomBusinessObject;
 mQuantity, mReservedQuantity, mIssuedOrderQuantity:Extended;
begin
  mList:=TStringList.Create;
  mLogs:=TStringList.Create;
  mHorizontalSplitter:=GetHorizontalSplitter(50);
  mSQL:='SELECT a.ID FROM '#13#10 +
        '  StoreCards A'#13#10 +
        '   '#13#10 +
        'WHERE (A.Hidden = ''N'' ) And A.AuthorizedAt$DATE>0 AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000034 AND CLSID=''C3V5QDVZ5BDL342M01C0CX3FCC'' AND ID = A.ID AND (( ' +
        'STRINGFIELDVALUE = ''1'' ) '#13#10 +
        ')))';
  mLogs.Add(mHorizontalSplitter);
  mLogs.add(DateTimeToStr(Now)+' Začátek');
  mLogs.Add(mHorizontalSplitter);
  OS.SQLSelect(mSQL,mList);
  if mList.count>0 then begin
    mLogs.Add(DateTimeToStr(Now)+' Počet karet: '+IntToStr(mlist.Count));
    mBO:=OS.CreateObject(Class_storecard);
    for i:=0 to mlist.count-1 do begin
      mBO.Load(mlist.Strings[i],nil);
      mQuantity:=OS.SQLSelectFirstAsExtended('Select sum(quantity) from storesubcards where storecard_ID='+QuotedStr(mBO.OID),0);
      mReservedQuantity:=NxEvalObjectExprAsFloatDef(mBO,'NxGetReservedQuantity('+QuotedStr(mBO.OID)+')',0);
      mIssuedOrderQuantity:=OS.SQLSelectFirstAsExtended('SELECT sum(A.Quantity-A.DeliveredQuantity)'#13#10 +
                                      'FROM'#13#10 +
                                      '  IssuedOrders2 A  '#13#10 +
                                      '  JOIN issuedorders IO ON IO.id = A.parent_id'#13#10 +
                                      'WHERE'#13#10 +
                                      '  1=1'#13#10 +
                                      'AND ((IO.DocDate$DATE >= '+NxFloatToIBStr(date-30)+') AND (IO.closed = ''N'' ) AND ( (  A.DeliveredQuantity = 0  OR  (A.DeliveredQuantity < A.Quantity' +
                                      ' AND A.DeliveredQuantity > 0) ) '#13#10 +
                                      ') AND ((''N'' = ''A'') OR ((''N'' = ''N'') AND (A.Revided_ID IS NULL)) )) and a.StoreCard_ID='+QuotedStr(mBO.OID),0);
      mLogs.Add(DateTimeToStr(now)+' Karta: '+mBO.DisplayName);
      mLogs.Add(DateTimeToStr(now)+' Stav na skladech: '+NxFloatToIBStr(mQuantity));
      mLogs.Add(DateTimeToStr(now)+' Rezervace: '+NxFloatToIBStr(mReservedQuantity));
      mLogs.Add(DateTimeToStr(now)+' Množství na OV: '+NxFloatToIBStr(mIssuedOrderQuantity));
      if (mQuantity=0) and (mReservedQuantity=0) and (mIssuedOrderQuantity=0) then begin
       mLogs.Add(DateTimeToStr(now)+' Podmínka splněna');
       mbo.SetFieldValueAsBoolean('Hidden',true);
       mbo.save;
      end else mLogs.Add(DateTimeToStr(now)+' Podmínka nesplněna');
      mLogs.Add(GetHorizontalSplitter(30));
    end;
    mBO.free;
  end else mLogs.Add(DateTimeToStr(Now)+' Nebyl nalezen žádný záznam');
  mLogs.Add(mHorizontalSplitter);
  mLogs.add(DateTimeToStr(Now)+' Konec');
  mLogs.Add(mHorizontalSplitter);
  Success := True;
  LogInfoStr := ''+NxCrLf+mLogs.text;
end;

procedure SCOnStoreFor1YearAndNoMovement(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mLogs:TStringList;
 i:integer;
 mSQL, mHorizontalSplitter,mOrder_ID:string;
 mBO:TNxCustomBusinessObject;
begin
  mList:=TStringList.Create;
  mLogs:=TStringList.Create;
  mHorizontalSplitter:=GetHorizontalSplitter(50);
  mSQL:='SELECT a.id FROM StoreSubcards A WHERE (A.X_NoMoveFor1Year = ''A'')';
  OS.SQLSelect(mSQL,mList);
  mLogs.Add(mHorizontalSplitter);
  mLogs.add(DateTimeToStr(Now)+' Začátek');
  mLogs.Add(mHorizontalSplitter);
  mLogs.Add(DateTimeToStr(now)+' Počet karet kde budu odebírat příznak: '+IntToStr(mlist.count));
  if mList.count>0 then begin
    mBO:=OS.CreateObject(Class_StoreSubCard);
    for i:=0 to mList.count-1 do begin
       mBO.Load(mList.Strings[i],nil);
       mBO.SetFieldValueAsBoolean('X_NoMoveFor1Year',False);
       mBO.save;
    end;
    mBO.free;
  end;
  mList.Clear;
  mSQL:='SELECT s.ID '#13#10 +
        'FROM StoreSubCards s '#13#10 +
        'WHERE s.Quantity > 0 '#13#10 +
        '  AND NOT EXISTS ('#13#10 +
        '      SELECT 1 '#13#10 +
        '      FROM StoreDocuments2 d2'#13#10 +
        '      INNER JOIN StoreDocuments d ON d.ID = d2.Parent_ID'#13#10 +
        '      WHERE d2.StoreCard_ID = s.StoreCard_ID'#13#10 +
        '        AND d2.Store_ID = s.Store_ID'#13#10 +
        '        AND d.DocumentType = ''21'' '#13#10 +
        '        AND d.DocDate$Date >= DATEADD(year, -1, GETDATE())'#13#10 +
        '  )'#13#10 +
        '  AND NOT EXISTS ('#13#10 +
        '      SELECT 1 '#13#10 +
        '      FROM StoreDocuments2 d2'#13#10 +
        '      INNER JOIN StoreDocuments d ON d.ID = d2.Parent_ID'#13#10 +
        '      WHERE d2.StoreCard_ID = s.StoreCard_ID'#13#10 +
        '        AND d2.Store_ID = s.Store_ID'#13#10 +
        '        AND d2.FlowSign = 1'#13#10 +
        '        AND d.DocDate$Date >= DATEADD(day, -180, GETDATE())'#13#10 +
        '  )';
  OS.SQLSelect(mSQL,mList);
  mLogs.Add(DateTimeToStr(now)+' Počet karet kde budu nastavovat příznak: '+IntToStr(mlist.count));
  if mList.count>0 then begin
    mBO:=OS.CreateObject(Class_StoreSubCard);
    for i:=0 to mList.count-1 do begin
       mBO.Load(mList.Strings[i],nil);
       mBO.SetFieldValueAsBoolean('X_NoMoveFor1Year',True);
       mLogs.Add(DateTimeToStr(now)+' '+mbo.DisplayName);
       mBO.save;
    end;
    mBO.free;
  end;
  mLogs.Add(mHorizontalSplitter);
  mLogs.add(DateTimeToStr(Now)+' Konec');
  mLogs.Add(mHorizontalSplitter);
  Success := True;
  LogInfoStr := ''+NxCrLF+mLogs.Text;
end;

begin
end.