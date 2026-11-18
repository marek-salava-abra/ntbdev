//LIPO

const
      cSQLSelectIssuedInvoiceByBillOfDelivery =  'select distinct II.id as ID   '+
                                                  'from ISSUEDINVOICES2 II2 '+
                                                  'join ISSUEDINVOICES II on II.ID = II2.PARENT_ID '+
                                                  'join STOREDOCUMENTS2 SD2 on SD2.ID = II2.PROVIDEROW_ID '+
                                                  'where SD2.parent_id = ''%s'' ';
      cSQLSelectIssuedInvoiceByReceivedOrder =  'select distinct II.id as ID   '+
                                                  'from ISSUEDINVOICES2 II2 '+
                                                  'join ISSUEDINVOICES II on II.ID = II2.PARENT_ID '+
                                                  'join STOREDOCUMENTS2 SD2 on SD2.ID = II2.PROVIDEROW_ID '+
                                                  'join STOREDOCUMENTS SD on SD.ID = SD2.Parent_id and SD.DocumentType = ''21'' '+
                                                  'join ReceivedOrders2 RO2 on RO2.ID = SD2.PROVIDEROW_ID '+
                                                  'where RO2.parent_id = ''%s'' ';

{GetIssuedInvoiceFromPDMDocumentID
Vratí ID faktury pokud existuje}
function GetIssuedInvoiceFromPDMDocumentID(AOS:TNxCustomObjectSpace;SourceDocType:String;SourceDocID:String):String;
begin
  Result:= '';
  if not CFxOID.IsEmptyOrFull(SourceDocID) then
  begin
    case SourceDocType of
    '03':Result:= SourceDocID;
    '21':Result:= AOS.SQLSelectFirstAsString( Format(cSQLSelectIssuedInvoiceByBillOfDelivery,[SourceDocID]) ,'');
    'RO':Result:= AOS.SQLSelectFirstAsString( Format(cSQLSelectIssuedInvoiceByReceivedOrder,[SourceDocID]) ,'');
    end;
  end;

end;

{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var mBO: TNxCustomBusinessObject;
    mID: String;
begin
  if Self.GetFieldValueAsBoolean('X_PD_ImportFromIssuedInvoice') then
  begin
    mID := GetIssuedInvoiceFromPDMDocumentID(Self.ObjectSpace,Self.GetFieldValueAsString('X_PD_SourceDocType'),Self.GetFieldValueAsString('X_PD_SourceDocID') );
    if not CFxOID.IsEmptyOrFull(mID) then
    begin
      mBO := Self.ObjectSpace.CreateObject(Class_IssuedInvoice);
      try
        mBO.Load(mID,nil);

        Self.SetFieldValueAsString('X_PD_ContentInvoiceNumber',mBO.GetFieldValueAsString('DisplayName'));
        Self.SetFieldValueAsDateTime('X_PD_ContentIssueDate', mBO.GetFieldValueAsDateTime('VATAdmitDate$DATE'));

        //Poskládat řádky do JSON
        Self.SetFieldValueAsString('X_PD_ContentData',GetRowsContentData(mBO));
        Self.SetFieldValueAsBoolean('X_PD_ImportFromIssuedInvoice',true);


      finally
        mBO.Free;
      end;
    end
    else
      Self.SetFieldValueAsString('X_PD_ContentData','Faktura nenalezena.');
  end;
end;

function GetRowsContentData(Self: TNxCustomBusinessObject):String;
var mRow: TNxCustomBusinessObject;
    mMon: TNxCustomBusinessMonikerCollection;
    i: Integer;
    mRoot,mItem: TJSONSuperObject;
    mArray: TJSONSuperObjectArray;
begin
  Result :='';

  mRoot := TJSONSuperObject.Create();
  try
    mRoot.O['content_data'] := TJSONSuperObject.CreateByDataType(jtArray);
    mMon := Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('rows'));
    for i:=0 to mMon.CountOfNotDeleted -1 do
    begin
      mItem := TJSONSuperObject.Create();
      try
        mRow:= mMon.BusinessObject[i];
        if mRow.GetFieldValueAsInteger('rowtype') = 3 then
        begin
          if mRow.GetFieldValueAsFloat('TotalPrice') = 0 then //Dohoda s lipo - nechceme položky typu 3, ale charakteru doprava. Dávat jako zboží.
          begin
            mItem.S['content_name'] := mRow.GetFieldValueAsString('StoreCard_ID.ForeignName');
            mItem.S['content_customs_code'] := mRow.GetFieldValueAsString('StoreCard_ID.Specification2');
            mItem.S['content_country'] := mRow.GetFieldValueAsString('StoreCard_ID.Country_ID.Code');
            mItem.D['content_weight'] := GetWeight_kg(mRow) / mRow.GetFieldValueAsFloat('UnitQuantity');
            mItem.D['content_pieces'] := mRow.GetFieldValueAsFloat('UnitQuantity');
            mItem.D['content_price'] := mRow.GetFieldValueAsFloat('TotalPrice') / mRow.GetFieldValueAsFloat('UnitQuantity');

            mRoot.O['content_data'].AsArray.add(mItem);
          end;
        end;
      finally
        mItem.free;
      end;
    end;

    Result := mRoot.AsString;
  finally
    mRoot.free;
  end;


end;

function GetWeight_kg(ARow:TNxCustomBusinessObject):Extended;
begin
  Result := 0;
  case ARow.GetFieldValueAsInteger('WeightUnit') of
    0: Result := ARow.GetFieldValueAsFloat('Weight') / 1000; //g
    1: Result := ARow.GetFieldValueAsFloat('Weight');
    2: Result := ARow.GetFieldValueAsFloat('Weight') * 1000;
  end;
end;



begin
end.