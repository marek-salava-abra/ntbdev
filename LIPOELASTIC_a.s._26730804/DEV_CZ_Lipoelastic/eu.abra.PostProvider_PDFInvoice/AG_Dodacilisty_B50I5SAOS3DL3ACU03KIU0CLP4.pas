uses 'eu.abra.PostProvider_PDFInvoice.ulib';


procedure InitSite_Hook(Self: TSiteForm);
var
  mAct: TMultiAction;
begin

  mAct:= Self.GetNewMultiAction;
  mAct.ShowControl := True;
  mAct.ShowMenuItem := True;
  mAct.Category:= 'tabList';
  mAct.Caption:= 'Faktura Base64';
  mAct.Items.Add('jedna');
  mAct.Hint:= 'Report';
  mAct.OnExecuteItem:= @actItemExec;

end;

//Varianta volání více metod
procedure _actItemExec(Sender: TAction; Index: Integer);
begin
  case Index of
    0: actItemExec(Sender,0);
  end;
end;




procedure actItemExec(Sender: TAction; Index: Integer);
var mBO:TNxCustomBusinessObject;
    mList,mLogInfoStr:TStringList;
    i,j,k:Integer;
    mSQL:String;

    mSite:TDynSiteForm;
    mOS:TNxCustomObjectSpace;

    mRow,mRow2:TNxCustomBusinessObject;
    mMon,mMon2:TNxCustomBusinessMonikerCollection;
    mID :String;
begin
  mSite := TDynSiteForm(Sender.Site);
  mOS := mSite.BaseObjectSpace;

  try
    mList := TStringList.Create;
    mLogInfoStr := TStringList.Create;
    mSite.FillListWithSelectedRows(mList);

    try
      //práce s objektem
      for i:= 0 to mList.Count -1 do
      begin
        mID := GetIssuedInvoiceFromPDMDocumentID(mOS, '21', mList[i]);
        mSite.ShowEditorSite( ReportToBase64(mOS ,'03' ,mID ),true);
      end;

    except
      mLogInfoStr.add('Nastala chyba ve funkci (actItemExecBatch). ' + ExceptionMessage);
    end;
  finally
    mList.Free;
    if mLogInfoStr.Count > 0 then
      ShowMessage(mLogInfoStr.text);
    mLogInfoStr.free;
  end;
end;


begin
end.