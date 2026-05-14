procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
begin
          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Obchodní uzavření';
          mMAction.Caption := 'Obchodní uzavření';
          mMAction.Items.Add('Obchodní uzavření');
          mMAction.Items.Add('Obchodní zpětné otevření');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;
end;

Procedure OnExec(Sender:TComponent;Index:integer);
var
 mSite:TSiteForm;
 mList:TStringList;
 mBO, mBusOrderBO, mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 i,j:integer;
 mJSON:TJSONSuperObject;
 mWinHTTP2:Variant;
 mOS:TNxCustomObjectSpace;
 mDateClosed:Extended;
 mText:string;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 mList:=TStringList.create;
 if Index=0 then mText:='uzavřít' else mText:='otevřít';
 TDynSiteForm(mSite).List.GetSelectedId(mList);
 if mList.count>0 then begin
   if NxMessageBox('Dotaz', 'Přejete si obchodně '+mtext+' '+IntToStr(mlist.Count)+' označených faktur??', mdConfirm, mdbYesNo, 0, 0, False, Nil)=mrYes then begin
    WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
      for i:=0 to mlist.Count-1 do begin

       mBO:=mOS.CreateObject(Class_IssuedInvoice);
       mBO.Load(mList.strings[i],nil);
       mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
       for j:=0 to mRows.Count-1 do begin
         mRowBO:=mRows.BusinessObject[j];
         if Index=0 then begin
           if not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('BusOrder_ID'))) then begin
             if not(mRowBO.GetFieldValueAsBoolean('BusOrder_ID.X_Closed')) then begin
                mDateClosed:=mOS.SQLSelectFirstAsExtended('Select max(ii.vatdate$date) from IssuedInvoices ii left join issuedinvoices2 ii2 on ii.id=ii2.parent_id where ii.amount>0 and ii2.BusOrder_ID='+QuotedStr(mRowBO.GetFieldValueAsString('BusOrder_ID')));
                if mDateClosed>0 then begin
                   mBusOrderBO:=mOS.CreateObject(Class_BusOrder);
                   mBusOrderBO.load(mRowBO.GetFieldValueAsString('BusOrder_ID'),nil);
                   mBusOrderBO.SetFieldValueAsBoolean('X_Closed',True);
                   mBusOrderBO.SetFieldValueAsDateTime('X_Change_closed',mDateClosed);
                   mBusOrderBO.SetFieldValueAsDateTime('X_ClosedDate',mDateClosed);
                   mBusOrderBO.save;
                   mBusOrderBO.Free;
                   mJSON:= TJSONSuperObject.CreateNew;
                   mWinHTTP2:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
                   mWinHTTP2.Open('POST','https://sod.spedos.cz/api/api.abra-zakazka.php?cis_zak='+ mRowBO.GetFieldValueAsString('BusOrder_ID.Code')+'&Rodneico='+ GetICO(mOS)+'&uzavreno=1');
                   mWinHTTP2.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
                   mWinHTTP2.Send();
                   mJSON := TJSONSuperObject.ParseString(mWinHTTP2.ResponseText, True);
                end;
             end;
           end;
         end;
         if Index=1 then begin
           if not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('BusOrder_ID'))) then begin
             if (mRowBO.GetFieldValueAsBoolean('BusOrder_ID.X_Closed')) then begin
                   mBusOrderBO:=mOS.CreateObject(Class_BusOrder);
                   mBusOrderBO.load(mRowBO.GetFieldValueAsString('BusOrder_ID'),nil);
                   mBusOrderBO.SetFieldValueAsBoolean('X_Closed',False);
                   mBusOrderBO.SetFieldValueAsDateTime('X_Change_closed',0);
                   mBusOrderBO.SetFieldValueAsDateTime('X_ClosedDate',0);
                   mBusOrderBO.save;
                   mBusOrderBO.Free;
                   mJSON:= TJSONSuperObject.CreateNew;
                   mWinHTTP2:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
                   mWinHTTP2.Open('POST','https://sod.spedos.cz/api/api.abra-zakazka.php?cis_zak='+ mRowBO.GetFieldValueAsString('BusOrder_ID.Code')+'&Rodneico='+ GetICO(mOS)+'&uzavreno=0');
                   mWinHTTP2.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
                   mWinHTTP2.Send();
                   mJSON := TJSONSuperObject.ParseString(mWinHTTP2.ResponseText, True);

             end;
           end;
         end;
       end;
       mBO.free;
       WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mList.Count));
       WaitWin.StepIt;
      end;
    WaitWin.Stop;
  end;
 end;
 TDynSiteForm(mSite).RefreshData;
end;


function GetICO(AOS : TNxCustomObjectSpace) : string;
const
  cSQL = 'SELECT OrgIdentNumber FROM GlobData ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;


begin
end.