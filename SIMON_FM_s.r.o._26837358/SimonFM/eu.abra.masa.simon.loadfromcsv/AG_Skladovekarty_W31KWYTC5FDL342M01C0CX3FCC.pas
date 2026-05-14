procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
  mAction:TAction;
begin

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImpUnits';
  mAction.Caption := '##Import hmotnosti##';
  mAction.Hint := 'Označí položky v seznamu dle CSV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImpUnits;
end;


Procedure ImpUnits(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mCode, mStoreCard_ID:string;
 i,j,k:Integer;
 mGrid:TDBGrid;
 mActiveDataSet:TNxDataDataSet;
 mList:TStringList;
 mUnits:TNxCustomBusinessMonikerCollection;
 mSCBO, mUnitBO:TNxCustomBusinessObject;
 mEanStr, mMAINUNITWEIGHT, mWIDTH, mHEIGHT, mDEPTH:string;
begin
  mSite := TComponent(Sender).Site;
  mOS:=msite.BaseObjectSpace;
  mOpenDlg:=TOpenDialog.Create(sender);
  mOpenDlg.Title := 'Import z CSV';
  mOpenDlg.Filter := 'Soubory CSV (*.csv)| *.csv';
  if mOpenDlg.Execute then begin
    try
      //mExcel := CreateOleObject('Excel.Application');
      //mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
      //mSheet := mWB.Sheets[1];
      mList:=TStringList.Create;
      mList.LoadFromFile(mOpenDlg.FileName);
      k:=mList.Count;
          WaitWin.StartProgress('Čekejte, prosím ...', '', k);
            for i:=1 to k-1 do begin
               mCode:=NxTrapStrTrim(mList.Strings[i],';');
               mEanStr:=NxTrapStrTrim(mList.Strings[i],';');
               mMAINUNITWEIGHT:=NxTrapStrTrim(mList.Strings[i],';');
               mWIDTH:=NxTrapStrTrim(mList.Strings[i],';');
               mHEIGHT:=NxTrapStrTrim(mList.Strings[i],';');
               mDEPTH:=NxTrapStrTrim(mList.Strings[i],';');
               mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from StoreCards where hidden=''N'' and code='+QuotedStr(mCode),'');
               if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                 mSCBO:=mOS.CreateObject(Class_StoreCard);
                 mSCBO.Load(mStoreCard_ID,nil);
                 mUnits:=mscbo.GetLoadedCollectionMonikerForFieldCode(mSCBO.GetFieldCode('StoreUnits'));
                 for j:=0 to mUnits.Count-1 do begin
                   mUnitBO:=mUnits.BusinessObject[j];
                   if mUnitBO.GetFieldValueAsString('Code')=mSCBO.GetFieldValueAsString('MainUnitCode') then begin
                       if mUnitBO.GetFieldValueAsFloat('Weight')=0 then begin
                         mUnitBO.SetFieldValueAsFloat('Weight',NxIBStrToFloat(mMAINUNITWEIGHT));
                         mUnitBO.SetFieldValueAsInteger('WeightUnit',1);
                       end;
                       //if (mUnitBO.GetFieldValueAsFloat('Width')+mUnitBO.GetFieldValueAsFloat('Height')+mUnitBO.GetFieldValueAsFloat('Depth')) =0 then begin
                         mUnitBO.SetFieldValueAsFloat('Width',NxIBStrToFloat(mWIDTH)/1000);
                         mUnitBO.SetFieldValueAsFloat('Height',NxIBStrToFloat(mHEIGHT)/1000);
                         mUnitBO.SetFieldValueAsFloat('Depth',NxIBStrToFloat(mDEPTH)/1000);
                         mUnitBO.SetFieldValueAsInteger('SizeUnit',0);
                       //end;
                   end;
                 end;
                 if mSCBO.NeedSave then mSCBO.save;
                 mSCBO.free
               end;
               WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
               WaitWin.StepIt;
          end;
          WaitWin.Stop;
         // mWB.Close;
    finally

    end;
   end;
end;

begin
end.