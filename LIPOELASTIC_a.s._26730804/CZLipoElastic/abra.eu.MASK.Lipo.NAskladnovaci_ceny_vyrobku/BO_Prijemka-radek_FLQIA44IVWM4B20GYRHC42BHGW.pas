uses 'EU.Aabra.Mask.Validace.lib',
      '_Knihovny_ALL.HistoryData' ;
var
price: Double;



{
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
Var
pstorecard_ID:string;
x: TNxCustomBusinessObject;
begin
if (Self.GetFieldValueAsString('Parent_id.docqueue_ID')<>'') then begin
  if (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1700000101') or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1300000101') or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='A000000101')
   or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1900000101')  or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='2H00000101') then begin



            pstorecard_ID:= self.GetFieldValueAsString('Storecard_ID');
            price:=Self.GetFieldValueAsFloat('Unitprice');
            x:= Self.objectspace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
            try
                  x.load(pstorecard_ID,nil);
                  if  Self.GetFieldValueAsString('Store_ID.X_Cena')='R' then begin
                          x.setFieldValueAsFloat('X_cena_rozprac',price);
          //                ShowMessage('01');
                  end;
                  if  Self.GetFieldValueAsString('Store_ID.X_Cena')='S' then begin
                          x.setFieldValueAsFloat('X_cena_skladova',price);
          //                ShowMessage('02');
                  end;
                 // x.Save;
                finally;
                  x.free;
                end;
  end;
end;
end;}

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;

begin
//if not(CFxNxRuntime.NxGetEnvironmentType=reWebServices) then begin
if not(self.GetFieldValueAsBoolean('Parent_ID.X_ZAPI')) then begin
  // Zjistime kod polozky Nazev
if (Self.GetFieldValueAsString('Parent_id.docqueue_ID')<>'1320000101') then begin
if (self.GetFieldValueAsString('Storecard_id')<>'') and (self.GetFieldValueAsString('Storecard_id')<>'0000000000')then begin
  mCode := Self.GetFieldCode('Storecard_ID');
  // Pokud se meni polozka Nazev
//  ShowMessage(IntToStr(AFieldCode));
  if (AFieldCode = mCode) or (AFieldCode=345) then begin
        if (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1700000101') or
         (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='2H00000101') or
          (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1300000101') or
          (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='A000000101') or
          (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='~00000000B') or
          (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='~00000000C') or
          //(Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='') or

          (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1900000101')








          then begin

                if Self.GetFieldValueAsString('Store_ID.X_Cena')='R' then begin
                    price:=Self.getFieldValueAsFloat('StoreCard_ID.X_Cena_rozprac');
                    self.SetFieldValueAsFloat('UnitPrice',price);
            //                ShowMessage('03');
                end;
                    if Self.GetFieldValueAsString('Store_ID.X_Cena')='S' then begin
                    price:=Self.getFieldValueAsFloat('StoreCard_ID.X_Cena_skladova');
                    self.SetFieldValueAsFloat('UnitPrice',price);
            //                ShowMessage('04');
                end;
                if Self.GetFieldValueAsString('Store_ID.X_Cena')='P' then begin
                    price:=Self.getFieldValueAsFloat('StoreCard_ID.X_Cena_precen');
                    self.SetFieldValueAsFloat('UnitPrice',price);
            //                ShowMessage('04');
                end;
                if Self.GetFieldValueAsString('Store_ID.X_Cena')='A' then begin
                    price:=Self.getFieldValueAsFloat('StoreCard_ID.X_Cena_rozprac1');
                    self.SetFieldValueAsFloat('UnitPrice',price);
            //                ShowMessage('04');
                end;
            if Self.GetFieldValueAsString('Store_ID.X_Cena')='SK' then begin
                    price:=Self.getFieldValueAsFloat('StoreCard_ID.X_Cena_skladova_SK');
                    self.SetFieldValueAsFloat('UnitPrice',price);
            //                ShowMessage('04');
                end;
            if Self.GetFieldValueAsString('Store_ID.X_Cena')='SR' then begin
                    price:=Self.getFieldValueAsFloat('StoreCard_ID.X_Cena_rozprac_SK');
                    self.SetFieldValueAsFloat('UnitPrice',price);
            //                ShowMessage('04');
                end;




       end;

  end;
  end;
end;
end;
end;




procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
  mCode: integer;
  mString:string;
begin
 if not(self.GetFieldValueAsBoolean('Parent_ID.X_ZAPI')) then begin
 //if not(CFxNxRuntime.NxGetEnvironmentType=reWebServices) then begin
    //mString:= GetHistoryData(self.ObjectSpace,'C3V5QDVZ5BDL342M01C0CX3FCC',self.oid, 'X_Cena_rozprac',Self.GetFieldValueAsDateTime('Parent_ID.DOcdate$date')+500);
    //if  mString='NoData' then
    //    NxShowSimpleMessage('Aktuální data ' + NxFloatToIBStr(Self.getFieldValueAsFloat('StoreCard_ID.X_Cena_rozprac')),nil)
    //else
    //    NxShowSimpleMessage('Historická data ' + mString,nil);

    //mString:=InputBox('A','B',mstring);
    //NxShowSimpleMessage(mString,nil);
    try
    if (Self.GetFieldValueAsString('Parent_id.docqueue_ID')<>'1320000101') then begin
        if (self.GetFieldValueAsString('Storecard_id')<>'') and (self.GetFieldValueAsString('Storecard_id')<>'0000000000')then begin
            if (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1700000101')
            or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='2H00000101')
            or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1300000101')
            or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='A000000101')
            or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1900000101')
             or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='~00000000B')
              or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='~00000000C')
            // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
            // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
            // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
            // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
            // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
            // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
            // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
            // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
            // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')

            or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='__8000000101') then begin

                       if Self.GetFieldValueAsString('Store_ID.X_Cena')='R' then begin

                    price:=Self.getFieldValueAsFloat('StoreCard_ID.X_Cena_rozprac');
                    self.SetFieldValueAsFloat('UnitPrice',price);
            //                ShowMessage('03');
                end;
                    if Self.GetFieldValueAsString('Store_ID.X_Cena')='S' then begin
                          if Self.getFieldValueAsFloat('StoreCard_ID.X_Cena_skladova')>0 then  begin
                              price:=Self.getFieldValueAsFloat('StoreCard_ID.X_Cena_skladova');
                              self.SetFieldValueAsFloat('UnitPrice',price);
                          end;
            //                ShowMessage('04');
                end;
                if Self.GetFieldValueAsString('Store_ID.X_Cena')='P' then begin
                    price:=Self.getFieldValueAsFloat('StoreCard_ID.X_Cena_precen');
                    self.SetFieldValueAsFloat('UnitPrice',price);
            //                ShowMessage('04');
                end;
                if Self.GetFieldValueAsString('Store_ID.X_Cena')='A' then begin
                    price:=Self.getFieldValueAsFloat('StoreCard_ID.X_Cena_rozprac1');
                    self.SetFieldValueAsFloat('UnitPrice',price);
            //                ShowMessage('04');
                end;
            if Self.GetFieldValueAsString('Store_ID.X_Cena')='SK' then begin
                    price:=Self.getFieldValueAsFloat('StoreCard_ID.X_Cena_skladova_SK');
                    self.SetFieldValueAsFloat('UnitPrice',price);
            //                ShowMessage('04');
                end;
            if Self.GetFieldValueAsString('Store_ID.X_Cena')='SR' then begin
                    price:=Self.getFieldValueAsFloat('StoreCard_ID.X_Cena_rozprac_SK');
                    self.SetFieldValueAsFloat('UnitPrice',price);
            //                ShowMessage('04');
                end;

            end;
        end;

    end;
    finally

    end;
  end;
end;

begin
end.