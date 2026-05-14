procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  i : integer;
begin

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Doplní EAN';
  mAction.Hint := 'Doplní EAN na skladovou kartu na označeném řádk';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @ChangeDiscount;
    //mAction.OnUpdate := @ImportOnUpdate;

    mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Karta';
  mAction.Hint := 'Zobrazí kartu z řádku';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @ShowCard;

end;

Procedure ShowCard(sender:Tcomponent);
var
 mSite:TSiteForm;
 mGRows:TMultiGrid;
 mList:TStringList;
 mBO, mBO2, mUnit,mEAN:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 i,j:integer;
begin
     msite:=TComponent(sender).DynSite;
     mBO:=TDynSiteForm(msite).CurrentObject;
     mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));


     mList:=TStringList.create;
     mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
     if Assigned(mGRows) then mGRows.FillListFromSelectedRows_1(mList,false);
       for i:=0 to mRows.count-1 do begin
          if mList.count=0 then begin
            NxShowSimpleMessage('Není označen žádný řádek.',msite);
            exit;
          end;
          if  true then begin
             for j:=0 to mList.count-1 do begin
            if mRows.BusinessObject[i].OID=mList.Strings[j] then begin
              mSite.ShowSite('W31KWYTC5FDL342M01C0CX3FCC',True,'FilterByUserDynSQLCondition;A.ID='+QuotedStr(mrows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID'))+';Omezení za kartu');
            end;
            end;
          end;
       end;

end;


Procedure ChangeDiscount(sender:Tcomponent);
var
 msite:TSiteForm;
 mGRows:TMultiGrid;
 mList:TStringList;
 mBO, mBO2, mUnit,mEAN:TNxCustomBusinessObject;
 mRowBO:TNxCustomBusinessObject;
 mRows, mUnits, mEans:TNxCustomBusinessMonikerCollection;
 i, j:integer;
 mDiscount:Extended;
 mStockType_ID, mEANString:String;
begin
     msite:=TComponent(sender).DynSite;
     mBO:=TDynSiteForm(msite).CurrentObject;
     mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));


     mList:=TStringList.create;
     mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
     if Assigned(mGRows) then mGRows.FillListFromSelectedRows_1(mList,false);
       for i:=0 to mRows.count-1 do begin
          if mList.count=0 then begin
            NxShowSimpleMessage('Není označen žádný řádek.',msite);
            exit;
          end;
          if  true then begin
           for j:=0 to mList.count-1 do begin
            if mRows.BusinessObject[i].OID=mList.Strings[j] then begin
            mBO2:=mBO.ObjectSpace.CreateObject(Class_StoreCard);
            mbo2.Load(mrows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID'),nil);
            mEANString:=InputBox('Info','Sejměte EAN?','');
            if NxIsItEAN(mEANString) then begin
              mUnits:=mBO2.GetLoadedCollectionMonikerForFieldCode(mBO2.GetFieldCode('StoreUnits'));
              mUnit:=mUnits.BusinessObject[0];
              mEans:=mUnit.GetLoadedCollectionMonikerForFieldCode(mUnit.GetFieldCode('StoreEANs'));
              mEAN:=mEans.AddNewObject;
              mEAN.SetFieldValueAsString('Ean',mEANString);

            end;
           if mBO2.NeedSave then mBO2.Save;
           end;
          end;
          end;
       end;
     if Assigned(mGRows) then mGRows.DataSource.DataSet.Refresh;
end;

begin
end.