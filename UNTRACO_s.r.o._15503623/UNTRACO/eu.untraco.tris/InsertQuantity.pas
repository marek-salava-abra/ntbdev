procedure  Quantity (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mConnection:TSQLConnection;
 mDataSet: TSQLDataset;
 mList, mLog:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
 mMessage, mSQL:string;
begin
  mList:=TStringList.Create;
  mLog:=TStringList.Create;
  OS.SqlSelect('Select ssc.id from storesubcards ssc left join storecards sc on sc.id=ssc.storecard_id where sc.hidden=''N'' ',mList);
   Try
    mConnection := TSQLConnection.Create;
    mConnection.Driver := dbMSSQL;
    mConnection.Params :=
      'SERVER NAME=ABRA'#13#10 +
      'USER NAME=Trisuser'#13#10 +
      'PASSWORD=tr'#13#10 +
      'DATABASE=TRIS';
    try
      mConnection.Connect;
      mConnection.StartTransaction;
      try
        mDataSet := mConnection.NewDataset;
        mDataSet.SQL := 'delete from dbo.ABRA_MasterBalance';
        mDataSet.ExecSQL;
        //mConnection.Commit;
        for i:=0 to mlist.Count-1 do begin
        mBO:= os.CreateObject(Class_StoreSubCard);
        mBO.Load(mlist.Strings[i],nil);
         mSQL:='INSERT INTO dbo.ABRA_MasterBalance (Artikl, Popis,Sklad, Pocet, MJ) ' +
                                 'VALUES('+QuotedStr(AnsiLeftStr(mbo.GetFieldValueAsString('StoreCard_ID.Code'),25))+', '+
                                 Quotedstr(AnsiLeftStr(mbo.GetFieldValueAsString('StoreCard_ID.Name'),40))+', '+
                                 Quotedstr(mbo.GetFieldValueAsString('Store_ID.Code'))+', '+
                                 FloatToStr(mbo.GetFieldValueAsFloat('Quantity')/mBO.GetFieldValueAsFloat('StoreCard_ID.MainUnitRate'))+', '+
                                 QuotedStr(mBO.GetFieldValueAsString('StoreCard_ID.MainUnitCode'))+')';
         mLog.Add(mSQL);
         mDataSet.SQL := mSQL;

         mdataset.ExecSQL;
         mbo.free
         end;

      Except
        mMessage:=mMessage+#13#10+'ExecSQL:'+#13#10+ExceptionMessage;
      end;

    mConnection.Commit;
    except
     mMessage:=mMessage+#13#10+'Commit:'+#13#10+ExceptionMessage;
    end;
  finally

  end;
  CFxLog.SaveLog(NxCreateContext(OS),'LS','Insert Quantity',mLog.Text,2,now);
  Success := True;
  LogInfoStr := ''+mMessage;
end;

begin
end.