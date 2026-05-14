procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  i : integer;
begin

  {mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Částečné vyskladnění';
  mAction.ShortCut := TextToShortCut('Ctrl+D'); //16450;
  mAction.Hint := 'rozpadne objednávku na dvě ';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateSplOrder;
    //mAction.OnUpdate := @ImportOnUpdate;}

  {mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Částečný DL';
  mAction.ShortCut := TextToShortCut('Ctrl+D'); //16450;
  mAction.Hint := 'Vytvoří DL na skladové položky';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateDL;   }

end;

procedure _AfterSave_PostHook(Self: TDynSiteForm);
var
 mCurrBO, mTextBO, mBO:TNxCustomBusinessObject;
 mBody, mSubject, mAccount_ID, mTO:string;
 mOS:TNxCustomObjectSpace;
begin
 {mCurrBO:=TDynSiteForm(Self).CurrentObject;
 if (mCurrBO.GetFieldValueAsString('DocQueue_ID.Code')='OPES') and
    (mCurrBO.GetFieldValueAsString('U_OrderState_ID.Code')='STOBJ05') and
    (mCurrBO.GetFieldValueAsString('TransportationType_ID.Code')='O1') then begin
    if NxMessageBox('Dotaz','Přjete si odeslat info o osobním odběru na email '+mCurrBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email')+'?' , mdConfirm, mdbYesNo, 0, 0, False, Self)= mrYes then begin
      mOS:=mCurrBO.ObjectSpace;
      mTextBO:=mOS.CreateObject('PKVPDHXNS3L4DE0DC0XUE1FP2K');
      mTextBO.Load('9C92000101',nil);
      mAccount_id:='1300000101';
      mBody:=mTextBO.GetFieldValueAsString('X_Note');
      mSubject:='Zboží je přiraveno k osobnímu odběru';
      mBody:=NxSearchReplace(mBody,'#CISOBJ#',mCurrBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
      mTO:=mCurrBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Email');
      SendInternalMail(mOS, mTO,'','',
                         mSubject,mBody,
                         '','',mCurrBO.GetFieldValueAsString('Firm_ID'),
                         mCurrBO.GetLoadedCollectionMonikerForFieldCode(mCurrBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                         mCurrBO.GetLoadedCollectionMonikerForFieldCode(mCurrBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'), mAccount_ID);
      mBO:=mOS.CreateObject(Class_ReceivedOrder);
      mBO.load(mCurrBO.OID,nil);
      mBO.SetFieldValueAsString('U_OrderState_ID','');
      mBO.save;
      mBO.free;
    end;
 end; }
end;

procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String;
                           ASubject:String; ABody:String; AAtachement, AAtachement2:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String; aAccount_ID:string);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID',aAccount_ID);
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailBO.SetFieldValueAsString('BodySavedAs','1');
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusTransaction_ID',ABusTransaction_ID);
     mMRecipients:=mMailBO.GetCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);
     mMailRecipient.SetFieldValueAsInteger('EmailType',0);
     if not(acc='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ACC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',1);
     end;
     if not(ABCC='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ABCC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',2);
     end;

     if not(AAtachement='') then begin
      TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;

     if not(AAtachement2='') then begin
      TNxEmailSent(mMailBO).AttachFile(AAtachement2);

     end;



     mMailBO.Save;
     mMailBO.free;

  end;
end;

Procedure CreateDL(Sender:TComponent);
var
 mBO:TNxCustomBusinessObject;
 mSite:TSiteForm;
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mRows:TNxCustomBusinessMonikerCollection;
begin
  mSite:=TComponent(Sender).DynSite;
  mBO:=TDynSiteForm(mSite).CurrentObject;
  if Assigned(mBO) then begin
                      mInputParams := TNxParameters.Create;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                      mParam.AsString := '8RC0000101';
                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                      mParam.AsString := mBO.OID;
                      mParam := mInputParams.GetOrCreateParam(dtInteger, 'StoreQuantityKind');
                      mParam.AsInteger := 1;
                      mImportMan:=NxCreateDocumentImportManager(mbo.ObjectSpace,Class_ReceivedOrder,Class_BillOfDelivery);
                      mImportMan.AddInputDocument(mbo.OID);
                      mImportMan.LoadParams(mInputParams);
                      mImportMan.Execute;
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '8RC0000101');
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mBO.GetFieldValueAsString('Firm_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mBO.GetFieldValueAsString('FirmOffice_ID'));
                      mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                      if mrows.count>0 then begin

                        mImportMan.OutputDocument.Save;
                        mbo.SetFieldValueAsString('PMState_ID','1040000101');
                        mbo.save;
                      end;
                      TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
                      if mRows.count>0 then NxShowSimpleMessage('Založil jsem '+mImportMan.OutputDocument.DisplayName,nil);
                      if mRows.count=0 then NxShowSimpleMessage('Doklad by neměl žádný řádek.',nil);

  end;
end;

begin
end.