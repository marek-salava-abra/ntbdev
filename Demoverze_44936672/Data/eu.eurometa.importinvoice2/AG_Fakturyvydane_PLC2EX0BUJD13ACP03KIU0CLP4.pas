uses 'eu.eurometa.importinvoice2.fce';

Const
 cDivision_ID='1000000101';

procedure FormCreate_Hook(Self: TSiteForm);

var
  mAction: TAction;
begin

    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Nahrát ISDOC';
    mAction.Hint := 'Nahraje doklad z ISDOC';
    mAction.Category := 'tabDetail';
    mAction.OnExecute := @ImportISDOC;
  //end;
end;

procedure ImportISDOC(Sender:TComponent);
var
 mSite:TSiteForm;
 mZipFile:TZipFile;
 mZipFileName:String;
 mOpenDlg:TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mXMLHead:TNxScriptingXMLWrapper;
 i,j,k:Integer;
 mStream:TMemoryStream;
 mBO, mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mGRows : TMultiGrid;
 mFileList: TStringList;
 mName, mCode, mPrice_ID:String;
 mPrice:Extended;

begin
 mSite:=TComponent(Sender).DynSite;
 if Assigned(msite) then begin
 mBO:=TComponent(Sender).DynSite.CurrentObject;
 mOS:=mbo.ObjectSpace;
  if osNew in mBO.State then begin
   mRows:=mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
   mOpenDlg := TOpenDialog.Create(TComponent(Sender));
   mOpenDlg.Options:=([ofAllowMultiSelect]);
   mOpenDlg.DefaultExt:='isdocx';
       if mOpenDlg.Execute then begin
        mFileList := Tstringlist.Create;
        mFileList.AddStrings (mOpenDlg.files);
        for k:=0 to mFileList.count-1 do begin
           mStream:=TMemoryStream.Create;
           mXMLHead := TNxScriptingXMLWrapper.Create;
           //mZipFile:=TZipFile.Create;
           //mZipFileName:=mFileList.Strings[k];
           //mZipFile.Open(mZipFileName,zfomReadWrite);
           //mZipFile.ReadByFileIndex(0,mStream);
           //mZipFile.Extract(mZipFileName,'d:\invoice.xml',false);
           //mZipFile.Close;
          // mStream.SaveToFile('d:\test.xml');
           mXMLHead.loadFromFile(mFileList.Strings[k]);
           for i:=0 to mXMLHead.getElementsCountInArray('InvoiceLines')-1 do begin
             for j:=0 to mXMLHead.getElementsCountInArray('InvoiceLines['+inttostr(i)+'].InvoiceLine')-1 do begin
               mRowBO:=mRows.AddNewObject;
               mRowBO.SetFieldValueAsInteger('RowType',2);
               mName:=mXMLHead.getElementAsString('InvoiceLines['+inttostr(i)+'].InvoiceLine['+inttostr(j)+'].Item.Description');
               mCode:=mXMLHead.getElementAsString('InvoiceLines['+inttostr(i)+'].InvoiceLine['+inttostr(j)+'].Item.SecondarySellersItemIdentification.ID');
               //mPrice_ID:=scrGetOrCreatePrice(mOS,mName,mCode);
               mPrice:=strtofloat(NxSearchReplace(mXMLHead.getElementAsString('InvoiceLines['+inttostr(i)+'].InvoiceLine['+inttostr(j)+'].UnitPrice'),'.',',',[srAll]));
               mRowBO.SetFieldValueAsString('Text',mcode+' '+mName);
               mRowBO.SetFieldValueAsFloat('Quantity',mXMLHead.getElementAsFloat('InvoiceLines['+inttostr(i)+'].InvoiceLine['+inttostr(j)+'].InvoicedQuantity'));
               mRowBO.SetFieldValueAsString('Qunit',mXMLHead.getAttributeValue('InvoiceLines['+inttostr(i)+'].InvoiceLine['+inttostr(j)+'].InvoicedQuantity','unitCode'));
               //mRowBO.SetFieldValueAsFloat('VatRate',mXMLHead.getElementAsFloat('InvoiceLines['+inttostr(i)+'].InvoiceLine['+inttostr(j)+'].ClassifiedTaxCategory.Percent'));
               mRowBo.SetFieldValueAsString('VatRate_ID', GetVatRate_ID(mOS,mXMLHead.getElementAsString('InvoiceLines['+inttostr(i)+'].InvoiceLine['+inttostr(j)+'].ClassifiedTaxCategory.Percent')));
               mRowBO.SetFieldValueAsFloat('UnitPrice',mPrice);
               IF mXMLHead.getElementAsFloat('InvoiceLines['+inttostr(i)+'].InvoiceLine['+inttostr(j)+'].ClassifiedTaxCategory.Percent')=15 then mrowbo.SetFieldValueAsString('VatRate_ID','01500X0000');
               IF mXMLHead.getElementAsFloat('InvoiceLines['+inttostr(i)+'].InvoiceLine['+inttostr(j)+'].ClassifiedTaxCategory.Percent')=21 then mrowbo.SetFieldValueAsString('VatRate_ID','02100X0000');
               mRowBO.SetFieldValueAsString('Division_ID', cDivision_ID);
               try
                mRowBO.SetFieldValueAsString('U_DL_Number',mXMLHead.getElementAsString('InvoiceLines['+inttostr(i)+'].InvoiceLine['+inttostr(j)+'].DeliveryNoteReference.ID'));
               Except
               end;
               try
                mRowBO.SetFieldValueAsString('U_OP_Number',mXMLHead.getElementAsString('InvoiceLines['+inttostr(i)+'].InvoiceLine['+inttostr(j)+'].OrderReference.SalesOrderID'));
               Except
               end;



             end;
           end;
        end;
        mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
       if Assigned(mGRows) then mGRows.DataSource.DataSet.Refresh;
       end;
  end;
 end;
end;

begin
end.