uses 'eu.abra.PostProviders.extras.TransportationType.uLib';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
begin

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Aktualizace stavu';
  mAction.Hint := 'Provede přenos stavu z odeslané pošty do připojených dokladů.';
  mAction.Category := 'tabDocuments';
  mAction.OnExecute := @Start;

end;


procedure  Start(sender: TAction);
var mBO: TNxCustomBusinessObject;


begin
   mBO := TDynSiteForm(sender.Site).CurrentObject;
  try
    ChangeStatus(mBO, mBO.GetFieldValueAsInteger('X_PD_Status'),'', false );
  finally

    mBO.free;
  end;
end;


{změna stavu procesu}
procedure ChangeStatus(var ABO: TNxCustomBusinessObject; AStatusIndex: Integer; var AErrorLog :String; ANeedSave : Boolean = True);
var mList : TStringList;
    i, mRel : Integer;
    mRightID, mRow, mTableName : String;
    mClass : TNxPackedGuid;
    mBO : TNxCustomBusinessObject;
begin
  try
    try
      mTableName := '';
      mList := TStringList.Create();
      if Assigned(ABO) then
      begin
      ABO.SetFieldValueAsInteger('X_PD_Status',AStatusIndex);
      if ANeedSave then
        ABO.Save;
      end;
      ABO.ObjectSpace.SQLExecute('Update PDMIssuedDocs set X_PD_Status = '+IntToStr(AStatusIndex)+' where X_PD_FirstPackage_ID = '+QuotedStr(ABO.OID));
      ABO.ObjectSpace.SQLSelect('select rel_def,RIGHTSIDE_ID from relations where LEFTSIDE_ID = '+QuotedStr(ABO.OID),mList);

      for i := 0 to mList.Count -1 do
      begin
        mRow := mList.Strings[i];
        mRel := StrToInt(NxToken(mRow, ';'));
        mRightID := NxToken(mRow, ';');
        mTableName := '';
        case mRel of
          //FV
          1400: mTableName := 'IssuedInvoices';
          //OP
          1431: mTableName := 'ReceivedOrders';
          //DL
          1438: mTableName := 'StoreDocuments';
        end;

        OutputDebugString('eu.abra.PostProviders: ChangeStatus: mRel='+IntToStr(mRel)+'; mRightID='+mRightID + '; mTableName='+mTableName);

        if mTableName = '' then
          continue;

        try
         OutputDebugString('eu.abra.PostProviders: ChangeStatus: SQLUpdate'+ 'update '+ mTableName + ' set X_PD_Status = '+IntToStr(AStatusIndex) + ' where ID = '+ QuotedStr(ABO.OID));
         ABO.ObjectSpace.SQLExecute('update '+ mTableName + ' set X_PD_Status = '+IntToStr(AStatusIndex) + ' where ID = '+ QuotedStr(mRightID));
        except
          ShowMessage('Nepodařilo se změnit stav na připojeném dokladu. Tento krok bude přeskočen. Pravděpodobě nemáte opravnění.');
        end;

      end;

    except
      AErrorLog := AErrorLog +#10#13 +'Nepodařilo se změnit stav. '+ ExceptionMessage;
    end;
  finally
    mList.Free;
  end;
end;



begin
end.