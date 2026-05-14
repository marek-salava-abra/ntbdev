procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportWeight';
  mAction.Caption := '##Import rozmer##';
  mAction.Hint := 'Naimportuje data z CSV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportData;
end;

Procedure ImportData(sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList, mFoundList:TStringList;
 mBO, mUnitBO, mSupplierBO, mSMBO, mStorePrice, mSSBO:TNxCustomBusinessObject;
 mUnits,mStorePrices:TNxCustomBusinessMonikerCollection;
 i,j:integer;
 mOpenDlg:TOpenDialog;
 mTempStr:String;
 mStoreCard_ID, mFirm_ID, mStorePrice_ID, mStore_ID, mStoreSubCard_ID,mPriceList_ID:string;
 mcode, mHmotnost, mRozmerA, mRozmerB, mRozmerC, mRP:string;
begin
  mSite:=TComponent(sender).BusRollSite;
  mOS:=mSite.BaseObjectSpace;
  mList:=tstringlist.create;
  mFoundList:=TStringList.Create;
  mOpenDlg := TOpenDialog.Create(Sender);
  if mOpenDlg.Execute then begin
    mList.LoadFromFile(mOpenDlg.FileName);
    if mList.Count>0 then begin
     WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
      for i:=1 to mlist.count-1 do begin
         mTempStr:=mlist.Strings[i];
         mcode:=Trim(NxTrapStr(mTempStr,';'));
         //mRP:=Trim(NxTrapStr(mTempStr,';'));
         mHmotnost:=Trim(NxTrapStr(mTempStr,';'));
         mRozmerA:=Trim(NxTrapStr(mTempStr,';'));
         mRozmerB:=Trim(NxTrapStr(mTempStr,';'));
         mRozmerC:=Trim(NxTrapStr(mTempStr,';'));

         mRP:=Trim(NxTrapStr(mTempStr,';'));
         mStoreCard_ID:=GetStoreCard_ID(mOS, mCode);

         if not(NxIsEmptyOID(mStoreCard_ID)) then begin
           mSMBO:=mOS.CreateObject(Class_StoreCard);
           mSMBO.Load(mStoreCard_ID,nil);
           mUnits:=mSMBO.GetLoadedCollectionMonikerForFieldCode(mSMBO.GetFieldCode('StoreUnits'));
           for j:=0 to mUnits.Count-1 do begin
             mUnitBO:=mUnits.BusinessObject[j];
             if mUnitBO.GetFieldValueAsString('Code')=mSMBO.GetFieldValueAsString('MainUnitcode') then begin
               if (NxIBStrToFloat(mHmotnost)>0) then begin
                 mUnitBO.SetFieldValueAsFloat('Weight',NxIBStrToFloat(mHmotnost));
                 if mRP='g' then mUnitBO.SetFieldValueAsInteger('WeightUnit',0);
               end;
               mUnitBO.SetFieldValueAsFloat('Width',NxIBStrToFloat(mRozmerA)/1000);
               mUnitBO.SetFieldValueAsFloat('Height',NxIBStrToFloat(mRozmerB)/1000);
               mUnitBO.SetFieldValueAsFloat('Depth',NxIBStrToFloat(mRozmerC)/1000);
             end;
           end;
           mFoundList.Add(mSMBO.DisplayName);
           mSMBO.save;
           mSMBO.free;
         end;
         WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
         WaitWin.StepIt;
      end;
     WaitWin.Stop;
     NxShowSimpleMessage('Nahráno '+IntToStr(mFoundList.count) +'/'+IntToStr(mlist.count)+' položek.',mSite);
    end;
   end;
end;

function GetStoreCard_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM StoreCards WHERE CODE=''%s''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

begin
end.