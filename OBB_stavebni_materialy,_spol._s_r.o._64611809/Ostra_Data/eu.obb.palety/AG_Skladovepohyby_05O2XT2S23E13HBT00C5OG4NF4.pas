procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  i : integer;
begin

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Paletové saldo';
  mAction.Hint := 'Zobrazí paletové saldo';
  mAction.Category := 'tabList';
  mAction.OnExecute := @PaletoveSaldo;
    //mAction.OnUpdate := @ImportOnUpdate;

end;

Procedure PaletoveSaldo(sender:TComponent);
var
 mList:TStringList;
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mFirm_ID:string;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=msite.BaseObjectSpace;
 mFirm_ID:='';
 if GetFirm_ID(mSite,mFirm_ID) then begin
   if not(NxIsEmptyOID(mFirm_ID)) then begin
      try
       mList:=TStringList.Create;
       mOS.SQLSelect(format('SELECT A.ID FROM StoreDocuments2 A JOIN StoreDocuments SD ON SD.ID=A.Parent_ID '+
                            'LEFT JOIN Firms F ON F.ID=SD.Firm_ID LEFT JOIN StoreCards SC ON SC.ID=A.StoreCard_ID '+
                            'WHERE A.RowType=3 AND (SD.DocQueue_ID IN (SELECT ID FROM DocQueues WHERE DocumentType = ''21'')) '+
                            'AND (SD.DocDate$DATE >=%s and SD.DocDate$DATE < %s ) '+
                            'AND (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) '+
                            'AND (SC.StoreAssortmentGroup_ID = ''E300000101'' ) ',[IntToStr(Trunc(Date-365)),IntToStr(Trunc(Date+1)),mFirm_ID,mFirm_ID]),mList);
       if mList.count>0 then
       CFxReportManager.PrintByIDs(NxCreateContext(mOS),mList,'WBFDIVPW1ZE13HBT00C5OG4NF4','1J60000101',rtoPreview,pekPDF,'','') else
       NxShowSimpleMessage('Nepovedlo se najít žádný pohyb dle podmínek',mSite);
      except
       NxShowSimpleMessage(ExceptionMessage,msite);
      end;
   end;
 end;
end;


Function GetFirm_ID(var ASite : TSiteform; var aFirm_ID : string):Boolean;
var
    mLabel1,mCbCCMaterialComposition: TLabel;
    mEd1, mEd2, mEd3, mEd4, mEd5, mEd6:TEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mCbSupplier: TRollComboEdit;
    mCbCcSupplier: TLabel;
    mCbMaterialComposition: TRollComboEdit;
begin
  Result:=False;
 if ASite <> nil then begin
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 510;
    mForm.Height:= 180;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Zjistí paletové saldo pro';


    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Firma:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCbCCMaterialComposition:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCCMaterialComposition.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCbCCMaterialComposition.Left:= 236;
    mCbCCMaterialComposition.Top:= 10;
    mCbCCMaterialComposition.Width:= 255;

    mCbMaterialComposition:= TRollComboEdit.Create(mForm);
    mCbMaterialComposition.Parent:= mForm;

    mCbMaterialComposition.ClassID:= 'O3OWQQYWYJCL3J0B01K0LEIOE0';
    mCbMaterialComposition.Complete:= True;
    mCbMaterialComposition.Prefilling:= pmNone;
    mCbMaterialComposition.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mCbMaterialComposition.Top:= 10;
    mCbMaterialComposition.Left:= 125;
    mCbMaterialComposition.Width:= 108;
    mCbMaterialComposition.DataText:=aFirm_ID;
    mCbMaterialComposition.ConnectedControl:= mCbCCMaterialComposition;
    mCbMaterialComposition.ConnectedControlField:= 'Name';



    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 45;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 45;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
    //aresult:=mresult;
   // if mButCancel.OnC
    if mResult = 1 then

         aFirm_ID:=mCbMaterialComposition.DataText;

        Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;


begin
end.