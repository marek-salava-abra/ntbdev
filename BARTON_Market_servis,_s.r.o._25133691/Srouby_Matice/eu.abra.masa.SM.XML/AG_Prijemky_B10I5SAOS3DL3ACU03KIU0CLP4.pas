uses '.ImportFile', '.fce', '.inputpanel';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'XML';
  mAction.Hint := 'XML';
  mAction.Category := 'tabDetail, tabList';
  mAction.OnExecute := @ImportXML_OnExecute;

end;

procedure ImportXML_OnExecute(Sender : TComponent; Index : integer);
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
  mFirm_ID, mStore_ID, mDivision_ID, mDocQueue_ID, mDescription: String;
begin
  mSite := TComponent(Sender).DynSite;
  mOpenDlg := TOpenDialog.create(nil);
  mOpenDlg.Options:=([ofAllowMultiSelect]);
  mOpenDlg.DefaultExt:='XML';
  mos:=msite.CompanyObjectSpace;
  mFirm_id:=mOS.SQLSelectFirstAsString('Select id from firms where hidden=''N'' and firm_id is null and orgidentnumber=''25133691'' ','');
  mDocQueue_ID:='L000000101';
  mDivision_ID:='1000000101';
  mStore_ID:='1000000101';
  mDescription:='';
  try
    if InputDialog(msite, mFirm_ID, mStore_ID, mDivision_ID, mDocQueue_ID, mDescription) then begin
    if mOpenDlg.Execute then begin
      mList := TStringList.Create;
      mFileList := Tstringlist.Create;

      mFileList.AddStrings (mOpenDlg.files);

      try
         for i:=0 to mFileList.Count-1 do begin

           ImportFile(mfilelist.Strings[i], mOS,mSite,mFirm_ID, mStore_ID, mDivision_ID, mDocQueue_ID, mDescription);

         end;

      finally
        mList.Free;
      end;
      TDynSiteForm(mSite).RefreshData;
      ShowMessage('Import dokončen.');
    end else
      ShowMessage('Import přerušen.');
    end;
  finally
    mOpenDlg.Free;
  end;
end;







begin
end.