var
  gProgressForm : TForm;


procedure ProgressInit(ASite : TSiteForm; ACaption : string; AMaxValue : Integer);
begin
  gProgressForm:= TForm.Create(ASite.GetSiteAppForm);
  gProgressForm.BorderStyle:= bsToolWindow;
  gProgressForm.Position:= poScreenCenter;
  gProgressForm.ClientWidth:= 220;
  gProgressForm.ClientHeight:= 25;
  gProgressForm.Caption := ACaption;

  with TProgressBar.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= 2;
    Top:= gProgressForm.ClientHeight - Height - 2;
    Width:= gProgressForm.ClientWidth - 4;
    Name:= 'prgBar';
    Max := AMaxValue
  end;

  gProgressForm.Show();
  Application.ProcessMessages();
end;

procedure ProgressDispose;
begin
  gProgressForm.Close();
end;

procedure ProgressSetMax(aValue: Integer);
begin
  TProgressBar(gProgressForm.FindChildControl('prgBar')).Max:= aValue;
end;

procedure ProgressSetPos(aValue: Integer);
begin
  TProgressBar(gProgressForm.FindChildControl('prgBar')).Position:= aValue + 1;
  TProgressBar(gProgressForm.FindChildControl('prgBar')).Repaint;

  gProgressForm.Refresh();
  gProgressForm.BringToFront();

  Application.ProcessMessages();
end;

function FrmTeplomer(aParentForm: TForm): TForm;
var Frm: TForm;
begin
  Frm:= TForm.Create(aParentForm);
  Frm.BorderStyle:= bsDialog;
  Frm.Position:= poScreenCenter;
  Frm.ClientWidth:= 150;
  Frm.ClientHeight:= 30;
  with TProgressBar.Create(Frm) do
  begin
    Parent:= Frm;
    Left:= 2;
    Top:= Frm.ClientHeight - Height - 2;
    Width:= Frm.ClientWidth - 4;
    Name:= 'prgBar'
  end;
  Result:= Frm;
end;

Function GetData(var ASite : TSiteform; var aFirm_ID:string; var aResult:integer;):Boolean;
var
    mLabel1,mCbCCMaterialComposition, mCbCCDivision, mCBBOD, mCBVR: TLabel;
    mEd1, mEd2, mEd3, mEd4, mEd5, mEd6:TEdit;
    mNumEd:TNumEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mDed:TDateEdit;
    mCbMaterialComposition, mCbDivision, mBODDQ, mVRDQ: TRollComboEdit;
    mAllowedBOD, mAllowedVR, mListZpusob:TStringList;
    mParBOD, mParVR:String;
    cbZpusob:TComboBox;
    {mAllowed:=TStringList.create;
    mSQL3 := 'select id from StoreCards where hidden=''N'' ';
    dSite.BaseObjectSpace.SQLSelect(mSQL3,mAllowed);
    mParam3:=mAllowed.DelimitedText;
    mCbMaterial.Parameters.Clear;
    mCbMaterial.Parameters.Add('_Allowed='+mParam3);}
begin
 Result:=false;
 if ASite <> nil then begin
    Result:=False;
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 510;
    mForm.Height:= 120;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Hlavní dodavatel:';



    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Firma:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCBBOD:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCBBOD.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCBBOD.Left:= 236;
    mCBBOD.Top:= 11;
    mCBBOD.Width:= 255;

    mBODDQ:= TRollComboEdit.Create(mForm);
    mBODDQ.Parent:= mForm;

    mBODDQ.ClassID:= 'O3OWQQYWYJCL3J0B01K0LEIOE0';
    mBODDQ.Complete:= True;
    mBODDQ.Prefilling:= pmNone;
    mBODDQ.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mBODDQ.Top:= 11;
    mBODDQ.Left:= 137;
    mBODDQ.Width:= 108;
    mBODDQ.DataText:=aFirm_ID;
    {mBODDQ.Parameters.Clear;
    mBODDQ.Parameters.Add('_Allowed='+mParBOD);  }
    mBODDQ.ConnectedControl:= mCBBOD;
    mBODDQ.ConnectedControlField:= 'Name';

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 50;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 50;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
    //aresult:=mresult;
   // if mButCancel.OnC
    if mResult = 1 then begin
         aResult:=1;
         aFirm_ID:=mBODDQ.DataText;
         Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    end;
    mForm.free;
  end;
end;

function GetSupplier_ID(AOS : TNxCustomObjectSpace; aStoreCard_ID, aFirm_ID : string) : string;
const
  cSQL = 'SELECT ID FROM Suppliers WHERE StoreCard_ID=''%s'' and Firm_ID=''%s''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, aFirm_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;



begin
end.