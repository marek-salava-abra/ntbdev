const
  cURLCNB='https://www.cnb.cz/cs/financni_trhy/devizovy_trh/kurzy_devizoveho_trhu/denni_kurz.txt';
  cLocalCurrency='0000CZK000';

Procedure ImportExchangeRate(OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String; aURL: String);
var
  mFile, mRow, mResult, mLogInf: TStringList;
  mCode, mOID: String;
  mValue: Double;
  mDate: TDateTime;
  i: Integer;
  mKurz: TNxCustomBusinessObject;
begin
  mLogInf:=TStringList.Create;
  try
    mFile:=TStringList.Create;
    try
      if CFxInternet.HTTPGetText(aURL,'',mFile) then begin
        mDate:=StrToDate(Trim(NxLeft(mFile[0],10)));//StrToDate(NxSetDateToFloatString(Trim(NxLeft(mFile[0],10))));
        if mDate=0 then RaiseException('Chybně načtený kurzovní lístek!');
        for i:=2 to mFile.Count -1 do begin
          mRow:=TStringList.Create;
          try
            NxTrapStrToStrings(mFile[i],'|',mRow);
            mCode:=NxPadL(mRow[3],7,'0') + '000';
            mResult:=TStringList.Create;
            mOID:='0000000000';
            try
              OS.SQLSelect(Format('Select ID From ExchangeRates Where Currency_ID=''%s'' and RefCurrency_ID=''%s''',[mCode,cLocalCurrency]),mResult);
              if mResult.Count=1 then mOID:=mResult[0];
            finally
              mResult.Free;
            end;
            if not(NxIsEmptyOID(mOID)) then begin
              mValue:=StrToFloat(mRow[4]);
              mKurz:=OS.CreateObject('W3AWZR451FD133N2010DELDFKK');
              try
               if mKurz.Test(mOID) then begin
                 mKurz.Load(mOID,nil);
                 if mDate<>mKurz.GetFieldValueAsDateTime('Date$DATE') then begin
                   mKurz.SetFieldValueAsDateTime('AnnouncementDate$DATE',mDate);
                   mKurz.SetFieldValueAsDateTime('Date$DATE',mDate);
                   mKurz.SetFieldValueAsFloat('CurrRate',mValue);
                   mKurz.SetFieldValueAsBoolean('ActualRate',true);
                   if mKurz.NeedSave then mKurz.Save;
                 end else begin
                   mLogInf.Append('Pro měnu '+ mRow[3] +' není nový platný kurz.');
                 end;;
               end;
              finally
                mKurz.Free;
              end;
            end;
          finally
            mRow.Free;
          end;
        end;
      end else begin
        Success:=False;
        mLogInf.Append('Nepodařilo se získat soubor kurzového lístku!');
      end;
    finally
      mFile.Free;
    end;
  except
    mLogInf.Append(ExceptionMessage);
    Success:=False;
  end;
  LogInfoStr:=mLogInf.Text;
  mLogInf.Free;
end;

procedure  KurzovniListek(OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
begin
  Success := True;
  LogInfoStr := '';
  ImportExchangeRate(OS,Success,LogInfoStr,cURLCNB);
end;

begin
end.