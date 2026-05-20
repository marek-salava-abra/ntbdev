const
   cDynSQL = 'WBFDIVPW1ZE13HBT00C5OG4NF4';  // Packed GUID z DynSQL Editoru pro skladové pohyby
   cExport_ID = '1040000101';  // Export skladových pohybů
   cPath = '\\SRV-BMS1\Public\Abra_EDI\OUT_DL_a_FA\'; //cesta pro uložení souboru

{
   Dohledání stejných řádků k DL z jiných DL přes OP + Jejich export
}
procedure Execute(Sender: TBasicAction);
var
   mSQL: String;
   mFile: String;
   i,j: Integer;

   mList: TStringList;
   mSQLResult,mSQLResult2: TStringList;
   mIDs: TStringList;
   mHeads: TStringList;

   mBillOfDelivery: TNxCustomBusinessObject;
   mRows: TNxCustomBusinessMonikerCollection;
   mRow: TNxCustomBusinessObject;

   mBillOfDeliveryRow: TNxCustomBusinessObject;
   mCanExport: Boolean;
begin
   mList:= TStringList.Create;
   mBillOfDelivery:= Sender.Site.BaseObjectSpace.CreateObject(Class_BillOfDelivery);
   mIDs:= TStringList.Create;
   try
      mIDs.Duplicates:= dupIgnore;  // Zahazuj duplicity
      mIDs.Sorted:= True;  // Musíš být setříděný kvůli zahazování duplicity

      Sender.Site.List.GetSelectedId(mList);
      if mList.Count <> 1 then
      begin
         NxShowSimpleMessage('Musíte vybrat právě jeden dodací list.',nil);
      end
      else
      begin
         mBillOfDelivery.Load(mList[0],nil);
         mRows:= mBillOfDelivery.GetLoadedCollectionMonikerForFieldCode(mBillOfDelivery.GetFieldCode('Rows'));

         // Jedu cyklem přes řádky, kdyby náhodou byl každý řádek z jiné OP
         For i:= 0 to mRows.Count - 1 do
         begin
            mRow:= mRows.BusinessObject[i];
            // Dohledám všechny řádky OP, z vybraného DL
            mSQL:= 'Select RO2.ID '+
                   'From ReceivedOrders2 RO2 '+
                   'Where RO2.Parent_ID = '+QuotedStr(mRow.GetFieldValueAsString('Provide_ID'));
            mSQLResult:= TStringList.Create;
            mSQLResult2:= TStringList.Create;
            try
               Sender.Site.BaseObjectSpace.SQLSelect(mSQL,mSQLResult);
               For i:= 0 to mSQLResult.Count - 1 do
               begin
                  // Dohledám všechny DL k danému řádku OP
                  mSQL:= 'Select SD2.ID '+
                         'From StoreDocuments2 SD2 '+
                         'Where SD2.FlowType = ''21'' and ProvideRow_ID = '+QuotedStr(mSQLResult[i]);
                  Sender.Site.BaseObjectSpace.SQLSelect(mSQL,mSQLResult2);
                  For j:= 0 to mSQLResult2.Count - 1 do
                  begin
                     mIDs.Add(mSQLResult2[j]); // Do seznamu řádků DL dám vše, vlastnost striglistu na dupIgnore zařídí, že nebude řádek 2x
                  end;
               end;
            finally
               mSQLResult.Free;
               mSQLResult2.Free;
            end;
         end;

         if mIDs.Count = 0 then
         begin
            NxShowSimpleMessage('Nedohledal jsem žádné řádky DL, nic neexportuji',nil);
         end
         else
         begin
            mBillOfDeliveryRow:= Sender.Site.BaseObjectSpace.CreateObject(Class_BillOfDeliveryRow);
            mHeads:= TStringList.Create; // Hlavičky DL, abych mohl zapsat datum exportu
            try
               mHeads.Duplicates:= dupIgnore;
               mHeads.Sorted:= True;

               mBillOfDeliveryRow.Load(mIDs[0],nil);  // Načtu si řádek kvůli proměnným.
               //Sestavení cesty pro export
               mFile:= NxEvalObjectExprAsString(mBillOfDeliveryRow,QuotedStr(cPath))+
                       NxSearchReplace(mBillOfDeliveryRow.GetFieldValueAsString('Parent_ID.DocQueue_ID.Code')+NxEvalObjectExprAsString(mBillOfDeliveryRow,'NxGetDocumentDisplayName(Provide_ID,'+QuotedStr('RO')+')'),'/','-',[srAll])+
                       '.txt';

               // Test na stavy DL
               mCanExport:= True;
               For i:= 0 to mIDs.Count - 1 do
               begin
                  mBillOfDeliveryRow.Load(mIDs[i]);
                  {
                     V rámci skriptu pro nalezení „bratříčků“ DL bych potřeboval ještě ošetřit, aby v případě, že je alespoň 1 DL nevyřízený nebo nestornovaný,
                     export neproběhne a objeví se hláška „Existuje alespoň jeden DL, který není dokončen, DL dokončete a zopakujte tuto akci.“
                     Podmínka: všechny DL v StoreDocuments u shodného Provide_ID musí mít ( PMState_ID=‘SDDEF00000‘ or PMState_ID=‘3000000001‘)
                  }
                  if (mBillOfDeliveryRow.GetFieldValueAsString('Parent_ID.PMState_ID') <> 'SDDEF00000') and (mBillOfDeliveryRow.GetFieldValueAsString('Parent_ID.PMState_ID') <> '3000000001') then
                  begin
                     mCanExport:= False;
                  end;

                  mHeads.Add(mBillOfDeliveryRow.GetFieldValueAsString('Parent_ID')); // Uložení hlaviček DL
               end;

               if mCanExport then
               begin
                  CFxReportManager.ExportByIDs(NxCreateContext(Sender.Site.BaseObjectSpace),mIDs,cDynSQL,cExport_ID,2,'',mFile);

                  // Dopsání data exportu do hlaviček DL
                  For i:= 0 to mHeads.Count - 1 do
                  begin
                     mBillOfDelivery.Load(mHeads[i],nil);
                     mBillOfDelivery.SetFieldValueAsDateTime('X_EDI_Exportovano',Now);
                     if mBillOfDelivery.NeedSave then mBillOfDelivery.Save;
                  end;

                  NxShowSimpleMessage('Export dokončen: '+#10#13+mFile,nil);
               end
               else
               begin
                  NxShowSimpleMessage('Existuje alespoň jeden DL, který není dokončen, DL dokončete a zopakujte tuto akci.',nil);
               end;

            finally
               mBillOfDeliveryRow.Free;
               mHeads.Free;
            end;
         end;
      end;
   finally
      mList.Free;
      mBillOfDelivery.Free;
      mIDs.Free;
   end;
end;

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
Var
   mAction: TMultiAction;
begin
   mAction := Self.GetNewMultiAction;
   mAction.ShowControl := True; //Zobraz jako tlačítko
   mAction.ShowMenuItem := True;
   mAction.Name := 'JIFR_Export_DLs';
   mAction.Caption := 'EDI Export DL';
   mAction.Items.Add('Export DL');
   mAction.Hint := 'Exportuje všechny řádky DL, které k tomuto dokladu patří.';
   mAction.Category := 'tabList'; // kde se má tlačítko zobrazit
   mAction.OnExecuteItem := @Execute;  //OPocedura obsluhující tlačítko
   mAction.Enabled := True;
end;

begin
end.