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
  mMAction.Caption := 'Výstupní pohyb';
  mMAction.Hint := 'Výstupní pohyb';
  mMAction.Category := 'tablist,tabdetail';
  mMAction.OnExecuteItem := @ShowSDDocExecuteItem;
  mMAction.Items.Add('Pohyby šarží na příjemkách k řádku ');
  mMAction.Items.Add('Pohyby šarží na dodacím listu ');
  mMAction.Items.Add('Všechny navázané skladové doklady');
  mMAction.Items.Add('Pohyby šarží na řádku OV');

end;

 procedure ShowSDDocExecuteItem(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 msite:TDynSiteForm;
 mr2:TStringList;
 mStrings:string;
 i:integer;
 mOLE, mRoll,mRoll2,mAgenda, mOResult: Variant;
 mSelected ,_ss:Variant;
 mstring:string;
 mFilter:string;
begin
  mSite := TComponent(sender).DynSite;
  mbo:=TDynSiteForm(mSite).CurrentObject;


              if index=3 then begin
                                          mr2:=TStringList.create;
                                           try
                                               mbo.ObjectSpace.SQLSelect('SELECT distinct a.id as hodnota FROM DefRollData A where A.CLSID=' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                                                ' and a.X_parent_ID='+quotedstr(mbo.GetFieldValueAsString('ID')) ,mr2);
                                                if mr2.count>0 then begin

                                                         mFilter:= '';
                                                         for i:= 0 to mr2.Count - 1 do begin
                                                            mFilter:= mFilter + Format('''%s'',', [mr2[i]]);
                                                            if i = mr2.Count-1  then begin
                                                                mFilter:= copy(mFilter, 1, Length(mFilter) - 1);
                                                            end;
                                                          end;
                                                          msite.ShowSite('FJFZPKZ3TVMOV00YPT2WI34V34',true,'FilterByUserDynSQLCondition;A.ID in (' + mFilter + ') ');
                                                    end else begin
                                                        NxShowSimpleMessage('Pro doklad nebyly vygenerovány šarže.',nil);
                                                    end;
                                           finally
                                              mr2.free;
                                           end;

              end else begin
                     mOLE := GetAbraOLEApplication;
                      mroll := mOLE.GetAgenda('S1X0KZC0NJE13C5U00CA141B44');

                      mSelected := mOLE.CreateStrings;
                      mr2:=TStringList.create;
                      try
                             if index=0 then begin
                                mbo.ObjectSpace.SQLSelect('SELECT drb.id FROM Storedocuments2 SD2 left join DocRowBatches DRB on drb.Parent_ID=sd2.id where SD2.ProvideRow_ID=' + quotedstr(mbo.GetFieldValueAsString('ID')) ,mr2);
                              end;
                              if index=1 then begin                                                                                                                                                                                                                                      // +' and (SD.Documenttype=''20'')'
                                mbo.ObjectSpace.SQLSelect('SELECT distinct drb.id FROM Storedocuments2 SD2 join storedocuments sd on sd.id=sd2.parent_ID join DocRowBatches DRB on drb.parent_id=sd2.id where sd2.ProvideRow_ID=' + quotedstr(mbo.GetFieldValueAsString('X_ProvideRow_ID')),mr2);
                              end;
                              if index=2 then begin                                                                                                                                                                                                                                      // +' and (SD.Documenttype=''20'')'
                                mbo.ObjectSpace.SQLSelect('SELECT distinct drb.id FROM Storedocuments2 SD2 join storedocuments sd on sd.id=sd2.parent_ID join DocRowBatches DRB on drb.parent_id=sd2.id where (sd2.ProvideRow_ID=' + quotedstr(mbo.GetFieldValueAsString('X_ProvideRow_ID')) + ' or SD2.ProvideRow_ID=' + quotedstr(mbo.GetFieldValueAsString('ID'))+')' ,mr2);
                              end;



                                 if mr2.count=0 then begin
                                     NxShowSimpleMessage('Pro šarži nebyl dohledán pohyb ', nil);
                                     mr2.free;
                                     exit;
                                 end;
                                 for i := 0 to mr2.Count - 1 do begin
                                     mSelected.Add(mr2.Strings[i]);
                                 end;
                               mstring:= mroll.SingleSelectFromSelected2(mSelected, 'Pohyb: ' + mbo.GetFieldValueAsString('Storecard_id.DisplayName')  +' v množství: ' + NxFloatToIBStr(mbo.GetFieldValueAsFloat('quantity')) , '');
                      finally
                            mr2.free;
                        //    mselected.free;
                        end;

                end;


end;





begin
end.
