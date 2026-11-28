var

    mCbCashDesk, mCbDocQueue: TRollComboEdit;
    mCbCcCashDesk,mCbCcDocQueue: TLabel;
    tempSite:TSiteForm;
    //mMaterialSQL2,mMAterialParam2:String;
Function GetPaymentDate(var ASite : TSiteform; var aCashDesk_ID, aDocqueue_ID:String; var aKarta:Boolean;var aResult:integer; var aAmount:Extended;):Boolean;
var
    mLabel1: TLabel;
    mBEd1: TCheckBox;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mAllowed:TStringList;
    mSQL:String;

begin
 if ASite <> nil then begin
    tempSite:=ASite;
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
    mLabel1.Caption := 'Proveďte platbu na terminálu před potvrzením tohoto okna.'+chr(13)+chr(10)+'(Kliknutí OK vytvoří pokladní doklady a odešle EET)';
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
Function GetPaymentDate2(var ASite : TSiteform; var aCashDesk_ID, aDocqueue_ID:String; var aKarta:Boolean;var aResult:integer; var aAmount:Extended;):Boolean;
var
    mLabel1: TLabel;
    mBEd1: TCheckBox;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mAllowed:TStringList;
    mSQL:String;
    mNumEd:TNumEdit;

begin
 if ASite <> nil then begin
    tempSite:=ASite;
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 410;
    mForm.Height:= 230;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Zadejte údaje pro platbu';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Částka k úhradě:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mNumEd:= tNumEdit.Create(mForm);
    mNumEd.Left := 125;
    mNumEd.Top := 15;
    mNumEd.Value:=aAmount;
    mNumEd.Parent := mForm;
    if aKarta then mNumEd.DecimalPlaces := 2 else mNumEd.DecimalPlaces:=0;


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
    mLabel1.Font.Size := 10;}
    if aKarta then begin
    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Proveďte platbu na terminálu před potvrzením tohoto okna.'+chr(13)+chr(10)+'(Kliknutí OK vytvoří pokladní doklady a odešle EET)';
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
    mCbCashDesk.Top:= 37;
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
    mCbDocQueue.Top:= 62;
    mCbDocQueue.Left:= 125;
    mCbDocQueue.Width:= 108;
    mCbDocQueue.DataText:=aDocqueue_ID;

    mCbDocQueue.ConnectedControl:= mCbCcDocQueue;
    mCbDocQueue.ConnectedControlField:= 'Name';

    {
    mBEd1:= TCheckBox.Create(mForm);
    mBEd1.Left := 125;
    mBEd1.Top := 85;
    mBEd1.Caption:='Platba kartou';
    mBEd1.Checked := aKarta;
    mBEd1.Parent := mForm;
    mbed1.ReadOnly := True;  }


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
         aAmount:=mNumEd.value;
        Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;
Procedure SetFilter(Sender:TRollComboEdit);
var

 mAllowed:TstringList;
 mSQL:String;
begin
    if NxIsEmptyOID(mCbCashDesk.DataText) then begin
     mAllowed:=TStringList.create;
     mSQL:='Select id from docqueues where DocumentType=''05'' ';
     tempSite.BaseObjectSpace.SQLSelect(mSQL,mAllowed);
     mCbDocQueue.Parameters.Clear;
     mCbDocQueue.Parameters.Add('_Allowed='+mAllowed.DelimitedText);
    end;
    if not(NxIsEmptyOID(mCbCashDesk.DataText)) then begin
     mAllowed:=TStringList.create;
     mSQL:='select D.id from docqueues d left join cashdesksdocQueues cdd on d.id=cdd.docqueue_id where d.documenttype=''05'' and cdd.cashdesk_id=''%s'' ';
     tempSite.BaseObjectSpace.SQLSelect(format(mSQL,[mCbCashDesk.DataText]),mAllowed);
     mCbDocQueue.Parameters.Clear;
     mCbDocQueue.Parameters.Add('_Allowed='+mAllowed.DelimitedText);
    end;
end;

Function GetPaymentType(var ASite : TSiteform; var aMessage:string; var aTempResult:Integer):boolean;
var
    mLabel1: TLabel;
    mBEd1: TCheckBox;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mAllowed:TStringList;
    mSQL:String;
    mNumEd:TNumEdit;

begin
 if ASite <> nil then begin
    tempSite:=ASite;
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 410;
    mForm.Height:= 130;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Vyberte způsob úhrady';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := aMessage;
    mLabel1.Top := 15;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 580;
    mLabel1.Font.Size := 10;


    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Kartou';
    mButOk.Top := 60;
    mButOk.Left := 152;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Hotově';
    mButCancel.Top := 60;
    mButCancel.Left := 220;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;

    Result:=False;
    aTempResult := mForm.ShowModal(ASite);


    if aTempResult = 1 then Result:=true;
    if aTempResult = 2 then Result:=True;
    mForm.free;
  end;
end;

begin
end.