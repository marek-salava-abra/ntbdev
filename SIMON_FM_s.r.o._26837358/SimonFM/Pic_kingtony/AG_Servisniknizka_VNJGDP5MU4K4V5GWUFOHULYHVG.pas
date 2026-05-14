procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actKingTonyPic';
  mAction.Caption := 'nahrání obrázků KT';
  mAction.Hint := 'Naimportuje obrázky ke kartám, kde nejsou';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportData;
end;

Procedure ImportData(sender:TComponent);
var
 mList:TStringList;
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 i,j,k, mIntPosindex:integer;
 mBO, mNewBO:TNxCustomBusinessObject;
 mPictures:TNxCustomBusinessMonikerCollection;
begin
  mSite:=TComponent(sender).DynSite;
  mOS:=mSite.BaseObjectSpace;
  mList:=tstringlist.create;
  mOS.SQLSelect('SELECT a.id FROM StoreCards A WHERE not(A.specification2='''') and ((A.Producer_ID IN (SELECT ID FROM Firms WHERE ID=''3NA4000101'' or Firm_ID=''3NA4000101'')) ) AND (A.Hidden = ''N'' ) AND (not(a.id in (select parent_id from storecardpictures))) ',mList);
  if mList.count>0 then begin
    k:=mlist.Count;
    WaitWin.StartProgress('Čekejte, prosím ...', '', k);
    for i:=0 to k-1 do begin
        mbo:=mOS.CreateObject(Class_StoreCard);
        mBO.Load(mList.Strings[i],nil);
        mPictures:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Pictures'));
          if FileExists('\\aserver\Public\KT_Foto\'+mBO.GetFieldValueAsString('specification2')+'.jpg') then begin
                 mNewBO:=mPictures.AddNewObject;
                 mNewBO.SetFieldValueAsString('Picture_ID.PictureTitle',mBO.GetFieldValueAsString('Name'));
                 mNewBO.SetFieldValueAsBoolean('Picture_ID.ExternalFile',true);
                 mNewBO.SetFieldValueAsString('Picture_ID.PathAndFileName','\\aserver\Public\KT_Foto\'+mBO.GetFieldValueAsString('specification2')+'.jpg');
                 //mNewBO.SetFieldValueAsBoolean('X_AES_Send',true);
              for j:=1 to 9 do begin
                 if FileExists('\\aserver\Public\KT_Foto\'+mBO.GetFieldValueAsString('specification2')+'_'+inttostr(j)+'.jpg') then begin
                  mNewBO:=mPictures.AddNewObject;
                  mNewBO.SetFieldValueAsString('Picture_ID.PictureTitle',mBO.GetFieldValueAsString('Name'));
                  mNewBO.SetFieldValueAsBoolean('Picture_ID.ExternalFile',true);
                  mNewBO.SetFieldValueAsString('Picture_ID.PathAndFileName','\\aserver\Public\KT_Foto\'+mBO.GetFieldValueAsString('specification2')+'_'+inttostr(j)+'.jpg');
                  //mNewBO.SetFieldValueAsBoolean('X_AES_Send',true);
                 end;
              end;
          end;
        if mBO.NeedSave then mBO.Save;
        mBO.Free;
        WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
        WaitWin.StepIt;
    end;
    WaitWin.Stop;
  end;

end;


begin
end.