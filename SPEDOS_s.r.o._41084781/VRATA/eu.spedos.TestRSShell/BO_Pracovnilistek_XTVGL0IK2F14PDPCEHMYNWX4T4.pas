{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mCashDesk_ID, mDocqueue_ID:String;
 mKarta:Boolean;
 mResult:integer;
 mAmount:Extended;
begin
  if CFxNxRuntime.NxGetEnvironmentType=reOLEAutomation then begin
  { GetPaymentDate(nil, mCashDesk_ID,mDocqueue_ID,mKarta,mResult,mAmount);

   NxShowSimpleMessage('jsem tu, nemám site '+mCashDesk_ID,nil); }
  end;
end;


Function GetPaymentDate(var ASite : TSiteform; var aCashDesk_ID, aDocqueue_ID:String; var aKarta:Boolean;var aResult:integer; var aAmount:Extended;):Boolean;
var
    mLabel1: TLabel;
    mBEd1: TCheckBox;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mAllowed:TStringList;
    mSQL:String;
    mCbCashDesk, mCbDocQueue: TRollComboEdit;
    mCbCcCashDesk,mCbCcDocQueue: TLabel;
    tempSite:TSiteForm;
begin
 if ASite = nil then begin

    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 410;
    mForm.Height:= 230;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Zadejte údaje pro platbu';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Částka k úhradě:    '+NxFormatNumeric('0.00,',aAmount);
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;
    mLabel1.Font.Color :=clRed;


    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Pokladna:';
    mLabel1.Top := 35;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;
    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Řada dokladů:';
    mLabel1.Top := 60;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;
    {mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Kartou?';
    mLabel1.Top := 85;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;  }
    if aKarta then begin
    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Proveďte platbu na terminálu před potvrzením tohoto okna.'+chr(13)+chr(10)+'(Kliknutí OK vytvoří fiskalizované pokladní doklady)';
    mLabel1.Top := 110;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;
    end;
    mCbCcCashDesk:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcCashDesk.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCbCcCashDesk.Left:= 236;
    mCbCcCashDesk.Top:= 35;
    mCbCcCashDesk.Width:= 255;

    mCbCashDesk:= TRollComboEdit.Create(mForm);
    mCbCashDesk.Parent:= mForm;

    mCbCashDesk.ClassID:= 'SXDAHWVT5ND133N4010DELDFKK';
    mCbCashDesk.Complete:= True;
    mCbCashDesk.Prefilling:= pmNone;
    mCbCashDesk.TextField:= 'Name';  // položka podle které se bude vyhledávat středisko
    mCbCashDesk.Top:= 35;
    mCbCashDesk.Left:= 125;
    mCbCashDesk.Width:= 108;
    mCbCashDesk.DataText:=aCashDesk_ID;
    mCbCashDesk.OnExit:=@SetFilter;
    mCbCashDesk.ConnectedControl:= mCbCcCashDesk;
    mCbCashDesk.ConnectedControlField:= 'Name';

    mCbCcDocQueue:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcDocQueue.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCbCcDocQueue.Left:= 236;
    mCbCcDocQueue.Top:= 60;
    mCbCcDocQueue.Width:= 255;

    mCbDocQueue:= TRollComboEdit.Create(mForm);
    mCbDocQueue.Parent:= mForm;

    mCbDocQueue.ClassID:= 'W2XNBCJK3ZD13ACL03KIU0CLP4';
    mCbDocQueue.Complete:= True;
    mCbDocQueue.Prefilling:= pmNone;
    mCbDocQueue.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mCbDocQueue.Top:= 60;
    mCbDocQueue.Left:= 125;
    mCbDocQueue.Width:= 108;
    mCbDocQueue.DataText:=aDocqueue_ID;

    mCbDocQueue.ConnectedControl:= mCbCcDocQueue;
    mCbDocQueue.ConnectedControlField:= 'Name';


    {mBEd1:= TCheckBox.Create(mForm);
    mBEd1.Left := 125;
    mBEd1.Top := 85;
    mBEd1.Caption:='Platba kartou';
    mBEd1.Checked := aKarta;
    mBEd1.Parent := mForm;
    mBEd1.ReadOnly := True; }


    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 160;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 160;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;

    Result:=False;
    mResult := mForm.ShowModal(ASite);
    aResult:= mResult;
   // if mButCancel.OnC
    if mResult = 1 then
         aCashDesk_ID:=mCbCashDesk.DataText;
         aDocqueue_ID:=mCbDocQueue.DataText;
         //aKarta:= mBEd1.Checked;
        Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;


begin
end.