uses 'eu.spedos.importFP.progress', 'eu.spedos.importFP.fce';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Nahrej XML';
  mAction.Hint := 'Nahraje XML faktury přijaté';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportFP;
end;

Procedure ImportFP(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mOpenDLG:TOpenDialog;
 mXMLHead:TNxScriptingXMLWrapper;
 j,m:integer;
 mFPBO, mFPRowBO, mTempBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mFolder:string;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=msite.BaseObjectSpace;
 mTempBO:=mos.CreateObject(Class_Division);
 mfolder:=NxEvalObjectExprAsString(mTempBO,'NxMakeAndGetExportFolder('+Quotedstr('SpedosXML')+')');
 mOpenDlg := TOpenDialog.Create(Sender);
 mopenDLG.Filter :=  'Soubory s daty (*.xml)|*.xml';
 mOpenDLG.InitialDir:=mFolder;
 try
    if mOpenDlg.Execute then begin
      try
        mXMLHead:=TNxScriptingXMLWrapper.create;
        mXMLHead.loadFromFile(mOpenDlg.FileName);
        if not(mXMLHead.getElementAsString('issuedinvoice['+inttostr(0)+'].DestOrgIdentNumber')='27795152') then begin
          NxShowSimpleMessage('Doklad není určen pro firmu SPEDOS Vrata a.s.',msite);
          exit;
        end;
        mFPBO:=mOS.CreateObject(Class_ReceivedInvoice);
        mFPBO.New;
        mFPBO.Prefill;
        mFPBO.SetFieldValueAsString('DocQueue_ID','9100000101');
        mFPBO.SetFieldValueAsString('Firm_ID',GetFirm_ID(mOS,mXMLHead.getElementAsString('issuedinvoice['+inttostr(0)+'].OrgIdentNumber')));
        mFPBO.SetFieldValueAsDateTime('VatDate$Date',mXMLHead.getElementAsDateTime('issuedinvoice['+inttostr(0)+'].vatdate'));
        mFPBO.SetFieldValueAsDateTime('DocDate$Date',mXMLHead.getElementAsDateTime('issuedinvoice['+inttostr(0)+'].vatdate'));
        mFPBO.SetFieldValueAsString('Period_ID',GetPeriod_ID(mOS,mFPBO.GetFieldValueAsDateTime('DocDate$Date')));
        mFPBO.SetFieldValueAsDateTime('VATAdmitDate$DATE',mXMLHead.getElementAsDateTime('issuedinvoice['+inttostr(0)+'].vatdate'));
        mFPBO.SetFieldValueAsDateTime('DueDate$Date',mXMLHead.getElementAsDateTime('issuedinvoice['+inttostr(0)+'].duedate'));
        mFPBO.SetFieldValueAsString('VarSymbol',mXMLHead.getElementAsString('issuedinvoice['+inttostr(0)+'].VarSymbol'));
        mFPBO.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('issuedinvoice['+inttostr(0)+'].ExternalNumber'));
        mFPBO.SetFieldValueAsString('Description',mXMLHead.getElementAsString('issuedinvoice['+inttostr(0)+'].Description'));
        if mXMLHead.getElementAsString('issuedinvoice['+inttostr(0)+'].IsReverseChargeDeclared')='Ano' then mFPBO.SetFieldValueAsBoolean('IsReverseChargeDeclared',True);
        mRows:=mFPBO.GetLoadedCollectionMonikerForFieldCode(mFPBO.GetFieldCode('Rows'));
        j:=mXMLHead.getElementsCountInArray('issuedinvoice['+inttostr(0)+'].rows.row');
        ProgressInit(mSite, 'Import řádků ...', j);
         for m:=0 to j-1 do begin
          if not(mXMLHead.getElementAsFloat('issuedinvoice['+inttostr(0)+'].rows.row['+IntToStr(m)+'].TAmountWithoutVAT')=0) then begin
           mFPRowBO:=mRows.AddNewObject;
           mFPRowBO.prefill;
           mFPRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('issuedinvoice['+inttostr(0)+'].rows.row['+IntToStr(m)+'].text'));
           mFPRowBO.SetFieldValueAsString('VatRate_ID',GetVatRate_ID(mOS,mXMLHead.getElementAsString('issuedinvoice['+inttostr(0)+'].rows.row['+IntToStr(m)+'].vatrate')));
           mFPRowBO.SetFieldValueAsFloat('TAmountWithoutVAT',mXMLHead.getElementAsFloat('issuedinvoice['+inttostr(0)+'].rows.row['+IntToStr(m)+'].TAmountWithoutVAT'));
           mFPRowBO.SetFieldValueAsString('Division_ID','2000000101');
           mFPRowBO.SetFieldValueAsString('BusOrder_ID',GetBusOrder_ID(mOS,mXMLHead.getElementAsString('issuedinvoice['+inttostr(0)+'].rows.row['+IntToStr(m)+'].BusOrder.Code')));
           if AnsiLeftStr(mXMLHead.getElementAsString('issuedinvoice['+inttostr(0)+'].rows.row['+IntToStr(m)+'].BusOrder.Code'),2)='SK' then mFPRowBO.SetFieldValueAsString('ExpenseType_ID','6100000101') else mFPRowBO.SetFieldValueAsString('ExpenseType_ID','7100000101');
           mFPRowBO.SetFieldValueAsString('BusTransaction_ID',GetBusTransaction_ID(mOS,mFPRowBO.GetFieldValueAsString('BusOrder_ID')));
           if mXMLHead.getElementAsString('issuedinvoice['+inttostr(0)+'].rows.row['+IntToStr(m)+'].BT_Code')='48' then begin
            mFPRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('issuedinvoice['+inttostr(0)+'].rows.row[0].text'));
            mFPRowBO.SetFieldValueAsString('ExpenseType_ID','Z100000101')
           end;
           if mFPBO.GetFieldValueAsBoolean('IsReverseChargeDeclared') then begin
            mFPRowBO.SetFieldValueAsInteger('VATMode',mXMLHead.getElementAsInteger('issuedinvoice['+inttostr(0)+'].rows.row['+IntToStr(m)+'].VATMode'));
            mFPRowBO.SetFieldValueAsString('DRCArticle_ID',GetDRCArticle_ID(mOS,mXMLHead.getElementAsString('issuedinvoice['+inttostr(0)+'].rows.row['+IntToStr(m)+'].DRCCode')));
           end;
          end;
           ProgressSetPos(m+1);
         end;
        ProgressDispose();
        mFPBO.save;
      finally
      end;
    end;
 finally
 end;
end;

begin
end.