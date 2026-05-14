uses 'eu.abra.mavy.LabelPrinter.API.SendToLabelPrinter';

{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
  mJSON: TJSONSuperObject;
  mOS: TNxCustomObjectSpace;
  mLabelPrinter_ID, mStateCode,mMessage,mBarcode, mState_ID: string;
  mError: boolean;
  mSourceBO: TNxCustomBusinessObject;

begin
  try
    if osNew IN Self.State then begin
      mOS:= Self.ObjectSpace;
      try
        mSourceBO:= mOS.CreateObject(Self.GetFieldValueAsString('X_LP_SourceCLSID'));
        mSourceBO.Load(Self.GetFieldValueAsString('X_LP_Source_ID'),nil);
        if Assigned(mSourceBO) then begin
          SendPackage(mOS, Self, mSourceBO, mJSON, mError,mStateCode,mMessage,mBarcode,mLabelPrinter_ID);
        end;
        if not mError then begin
          mState_ID:= SQLSingleSelect(mOS, 'SELECT ID FROM DefRollData WHERE Code = '+ mStateCode + ' and CLSID = ''VB0Q5JB0CRD4V4HES4OTTIYVIK''');
          if not NxIsEmptyOID(mState_ID) then Self.SetFieldValueAsString('X_LP_State_ID', mState_ID);
          Self.SetFieldValueAsString('X_LP_Error_message', mMessage);
          Self.SetFieldValueAsString('X_LP_Barcode', mBarcode);
          Self.SetFieldValueAsString('X_LP_ExternalID', mLabelPrinter_ID);
          AResult:= True;
        end
        else begin
          Self.AddValidateError(Self.GetFieldCode('DocQueue_ID'),'Nepodařilo se uložit zásilku do LP, balík nebude uložen');
          AResult:= False;
        end;
        //mJSON.Free;
        mSourceBO.Free;
      except
        if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Nastala chyba při validaci nového balíku: ' + ExceptionMessage);
        AResult:= False;
      end;
    end;
  finally

  end;
end;

begin
end.