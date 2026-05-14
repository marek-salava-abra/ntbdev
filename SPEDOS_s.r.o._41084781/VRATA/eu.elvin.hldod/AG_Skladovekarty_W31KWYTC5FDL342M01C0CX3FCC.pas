uses 'eu.elvin.hldod.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actMainSupplier';
  mAction.Caption := 'Hlavní dodavatel';
  mAction.Hint := 'Založí dodavatele a nastaví jako hlavního';
  mAction.Category := 'tabList';
  mAction.OnExecute := @MainSupplier;
end;


Procedure MainSupplier(sender:TComponent);
var
 mSite:TSiteForm;
 mSupplier_ID, mFirm_ID:string;
 i,mResult:integer;
 mSCBO, mSupplierBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
 mResult:=0;
  try
    mList:=TStringList.Create;
    TBusRollSiteForm(mSite).List.GetSelectedId(mList);
    if mlist.count>0 then begin
       if NxMessageBox('Dotaz', 'Přejete si nastavit hlavního dodavatele na '+IntToStr(mlist.Count)+' skladových kartách?', mdConfirm, mdbYesNo, 0, 0, False, Nil)=mrYes then begin
          if GetData(mSite, mFirm_ID, mResult) then begin
            if NxIsEmptyOID(mFirm_ID) then begin
              NxShowSimpleMessage('Nebyla vybrána firma, ukončuji.',mSite);
              exit;
            end;
            if mResult=1 then begin
             ProgressInit(mSite, 'Vkládám dodavatele...', mList.Count);
              for i:=0 to mList.count-1 do begin
                 mSCBO:=mOS.CreateObject(Class_StoreCard);
                 mscbo.Load(mlist.Strings[i],nil);
                 mSupplier_ID:=GetSupplier_ID(mOS, mSCBO.OID,mFirm_ID);
                 if NxIsEmptyOID(mSupplier_ID) then begin
                    mSupplierBO:=mOS.CreateObject(Class_Supplier);
                    mSupplierBO.new;
                    mSupplierBO.Prefill;
                    msupplierbo.SetFieldValueAsString('Firm_ID',mFirm_ID);
                    mSupplierBO.SetFieldValueAsString('StoreCard_ID',mSCBO.OID);
                    mSupplierBO.SetFieldValueAsString('QUnit',mSCBO.GetFieldValueAsString('MainUnitCode'));
                    mSupplierBo.Save;
                    mSupplier_ID:=mSupplierBO.OID;
                    mSupplierBO.free;
                 end;
                 mSCBO.SetFieldValueAsString('MainSupplier_ID',mSupplier_ID);
                 if mSCBO.NeedSave then mSCBO.save;
                 mSCBO.Free;

                ProgressSetPos(i);
              end;
              ProgressDispose();
            end;
          end;
       end;
    end;
  except
   NxShowSimpleMessage(ExceptionMessage, mSite);
  end;
end;

begin
end.