procedure exeCreateICN(Sender: TBasicAction);
var
  mManager: TNxDocumentImportManager;
  p: TNxParameters; i,j,k: Integer; s: string;
  mII: TNxIssuedInvoice;
  mICN: TNxIssuedCreditNote;
  mRow: TNxCustomBusinessObject;
  mOS: TNxCustomObjectSpace;
begin
  mOS:= Sender.Site.BaseObjectSpace;
  //nejprve vytvořím fakturu, abych měl co vracet
  mII := TNxIssuedInvoice(mOS.CreateObject(Class_IssuedInvoice));
  mII.New;
  mII.Prefill;
  mII.SetFieldValueAsString('StoreDocQueue_ID','P600000101');
  mRow := mII.Rows.AddNewObject;
  mRow.SetFieldValueAsInteger('RowType', 3);
  mRow.SetFieldValueAsString('Store_ID', '2100000101'); //hlavní sklad
  mRow.SetFieldValueAsString('StoreCard_ID', '8200000101'); //39 CD (mají šarže)
  mRow.SetFieldValueAsFloat('Quantity',2); //jedno budu chtít vrátit
  mRow.SetFieldValueAsString('Division_ID', '2100000101'); //000
  mII.Save;
  NxShowSimpleMessage('Vytvořena ' + mII.DisplayName, Sender.Site);
  //uděláme dobropis
  mManager := NxCreateDocumentImportManager(mOS, Class_IssuedInvoice, Class_IssuedCreditNote);
  mManager.AddInputDocument(mII.OID);
  p := TNxParameters.Create;
  p.GetOrCreateParam(dtString,'StoreDocQueue_ID').AsString := 'R600000101'; //VR
  p.GetOrCreateParam(dtBoolean,'DoNotImportChargesSerialNumbers').AsBoolean := False; //žádné nemáme
  mManager.LoadParams(p);
  mManager.Execute;
  mManager.AfterExecuteFromOLE;  //tohle má uožnit upravit množství
  mICN := TNxIssuedCreditNote(mManager.OutputDocument);
  mICN.Rows.BusinessObject[0].SetFieldValueAsFloat('Quantity',1);
  micn.rows.BusinessObject[0].validate; //ponížíme řádek
  mICN.Save;
  NxShowSimpleMessage('Vytvořen ' + mICN.DisplayName, Sender.Site);

end;

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
begin
  with Self.GetNewAction do begin
    name := 'actCreateICN';
    caption := 'Vytvoř DV';
    category := 'tabList';
    onExecute := @exeCreateICN;
  end;
end;

begin
end.