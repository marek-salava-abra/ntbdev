procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;
  mUser:TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;
     mUser:=self.BaseObjectSpace.CreateObject(Class_SecurityUser);
     mUser.Load(NxGetActualUserID(self.BaseObjectSpace),nil);

   { mBut:= Self.GetNewAction;
    mBut.ShowControl := True;
    mBut.ShowMenuItem := True;
    mBut.Caption := 'Rychlý tisk';
    mBut.Category := 'tabList';
    mBut.OnExecute := @PrintDoc;
    if not(mUser.OID='H100000101') then begin }
    mBut:= Self.GetNewAction;
    mBut.ShowControl := True;
    mBut.ShowMenuItem := True;
    mBut.Caption := 'Kontrola VYP';
    mBut.Category := 'tabList';
    mBut.OnExecute := @Mistr;
    {end;
    mBut:= Self.GetNewAction;
    mBut.ShowControl := True;
    mBut.ShowMenuItem := True;
    mBut.Caption := 'Volné termíny';
    mBut.Category := 'tabDetail';
    mBut.OnExecute := @FreeTerms;}

end;

Procedure Mistr(sender:Tcomponent);
var
 mSite:TSiteForm;
 mOperation, mBO:TNxCustomBusinessObject;
 mQuantity:Extended;
 mSQL:String;
 mList:TStringList;
 mOutPuts, mSNNumbers:TNxCustomBusinessMonikerCollection;
begin
 mSite:=TComponent(sender).DynSite;
 mBO:= TDynSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
   if (mbo.GetFieldValueAsFloat('Quantity')-mbo.GetFieldValueAsFloat('FinishedQuantity'))>0 then begin
    if NxMessageBox('Dotaz','Přejete si zadat kontrolu na poslední operaci?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
       mQuantity:=NxIBStrToFloat(InputBox('Výroba','Zadejte množství','1',msite));
       if mQuantity>0 then begin
         mList:=TStringList.Create;
         mSQL:='select id from plmjobordersroutines where finished=''A'' and parent_id in (select id from plmjooutputitems where owner_id in (select id from plmjonodes where parent_id=''%s'' and master_id is null))';

         mBO.ObjectSpace.SQLSelect(Format(mSQL,[mBO.OID]),mList);
         mOutPuts:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('OutPuts'));
         mSNNumbers:=mOutPuts.BusinessObject[0].GetLoadedCollectionMonikerForFieldCode(mOutPuts.BusinessObject[0].GetFieldCode('PLMJobOrdersSN'));
         if mList.Count>0 then begin
           Try

            mOperation:=mbo.ObjectSpace.CreateObject(Class_PLMOperation);
            mOperation.New;
            mOperation.Prefill;
            mOperation.SetFieldValueAsString('BusOrder_ID', mbo.GetFieldValueAsString('BusOrder_ID'));
            mOperation.SetFieldValueAsString('BusTransaction_ID', mbo.GetFieldValueAsString('BusTransaction_ID'));
            mOperation.SetFieldValueAsString('Division_ID', mbo.GetFieldValueAsString('Division_ID'));
            mOperation.SetFieldValueAsFloat('Quantity', mQuantity);
            mOperation.SetFieldValueAsString('JobOrdersRoutines_ID',mList.strings[0]);
            mOperation.SetFieldValueAsString('SalaryClass_ID',mOperation.GetFieldValueAsString('JobOrdersRoutines_ID.SalaryClass_ID'));
            mOperation.SetFieldValueAsString('WorkPlace_ID',mOperation.GetFieldValueAsString('JobOrdersRoutines_ID.WorkPlace_ID'));
            mOperation.SetFieldValueAsDateTime('StartedAt$DATE',Now);
            mOperation.SetFieldValueAsDateTime('FinishedAt$DATE',now);
            if mSNNumbers.Count>0 then
            mOperation.SetFieldValueAsString('JobOrdersSN_ID',mSNNumbers.BusinessObject[0].OID);
            mOperation.SetFieldValueAsFloat('Duration',0);
            moperation.SetFieldValueAsBoolean('OperationResult',True);
            moperation.SetFieldValueAsString('PerformedBy_ID','1300000101');

            mOperation.save;
            moperation.Free

           except
            NxShowSimpleMessage('Něco se nepovedlo '+ExceptionMessage,mSite);
           end;
           NxShowSimpleMessage('Pracovní lístek založen',mSite);
         end;
       end;
    end;
   end;
 end;
end;

Procedure FreeTerms(sender:Tcomponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 mSQL, mString:string;
 mToken1, mToken2:string;
 mList:TStringList;
 i:integer;
begin
  mSite:=TComponent(sender).DynSite;
  mBO:= TDynSiteForm(mSite).CurrentObject;
  mString:='';
   if Assigned(mBO) then begin
      mSQL:=Format('select jo.ScheduledAt$Date, count(jo.id) from plmjoborders jo left join busorders bo on bo.id=jo.busorder_ID where not(bo.X_BusOrderType_ID=''FE00000101'') and jo.ScheduledAt$Date>%s group by jo.ScheduledAt$Date ', [IntToStr(Trunc(date))]);
      mList:=TStringList.Create;
      mbo.ObjectSpace.SQLSelect(msql,mList);
      if mlist.Count>0 then begin
       if mlist.count>28 then begin
        for i:=0 to 28 do begin
          mToken1:=NxToken(mlist.strings[i],';');
          mToken2:=NxToken(mlist.strings[i],';');
          mString:=mString+FormatDateTime('dd.mm.yyyy',StrToFloat(mToken1))+'   '+mToken2+#10+#13;
        end;
       end;
       if mlist.count<29 then begin
        for i:=0 to mlist.count-1 do begin
          mToken1:=NxToken(mlist.strings[i],';');
          mToken2:=NxToken(mlist.strings[i],';');
          mString:=mString+FormatDateTime('dd.mm.yyyy',StrToFloat(mToken1))+'   '+mToken2+#10+#13;
        end;
       end;
       NxShowSimpleMessage(mString,msite);
      end;

   end;
end;

Procedure PrintDoc (sender:Tcomponent);
var
 mSite:TSiteForm;
 mList:tstringList;
 i:integer;
 PrinterName:string;
 mCopyDoc, mCopyDL:extended;
 mResult:integer;
 mPrintDoc, mPrintDL:TStringList;
 mBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
begin
 mSite:=TComponent(sender).dynsite;
 Printer.PrinterIndex := -1; // select default printer
 printername := Printer.Printers[ Printer.PrinterIndex ];
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mbo) then begin
  mOS:=mbo.ObjectSpace;
   mPrintDoc:=TStringList.Create;
   mPrintDoc.Add(mBO.OID);
     CFxReportManager.PrintByIDs(NxCreateContext_1(mBO), mPrintDoc,'JPGQAKK24CK4F4U5IKVZDJEQL4','1110000101',rtoPrint,pekPDF,PrinterName,'');


  mPrintDoc.free;

 end;
end;

begin
end.