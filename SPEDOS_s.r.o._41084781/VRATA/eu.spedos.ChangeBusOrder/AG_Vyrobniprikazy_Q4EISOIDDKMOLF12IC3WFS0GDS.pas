uses 'eu.spedos.ChangeBusOrder.fce';

Var
  dSite:TSiteForm;
  mCbVyrobek,mCbBusOrder:TRollComboEdit;
{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Změna zakázky';
  mAction.Hint := 'Změní zakázku na souvisejících dokladech';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ChangeBusOrder;
end;

Procedure ChangeBusOrder(Sender:TComponent);
var
 mSite:TSiteForm;
 mBO, mVyrobekBO:TNxCustomBusinessObject;
 mBusOrder_ID, aVyrobek_ID, mSerialNumber_ID, mOldSerialNumber_ID, mOldBusOrder_ID:string;
 mOldSN, mNewSN, mJOSerial_ID:string;
 mOS:TNxCustomObjectSpace;
 mPLMJOOutputItemBO, mPLMJobOrdersSNBO, mStoreSubBatchBO, mJOBO:TNxCustomBusinessObject;
 mPLMJOOutputItems, mPLMJobOrdersSNs:TNxCustomBusinessMonikerCollection;
 i,j:integer;
 mSSB_ID, mJobOrder_ID:string;
 mWinHttp:variant;
 mJSON:TJSONSuperObject;
 mIDFrom, mIDTo:string;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=msite.BaseObjectSpace;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
   if NxMessageBox('Dotaz','Přejete si změnit zakázku na výrobním příkaze '+mbo.DisplayName+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
      if GetBusOrder_ID(msite,mBusOrder_ID, aVyrobek_ID) then begin
        if NxIsEmptyOID(mBusOrder_ID) or NxIsEmptyOID(aVyrobek_ID) then begin
          NxShowSimpleMessage('Není vyplněna zakázka nebo výrobek. Ukončuji.',mSite);
          Exit;
        end;
        if not(NxIsEmptyOID(mBusOrder_ID)) then begin
           mOldBusOrder_ID:=mbo.GetFieldValueAsString('BusOrder_ID');
           mVyrobekBO:=mOS.CreateObject('XNAVPBFTCRO4BBYJZ2FN14T51O');
           mVyrobekBO.Load(aVyrobek_ID,nil);
           mNewSN:=mVyrobekBO.GetFieldValueAsString('Name');
           mJobOrder_ID:=GetJobOrder_ID(mOS,mNewSN);
           if not(NxIsEmptyOID(mJobOrder_ID)) then begin
             mJOBO:=mOS.CreateObject(Class_PLMJobOrder);
             mJOBO.load(mJobOrder_ID,nil);
             NxShowSimpleMessage('Pro výrobní číslo '+mNewSN+' již existuje '+mjobo.DisplayName+'. Ukončuji.',msite);
             mjobo.free;
             exit;
           end;
           mSerialNumber_ID:=GetSerialNumber_ID(mOS,mVyrobekBO.GetFieldValueAsString('Name'));
           //NxShowSimpleMessage(mVyrobekBO.GetFieldValueAsString('Name')+' '+mSerialNumber_ID,mSite);
           mPLMJOOutputItems:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Outputs'));
           for i:=0 to mPLMJOOutputItems.Count-1 do begin
             mPLMJOOutputItemBO:=mPLMJOOutputItems.BusinessObject[i];
             mPLMJobOrdersSNs:=mPLMJOOutputItemBO.GetLoadedCollectionMonikerForFieldCode(mPLMJOOutputItemBO.GetFieldCode('PLMJobOrdersSN'));
             for j:=0 to mPLMJobOrdersSNs.count-1 do begin
               mPLMJobOrdersSNBO:=mPLMJobOrdersSNs.BusinessObject[j];
               mOldSN:=mPLMJobOrdersSNBO.GetFieldValueAsString('StoreBatch_ID.Name');
               mJOSerial_ID:=mPLMJobOrdersSNBO.OID;
               mOldSerialNumber_ID:=mPLMJobOrdersSNBO.GetFieldValueAsString('StoreBatch_ID');
               //NxShowSimpleMessage(mPLMJobOrdersSNBO.GetFieldValueAsString('StoreBatch_ID.Name'),mSite);
             end;
           end;
           mSSB_ID:=GetSSB_ID(mOS, mSerialNumber_ID,mbo.GetFieldValueAsString('Store_ID'));
           if NxIsEmptyOID(mSSB_ID) then begin
             mStoreSubBatchBO:=mOS.CreateObject(Class_StoreSubBatch);
             mStoreSubBatchBO.New;
             mStoreSubBatchBO.prefill;
             mStoreSubBatchBO.SetFieldValueAsString('StoreBatch_ID',mSerialNumber_ID);
             mStoreSubBatchBO.SetFieldValueAsString('Store_ID',mBO.GetFieldValueAsString('Store_ID'));
             mStoreSubBatchBO.Save;
             mStoreSubBatchBO.free;
           end;
           mbo.SetFieldValueAsString('BusOrder_ID', mBusOrder_ID);
           mIDFrom:=mBO.GetFieldValueAsString('U_ID_vyrobku');
           mbo.SetFieldValueAsString('U_ID_vyrobku',mVyrobekBO.GetFieldValueAsString('Code'));
           mIDTo:=mBO.GetFieldValueAsString('U_ID_vyrobku');
           mbo.SetFieldValueAsString('U_vyrobni_cislo',mVyrobekBO.GetFieldValueAsString('Name'));
           mBO.SetFieldValueAsString('U_id_pozice',mVyrobekBO.GetFieldValueAsString('X_OP_Pozice.Code'));
           mBO.SetFieldValueAsString('X_Pozice_OD',mVyrobekBO.GetFieldValueAsString('X_OP_Pozice'));
           mBO.save;
           mOS.SQLExecute('Update StoreDocuments2 set busorder_id='+QuotedStr(mBusOrder_ID)+' where productiontask_id='+QuotedStr(mbo.GetFieldValueAsString('ProductionTask_ID')));
           mOS.SQLExecute('Update StoreDocuments set Description='+QuotedStr(mNewSN)+' where Description='+QuotedStr(mOldSN));
           mOS.SqlExecute('Update PLMJobOrdersSN set StoreBatch_ID='+Quotedstr(mSerialNumber_ID)+' where ID='+QuotedStr(mJOSerial_ID));
           mOS.SQLExecute('Update DocRowBatches set StoreBatch_ID='+QuotedStr(mSerialNumber_ID)+' where StoreBatch_id='+QuotedStr(mOldSerialNumber_ID)+' and parent_id in (select id from storedocuments2 where productiontask_id='
                            +QuotedStr(mbo.GetFieldValueAsString('ProductionTask_id'))+' and flowtype='+Quotedstr('28')+')');
           mOS.SQLExecute('Update StoreSubBatches set quantity=quantity+1 where StoreBatch_ID='+QuotedStr(mSerialNumber_ID)+' and Store_ID='+QuotedStr(mbo.GetFieldValueAsString('Store_ID')));
           mOS.SQLExecute('Update StoreSubBatches set quantity=quantity-1 where StoreBatch_ID='+QuotedStr(mOldSerialNumber_ID)+' and Store_ID='+QuotedStr(mbo.GetFieldValueAsString('Store_ID')));
           mOS.SQLExecute('Update PLMOperations set BusOrder_id='+QuotedStr(mBusOrder_ID)+' where BusOrder_id='+Quotedstr(mOldBusOrder_ID));
           mOS.SQLExecute('Update PLMAGGREGATEWORKTICKETS set BusOrder_id='+QuotedStr(mBusOrder_ID)+' where BusOrder_id='+Quotedstr(mOldBusOrder_ID));
           mOS.SQLExecute('Update GeneralLedger set DebitBusOrder_ID='+QuotedStr(mBusOrder_ID)+' where DebitBusOrder_ID='+Quotedstr(mOldBusOrder_ID)+' and accdocqueue_id in (select id from accdocqueues where documenttype in (''WT'',''27'',''28'',''29'')) ');
           mOS.SQLExecute('Update GeneralLedger set CreditBusOrder_ID='+QuotedStr(mBusOrder_ID)+' where CreditBusOrder_ID='+Quotedstr(mOldBusOrder_ID)+' and accdocqueue_id in (select id from accdocqueues where documenttype in (''WT'',''27'',''28'',''29'')) ');
           Try
             mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
             mWinHTTP.Open('POST','https://sod.spedos.cz/api/api.abra-vyrobek-na-zakazku.php?test&Rodneico='+ GetICO(mbo.ObjectSpace)+
             '&ID_montaz_vyrobky_from='+mIDFrom+'&ID_montaz_vyrobky_to='+mIDTo);
             //NxShowSimpleMessage('Jdu odeslat POST na: '+'https://sod.spedos.cz/api/api.abra-vyrobek-na-zakazku.php?test&Rodneico='+ GetICO(mbo.ObjectSpace)+
             //'&ID_montaz_vyrobky_from='+mIDFrom+'&ID_montaz_vyrobky_to='+mIDTo,mSite);
             mWinHTTP.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
             mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
             mWinHTTP.Send('');
             //NxShowSimpleMessage(mWinHTTP.ResponseText,msite);
             mJSON := TJSONSuperObject.Create;
             mJSON := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
             //NxShowSimpleMessage('Odpověď byla: '+mJSON.AsString,mSite);
           except
             NxShowSimpleMessage(ExceptionMessage,mSite);
           end;
           TDynSiteForm(mSite).RefreshData;
           TDynSiteForm(mSite).ActiveDataSet.SeekID(mBO.OID);
           NxShowSimpleMessage('Provedeno.',msite);
        end;
      end;
   end;
 end;
end;

Procedure SetVyrobek(Sender:TRollComboEdit);
  var
   mAllowed:TstringList;
   mSQL, mParam:string;
  begin
      if not(NxIsEmptyOID(mCbBusOrder.datatext)) then begin
      mAllowed:=TStringList.create;
      mSQL := 'select id from defrolldata where X_BusOrder_ID=' + QuotedStr(mCbBusOrder.datatext)+' and clsid=''XNAVPBFTCRO4BBYJZ2FN14T51O'' ';
      dSite.BaseObjectSpace.SQLSelect(mSQL,mAllowed);
      mParam:=mAllowed.DelimitedText;
      mCbVyrobek.Parameters.Clear;
      mCbVyrobek.Parameters.Add('_Allowed='+mParam);
      mAllowed.Free;
      end;
  end;

procedure _SaveChanges_PreHook(Self: TDynSiteForm);
begin

end;

Function GetBusOrder_ID(var ASite : TSiteform; var aBusOrder_ID, aVyrobek_ID : string):Boolean;
var
    mLabel1,mCbCCBusOrder, mCbCcVyrobek: TLabel;
    mEd1, mEd2, mEd3, mEd4, mEd5, mEd6:TEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mCbCcSupplier: TLabel;
    mCbMaterialComposition: TRollComboEdit;
begin

 if ASite <> nil then begin
    dSite:=ASite;
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 510;
    mForm.Height:= 180;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Změní zakázku';


    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Zakázka:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCbCCBusOrder:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCCBusOrder.Parent:= mForm;
    mCbCCBusOrder.Left:= 236;
    mCbCCBusOrder.Top:= 10;
    mCbCCBusOrder.Width:= 255;

    mCbBusOrder:= TRollComboEdit.Create(mForm);
    mCbBusOrder.Parent:= mForm;

    mCbBusOrder.ClassID:= '03OXHKRF4VD13ACL03KIU0CLP4';
    mCbBusOrder.Complete:= True;
    mCbBusOrder.Prefilling:= pmNone;
    mCbBusOrder.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mCbBusOrder.Top:= 10;
    mCbBusOrder.Left:= 125;
    mCbBusOrder.Width:= 108;
    mCbBusOrder.DataText:=aBusOrder_ID;
    mCbBusOrder.ConnectedControl:= mCbCCBusOrder;
    mCbBusOrder.OnExit:=@SetVyrobek;
    mCbBusOrder.ConnectedControlField:= 'Name';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Výrobek:';
    mLabel1.Top := 31;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCbCcVyrobek:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcVyrobek.Parent:= mForm;
    mCbCcVyrobek.Left:= 236;
    mCbCcVyrobek.Top:= 31;
    mCbCcVyrobek.Width:= 255;

    mCbVyrobek:= TRollComboEdit.Create(mForm);
    mCbVyrobek.Parent:= mForm;

    mCbVyrobek.ClassID:= '3ZUF1IWKAZA4PG3PRYPOVXOSV4';
    mCbVyrobek.Complete:= True;
    mCbVyrobek.Prefilling:= pmNone;
    mCbVyrobek.TextField:= 'Name';  // položka podle které se bude vyhledávat středisko
    mCbVyrobek.Top:= 31;
    mCbVyrobek.Left:= 125;
    mCbVyrobek.Width:= 108;
    mCbVyrobek.DataText:=aBusOrder_ID;
    mCbVyrobek.ConnectedControl:= mCbCcVyrobek;
    mCbVyrobek.ConnectedControlField:= 'Code';



    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 75;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 75;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
    //aresult:=mresult;
   // if mButCancel.OnC
    if mResult = 1 then
         aVyrobek_ID:=mCbVyrobek.DataText;
         aBusOrder_ID:=mCbBusOrder.DataText;
         Result:=true;
    mForm.free;
  end;
end;

begin
end.