procedure CheckARESFromIssuedInvoices(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mBO, mBOTemp: TNxCustomBusinessObject;
  mList, mStringFields: TStringList;
  mErrStr, mFieldName, mLog: string;
  mParams, mParamsTemp: TNxParameters;
  mDifferent: Boolean;
  i, j, mDiff: Integer;
begin
  Success := True;
  LogInfoStr := '';
  mErrStr:= '';
  mLog:= '';
  mList:= TStringList.Create;
  mList.Sorted:= True;
  mList.Duplicates:= dupIgnore;
  mStringFields:= TStringList.Create;
  //mParamsTemp:= TNxParameters.Create;
  try
    mStringFields.CommaText:=
      'Name,OrgIdentNumber,VATIdentNumber,ResidenceAddress_ID.Street,ResidenceAddress_ID.City,ResidenceAddress_ID.PostCode,'+
      'ResidenceAddress_ID.Country,ResidenceAddress_ID.CountryCode';
    OS.SQLSelect(
      ' SELECT FI.ID FROM IssuedInvoices II'+
      ' JOIN Firms FI ON FI.ID = II.Firm_ID '+
      ' JOIN Addresses AD ON AD.ID = FI.ResidenceAddress_ID '+
      ' WHERE FI.OrgIdentNumber <> '''' AND AD.CountryCode = ''CZ'' AND II.DocDate$DATE = '+NxFloatToIBStr(Date), mList);
    mList.Sort;
    for i:= 0 to mList.Count -1 do begin
      mDifferent:= false;
      mBO:= OS.CreateObject(Class_Firm);
      try
        mBO.Load(mList[i], nil);
        mBOTemp:= mBO.Clone;
        if TNxFirm(TNxHeaderBusinessObject(mBOTemp)).GetARESCZData(mErrStr) then begin
          for j:= 0 to mStringFields.Count -1 do begin
            if AnsiCompareStr(mBO.GetFieldValueAsString(mStringFields[j]), mBOTemp.GetFieldValueAsString(mStringFields[j])) <> 0 then begin
              LogInfoStr:= LogInfoStr + nxCrLf + nxCrLf + mBO.GetFieldValueAsString('Name')+' - IČ: '+mBO.GetFieldValueAsString('OrgIdentNumber') + nxCrLf +
                ' Nesrovnalost: Pole: '+mStringFields[j] +' | ABRA: '+mBO.GetFieldValueAsString(mStringFields[j])+' | ARES: '+mBOTemp.GetFieldValueAsString(mStringFields[j]);
              Success:= false;
              break;
            end;
          end;
        end else begin
          LogInfoStr:= LogInfoStr + nxCrLf + nxCrLf + mBO.GetFieldValueAsString('Name')+' - '+mBO.GetFieldValueAsString('OrgIdentNumber') +' Chyba: '+mErrStr + nxCrLf;
        end;

        {

          mBOTemp.SaveChangesToParameters(mParamsTemp);
          //LogInfoStr:= LogInfoStr + nxCrLf + IntToStr(mParamsTemp.Count);

          for j:= 0 to mParamsTemp.Count -1 do begin
            //LogInfoStr:= LogInfoStr + nxCrLf + mParamsTemp.Params[j].Name;
            //exit;
            mFieldName:= NxLeft(mParamsTemp.Params[j].Name, NxCharPos(';', mParamsTemp.Params[j].Name)-1);
            if mFieldName in ['Name', 'OrgIdentNumber', 'VATIdentNumber', 'ResidenceAddress_ID.Street', 'ResidenceAddress_ID.City',
              'ResidenceAddress_ID.PostCode', 'ResidenceAddress_ID.Country', 'ResidenceAddress_ID.CountryCode',
              'Street', 'City', 'PostCode', 'Country', 'CountryCode'] then begin
              case mParamsTemp.Params[j].DataType of
                dtString:
                  begin
                    mDiff:= AnsiCompareStr(mBO.GetFieldValueAsString(mFieldName), mBOTemp.GetFieldValueAsString(mFieldName));
                    LogInfoStr:= LogInfoStr + nxCrLf + mFieldName+ ' '+ mBO.GetFieldValueAsString(mFieldName) + ' '+mBOTemp.GetFieldValueAsString(mFieldName);
                  end;
              end;
              if mDiff <> 0 then begin
                mDifferent:= True;
                LogInfoStr:= LogInfoStr + nxCrLf + mBO.GetFieldValueAsString('Name')+' - '+mBO.GetFieldValueAsString('OrgIdentNumber');
                Success:= false;
                break;
              end;
            end;
          end;
        end;
        }
      finally
        mBO.Free;
        mBOTemp.Free;
      end;
    end;
    if Success = True then begin
      LogInfoStr:= LogInfoStr + nxCrLf + 'Všechny firmy byly shodné s databází ARES';
    end;
  finally
    //mParamsTemp.Free;
    mStringFields.Free;
    mList.Free;
  end;
end;

begin
end.