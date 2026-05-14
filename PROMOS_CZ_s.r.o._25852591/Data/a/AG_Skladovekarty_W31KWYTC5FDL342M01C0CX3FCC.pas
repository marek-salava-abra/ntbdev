procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mUser : TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Pohyby';
    mAction.Hint := 'Pohyby';
    mAction.Category := 'tabList';
    mAction.OnExecute := @GetStoreMO;

    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'import ean';
    mAction.Hint := 'Pohyby';
    mAction.Category := 'tabList';
    mAction.OnExecute := @importean2;


end;
Procedure importean2(sender:TComponent);
var
 mSite:TSiteForm;
 mList:TStringList;
 mStoreCardBO, mSupplierBO:TNxCustomBusinessObject;
 mUnits:TNxCustomBusinessMonikerCollection;
 i,j:integer;
 mOS:TNxCustomObjectSpace;
 mQuantity:Extended;
begin
 mSite:=TComponent(sender).BusRollSite;
 mlist:=TStringList.create;
 mOS:=mSite.BaseObjectSpace;
 TBusRollSiteForm(mSite).List.GetSelectedId(mList);
 for i:=0 to mlist.Count-1 do begin
    mQuantity:=0;
    mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
    mStoreCardBO.Load(mlist.Strings[i],nil);
    mUnits:=mStoreCardBO.GetLoadedCollectionMonikerForFieldCode(mStoreCardBO.GetFieldCode('StoreUnits'));
    for j:=0 to mUnits.count-1 do begin
        if mUnits.BusinessObject[j].GetFieldValueAsString('Code')='bal' then mQuantity:= mUnits.BusinessObject[j].GetFieldValueAsFloat('UnitRate');
    end;
    if mQuantity>0 then begin
               mSupplierBO:=msite.BaseObjectSpace.CreateObject(Class_Supplier);
               mSupplierBO.new;
               mSupplierBo.prefill;
               mSupplierBO.SetFieldValueAsString('StoreCard_ID',mStoreCardBO.OID);
               mSupplierBO.SetFieldValueAsString('Firm_ID','TT10000101');
               mSupplierBO.SetFieldValueAsString('Qunit',mStoreCardBO.GetFieldValueAsString('MainUnitcode'));
               mSupplierbo.SetFieldValueAsFloat('Packing',mQuantity);
               msupplierbo.save;
               msupplierbo.free;
    end;
    mStoreCardBO.free;
 end;
end;

Procedure importean(sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg:TOpenDialog;
 i,j:integer;
 mStoreCardBO, mUnitBO, mSupplierBO:TNxCustomBusinessObject;
 mUnits:TNxCustomBusinessMonikerCollection;
 mList:TStringList;
 mStoreCard_ID, mCode, mEan, mSupplier_ID:string;
 mQuantity:extended;
begin
  mSite:=TComponent(sender).BusRollSite;
  mOpenDlg := TOpenDialog.Create(Sender);
  if mOpenDlg.Execute then begin
      mList := TStringLIst.Create;
      mlist.LoadFromFile(mOpenDlg.FileName);
      for i:=0 to mList.Count-1 do begin
         mCode:=NxTrapStr(mlist.Strings[i],';');
         mQuantity:=NxIBStrToFloat(NxTrim(NxTrapStr(mlist.strings[i],';'),' '));
         //if i=0 then NxShowSimpleMessage(mcode, mSite);
         //mCode:=Copy(mCode,2,20);
         //if i=0 then NxShowSimpleMessage(mcode, mSite);
         //if Length(mEan)>14 then mEan:='';
         mStoreCard_ID:=GetStoreCard_ID(msite.BaseObjectSpace,mCode);
         if not(NxIsEmptyOID(mStoreCard_ID)) then begin
           if mQuantity>0 then begin
             mStoreCardBO:=msite.BaseObjectSpace.CreateObject(Class_StoreCard);
             mStoreCardBO.Load(mStoreCard_ID,nil);
             mUnits:=mStoreCardBO.GetLoadedCollectionMonikerForFieldCode(mStoreCardbo.GetFieldCode('StoreUnits'));
             {for j:=0 to mUnits.Count-1 do begin
               if mUnits.BusinessObject[j].GetFieldValueAsString('Code')=mStoreCardBO.GetFieldValueAsString('MainUnitCode') then mUnits.BusinessObject[j].SetFieldValueAsString('Ean',mEan);
             end; }
             mUnitBO:=mUnits.AddNewObject;
             mUnitBO.prefill;
             mUnitBo.SetFieldValueAsString('Code','bal');
             mUnitBo.SetFieldValueAsFloat('UnitRate',mQuantity);
             mSupplier_ID:=GetSupplier_ID(mSite.BaseObjectSpace,mStoreCard_ID);
             if not(NxIsEmptyOID(mSupplier_ID)) then begin
               mSupplierBO:=msite.BaseObjectSpace.CreateObject(Class_Supplier);
               mSupplierBO.load(mSupplier_ID,nil);
               mSupplierbo.SetFieldValueAsFloat('Packing',mQuantity);
               msupplierbo.save;
               msupplierbo.free;

             end;
             mStoreCardBO.save;
             mStoreCardBO.free;
           end;
         end;
      end;
  end;
end;


procedure GetStoreMO(Sender:Tcomponent);
var
 mSite:TSiteForm;
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 mDate, mDate2:extended;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mBO:=TBusRollSiteForm(mSite).CurrentObject;
 if DejData(mDate,mDate2, msite) then begin
     mList:=TStringList.Create;
     mbo.ObjectSpace.SQLSelect(format('select sd2.id from storedocuments sd left join storedocuments2 sd2 on sd2.parent_id=sd.id where sd2.storecard_id=''%s'' and sd.docdate$date>%s and sd.docdate$date<%s',[mbo.oid,IntToStr(Trunc(mDate)),IntToStr(Trunc(mDate2))]),mList);
     if mlist.Count>0 then begin
      CFxReportManager.PrintByIDs(NxCreateContext_1(mBO),mlist,'WBFDIVPW1ZE13HBT00C5OG4NF4','1N00000101',rtoPreview,pekPDF,'','');


     end;
     mlist.Free;
 end;

end;

Function DejData(var aDateFrom, aDateTo:Extended; var asite:TSiteForm):boolean;

 var
  mForm: TForm;
  mLab: TLabel;
  mEd1: TNumEdit;
  mEd2, mEd3: TDateEdit;
  mResult: integer;
  mButOK, mButCancel: TButton;
begin
  mForm := TForm.Create(aSite);
  try
    Result:=False;
    mForm.Caption := 'Zadejte datumy';
    mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsDialog;
    mform.Position:=poScreenCenter;
    mForm.Width := 350;
    mForm.Height := 145;
    mForm.Scaled := False;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 10;
    mLab.Caption := 'Datum od';
    mLab.Parent := mForm;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 35;
    mLab.Parent := mForm;
    mEd2 := tDateEdit.Create(mForm);
    mEd2.Left := 110;
    mEd2.Top := 6;
    mEd2.Width := 100;
    mEd2.Parent := mForm;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 35;
    mLab.Caption := 'Datum do';
    mLab.Parent := mForm;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 35;
    mLab.Parent := mForm;
    mEd3 := tDateEdit.Create(mForm);
    mEd3.Left := 110;
    mEd3.Top := 31;
    mEd3.Width := 100;
    mEd3.Parent := mForm;
    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 70;
    mButOk.Left := 152;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 70;
    mButCancel.Left := 220;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    mResult := mForm.Showmodal(asite);
    if mResult = 1 then
      //ShowMessage('Řádně jste zadal:' + Chr(13) + Chr(10) + mEd1.Text + Chr(13) + Chr(10) + mEd2.Text);

      aDateFrom:=mEd2.Date;
      aDateTo:=mEd3.Date;
      Result:=True;
  finally
   // mForm.Free;
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

function GetSupplier_ID(AOS : TNxCustomObjectSpace; aStoreCard_ID : string) : string;
const
  cSQL = 'SELECT ID FROM Suppliers WHERE StoreCard_ID=''%s'' and Firm_ID=''TT10000101'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;


begin
end.