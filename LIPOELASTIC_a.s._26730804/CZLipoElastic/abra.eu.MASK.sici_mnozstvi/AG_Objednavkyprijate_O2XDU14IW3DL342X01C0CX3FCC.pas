

procedure OnExec(Sender: TComponent;index:integer);       // přidělení objectspace a zadání zdrojového souboru
     var
  mRows : TNxCustomBusinessMonikerCollection;
  i : integer;
  mMinMnozstvi:double;
  mSite: TDynSiteForm;
  mBO:TNxCustomBusinessObject;
  mBResult:boolean;
begin

           mSite := TDynSiteForm(NxFindSiteForm(Sender));
        mBO:=TDynSiteForm(mSite).CurrentObject;
        mBResult:=InputQuery('Dojde k zásadní změne dokladu, opravdu chcete pokračovat?', 'Přepočítat množství' ,
                    mBO.GetFieldValueAsString('DocQueue_id.Code') + '-' + inttostr(mBO.GetFieldValueAsInteger('ordnumber')) + '/' + mBO.GetFieldValueAsString('Period_id.Code')) ;

           mBResult:=InputQuery('Dojde k zásadní změne dokladu, opravdu chcete pokračovat?', 'Přepočítat množství' , '');
           if mBResult then begin

                                 mRows := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));


                                      for i := 0 to mRows.Count - 1 do begin

                                                      mMinMnozstvi:=0;
                                                      if (mRows.BusinessObject[i].GetFieldValueAsInteger('RowType') = 3) then begin

                                                                    mMinMnozstvi := mRows.BusinessObject[i].GetFieldValueAsInteger('StoreCard_ID.X_Davka_sici') ;
                                                                    if mMinMnozstvi=0 then mMinMnozstvi:=1;

                                                                    mRows.BusinessObject[i].setFieldValueAsfloat('Quantity',(NxRoundByValue(((mRows.BusinessObject[i].GetFieldValueAsfloat('Quantity')/mMinMnozstvi)),2,1 )* mMinMnozstvi));

                                                      end;


                                    end;

                                    mRows.free;
                          mBO.Save;
                           mBO.Refresh;

          end;



end;



{
Vyvoláva sa po vykonaní inicializácie agendy/formulára. V tomto okamihu je už na formulári dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
 muser:TNxCustomBusinessObject;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter:Boolean;
  mUserFilterTL:string;
begin

     {     mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Doplnění šicí dávky';
          mMAction.Caption := 'Doplnění šicí dávky';
          mMAction.Items.Add('Doplnění šicí dávky');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;

       }


end;





begin
end.



