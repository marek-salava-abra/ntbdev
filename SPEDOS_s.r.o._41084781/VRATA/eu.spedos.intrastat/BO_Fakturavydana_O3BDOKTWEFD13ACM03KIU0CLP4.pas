{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i:Integer;
 mRowBO:TNxCustomBusinessObject;
begin
  if (AFieldCode=self.GetFieldCode('IsReverseChargeDeclared')) and not(Avalue.AsBoolean=AOriginalValue.AsBoolean) then begin
    if self.GetFieldValueAsBoolean('IsReverseChargeDeclared') and (self.GetFieldValueAsInteger('TradeType')=1) then begin
      mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
      for i:=0 to mrows.Count-1 do begin
        mRowBO:=mRows.BusinessObject[i];
        if mRowBO.GetFieldValueAsInteger('RowType')=2 then begin
         mRowbo.SetFieldValueAsInteger('VATMode',1);
         mRowbo.SetFieldValueAsString('DRCArticle_ID','1100000000');
        end;
      end;
    end;
    if not(self.GetFieldValueAsBoolean('IsReverseChargeDeclared')) and (self.GetFieldValueAsInteger('TradeType')=1) then begin
      mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
      for i:=0 to mrows.Count-1 do begin
        mRowBO:=mRows.BusinessObject[i];
        if mRowBO.GetFieldValueAsInteger('RowType')=2 then begin
         mRowbo.SetFieldValueAsInteger('VATMode',0);
         mRowbo.SetFieldValueAsString('DRCArticle_ID','0000000000');
        end;
      end;
    end;
  end;
end;



{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mRowBO:TNxCustomBusinessObject;
 mIntra2Amount, mLocalIntra2Amount:Extended;
begin
  if self.GetFieldValueAsInteger('TradeType')=2 then begin
    mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
      for i:=0 to mrows.Count-1 do begin
        mRowBO:=mRows.BusinessObject[i];
        if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
          if mRowBO.GetFieldValueAsBoolean('StoreCard_ID.IsProduct') and not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('X_Pozice_OD'))) then begin
            mIntra2Amount:=GetIntrastatAmount(self.ObjectSpace,mRowBO.GetFieldValueAsString('X_Pozice_OD'), mRowBO.GetFieldValueAsString('Parent_ID'));
            mLocalIntra2Amount:=GetLocalIntrastatAmount(self.ObjectSpace,mRowBO.GetFieldValueAsString('X_Pozice_OD'), mRowBO.GetFieldValueAsString('Parent_ID'));
            mRowBO.SetFieldValueAsFloat('IntrastatAmount', mRowBO.GetFieldValueAsFloat('TAmountWithoutVAT')+mIntra2Amount);
            mRowBO.SetFieldValueAsFloat('LocalIntrastatAmount', mRowBO.GetFieldValueAsFloat('LocalTAmountWithoutVAT')+mLocalIntra2Amount);
          end;
          if not(mRowBO.GetFieldValueAsBoolean('StoreCard_ID.IsProduct'))  then begin
            mRowBO.SetFieldValueAsFloat('IntrastatAmount', mRowBO.GetFieldValueAsFloat('TAmountWithoutVAT'));
            mRowBO.SetFieldValueAsFloat('LocalIntrastatAmount', mRowBO.GetFieldValueAsFloat('LocalTAmountWithoutVAT'));
          end;
          if not(mRowBO.GetFieldValueAsBoolean('StoreCard_ID.IsProduct')) and (NxIsEmptyOID(mRowBO.GetFieldValueAsString('X_Pozice_OD')))  then begin
            mRowBO.SetFieldValueAsFloat('IntrastatAmount', mRowBO.GetFieldValueAsFloat('TAmountWithoutVAT'));
            mRowBO.SetFieldValueAsFloat('LocalIntrastatAmount', mRowBO.GetFieldValueAsFloat('LocalTAmountWithoutVAT'));
          end;
        end;
        if mRowBO.GetFieldValueAsInteger('RowType')=2 then begin
          mRowBo.SetFieldValueAsBoolean('SplitIntrastat',false);
          mRowBo.SetFieldValueAsBoolean('ToIntrastat',false);
          mRowBo.SetFieldValueAsInteger('IntrastatStatus',0);
        end;
      end;
   end;
end;

function GetIntrastatAmount(var AOS : TNxCustomObjectSpace;var aPozice_ID, aParent_ID:string): extended;
const
  cSQL = 'SELECT sum(TAmountWithoutVAT) FROM IssuedInvoices2 WHERE X_Pozice_OD=''%s'' and parent_ID=''%s'' and rowtype=2 ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aPozice_ID, aParent_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;
function GetLocalIntrastatAmount(var AOS : TNxCustomObjectSpace;var aPozice_ID, aParent_ID:string): extended;
const
  cSQL = 'SELECT sum(LocalTAmountWithoutVAT) FROM IssuedInvoices2 WHERE X_Pozice_OD=''%s'' and parent_ID=''%s'' and rowtype=2 ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aPozice_ID, aParent_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

begin
end.