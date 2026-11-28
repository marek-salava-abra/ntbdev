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

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Změní typ naskladnění';
  mAction.ShortCut := TextToShortCut('Ctrl+R'); //16450;
  mAction.Hint := 'Typ naskladnění';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @ChangeDiscount;
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
         mNewRowBO.SetFieldValueAsString('X_StockType_ID',mOPRow.GetFieldValueAsString('X_StockType_ID'));
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


Procedure ChangeDiscount(sender:Tcomponent);
var
 msite:TSiteForm;
 mGRows:TMultiGrid;
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 i, j:integer;
 mDiscount:Extended;
 mStockType_ID:String;
begin
     msite:=TComponent(sender).DynSite;
     mBO:=TDynSiteForm(msite).CurrentObject;
     mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
     if  GetStockType(msite,mStockType_ID) then begin

     mList:=TStringList.create;
     mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
     if Assigned(mGRows) then mGRows.FillListFromSelectedRows_1(mList,True);
       for i:=0 to mRows.count-1 do begin
          for j:=0 to mList.count-1 do begin
            if mRows.BusinessObject[i].OID=mList.Strings[j] then mrows.BusinessObject[i].SetFieldValueAsString('X_StockType_ID',mStockType_ID);
          end;
       end;
     if Assigned(mGRows) then mGRows.DataSource.DataSet.Refresh;
end;
end;



Function GetStockType(var ASite : TSiteform; var aStockType_ID : string):Boolean;
var
    mLabel1,mCbCCMaterialComposition: TLabel;
    mEd1, mEd2, mEd3, mEd4, mEd5, mEd6:TEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mCbSupplier: TRollComboEdit;
    mCbCcSupplier: TLabel;
    mCbMaterialComposition: TRollComboEdit;
begin
 if ASite <> nil then begin
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 510;
    mForm.Height:= 180;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Naskladnění';


    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Typ naskladnění:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCbCCMaterialComposition:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCCMaterialComposition.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCbCCMaterialComposition.Left:= 236;
    mCbCCMaterialComposition.Top:= 10;
    mCbCCMaterialComposition.Width:= 255;

    mCbMaterialComposition:= TRollComboEdit.Create(mForm);
    mCbMaterialComposition.Parent:= mForm;

    mCbMaterialComposition.ClassID:= 'G3MACGSTQ0V4LFAZYDNQZPLKAO';
    mCbMaterialComposition.Complete:= True;
    mCbMaterialComposition.Prefilling:= pmNone;
    mCbMaterialComposition.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mCbMaterialComposition.Top:= 10;
    mCbMaterialComposition.Left:= 125;
    mCbMaterialComposition.Width:= 108;
    mCbMaterialComposition.DataText:=aStockType_ID;
    mCbMaterialComposition.ConnectedControl:= mCbCCMaterialComposition;
    mCbMaterialComposition.ConnectedControlField:= 'Name';



    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Další >';
    mButOk.Top := 45;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 45;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
    //aresult:=mresult;
   // if mButCancel.OnC
    if mResult = 1 then

         aStockType_ID:=mCbMaterialComposition.DataText;

        Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;


begin
end.