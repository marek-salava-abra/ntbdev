uses 'eu.abra.imports.ImportFile', 'eu.abra.imports.Progress', 'eu.abra.imports.fce';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Promos z XML';
  mAction.Hint := 'XML';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportXML_OnExecute;

end;

procedure ImportXML_OnExecute(Sender : TComponent);
var
  mSite : TSiteForm;
  mOpenDlg : TOpenDialog;
  mList, mFileList : TStringList;
  mBO : TNxCustomBusinessObject;
  mGRows : TMultiGrid;
  i,j: integer;
  mXMLHead : TNxScriptingXMLWrapper;
  mstrings : TStrings;
  mstring : String;
  mOS:TNxCustomObjectSpace;
  mFile : TstringList;
  mSTream:TMemoryStream;
  mFileName, mStr:String;
  mBytes:TBytes;
begin
  mSite := TComponent(Sender).BusRollSite;
  mOpenDlg := TOpenDialog.Create(Sender);
  mOS:= msite.BaseObjectSpace;
  try
    if mOpenDlg.Execute then begin

      mFileList:=tstringlist.Create;
      mFileList.Add(mOpenDlg.FileName);
      try
         for i:=0 to mFileList.Count-1 do begin

           ImportFile(mfilelist.Strings[i], mOS, mSite);
         end;

      finally
        mList.Free;
      end;
      TBusRollSiteForm(mSite).RefreshData;
      ShowMessage('Import dokončen.');
    end else
      ShowMessage('Import přerušen.');
  finally
    mOpenDlg.Free;
  end;
end;







begin
end.