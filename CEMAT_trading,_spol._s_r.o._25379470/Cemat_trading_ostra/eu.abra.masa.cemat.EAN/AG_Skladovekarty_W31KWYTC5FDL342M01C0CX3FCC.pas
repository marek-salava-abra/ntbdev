procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  i : integer;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import Ean/PID/CAI';
  mAction.Hint := 'Naimportuje EANy struktura Kód, zkrácený název, název,EAN,PID, CAI';
  mAction.Category := 'TabList';
  mAction.OnExecute := @ImportEAN;
end;

Procedure ImportEAN(sender:tcomponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 mOpenDlg:TOpenDialog;
 i:integer;
 mBO, mStoreUnitBO:TNxCustomBusinessObject;
 mUnits:TNxCustomBusinessMonikerCollection;
 mStoreCard_ID:string;
 mTempStr, mCode,mShortName,mName, mEAN, mPID, mCAI:string;
begin
  mSite:=TComponent(sender).BusRollSite;
  mOS:=mSite.BaseObjectSpace;
  mList:=tstringlist.create;
  mOpenDlg := TOpenDialog.Create(Sender);
  if mOpenDlg.Execute then begin
   mList.LoadFromFile(mOpenDlg.FileName);
    if mList.Count>0 then begin
     WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
      for i:=1 to mlist.count-1 do begin
       mTempStr:=mlist.Strings[i];
       mCode:=NxToken(mTempStr,';');
       mShortName:=NxToken(mTempStr,';');
       mName:=NxToken(mTempStr,';');
       mEAN:=NxToken(mTempStr,';');
       mPID:=NxToken(mTempStr,';');
       mCAI:=NxToken(mTempStr,';');
       mStoreCard_ID:=GetStoreCard_ID(mos,mCode);
       if not(NxIsEmptyOID(mStoreCard_ID)) then begin
         mBO:=mOS.CreateObject(Class_StoreCard);
         mBO.load(mStoreCard_ID,nil);
         if not(NxIsBlank(mEan)) then begin
          mUnits:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('StoreUnits'));
          mStoreUnitBO:=mUnits.BusinessObject[0];
          mStoreUnitBO.SetFieldValueAsString('EAN',mEAN);
         end;
         mBO.SetFieldValueAsString('U_PID',mPID);
         mbo.SetFieldValueAsString('U_CAI',mCAI);
         mBO.save;
         mBO.Free;
       end;
       WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
       WaitWin.StepIt;
      end;
     WaitWin.Stop;
     NxShowSimpleMessage('Nahráno '+IntToStr(mlist.count)+' karet.',mSite);
    end;
   end;
end;


function GetStoreCard_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM StoreCards WHERE Code=''%s''  ';
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