procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  i : integer;
begin


  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Vytvoř vratku palet';
  mAction.Hint := 'Vytvoří vratku palet k označenému řádku faktury';
  mAction.ShortCut := TextToShortCut('Ctrl+Q'); //16450;
  //mAction.Hint := 'Změní procento slevy';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @CreateRBOD;



end;

Procedure CreateRBOD(sender:Tcomponent);
var
 msite:TSiteForm;
 mGRows:TMultiGrid;
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 mRowBO, mIIRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mVR, mVRRow:TNxCustomBusinessObject;
 i, j:integer;
 mDiscount:Extended;
 mOS:TNxCustomObjectSpace;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mImportMan:TNxDocumentImportManager;
 mUser:TNxCustomBusinessObject;
 mQuantity, mOrigQuantity, mReturnedQuantity:Extended;
 mDoc:String;
 mResult:Integer;
begin
     msite:=TComponent(sender).DynSite;
     mOS:=msite.BaseObjectSpace;
     mUser:=mOS.CreateObject(Class_SecurityUser);
     mUser.Load(NxGetActualUserID(mOS),nil);
     mBO:=TDynSiteForm(msite).CurrentObject;
     mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
     mList:=TStringList.create;
     mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
     mOrigQuantity:=0;
     mQuantity:=0;
       if Assigned(mGRows) then mIIRowBO:=TNxRowsObjectDataSet(mGRows.DataSource.DataSet).ActiveObject;
       for i:=0 to mRows.count-1 do begin
          if Assigned(mIIRowBO) then begin
            if mRows.BusinessObject[i].OID=mIIRowBO.oid then begin
               if mrows.BusinessObject[i].GetFieldValueAsInteger('RowType')=3 then begin
                if not(mIIRowBO.GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')='E300000101') then begin
                 NxShowSimpleMessage('Tlačítko lze použít pouze na hromadné dobropisování palet.',msite);
                 exit;
                end;
                if mIIRowBO.GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')='E300000101' then begin

                mRowBO:=mos.CreateObject(Class_BillOfDeliveryRow);
                mrowbo.Load(mrows.BusinessObject[i].GetFieldValueAsString('ProvideRow_ID'),nil);
                mOrigQuantity:=mRowBO.GetFieldValueAsFloat('Quantity');
                mReturnedQuantity:=GetReturnedQuantity(mOS,mRowBO.OID);
                mQuantity:=(mOrigQuantity-mReturnedQuantity);
                GetQuantityForVR(msite,mQuantity,mResult);
                if mResult=1 then
               try

                 if mQuantity>(mOrigQuantity-mReturnedQuantity) then begin
                   NxShowSimpleMessage('Vratku nelze vytvořit. K označenému řádku lze vrátit maximálně  '+FloatToStr((mOrigQuantity-mReturnedQuantity))+' ks. Zadejte prosím správné množství.',msite);

                   Exit;
                 end;
               // tento řádek dole nastavuje na DL čerpané množství na 0

                mOS.SQLExecute(format('update storedocuments2 set deliveredquantity=0 where id=''%s'' ',[mRowBO.oid]));

               // konec řádku


                //NxShowSimpleMessage(format('update storedocuments2 set deliveredquantity=%s where id=''%s'' ',[floattostr(mRowBO.GetFieldValueAsFloat('Quantity')-mQuantity),mRowBO.oid]),msite);
                mInputParams := TNxParameters.Create;
                mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                mParam.AsString := mUser.GetFieldValueAsString('X_RBOD_ID');
                mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
                mParam.AsString := mRowBO.OID;
                mImportMan := NxCreateDocumentImportManager(mOS, Class_BillOfDelivery, Class_RefundedBillOfDelivery);
                try
                  mImportMan.AddInputDocument(mRowBO.GetFieldValueAsString('Parent_ID'));
                  mImportMan.LoadParams(mInputParams);
                  mImportMan.Execute;
                  mImportMan.CheckOutputDocument;
                  if Assigned(mImportMan.OutputDocument) then begin
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mUser.GetFieldValueAsString('X_RBOD_ID')); // musi byt...
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mbo.GetFieldValueAsString('Firm_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('U_vratkaFromFV',True);
                      if mimportman.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mimportman.OutputDocument.GetFieldCode('Rows')).count=0 then begin
                        NxShowSimpleMessage('Vratku nelze vytvořit. Zboží již bylo vráceno v celém množství',msite);
                        exit;
                      end;
                      mimportman.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mimportman.OutputDocument.GetFieldCode('Rows')).BusinessObject[0].SetFieldValueAsFloat('Quantity',mQuantity);
                      mImportMan.OutputDocument.Save;
                      mDoc:=mImportMan.OutputDocument.DisplayName;
                  end;
                finally
                mImportMan.Free;
                end;
               except
                mOS.SQLExecute(format('update storedocuments2 set deliveredquantity=%s where id=''%s'' ',[FloatToStr(mOrigQuantity), mRowBO.oid]));
                mDoc:='';
                NxShowSimpleMessage('Vratku nelze vytvořit. Pravděpodobně jste zadali větší množství, než je možno vrátit. ', msite);
               end;
                mOS.SQLExecute(format('update storedocuments2 set deliveredquantity=%s where id=''%s'' ',[FloatToStr(mOrigQuantity), mRowBO.oid]));
               end;
               end;
            end;
          end;
       end;
      if not(NxIsBlank(mDoc)) then NxShowSimpleMessage('Vytvořil jsem doklad '+mDoc+'. Nezapomeňte jej dobropisovat v agendě vrácení DL!',msite);
     if Assigned(mGRows) then mGRows.DataSource.DataSet.Refresh;
end;

function GetReturnedQuantity(AOS : TNxCustomObjectSpace; aRow_ID : string) : Extended;
const
  cSQL = 'SELECT Sum(Quantity) from storedocuments2 where RDocumentRow_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aRow_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;


Function GetQuantityForVR(var ASite:TSiteForm; var aQuantity:Extended;var aResult:Integer):Boolean;
var
    mLabel1: TLabel;
    mEd1: TNumEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
begin


if ASite <> nil then begin

    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 410;
    mForm.Height:= 170;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Zadejte údaje pro vrácení';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Množství:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mEd1 := TNumEdit.Create(mForm);
    mEd1.Left := 117;
    mEd1.Top := 10;
    mEd1.Width := 200;
    mEd1.Value := aQuantity;
    mEd1.Parent := mForm;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 75;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 75;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;

    Result:=False;
    mResult := mForm.ShowModal(ASite);
    aResult:= mResult;
    if mResult = 1 then
        aQuantity:=mEd1.Value;
        Result:=true;
    mForm.free;
  end;
end;



begin
end.