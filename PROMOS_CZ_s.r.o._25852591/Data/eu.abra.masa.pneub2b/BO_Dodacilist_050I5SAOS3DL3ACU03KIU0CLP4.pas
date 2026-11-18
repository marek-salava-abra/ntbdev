uses '.const';

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mXMLResponse, mXMLPostResponse:TNxScriptingXMLWrapper;
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mRowBO:TNxCustomBusinessObject;
 mPrintList:TStringList;
 mReportBytes: TBytes;
begin
  if (AnsiLeftStr(self.GetFieldValueAsString('X_B2BOrigin'),2)='82') and (self.GetFieldValueAsString('PMState_ID')='SDDEF00000') then begin
    try
      mXMLResponse:=TNxScriptingXMLWrapper.Create;
      mXMLResponse.CreateEmpty('Orders');
      mXMLResponse.setAttributeValue('Orders','xmlns','http://pneub2b.eu/SupplierOrdersResponse.xsd');
      mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
      for i:=0 to mrows.count-1 do begin
        mRowBO:=mRows.BusinessObject[i];
        if not(NxIsBlank(mRowBO.GetFieldValueAsString('U_B2BID'))) then begin
         mXMLResponse.AddElement('OrderItem');
         mXMLResponse.setAttributeValue('OrderItem[' + IntToStr(i) + ']','ID', mRowBO.GetFieldValueAsString('U_B2BID'));
         mXMLResponse.setAttributeValue('OrderItem[' + IntToStr(i) + ']','Amount', NxFloatToIBStr(mRowBO.GetFieldValueAsFloat('Quantity')));
         mXMLResponse.setAttributeValue('OrderItem[' + IntToStr(i) + ']','State', 'Done');
        end;
      end;
      //mXMLResponse.saveToFile('C:\Users\abraadmin\Documents\ABRA_EXPORT\xml\BOD.xml');
      mXMLPostResponse:=API_POST(cURL+'orders_change_item_states',self.GetFieldValueAsString('X_B2BOrigin'),'KingTonyDodavatel.',mXMLResponse, self.ObjectSpace);
    except

    end;
  end;
end;

begin
end.