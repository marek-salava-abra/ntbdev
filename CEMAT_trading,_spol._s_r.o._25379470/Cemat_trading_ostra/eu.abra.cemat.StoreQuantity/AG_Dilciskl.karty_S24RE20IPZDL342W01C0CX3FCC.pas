uses 'eu.abra.cemat.StoreQuantity.fce';


procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;

  mUser : TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

mBut:= Self.GetNewAction;
mBut.ShowControl := True;
mBut.ShowMenuItem := True;
mBut.Caption := 'Import stavu';
mBut.Category := 'tabList';
mBut.OnExecute := @ImportTXT_OnExecute;


end;


procedure ImportTXT_OnExecute(Sender : TComponent);
var
  mSite : TSiteForm;
  mOpenDlg : TOpenDialog;
  mList : TStringList;
  mBO : TNxCustomBusinessObject;
  mGRows : TMultiGrid;
  mOS: TNxCustomObjectSpace;
  i :Integer;
  mStore_ID, mStoreCardCode, mStoreCard_ID:string;
  mQuantity:Extended;
begin
  mSite := NxFindSiteForm(TComponent(Sender));
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      mList := TStringLIst.Create;
      try
        mList.LoadFromFile(mOpenDlg.FileName);
        //Import_AddRows(ARows : TNxCustomBusinessMonikerCollection; AList : TStringList; ADivision_ID : string; AStore_ID : string)
        mBO := TDynSiteForm(mSite).CurrentObject;
          mos:= TDynSiteForm(mSite).SiteContext.GetObjectSpace;
          for i:= 0 to mlist.Count-1 do begin
          mStore_ID:=scrGetStore_ID(mOS,'Code',NxToken(mlist.Strings[i],';'));
          mStoreCardCode:=(NxToken(mlist.Strings[i],';'));
          mQuantity:= StrToFloat(NxToken(mlist.Strings[i],';'));
          updatequantity(mOS,mQuantity, mStoreCardCode,mStore_ID);
          end;
        // po přidání řádku provedu refresh

      finally
        mList.Free;
      end;
      ShowMessage('Import dokončen.');
    end else
      ShowMessage('Import přerušen.');
  finally
    mOpenDlg.Free;
  end;
end;


begin
end.