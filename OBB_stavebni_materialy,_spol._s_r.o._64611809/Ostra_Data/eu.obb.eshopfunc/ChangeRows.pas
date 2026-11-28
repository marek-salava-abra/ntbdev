


Procedure ChangeDEUS(sender:Tcomponent);
var
 msite:TSiteForm;
 mGRows:TMultiGrid;
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 i, j:integer;
 mDiscount:Extended;
 mStore_ID, mDivision_ID, mBusTransaction_ID:String;
begin
     msite:=TComponent(sender).DynSite;
     mBO:=TDynSiteForm(msite).CurrentObject;
     mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));


     mList:=TStringList.create;
     mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
     if Assigned(mGRows) then mGRows.FillListFromSelectedRows_1(mList,false);
     GetStockType(msite,mStore_ID, mDivision_ID, mBusTransaction_ID);
       //NxShowSimpleMessage('skl '+mStore_ID+#13#10+'str '+mDivision_ID+#13#10+'obch '+mBusTransaction_ID,mSite);
       if NxIsEmptyOID(mStore_ID) or NxIsEmptyOID(mDivision_ID) or NxIsEmptyOID(mBusTransaction_ID) then begin
        NxShowSimpleMessage('Musí být vyplněny všechny 3 hodnoty.',msite);
        exit;
       end;
       for i:=0 to mList.count-1 do begin
          if mList.count=0 then begin
            NxShowSimpleMessage('Není označen žádný řádek.',msite);
            exit;
          end;
          if  true then begin
           for j:=0 to mList.count-1 do begin
            if mRows.BusinessObject[i].OID=mList.Strings[j] then begin
              mrows.BusinessObject[i].SetFieldValueAsString('BusTransaction_ID',mBusTransaction_ID);
              mrows.BusinessObject[i].SetFieldValueAsString('Division_ID',mDivision_ID);
              mrows.BusinessObject[i].SetFieldValueAsString('Store_ID',mStore_ID);
            end;
           end;
          end;
       end;
     if Assigned(mGRows) then mGRows.DataSource.DataSet.Refresh;
end;



Function GetStockType(var ASite : TSiteform; var aStore_ID, aDivision_ID, aBusTransaction_ID : string):Boolean;
var
    mLabel1,mCbccStore, mCBccDivision, mCBccBusTransaction: TLabel;
    mEd1, mEd2, mEd3, mEd4, mEd5, mEd6:TEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mCbSupplier: TRollComboEdit;
    mCbCcSupplier: TLabel;
    mCBStore, mCBDivision, mCBBusTransaction: TRollComboEdit;
begin
 if ASite <> nil then begin
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 510;
    mForm.Height:= 240;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Změní data na označených řádích';


    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Sklad:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCbccStore:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbccStore.Parent:= mForm;
    mCbccStore.Left:= 236;
    mCbccStore.Top:= 10;
    mCbccStore.Width:= 255;

    mCBStore:= TRollComboEdit.Create(mForm);
    mCBStore.Parent:= mForm;
    mCBStore.ClassID:= 'O3ZO2K155FDL3CL100C4RHECN0';
    mCBStore.Complete:= True;
    mCBStore.Prefilling:= pmNone;
    mCBStore.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mCBStore.Top:= 10;
    mCBStore.Left:= 125;
    mCBStore.Width:= 108;
    mCBStore.DataText:=aStore_ID;
    mCBStore.ConnectedControl:= mCbccStore;
    mCBStore.ConnectedControlField:= 'Name';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Středisko:';
    mLabel1.Top := 35;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCBccDivision:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCBccDivision.Parent:= mForm;
    mCBccDivision.Left:= 236;
    mCBccDivision.Top:= 35;
    mCBccDivision.Width:= 255;

    mCBDivision:= TRollComboEdit.Create(mForm);
    mCBDivision.Parent:= mForm;
    mCBDivision.ClassID:= 'OA5JMX4J2FD135CH000ILPWJF4';
    mCBDivision.Complete:= True;
    mCBDivision.Prefilling:= pmNone;
    mCBDivision.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mCBDivision.Top:= 35;
    mCBDivision.Left:= 125;
    mCBDivision.Width:= 108;
    mCBDivision.DataText:=aDivision_ID;
    mCBDivision.ConnectedControl:= mCBccDivision;
    mCBDivision.ConnectedControlField:= 'Name';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Obch. případ:';
    mLabel1.Top := 60;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCBccBusTransaction:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCBccBusTransaction.Parent:= mForm;
    mCBccBusTransaction.Left:= 236;
    mCBccBusTransaction.Top:= 60;
    mCBccBusTransaction.Width:= 255;

    mCBBusTransaction:= TRollComboEdit.Create(mForm);
    mCBBusTransaction.Parent:= mForm;
    mCBBusTransaction.ClassID:= '0BOXHKRF4VD13ACL03KIU0CLP4';
    mCBBusTransaction.Complete:= True;
    mCBBusTransaction.Prefilling:= pmNone;
    mCBBusTransaction.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mCBBusTransaction.Top:= 60;
    mCBBusTransaction.Left:= 125;
    mCBBusTransaction.Width:= 108;
    mCBBusTransaction.DataText:=aBusTransaction_ID;
    mCBBusTransaction.ConnectedControl:= mCBccBusTransaction;
    mCBBusTransaction.ConnectedControlField:= 'Name';



    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 145;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 145;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
    //aresult:=mresult;
   // if mButCancel.OnC
    if mResult = 1 then

         aStore_ID:=mCBStore.DataText;
         aDivision_ID:=mCBDivision.DataText;
         aBusTransaction_ID:=mCBBusTransaction.DataText;

        Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;


begin
end.