uses '.fce';

var
  dSite:TSiteForm;
  mSQL, mParam2:STring;
  mcbDocQueue:TRollComboEdit;
Procedure SetFilterDocQueue(Sender:TRollComboEdit);
var
 msql:STring;
 mAllowed:TstringList;
begin

    mAllowed:=TStringList.create;
    mSQL := 'select id from docqueues where Documenttype=' + QuotedStr('20')+' and hidden=''N'' ';
    dSite.BaseObjectSpace.SQLSelect(mSQL,mAllowed);
    mParam2:=mAllowed.DelimitedText;
    mCbDocqueue.Parameters.Clear;
    mCbDocqueue.Parameters.Add('_Allowed='+mParam2);
    mAllowed.Free;

end;
function InputDialog(var Asite:TSiteForm;var aFirm_ID, aStore_ID, aDivision_ID, aDocQueue_ID, aDescription: String;): Boolean;
var
 mForm:TForm;
 mLabel1, mLabel2, mLabel3, mLabel4:TLabel;
 mCbCcFirm, mCbCcDocQueue, mCbCcDivision, mCbCcStore:Tlabel;
 mcbFirm, mCbDivision, mCbStore:TRollComboEdit;
 mButOk, mButCancel : TButton;
 mResult : integer;
 mEd:TEdit;
begin
  if ASite <> nil then begin
    dsite:=ASite;

    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Width:= 510;
    mForm.Height:= 220;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Údaje pro import';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Řada dokladu';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;
    mLabel2 := TLabel.Create(mForm);
    mLabel2.Parent := mForm;
    mLabel2.Caption := 'Firma:';
    mLabel2.Top := 35;
    mLabel2.Left := 17;
    mLabel2.Height := 13;
    mLabel2.Width := 100;
    mLabel2.Font.Size := 10;
    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Sklad:';
    mLabel3.Top := 60;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    mLabel3.Width := 100;
    mLabel3.Font.Size := 10;
    mLabel4 := TLabel.Create(mForm);
    mLabel4.Parent := mForm;
    mLabel4.Caption := 'Středisko:';
    mLabel4.Top := 85;
    mLabel4.Left := 17;
    mLabel4.Height := 13;
    mLabel4.Width := 100;
    mLabel4.Font.Size := 10;
    mLabel4 := TLabel.Create(mForm);
    mLabel4.Parent := mForm;
    mLabel4 := TLabel.Create(mForm);
    mLabel4.Parent := mForm;
    mLabel4.Caption := 'Popis:';
    mLabel4.Top := 110;
    mLabel4.Left := 17;
    mLabel4.Height := 13;
    mLabel4.Width := 100;
    mLabel4.Font.Size := 10;
    mLabel4 := TLabel.Create(mForm);
    mLabel4.Parent := mForm;

    mCbCcDocQueue:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcDocQueue.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCbCcDocQueue.Left:= 228;
    mCbCcDocQueue.Top:= 10;
    mCbCcDocQueue.Width:= 255;

    mcbDocQueue:= TRollComboEdit.Create(mForm);
    mcbDocQueue.Parent:= mForm;

    mcbDocQueue.ClassID:= 'W2XNBCJK3ZD13ACL03KIU0CLP4';
    mcbDocQueue.Complete:= True;
    mcbDocQueue.OnEnter:=@SetFilterDocQueue;
    mcbDocQueue.ForcedField:= True;
    mcbDocQueue.Prefilling:= pmNone;
    mcbDocQueue.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mcbDocQueue.Top:= 10;
    mcbDocQueue.Left:= 117;
    mcbDocQueue.Width:= 108;
    mcbDocQueue.DataText:=aDocQueue_ID;
    mcbDocQueue.ConnectedControl:= mCbCcDocQueue;
    mcbDocQueue.ConnectedControlField:= 'Name';

    mCbCcFirm:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcFirm.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCbCcFirm.Left:= 228;
    mCbCcFirm.Top:= 35;
    mCbCcFirm.Width:= 255;

    mCbFirm:= TRollComboEdit.Create(mForm);
    mCbFirm.Parent:= mForm;

    mCbFirm.ClassID:= 'O3OWQQYWYJCL3J0B01K0LEIOE0';
    mCbFirm.Complete:= True;
    mCbFirm.ForcedField:= True;
    mCbFirm.Prefilling:= pmNone;
    mCbFirm.TextField:= 'Name';  // položka podle které se bude vyhledávat středisko
    mCbFirm.Top:= 35;
    mCbFirm.Left:= 117;
    mCbFirm.Width:= 208;
    mCbFirm.DataText:=AFirm_ID;
    mCbFirm.ConnectedControl:= mCbCcFirm;
    mCbFirm.ConnectedControlField:= 'Name';

     mCbCcStore:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcStore.Parent:= mForm;
    //mCbCc1.BevelOuter:= bvLowered;            STŘEDISKO
    mCbCcStore.Left:= 228;
    mCbCcStore.Top:= 60;
    mCbCcStore.Width:= 255;

    mCbStore:= TRollComboEdit.Create(mForm);
    mCbStore.Parent:= mForm;

    mCbStore.ClassID:= 'O3ZO2K155FDL3CL100C4RHECN0';
    mCbStore.Complete:= True;
    mCbStore.ForcedField:= True;
    mCbStore.Prefilling:= pmNone;
    mCbStore.TextField:= 'Code';  // položka podle které se bude vyhledávat  firma
    mCbStore.Top:= 60;
    mCbStore.Left:= 117;
    mCbStore.Width:= 108;
    mCbStore.DataText:=aStore_ID;
    mCbStore.ConnectedControl:= mCbCcStore;
    mCbStore.ConnectedControlField:= 'Name';

    mCbCcDivision:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcDivision.Parent:= mForm;
    //mCbCc1.BevelOuter:= bvLowered;            STŘEDISKO
    mCbCcDivision.Left:= 228;
    mCbCcDivision.Top:= 85;
    mCbCcDivision.Width:= 255;

    mCbDivision:= TRollComboEdit.Create(mForm);
    mCbDivision.Parent:= mForm;

    mCbDivision.ClassID:= 'OA5JMX4J2FD135CH000ILPWJF4';
    mCbDivision.Complete:= True;
    mCbDivision.ForcedField:= True;
    mCbDivision.Prefilling:= pmNone;
    mCbDivision.TextField:= 'Code';  // položka podle které se bude vyhledávat  firma
    mCbDivision.Top:= 85;
    mCbDivision.Left:= 117;
    mCbDivision.Width:= 108;
    mCbDivision.DataText:=ADivision_ID;
    mCbDivision.ConnectedControl:= mCbCcDivision;
    mCbDivision.ConnectedControlField:= 'Name';

    mEd := TEdit.Create(mForm);
    mEd.Left := 117;
    mEd.Top := 110;
    mEd.Width := 200;
    mEd.Text := aDescription;
    mEd.Parent := mForm;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 145;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 145;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
   // if mButCancel.OnC
    if mResult = 1 then begin
      aDocQueue_ID:=mcbDocQueue.DataText;
      aDivision_ID:=mCbDivision.DataText;
      aFirm_ID:=mcbFirm.DataText;
      aStore_ID:=mCbStore.DataText;
      aDescription:=mEd.text;
      Result:=True;

    end;
    if not(mResult=1) then Result:=False;
    end;
end;
begin
end.