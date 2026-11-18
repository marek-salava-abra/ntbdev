

uses '.lib';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction:= Self.GetNewMultiAction;
  mAction.Name:= 'actStoreCardAPISync';
  mAction.Caption:= '## Synchronizovat do SK ##';
  mAction.Items.Add('##Synchronizovat do SK##');
  mAction.Items.Add('##Synchronizovat do DE##');
  mAction.Items.Add('##Synchronizovat do AT##');
  mAction.Category:= 'tabList';
  mAction.OnExecuteItem:= @exeStoreCardAPISyncSwitch;
end;


procedure exeStoreCardAPISyncSwitch(Sender: TComponent; AIndex: Integer);
begin
  case AIndex of
    0: StoreCardSync(Sender, AIndex);
    1: StoreCardSync(Sender, AIndex);
    2: StoreCardSync(Sender, AIndex);
  end;
end;

procedure StoreCardSync(Sender: TComponent;Index:integer);
var
  mSite: TSiteForm;
  mBO, mEIDBO: TNxCustomBusinessObject;
  mOS: TNxCustomObjectSpace;
  mList: TStringList;
  mResultStr, mString, mResult_ID, mExternal_ID, mEIDString, mCountryCode: String;
  i,j: Integer;
  mEIDS:TNxCustomBusinessMonikerCollection;
begin
  mResultStr:= '';
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;
  mList:= TStringList.Create;
  try
    mSite.FillListWithSelectedRows(mList);
    mBO:= mOS.CreateObject(Class_StoreCard);
    try
      WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
      for i:= 0 to mList.Count -1 do begin
            mBO.Load(mList[i], nil);
            StoreCardAPISync2(mBO, mResultStr,index,mResult_ID);
            if not(NxIsEmptyOID(mResult_ID)) then begin
             case Index of
                0: mCountryCode:= 'SK';
                1: mCountryCode:= 'DE';
                2: mCountryCode:= 'AT';
             end;
             mEIDString:= mCountryCode+';'+FormatDateTime('YYYY.MM.DD hh:nn:ss',Now)+';'+mResult_ID;
             mString:=mBo.GetFieldValueAsString('X_SynchronizedAtCountries');
             mString:=SetFlagAtIndex(mString,index);
             mbo.SetFieldValueAsString('X_SynchronizedAtCountries',mString);
             mEIDS:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ExternalIDs'));
             mExternal_ID:=mOS.SQLSelectFirstAsString('Select id from StoreCardEIDS where parent_id='+QuotedStr(mbo.OID)+' and ExternalID like '+QuotedStr(mCountryCode+'%'),'');
             if NxIsEmptyOID(mExternal_ID) then begin
              mEIDBO:=mEIDS.AddNewObject;
              mEIDBO.SetFieldValueAsString('ExternalID',mEIDString);
             end else begin
               for j:=0 to mEIDS.count-1 do begin
                 try
                  if mEIDS.BusinessObject[j].OID=mExternal_ID then mEIDS.BusinessObject[j].SetFieldValueAsString('ExternalID',mEIDString);
                 except

                 end;
               end;
             end;
             mbo.save;
            end;
        WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
        WaitWin.StepIt;
      end;
     WaitWin.Stop;
    finally
      mBO.Free;
    end;
    NxShowSimpleMessage('Synchronizace proběhla u '+IntToStr(mList.Count)+' karet.'+nxCrLf+mResultStr, mSite);
  finally
    mList.Free;
    gUpdated:= 0;
    gCreated:= 0;
  end;
end;

function SetFlagAtIndex(var mS: string; mIndex: Integer): string;
var
  mR: string;
  mP: Integer;
begin
  mR := mS;
  mP := mIndex + 1;                   // převod 0-based → 1-based
  if (mP >= 1) and (mP <= Length(mR)) then
    mR[mP] := '1';                   // změní jen danou pozici, ostatní zachová
  Result := mR;
end;

begin
end.