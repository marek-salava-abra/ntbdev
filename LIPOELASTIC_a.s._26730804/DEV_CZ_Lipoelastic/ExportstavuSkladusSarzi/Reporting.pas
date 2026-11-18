
procedure Receivedorder_to_Retino(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mContext: TNxContext;
  mIDs: TStrings;
  mDynSourceID, mExportID, mFileName, mSQL, mStatIds: String;
  mCommand: Integer;
  mFTP: TFTP;
begin

  Success := True;
  LogInfoStr := '';
  mContext := NxCreateContext(OS);
  mDynSourceID := '40V53DORW3DL342X01C0CX3FCC';
  //mDynSourceID := '';
  mExportID := 'CTV0000101' ;//'2TM0000101';
  mCommand := 0;
  mFileName := '\\CZVS0006\export\Retino.xml';     //pozor, cesta je vzhledem k autoserveru ;


mSQL:='SELECT A.ID FROM ReceivedOrders A join ReceivedOrders2 RO2 on RO2.Parent_ID=a.ID WHERE (A.DocDate$DATE >= ' +
NxFloatToIBStr(((now())-7)) +
' and A.DocDate$DATE < ' +
NxFloatToIBStr((now())) +
' ) and RO2.BusOrder_ID = ' + quotedstr('1700000101') +
// 'and A.DocQueue_ID = ' + quotedstr('1S00000101') +
' AND (A.IsAvailableForDelivery = ' + quotedstr('A') + ')' ;

  LogInfoStr:= LogInfoStr + 'Dotaz: ' + mSQL;

  try
    mIDs := TStringList.Create;
    OS.SQLSelect(mSQL,mIDs);
        LogInfoStr:= LogInfoStr + 'Počet záznamů ' + inttostr(mids.count);
    if mids.count>0 then begin
//    showmessage(inttostr(mids.count));
        NxExportByIDs(mContext, mIDs, mDynSourceID, mExportID, mCommand, '', mFileName);
        LogInfoStr:= LogInfoStr + 'Export Retino proveden ' ;
    end else begin
        LogInfoStr:= LogInfoStr + 'Export Retino neproveden , nejsou žádné záznamy ' ;
    end;
  finally
    mIDs.Free;

  end;

if TRUE then begin
  mFTP := TFTP.Create;
    try
      // pasivní režim komunikace není třeba explicitně nastavovat, defaultní hodnot je True
      //mFTP.Passive := True;
      // nastavíme přístupové parametry spojení
      mFTP.Host := 'exact.lipoelastic.com';
      mFTP.Username:= 'exact.lipoelastic.com';
      mFTP.Password:= '6VV-Jt2ePUwdegPdvdCy';

      mFTP.Connect;   // otevřeme spojení na FTP server
            try
                 mFTP.Put(mFileName,'Retino.xml');
                 LogInfoStr:= LogInfoStr + 'Export Retino odeslán ' ;
            finally
              // uzavřeme spojení na FTP server
              mFTP.Disconnect;
            end;
    finally
      mFTP.Free;
    end;

  //finally
  //  mIDs.Free;
  end;
end;




procedure Create_report(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mContext: TNxContext;
  mIDs: TStrings;
  mDynSourceID, mExportID, mFileName, mSQL, mStatIds: String;
  mCommand: Integer;
  mFTP: TFTP;
begin

  Success := True;
  LogInfoStr := '';
  mContext := NxCreateContext(OS);
  mDynSourceID := 'I2UV1JU4A5P4REHGEDUNMJL4OG';
  //mDynSourceID := '';
  mExportID := '9TN0000101' ;//'2TM0000101';
  mCommand := 0;
  mFileName := '\\CZVS0006\export\Stav_Skladu.xml';     //pozor, cesta je vzhledem k autoserveru ;

    mStatIds := QuotedStr('1T72000101')+','+QuotedStr('2T72000101')+','+QuotedStr('3T72000101')+','+QuotedStr('4T72000101')+','+QuotedStr('6T72000101')+',';
    mStatIds := mStatIds + QuotedStr('1Z42000101')+','+QuotedStr('2Z42000101')+','+QuotedStr('3Z42000101')+','+QuotedStr('4Z42000101')+',';
    mStatIds := mStatIds + QuotedStr('5Z42000101')+','+QuotedStr('~000000U6E')+','+QuotedStr('PZX4000101')+','+QuotedStr('PZJQ000101')+',';
    mStatIds := mStatIds + QuotedStr('QZYL400101')+','+QuotedStr('~000000U6D')+','+QuotedStr('~000004PHE');


  mSQL:='SELECT SSC.id FROM StoreSubCards SSC left join StoreCards SC on sc.id=ssc.StoreCard_ID WHERE ssc.Store_ID = ' + QuotedStr('1120000101')
  + ' and sc.x_statistika in ('+ mStatIds +')';
  LogInfoStr:= LogInfoStr + 'Dotaz: ' + mSQL;

//  mStatIds := QuotedStr('1T72000101')+','+QuotedStr('2T72000101')+','+QuotedStr('3T72000101')+','+QuotedStr('4T72000101')+','+QuotedStr('6T72000101')+',';
//  mStatIds := mStatIds + QuotedStr('1Z42000101')+','+QuotedStr('2Z42000101')+','+QuotedStr('3Z42000101')+','+QuotedStr('4Z42000101')+',';
//  mStatIds := mStatIds + QuotedStr('5Z42000101')+','+QuotedStr('PZX4000101');
//  mSQL:='SELECT id FROM StoreBatches where storecard_id in (select id from StoreCards where x_statistika in ('+mStatIds+'))' ;

  try
    mIDs := TStringList.Create;
    OS.SQLSelect(mSQL,mIDs);
        LogInfoStr:= LogInfoStr + 'Počet záznamů ' + inttostr(mids.count);

//    showmessage(inttostr(mids.count));
    NxExportByIDs(mContext, mIDs, mDynSourceID, mExportID, mCommand, '', mFileName);
    LogInfoStr:= LogInfoStr + 'Export proveden ' ;
  finally
   // mIDs.Free;

  end;

if TRUE then begin
  mFTP := TFTP.Create;
    try
      // pasivní režim komunikace není třeba explicitně nastavovat, defaultní hodnot je True
      //mFTP.Passive := True;
      // nastavíme přístupové parametry spojení
      mFTP.Host := 'exact.lipoelastic.com';
      mFTP.Username:= 'exact.lipoelastic.com';
      mFTP.Password:= '6VV-Jt2ePUwdegPdvdCy';

      mFTP.Connect;   // otevřeme spojení na FTP server
            try
                 mFTP.Put(mFileName,'Stav_Skladu.xml');
                 LogInfoStr:= LogInfoStr + 'Export odeslán ' ;
            finally
              // uzavřeme spojení na FTP server
              mFTP.Disconnect;
            end;
    finally
  //    mFTP.Free;
    end;

  //finally
  //  mIDs.Free;
  end;
end;




begin
end.