procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportOSV';
  mAction.Caption := 'Import dat z XML do OSVF';
  mAction.Hint := 'Naimportuje data z XML';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportXML;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actShowReceipt';
  mAction.Caption := 'Zobrazí účtenku';
  mAction.Hint := 'Z aktuálního řádku zobrazí účtenku';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @ShowReceipt;
end;

Procedure ShowReceipt(Sender:TComponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 mControl: TControl;
 mDataset: TNxRowsObjectDataSet;
 mCurrRowBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
    mControl:= mSite.FindChildControl('tabRows.grdRows');
    mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
    mCurrRowBO:=mDataset.CurrentObject;
    if not(NxIsBlank(mCurrRowBO.GetFieldValueAsString('X_ReceiptURL'))) then
     NxShellOpenFile(mCurrRowBO.GetFieldValueAsString('X_ReceiptURL'))
     else NxShowSimpleMessage('Nebyla přiložena účtenka',mSite);
 end;
end;

Procedure ImportXML(sender:TComponent);
Var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mOpenDlg:TOpenDialog;
 i,j,k, l:integer;
 mXMLHead:TNxScriptingXMLWrapper;
 mBO, mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mFirm_ID, mOtherExpense_ID, mOtherExpenseRow_ID, mDateStr, mPeriodCode, mVatRate_ID, mVATCode:string;
 mDate, mDocDate, mVATTAmount:Extended;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 mOpenDlg := TOpenDialog.Create(Sender);
 mOpenDlg.Title := 'Import dat z XML do OSVF';
 mOpenDlg.Filter := 'Soubory XML (*.xml)| *.xml';
 l:=0;
 if mOpenDlg.Execute then begin
    mXMLHead:=TNxScriptingXMLWrapper.Create;
    mXMLHead.loadFromFile(mOpenDlg.FileName);
    if mXMLHead.getElementsCountInArray('expense')>0 then begin
       k:=mXMLHead.getElementsCountInArray('expense');
       WaitWin.StartProgress('Čekejte, prosím ...', '', k);
       for i:=0 to mXMLHead.getElementsCountInArray('expense')-1 do begin
         mOtherExpenseRow_ID:=mOS.SQLSelectFirstAsString('Select id from otherexpenses2 where X_ExpenseID='+QuotedStr(mXMLHead.getElementAsString('expense['+IntToStr(i)+'].expenseId')),'');
          if NxIsEmptyOID(mOtherExpenseRow_ID) then begin
           mDate:=iiCompileDateTime(mXMLHead.getElementAsString('expense['+IntToStr(i)+'].createExpenseDate'));
           //mDate:=mXMLHead.getElementAsDateTime('expense['+IntToStr(i)+'].createExpenseDate');
           mDocDate:=NxIncMonth(StrToDate('1.'+(IntToStr(NxExtractMonth(mDate)))+'.'+IntToStr(NxExtractYear(mDate))),1)-1;
           mPeriodCode:=IntToStr(NxExtractYear(mDocDate));
           mDateStr:=mPeriodCode+AnsiRightStr('0'+IntToStr(NxExtractMonth(mDocDate)),2);
           mFirm_ID:=GetOrCreateFirmFidoo(mOS,mXMLHead.getAttributeValue('expense['+IntToStr(i)+'].user','idUser'),
                                              mXMLHead.getAttributeValue('expense['+IntToStr(i)+'].user','firstName'),
                                              mXMLHead.getAttributeValue('expense['+IntToStr(i)+'].user','lastName'));
           mOtherExpense_ID:=mOS.SQLSelectFirstAsString('Select id from otherexpenses where firm_id='+QuotedStr(mFirm_ID)+
                                                        ' and X_YearMonth='+QuotedStr(mDateStr)+' and docqueue_id='+QuotedStr('30F0000101'),'');
           mBO:=mOS.CreateObject(Class_OtherExpense);
           if NxIsEmptyOID(mOtherExpense_ID) then begin
             mBO.New;
             mBO.Prefill;
             mBO.SetFieldValueAsString('DocQueue_ID','30F0000101');
             mBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
             mbo.SetFieldValueAsString('Period_ID',mOS.SQLSelectFirstAsString('Select id from periods where code='+QuotedStr(mPeriodCode),''));
             mbo.SetFieldValueAsDateTime('DocDate$Date',mDocDate);
             mbo.SetFieldValueAsBoolean('VATDocument',true);
             mBO.SetFieldValueAsInteger('DataEntryKind',0);
             mBO.SetFieldValueAsString('X_YearMonth',mDateStr);
           end else begin
             mBO.Load(mOtherExpense_ID,nil);
           end;
             mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('rows'));
             mRowBO:=mRows.AddNewObject;
             mVATTAmount:=NxIBStrToFloat(mXMLHead.getElementAsString('expense['+IntToStr(i)+'].amountVat'));
             mVATCode:='0';
             if mVATTAmount>0 then begin
               try
                mVATCode:=NxFloatToIBStr(100*NxIBStrToFloat(mXMLHead.getElementAsString('expense['+IntToStr(i)+'].vatRate')));
               except
                mVATCode:='0';
               end;
             end;
             mVatRate_ID:=mOS.SQLSelectFirstAsString('Select id from vatrates where country_id='+QuotedStr('00000CZ000')+' and tariff='+mVATCode,'');
             mRowBO.SetFieldValueAsString('VatRate_ID',mVatRate_ID);
             mRowBO.SetFieldValueAsFloat('TAmountWithoutVAT',NxIBStrToFloat(mXMLHead.getElementAsString('expense['+IntToStr(i)+'].taxBase')));
             mRowBO.SetFieldValueAsFloat('VATTAmount',mVATTAmount);
             if ElementExists(mXMLHead,'expense['+IntToStr(i)+'].accountingCategories.accountingCategoryCode') then
             mRowBO.SetFieldValueAsString('ExpenseType_ID',mos.SQLSelectFirstAsString('Select id from expensetypes where hidden=''N'' and code='+
                     QuotedStr(mXMLHead.getElementAsString('expense['+IntToStr(i)+'].accountingCategories.accountingCategoryCode')),''));
             mRowBO.SetFieldValueAsString('Text',AnsiLeftStr(mXMLHead.getElementAsString('expense['+IntToStr(i)+'].note'),160));
             mRowBO.SetFieldValueAsDateTime('X_DocDate$Date',mDate);
             if mXMLHead.getElementAsString('expense['+IntToStr(i)+'].receiptPresent')='true' then
              mRowBO.SetFieldValueAsString('X_ReceiptURL',mXMLHead.getElementAsString('expense['+IntToStr(i)+'].receiptLinks.link'));
             mRowBO.SetFieldValueAsString('X_ExpenseID',mXMLHead.getElementAsString('expense['+IntToStr(i)+'].expenseId'));
             mRowBO.SetFieldValueAsString('X_DocDateStr',DateTimeToStr(mDate));
             mRowBO.SetFieldValueAsString('Division_ID','1000000101');
             mBO.save;
             mBO.free;
             l:=l+1;
           end;
         WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
         WaitWin.StepIt;
      end;
     WaitWin.Stop;
     NxShowSimpleMessage('Zpracováno '+IntToStr(k)+' záznamů, založeno '+inttostr(l)+' řádků.',mSite);
    end;
 end;
end;

function ElementExists(mHlavicka : TNxScriptingXMLWrapper; AName: string): Boolean;

begin
  try
    if not(mHlavicka.getElementAsString(AName)='') then Result:= True;
  except
    Result:= False;
  end;
end;

function GetOrCreateFirmFidoo(aOS:TNxCustomObjectSpace; aID, afirstname, alastname:string):string;
var
 mFirmBO:TNxCustomBusinessObject;
 mFirm_ID:string;
begin
  mFirm_ID:=aos.SQLSelectFirstAsString('Select id from firms where firm_id is null and hidden=''N'' and X_fidooID='+QuotedStr(aID),'');
  if NxIsEmptyOID(mFirm_ID) then begin
    mFirmBO:=aOS.CreateObject(Class_Firm);
    mFirmBO.New;
    mFirmBO.Prefill;
    mFirmBO.SetFieldValueAsString('name', afirstname+' '+alastname);
    mFirmBO.SetFieldValueAsString('X_fidooID',aID);
    mFirmBO.save;
    mFirm_ID:=mFirmBO.OID;
    mFirmBO.Free;
  end;
  Result:=mFirm_ID;
end;

function iiCompileDateTime(const AText : string) : TDate;
var
  mYear, mMonth, mDay,mhour, mMin, mSec, a : string;
begin
  a := AText;
  mYear := NxToken(a, '-');
  mMonth  := NxToken(a, '-');
  mDay  := NxToken(a, 'T');
  mhour := NxToken(a, ':');
  mMin := NxToken(a, ':');
  mSec := NxToken(a, '+');
  a := Format('%s.%s.%s %s:%s:%s', [mDay, mMonth, mYear, mHour, mMin, mSec]);
  Result := StrToDateTime(a);
end;

procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol: TNxMultiGridColumn;
  mMGCol2: TNxMultiGridBooleanColumn;
  mMGColRoll: TNxMultiGridObjectRollColumn;
  b: Boolean;
  mMGcol3:TNxMultiGridDateColumn;

  procedure iPreparePosition(ALayout, ALine, ARequestPosition: Integer);
  var
    ii: Integer;
  begin
    for ii:=mMG.ColumnCount-1 downto 0 do
      if (mMG.Columns[ii].Layout = ALayout) and (mMG.Columns[ii].Line = ALine) and
        (mMG.Columns[ii].Order >= ARequestPosition) then
        mMG.Columns[ii].Order := mMG.Columns[ii].Order + 1;
  end;

begin
  mMG := TMultiGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdRows'));
  if Assigned(mMG) then begin
    b := True;
    for i:=mMG.ColumnCount-1 downto 0 do
      if mMG.Columns[i].FieldName = 'X_DocDateStr' then
        b := False;
    if b then begin
      mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_DocDateStr', ftWideString, 0, False, 306);
      with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'X_DocDateStr', False) do begin
        ReadOnly:= True;
        FieldName:= 'X_DocDateStr';
        FieldKind:= fkData;
      end;
      iPreparePosition(0, 0, 9);
      mMGCol := TNxMultiGridColumn.Create(mMG.Owner);
      mMGCol.FieldName := 'X_DocDateStr';
      mMGCol.Caption := 'Datum Fidoo';
      mMGCol.ReadOnly := True;
      mMGCol.Kind := ckText;
      mMGCol.Elastic := True;
      mMGCol.Width := 160;
      mMGCol.Layout := 0;
      mMGCol.Line := 0;
      mMGCol.Order := 9;
      mMG.AddColumn(mMGCol);
    end;



  end;
end;


begin
end.