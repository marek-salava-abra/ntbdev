function GetStoreCardInfo(Self: TNxWebServicesHelper;EAN: String):String;
Var
 mStoreCardBO:TNxCustomBusinessObject;
 mStoreCard_ID, mfilename:STring;
 mList, mOutputlist:TStringList;
 mBytes:TBytes;
begin
 Try
     NxScriptingLog.EnterSection('CheckEan ',logInfo);
     mstorecard_id:=scrStoreCard_ID(self.ObjectSpace,EAN);
     if not(NxIsEmptyOID(mStoreCard_ID)) then begin
         mList:=TStringList.Create;
         mOutputlist:=TStringList.create;
         mfilename:='d:\abragen\file.xml';
         NxScriptingLog.WriteEvent(logInfo, 'Před exportem '+EAN);
         mlist.Add(mStoreCard_ID);
         CFxReportManager.ExportByIDs(NxCreateContext(self.ObjectSpace),mList,'OGQQA2C25JDL342N01C0CX3FCC','1Q00000101',0,'',mFilename);
         if FileExists(mFileName) then begin
         mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          mBytes := TEncoding.Unicode.GetBytes(mOutputList.Text);
          Result:=EncodeBase64(mBytes);
          DeleteFile(mfilename);
        end;
        NxScriptingLog.WriteEvent(logInfo, 'Po exportu '+EAN);
     end;
    NxScriptingLog.LeaveSection('CheckEan ',logInfo);
  except result:='ERROR'
 end;


end;



function scrStoreCard_ID(AOS : TNxCustomObjectSpace;AValue : string) : string;
const
  cSQL = 'SELECT sc.id FROM storecards sc left join storeunits su on su.parent_id=sc.id left join storeeans se on se.parent_id=su.id WHERE se.ean like ''%s'' and sc.hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;
begin
end.