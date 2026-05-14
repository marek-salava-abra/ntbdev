procedure InitSite_Hook(Self: TSiteForm);
var
  mBut: TBasicAction;
begin

mBut:= Self.GetNewAction;
mBut.ShowControl := True;
mBut.ShowMenuItem := True;
mBut.Caption := 'Zobrazí karty';
mBut.Category := 'tabList';
mBut.OnExecute := @ShowCards;

end;

Procedure ShowCards(Sender:TObject);
var
 mList:TstringList;
 mSql:String;
 mSite:TSiteForm;
 mparam:String;
 mPriceList:TNxCustomBusinessObject;
 mSelPar, mPars: TNxParameters;
 i:integer;
begin
 if Sender is TComponent then begin
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) and (mSite is TBusRollSiteForm) then begin
      mPriceList := TBusRollSiteForm(mSite).CurrentObject;
        mList:=TStringList.Create;
        msql:='Select storecard_id from ACTIONSTOREPRICES where pricelist_id=''%s'' ';
        TBusRollSiteForm(mSite).CurrentObject.ObjectSpace.SQLSelect(format(mSql,[mPriceList.OID]),mList);
        if mlist.count>0 then begin
             mparam:=mlist.DelimitedText;
             mPars:=TNxParameters.Create;
             mPars.GetOrCreateParam(dtString, '_Allowed', pkInput).AsString := NxStringsToCkListStr(mList);
             NxShowRoll(NxCreateContext_1(mPriceList),'S3WZQKDB5FDL342M01C0CX3FCC',mPars,0, '', mSite);


        end;
      mPriceList.Free;
 end;
end;

end;

begin
end.