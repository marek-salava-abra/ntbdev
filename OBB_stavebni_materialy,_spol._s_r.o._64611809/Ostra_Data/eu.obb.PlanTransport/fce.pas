var
    mCbRole :TRollComboEdit;
    mSQL2,mParam2, mSQL3,mParam3:String;
    dSite:TSiteForm;
    dActQueue_ID:string;
Procedure SetFilterBO(Sender:TRollComboEdit);
var

 mAllowed:TstringList;
begin

    if not(NxIsEmptyOID(dActQueue_ID)) then begin
    mAllowed:=TStringList.create;
    mSQL3 := 'select s.id from securityroles s left join userdata u on u.id=s.id where u.fieldcode=2000001 and u.clsid=''QRDGQ1DV2CU4D3TOUMORZ0LWIW'' and u.stringfieldvalue=' + QuotedStr(dActQueue_ID)+' ';
    dSite.BaseObjectSpace.SQLSelect(mSQL3,mAllowed);
    mParam3:=mAllowed.DelimitedText;
    mCbRole.Parameters.Clear;
    mCbRole.Parameters.Add('_Allowed='+mParam3);
    mAllowed.Free;


    end;
end;



Function GetTransParam(var ASite : TSiteform; var aSolverRole_ID, aDescription, aActQueue_ID : string;var aStartDate:Extended; var aRuka, aVlek:Boolean):Boolean;
var
    mLabel1,mCbCCRole: TLabel;
    mEd1, mEd2, mEd3, mEd4, mEd5, mEd6:TEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mDateEd: TDateTimeEdit;
    mBED1, mBED2:TCheckBox;
begin
 if ASite <> nil then begin
    dSite:=ASite;
    dActQueue_ID:=aActQueue_ID;
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 510;
    mForm.Height:= 190;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Zadejte údaje pro dopravu';


    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Dopravce:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCbCCRole:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCCRole.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCbCCRole.Left:= 236;
    mCbCCRole.Top:= 10;
    mCbCCRole.Width:= 255;

    mCbRole:= TRollComboEdit.Create(mForm);
    mCbRole.Parent:= mForm;

    mCbRole.ClassID:= '0FKKTBSSQKB4B3RLYBSJFFAFUW';
    mCbRole.Complete:= True;
    mCbRole.Prefilling:= pmNone;
    mCbRole.TextField:= 'ShortName';  // položka podle které se bude vyhledávat středisko
    mCbRole.Top:= 10;
    mCbRole.Left:= 125;
    mCbRole.Width:= 108;
    mCbRole.OnEnter:=@SetFilterBO;
    mCbRole.DataText:=aSolverRole_ID;
    mCbRole.ConnectedControl:= mCbCCRole;
    mCbRole.ConnectedControlField:= 'Name';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Popis:';
    mLabel1.Top := 37;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mEd1 := TEdit.Create(mForm);
    mEd1.parent :=mForm;
    mEd1.top := 35;
    mEd1.left := 125;
    med1.Width := 150;

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Datum:';
    mLabel1.Top := 62;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mDateEd := TDateTimeEdit.Create(mForm);
    mDateEd.Parent:=mForm;
    mDateEd.top := 60;
    mDateEd.Left := 125;
    mdateed.Kind := dtekDateTime;

    mBEd1:= TCheckBox.Create(mForm);
    mBEd1.Left := 125;
    mBEd1.Top := 85;
    mBEd1.Caption:='HR';
    mBEd1.Checked := aRuka;
    mBEd1.Parent := mForm;

    mBEd2:= TCheckBox.Create(mForm);
    mBEd2.Left := 225;
    mBEd2.Top := 85;
    mBEd2.Caption:='Vlek';
    mBEd2.Checked := aVlek;
    mBEd2.Parent := mForm;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 105;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 105;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
    //aresult:=mresult;
   // if mButCancel.OnC
    if mResult = 1 then

         aSolverRole_ID:=mCbRole.DataText;
         aDescription:=med1.Text;
         aStartDate:=mDateEd.DateTime;
         aRuka:=mBED1.checked;
         avlek:=mbed2.Checked;
        Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;

begin
end.