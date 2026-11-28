{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mString:String;
 mList:TStringList;
 mUser:TNxCustomBusinessObject;
 mOriginalValue:Boolean;
begin
  mUser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID_1(self),nil);
  self.GetOriginalValue_3('Hidden',mOriginalValue);
  if not(mOriginalValue) and not(Self.GetFieldValueAsBoolean('Hidden')) then begin
    if not(NxGetActualUserID_1(Self)='SUPER00000') then begin
      mString:= NxSearchReplace(self.GetFieldValueAsString('K0'),' ','',[srAll]);
      if not(NxIBStrToFloat(mString)>1) then begin
        self.AddValidateError(self.GetFieldCode('K0'),'Firma nemá vyplněné klíče (1.dodavatel/odběratel + 2.firma/stavebniny/koncový zákazník nebo firma mimo obor)');
        AResult:=False;
      end;
    end;
  end;
  if not(mUser.GetFieldValueAsBoolean('U_CheckOrgIdentNumber')) then begin
   if not(NxIsBlank(self.GetFieldValueAsString('OrgIdentNumber'))) then begin
    mList:=TStringList.Create;
    mString:='Select id from firms where firm_id is null and orgidentnumber=''%s'' ';
    self.ObjectSpace.SQLSelect(format(mString,[self.GetFieldValueAsString('OrgIdentNumber')]),mlist);
    //NxShowSimpleMessage(IntToStr(mlist.count),nil);
    if ((mlist.count>0) and (osnew in self.State)) or ((mlist.count>1) and not(osnew in self.State)) then begin
      self.AddValidateError(self.GetFieldCode('OrgIdentNumber'),'Firma s IČ '+self.GetFieldValueAsString('OrgIdentNumber')+' již existuje, záznam nepůjde uložit');
      AResult:=False;
    end;
   end;
  end;
end;

begin
end.