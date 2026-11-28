procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;
  mUser:TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;
  mUser:=Self.BaseObjectSpace.CreateObject(Class_SecurityUser);
  mUser.load(NxGetActualUserID(self.BaseObjectSpace),nil);
  if mUser.GetFieldValueAsBoolean('U_InsertCode') then begin
  mBut:= Self.GetNewAction;
  mBut.ShowControl := True;
  mBut.ShowMenuItem := True;
  mBut.Caption := 'Vložit kódy SANITA';
  mBut.Category := 'tabList';
  mBut.OnExecute := @InsertCode;
  end;
end;

Procedure InsertCode(Sender:TComponent);
var
 mSite:TSiteForm;
 mList:TStringList;
 mSCBO:TNxCustomBusinessObject;
 i:integer;
 mBlank:Boolean;
 mOS:TNxCustomObjectSpace;
 mCode:String;
 mCodeInt:integer;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=TBusRollSiteForm(mSite).BaseObjectSpace;
 mList:=TStringList.create;
 mBlank:=False;
 mCode:=GetMaxCode(mOS);
 //NxShowSimpleMessage(mCode,msite);
 mCodeInt:= StrToInt(Copy(mCode,5,6));
// NxShowSimpleMessage(NxRight('000000'+IntToStr(mCodeInt+1),6),msite);
 if NxMessageBox('Dotaz','Přejete si doplnit jednorázové kódy pro SANITU k označeným záznamům? (strom a menu nebude změněno)' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
   TBusRollSiteForm(mSite).List.GetSelectedId(mList);
   if mList.count>0 then begin
     for i:=0 to mList.count-1 do begin
       mSCBO:=mOS.CreateObject(Class_StoreCard);
       mSCBO.Load(mlist.Strings[i],nil);
       if not(NxIsBlank(mSCBO.GetFieldValueAsString('Code'))) then mBlank:=True;
       mSCBO.free;
     end;
     if mBlank then begin
       NxShowSimpleMessage('Mminimálně jedna z označených karet má již vyplněný kód. Označte pouze karty bez kódu a zkuste to znovu.',mSite);
       exit;
     end;
     for i:=0 to mList.count-1 do begin
       mSCBO:=mOS.CreateObject(Class_StoreCard);
       mSCBO.Load(mlist.Strings[i],nil);
       mscbo.SetFieldValueAsString('Code','SN1S1'+NxRight('00000'+IntToStr(mCodeInt+i+1),5));
              mSCBO.SetFieldValueAsDateTime('AuthorizedAt$DATE',Date);
       mSCBO.SetFieldValueAsString('AuthorizedBy_ID',NxGetActualUserID(mOS));
       mscbo.save;
       mSCBO.free;
     end;
     TBusRollSiteForm(mSite).RefreshData;
   end;

 end;
end;


procedure _AfterCloneRec_Hook(Self: TRollSiteForm);
begin

end;

function GetMaxCode(AOS : TNxCustomObjectSpace) : string;
const
  cSQL = 'SELECT max(code) FROM storeCards WHERE code like ''SN1S1_____''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  Result:='SN1S100000';
  try
    AOS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then begin
       if NxIsNumeric(AnsiRightStr(mlist.strings[0],5)) then
      Result := mList.Strings[0]
    end;
  finally
    mList.Free;
  end;
end;

begin
end.