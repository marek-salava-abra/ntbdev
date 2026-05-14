uses 'eu.spedos.importov.fce';

procedure InitSite_Hook(Self: TSiteForm);

var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.Name := 'ImportOV';
  mAction.Caption := 'Import OV ND';
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Category := 'tablist';
  mAction.Hint := 'Naimportuje objednávku náhradních dílů';
  mAction.OnExecute := @ImportOV;

end;

Procedure importOV(sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg:TOpenDialog;
 mXMLHead:TNxScriptingXMLWrapper;
 i,j, k:integer;
 mOrderBO, mOrderRowBO, mStoreCardBO, mBusOrderBO, mUnitBO:TNxCustomBusinessObject;
 mRows, mUnits:TNxCustomBusinessMonikerCollection;
 mOS:TNxCustomObjectSpace;
 mFirm_ID, mStoreCard_ID, mBusOrder_ID, mOrder_ID, mStoreCardCategory_ID:String;
 mStoreCardList:TStringList;
 mPrice:Extended;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 mOpenDlg := TOpenDialog.Create(Sender);
 mOpenDlg.InitialDir:='\\192.168.0.80\abradata\exchange\ObjednavkyND\Vrata\';
 mOpenDlg.Filter:='XML objednávky|*.xml';
 mOpenDlg.Options :=[fdoFileMustExist];
 if mOpenDlg.Execute then begin
   try
     mXMLHead := TNxScriptingXMLWrapper.Create;
     mXMLHead.loadFromFile(mOpenDlg.FileName);
     for i:=0 to mXMLHead.getElementsCountInArray('order')-1 do begin
      mStoreCardList:=TStringList.create;
      mFirm_ID:=GetFirm_ID(mOS,mXMLHead.getElementAsString('order['+inttostr(i)+'].OwnOrgIdentNumber'));
      for j:=0 to  mXMLHead.getElementsCountInArray('order['+inttostr(i)+'].rows.row')-1 do begin
      if not(NxIsBlank(mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].StoreCard.Code'))) then begin
         mStoreCard_ID:=GetStoreCard2_id(mOS,mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].StoreCard.Code'),mFirm_ID);
         if NxIsEmptyOID(mStoreCard_ID) then mStoreCardList.Add(mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].StoreCard.Code')+'  '+mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].StoreCard.name'));
       end;
      end;
      if mStoreCardList.count>0 then begin
       NxShowSimpleMessage('Nenalezené položky dle externího kódu a IČ:'+#13#10+#13#10+mStoreCardList.Text+#13#10+#13#10+'Ukončuji.',mSite);
       exit;
      end;
      mOrderBO:=mOS.CreateObject(Class_ReceivedOrder);
      mOrderBO.New;
      mOrderBO.Prefill;
      mOrderBO.SetFieldValueAsString('DocQueue_ID','1LA0000101');
      mOrderBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
      mOrderBo.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('order['+inttostr(i)+'].AbraName'));
      mOrderBo.SetFieldValueAsString('U_SerialNumber',mXMLHead.getElementAsString('order['+inttostr(i)+'].SerialNumber'));
      try
       if UpperCase(mXMLHead.getElementAsString('order['+inttostr(i)+'].Reclamation'))='ANO' then mOrderBO.SetFieldValueAsBoolean('X_Reklamace',true);
       if UpperCase(mXMLHead.getElementAsString('order['+inttostr(i)+'].Reclamation'))='ÁNO' then mOrderBO.SetFieldValueAsBoolean('X_Reklamace',true);
      except

      end;
      mOrderBO.SetFieldValueAsDateTime('X_ExpDate', NxIBStrToFloat(mXMLHead.getElementAsString('order['+inttostr(i)+'].CreatedAt')));
      if mOrderBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='31708587' then begin
        morderbo.SetFieldValueAsString('Currency_ID','0000EUR000');
        mOrderBo.SetFieldValueAsInteger('TradeType',2);
        mOrderBO.SetFieldValueAsString('Country_ID','00000SK000');
        mOrderBO.SetFieldValueAsstring('IntrastatDeliveryTerm_ID','3001000000'); ;
        mOrderBO.SetFieldValueAsstring('IntrastatTransactionType_ID','1001000000');
        mOrderBO.SetFieldValueAsstring('IntrastatTransportationType_ID','2000000000');
        //mOrderBO.SetFieldValueAsInteger('TotalRounding',-33554175);
      end;
      mRows:=mOrderBO.GetLoadedCollectionMonikerForFieldCode(mOrderBO.GetFieldCode('Rows'));
        for j:=0 to  mXMLHead.getElementsCountInArray('order['+inttostr(i)+'].rows.row')-1 do begin
          mOrderRowBO:=mRows.AddNewObject;
          mOrderRowBO.Prefill;
          mOrderRowBO.SetFieldValueAsInteger('RowType',StrToInt(mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].RowType')));
          mOrderRowBO.SetFieldValueAsString('X_ExtRow_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].AbraIORow_ID'));
          if mOrderRowBO.GetFieldValueAsInteger('RowType')=0 then begin
           mOrderRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].text'));
          end;
          if mOrderRowBO.GetFieldValueAsInteger('RowType')=1 then begin
           mOrderRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].text'));
           mOrderRowBO.SetFieldValueAsString('VatRate_ID','02100X0000');
           if mOrderBO.GetFieldValueAsInteger('tradetype')=2 then mOrderRowBO.SetFieldValueAsString('VatRate_ID','00000X0000');
          end;
          if mOrderRowBO.GetFieldValueAsInteger('RowType')=2 then begin
           mOrderRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].text'));
           mOrderRowBo.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].Quantity')));
           mOrderRowBo.SetFieldValueAsString('QUnit',mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].QUnit'));
           mOrderRowBO.SetFieldValueAsString('VatRate_ID','02100X0000');
          end;
          if mOrderRowBO.GetFieldValueAsInteger('RowType')=3 then begin
           mOrderRowBO.SetFieldValueAsString('Store_ID','4A00000101');
           if mOrderBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='05665817' then
            mOrderRowBO.SetFieldValueAsString('Store_ID','1B00000101');            // změna dle helpdesk 11371 09.09.2024
           mStoreCard_ID:=GetStoreCard2_id(mOS,mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].StoreCard.Code'),mFirm_ID);
          { if NxIsEmptyOID(mStoreCard_ID) then begin
             mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
             mStoreCardBO.New;
             mStoreCardBO.Prefill;
             mStoreCardBO.SetFieldValueAsString('Code','IMPORT');
             mStoreCardBO.SetFieldValueAsString('Name',mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].StoreCard.Name'));
             mStoreCardBO.SetFieldValueAsString('X_RailCode',mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].StoreCard.Code'));
             mStoreCardBO.SetFieldValueAsInteger('Category',StrToInt(mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].StoreCard.Category')));
             if mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].StoreCard.IsProduct')='Ano' then mStoreCardBO.SetFieldValueAsBoolean('IsProduct',True);
             mStoreCardBO.SetFieldValueAsString('StoreCardCategory_ID',GetStoreCardCategory_ID(mOS,mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].StoreCard.StoreCardCategoryCode')));
             mStoreCardBo.SetFieldValueAsString('VatRate_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].StoreCard.VatRate_ID'));
             mUnits:=mStoreCardBO.GetLoadedCollectionMonikerForFieldCode(mStoreCardBO.GetFieldCode('StoreUnits'));
             mUnitBO:=mUnits.BusinessObject[0];
             mUnitBO.SetFieldValueAsString('Code',mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].StoreCard.MainUnitCode'));
             mStoreCardBo.SetFieldValueAsString('MainUnitCode',mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].StoreCard.MainUnitCode'));
             //mStoreCardBO.SetFieldValueAsString('Specification',mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].StoreCard.Specification'));
             //mStoreCardBO.SetFieldValueAsString('Specification2',mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].StoreCard.Specification2'));
             mStoreCardBO.Save;
             mStoreCard_ID:=mStoreCardBO.OID;
             mStoreCardBO.Free;
           end; }
           mOrderRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
           if not(NxIsEmptyOID(mOrderRowBO.GetFieldValueAsString('StoreCard_ID.X_Store_ID'))) then mOrderRowBO.SetFieldValueAsString('Store_ID',mOrderRowBO.GetFieldValueAsString('StoreCard_ID.X_Store_ID'));
           mOrderRowBo.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].Quantity')));
          end;
           mBusOrder_ID:=GetBusOrder_ID(mOS,mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].BusOrder.Code'));
           if NxIsEmptyOID(mBusOrder_ID) then begin
             mBusOrderBO:=mOS.CreateObject(Class_BusOrder);
             mBusOrderBO.New;
             mBusOrderBO.Prefill;
             mBusOrderBO.SetFieldValueAsString('Code',mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].BusOrder.Code'));
             mBusOrderBO.SetFieldValueAsString('Name',mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].BusOrder.Name'));
             mBusOrderBO.SetFieldValueAsString('Firm_ID', GetFirm_ID(mOS,mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].BusOrder.Firm_OrgIdentNumber')));
             mBusOrderBO.Save;
             mBusOrder_ID:=mBusOrderBO.OID;
             mBusOrderBO.free;
           end;
          mOrderRowBO.SetFieldValueAsString('BusOrder_ID',mBusOrder_ID);
          mOrderRowBO.SetFieldValueAsString('BusTransaction_ID',mOS.SQLSelectFirstAsString(format('select id from bustransactions where code=''%s'' and hidden=''N'' and closingdate$date=0 ',[mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].BusTransactionCode')]),''));
          if mOrderBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='31708587' then mOrderRowBO.SetFieldValueAsString('Division_ID','1100000101') else
          mOrderRowBO.SetFieldValueAsString('Division_ID','D000000101');
          mOrderRowBO.SetFieldValueAsString('X_Description',mXMLHead.getElementAsString('order['+inttostr(i)+'].rows.row['+IntToStr(j)+'].Description'));
          if mOrderBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='31708587' then begin
            mPrice:=(NxEvalObjectExprAsFloatDef(mOrderBO,'NxGetStoreCardUnitPriceDef('+Quotedstr(mOrderBO.GetFieldValueAsString('Firm_ID'))+', '+Quotedstr('')+', ' + QuotedStr(mStoreCard_ID) + ','+Quotedstr('4000000101')+', '+Quotedstr(mOrderRowBO.GetFieldValueAsString('StoreCard_ID.MainUnitCode'))+',false,'+QuotedStr('0000EUR000')+','+inttostr(trunc(Date))+')',0));
            mOrderRowBO.SetFieldValueAsFloat('UnitPrice',mPrice);
            mOrderRowBO.SetFieldValueAsBoolean('ToESL',True);
            mOrderROwBO.SetFieldValueAsString('ESLIndicator_ID','1000000000');
          end;
        end;
      mOrderBO.Save;
      mOrder_ID:=mOrderBO.OID;
      mOrderBO.free;
     end;
   finally
     TDynSiteForm(mSite).RefreshData;
     TDynSiteForm(mSite).ActiveDataSet.SeekID(mOrder_ID);
   end;
   NxCopyFile(mOpenDlg.FileName,NxSearchReplace(mOpenDlg.FileName,'\\192.168.0.80\abradata\exchange\ObjednavkyND\Vrata','\\192.168.0.80\abradata\exchange\ObjednavkyND\Vrata\Archiv',[srAll]));
   DeleteFile(mOpenDlg.FileName);
 end;
end;

function RGBToColor(const R, G, B: Byte): Integer;
begin
	  Result := R or (G shl 8) or (B shl 16);
end;

//barva řádku
procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mGrid: TDBGrid;
begin
  mGrid := TDBGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdList'));
  if Assigned(mGrid) then begin
    mGrid.OnGetCellParams := @OnGetCellParams;
  end;
end;

procedure OnGetCellParams(Sender: TObject; Field: TField; AFont: TFont; var Background: TColor; Highlight: Boolean);
var
  mGrid: TDBGrid;
  mSite: TDynSiteForm;
  mBO: TNxCustomBusinessObject;
begin
  if Highlight then exit;
  mGrid := TDBGrid(Sender);
  mSite := TDynSiteForm(mGrid.Owner);
  mbo:=TDynSiteForm(msite).CurrentObject;
  if Assigned(mBO) then begin
    if mbo.GetFieldValueAsBoolean('X_Reklamace')  then Background:= RGBToColor(51, 255, 212);
  end;
end;

begin
end.