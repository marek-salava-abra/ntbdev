

procedure OnExec(Sender: TComponent;index:integer);       // přidělení objectspace a zadání zdrojového souboru
     var
  mRows : TNxCustomBusinessMonikerCollection;
  i : integer;
  mMinMnozstvi:double;
  mSite: TDynSiteForm;
  mBO:TNxCustomBusinessObject;
  mBResult:boolean;
  mr:tstringlist;
  mi:integer;
begin

           mSite := TDynSiteForm(NxFindSiteForm(Sender));
        mBO:=TDynSiteForm(mSite).CurrentObject;
      //  mBResult:=InputQuery('Dojde k zásadní změne dokladu, opravdu chcete pokračovat?', 'Přepočítat množství' ,
        //            mBO.GetFieldValueAsString('DocQueue_id.Code') + '-' + inttostr(mBO.GetFieldValueAsInteger('ordnumber')) + '/' + mBO.GetFieldValueAsString('Period_id.Code')) ;

          // mBResult:=InputQuery('Dojde k zásadní změne dokladu, opravdu chcete pokračovat?', 'Přepočítat množství' , '');
           //if mBResult then begin

                                 mRows := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));


                                      for i := 0 to mRows.Count - 1 do begin
                                                                    mRows.BusinessObject[i].setFieldValueAsfloat('DeliveredQuantity',0);
                                                                    mr:=tstringlist.create;
                                                                    try
                                                                        msite.BaseObjectSpace.SQLSelect('Select sd2.id from StoreDocuments2 SD2 where sd2.Provide_ID=' + quotedstr(mbo.oid)
                                                                                                         + ' and sd2.ProvideRow_ID=' + quotedstr(mRows.BusinessObject[i].oid) + ' and sd2.ProvideRowType<>' + quotedstr('IO')
                                                                                                         ,mr);
                                                                        if mr.count>0 then begin
                                                                            MI:=msite.BaseObjectSpace.SQLExecute('update StoreDocuments2 set Provide_ID=' + quotedstr('')
                                                                                                       + ' ,ProvideRow_ID=' + quotedstr('') + ',ProvideRowType=' + quotedstr('')
                                                                                                        + ' where id=' + quotedstr(mr.Strings[0])
                                                                                                         );
                                                                            //NxShowSimpleMessage('Dokad k uvolnění',nil);
                                                                           end;
                                                                    finally

                                                                    end;




                                    end;

                                    mRows.free;
                          mBO.Save;
                           mBO.Refresh;

       //   end;



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

          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Odpojeni dokladu';
          mMAction.Caption := 'Odpojeni dokladu';
          mMAction.Items.Add('Odpojeni dokladu');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;




end;





begin
end.



