procedure OnExec(Sender: TAction; Index: integer);
var
  mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i:integer;
   mForm: TDynSiteForm;
   mi:integer;
   mBookmark : TBookmarkList;
   miChange:integer;
   mTermin_dodani:integer;
   xTerminDodani: TDateTime;
   ii: integer;
  mValidDate, mISHoliday: boolean;

begin
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    if index=3 then begin
    miChange:=1;
    miChange:= strtoint(InputBox('Dodání za', 'dnů' , inttostr(miChange)));
    end;

     if mBookmark.count=0 then begin




                   if (tdynsiteform(msite).CurrentObject.GetFieldValueAsString('PaymentType_ID')='3A50000101')  then begin
                                          if (tdynsiteform(msite).CurrentObject.GetFieldValueAsBoolean('Confirmed')) then begin
                                              // NxShowSimpleMessage('validace osoby', nil);


                                                  if index=0 then begin
                                                                           {                  mValidDate:= false;
                                                                    xTerminDodani:= 0;
                                                                    ii:=0;
                                                                    if tdynsiteform(msite).CurrentObject.GetFieldValueAsDateTime('X_termin_dodani')= 0 then begin
                                                                      xTerminDodani:= Date;
                                                                      if HourOfTheDay(Now) > 11 then xTerminDodani:= xTerminDodani + 1;
                                                                      xTerminDodani:= xTerminDodani + tdynsiteform(msite).CurrentObject.GetFieldValueAsInteger('Firm_ID.X_MoveDelivery'); //X_LeadTime
                                                                      mISHoliday:=NxEvalParametersExprAsBooleanDef(msite.BaseObjectSpace,nil,'NxDayIsHoliday('+NxFloatToIBStr(xTerminDodani)+'.0)',false);
                                                                      //NxShowSimpleMessage(NxBoolToStr(mISHoliday), nil);
                                                                      if (DayOfTheWeek(xTerminDodani) in [6,7]) or (mISHoliday) then
                                                                      begin
                                                                        while ((DayOfTheWeek(xTerminDodani) in [6,7]) or (mISHoliday)) and (ii<20) do
                                                                        begin
                                                                          xTerminDodani:= xTerminDodani + 1;
                                                                          mISHoliday:=NxEvalParametersExprAsBooleanDef(msite.BaseObjectSpace,nil,'NxDayIsHoliday('+NxFloatToIBStr(xTerminDodani)+'.0)',false);
                                                                          Inc(ii);
                                                                        end;
                                                                      end;
                                                                      mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(int(xTermindodani)) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                                                            mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(int(xTermindodani)) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));

                                                                      //Self.SetFieldValueAsDateTime('X_Termin_Dodani', mTerminDodani);
                                                                    end;


                                                                 finally

                                                                 end;  }
                                                                  mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(now()) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(now()) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));



                                                  end;
                                                  if index=1 then begin

                                                      try
                                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(int(now())+1) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(int(now()+1)) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                                      finally
                                                      end;

                                                  end;

                                                  if index=2 then begin

                                                      try
                                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(int(now())+7) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(int(now()+7)) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                                      finally
                                                      end;

                                                  end;
                                                  if index=3 then begin

                                                      try
                                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(int(now())+miChange) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(int(now()+miChange)) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                                      finally
                                                      end;

                                                  end;
                                            TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;



                                          end;
                   end else begin
                                                  if index=0 then begin
                                                                         {                  mValidDate:= false;
                                                                    xTerminDodani:= 0;
                                                                    ii:=0;
                                                                    if tdynsiteform(msite).CurrentObject.GetFieldValueAsDateTime('X_termin_dodani')= 0 then begin
                                                                      xTerminDodani:= Date;
                                                                      if HourOfTheDay(Now) > 11 then xTerminDodani:= xTerminDodani + 1;
                                                                      xTerminDodani:= xTerminDodani + tdynsiteform(msite).CurrentObject.GetFieldValueAsInteger('Firm_ID.X_MoveDelivery'); //X_LeadTime
                                                                      mISHoliday:=NxEvalParametersExprAsBooleanDef(msite.BaseObjectSpace,nil,'NxDayIsHoliday('+NxFloatToIBStr(xTerminDodani)+'.0)',false);
                                                                      //NxShowSimpleMessage(NxBoolToStr(mISHoliday), nil);
                                                                      if (DayOfTheWeek(xTerminDodani) in [6,7]) or (mISHoliday) then
                                                                      begin
                                                                        while ((DayOfTheWeek(xTerminDodani) in [6,7]) or (mISHoliday)) and (ii<20) do
                                                                        begin
                                                                          xTerminDodani:= xTerminDodani + 1;
                                                                          mISHoliday:=NxEvalParametersExprAsBooleanDef(msite.BaseObjectSpace,nil,'NxDayIsHoliday('+NxFloatToIBStr(xTerminDodani)+'.0)',false);
                                                                          Inc(ii);
                                                                        end;
                                                                      end;
                                                                      mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(int(xTermindodani)) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                                                            mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(int(xTermindodani)) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));

                                                                      //Self.SetFieldValueAsDateTime('X_Termin_Dodani', mTerminDodani);
                                                                    end;


                                                                 finally

                                                                 end;  }
                                                                  mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(now()) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(now()) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));

                                                 end;
                                                  if index=1 then begin

                                                      try
                                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(int(now())+1) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(int(now()+1)) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                                      finally
                                                      end;

                                                  end;

                                                  if index=2 then begin

                                                      try
                                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(int(now())+7) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(int(now()+7)) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                                      finally
                                                      end;

                                                  end;
                                                  if index=3 then begin

                                                      try
                                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(int(now())+miChange) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(int(now()+miChange)) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                                      finally
                                                      end;

                                                  end;

                                            TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;


                   end;





    end else begin

         for i := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
               if (tdynsiteform(msite).CurrentObject.GetFieldValueAsString('PaymentType_ID')='3A50000101')  then begin
                     if (tdynsiteform(msite).CurrentObject.GetFieldValueAsBoolean('Confirmed')) then begin
                                              // NxShowSimpleMessage('validace osoby', nil);





                                  if index=0 then begin
                                                               {                  mValidDate:= false;
                                                                    xTerminDodani:= 0;
                                                                    ii:=0;
                                                                    if tdynsiteform(msite).CurrentObject.GetFieldValueAsDateTime('X_termin_dodani')= 0 then begin
                                                                      xTerminDodani:= Date;
                                                                      if HourOfTheDay(Now) > 11 then xTerminDodani:= xTerminDodani + 1;
                                                                      xTerminDodani:= xTerminDodani + tdynsiteform(msite).CurrentObject.GetFieldValueAsInteger('Firm_ID.X_MoveDelivery'); //X_LeadTime
                                                                      mISHoliday:=NxEvalParametersExprAsBooleanDef(msite.BaseObjectSpace,nil,'NxDayIsHoliday('+NxFloatToIBStr(xTerminDodani)+'.0)',false);
                                                                      //NxShowSimpleMessage(NxBoolToStr(mISHoliday), nil);
                                                                      if (DayOfTheWeek(xTerminDodani) in [6,7]) or (mISHoliday) then
                                                                      begin
                                                                        while ((DayOfTheWeek(xTerminDodani) in [6,7]) or (mISHoliday)) and (ii<20) do
                                                                        begin
                                                                          xTerminDodani:= xTerminDodani + 1;
                                                                          mISHoliday:=NxEvalParametersExprAsBooleanDef(msite.BaseObjectSpace,nil,'NxDayIsHoliday('+NxFloatToIBStr(xTerminDodani)+'.0)',false);
                                                                          Inc(ii);
                                                                        end;
                                                                      end;
                                                                      mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(int(xTermindodani)) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                                                            mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(int(xTermindodani)) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));

                                                                      //Self.SetFieldValueAsDateTime('X_Termin_Dodani', mTerminDodani);
                                                                    end;


                                                                 finally

                                                                 end;  }
                                                                  mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(now()) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(now()) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));


                                  end;
                                  if index=1 then begin

                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(now()+1) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(now()+1) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                  end;

                                  if index=2 then begin

                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(now()+7) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(now()+7) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                  end;

                                    if index=3 then begin

                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(now()+miChange) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(now()+miChange) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                  end;
                                  TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
                    end;
               end else begin
                   if index=0 then begin

                                                 {      try
                                                             mValidDate:= false;
                                                                    xTerminDodani:= 0;
                                                                    ii:=0;
                                                                    if tdynsiteform(msite).CurrentObject.GetFieldValueAsDateTime('X_termin_dodani')= 0 then begin
                                                                      xTerminDodani:= Date;
                                                                      if HourOfTheDay(Now) > 11 then xTerminDodani:= xTerminDodani + 1;
                                                                      xTerminDodani:= xTerminDodani + tdynsiteform(msite).CurrentObject.GetFieldValueAsInteger('Firm_ID.X_MoveDelivery'); //X_LeadTime
                                                                      mISHoliday:=NxEvalParametersExprAsBooleanDef(msite.BaseObjectSpace,nil,'NxDayIsHoliday('+NxFloatToIBStr(xTerminDodani)+'.0)',false);
                                                                      //NxShowSimpleMessage(NxBoolToStr(mISHoliday), nil);
                                                                      if (DayOfTheWeek(xTerminDodani) in [6,7]) or (mISHoliday) then
                                                                      begin
                                                                        while ((DayOfTheWeek(xTerminDodani) in [6,7]) or (mISHoliday)) and (ii<20) do
                                                                        begin
                                                                          xTerminDodani:= xTerminDodani + 1;
                                                                          mISHoliday:=NxEvalParametersExprAsBooleanDef(msite.BaseObjectSpace,nil,'NxDayIsHoliday('+NxFloatToIBStr(xTerminDodani)+'.0)',false);
                                                                          Inc(ii);
                                                                        end;
                                                                      end;
                                                                      mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(int(xTermindodani)) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                                                            mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(int(xTermindodani)) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));

                                                                      //Self.SetFieldValueAsDateTime('X_Termin_Dodani', mTerminDodani);
                                                                    end;


                                                                 finally

                                                                 end;  }
                                                                  mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(now()) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(now()) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));

                                  end;
                                  if index=1 then begin

                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(now()+1) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(now()+1) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                  end;
                                  if index=2 then begin

                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(now()+7) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(now()+7) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                  end;
                                  if index=3 then begin

                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set confirmed=''A'', X_Termin_dodani=' + NxFloatToIBStr(now()+miChange) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                        mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + NxFloatToIBStr(now()+miChange) + ' where parent_id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                                  end;
                                  TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
               end;
         end;

    end;





end;


{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
  mAction: TBasicAction;
  mAList: TActionList;
  i: integer;
  mAct: TBasicAction;
begin
           mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Potvrzeno';
          mMAction.Caption := 'Potvrzeno termin ';
          mMAction.Items.Add('Dnes ');
          mMAction.Items.Add('Zítra');
          mMAction.Items.Add('Za týden');
          mMAction.Items.Add('Ruční korekce');




          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


end;


begin
end.