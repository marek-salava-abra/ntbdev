procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportVouchers';
  mAction.Caption := '## Import Vouchers ##';
  mAction.Hint := 'Import data from E-shop API';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportData;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportVouchersXLS';
  mAction.Caption := '## Import Vouchers XLS ##';
  mAction.Hint := 'Import data from XLS, structure of XLS:FirmCode, FirmName, VoucherCode';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportDataXLS;
end;

Procedure ImportDataXLS(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 i,j:integer;
 mExcel, mWB, mSheet: Variant;
 mVoucherCode,mFirmCode, mSalesRep, mVoucher_ID, mFirm_ID, mSales_ID:string;
 mVoucherBO, mFirmBO, mbusTransactionBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mOpenDlg:=TOpenDialog.Create(sender);
 mOpenDlg.Title := 'Import XLS';
 mOpenDlg.Filter := 'Excel files (*.xls, *.xlsx)| *.xls;*.xlsx';
 if mOpenDlg.Execute then begin
  try
          mExcel := CreateOleObject('Excel.Application');
          mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
          mSheet := mWB.Sheets[1];
          i:=2;
          j:=mSheet.UsedRange.Rows.Count+1;
          WaitWin.StartProgress('Please, wait ...', '', j);
          while i<j  do begin
            WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(j));
              mVoucherCode:=VarToStr(msheet.cells[i,3]);
              mFirmCode:=VarToStr(msheet.cells[i,1]);
              mSalesRep:=AnsiLeftStr(VarToStr(msheet.cells[i,4]),20);
              mVoucher_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid='+QuotedStr(Class_BO_Vouchers)+
                                                      'and code='+QuotedStr(mVoucherCode)+' and hidden=''N'' ','');
              mFirm_ID:='';
              if not(NxIsBlank(mFirmCode)) then mFirm_ID:=mOS.SQLSelectFirstAsString('Select id from firms where firm_id is null and hidden=''N'' and code='+QuotedStr(mFirmCode),'');
              if not(NxIsBlank(mSalesRep)) then mSales_ID:=mOS.SQLSelectFirstAsString('Select id from bustransactions where hidden=''N'' and code='+QuotedStr(mSalesRep),'');
              mVoucherBO:=mOS.CreateObject(Class_BO_Vouchers);
              if NxIsEmptyOID(mVoucher_ID) then mVoucherBO.new else mVoucherBO.Load(mVoucher_ID);
              mVoucherBO.SetFieldValueAsString('Code',mVoucherCode);
              mVoucherBO.SetFieldValueAsDateTime('X_DateTimeOfLastChange',Now);
              if not(NxIsEmptyOID(mFirm_ID)) then
               mVoucherBO.SetFieldValueAsString('X_VO_Company_ID',mFirm_ID);
              mVoucherBO.save;
              mVoucherBO.free;
              if NxIsEmptyOID(mSales_ID) and not(NxIsBlank(mSalesRep)) then begin
                mbusTransactionBO:=mOS.CreateObject(Class_BusTransaction);
                mbusTransactionBO.New;
                mbusTransactionBO.prefill;
                mbusTransactionBO.SetFieldValueAsString('Code',mSalesRep);
                mbusTransactionBO.Save;
                mSales_ID:=mbusTransactionBO.OID;
                mbusTransactionBO.free;
              end;
              if not(NxIsEmptyOID(mFirm_ID)) and not(NxIsEmptyOID(mSales_ID)) then begin
                mFirmBO:=mOS.CreateObject(class_firm);
                mFirmBO.load(mFirm_ID,nil);
                mFirmBO.SetFieldValueAsString('X_SalesRep_ID',mSales_ID);
                mFirmBO.save;
                mfirmbo.free;
              end;
            inc(i);
            WaitWin.StepIt;
          end;
         WaitWin.Stop;
         mWB.close;

     except
      WaitWin.Stop;
      mWB.close;
      NxShowSimpleMessage(ExceptionMessage,msite);
  end;
 end;
end;


Procedure ImportData(Sender:TComponent);
var
 mSite:TSiteForm;
 mJSON:TJSONSuperObject;
 i,j, mRes:integer;
 mDate:Extended;
 mVoucher_ID, mVoucherCode:string;
 mVoucherBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=TBusRollSiteForm(mSite).BaseObjectSpace;
 mJSON:=TJSONSuperObject.Create;
 mDate:=Date-7;
 if GetDate(mSite,mDate, mRes) then begin
     if mDate<10 then mDate:=date-100;
     mJSON:=API_GET('https://www.lipoelastic.cz/api/vouchers?_token=dm91Y2hlcnNfYXBpOlRMbTRoUkpza1JGN0xFNA&countrySiteId=14&startDate='+FormatDateTime('YYYY-MM-DD',mDate));
     if mJSON.B['success'] then begin
       j:=mJSON.A['coupons'].Length;
       if j=0 then begin
         NxShowSimpleMessage('There is none voucher. Exiting.', mSite);
       end else begin
        WaitWin.StartProgress('Please, wait ...', '', j);
        for i:=0 to j-1 do begin
          mVoucherCode:=mJSON.A['coupons'].O[i].S['code'];
          mVoucher_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where code='+QuotedStr(mVoucherCode)+' and clsid='+QuotedStr(Class_BO_Vouchers)+' and hidden='+QuotedStr('N'),'');
          if NxIsEmptyOID(mVoucher_ID) then begin
            mVoucherBO:=mOS.CreateObject(Class_BO_Vouchers);
            mVoucherBO.new;
            mVoucherBO.Prefill;
            mVoucherBO.SetFieldValueAsString('Code',mVoucherCode);
            mVoucherBO.SetFieldValueAsDateTime('X_DateTimeOfLastChange',Now);
            mVoucherBO.save;
            mVoucherBO.free;
          end;
         WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(j));
         WaitWin.StepIt;
        end;
       WaitWin.stop;
       TBusRollSiteForm(mSite).RefreshData;
       NxShowSimpleMessage('Done.',mSite);
       end;
      end else begin
        NxShowSimpleMessage(mJSON.AsString,msite);
        NxShowSimpleMessage('False result from API. Exiting',mSite);
      end;
      end;
end;


function API_GET(aURL:String): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mRequest, mLogin: string;
  mJSON:TJSONSuperObject;
  mList:TStringList;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('GET', aURL);
    //mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
    //mWinHTTP.SetRequestHeader('Accept-Encoding', 'identity');
    mWinHTTP.Send();
    Result:=TJSONSuperObject.ParseString(ConvertToText(mWinHTTP.Responsebody), True);
  except

  end;
end;


function ConvertToText(aUnicodeBytes: TBytes): String;
var
  mUnicodeBites: TBytes;
begin
  mUnicodeBites := TEncoding.Convert(aUnicodeBytes,Encoding_cpUTF_8,Encoding_cpUTF_16);
  Result := TEncoding.Unicode.GetString(mUnicodeBites);
end;


function ConvertUTF8toString(aString: String): String;
var
  mUnicodeBites: TBytes;
begin
  mUnicodeBites := TEncoding.UTF8.GetBytes(aString);
  mUnicodeBites := TEncoding.Convert(mUnicodeBites,Encoding_cpUTF_8,Encoding_cpUTF_16);
  Result := TEncoding.Unicode.GetString(mUnicodeBites);
end;

Function GetDate(var ASite : TSiteform; var aDate:Extended; var aResult:integer):Boolean;
var
    mLabel: TLabel;
    mDateEd:TDateEdit;
    mButOk, mButCancel : TButton;
    mResult, mCount : integer;
    mForm : TForm;

 begin
 if ASite <> nil then begin
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 510;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Info:';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Date from:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mDateEd := TDateEdit.Create(mForm);
    mDateEd.Left := 140;
    mDateEd.Top := (mCount*25)+10;
    mDateEd.Width := 80;
    mDateEd.Date := aDate;
    mDateEd.Parent := mForm;



    mCount:= mCount+1;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Default:= true;
    mButOk.Caption := 'OK';
    mButOk.Top := (mCount*25)+20;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := (mCount*25)+20;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    mForm.Height:= (mCount*25)+95;

    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
         aResult:=1;
         aDate:=mDateEd.Date;
         Result:=True;
     end;
    mForm.free;
  end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;


begin
end.