procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  i : integer;
begin


  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Související zboží';
  mAction.ShortCut := TextToShortCut('Ctrl+Q'); //16450;
  mAction.Hint := 'Naplní řádky';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @FillRows;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Smazat řádky s 0';
  mAction.ShortCut := TextToShortCut('Ctrl+W'); //16450;
  mAction.Hint := 'Smaže nulové řádky';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @DeleteRows;
    //mAction.OnUpdate := @ImportOnUpdate;

end;

procedure FillRows(Sender:TComponent);
var
 mSite:TSiteForm;
 mCurrentBO, mNewRowBO, mOPRow:TNxCustomBusinessObject;
 mList, mList2:TStringList;
 mGRows:TMultiGrid;
 mSQL:String;
 mOS:TNxCustomObjectSpace;
 i:Integer;
 mRows:TNxCustomBusinessMonikerCollection;
 mO: TNxHeaderBusinessObject;
  mORow: TNxRowBusinessObject;
  mOSC: TNxCustomBusinessObject;
  mPOSIndex: integer;
  ss, ss2: TStringList;
  s, mSCName: String;
begin
  mSite:=TComponent(Sender).DynSite;
  mCurrentBO:=TDynSiteForm(mSite).CurrentObject;
  mOS:=mCurrentBO.ObjectSpace;
  //if osNew in mCurrentBO.State then begin
  if true then begin
     mList:=TStringList.create;
     mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
     if Assigned(mGRows) then mOPRow:=TNxRowsObjectDataSet(mGRows.DataSource.DataSet).CurrentObject;
     //NxShowSimpleMessage(mOPRow.GetFieldValueAsString('StoreCard_ID.Name'),mSite);
     mSQL:='Select X_replacement_ID from defrolldata where clsid=''E0AU5EE55XVOTDWIIOPHAZPUFC'' and hidden=''N'' and X_StoreCard_ID=''%s'' ';


     mOS.SQLSelect(format(mSQL,[mOPRow.GetFieldValueAsString('StoreCard_ID')]),mList);
     if mList.count>0 then begin
        mRows:=mCurrentBO.GetCollectionMonikerForFieldCode(mCurrentBO.GetFieldCode('Rows'));
        //mList.sort;
       for i:=0 to mList.Count-1 do begin
         mNewRowBO:=mRows.AddNewObject;
         mNewRowBO.SetFieldValueAsInteger('RowType',3);
         mNewRowBO.SetFieldValueAsString('Store_ID', mOPRow.GetFieldValueAsString('Store_ID'));
         mNewRowBO.SetFieldValueAsString('StoreCard_ID',mList.Strings[i]);
         mNewRowBO.SetFieldValueAsString('Division_ID',mOPRow.GetFieldValueAsString('Division_ID'));
         mNewRowBO.SetFieldValueAsString('BusTransaction_ID',mOPRow.GetFieldValueAsString('BusTransaction_ID'));
         mNewRowBO.SetFieldValueAsFloat('Quantity',0);

       end;
     end;

     mlist.Free;
     if Assigned(mGRows) then mGRows.DataSource.DataSet.Refresh;
  end;
end;

Procedure DeleteRows(Sender:TComponent);
var
 mSite:TSiteForm;
 mCurrentBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mGRows:TMultiGrid;
 i:Integer;
begin
   mSite:=TComponent(Sender).DynSite;
   mCurrentBO:=TDynSiteForm(mSite).CurrentObject;
    if osNew in mCurrentBO.State then begin
      mRows:=mCurrentBO.GetLoadedCollectionMonikerForFieldCode(mCurrentBO.GetFieldCode('Rows'));
      for i:=0 to mrows.Count-1 do begin
         if mRows.BusinessObject[i].GetFieldValueAsFloat('Quantity')=0 then mRows.BusinessObject[i].MarkForDelete;
      end;
    end;
    mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
     if Assigned(mGRows) then mGRows.DataSource.DataSet.Refresh;
end;

Procedure ShowRows(Sender:Tcomponent);
var
 mSite:TSiteForm;
 mSelPar, mPars:TNxParameters;
begin
  mSite:=TComponent(Sender).DynSite;
   msite.ShowSite('T2FWDKF0NSSOBC2KLELLUBPBXW', True,
   'QueryByUserDynsqlCondition;a.quantity>a.deliveredquantity and A.parent_ID='+QuotedStr(TDynSiteForm(mSite).CurrentObject.OID));

end;

begin
end.