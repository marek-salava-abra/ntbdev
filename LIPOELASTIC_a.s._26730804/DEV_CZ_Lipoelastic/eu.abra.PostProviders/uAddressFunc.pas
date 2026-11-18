uses
  'eu.abra.PostProviders.uConst',
  'eu.abra.PostProviders.uSQLFunc',
  'eu.abra.PostProviders.uDocTypeFunc';

//nastavi adresu
procedure SetAddress(AOS: TNxCustomObjectSpace; var APackagesDataSet: TDataSet; ASender : Boolean);
var
  mTmp, mCity, mStreet, mPostCode, mCountryCode, mPhoneNumber, mSufix: string;
begin
  //mTmp := GetAddress(AOS, APackagesDataSet);
  mSufix := NxIIfStr(ASender, cFDSen,'' );

  mTmp := GetAddressByAdrID(AOS, APackagesDataSet, ASender);

  mCity := NxTrim(NxTrapStr(mTmp, ';'), '"');
  mStreet := NxTrim(NxTrapStr(mTmp, ';'), '"');
  mPostCode := NxTrim(NxTrapStr(mTmp, ';'), '"');
  mCountryCode := NxTrim(NxTrapStr(mTmp, ';'), '"');
  mPhoneNumber := NxTrim(NxTrapStr(mTmp, ';'), '"');

  APackagesDataSet.FieldByName(cFDAdrCity+mSufix).AsString := mCity;
  APackagesDataSet.FieldByName(cFDAdrStreet+mSufix).AsString := mStreet;
  APackagesDataSet.FieldByName(cFDAdrPostCode+mSufix).AsString := mPostCode;
  APackagesDataSet.FieldByName(cFDAdrCountryCode+mSufix).AsString := mCountryCode;
  APackagesDataSet.FieldByName(cFDAdrPhoneNumber+mSufix).AsString := mPhoneNumber;
end;

//dotahne adresu
function GetAddress(AOS: TNxCustomObjectSpace; const APackagesDataSet: TDataSet; ASender : Boolean ): string;
const
  cSQL = 'select ad.city, ad.Street, ad.PostCode, ad.CountryCode from %s sdoc '+
         'left join %ss b on b.id = sdoc.%s_id '+
         'left join Addresses ad on ad.id = b.%saddress_id '+
         'where sdoc.ID = %s';
var
  mResult, mID, mTmp, mSQL, mTableName,mSufix: string;
  i: Integer;
begin
  Result := '';
  mSufix := NxIIfStr(ASender, cFDSen,'' );
  mResult := '';
  mTmp := '';
  mSQL := '';
  mID := APackagesDataSet.FieldByName(cFDID).AsString;
  mTableName:= GetTableName(APackagesDataSet.FieldByName(cFDDocumentType).AsString);
  case APackagesDataSet.FieldByName(cFDTargetAddressType+mSufix).AsInteger of
    cFromFirm:
      begin
        mSQL := 'Firm';
        mTmp := 'Residence';
      end;
    cFromFirmOffice: mSQL := 'FirmOffice';
    cFromPerson: mSQL := 'Person';
  end;
  mSQL := Format(cSQL, [mTableName, mSQL, mSQL, mTmp, QuotedStr(mID)]);
  mResult := GetFirstRecordFromSQL(AOS, mSQL);
  if Trim(mResult) <> '' then begin
    mResult := mResult + ';' + GetPhoneNumber(AOS, mTableName, mID);
  end;
  Result := mResult;
end;


//dotahne adresu
//v3.2 - často je chtěno pracovat s jinou položkou než je firma z Firm_ID. Nechme tedy možnost zadat ID a naáhnout data podle téhoto ID
function GetAddressByAdrID(AOS: TNxCustomObjectSpace; const APackagesDataSet: TDataSet; ASender:Boolean): string;
const
  cField = ' ad.city, ad.Street, ad.PostCode, ad.CountryCode, ad.PhoneNumber1 ';
  cSQL = 'select ad.city, ad.Street, ad.PostCode, ad.CountryCode from %s sdoc '+
         'left join %ss b on b.id = sdoc.%s_id '+
         'left join Addresses ad on ad.id = b.%saddress_id '+
         'where sdoc.ID = %s';
var
  mResult, mID, mTmp, mSQL, mTableName,mSufix: string;
  i: Integer;
begin
  Result := '';
  mSufix := NxIIfStr(ASender, cFDSen,'' );
  mResult := '';
  mTmp := '';
  mSQL := '';
  mTableName := '';

  mID :='';
  //Firm
  case APackagesDataSet.FieldByName(cFDTargetAddressType+mSufix).AsInteger of
    cFromFirm:
      begin
        mID := APackagesDataSet.FieldByName(cFDFirm_ID+mSufix).AsString;
        mTableName := 'Firm';
        mTmp := 'Residence';
      end;
    cFromFirmOffice:
      begin
        mID := APackagesDataSet.FieldByName(cFDFirmOffice_ID+mSufix).AsString;
        mTableName := 'FirmOffice';
      end;
    cFromPerson:
      begin
        mID := APackagesDataSet.FieldByName(cFDPerson_ID+mSufix).AsString;
        mTableName := 'Person';
      end;
  end;
  mSQL := Format('select %s from %ss A left join Addresses ad on ad.id = A.%sAddress_id where A.id = ''%s''',[cField,mTableName,mTmp,mID]);
  mResult := GetFirstRecordFromSQL(AOS, mSQL);
  Result := mResult;
end;


//nastavi poznámku pro řidiče
procedure SetNoteForDriver(AOS: TNxCustomObjectSpace; var APackagesDataSet: TDataSet; const ASourceField: string);
var
  mTmp, mNoteForDriver: string;
begin
  if Trim(ASourceField) = '' then exit;

  mTmp := GetNoteForDriver(AOS, APackagesDataSet, ASourceField);
  mNoteForDriver := NxTrim(NxTrapStr(mTmp, ';'), '"');
  APackagesDataSet.FieldByName(cFDNoteForDriver).AsString := mNoteForDriver;
end;

//dotahne poznámku pro řidiče
function GetNoteForDriver(AOS: TNxCustomObjectSpace; const APackagesDataSet: TDataSet; const ASourceField: string): string;
const
  cSQL = 'select ad.%s from %s sdoc '+
         'left join %ss b on b.id = sdoc.%s_id '+
         'left join Addresses ad on ad.id = b.%saddress_id '+
         'where sdoc.ID = %s';
var
  mID, mTmp, mSQL, mTableName: string;
begin
  Result := '';
  mTmp := '';
  mSQL := '';
  mID := APackagesDataSet.FieldByName(cFDID).AsString;
  mTableName:= GetTableName(APackagesDataSet.FieldByName(cFDDocumentType).AsString);
  case APackagesDataSet.FieldByName(cFDTargetAddressType).AsInteger of
    cFromFirm:
      begin
        mSQL := 'Firm';
        mTmp := 'Residence';
      end;
    cFromFirmOffice: mSQL := 'FirmOffice';
    cFromPerson: mSQL := 'Person';
  end;
  mSQL := Format(cSQL, [ASourceField, mTableName, mSQL, mSQL, mTmp, QuotedStr(mID)]);
  Result := GetFirstRecordFromSQL(AOS, mSQL);
end;

//nastavi nazev firmy/jmeno osoby
procedure SetAdrName(AOS: TNxCustomObjectSpace; var APackagesDataSet: TDataSet; ASender:Boolean );
var
  mTmp, mFirmName, mPersonName,mSufix: string;
begin
  mTmp := GetAdrName(AOS, APackagesDataset,ASender);
  mSufix := NxIIfStr(ASender, cFDSen,'' );

  mFirmName := NxTrim(NxTrapStr(mTmp, ';'), '"');
  mPersonName := NxTrim(NxTrapStr(mTmp, ';'), '"');

  case APackagesDataSet.FieldByName(cFDTargetAddressType+mSufix).AsInteger of
    cFromFirm, cFromFirmOffice: APackagesDataSet.FieldByName(cFDAdrName+mSufix).AsString := mFirmName;
    cFromPerson: APackagesDataSet.FieldByName(cFDAdrName+mSufix).AsString := mPersonName;
  end;
  APackagesDataSet.FieldByName(cFDPersonName+mSufix).AsString := mPersonName;
end;

//dotahne nazev firmy/jmeno osoby
function GetAdrName(AOS: TNxCustomObjectSpace; var APackagesDataSet: TDataSet; ASender:Boolean): string;
const
  cSQL = 'select F.name, PE.FirstName ||'' ''|| PE.LastName from %s sdoc '+
         'left join Firms F ON F.ID=sdoc.Firm_ID '+
         'left join Persons PE ON PE.ID=sdoc.Person_ID '+
         'where sdoc.ID = %s';
var
  mID, mSQL, mTableName,mSufix: string;
begin
  Result := '';
  mSufix := NxIIfStr(ASender, cFDSen,'' );
  case APackagesDataSet.FieldByName(cFDTargetAddressType+mSufix).AsInteger of
    cFromFirm:
      begin
        mID := APackagesDataSet.FieldByName(cFDFirm_ID+mSufix).AsString;
        mTableName := 'Firm';
        mSQL := Format('select A.name, PE.FirstName ||'' ''|| PE.LastName from %ss A left join Persons PE ON PE.ID = ''%s'' where A.id = ''%s''',[mTableName,APackagesDataSet.FieldByName(cFDPerson_ID+mSufix).AsString ,mID]);
      end;
    cFromFirmOffice:
      begin
        mID := APackagesDataSet.FieldByName(cFDFirmOffice_ID+mSufix).AsString;
        mTableName := 'FirmOffice';
        mSQL := Format('select A.name, PE.FirstName ||'' ''|| PE.LastName from %ss A left join Persons PE ON PE.ID = ''%s'' where A.id = ''%s''',[mTableName,APackagesDataSet.FieldByName(cFDPerson_ID+mSufix).AsString ,mID]);
      end;
    cFromPerson:
      begin
        mID := APackagesDataSet.FieldByName(cFDPerson_ID+mSufix).AsString;
        mTableName := 'Person';
        mSQL := Format('select PE.FirstName ||'' ''|| PE.LastName from %ss PE where PE.id = ''%s''',[mTableName,APackagesDataSet.FieldByName(cFDPerson_ID+mSufix).AsString ,mID]);
      end;
  end;
  Result := GetFirstRecordFromSQL(AOS, mSQL);
  (*
  mID := APackagesDataSet.FieldByName(cFDID).AsString;
  mTableName:= GetTableName(APackagesDataSet.FieldByName(cFDDocumentType).AsString);
  mSQL := Format(cSQL, [mTableName, QuotedStr(mID)]);
  Result := GetFirstRecordFromSQL(AOS, mSQL);
  *)
end;

function GetPhoneNumber(AOS: TNxCustomObjectSpace; ATableName: string; ASourceDocID: TNxOID): string;
const
  cSQL_GetPhoneNumber = 'select Aadfpe.PhoneNumber1, Aadfpe.PhoneNumber2, Aadpe.PhoneNumber1, Aadpe.PhoneNumber2, Aadfo.PhoneNumber1, Aadfo.PhoneNumber2, Aadf.PhoneNumber1, Aadf.PhoneNumber2 from %s Asdoc '+
                        'join Firms Af on Af.id = Asdoc.Firm_id '+
                        'left join Addresses Aadf on Aadf.id = Af.ResidenceAddress_ID '+
                        'left join FirmOffices Afo on Afo.id = Asdoc.FirmOffice_id '+
                        'left join Addresses Aadfo on Aadfo.id = Afo.address_id '+
                        'left join Persons Ape on Ape.id = Asdoc.Person_id '+
                        'left join Addresses Aadpe on Aadpe.id = Ape.address_id '+
                        'left join FirmPersons Afpe on Afpe.Person_id = Asdoc.Person_id and Afpe.Parent_id = Asdoc.Firm_id '+
                        'left join Addresses Aadfpe on Aadfpe.id = Afpe.address_id '+
                        'where Asdoc.ID = %s';
var
  mSQL, mPhoneNumber: String;
  mList: TStringList;
  i: integer;
begin
  Result := '';
  mSQL := Format(cSQL_GetPhoneNumber, [ATableName, QuotedStr(ASourceDocID)]);
  mList := TStringList.Create;
  try
    mPhoneNumber := GetFirstRecordFromSQL(AOS, mSQL);
    NxTrapStrToStrings(mPhoneNumber, ';', mList);
    for i := 0 to mList.Count - 1 do begin
      mPhoneNumber := NxTrim(mList[i], '"');
      if (Trim(mPhoneNumber) = '') then
        continue
      else begin
        Result := NxSearchReplace(mPhoneNumber, ' ', '', [srAll]);
        break;
      end;
    end;
  finally
    mList.Free;
  end;
end;



begin
end.