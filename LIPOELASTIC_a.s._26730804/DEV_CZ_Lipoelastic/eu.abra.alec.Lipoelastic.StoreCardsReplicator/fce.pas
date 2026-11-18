var
  gProgressForm : TForm;


procedure ProgressInit(ASite : TSiteForm; ACaption : string; AMaxValue : Integer);
begin
  gProgressForm:= TForm.Create(ASite);
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


function GetIDFromDefRollData(AOS: TNxCustomObjectSpace; ACLSID, AColumn, AValue: string;):String;
begin
  Result:= AOS.SQLSelectFirstAsString('SELECT ID FROM DefRollData WHERE Hidden = ''N'' AND CLSID = '+QuotedStr(ACLSID)+' AND UPPER('+AColumn+') = '+QuotedStr(UpperCase(AValue)));
end;

function GetLatestEAN (AOS:TNxCustomObjectSpace; APrefix:string; ALen:integer;):string;
var
 mList:TStringList;
 mNumPart, mEAN:string;
 i, mValue: integer;
begin
  try
    mNumPart:= '';
    mEAN:= '';
    mList:=TStringList.Create;
    AOS.SQLSelect(format(
      ' SELECT DISTINCT LEFT(RIGHT(SU.EAN,'+IntToStr(ALen-Length(APrefix))+'),'+IntToStr(ALen-Length(APrefix)-1)+') FROM StoreEANs SU '+
      ' WHERE (SU.EAN LIKE ''%s'') AND (LEN(SU.EAN) = 13) '+
      ' ORDER BY LEFT(RIGHT(SU.EAN,'+IntToStr(ALen-Length(APrefix))+'),'+IntToStr(ALen-Length(APrefix)-1)+') ASC',[APrefix+NxReplicate('_', ALen-Length(APrefix))]),mList);

    if mList.Count < 2 then begin
      if mList.Count = 0 then begin
        mNumPart:= NxPadL(FloatToStr(1), (ALen - 1) - Length(APrefix), '0');   //začínám jedničkou
      end else begin
        mNumPart:= NxPadL(FloatToStr(NxIBStrToFloat(mList[0]) +1), (ALen - 1) - Length(APrefix), '0');
      end;
    end else begin
      for i:=0 to mList.Count - 1 do begin
        if (i < mList.count-1) then begin
          if (StrToInt(mList[i]) + 1 <> StrToInt(mList[i+1])) then begin
            mNumPart:= NxPadL(FloatToStr(NxIBStrToFloat(mList[i]) +1), (ALen - 1) - Length(APrefix), '0');
            break;
          end;
        end else begin
          mNumPart:= NxPadL(FloatToStr(NxIBStrToFloat(mList[i]) +1), (ALen - 1) - Length(APrefix), '0');
        end;
      end;
    end;
    mEAN:= APrefix+mNumPart;
    NxCorrectEAN13(mEAN);
    Result:= mEAN;
  finally
    mList.Free;
  end;
end;

function CloneStoreCardRelatedObjects(AOS: TNxCustomObjectSpace; ATable, ACLSID, AOriginalSC_ID, AClonedSC_ID: string; var AerrLog: String):boolean;
var
  mOrigBO, mNewBO: TNxCustomBusinessObject;
  mList: TStringList;
  i: integer;
  mFragment: string;
begin
  try
    mList:= nil;
    mList:= TStringList.Create;
    //if ACLSID = Class_StoreCardMenuItemLink then mFragment:= ' IsBasicLink = ''N'' AND' else mFragment :='';
    AOS.SQLSelect('SELECT ID FROM '+ATable+' WHERE StoreCard_ID = '+QuotedStr(AOriginalSC_ID), mList);
    for i:= 0 to mList.Count -1 do
    begin
      mOrigBO:= AOS.CreateObject(ACLSID);
      try
        try
          mOrigBO.Load(mList[i], nil);
          if mOrigBO.HasField('IsBasicLink') then if mOrigBO.GetFieldValueAsBoolean('IsBasicLink') = True then continue;
          mNewBO:= mOrigBO.Clone;
          mNewBO.SetFieldValueAsString('StoreCard_ID', AClonedSC_ID);
          mNewBO.Save;
        except
          AerrLog:= AerrLog + #10#13 + ExceptionMessage;
        end;
      finally
        mOrigBO.Free;
        mNewBO.Free;
      end;
    end;
  except
    mList.Free;
    AerrLog:= AerrLog + #10#13 + ExceptionMessage;
    //ShowMessage(ExceptionMessage);
    Result:= False;
    Exit;
  end;
  mList.Free;
  Result:= True;
end;


begin
end.