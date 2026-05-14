procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Převod bez vazby';
  mAction.Hint := 'Provede převod bez vazby na OBDV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateTransfer;
end;

Procedure CreateTransfer(sender:TComponent);
var
 mSite:TSiteForm;
 mBO, mRowBO, mOTBO, mOTRowBO:TNxCustomBusinessObject;
 mRows, mOTRows:TNxCustomBusinessMonikerCollection;
 i, mResult:integer;
 mDestStore_ID:string;
 mOS:TNxCustomObjectSpace;
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
begin
 mResult:=0;
 mSite:=TComponent(sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
   mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
   mOS:=mbo.ObjectSpace;
   if NxMessageBox('Dotaz','Přejete si vytvořit převod bez vazby k '+mbo.DisplayName+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
     //if true then begin
      if GetData(mSite, mDestStore_ID, mResult) then begin
            if NxIsEmptyOID(mDestStore_ID) then begin
              NxShowSimpleMessage('Nebyl vybrán cílový sklad, nebude vytvořena převodka příjem.',mSite);
              //exit;
            end;
            if mResult=1 then begin
            //if true then begin
             try
               mOTBO:=mOS.CreateObject(Class_OutgoingTransfer);
               mOTBO.New;
               mOTBO.prefill;
               mOTBO.SetFieldValueAsString('DocQueue_ID','R100000101');
               mOTBO.SetFieldValueAsString('Firm_ID',mbo.GetFieldValueAsString('Firm_ID'));
               mOTBO.SetFieldValueAsString('Description', mBO.DisplayName);
               mOTRows:=mOTBO.GetLoadedCollectionMonikerForFieldCode(mOTBO.GetFieldCode('Rows'));
               for i:=0 to mRows.Count-1 do begin
                mRowBO:=mRows.BusinessObject[i];
                if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
                 if not(mRowBO.GetFieldValueAsString('BusTransaction_ID.Code')='48') then begin
                  if not(mRowBO.GetFieldValueAsString('StoreCard_ID.code')='xxxx') then begin
                    mOTRowBO:=mOTRows.AddNewObject;
                    mOTRowBO.Prefill;
                    mOTRowBO.SetFieldValueAsString('Store_ID',mRowBO.GetFieldValueAsString('Store_ID'));
                    mOTRowBO.SetFieldValueAsString('StoreCard_ID',mRowBO.GetFieldValueAsString('StoreCard_ID'));
                    mOTRowBO.SetFieldValueAsString('Division_ID',mRowBO.GetFieldValueAsString('Division_ID'));
                    mOTRowBO.SetFieldValueAsString('BusOrder_ID',mRowBO.GetFieldValueAsString('BusOrder_ID'));
                    mOTRowBO.SetFieldValueAsString('BusTransaction_ID',mRowBO.GetFieldValueAsString('BusTransaction_ID'));
                    mOTRowBO.SetFieldValueAsFloat('Quantity',mRowBO.GetFieldValueAsFloat('Quantity'));
                  end;
                 end;
                end;
               end;
               mOTBO.Save;
               try
                  if not(NxIsEmptyOID(mDestStore_ID)) then begin
                      mInputParams := TNxParameters.Create;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                      mParam.AsString := 'T100000101';
                      mParam := mInputParams.GetOrCreateParam(dtString, 'Store_ID');
                      mParam.AsString := mDestStore_ID;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                      mParam.AsString := mOTBO.OID;
                      mImportMan:=NxCreateDocumentImportManager(mOS,Class_OutgoingTransfer,Class_IncomingTransfer);
                      mImportMan.AddInputDocument(mOTBO.OID);
                      mImportMan.LoadParams(mInputParams);
                      mImportMan.Execute;
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', 'T100000101');
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mOTBO.GetFieldValueAsString('Firm_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mOTBO.GetFieldValueAsString('FirmOffice_ID'));
                      mImportMan.OutputDocument.save;
                      NxShowSimpleMessage('Založil jsem '+mOTBO.DisplayName+' a '+mImportMan.OutputDocument.DisplayName+'.',mSite);
                  end;
                except
                 NxShowSimpleMessage(ExceptionMessage,mSite);
                end;
              except
               NxShowSimpleMessage(ExceptionMessage, mSite);
              end;
            end;
      end;
   end;
 end;
end;


Function GetData(var ASite : TSiteform; var aStore_ID:string; var aResult:integer;):Boolean;
var
    mLabel1,mCbCCMaterialComposition, mCbCCDivision, mCBBOD, mCBVR: TLabel;
    mEd1, mEd2, mEd3, mEd4, mEd5, mEd6:TEdit;
    mNumEd:TNumEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mDed:TDateEdit;
    mCbMaterialComposition, mCbDivision, mBODDQ, mVRDQ: TRollComboEdit;
    mAllowedBOD, mAllowedVR, mListZpusob:TStringList;
    mParBOD, mParVR:String;
    cbZpusob:TComboBox;
    {mAllowed:=TStringList.create;
    mSQL3 := 'select id from StoreCards where hidden=''N'' ';
    dSite.BaseObjectSpace.SQLSelect(mSQL3,mAllowed);
    mParam3:=mAllowed.DelimitedText;
    mCbMaterial.Parameters.Clear;
    mCbMaterial.Parameters.Add('_Allowed='+mParam3);}
begin
 Result:=false;
 if ASite <> nil then begin
    Result:=False;
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 510;
    mForm.Height:= 120;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Cílový sklad:';



    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Sklad:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCBBOD:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCBBOD.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCBBOD.Left:= 236;
    mCBBOD.Top:= 11;
    mCBBOD.Width:= 255;

    mBODDQ:= TRollComboEdit.Create(mForm);
    mBODDQ.Parent:= mForm;

    mBODDQ.ClassID:= 'O3ZO2K155FDL3CL100C4RHECN0';
    mBODDQ.Complete:= True;
    mBODDQ.Prefilling:= pmNone;
    mBODDQ.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mBODDQ.Top:= 11;
    mBODDQ.Left:= 137;
    mBODDQ.Width:= 108;
    mBODDQ.DataText:=aStore_ID;
    {mBODDQ.Parameters.Clear;
    mBODDQ.Parameters.Add('_Allowed='+mParBOD);  }
    mBODDQ.ConnectedControl:= mCBBOD;
    mBODDQ.ConnectedControlField:= 'Name';

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 50;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 50;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
    //aresult:=mresult;
   // if mButCancel.OnC
    if mResult = 1 then begin
         aResult:=1;
         aStore_ID:=mBODDQ.DataText;
         Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    end;
    mForm.free;
  end;
end;


begin
end.