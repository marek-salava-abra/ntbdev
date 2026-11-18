procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Smazat cenu pro příjem';
  mAction.Items.Add('Smazat cenu pro příjem');
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @DeleteReceiptPrice;
end;

procedure DeleteReceiptPrice(Sender:TObject);
var
  mBO: TNxCustomBusinessObject;
  mList: TStringList;
  mSite: TSiteForm;
  i: integer;
begin
  try
    mSite:= NxFindSiteForm(TComponent(Sender));
    mList:= TStringList.Create;
    TDynSiteForm(mSite).FillListWithSelectedRows(mList);
    for i:= 0 to mList.Count -1 do begin
      mBO:= mSite.BaseObjectSpace.CreateObject(Class_PLMPieceList);
      try
        mBO.Load(mList[i], nil);
        mBO.SetFieldValueAsFloat('PriceForReceipt', 0);
        mBO.Save;
      finally
        mBO.Free;
      end;
    end;
  finally
    mList.Free;
    TDynSiteForm(mSite).RefreshData;
  end;
end;

begin
end.