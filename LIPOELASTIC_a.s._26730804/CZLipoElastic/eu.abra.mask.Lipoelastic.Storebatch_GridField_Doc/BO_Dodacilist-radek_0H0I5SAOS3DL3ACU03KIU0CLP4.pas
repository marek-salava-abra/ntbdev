uses 'EU.Aabra.Mask.Validace.lib';
{procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);

var
  mCode: integer;
  i:integer;
  mBO_Moniker : TNxCustomBusinessMonikerCollection;
  mr1:TStringList;
        mBO_Storeunit:TNxCustomBusinessObject;
        pocet:Double;
begin
  if AFieldCode = Self.GetFieldCode('Storecard_ID') then begin
    if AOriginalValue.AsString <> AValue.AsString then begin
       Self.SetFieldValueAsString('X_StoreBatch_ID', '0000000000');
    end else begin

    end;
    exit;
  end;
  if AFieldCode = Self.GetFieldCode('X_StoreBatch_ID') then begin
    if  (not NxIsEmptyOID(Self.GetFieldValueAsString('X_StoreBatch_ID'))) then begin
        if AOriginalValue.AsString<> AValue.AsString then begin
                mr1:= TStringList.Create;
                Try
                        self.ObjectSpace.SQLSelect(format('SELECT id FROM StoreUnits WHERE (parent_ID=''%s'') and (Description=''%S'')',
                        [self.GetFieldValueAsString('Storecard_ID'),Self.GetMonikerForFieldCode(Self.GetFieldCode('X_StoreBatch_ID')).BusinessObject.GetFieldValueAsString('Name')]),mr1);
                       if mr1.Count=0 then begin
                                ShowMessage('Skladová jednotka pro šarži nenalezena, prosím opravte');
                                self.SetFieldValueAsString('QUnit','');
                        end else begin
                                mBO_Storeunit:=self.ObjectSpace.CreateObject('G2WVAN4GFNDL342T01C0CX3FCC');
                                Try
                                        mBO_Storeunit.Load(mr1.Strings[0],nil);
                                         pocet:=0;

                                        pocet:=(self.getFieldValueAsFloat('Quantity')* self.getFieldValueAsFloat('UnitRate'))/mBO_Storeunit.GetFieldValueAsFloat('UnitRate') ;
                                        //self.SetFieldValueAsFloat('Quantity',pocet);
                                        //self.SetFieldValueAsString('QUnit',mBO_Storeunit.GetFieldValueAsString('Code'));
                                        mBO_Moniker:=Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('DocRowBatches'));
                                        if mBO_Moniker.Count=1 then begin
                                                for i := 0 to mBO_Moniker.Count - 1 do begin
                                                        mBO_Moniker.BusinessObject[i].setFieldValueAsstring('StoreBatch_ID',AValue.AsString);
                                                        mBO_Moniker.BusinessObject[i].SetFieldValueAsFloat('Quantity',self.getFieldValueAsFloat('Quantity'));
                                                        mBO_Moniker.BusinessObject[i].setFieldValueAsstring('QUnit',self.getFieldValueAsString('QUnit'));
                                                        mBO_Moniker.BusinessObject[i].SetFieldValueAsFloat('Unitrate',self.GetFieldValueAsFloat('unitrate'));
                                                        // ShowMessage(mBO_Moniker.BusinessObject[i].getFieldValueAsstring('NewBatchName'));
                                                end ;
                                        end else begin
                                                        mBO_Moniker.AddNewObject;
                                                        mBO_Moniker.BusinessObject[i].Prefill;

                                                        mBO_Moniker.BusinessObject[i].SetFieldValueAsstring('Parent_ID',self.getFieldValueAsstring('ID'));
                                                        mBO_Moniker.BusinessObject[i].SetFieldValueAsFloat('Quantity',self.getFieldValueAsFloat('Quantity'));
                                                        mBO_Moniker.BusinessObject[i].setFieldValueAsstring('QUnit',self.getFieldValueAsString('QUnit'));
                                                        mBO_Moniker.BusinessObject[i].SetFieldValueAsFloat('Unitrate',self.GetFieldValueAsFloat('unitrate'));
                                                        mBO_Moniker.BusinessObject[i].setFieldValueAsstring('StoreBatch_ID',AValue.AsString);

                                        end  ;

                                        //mBO_Moniker.Save(i);

                                        //mBO_Moniker.SaveAll;
        mBO_Moniker.Free;

                                finally
                                mBO_Storeunit.free;
                                end;


                        end;
                finally
                        mr1.free;
                end;
        end;
     end;
  end;

end;


// filtrování šarží podle skladové karty
procedure CompleteRollValidateParams_hook(Self: TNxCustomBusinessObject; AFieldCode: integer; AParams: TNxParameters);
begin
        if self.GetFieldValueAsInteger('Rowtype')=3 then begin
                if NxIsEmptyOID(self.GetFieldValueAsString('Storecard_ID')) then begin
                                        AParams.NewFromDataType(dtString, 'FilterStoreBatch').AsString := '';
                end else begin
                        if AFieldCode = Self.GetFieldCode('X_StoreBatch_ID') then begin
                                if Assigned(Self.GetMonikerForFieldCode(Self.GetFieldCode('StoreCard_ID'))) AND not Self.GetMonikerForFieldCode(Self.GetFieldCode('StoreCard_ID')).IsNull and not NxIsEmptyOID(self.GetFieldValueAsString('StoreCard_ID')) then begin
                                        AParams.NewFromDataType(dtString, 'FilterStoreBatch').AsString := Self.GetMonikerForFieldCode(Self.GetFieldCode('Storecard_ID')).BusinessObject.GetFieldValueAsString('ID');
                                end;
                        end;
                end ;

        end;
end;

// kontrola zadání šarží
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
    if Self.GetFieldValueAsInteger('Rowtype')=3 then begin
        if Self.GetMonikerForFieldCode(Self.GetFieldCode('Storecard_ID')).BusinessObject.GetFieldValueAsinteger('Category')=2 then begin
                if NxIsEmptyOID(Self.GetFieldValueAsString('X_Storebatch_ID')) then begin
                        AResult := False;
                        Self.AddValidateError(Self.GetFieldCode('X_Storebatch_ID'), 'Položka šarže/sériové číslo je poviná');
                end;
        end;
    end;
end;

  }
begin
end.