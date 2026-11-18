uses
  'eu.abra.PostProviders.extras.Cemat.uconst';


{GetAddress}

function GetAddress(AReportHelper:TNxQRScriptHelper;AIssuedOrderID:String;FieldName:String):String;
var mBO: TNxCustomBusinessObject;
begin
  Result := '';
  try
    try
      mBO := AReportHelper.ObjectSpace.CreateObject(Class_ReceivedOrder);
      mBO.Load(AIssuedOrderID,nil);
      if UpperCase( FieldName)  = UpperCase( 'U_name') then
        Result :=  Trim(mBO.GetFieldValueAsString('U_name'));
      if UpperCase( FieldName) = UpperCase('U_street') then
        Result :=  Trim(mBO.GetFieldValueAsString('U_street'));
      if UpperCase( FieldName) = UpperCase('U_city_postcode') then
        Result :=  Trim(mBO.GetFieldValueAsString('U_city_postcode'));
      if UpperCase( FieldName) = UpperCase('U_Postcode') then
        Result :=  Trim(mBO.GetFieldValueAsString('U_Postcode'));
      if UpperCase( FieldName) = UpperCase('U_CountryCode') then
        Result :=  Trim(mBO.GetFieldValueAsString('U_CountryCode.Code'));
      if UpperCase( FieldName) = UpperCase('U_contact') then
        Result :=  Trim(mBO.GetFieldValueAsString('U_contact'));
      if UpperCase( FieldName) = UpperCase('U_email_zakazka') then
        Result :=  Trim(mBO.GetFieldValueAsString('U_email_zakazka'));
      if UpperCase( FieldName) = UpperCase('U_phone') then
        Result :=  Trim(mBO.GetFieldValueAsString('U_phone'));


    except
      Result := '';
    end;
  finally
    mBO.Free;
  end;
end;

{GetAddress}

function HaveFullAddress(AReportHelper:TNxQRScriptHelper;AIssuedOrderID:String): Boolean;
var mBO: TNxCustomBusinessObject;
begin
  Result := True;
  try
    try
      mBO := AReportHelper.ObjectSpace.CreateObject(Class_ReceivedOrder);
      mBO.Load(AIssuedOrderID,nil);
      if Trim(mBO.GetFieldValueAsString('U_street')) = '' then
        Result := False;
      if Trim(mBO.GetFieldValueAsString('U_city_postcode')) = '' then
        Result := False;
      if Trim(mBO.GetFieldValueAsString('U_Postcode')) = '' then
        Result := False;

    except
      Result := false;
    end;
  finally
    mBO.Free;
  end;

end;





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

//POZOR - Pro správné fungování je třeba naplnit definovatelné položky.

procedure GetDataFromDoc(AOSInt: integer; APackagesDataSetInt: integer; AHeaderDataSetInt: integer);
const
  cSQLProvider = 'select a.ID from PDMPostProviders a where a.X_PD_IsLicensed = %s and a.X_PD_Driver = %s and upper(a.Code) = %s';
  cSQLContentType = 'select b.ID from PDMPostProviders2 a join PDMIssuedContentTypes b on b.ID = a.IssuedContentType_ID where a.parent_ID = %s and upper(b.Code) = %s';
  cSQLBranches = 'select a.ID from PDMServiceTypes a where a.X_PD_PostProvider_ID = %s and a.hidden = ''N'' and a.x_pd_externid = %s and a.x_pd_externid <> '''' ';
  cSQLStoreID = 'select a.ID from Stores a where a.code = ''000''';
  cSQLUserStoreID = 'select a.X_Store_ID from SecurityUsers a where a.id = ''%s'' ';
  cDivisionID = '1000000101';
  cDocQueueID = '8M20000101';
  cStoreID = '2000000101';
  cMU_EUpal = 'VII0000101';
var
  mOS: TNxCustomObjectSpace;
  mPackagesDataSet, mHeaderDataSet: TDataSet;
  mSQL, mIssuedContent_ID, mServiceType_ID, mServiceType_ID2, mDoc_ID, mPostProvider_ID, mDocType: string;
  mDocBO : TNxCustomBusinessObject;
  mStore :String;

  function GetWeight(ADataSet: TDataSet):Extended;
  var mBO : TNxCustomBusinessObject;
  begin
    try
      Result := 0;
      if ADataSet.FieldByName(cFDDocumentType).AsString = 'RO' then
      begin
        mBO := ADataSet.Site.BaseObjectSpace.CreateObject(Class_ReceivedOrder);
        mBO.Load( ADataSet.FieldByName(cFDID).AsString, nil);
        OutputDebugString('GetWeight: '+FloatToStr( mBO.GetFieldValueAsFloat('Weight') ));
        if mBO.GetFieldValueAsInteger('WeightUnit') = 0 then
          Result := mBO.GetFieldValueAsFloat('Weight') / 1000
        else
          Result := mBO.GetFieldValueAsFloat('Weight');
      end;
    finally
      mBO.Free;
    end;
  end;

  procedure AddPackageWeight(Sender: TField);
  begin
    case Sender.AsString of
      cMU_EUpal:
      begin
        if  Sender.DataSet.FieldByName(cFDWeight+IntToStr(0)).AsFloat > 0 then
          Sender.DataSet.FieldByName(cFDWeight+IntToStr(0)).AsFloat := GetWeight(Sender.DataSet) + (  Sender.DataSet.FieldByName(cFDCountMUnit+IntToStr(0)).AsInteger * 15 );   //EUROPALETA
      end;
    end;
  end;

  procedure AddPackageWeightAfterSetQuanty(Sender: TField);
  begin
    case Sender.DataSet.FieldByName(cFDManipulationUnit+IntToStr(0)).AsString of
      cMU_EUpal:
      begin
        if Sender.AsInteger > 0 then
        begin
          if  Sender.DataSet.FieldByName(cFDWeight+IntToStr(0)).AsFloat > 0 then
            Sender.DataSet.FieldByName(cFDWeight+IntToStr(0)).AsFloat := GetWeight(Sender.DataSet) + (  Sender.DataSet.FieldByName(cFDCountMUnit+IntToStr(0)).AsInteger * 15 );   //EUROPALETA
        end;
      end;
    end;
  end;

  procedure AddPackageWeightAfterSet(Sender: TField);
  begin
    case Sender.DataSet.FieldByName(cFDManipulationUnit+IntToStr(0)).AsString of
      cMU_EUpal:
      begin
        if Sender.AsFloat > 0 then
          Sender.AsFloat := Sender.AsFloat +  (  Sender.DataSet.FieldByName(cFDCountMUnit+IntToStr(0)).AsInteger * 15 );   //EUROPALETA
      end;
    end;
  end;

begin

  try

    OutputDebugString('postprovider:Star prefill GetDataFromDoc');
    mOS := TNxCustomObjectSpace(IntToObj(AOSInt));
    mPackagesDataSet := TDataSet(IntToObj(APackagesDataSetInt));
    mHeaderDataSet := TDataSet(IntToObj(AHeaderDataSetInt));
    mPackagesDataSet.First;
    while not mPackagesDataSet.Eof do
    begin
      mPackagesDataSet.Edit;
      mDoc_ID := '';
      mServiceType_ID := '';
      mIssuedContent_ID := '';
      mServiceType_ID2 := '';
      mDocType := mPackagesDataSet.FieldByName(cFDDocumentType).AsString;

      try
        if (mDocType = 'RO') or (mDocType = '03') then
        begin
          case mDocType of
            'RO': mDocBO := mOS.CreateObject(Class_ReceivedOrder);
            '03': mDocBO := mOS.CreateObject(Class_IssuedInvoice);
          end;

          mDoc_ID := mPackagesDataSet.FieldByName(cFDID).AsString;
          if not NxIsEmptyOID(mDoc_ID) then
          begin

            mPackagesDataSet.Edit;

            mDocBO.Load(mDoc_ID,nil);
            mPostProvider_ID := '';
            //dopravce podle dokladu
            if mPostProvider_ID = '' then
            begin
              mPostProvider_ID := mDocBO.GetFieldValueAsString('TransportationType_ID.X_Postprovider_ID');//GetFirstRecordFromSQL(mOS, mSQL); //X_PD_BB_Modul
              mHeaderDataSet.First;
              mHeaderDataSet.Edit;
              if not CFxOID.IsEmptyOrFull(mPostProvider_ID) then
                mHeaderDataSet.FieldByName(cFDPDMProvider).AsString := mPostProvider_ID;
              mHeaderDataSet.FieldByName(cFDDocQueue).AsString := cDocQueueID;

              if mDocBO.CLSID = Class_ReceivedOrder then
              begin
                mStore := GetFirstRecordFromSQL(mOS, 'select first 1 B.Store_ID from receivedOrders A join ReceivedOrders2 B on b.parent_id = a.id where B.RowType = 3 and A.ID = ' +QuotedStr(mDocBO.OID)+ '');
                if not CFxOID.IsEmptyOrFull(mStore) then
                begin
                  mHeaderDataSet.FieldByName(cFDStore).AsString := mStore;
                end
                else
                begin
                  //z uživatele
                  mStore := GetFirstRecordFromSQL(mOS, Format(cSQLUserStoreID,[NxGetActualUserID(mDocBO.ObjectSpace)]) );
                  if not CFxOID.IsEmptyOrFull(mStore) then
                    mHeaderDataSet.FieldByName(cFDStore).AsString := mStore;
                end;

              end
              else
              begin
                mHeaderDataSet.FieldByName(cFDStore).AsString := cStoreID;
              end;

              mHeaderDataSet.FieldByName(cFDBankAccount).AsString := mDocBO.GetFieldValueAsString('BankAccount_ID');
              mHeaderDataSet.FieldByName(cFDDivision).AsString := cDivisionID;
              mHeaderDataSet.Post;
              mHeaderDataSet.Edit;
            end;

            if not NxIsEmptyOID(mPostProvider_ID) then
            begin
              mServiceType_ID := '';
              mIssuedContent_ID := mDocBO.GetFieldValueAsString('TransportationType_ID.X_Service_ID');//GetFirstRecordFromSQL(mOS, mSQL); //X_PD_BB_Modul
              if mDocBO.HasField('X_PD_BB_Branches') then
                if ( mDocBO.GetFieldValueAsString('X_PD_BB_Branches') <> '' )  then
                begin
                  mSQL := format(cSQLBranches, [QuotedStr(mPostProvider_ID), QuotedStr( UpperCase(mDocBO.GetFieldValueAsString('X_PD_BB_Branches')))  ]);
                  mServiceType_ID := GetFirstRecordFromSQL(mOS, mSQL); //X_PD_BB_Branches
                end;

              if mServiceType_ID = '' then
              if (Trim(mDocBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber')) <> '') and (mDocBO.GetFieldValueAsString('TransportationType_ID.X_Postprovider_ID.code') = 'CP' ) then
              begin
                {
                case UpperCase(mDocBO.GetFieldValueAsString('TransportationType_ID.X_Postprovider_ID.code')) of
                  'PPL':begin
                    if mDocBO.GetFieldValueAsString('TransportationType_ID.X_Service_ID') = '4000000101' then
                      mIssuedContent_ID := '3000000101';
                  end;
                  'GEIS':begin
                    if mDocBO.GetFieldValueAsString('TransportationType_ID.X_Service_ID') = 'H000000101' then
                      mIssuedContent_ID := 'G000000101';
                  end;
                end;}
              end;
              mPackagesDataSet.FieldByName(cFDContentType).AsString := mIssuedContent_ID;
              mPackagesDataSet.FieldByName(cFDPDMServiceType+IntToStr(0)).AsString := mServiceType_ID;

              if mDocBO.HasField('Weight') then
                mPackagesDataSet.FieldByName(cFDWeight+IntToStr(0)).AsFloat := mDocBO.GetFieldValueAsFloat('Weight');

              //Manipulační jednotky
              if UpperCase( mDocBO.GetFieldValueAsString('TransportationType_ID.X_Postprovider_ID.code')) = 'GEIS' then
              begin
                mPackagesDataSet.FieldByName(cFDCountMUnit+IntToStr(0)).AsInteger := 1;
                mPackagesDataSet.FieldByName(cFDManipulationUnit+IntToStr(0)).AsString := cMU_EUpal;
              end;

              if UpperCase( mDocBO.GetFieldValueAsString('TransportationType_ID.X_Postprovider_ID.code')) = 'DSV' then
              begin
                mPackagesDataSet.FieldByName(cFDPickupDate).AsDateTime := Today();
                mPackagesDataSet.FieldByName(cFDDeliveryDate).AsDateTime := IncDay(Today(),1);

                mPackagesDataSet.FieldByName(cFDPickupTimeFrom).AsDateTime := now();
                mPackagesDataSet.FieldByName(cFDPickupTimeTo).AsDateTime := now();
                mPackagesDataSet.FieldByName(cFDDeliveryTimeFrom).AsDateTime := now();
                mPackagesDataSet.FieldByName(cFDDeliveryTimeTo).AsDateTime := now();
                mPackagesDataSet.FieldByName(cFDContent).AsString := 'pneu';
              end;




              //HMOTNOST Z DOKLADU
              mPackagesDataSet.FieldByName(cFDManipulationUnit+IntToStr(0)).OnChange := @AddPackageWeight;
              //mPackagesDataSet.FieldByName(cFDWeight+IntToStr(0)).OnChange := @AddPackageWeightAfterSet;
              mPackagesDataSet.FieldByName(cFDCountMUnit+IntToStr(0)).OnChange := @AddPackageWeightAfterSetQuanty;

              if mDocBO.GetFieldValueAsInteger('WeightUnit') = 0 then
              begin
                mPackagesDataSet.FieldByName(cFDWeight+IntToStr(0)).AsFloat := mDocBO.GetFieldValueAsFloat('Weight') / 1000;
                case mPackagesDataSet.FieldByName(cFDManipulationUnit+IntToStr(0)).AsString of
                  cMU_EUpal:
                  begin
                    if  mPackagesDataSet.FieldByName(cFDWeight+IntToStr(0)).AsFloat > 0 then
                      mPackagesDataSet.FieldByName(cFDWeight+IntToStr(0)).AsFloat := mPackagesDataSet.FieldByName(cFDWeight+IntToStr(0)).AsFloat + (  1 * 15 );   //EUROPALETA
                  end;
                end;
              end
              else
              begin
                mPackagesDataSet.FieldByName(cFDWeight+IntToStr(0)).AsFloat := mDocBO.GetFieldValueAsFloat('Weight');
                case mPackagesDataSet.FieldByName(cFDManipulationUnit+IntToStr(0)).AsString of
                  cMU_EUpal:
                  begin
                    if  mPackagesDataSet.FieldByName(cFDWeight+IntToStr(0)).AsFloat > 0 then
                      mPackagesDataSet.FieldByName(cFDWeight+IntToStr(0)).AsFloat := mPackagesDataSet.FieldByName(cFDWeight+IntToStr(0)).AsFloat + (  1 * 15 );   //EUROPALETA
                  end;
                end;
              end;
              mPackagesDataSet.FieldByName(cFDWeightUnit+IntToStr(0)).AsInteger := 1;

              if mPackagesDataSet.FieldByName(cFDWeight+IntToStr(0)).AsFloat = 0 then
                mPackagesDataSet.FieldByName(cFDWeight+IntToStr(0)).AsFloat := 0;

            end;


            //FV
            if mDocBO.HasField('ExternalNumber') and ( mDocBO.GetFieldValueAsString('ExternalNumber') <> '' ) then
            begin
              mPackagesDataSet.FieldByName(cFDVarSymbol).AsString := NxLeft( mDocBO.GetFieldValueAsString('ExternalNumber'), 10);
            end;

            if mDocBO.HasField('U_note_driver') then
            begin

              if mDocBO.GetFieldValueAsString('ExternalNumber') <> '' then
                mPackagesDataSet.FieldByName(cFDNoteForDriver).AsString :=  mDocBO.GetFieldValueAsString('ExternalNumber')+'; '+  mDocBO.GetFieldValueAsString('U_note_driver')
              else
                mPackagesDataSet.FieldByName(cFDNoteForDriver).AsString :=  mDocBO.GetFieldValueAsString('U_note_driver');
            end else
            begin
              mPackagesDataSet.FieldByName(cFDNoteForDriver).AsString := mDocBO.GetFieldValueAsString('ExternalNumber') + '; ';
            end;



            //Dobírka
            if mDocBO.HasField('PaymentType_ID') then
              if mDocBO.GetFieldValueAsInteger('PaymentType_ID.PaymentKind') = 3 then
                mPackagesDataSet.FieldByName(cFDCashOnDelivery).AsFloat:= mDocBO.GetFieldValueAsFloat('Amount');

            mPackagesDataSet.FieldByName(cFDAmount).AsFloat:= mDocBO.GetFieldValueAsFloat('Amount');

            mPackagesDataSet.Post;

          end;
        end;
      finally
        mDocBO.Free;
      end;
      mPackagesDataSet.Next;
    end;
    mPackagesDataSet.First;
    mPackagesDataSet.Edit;
    mHeaderDataSet.Post;

  except
    ShowMessage('Nastala vyjímka během předvyplnění.' + ExceptionMessage);
  end;


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