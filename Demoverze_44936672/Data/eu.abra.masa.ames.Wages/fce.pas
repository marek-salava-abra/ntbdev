Function GetData(var ASite : TSiteform; var aDivision_ID, aINTDQ_ID: string; var aDate:Extended;var aSpolecnik: boolean; var aResult:integer;):Boolean;
var
    mLabel1,mCbCCMaterialComposition, mCbCCDivision, mCBINT, mCBVR: TLabel;
    mEd1, mEd2, mEd3, mEd4, mEd5, mEd6:TEdit;
    mNumEd:TNumEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mDed:TDateEdit;
    mCbMaterialComposition, mINTDQ, mVRDQ: TRollComboEdit;
    mAllowedINT, mAllowedVR:TStringList;
    mParINT:String;
    mBEd01:TCheckBox;
begin
 if ASite <> nil then begin
    mAllowedINT:=TStringList.create;
    mAllowedVR:=TStringList.create;
    ASite.BaseObjectSpace.SQLSelect('Select id from docqueues where documenttype='+QuotedStr('00'),mAllowedINT);
    mParINT:=mAllowedINT.DelimitedText;
    Result:=False;
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 510;
    mForm.Height:= 220;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Údaje pro import:';


    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Středisko:';
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

    mCbMaterialComposition.ClassID:= 'OA5JMX4J2FD135CH000ILPWJF4';
    mCbMaterialComposition.Complete:= True;
    mCbMaterialComposition.Prefilling:= pmNone;
    mCbMaterialComposition.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mCbMaterialComposition.Top:= 10;
    mCbMaterialComposition.Left:= 110;
    mCbMaterialComposition.Width:= 108;
    mCbMaterialComposition.DataText:=aDivision_ID;
    mCbMaterialComposition.ConnectedControl:= mCbCCMaterialComposition;
    mCbMaterialComposition.ConnectedControlField:= 'Name';


    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Řada:';
    mLabel1.Top := 30;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCBINT:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCBINT.Parent:= mForm;
    mCBINT.Left:= 236;
    mCBINT.Top:= 31;
    mCBINT.Width:= 255;

    mINTDQ:= TRollComboEdit.Create(mForm);
    mINTDQ.Parent:= mForm;

    mINTDQ.ClassID:= 'W2XNBCJK3ZD13ACL03KIU0CLP4';
    mINTDQ.Complete:= True;
    mINTDQ.Prefilling:= pmNone;
    mINTDQ.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mINTDQ.Top:= 31;
    mINTDQ.Left:= 110;
    mINTDQ.Width:= 108;
    mINTDQ.DataText:=aINTDQ_ID;
    mINTDQ.Parameters.Clear;
    mINTDQ.Parameters.Add('_Allowed='+mParINT);
    mINTDQ.ConnectedControl:= mCBINT;
    mINTDQ.ConnectedControlField:= 'Name';



    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Datum:';
    mLabel1.Top := 50;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mDed := TDateEdit.Create(mForm);
    mDed.Left := 110;
    mDed.Top := 51;
    mDed.Width := 80;
    mDed.Date := aDate;
    mDed.Parent := mForm;

    mBEd01:= TCheckBox.Create(mForm);
    mBEd01.Left := 17;
    mBEd01.Top := 74;
    mBEd01.Caption :='Společníci?';
    mBEd01.Checked := False;
    mBEd01.Parent := mForm;

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
         aDivision_ID:=mCbMaterialComposition.DataText;
         aINTDQ_ID:=mINTDQ.DataText;
         aDate:=mDed.Date;
         Result:=true;
         aSpolecnik:=mBEd01.Checked;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;

begin
end.