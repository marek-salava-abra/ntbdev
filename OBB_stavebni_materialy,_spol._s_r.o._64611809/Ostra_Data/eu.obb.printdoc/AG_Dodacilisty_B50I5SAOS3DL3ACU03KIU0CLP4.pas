Uses 'eu.obb.printdoc.fce2';

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
    mBut.Caption := 'FOFR TISK (DL+FV)';
    mBut.Hint := 'Rychle vytiskne označený dodací list a svázanou fakturu vydanou(bez náhledu)';
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
 mPrintDoc, mPrintDL, mPrintDL2:TStringList;
 mBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
begin
 mSite:=TComponent(sender).dynsite;
 Printer.PrinterIndex := -1; // select default printer
 printername := Printer.Printers[ Printer.PrinterIndex ];
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mbo) then begin
  mOS:=mbo.ObjectSpace;
  mCopyDoc:=2;
  mCopyDL:=2;
  mResult:=0;
  if GetCopies(msite,mResult, mcopydoc, mcopydl) then begin
  if mResult=1 then begin
  mPrintDoc:=TStringList.Create;
  mPrintDL:=TStringList.Create;
  mPrintDL2:=TStringList.Create;
  mPrintDoc.Add(mBO.OID);
  mOS.SQLSelect(Format('Select parent_id from issuedinvoices2 where provide_id=''%s'' and provide_id is not null group by parent_id ',[mbo.oid]),mPrintDL);
  for i:=1 to trunc(mCopyDoc) do begin
    CFxReportManager.PrintByIDs(NxCreateContext_1(mBO), mPrintDoc,'05DOXDMCSZDL3FUD00C5OG4NF4','1560000101',rtoPrint,pekPDF,PrinterName,'');
  end;
  if mPrintDL.count>0 then begin
   for i:=1 to trunc(mCopyDL) do begin
     CFxReportManager.PrintByIDs(NxCreateContext_1(mBO), mPrintDL,'40SBPEINEFD13ACM03KIU0CLP4','1650000101',rtoPrint,pekPDF,PrinterName,'');
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