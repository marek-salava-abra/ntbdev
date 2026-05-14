Function GetDataForReturn(var ASite : TSiteform; var aStore_ID, aICNDQ_ID, aVRDQ_ID : string; var aDate:Extended;var aResult:integer;):Boolean;
var
    mLabel1,mCbCCMaterialComposition, mCbCCDivision, mCBICN, mCBVR: TLabel;
    mEd1, mEd2, mEd3, mEd4, mEd5, mEd6:TEdit;
    mNumEd:TNumEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mDed:TDateEdit;
    mCbMaterialComposition, mICNDQ, mVRDQ: TRollComboEdit;
    mAllowedICN, mAllowedVR:TStringList;
    mParICN, mParVR:String;
begin
 if ASite <> nil then begin
    mAllowedICN:=TStringList.create;
    mAllowedVR:=TStringList.create;
    ASite.BaseObjectSpace.SQLSelect('Select id from docqueues where documenttype='+QuotedStr('60'),mAllowedICN);
    ASite.BaseObjectSpace.SQLSelect('Select id from docqueues where documenttype='+QuotedStr('23'),mAllowedVR);
    mParICN:=mAllowedICN.DelimitedText;
    mParVR:=mAllowedVR.DelimitedText;
    Result:=False;
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 510;
    mForm.Height:= 220;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Údaje pro vracení:';


    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Sklad:';
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

    mCbMaterialComposition.ClassID:= 'O3ZO2K155FDL3CL100C4RHECN0';
    mCbMaterialComposition.Complete:= True;
    mCbMaterialComposition.Prefilling:= pmNone;
    mCbMaterialComposition.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mCbMaterialComposition.Top:= 10;
    mCbMaterialComposition.Left:= 110;
    mCbMaterialComposition.Width:= 108;
    mCbMaterialComposition.DataText:=aStore_ID;
    mCbMaterialComposition.ConnectedControl:= mCbCCMaterialComposition;
    mCbMaterialComposition.ConnectedControlField:= 'Name';


    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Dobropisy:';
    mLabel1.Top := 30;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCBICN:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCBICN.Parent:= mForm;
    mCBICN.Left:= 236;
    mCBICN.Top:= 31;
    mCBICN.Width:= 255;

    mICNDQ:= TRollComboEdit.Create(mForm);
    mICNDQ.Parent:= mForm;

    mICNDQ.ClassID:= 'W2XNBCJK3ZD13ACL03KIU0CLP4';
    mICNDQ.Complete:= True;
    mICNDQ.Prefilling:= pmNone;
    mICNDQ.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mICNDQ.Top:= 31;
    mICNDQ.Left:= 110;
    mICNDQ.Width:= 108;
    mICNDQ.DataText:=aICNDQ_ID;
    mICNDQ.Parameters.Clear;
    mICNDQ.Parameters.Add('_Allowed='+mParICN);
    mICNDQ.ConnectedControl:= mCBICN;
    mICNDQ.ConnectedControlField:= 'Name';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Vratky:';
    mLabel1.Top := 50;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCBVR:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCBVR.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCBVR.Left:= 236;
    mCBVR.Top:= 51;
    mCBVR.Width:= 255;

    mVRDQ:= TRollComboEdit.Create(mForm);
    mVRDQ.Parent:= mForm;

    mVRDQ.ClassID:= 'W2XNBCJK3ZD13ACL03KIU0CLP4';
    mVRDQ.Complete:= True;
    mVRDQ.Prefilling:= pmNone;
    mVRDQ.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mVRDQ.Top:= 51;
    mVRDQ.Left:= 110;
    mVRDQ.Width:= 108;
    mVRDQ.DataText:=aVRDQ_ID;
    mVRDQ.Parameters.Clear;
    mVRDQ.Parameters.Add('_Allowed='+mParVR);
    mVRDQ.ConnectedControl:= mCBVR;
    mVRDQ.ConnectedControlField:= 'Name';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Datum:';
    mLabel1.Top := 70;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mDed := TDateEdit.Create(mForm);
    mDed.Left := 110;
    mDed.Top := 71;
    mDed.Width := 80;
    mDed.Date := aDate;
    mDed.Parent := mForm;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
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
    //aresult:=mresult;
   // if mButCancel.OnC
    if mResult = 1 then
         aResult:=1;
         aStore_ID:=mCbMaterialComposition.DataText;
         aICNDQ_ID:=mICNDQ.DataText;
         aVRDQ_ID:=mVRDQ.DataText;
         aDate:=mDed.Date;
         Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;

begin
end.