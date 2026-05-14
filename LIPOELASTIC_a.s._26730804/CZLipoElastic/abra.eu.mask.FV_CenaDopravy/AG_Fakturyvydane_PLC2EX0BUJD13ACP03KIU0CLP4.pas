
var
     mBookmark : TBookmarkList;

procedure cena_dopravy(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i,j:integer;
   mForm: TDynSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   self:TNxCustomBusinessObject;
   mr:tstringlist;
   mWeight:double;
   mkarton:integer;
begin
  mtext:='0';
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mbo:= TDynSiteForm(mSite).CurrentObject;
    if index=0 then begin
         mB_Result:=InputQuery('Zadaj cenu', 'Doprava ', mtext);
             mtext:= NxFloatToIBStr(NxIBStrToFloat(mtext)) ;
    end;
    if index=1 then mB_Result:=true;

   // if mB_Result then begin
                if mBookmark.count=0 then begin
                           //if index=0 then begin
                           if index=0 then begin


                                          if mB_Result then mi:=msite.BaseObjectSpace.SQLExecute('update issuedinvoices set X_Delivery_price=' + mtext + ' where id=' + QuotedStr(TDynSiteForm(mSite).CurrentObject.oid))  ;
                           end;

                           if index=1 then begin
                              self:=TDynSiteForm(msite).CurrentObject;
                                if self.GetFieldValueAsString('Docqueue_ID')='O200000101' then begin
                                                  if mkarton=0 then mkarton:=1;
                                                  mr:=tstringlist.create;
                                                  try
                                                          msite.BaseObjectSpace.SQLSelect('SELECT ((SU.Weight* CASE WHEN (SU.WeightUnit=0) THEN 0.001 WHEN (SU.WeightUnit=2) THEN 1000 ELSE 1 END )*(CAST(RO2.Quantity as Float) / RO2.Unitrate))+ ' +

                                                                ' ((select sum(susc.Weight* CASE WHEN (SUSC.WeightUnit=0) THEN 0.001  WHEN (SUSC.WeightUnit=2) THEN 1000 ELSE 1 END) ' +
                                              ' From storecards sc left join storecards scsc on sc.X_krabicka_ID=scsc.ID left join StoreUnits susc on SUsc.Parent_ID=scsc.id  ' +
                                              ' where sc.id=RO2.StoreCard_ID) *(CAST(RO2.Quantity as Float) / RO2.Unitrate)) ' +
                                                                                                      ' FROM issuedinvoices RO2, StoreUnits SU '+
                                                                                                      ' WHERE '+
                                                                                                      ' (RO2.StoreCard_ID IS NOT NULL) AND SU.Parent_ID=RO2.StoreCard_ID AND SU.Code=RO2.QUnit and '+
                                                                                                      ' (RO2.Parent_ID in (' + self.oid   + '))',mr);
                                                                                                 if mr.count>0 then begin
                                                                                                    //NxShowSimpleMessage(mr.Strings[0],nil);
                                                                                                    mWeight:=0;
                                                                                                    for j:=0 to mr.count-1 do begin
                                                                                                             mWeight:=mWeight + NxIBStrToFloat(mr.Strings[j]);
                                                                                                    end;

                                                                                                    mWeight:=mWeight+ (0.2*mKarton);
                                                                                                    if self.getFieldValueAsFloat('U_weight')=0 then self.SetFieldValueAsFloat('U_weight',mWeight)
                                              //                                                      else self.OutputDocument.SetFieldValueAsFloat('U_weight',(self.OutputDocument.getFieldValueAsFloat('U_weight') + mWeight))
                                                                                                    ;
                                                                                                 end;
                                                  finally
                                                      mr.free;
                                                  end;
                                                        self.save;
                                              end;
                           end;

                                          TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem ;
                end else begin
                     for i := 0 to mBookmark.Count- 1 do begin
                                      mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                     if index=0 then begin
                                          if mB_Result then mi:=msite.BaseObjectSpace.SQLExecute('update issuedinvoices set X_Delivery_price=' + mtext + ' where id=' + QuotedStr(TDynSiteForm(mSite).CurrentObject.oid)) ;
                                      end;
                                     if index=1 then begin
                                                        self:=TDynSiteForm(msite).CurrentObject;
                                                          if self.GetFieldValueAsString('Docqueue_ID')='O200000101' then begin
                                                                            if mkarton=0 then mkarton:=1;
                                                                            mr:=tstringlist.create;
                                                                            try
                                                                                    msite.BaseObjectSpace.SQLSelect('SELECT ((SU.Weight* CASE WHEN (SU.WeightUnit=0) THEN 0.001 WHEN (SU.WeightUnit=2) THEN 1000 ELSE 1 END )*(CAST(RO2.Quantity as Float) / RO2.Unitrate))+ ' +

                                                                                          ' ((select sum(susc.Weight* CASE WHEN (SUSC.WeightUnit=0) THEN 0.001  WHEN (SUSC.WeightUnit=2) THEN 1000 ELSE 1 END) ' +
                                                                        ' From storecards sc left join storecards scsc on sc.X_krabicka_ID=scsc.ID left join StoreUnits susc on SUsc.Parent_ID=scsc.id  ' +
                                                                        ' where sc.id=RO2.StoreCard_ID) *(CAST(RO2.Quantity as Float) / RO2.Unitrate)) ' +
                                                                                                                                ' FROM issuedinvoices RO2, StoreUnits SU '+
                                                                                                                                ' WHERE '+
                                                                                                                                ' (RO2.StoreCard_ID IS NOT NULL) AND SU.Parent_ID=RO2.StoreCard_ID AND SU.Code=RO2.QUnit and '+
                                                                                                                                ' (RO2.Parent_ID in (' + self.oid   + '))',mr);
                                                                                                                           if mr.count>0 then begin
                                                                                                                              //NxShowSimpleMessage(mr.Strings[0],nil);
                                                                                                                              mWeight:=0;
                                                                                                                              for j:=0 to mr.count-1 do begin
                                                                                                                                       mWeight:=mWeight + NxIBStrToFloat(mr.Strings[j]);
                                                                                                                              end;

                                                                                                                              mWeight:=mWeight+ (0.2*mKarton);
                                                                                                                              if self.getFieldValueAsFloat('U_weight')=0 then self.SetFieldValueAsFloat('U_weight',mWeight)
                                                                        //                                                      else self.OutputDocument.SetFieldValueAsFloat('U_weight',(self.OutputDocument.getFieldValueAsFloat('U_weight') + mWeight))
                                                                                                                              ;
                                                                                                                           end;
                                                                            finally
                                                                                mr.free;
                                                                            end;
                                                                           self.save;
                                                                        end;
                                                     end;



                                      // end; //DolneniObalu(msite,TDynSiteForm(mSite).CurrentObject,index);
                                      TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem ;

                     end;

                end;
    //    end else begin
    //        NxShowSimpleMessage('Akce byla stornována uživatelem',nil);
    //    end;;




end;


procedure InitSite_Hook(Self: TDynSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
begin
if (NxGetActualUserID(self.BaseObjectSpace)='SUPER00000') or (NxGetActualUserID(self.BaseObjectSpace)='1Z10000101') then begin
  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Cena Dopravy';
  mmAction.Hint := 'Cena Dopravy';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Cena dopravy');
  mMAction.Items.Add('Váha dopravy');
  mmAction.OnExecute:= @cena_dopravy;

end;

end;


begin
end.