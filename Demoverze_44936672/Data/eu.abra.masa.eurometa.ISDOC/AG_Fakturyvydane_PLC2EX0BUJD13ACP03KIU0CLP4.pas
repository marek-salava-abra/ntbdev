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
 mControl: TControl;
 mDataset: TNxRowsObjectDataSet;
begin
 mSite:=TComponent(Sender).DynSite;
 //tady je komentář, protože se mi nechce psát znovu celý popis, ale v podstatě se kontroluje, jestli je formulář v editaci, pokud ne, tak se nedá načíst ISDOC, pak se otevře dialog pro výběr souboru, načte se XML a projde se cyklem přes položky a vloží do gridu jako nové řádky. Na konci se refreshne dataset, aby se změny projevily.
 if Assigned(msite) then begin
  mBO:=TDynSiteForm(msite).CurrentObject;
  mOS:=mBO.ObjectSpace;
    if not(TDynSiteForm(mSite).Edit) then begin
        NxShowSimpleMessage('Nejste ve stavu editace, řádky nepůjde vložit.',mSite);
        exit;
    end;
    mOpenDlg := TOpenDialog.Create(TComponent(Sender));
    mOpenDlg.Options:=([ofAllowMultiSelect]);
    mOpenDlg.DefaultExt:='isdoc';
    if mOpenDlg.Execute then begin
       mXMLHead := TNxScriptingXMLWrapper.Create;
       mXMLHead.loadFromFile(mOpenDlg.FileName);
       mControl:= mSite.FindChildControl('tabRows.grdRows');
       mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
           for i:=0 to mXMLHead.getElementsCountInArray('InvoiceLines')-1 do begin
             for j:=0 to mXMLHead.getElementsCountInArray('InvoiceLines['+inttostr(i)+'].InvoiceLine')-1 do begin
               mRowBO:=mDataset.CreateBusinessObject;
               mRowBO.Prefill;
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
        TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
        mDataset.RefreshAndRestoreLastSelectedItem;
        mDataSet.EnableControls;
    end;
 end;
end;

function GetVatRate_ID(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM Vatrates where tariff=%s';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='01500X0000';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

begin
end.