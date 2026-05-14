procedure AfterFillOptputRows_Hook(Self: TNxDocumentImportManager);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i:Integer;
 mRowBO:TNxCustomBusinessObject;
begin
 if self.OutputDocument.GetFieldValueAsInteger('TradeType')=2 then begin
      mRows:=self.OutputDocument.GetLoadedCollectionMonikerForFieldCode(self.OutputDocument.GetFieldCode('Rows'));
      for i:=0 to mrows.Count-1 do begin
        mRowBO:=mRows.BusinessObject[i];
        if mRowBO.GetFieldValueAsInteger('RowType')=2 then begin
          mRowBo.SetFieldValueAsBoolean('SplitIntrastat',True);
          mRowBo.SetFieldValueAsBoolean('ToIntrastat',True);
          mRowBo.SetFieldValueAsInteger('IntrastatStatus',2);
          mRowBo.SetFieldValueAsBoolean('ToEsl',True);
          mRowBo.SetFieldValueAsInteger('ESLStatus',1);
          mRowBO.SetFieldValueAsString('ESLIndicator_ID','1000000000');
        end;
      end;
 end;
  if self.OutputDocument.GetFieldValueAsInteger('TradeType')=1 then begin
    if self.OutputDocument.GetFieldValueAsBoolean('IsReverseChargeDeclared') then begin
      mRows:=self.OutputDocument.GetLoadedCollectionMonikerForFieldCode(self.OutputDocument.GetFieldCode('Rows'));
      for i:=0 to mrows.Count-1 do begin
        mRowBO:=mRows.BusinessObject[i];
        if mRowBO.GetFieldValueAsInteger('RowType')=2 then begin
         mRowbo.SetFieldValueAsInteger('VATMode',1);
        end;
      end;
    end;
  end;
end;

begin
end.