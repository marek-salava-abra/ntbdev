procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;
  mUser:TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;
  mUser:=Self.BaseObjectSpace.CreateObject(Class_SecurityUser);
  mUser.load(NxGetActualUserID(self.BaseObjectSpace),nil);
  if mUser.GetFieldValueAsBoolean('U_VR') then begin


    mBut:= Self.GetNewAction;
    mBut.ShowControl := True;
    mBut.ShowMenuItem := True;
    mBut.Caption := 'Vratka celého DL';
    mBut.Hint := 'Vytvoří vratku označeného celého nečerpaného dodacího listu';
    mBut.Category := 'tabList';
    mBut.OnExecute := @VRfromDL;
   end;
end;


Procedure VRfromDL (Sender:TComponent);
var
 mSite:TSiteForm;
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mUser, mBO, mBOD:TNxCustomBusinessObject;
 mBOD_ID, mBO_ID:String;
 mParam:TNxParameter;
 mOS:TNxCustomObjectSpace;
 mBool:Boolean;
 i:Integer;
begin
 mSite:=TComponent(Sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 mOS:=mBO.ObjectSpace;
 mBO_ID:=mbo.OID;
 mUser:=mOS.CreateObject(Class_SecurityUser);
 mUser.Load(NxGetActualUserID_1(mBO),nil);
 mBool:=False;
 if NxIsEmptyOID(mUser.GetFieldValueAsString('X_RBOD_ID')) then begin
    NxShowSimpleMessage('Přihlášený uživatel nemá nastavenu výchozí řadu VR. Tlačítko nelze použít.',mSite);
    exit;
 end;
 if NxMessageBox('Dotaz','Skutečně vytvořit vratku celého dodacího listu?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
                if not(mbo.GetFieldValueAsBoolean('IsAvailableForDelivery')) then begin
                   NxShowSimpleMessage('Dodací list je čerpaný (nebo částečně čerpaný), vratku nelze vytvořit',mSite);
                 exit;
                end;
                for i:=0 to mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).Count-1 do begin
                  if mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).BusinessObject[i].GetFieldValueAsFloat('DeliveredQuantity')>0
                  then mBool:=True;
                end;
                if mBool then begin
                 NxShowSimpleMessage('Dodací list je čerpaný (nebo částečně čerpaný), vratku nelze vytvořit',mSite);
                 exit;
                end;
                mInputParams := TNxParameters.Create;
                mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                mParam.AsString := mUser.GetFieldValueAsString('X_RBOD_ID');
                mImportMan := NxCreateDocumentImportManager(mOS, Class_BillOfDelivery, Class_RefundedBillOfDelivery);
                try
                  mImportMan.AddInputDocument(mBO.OID);
                  mImportMan.LoadParams(mInputParams);
                  mImportMan.Execute;
                  mImportMan.CheckOutputDocument;
                  if Assigned(mImportMan.OutputDocument) then begin
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mUser.GetFieldValueAsString('X_RBOD_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('U_vratkaDL',True);
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('Finished',True);
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('IsAvailableForDelivery',False);
                      mImportMan.OutputDocument.SetFieldValueAsString('Description','Vratka nefakturovaného '+mbo.DisplayName);
                      mImportMan.OutputDocument.Save;
                      //mBod:=mImportMan.OutputDocument;
                      mBOD_ID:=mImportMan.OutputDocument.OID;
                      mBOD:=mOS.CreateObject(Class_RefundedBillOfDelivery);
                      mBOD.Load(mBOD_ID,nil);
                  end;
                finally
                mImportMan.Free;
                mInputParams.Free;
                mbo.Free;
                mbo:=mOS.CreateObject(Class_BillOfDelivery);
                mbo.Load(mbo_ID,nil);
                mBO.SetFieldValueAsBoolean('U_Storno',True);
                mBO.save;
                TDynSiteForm(mSite).RefreshData;
                end;
                if not(NxIsEmptyOID(mBOD_ID)) then begin
                  if NxMessageBox('Dotaz','Vytvořil jsem doklad '+mBOD.DisplayName+'. Přejete si jej zobrazit?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
                      msite.ShowDynForm('BL0I5SAOS3DL3ACU03KIU0CLP4', nil, nil, False, 'DoShow;' + mBOD.OID);
                  end;
                end;


 end;
end;

begin
end.