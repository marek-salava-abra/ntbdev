Uses 'eu.obb.printdoc.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;
  mUser:TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;


    mBut:= Self.GetNewAction;
    mBut.ShowControl := True;
    mBut.ShowMenuItem := True;
    mBut.Caption := 'FOFR TISK (PP+DL)';
    mBut.Hint := 'Rychle vytiskne označený pokladní příjem a dodací list (bez náhledu)';
    mBut.Category := 'tabList';
    mBut.OnExecute := @PrintDoc;

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
 mBO,mEETTurnover:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mMessage:string;
begin
 mSite:=TComponent(sender).dynsite;
 Printer.PrinterIndex := -1; // select default printer
 printername := Printer.Printers[ Printer.PrinterIndex ];
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mbo) then begin
  mOS:=mbo.ObjectSpace;
  if not(NxIsEmptyOID(mBO.GetFieldValueAsString('EETTurnover_ID'))) then begin
       mEETTurnover:=mOS.CreateObject(Class_EETTurnover);
       mEETTurnover.load(mBO.GetFieldValueAsString('EETTurnover_ID'),nil);
       if not(mEETTurnover.GetFieldValueAsInteger('TurnOverState')=2)then begin
       if  TNxEETTurnover(mEETTurnover).Process(mMessage) then begin
                OutputDebugString('Zaevidováno');
              end
              else begin
                RaiseException(Format('Během evidence tržby nastala chyba (%s)', [mMessage]));
              end;
        end;
       mEETTurnover.free;
    end;

  mCopyDoc:=2;
  mCopyDL:=2;
  if GetCopies(msite,mResult, mcopydoc, mcopydl) then begin
  if mResult=1 then begin
  mPrintDoc:=TStringList.Create;
  mPrintDL:=TStringList.Create;
  mPrintDoc.Add(mBO.OID);
  mOS.SQLSelect(Format('Select provide_id from cashreceived2 where parent_id=''%s'' and provide_id is not null group by provide_id ',[mbo.oid]),mPrintDL);
  for i:=1 to trunc(mCopyDoc) do begin
    CFxReportManager.PrintByIDs(NxCreateContext_1(mBO), mPrintDoc,'IPTMF0ABJBG4FF4EETPMAMHJOC','9S00000101',rtoPrint,pekPDF,PrinterName,'');
  end;
  if mPrintDL.count>0 then begin
  for i:=1 to trunc(mCopyDL) do begin
    CFxReportManager.PrintByIDs(NxCreateContext_1(mBO), mPrintDL,'05DOXDMCSZDL3FUD00C5OG4NF4','1560000101',rtoPrint,pekPDF,PrinterName,'');
  end;
  end;
  mPrintDoc.free;
  mprintdl.Free;
 end;
 end;
 end;
end;

begin
end.