  Var
mbo:TNxCustomBusinessObject;
mr:tstringlist;
mID:string;


  procedure iFillStores(AOS : TNxCustomObjectSpace; AList : Tstrings);
  const
    cSQL = 'SELECT Code FROM BusOrders WHERE Hidden=''N'' ORDER BY Code';
  begin
    AOS.SQLSelect(cSQL, AList);
  end;



procedure RowOperationOnExecute(Sender: TAction);
var
  mSite : TSiteForm;

begin
 mSite := NxFindSiteForm(Sender);



end;







  {
Vyvoláva sa po vykonaní inicializácie agendy/formulára. V tomto okamihu je už na formulári dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin

        mAction := Self.GetNewAction;
        mAction.ShowControl := True;
        mAction.ShowMenuItem := True;
        mAction.Caption := '                                               .';
        mAction.Hint := '                                                .';
        mAction.Category := 'tablist,tabdetail';
        mAction.OnExecute := @RowOperationOnExecute;




end;



begin
end.