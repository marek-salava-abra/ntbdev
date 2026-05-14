uses 'EU.Aabra.Mask.Validace.lib';
{
// mazání šarže při změně skladové karty
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);

var
  mCode: integer;
  i:integer;
  mBO_Moniker : TNxCustomBusinessMonikerCollection;
  mr1:TStringList;
        mBO_Storeunit,mBO_Storeunit1:TNxCustomBusinessObject;
        pocet:Double;
begin

  if AFieldCode = Self.GetFieldCode('Storecard_ID') then begin
    if AOriginalValue.AsString <> AValue.AsString then begin
       Self.SetFieldValueAsString('X_StoreBatch_ID', '0000000000');
       self.SetFieldValueAsFloat('UnitPrice',0);
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
                                         // mBO_Storeunit.GetFieldValueAsFloat('')
                                         //ShowMessage('Skladová jednotka pro šarži nalezena');
                                        pocet:=(self.getFieldValueAsFloat('Quantity')* self.getFieldValueAsFloat('Unitrate'))
                                        /mBO_Storeunit.GetFieldValueAsFloat('UnitRate') ;
                                        self.SetFieldValueAsFloat('Quantity',pocet);
                                        self.SetFieldValueAsString('QUnit',mBO_Storeunit.GetFieldValueAsString('Code'));
                                finally
                                mBO_Storeunit.free;
                                end;

                                
                        end;
                finally
                        mr1.free;
                end;
        end;
        //mBO_Moniker:=Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('DocRowBatches'));
        //for i := 0 to mBO_Moniker.Count - 1 do begin
        //     ShowMessage(mBO_Moniker.BusinessObject[i].getFieldValueAsstring('NewBatchName'));
        // end;
        //mBO_Moniker.Free;
     end;
  end;

end;
function GetStoreBatch_ID(AOS : TNxCustomObjectSpace; aStoreCard_ID, aName : string) : string;
const
  cSQL = 'SELECT ID FROM Storebatches WHERE Name=''%s'' and storecard_id=''=s'' and hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID,aName]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;
// filtrování šarží podle skladové karty
{
Vyvolává se bezprostředně před provedením softvalidace objektu.

procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
var
  mCode: integer;
  i:integer;
  mBO_Moniker, mUnits : TNxCustomBusinessMonikerCollection;
  mr1:TStringList;
        mBO_Storeunit,mBO_Storeunit1, mStoreCardBO:TNxCustomBusinessObject;
        pocet:Double;
  mStoreBatch_ID, mNameBatch:String;
  k:integer;
begin
    {if NxIsEmptyOID(Self.GetFieldValueAsString('X_StoreBatch_ID')) and (osNew in self.State) and (self.GetFieldValueAsInteger('StoreCard_ID.Category')=2)then begin
      mStoreCardBO:=self.ObjectSpace.CreateObject(Class_StoreCard);
      mStoreCardBO.load(self.GetFieldValueAsString('StoreCard_ID'),nil);
      mUnits:=mStoreCardBO.GetLoadedCollectionMonikerForFieldCode(mStoreCardBO.GetFieldCode('StoreUnits'));
      NxShowSimpleMessage('jsem tu',nil);
      for k:=0 to mUnits.count-1 do begin
         if self.GetFieldValueAsString('Qunit')=mUnits.BusinessObject[k].GetFieldValueAsString('Code') then mNameBatch:=mUnits.BusinessObject[k].GetFieldValueAsString('Description');

      end;
      NxShowSimpleMessage(mNameBatch,nil);
       mStoreBatch_ID:=GetStoreBatch_ID(self.ObjectSpace,Self.GetFieldValueAsString('StoreCard_ID'),mNameBatch);

      if not(NxIsEmptyOID(mStoreBatch_ID)) then self.SetFieldValueAsString('X_StoreBatch_ID',mStorebatch_ID);

    end;


    exit;


end;

procedure CompleteRollValidateParams_Hook(Self: TNxCustomBusinessObject; AFieldCode: integer; AParams: TNxParameters);
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
//procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
//begin
//        if Self.GetMonikerForFieldCode(Self.GetFieldCode('Storecard_ID')).BusinessObject.GetFieldValueAsinteger('Category')=2 then begin
//                if NxIsEmptyOID(Self.GetFieldValueAsString('X_Storebatch_ID')) then begin
//                        AResult := False;
//                        Self.AddValidateError(Self.GetFieldCode('X_Storebatch_ID'), 'Položka šarže/sériové číslo je poviná');
//                end;
//        end;
//end;
     }
begin
end.