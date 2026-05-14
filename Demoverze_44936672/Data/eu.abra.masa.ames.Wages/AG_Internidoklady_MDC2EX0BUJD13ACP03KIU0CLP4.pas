uses 'eu.abra.masa.ames.Wages.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportWages';
  mAction.Caption := 'Naimportuje mzdy';
  mAction.Hint := 'Naimportuje data z XLS do interního dokladu';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportWages;
end;

Procedure ImportWages(Sender:TComponent);
var
 mSite:TSiteForm;
 mDocQueue_ID, mDivision_ID:string;
 mDocDate, mValue:extended;
 mBO, mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 i,j, mResult:integer;
 mOpenDlg:TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mExcel, mWB, mSheet: Variant;
 mSpolecnik:Boolean;
begin
  mSite:=TComponent(Sender).DynSite;
  mOS:=mSite.BaseObjectSpace;
  mDocQueue_ID:='1000000101';
  mDivision_ID:='';
  mDocDate:=EncodeDate(CurrentYear,MonthOfTheYear(date),1)-1;
  mResult:=0;
  mSpolecnik:=false;
  GetData(mSite,mDivision_ID,mDocQueue_ID,mDocDate, mSpolecnik,mResult);
  if mResult=1 then begin
     if NxIsEmptyOID(mDivision_ID) then begin
       NxShowSimpleMessage('Středisko musí být vyplněno, ukončuji.',mSite);
       exit;
     end;
     if NxIsEmptyOID(mDocQueue_ID) then begin
       NxShowSimpleMessage('Řada dokladů musí být vyplněna, ukončuji.',mSite);
       exit;
     end;
     if mDocDate=0 then begin
       NxShowSimpleMessage('Datum musí být vyplněno, ukončuji.',mSite);
       exit;
     end;
     mOpenDlg:=TOpenDialog.Create(sender);
     mOpenDlg.Title := 'Import z Excelu';
     mOpenDlg.Filter := 'Soubory aplikace Excel (*.xls, *.xlsx)| *.xls;*.xlsx';
     if mOpenDlg.Execute then begin
       try
        mBO:=mOS.CreateObject(Class_InternalDocument);
        mBO.new;
        mbo.Prefill;
        mBO.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);
        mBO.SetFieldValueAsDateTime('DocDate$Date',mDocDate);
        mBO.SetFieldValueAsString('Period_ID',mos.SQLSelectFirstAsString(format('select id from periods where code=''%s'' ',[FormatDateTime('YYYY',mDocDate)])));
        mBO.SetFieldValueAsString('Firm_ID','F011000000');
        mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
        i:=23;
        mExcel := CreateOleObject('Excel.Application');
        mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
        mSheet := mWB.Sheets[1];
        j:=mSheet.UsedRange.Rows.Count+1;
        WaitWin.StartProgress('Čekejte, prosím ...', '', j);
        while i<j  do begin
        WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(j));
                 //if NxIBStrToFloat(VarToStr(mSheet.Cells[i, 3]))>0 then begin
                  mValue:=NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 34]),' ','',[srall]))+NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 35]),' ','',[srall]))+
                          NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 36]),' ','',[srall]))+NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 37]),' ','',[srall]))+
                          NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 38]),' ','',[srall]))+NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 39]),' ','',[srall]))+
                          NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 40]),' ','',[srall]))+NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 41]),' ','',[srall]))+
                          NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 42]),' ','',[srall]))+NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 43]),' ','',[srall]))+
                          NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 44]),' ','',[srall]))+NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 45]),' ','',[srall]))+
                          NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 46]),' ','',[srall]))+NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 47]),' ','',[srall]))+
                          NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 48]),' ','',[srall]))+NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 49]),' ','',[srall]))+
                          NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 50]),' ','',[srall]))+NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 51]),' ','',[srall]))+
                          NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 52]),' ','',[srall]))+NxIBStrToFloat(NxSearchReplace(VarToStr(mSheet.Cells[i, 53]),' ','',[srall]));
                  //if i=45 then NxShowSimpleMessage('#'+VarToStr(mSheet.Cells[i, 2])+'#    hodnota'+FloatToStr(mValue),mSite);
                 //end;
            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'Stravenkový paušál',[srAll],0)>0) and not(mSpolecnik) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['527100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['331100'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Stravenkový paušál');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue);
            end;
            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'Stravenkový paušál',[srAll],0)>0) and (mSpolecnik) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['527100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['331100'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Stravenkový paušál');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue-1);
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['527100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['366100'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Stravenkový paušál - společníci');
             mRowBO.SetFieldValueAsFloat('TAmount',1);
            end;

            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'Hrubá mzda .',[srAll],0)>0) and not(mSpolecnik) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['521100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['331100'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Hrubá mzda');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue);
            end;
            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'Hrubá mzda .',[srAll],0)>0) and (mSpolecnik) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['521100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['331100'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Hrubá mzda');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue-1);
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['523100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['366100'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Hrubá mzda - společníci');
             mRowBO.SetFieldValueAsFloat('TAmount',1);
            end;

            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'Penzijní připojištění org',[srAll],0)>0) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['527100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['379110'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Penzijní připojištění organizace');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue);
            end;

            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'Daň po sl. a bon. (',[srAll],0)>0) and not(mSpolecnik) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['331100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['342100'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Daň po sl. a bon. (k platbě)');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue);
            end;
            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'Daň po sl. a bon. (',[srAll],0)>0) and (mSpolecnik) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['331100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['342100'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Daň po sl. a bon. (k platbě)');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue-1);
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['366100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['342100'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Daň po sl. a bon. (k platbě) - společníci');
             mRowBO.SetFieldValueAsFloat('TAmount',1);
            end;

            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'ZP zaměstnanec.',[srAll],0)>0) and not(mSpolecnik) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['331100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['336200'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Zdravotní pojištění odvod');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue);
            end;
            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'ZP zaměstnanec.',[srAll],0)>0) and (mSpolecnik) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['331100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['336200'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Zdravotní pojištění odvod');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue-1);
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['366100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['336200'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Zdravotní pojištění odvod - společníci');
             mRowBO.SetFieldValueAsFloat('TAmount',1);
            end;

            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'SP zaměstnanec.',[srAll],0)>0) and not(mSpolecnik) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['331100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['336100'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Sociální pojištění odvod');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue);
            end;
            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'SP zaměstnanec.',[srAll],0)>0) and (mSpolecnik) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['331100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['336100'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Sociální pojištění odvod');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue-1);
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['366100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['336100'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Sociální pojištění odvod - společníci');
             mRowBO.SetFieldValueAsFloat('TAmount',1);
            end;

            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'Ostatní zákonné srážky',[srAll],0)>0) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['331100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['333100'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Ostatní zákonné srážky');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue);
            end;

            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'Půjčky .',[srAll],0)>0) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['331100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['335100'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Půjčky');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue);
            end;

            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'Odbory .',[srAll],0)>0) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['331100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['333100'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Odbory');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue);
            end;

            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'Škody .',[srAll],0)>0) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['331100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['335100'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Škody');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue);
            end;

            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'MultiSport',[srAll],0)>0) and not(mSpolecnik) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['331100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['648200'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','MultiSport');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue);
            end;
            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'MultiSport',[srAll],0)>0) and (mSpolecnik) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['331100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['648200'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','MultiSport');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue-1);
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['366100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['648200'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','MultiSport - společníci');
             mRowBO.SetFieldValueAsFloat('TAmount',1);
            end;

            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'SP zaměstnavatel',[srAll],0)>0) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['524100'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['336100'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Sociální pojištění organizace');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue);
            end;

            if (NxSearch(VarToStr(mSheet.Cells[i, 2]),'ZP zaměstnavatel (9%).',[srAll],0)>0) then begin
             mRowBO:=mRows.AddNewObject;
             mRowBO.Prefill;
             mRowBO.SetFieldValueAsString('DebitAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['524200'])));
             mRowBO.SetFieldValueAsString('CreditAccount_ID',mos.SQLSelectFirstAsString(format('select id from accounts where code=''%s'' ',['336200'])));
             mRowBo.SetFieldValueAsString('DebitDivision_ID',mDivision_ID);
             mRowBo.SetFieldValueAsString('CreditDivision_ID',mDivision_ID);
             mRowBO.SetFieldValueAsString('Text','Zdravotní pojištění organizace');
             mRowBO.SetFieldValueAsFloat('TAmount',mValue);
            end;

        Inc(i);
        WaitWin.StepIt;
        end;
        mbo.SetFieldValueAsString('Description','Mzdy '+FormatDateTime('YYYY',mDocDate)+'/'+FormatDateTime('MM',mDocDate)+' '+mrowbo.GetFieldValueAsString('DebitDivision_ID.Name'));
        mBO.save;
        TDynSiteForm(mSite).RefreshData;
        TDynSiteForm(mSite).ActiveDataSet.SeekID(mBO.OID);
        mWB.close;
        finally
         WaitWin.Stop;
        end;
     end;


  end;
end;


begin
end.