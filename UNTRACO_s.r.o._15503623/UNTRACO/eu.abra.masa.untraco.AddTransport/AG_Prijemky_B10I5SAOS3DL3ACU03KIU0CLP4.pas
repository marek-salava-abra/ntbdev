procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Import dopravy ##';
  mAction.Hint := 'Vloží dopravu do příjemky, rozpočte dle ';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SetOtherCosts;
end;

Procedure SetOtherCosts(Sender: TComponent);
var
  mSite: TSiteForm;
  mFileContent,mRowFields, mReceiptCardList: TStringList;
  i, j, mOrdNumber: integer;
  mOS: TNxCustomObjectSpace;
  mOpenDlg: TOpenDialog;
  mIssuedOrder_ID:string;
  // Proměnné pro uložení hodnot
  mReference, mObjednavka, mDQCode, mPCode,mReceiptCardName: string;
  mCena, mRowAmount, mTotalAmount, mTransAmount, mDistributedSum: Extended;
  mReceiptCardBO, mRCRowBO:TNxCustomBusinessObject;
  mRows:TNxCustomBusinessMonikerCollection;
begin
  mSite := TComponent(Sender).DynSite;
  mOS := TDynSiteForm(mSite).BaseObjectSpace;
  mOpenDlg := TOpenDialog.Create(sender);
  mOpenDlg.Title := 'Import z CSV';
  mOpenDlg.Filter := 'Soubory s fakturou (*.csv)| *.csv';

  if mOpenDlg.Execute then begin
    mFileContent := TStringList.Create;
    mRowFields := TStringList.Create;

    // Nastavení pro správné dělení podle středníku
    mRowFields.Delimiter := ';';
    mRowFields.StrictDelimiter := True;

    try
      mFileContent.LoadFromFile(mOpenDlg.FileName);

      // i := 1 zajistí přeskočení hlavičky
      if mFileContent.Count > 1 then begin
        WaitWin.StartProgress('Čekejte, prosím ...', '', mFileContent.Count);
        for i := 1 to mFileContent.Count - 1 do begin
          // Vynecháme případné prázdné řádky na konci souboru
          if Trim(mFileContent.strings[i]) = '' then Continue;
          mReceiptCardName:='';
          mPCode:='';
          // Načteme řádek do pomocného listu, který ho rozseká podle středníků
          mRowFields.DelimitedText := mFileContent.strings[i];

          // Kontrola, zda řádek má dostatek sloupců
          if mRowFields.Count > 9 then begin
            // AnsiDequotedStr odstraní uvozovky na začátku a konci textu
            mReference  := AnsiDequotedStr(mRowFields.strings[1], '"'); // 2. hodnota
            mObjednavka := AnsiDequotedStr(mRowFields.strings[2], '"'); // 3. hodnota
            mCena    := NxIBStrToFloat(AnsiDequotedStr(mRowFields.strings[9], '"')); // 10. hodnota (Cena)
            mDQCode:=NxTrapStrTrim(mReference,'-');
            mOrdNumber:=StrToInt(NxTrapStrTrim(mReference,'/'));
            mPCode:=NxTrapStrTrim(mReference,'-');
            mReference  := AnsiDequotedStr(mRowFields.strings[1], '"');
            mIssuedOrder_ID:=mOS.SQLSelectFirstAsString('Select io.id from issuedorders io left join docqueues dq on dq.id=io.docqueue_id '+
                                                        'left join periods p on p.id=io.period_id where p.code='+QuotedStr(mPCode)+
                                                        ' and io.ordnumber='+IntToStr(mOrdNumber)+' and dq.code='+QuotedStr(mDQCode),'');
            if not(NxIsEmptyOID(mIssuedOrder_ID)) then begin
              mReceiptCardList:=TStringList.Create;
              mOS.SQLSelect('Select distinct(parent_id) from storedocuments2 where provide_id='+QuotedStr(mIssuedOrder_ID)+' and flowtype='+QuotedStr('20'), mReceiptCardList);
              if mReceiptCardList.Count=1 then begin
                mReceiptCardBO:=mOS.CreateObject(Class_ReceiptCard);
                mReceiptCardBO.Load(mReceiptCardList.Strings[0],nil);
                mTotalAmount:=mOS.SQLSelectFirstAsExtended('Select sum(quantity) from storedocuments2 where Parent_ID=' + QuotedStr(mReceiptCardBO.OID),0);
                mReceiptCardName:=mReceiptCardBO.DisplayName;
                mRows:=mReceiptCardBO.GetLoadedCollectionMonikerForFieldCode(mReceiptCardBO.GetFieldCode('Rows'));
                mDistributedSum := 0;

                for j := 0 to mRows.count - 1 do begin
                  mRCRowBO := mRows.BusinessObject[j];
                  mRowAmount := mRCRowBO.GetFieldValueAsFloat('Quantity');

                  // Rozpočet dopravy
                  if j = (mRows.count - 1) then begin
                    // Poslední řádek dostane zbytek, aby to sedělo přesně na mCena
                    mTransAmount := mCena - mDistributedSum;
                  end else begin
                    // Výpočet poměru s ochranou proti dělení nulou
                    if mTotalAmount <> 0 then begin
                      mTransAmount := (mRowAmount / mTotalAmount) * mCena;
                      // Zaokrouhlení na 2 desetinná místa (SimpleRoundTo z jednotky Math, -2 značí setiny)
                      mTransAmount := NxRoundByValue(mTransAmount, ctArithmetic, 0.01);
                    end else begin
                      mTransAmount := 0;
                    end;
                    // Přičteme k průběžné sumě pro kontrolu u posledního řádku
                    mDistributedSum := mDistributedSum + mTransAmount;
                  end;

                  // Zápis do objektu
                  mRCRowBO.GetMonikerForFieldCode(mRCRowBO.GetFieldCode('AdditionalCosts_ID')).BusinessObject.SetFieldValueAsFloat('TransportationAmount', mTransAmount);
                  mRCRowBO.GetMonikerForFieldCode(mRCRowBO.GetFieldCode('AdditionalCosts_ID')).BusinessObject.SetFieldValueAsBoolean('TransportationIsLocal', True);
                  mRCRowBO.GetMonikerForFieldCode(mRCRowBO.GetFieldCode('AdditionalCosts_ID')).BusinessObject.SetFieldValueAsBoolean('TransportationUsed', True);
                end;
                if mReceiptCardBO.NeedSave then mReceiptCardBO.save;
                mReceiptCardBO.free;
                mReceiptCardList.free;
              end;
            end;

            // ZDE pak můžete pracovat s mOS a plnit příjemku
          end;
          WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr( mFileContent.Count));
          WaitWin.StepIt;
         end;
      WaitWin.stop;
      NxShowSimpleMessage('Nahráno.',mSite);
      end;
    finally
      mFileContent.Free;
      mRowFields.Free;
    end;
  end;
end;

begin
end.