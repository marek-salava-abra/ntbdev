uses
  'eu.abra.PostProviders.extras.uConst';

procedure ExAfterGetData_DoNothing(AOSInt: integer; APackagesDataSetInt: integer; AHeaderDataSetInt: integer);
const
  cSQL = 'select a.ID from PDMPostProviders a where a.X_PD_IsLicensed = %s and a.X_PD_Driver = %s and upper(a.Code) = %s';
var
  mOS: TNxCustomObjectSpace;
  mPackagesDataSet, mHeaderDataSet: TDataSet;
  mSQL, mPostProvider_ID: string;
begin
  mOS := TNxCustomObjectSpace(IntToObj(AOSInt));
  mPackagesDataSet := TDataSet(IntToObj(APackagesDataSetInt));
  mHeaderDataSet := TDataSet(IntToObj(AHeaderDataSetInt));

// dohledani poskytovatele a prirazeni do hlavickoveho datasetu
  mSQL := format(cSQL, [QuotedStr('A'), IntToStr(cDriverBalikobot), QuotedStr('DPD')]);
  mPostProvider_ID := GetFirstRecordFromSQL(mOS, mSQL);

  if not CFxOID.IsEmpty(mPostProvider_ID) then begin
    //změna posktytovatele
    mHeaderDataSet.First;
    mHeaderDataSet.Edit;
    mHeaderDataSet.FieldByName(cFDPDMProvider).AsString := mPostProvider_ID;
  end;

end;

procedure GetDataFromIssuedOrder(AOSInt: integer; APackagesDataSetInt: integer; AHeaderDataSetInt: integer);
const
  cSQLProvider = 'select a.ID from PDMPostProviders a where a.X_PD_IsLicensed = %s and a.X_PD_Driver = %s and upper(a.Code) = %s';
  cSQLContentType = 'select b.ID from PDMPostProviders2 a join PDMIssuedContentTypes b on b.ID = a.IssuedContentType_ID where a.parent_ID = %s and upper(b.Code) = %s';
  cSQLBranches = 'select a.ID from PDMServiceTypes a where a.X_PD_PostProvider_ID = %s and a.X_ExternID = %s';
  cSQL3 = '';
var
  mOS: TNxCustomObjectSpace;
  mPackagesDataSet, mHeaderDataSet: TDataSet;
  mSQL, mIssuedContent_ID, mServiceType_ID, mServiceType_ID2, mOrder_ID, mPostProvider_ID: string;
  mOrderBO : TNxCustomBusinessObject;
begin


    mOS := TNxCustomObjectSpace(IntToObj(AOSInt));
    mPackagesDataSet := TDataSet(IntToObj(APackagesDataSetInt));
    mHeaderDataSet := TDataSet(IntToObj(AHeaderDataSetInt));

    mPackagesDataSet.First;
    while not mPackagesDataSet.Eof do begin
      mPackagesDataSet.Edit;
      try
        mOrder_ID := '';

        if mPackagesDataSet.FieldByName(cFDDocumentType).AsString = 'RO' then
        begin
          mOrderBO := mOS.CreateObject(Class_ReceivedOrder);
          mOrder_ID := mHeaderDataSet.FieldByName(cFDID).AsString;
          if not NxIsEmptyOID(mOrder_ID) then
          begin
            mOrderBO.Load(mOrder_ID,nil);
            mPostProvider_ID := '';
            //dopravce podel objednávky
            if mPostProvider_ID = '' then
            begin
              mSQL := format(cSQLProvider, [QuotedStr('A'), IntToStr(cDriverBalikobot), QuotedStr( UpperCase(mOrderBO.GetFieldValueAsString('X_PD_BB_Modul')))]);
              mPostProvider_ID := GetFirstRecordFromSQL(mOS, mSQL); //X_PD_BB_Modul

              mHeaderDataSet.First;
              mHeaderDataSet.Edit;
              mHeaderDataSet.FieldByName(cFDPDMProvider).AsString := mPostProvider_ID;
              mHeaderDataSet.Post;
            end;

            if not NxIsEmptyOID(mPostProvider_ID) then
            begin
              //dohledani typu obsahu a doplnkovych sluzeb
              //Dohledání služeb nabízenýh poskytovatelem.
              mSQL := format(cSQLContentType, [QuotedStr(mPostProvider_ID), QuotedStr( UpperCase(mOrderBO.GetFieldValueAsString('X_PD_BB_Services')) )]);
              mIssuedContent_ID := GetFirstRecordFromSQL(mOS, mSQL); //X_PD_BB_Services

              //Dohledá pobočky poskytované v rámci dobravce a jeho služby
              mSQL := format(cSQLBranches, [QuotedStr(mPostProvider_ID), QuotedStr( UpperCase(mOrderBO.GetFieldValueAsString('X_PD_BB_Branches')))  ]);
              mServiceType_ID := GetFirstRecordFromSQL(mOS, mSQL); //X_PD_BB_Branches


              mPackagesDataSet.FieldByName(cFDContentType).AsString := mIssuedContent_ID;
              mPackagesDataSet.FieldByName(cFDPDMServiceType+IntToStr(0)).AsString := mServiceType_ID;
              mPackagesDataSet.Post;
            end;
          end;
        end;
      finally
        mOrderBO.Free;
      end;
      mPackagesDataSet.Next;
    end;
    mPackagesDataSet.First;
    mPackagesDataSet.Edit;


end;

function GetFirstRecordFromSQL(AOS: TNxCustomObjectSpace; ASQL: String): String;
var
  mSQLRes: TStrings;
begin
  Result := '';
  mSQLRes := TStringList.Create;
  try
    AOS.SQLSelect(ASQL, mSQLRes);
    if mSQLRes.Count > 0 then
      Result := mSQLRes.Strings[0];
  finally
    mSQLRes.Free;
  end;
end;

begin
end.