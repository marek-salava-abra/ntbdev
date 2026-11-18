
   //Příklad přenosu položky do připojené FV
{
Vyvolává se po uložení vlastních dat objektu do databáze.

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var mList: TStringList;
    mBO : TNxCustomBusinessObject;
const cSQLSelDoc = 'select RIGHTSIDE_ID from relations where LEFTSIDE_ID = ''%s'' and rel_def = 1400 ';

begin
  mBO := nil;
  OutputDebugString('Přenos čísla zásilky do faktury');
  if Self.GetFieldValueAsString('PostNumber') <> '' then
  begin
    try
      mList := TStringList.Create();
      try
        Self.ObjectSpace.SQLSelect(Format(cSQLSelDoc,[Self.OID]),mList);
        if mList.Count > 0 then
        begin
          if not CFxOID.IsEmptyOrFull(mList[0]) then
          begin
          mBO := Self.ObjectSpace.CreateObject(Class_IssuedInvoice);
          mBO.Load(mList[0],nil);
          if Self.GetFieldValueAsString('PostNumber') <> mBO.GetFieldValueAsString('X_number_delivery') then
          begin
            mBO.SetFieldValueAsString('X_number_delivery',Self.GetFieldValueAsString('PostNumber') );
            mBO.SetFieldValueAsString('X_delivery_link',Self.GetFieldValueAsString('X_PD_Track_Url') );

            mBO.Save;
          end;
          end else OutputDebugString('SQL result Null');
        end else OutputDebugString('SQL Result Null');



      except
        OutputDebugString(ExceptionMessage);
      end;
    finally
      if mBO <> nil then
        mbo.Free;
      mList.free;
    end;
  end;
end;
      }
begin
end.