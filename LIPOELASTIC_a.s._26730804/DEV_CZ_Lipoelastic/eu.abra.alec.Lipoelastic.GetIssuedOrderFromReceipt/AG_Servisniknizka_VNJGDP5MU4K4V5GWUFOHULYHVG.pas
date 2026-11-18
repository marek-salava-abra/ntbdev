{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
{
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction:= Self.GetNewAction;
  mAction.Name:= 'actSearchAction';
  mAction.Caption:= 'Zkus dohledat OV';
  mAction.Category:= 'tabList';
  mAction.OnExecute:= @SearchOVFromComponent;
end;

procedure SearchOVFromComponent(Sender: TComponent);
var
  mOS: TNxCustomObjectSpace;
  mBMBO: TNxCustomBusinessObject;
  mDRowBatches: TNxCustomBusinessMonikerCollection;
  mProductCard_ID, mIssuedOrderRow_ID, mComponentCard_ID, mBatchMovement_ID, mBatchName: string;
  mBatchQuantity: Extended;
  i: integer;
begin
  mOS:= Sender.Site.BaseObjectSpace;
  mComponentCard_ID:= InputBox('', '', '', Sender.Site);
  if not(NxIsEmptyOID(mComponentCard_ID)) then begin
    mProductCard_ID:= mOS.SQLSelectFirstAsString(
      ' SELECT PL.StoreCard_ID FROM PLMPieceLists PL '+
      ' JOIN PLMPieceLists2 PL2 ON PL.ID = PL2.Parent_ID '+
      ' WHERE PL2.StoreCard_ID = '+QuotedStr(mComponentCard_ID));
    if not(NxIsEmptyOID(mProductCard_ID)) then begin

      mDRowBatches:= Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('DocRowBatches'));
      for i:= 0 to mDRowBatches.Count -1 do begin
        mBatchName:= mDRowBatches.BusinessObject[i].GetFieldValueAsString('StoreBatch_ID.Name');
        mBatchQuantity:= mDRowBatches.BusinessObject[i].GetFieldValueAsFloat('Quantity');

        mBatchMovement_ID:= mOS.SQLSelectFirstAsString(
          ' SELECT DRD.ID FROM IssuedOrders IO '+
          ' JOIN IssuedOrders2 IO2 ON IO2.Parent_ID = IO.ID '+
          ' JOIN DefRollData DRD ON DRD.X_Parent_ID = IO2.ID '+
          ' WHERE IO.Firm_ID = '+QuotedStr('IHFJ800101')+            //Firma fixně
          ' AND IO.Closed = ''N'' '+
          ' AND ((IO2.Quantity - IO2.DeliveredQuantity) >= '+NxFloatToIBStr(mBatchQuantity)+')'+    //má být množství na příjemce
          ' AND (IO.DocDate$DATE >= 45505) '+                       //datum dočasně
          ' AND IO2.StoreCard_ID = '+QuotedStr(mProductCard_ID));

        if not(NxIsEmptyOID(mBatchMovement_ID)) then begin
          mBMBO:= mOS.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S'); //POHYBY ŠARŽÍ NA OV
          try
            mBMBO.Load(mBatchMovement_ID, nil);
            OutputDebugString('Tu '+mBatchMovement_ID+' bych doplnil šarži ze SK do X_Ponožky: '+mBatchName);
          finally
            mBMBO.Free;
          end;

        end;
      end;
    end;

  end;
end;
}

begin
end.