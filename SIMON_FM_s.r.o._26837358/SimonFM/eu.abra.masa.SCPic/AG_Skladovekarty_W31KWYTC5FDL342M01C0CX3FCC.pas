procedure InitSite_Hook(Self: TSiteForm);
var
  mAct: TBasicAction;
begin
  mAct := Self.GetNewAction;
  mAct.Caption := '##Obrázek hromadně##';
  mAct.Category := 'tabList';
  mAct.OnExecute := @AddPicture;
end;

Procedure AddPicture(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 i,j,k, mResult:integer;
 mBO, mNewBO:TNxCustomBusinessObject;
 mPictures:TNxCustomBusinessMonikerCollection;
 mSelectedList:TStringList;
 mOpenDlg : TOpenDialog;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mSelectedList:=TStringList.Create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mSelectedList);
 if mSelectedList.Count>0 then begin
   if NxMessageBox('Dotaz','Přejete si přidat obrázek k '+IntToStr(mSelectedList.count)+' kartám?' , mdConfirm, mdbYesNo, 0, 0, False, mSite)= mrYes then begin
     mOpenDlg := TOpenDialog.Create(Sender);
     if mOpenDlg.Execute then begin
       mResult:=NxMessageBox('Dotaz','Smazat obrázky před nahráním?' , mdConfirm, mdbYesNo, 0, 0, False, mSite);
       for i:=0 to mSelectedList.count-1 do begin
         mBO:=mOS.CreateObject(Class_StoreCard);
         mBO.Load(mSelectedList.Strings[i],nil);
         mPictures:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Pictures'));
         if mResult=mrYes then begin
           for j:=0 to mPictures.Count-1 do begin
             mPictures.BusinessObject[j].MarkForDelete;
           end;
         end;
         mNewBO:=mPictures.AddNewObject;
         mNewBO.SetFieldValueAsString('Picture_ID.PictureTitle',mBO.GetFieldValueAsString('Name'));
         mNewBO.SetFieldValueAsBoolean('Picture_ID.ExternalFile',true);
         mNewBO.SetFieldValueAsString('Picture_ID.PathAndFileName',mOpenDlg.FileName);
         if mBO.NeedSave then mbo.save;
         mBO.free;
       end;
     end;
     TBusRollSiteForm(mSite).RefreshData;
     TBusRollSiteForm(mSite).DataSet.SeekID(mSelectedList.Strings[i]);
     NxShowSimpleMessage('Hotovo.',mSite);
   end;
 end;
end;

begin
end.