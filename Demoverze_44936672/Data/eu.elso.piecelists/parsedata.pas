const
  cRowDescription2 = ['ucet','nazev'];
  cSeparator2 = ';';
  errStoreCardNotFound2 = 'Skladová karta s kodem %s nenalezena.';

{
  funkce rozloží vstupní parametry a uloží je do TNxParameters > hierarchická struktura s pojmenovanými parametry
  pořadí parametru v řetězcích a jejich pojmenování je definováno poli cHeadDescription a cRowDescription
}
function ParseData(ARows : TStrings ) : TNxParameters;
var
  mRows, mRow : TNxParameters;
  i, j, mPos : integer;
  mToken, mStr : string;
  x : TStringList;
begin
  OutputDebugString('Enter procedure ParseData');
  Result := TNxParameters.Create;
  mRows := TNxParameters(Result.GetOrCreateParam(dtList, 'rows', pkInput));
  for j := 0 to ARows.Count - 1 do begin
    mRow := TNxParameters(mRows.GetOrCreateParam(dtList, IntToStr(j), pkInput));
    mStr := ARows.Strings[j];
   for i := 0 to  Length(cRowDescription2) - 1 do begin
      mPos := AnsiPos(cSeparator2, mStr);
      if mPos = 0 then
        mPos := Length(mStr) + 1;
      mToken := NxLeft(mStr, mPos - 1);
      mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);
      mRow.GetOrCreateParam(dtString, cRowDescription2[i], pkInput).AsString := Trim(mToken);
    end;
  end;

//  Result.GetOrCreateParam(dtString, 'id', pkInput).AsString := '0000000000';
  OutputDebugString('Leave procedure ParseData');
end;

function GetAccount_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM Accounts WHERE Code=''%s''  ';
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

function GetFirm_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT F.ID FROM Firms F left join Addresses A on A.ID=F.REsidenceAddress_ID WHERE A.Location=''%s'' and f.hidden=''N'' ';
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

Function GetDate(var aDate:TDateTime; var Asite:TSiteForm):boolean;

var
  mForm: TForm;
  mLab: TLabel;
  mEd1: TEdit;
  mEd2: TDateEdit;
  mResult: integer;
  mBut: TButton;
begin
  mForm := TForm.Create(Nil);
  try
    mForm.Caption := 'Zadejte údaje pro ';
    mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsDialog;
    mForm.Width := 350;
    mForm.Height := 120;
    mForm.Scaled := False;
    mForm.Position := poScreenCenter;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 10;
    mLab.Caption := 'Datum do:';
    mLab.Parent := mForm;
    mEd2 := TDateEdit.Create(mForm);
    mEd2.Left := 110;
    mEd2.Top := 10;
    mEd2.Width := 80;
    mEd2.Date := date;
    mEd2.Parent := mForm;
    CreateButton(mForm, mForm, 30, 20, 70, 25, 'Cancel', 2);
    CreateButton(mForm, mForm, 30, 120, 70, 25, 'OK', 1);
    mResult := mForm.Showmodal(Asite);
    if mResult = 1 then
      aDate:= mEd2.Date;
  finally
    mForm.Free;
  end;
end;


function CreateButton(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AWidth, AHeight: integer; ACaption: string; AModalResult: integer): TButton;
begin
  Result := TButton.Create(AOwner);
  Result.Top := ATop;
  Result.Left := ALeft;
  Result.Width := AWidth;
  Result.Height := AHeight;
  Result.Caption := ACaption;
  Result.ModalResult := AModalResult;
  Result.Parent := AParent;
end;

begin
end.