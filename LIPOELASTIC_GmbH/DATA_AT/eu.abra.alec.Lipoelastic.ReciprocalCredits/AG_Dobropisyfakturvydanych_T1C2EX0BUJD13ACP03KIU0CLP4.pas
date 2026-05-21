procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.Name:= 'actCreateReciprocalCredit';
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Reciprocal Credit ##';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateReciprocalCreditForSelectedDocs;
end;


procedure CreateReciprocalCreditForSelectedDocs(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mList, mLogList: TStringList;
  i: Integer;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mList:= TStringList.Create;
  mLogList:= TStringList.Create;
  try
    TDynSiteForm(mSite).FillListWithSelectedRows(mList);
    for i:= 0 to mList.Count -1 do
    begin
      CreateReciprocalCredit(mOS, mList[i], mLogList)
    end;

    if mLogList.Count > 0 then
      NxShowSimpleMessage(mLogList.Text, mSite);
  finally
    mList.Free;
    mLogList.Free;
  end;
end;


function CreateReciprocalCredit(AOS: TNxCustomObjectSpace; ACreditNote_ID: string; ALogList: TStringList): Boolean;
const
  cDOCQUEUE_ID_RECIPROCAL_CREDIT = '0300000101';
  cCURRENCY_ID = '0000EUR000';
var
  mCreditNoteBO, mRecCreditBO, mRCRowBO: TNxCustomBusinessObject;
  mRCRows: TNxCustomBusinessMonikerCollection;
begin
  Result:= false;

  mCreditNoteBO:= AOS.CreateObject(Class_IssuedCreditNote);
  mRecCreditBO:= AOS.CreateObject(Class_Compensation);
  try
    try
      mCreditNoteBO.Load(ACreditNote_ID, nil);

      mRecCreditBO.New;
      mRecCreditBO.Prefill;
      mRecCreditBO.SetFieldValueAsString('DocQueue_ID', cDOCQUEUE_ID_RECIPROCAL_CREDIT);
      mRecCreditBO.SetFieldValueAsDateTime('DocDate$DATE', Date);
      mCreditNoteBO.SetFieldValueAsString('Currency_ID', cCURRENCY_ID);
      //mRecCreditBO.SetFieldValueAsString('Firm_ID', mCreditNoteBO.GetFieldValueAsString('Firm_ID'));

      mRCRows:= mRecCreditBO.GetLoadedCollectionMonikerForFieldCode(mRecCreditBO.GetFieldCode('Rows'));

      //Credit note
      mRCRowBO:= mRCRows.AddNewObject;
      mRCRowBO.Prefill;
      mRCRowBO.SetFieldValueAsBoolean('Credit', False);
      mRCRowBO.SetFieldValueAsDateTime('DocDate$DATE', Date);
      mRCRowBO.SetFieldValueAsString('Currency_ID', mCreditNoteBO.GetFieldValueAsString('Currency_ID'));
      mRCRowBO.SetFieldValueAsFloat('Amount', mCreditNoteBO.GetFieldValueAsFloat('Amount'));
      mRCRowBO.SetFieldValueAsFloat('PAmount', mCreditNoteBO.GetFieldValueAsFloat('Amount'));
      mRCRowBO.SetFieldValueAsString('PDocumentType', '60');
      mRCRowBO.SetFieldValueAsString('PDocument_ID', mCreditNoteBO.OID);

      //Issued Invoice
      mRCRowBO:= mRCRows.AddNewObject;
      mRCRowBO.SetFieldValueAsBoolean('Credit', True);
      mRCRowBO.SetFieldValueAsDateTime('DocDate$DATE', Date);
      mRCRowBO.SetFieldValueAsString('Currency_ID', mCreditNoteBO.GetFieldValueAsString('Currency_ID'));
      mRCRowBO.SetFieldValueAsFloat('Amount', mCreditNoteBO.GetFieldValueAsFloat('Amount'));
      mRCRowBO.SetFieldValueAsFloat('PAmount', mCreditNoteBO.GetFieldValueAsFloat('Amount'));
      mRCRowBO.SetFieldValueAsString('PDocumentType', '03');
      mRCRowBO.SetFieldValueAsString('PDocument_ID', mCreditNoteBO.GetFieldValueAsString('Source_ID'));

      mRecCreditBO.Save;
      ALogList.Add(mCreditNoteBO.DisplayName + ' --> '+ mRecCreditBO.DisplayName + ' - OK ');
      Result:= True;
    except
      ALogList.Add(mCreditNoteBO.DisplayName + ' --> '+ mRecCreditBO.DisplayName + ' - Error: ' + ExceptionMessage);
      Result:= false;
    end;
  finally
    mCreditNoteBO.Free;
    mRecCreditBO.Free;
  end;
end;



begin
end.