uses 'eu.abra.boma.netcentrum.maildoc';

procedure _AfterDwarfSave_Hook(Self: TNxCustomBusinessObject; ADwarfCode: Integer);
var
  mBO: TNxCustomBusinessObject;
  mResults: TStringList;
begin
  if ADwarfCode=2 then begin
    if not(NxIsEmptyOID(Self.GetFieldValueAsString('ReceivedOrder_ID'))) then begin
      mBO:=Self.ObjectSpace.CreateObject(Class_ReceivedOrder);
      try
        mBO.Load(Self.GetFieldValueAsString('ReceivedOrder_ID'),nil);
        if (Self.GetFieldValueAsFloat('NotPaidAmount') <= 0) then begin
          mBO.SetFieldValueAsBoolean('X_ID_Transakce',True);
          mResults:=TStringList.Create;
          try
            Self.ObjectSpace.SQLSelect('SELECT (select DC.Code from DocQueues DC where DC.ID = A.DocQueue_ID) || ''-'' || A.OrdNumber || ''/'' || (select P.Code from Periods P where P.ID = A.Period_ID) FROM Table(PaymentsForDocument(''10'', ' + QuotedStr(Self.OID) + ', 0)) A WHERE (A.DocumentType <> ''13'') and (A.DocumentType <> ''14'') and (A.DocumentType <> ''15'')',mResults);
            mBO.SetFieldValueAsString('X_ID_Transakce_nom',mResults.CommaText);
          finally
            mResults.Free;
          end;
        end;
        if mBO.NeedSave then mBO.Save;
      finally
        mBO.Free;
      end;
    end;
  end;
end;

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  myXML: TNxScriptingXMLWrapper;
  mDirList: TStringList;
  mMon : TNxCustomBusinessMonikerCollection;
  mRow: TNxCustomBusinessObject;
  i: Integer;
begin
  //uložíme po změně stavu na 02
  if (Self.GetFieldValueAsString('Firm_ID')=cFirm_ID) and
     (Self.GetFieldValueAsInteger('X_WEB_Stav_Dokladu')=2) then
  begin
    mDirList := TStringList.Create;
    try
      if FileExists(NxAddSlash(cZalohaPath) + 'ListOf02.tsl') then mDirList.LoadFromFile(NxAddSlash(cZalohaPath) + 'ListOf02.tsl');
      if mDirList.IndexOf(Self.OID) = -1 then mDirList.Append(Self.OID); //přidáme jen když neexistuje
      mDirList.SaveToFile(NxAddSlash(cZalohaPath) + 'ListOf02.tsl');
    finally
      mDirList.Free;
    end;
  end;
  if (Self.GetFieldValueAsString('Firm_ID')=cFirm_ID) and
     (Self.GetFieldValueAsInteger('X_WEB_Stav_Dokladu')=1) then
  begin
    if Length(Self.GetFieldValueAsString('Description')) = 0 then
      Self.SetFieldValueAsString('Description', Self.GetFieldValueAsString('ReceivedOrder_ID.DisplayName'));
    myXML := TNxScriptingXMLWrapper.Create;
    mDirList := TStringList.Create;
    try
      myXML.CreateEmpty(Self.ClassName);
      myXML.setElementAsString('ID',Self.OID);
      myXML.setElementAsString('X_Poznamka_web',Self.GetFieldValueAsString('ReceivedOrder_ID.X_Poznamka_web'));
      myXML.setElementAsBoolean('X_IsPoznamka',Self.GetFieldValueAsBoolean('ReceivedOrder_ID.X_IsPoznamka'));
      if Self.HasField('X_WEB_DCity') then myXML.setElementAsString('X_WEB_DCity',Self.GetFieldValueAsString('X_WEB_DCity'));
      if Self.HasField('X_WEB_DCountry') then myXML.setElementAsString('X_WEB_DCountry',Self.GetFieldValueAsString('X_WEB_DCountry'));
      if Self.HasField('X_WEB_DFirm') then myXML.setElementAsString('X_WEB_DFirm',Self.GetFieldValueAsString('X_WEB_DFirm'));
      if Self.HasField('X_WEB_DFirm_xx') then myXML.setElementAsString('X_WEB_DFirm_xx',Self.GetFieldValueAsString('X_WEB_DFirm_xx'));
      if Self.HasField('X_WEB_DName') then myXML.setElementAsString('X_WEB_DName',Self.GetFieldValueAsString('X_WEB_DName'));
      if Self.HasField('X_WEB_DPostCode') then myXML.setElementAsString('X_WEB_DPostCode',Self.GetFieldValueAsString('X_WEB_DPostCode'));
      if Self.HasField('X_WEB_DStreet') then myXML.setElementAsString('X_WEB_DStreet',Self.GetFieldValueAsString('X_WEB_DStreet'));
      if Self.HasField('X_WEB_Email') then myXML.setElementAsString('X_WEB_Email',Self.GetFieldValueAsString('X_WEB_Email'));
      if Self.HasField('X_WEB_Firm') then myXML.setElementAsString('X_WEB_Firm',Self.GetFieldValueAsString('X_WEB_Firm'));
      if Self.HasField('X_WEB_Firm_xx') then myXML.setElementAsString('X_WEB_Firm_xx',Self.GetFieldValueAsString('X_WEB_Firm_xx'));
      if Self.HasField('X_Web_ICD') then myXML.setElementAsString('X_Web_ICD',Self.GetFieldValueAsString('X_Web_ICD'));
      if Self.HasField('X_WEB_IICity') then myXML.setElementAsString('X_WEB_IICity',Self.GetFieldValueAsString('X_WEB_IICity'));
      if Self.HasField('X_WEB_IICountry') then myXML.setElementAsString('X_WEB_IICountry',Self.GetFieldValueAsString('X_WEB_IICountry'));
      if Self.HasField('X_WEB_IIName') then myXML.setElementAsString('X_WEB_IIName',Self.GetFieldValueAsString('X_WEB_IIName'));
      if Self.HasField('X_WEB_IIPostCode') then myXML.setElementAsString('X_WEB_IIPostCode',Self.GetFieldValueAsString('X_WEB_IIPostCode'));
      if Self.HasField('X_WEB_IIStreet') then myXML.setElementAsString('X_WEB_IIStreet',Self.GetFieldValueAsString('X_WEB_IIStreet'));
      if Self.HasField('X_WEB_OrgIdentNumber') then myXML.setElementAsString('X_WEB_OrgIdentNumber',Self.GetFieldValueAsString('X_WEB_OrgIdentNumber'));
      if Self.HasField('X_WEB_Phone') then myXML.setElementAsString('X_WEB_Phone',Self.GetFieldValueAsString('X_WEB_Phone'));
      if Self.HasField('X_WEB_USER') then myXML.setElementAsString('X_WEB_USER',Self.GetFieldValueAsString('X_WEB_USER'));
      if Self.HasField('X_WEB_VATIdentNumber') then myXML.setElementAsString('X_WEB_VATIdentNumber',Self.GetFieldValueAsString('X_WEB_VATIdentNumber'));
      if Self.HasField('X_ID_transakce_nom') then myXML.setElementAsString('X_ID_transakce_nom',Self.GetFieldValueAsString('X_ID_transakce_nom'));
      if Self.HasField('X_ID_Transakce') then myXML.setElementAsBoolean('X_ID_Transakce',Self.GetFieldValueAsBoolean('X_ID_Transakce'));
      if Self.HasField('X_WEB_Stav_Dokladu') then myXML.setElementAsInteger('X_WEB_Stav_Dokladu',Self.GetFieldValueAsInteger('X_WEB_Stav_Dokladu'));
      if Self.HasField('Description') then myXML.setElementAsString('Description',Self.GetFieldValueAsString('Description'));
      if Self.HasField('VarSymbol') then myXML.setElementAsString('VarSymbol',Self.GetFieldValueAsString('VarSymbol'));
      myXML.setElementAsBoolean('X_Amazon',Self.GetFieldValueAsBoolean('ReceivedOrder_ID.X_Amazon'));
      myXML.setElementAsString('X_AmazonCountry_ID',Self.GetFieldValueAsString('ReceivedOrder_ID.X_AmazonCountry_ID'));
      myXML.setElementAsString('Currency_ID',Self.GetFieldValueAsString('Currency_ID'));
      myXML.setElementAsString('Country_ID',Self.GetFieldValueAsString('Country_ID'));
      mMon := Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('Rows'));
      myXML.addElement('ROWS');
      for i:=0 to mMon.count -1 do
      begin
        mRow := mMon.BusinessObject[mMon.count -1 - i];
        myXML.addElement('ROWS.ROW');
        myXML.setElementAsInteger(format('ROWS.ROW[%d].RowType',[i]),mRow.GetFieldValueAsInteger('RowType'));
        myXML.setElementAsString(format('ROWS.ROW[%d].Text',[i]),mRow.GetFieldValueAsString('Text'));
        myXML.setElementAsString(format('ROWS.ROW[%d].StoreCardName',[i]),mRow.GetFieldValueAsString('StoreCard_ID.DisplayName'));
        myXML.setElementAsFloat(format('ROWS.ROW[%d].Quantity',[i]),mRow.GetFieldValueAsFloat('Quantity'));
        myXML.setElementAsFloat(format('ROWS.ROW[%d].QUnit',[i]),mRow.GetFieldValueAsFloat('QUnit'));
        myXML.setElementAsFloat(format('ROWS.ROW[%d].UnitPrice',[i]),mRow.GetFieldValueAsFloat('UnitPrice'));
        myXML.setElementAsFloat(format('ROWS.ROW[%d].TAmount',[i]),mRow.GetFieldValueAsFloat('TAmount'));
        myXML.setElementAsString(format('ROWS.ROW[%d].BusOrderCode',[i]),mRow.GetFieldValueAsString('BusOrder_ID.Code'));
        {if mRow.GetFieldValueAsInteger('RowType') in [0,1,2,4] then    //text
        begin
          myXML.setElementAsString(format('ROWS.ROW[%d].Text',[i]),mRow.GetFieldValueAsString('Text'));
        end;
        if mRow.GetFieldValueAsInteger('RowType') = 3 then             //název skladové karty
        begin
          myXML.setElementAsString(format('ROWS.ROW[%d].StoreCardName',[i]),mRow.GetFieldValueAsString('StoreCard_ID.DisplayName'));
        end;
        if mRow.GetFieldValueAsInteger('RowType') in [2,3] then    //množství
        begin
          myXML.setElementAsFloat(format('ROWS.ROW[%d].Quantity',[i]),mRow.GetFieldValueAsFloat('Quantity'));
          myXML.setElementAsFloat(format('ROWS.ROW[%d].QUnit',[i]),mRow.GetFieldValueAsFloat('QUnit'));
        end;
        if mRow.GetFieldValueAsInteger('RowType') in [0,1,2] then    //Částka
        begin
          myXML.setElementAsFloat(format('ROWS.ROW[%d].UnitPrice',[i]),mRow.GetFieldValueAsString('UnitPrice'));
        end;
        if mRow.GetFieldValueAsInteger('RowType') in [4] then    //Částka zálohy
        begin
          myXML.setElementAsFloat(format('ROWS.ROW[%d].TAmount',[i]),mRow.GetFieldValueAsString('TAmount'));
        end;}
      end;

//      myXML.setElementAsString('ID', Self.GetFieldValueAsString('Firm_ID')
      if FileExists(NxAddSlash(cZalohaPath) + 'ListOfNew.tsl') then mDirList.LoadFromFile(NxAddSlash(cZalohaPath) + 'ListOfNew.tsl');
      if mDirList.IndexOf(Self.OID + '.XML') = -1 then mDirList.Append(Self.OID + '.XML'); //přidáme jen když neexistuje
      myXML.saveToFile(NxAddSlash(cZalohaPath) + Self.OID + '.XML');
      mDirList.SaveToFile(NxAddSlash(cZalohaPath) + 'ListOfNew.tsl');
    finally
      myXML.Free;
      mDirList.Free;
    end;
  end;

end;

begin
end.