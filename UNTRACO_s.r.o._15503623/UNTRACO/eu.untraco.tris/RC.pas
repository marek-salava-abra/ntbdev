procedure CheckRC (OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string);
var
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 mOVName:string;
 mReceiptCard_ID, mStoreCard_ID:string;
 mReceiptCardBO, mRowBO, mOVRow:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mRowChecked, mBool:Boolean;
 mDateStr, mYear, mMonth, mDay:string;
 mDate:Extended;
 i,j:Integer;
begin
  mOS:=OS;
  mBool:=False;
  try
    mList:=TStringList.Create;
             mlist.LoadFromFile(Directory+'\'+FileName);
             if Trim(Copy(mlist.Strings[1],19,3))='380' then begin
                mOVName:=Trim(Copy(mlist.Strings[1],99,15));
                mReceiptCard_ID:=GetReceiptCard_ID(mOS, mOVName);
                if not(NxIsEmptyOID(mReceiptCard_ID)) then begin
                  mDateStr:=Trim(Copy(mlist.Strings[1],25,8));
                  mDay:=AnsiRightStr(mDateStr,2);
                  mYear:=AnsiLeftStr(mDateStr,4);
                  mMonth:=AnsiRightStr(Trim(Copy(mlist.Strings[1],25,6)),2);
                  mDate:=StrToDateTime(Format('%s.%s.%s',[mDay,mMonth,mYear]));
                  mReceiptCardBO:=mOS.CreateObject(Class_ReceiptCard);
                  mReceiptCardBO.Load(mReceiptCard_ID,nil);
                  mReceiptCardBO.SetFieldValueAsString('Firm_ID','6P60000101');
                  mReceiptCardBo.SetFieldValueAsDateTime('DocDate$Date',mDate);
                  mReceiptCardBO.SetFieldValueAsString('Description',Copy(mlist.Strings[1],99,15)+' '+Copy(mlist.Strings[1],4,15));
                  mReceiptCardBO.SetFieldValueAsInteger('TradeType',2);
                  mReceiptCardBO.SetFieldValueAsString('Country_ID','00000DK000');
                  mReceiptCardBO.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000');
                  mReceiptCardBO.SetFieldValueAsString('IntrastatTransactionType_ID','1001000000');
                  mReceiptCardBO.SetFieldValueAsString('IntrastatTransportationType_ID','2000000000');
                  mRows:=mReceiptCardBO.GetCollectionMonikerForFieldCode(mReceiptCardBO.GetFieldCode('Rows'));

                   for j:=2 to mList.Count-1 do begin
                     if AnsiLeftStr(mlist.strings[j],3)='LIN' then begin
                       mStorecard_ID:=GetSToreCard_ID(mos,trim(copy(mlist.Strings[j],10,25)),trim(copy(mlist.Strings[j],4,6)));
                       if NxIsEmptyOID(mStoreCard_ID) then NxShowSimpleMessage(trim(copy(mlist.Strings[j],4,6)) +' '+trim(copy(mlist.Strings[j],10,25))+' '+FileName,nil);
                       mRowChecked:=false;
                       for i:=0 to mRows.count-1 do begin
                         mRowBO:=mRows.BusinessObject[i];
                         if mRowBO.GetFieldValueAsString('StoreCard_ID')=mStoreCard_ID then begin
                           mRowBO.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mlist.Strings[j],63,12))*GetStoreUnitRate(mos,mRowBO.GetFieldValueAsString('StoreCard_ID')));
                           mRowBo.SetFieldValueAsInteger('IntrastatStatus',2);
                           mRowBO.SetFieldValueAsFloat('TotalPrice',NxIBStrToFloat(copy(mlist.Strings[j],118,12)));
                           mRowBO.SetFieldValueAsFloat('UnitPrice', 0);
                           mRowBO.SetFieldValueAsString('OriginCountry_ID',mRowBO.GetFieldValueAsString('StoreCard_ID.Country_ID'));
                           mRowBO.SetFieldValueAsString('U_lin',trim(copy(mlist.Strings[j],4,6)));
                           mRowChecked:=True;
                         end;
                       end;
                        if not(mRowChecked) then begin
                           mRowBO:=mrows.AddNewObject;
                           mRowBO.Prefill;
                           mRowBO.SetFieldValueAsString('Store_ID','1000000101');
                           mRowBO.SetFieldValueAsString('StoreCard_ID',mStorecard_ID);
                           mRowBO.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mlist.Strings[j],63,12))*GetStoreUnitRate(mos,mRowBO.GetFieldValueAsString('StoreCard_ID')));
                           mRowBo.SetFieldValueAsInteger('IntrastatStatus',2);
                           mRowBO.SetFieldValueAsFloat('TotalPrice',NxIBStrToFloat(copy(mlist.Strings[j],118,12)));
                           mRowBO.SetFieldValueAsFloat('UnitPrice', 0);
                           mRowBO.SetFieldValueAsString('OriginCountry_ID',mRowBO.GetFieldValueAsString('StoreCard_ID.Country_ID'));
                           mRowBO.SetFieldValueAsString('U_lin',trim(copy(mlist.Strings[j],4,6)));

                         end;
                     end;
                    end;
                  for i:=0 to mRows.count-1 do begin
                   if not(mRows.BusinessObject[i].GetFieldValueAsFloat('UnitPrice')=0) then mrows.BusinessObject[i].MarkForDelete;
                  end;
                  for i:=0 to mRows.CountOfNotDeleted-1 do begin
                   if not(mrows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID')='1T00000101') then begin
                    if not(mBool) then begin
                       if not(mrows.BusinessObject[i].GetFieldValueAsFloat('UnitQuantity')=mrows.BusinessObject[i].GetFieldValueAsFloat('X_ConfirmedQuantity')) then mBool:=True;
                    end;
                   end;
                  end;
                  if mBool then mReceiptCardBO.SetFieldValueAsInteger('X_TrisState',3) else mReceiptCardBO.SetFieldValueAsInteger('X_TrisState',2);
                  mReceiptCardBO.Save;
                  mReceiptCardBO.Free;
                  NxCopyFile(Directory+'\'+FileName,'C:\SERVER\EDILGC\FTPortM\Fronta\Logicentrum\Archiv\Prijato\'+FileName);
                  DeleteFile(Directory+'\'+FileName);
                end;
             end;

  finally

  end;
  ProcessContinue := True;

end;



function GetStoreCard_ID(AOS : TNxCustomObjectSpace; aEAN, bValue : string) : string;
const
  cSQL = 'SELECT sc.ID FROM StoreCards Sc left join StoreUnits su on sc.id=su.parent_id left join storeeans se on se.parent_id=su.id where se.ean=''%s'' and sc.hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    //if bValue='63' then NxShowSimpleMessage(Format(cSQL, [aEAN]),nil);
    AOS.SQLSelect(Format(cSQL, [aEAN]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetStoreUnitRate(AOS : TNxCustomObjectSpace; aStoreCard_ID : string) : Extended;
const
  cSQL = 'SELECT su.Unitrate FROM StoreUnits su where su.parent_ID=''%s'' and su.X_EDI=''A'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:=1;
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
  finally
    mList.Free;
  end;
end;

function GetReceiptCard_ID(AOS : TNxCustomObjectSpace; aDescription : string) : String;
const
  cSQL = 'SELECT ID FROM StoreDocuments  where Description=''%s'' and DocumentType=''20'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [aDescription]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0];
  finally
    mList.Free;
  end;
end;

begin
end.