Procedure CreateDocument(var OS:TNxCustomObjectSpace;var aFirm_ID, aFirmOffice_ID, aDoc_ID, AFileName:string; aRelDef:Integer);
var
 mDocBO, mRelBO, mDocContent:TNxCustomBusinessObject;
 mDocContents:TNxCustomBusinessMonikerCollection;
 mList:TStringList;
 mStrMem:TMemoryStream;
begin
   try
     NxScriptingLog.WriteEvent(logInfo,'začátek dokladu');
          mDocBO:=OS.CreateObject(Class_Document);
          mDocBO.new;
          mDocBO.Prefill;
          mDocBO.SetFieldValueAsString('DocQueue_ID','7100000101');
          mDocBo.SetFieldValueAsString('Category_ID','5000000000');
          mdocBo.SetFieldValueAsString('Firm_ID', aFirm_ID);
          mDocBO.SetFieldValueAsString('Division_ID','1000000101');
          mDocBO.SetFieldValueAsString('FirmOffice_ID',aFirmOffice_ID);
          mDocContents:= mDocBO.GetLoadedCollectionMonikerForFieldCode(mDocBO.GetFieldCode('Contents'));
          mDocContent:= mDocContents.AddNewObject;
          mDocContent.SetFieldValueAsString('FileName',AFileName);
          mDocContent.SetFieldValueAsString('PathAndFileName',AFileName);
          mDocContent.SetFieldValueAsBoolean('ExternalFile', False);
          mStrMem:= TMemoryStream.Create();
          try
            mStrMem.LoadFromFile(aFileName);
            mDocContent.SetFieldValueAsBytes('Data_ID.BlobData', mStrMem.GetBytes);
          finally
            mStrMem.Free;
          end;
          mDocBO.save;
              mRelBO:=OS.CreateObject(Class_Relation);
              mRelBO.New;
              mrelbo.Prefill;
              mRelBO.SetFieldValueAsString('LeftSide_ID',aDoc_ID);
              mrelbo.SetFieldValueAsString('RightSide_ID',mDocBO.OID);
              mrelbo.SetFieldValueAsInteger('Rel_Def',aRelDef);
              mrelbo.save;
              mrelbo.free;
          mDocBO.free;

   except
    NxShowSimpleMessage(ExceptionMessage,nil);
   end;
end;


begin
end.