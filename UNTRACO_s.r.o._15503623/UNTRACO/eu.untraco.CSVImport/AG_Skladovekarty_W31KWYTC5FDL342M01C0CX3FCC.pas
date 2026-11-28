procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImport2';
  mAction.Caption := 'Import CSV';
  mAction.Hint := 'Naimportuje data z CSV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportData;
end;

Procedure ImportData(sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 mBO, mUnitBO, mSkupinaBO, mKategorieBO:TNxCustomBusinessObject;
 i,j:integer;
 mOpenDlg:TOpenDialog;
 mTempStr:String;
 mCode, mName, mKategorie, mSkupina: String;
 mMainUnitCode:String;
 mSirka, mVyska, mHloubka:Extended;
 mStoreCard_ID, mKategorie_ID, mSkupina_ID:string;
 mUnits:TNxCustomBusinessMonikerCollection;
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
         mCode:= NxTrapStrTrim(mTempStr, ';');
         mMainUnitCode:= NxTrapStrTrim(mTempStr, ';');
         mSirka:= NxIBStrToFloat(NxTrapStrTrim(mTempStr, ';'));
         mVyska:= NxIBStrToFloat(NxTrapStrTrim(mTempStr, ';'));
         mHloubka:= NxIBStrToFloat(NxTrapStrTrim(mTempStr, ';'));
         mStoreCard_ID:=GetStoreCard_ID(mOS, mCode);
         if not(NxIsEmptyOID(mStoreCard_ID)) then begin
          mBO:=mOS.CreateObject(Class_StoreCard);
          mBO.Load(mStoreCard_ID,nil);
          mUnits:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
          for j:=0 to mUnits.Count-1 do begin
            mUnitBO:=mUnits.BusinessObject[j];
            if mUnitBO.GetFieldValueAsString('Code')=mbo.GetFieldValueAsString('MainUnitCode') then begin
              mUnitBO.SetFieldValueAsFloat('Width',mSirka);
              mUnitBO.SetFieldValueAsFloat('Height',mVyska);
              mUnitBO.SetFieldValueAsFloat('Depth',mHloubka);
              mUnitBO.SetFieldValueAsInteger('SizeUnit',3);
            end;
          end;
          mbo.Save;
         end;
         {mName:= NxTrapStr(mTempStr, ';');
         mKategorie:= NxTrapStr(mTempStr, ';');
         mSkupina:= NxTrapStr(mTempStr, ';');
         mStoreCard_ID:=GetStoreCard_ID(mOS, mCode);
         if not(NxIsEmptyOID(mStoreCard_ID)) then begin
          mBO:=mOS.CreateObject(Class_StoreCard);
          mBO.Load(mStoreCard_ID,nil);
          mKategorie_ID:=GetKategorie_ID(mOS,mKategorie);
          mSkupina_ID:=GetSkupina_ID(mOS, mSkupina);
          if NxIsEmptyOID(mKategorie_ID) then begin
           mKategorieBO:=mOS.CreateObject('VNRAGRSMSN04XABMBOV11TQUZO');
           mKategorieBO.New;
           mKategorieBO.Prefill;
           mKategorieBO.SetFieldValueAsString('Code',AnsiLeftStr(mKategorie,10));
           mKategorieBO.SetFieldValueAsString('Name',AnsiLeftStr(mKategorie,40));
           mKategorieBO.save;
           mKategorie_ID:=mKategorieBO.oid;
           mKategorieBO.free;
          end;
          if NxIsEmptyOID(mSkupina_ID) then begin
           mSkupinaBO:=mOS.CreateObject('ZILZMIWWMO4OB5UGEDXZXFYWEO');
           mSkupinaBO.New;
           mSkupinaBO.Prefill;
           mSkupinaBO.SetFieldValueAsString('Code',AnsiLeftStr(mSkupina,10));
           mSkupinaBO.SetFieldValueAsString('Name',AnsiLeftStr(mSkupina,40));
           mSkupinaBO.save;
           mSkupina_ID:=mSkupinaBO.oid;
           mSkupinaBO.free;
          end;
          mBO.SetFieldValueAsString('X_kategorie_ID',mKategorie_ID);
          mbo.SetFieldValueAsString('X_produkt_ID',mSkupina_ID);
          if mbo.needsave then mbo.save;
          mbo.Free;
         end;    }

         WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
         WaitWin.StepIt;
      end;
     WaitWin.Stop;
     NxShowSimpleMessage('Nahráno '+IntToStr(mlist.count-1)+' položek.',mSite);
    end;
   end;
end;

function GetStoreCard_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM StoreCards WHERE Code=''%s'' and hidden=''N'' ';
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

function GetKategorie_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM Defrolldata WHERE name=''%s'' and hidden=''N'' and clsid=''VNRAGRSMSN04XABMBOV11TQUZO'' ';
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

function GetSkupina_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM Defrolldata WHERE name=''%s'' and hidden=''N'' and clsid=''ZILZMIWWMO4OB5UGEDXZXFYWEO'' ';
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