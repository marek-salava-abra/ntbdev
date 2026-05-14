procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction:= Self.GetNewAction;
  mAction.Name:= 'actSyncBatch';
  mAction.Caption:= '## SK šarže -> CZ šarže ##';
  mAction.Category:= 'tabList';
  mAction.OnExecute:= @SyncBatch;
end;

Procedure SyncBatch(sender:tcomponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mComponentCard_ID,mProductCard_ID,mBatchMovement_ID, mOrigin_ID:string;
 mBO,mBatchMovementBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 mBO:=TDynSiteForm(mSite).CurrentObject;
      mOrigin_ID:=mOS.SQLSelectFirstAsString('Select x_origin_id from issuedorders2 where id='+QuotedStr(mBO.GetFieldValueAsString('Parent_ID.ProvideRow_ID')),'');
      if NxIsEmptyOID(mOrigin_ID) and (mbo.GetFieldValueAsString('Parent_ID.FlowType')='20') then begin
      mComponentCard_ID:=mBO.GetFieldValueAsString('parent_id.StoreCard_ID');
      if not (NxIsEmptyOID(mComponentCard_ID)) then
        mProductCard_ID:= mOS.SQLSelectFirstAsString(
          ' SELECT PL.StoreCard_ID FROM PLMPieceLists PL '+
          ' JOIN PLMPieceLists2 PL2 ON PL.ID = PL2.Parent_ID '+
          ' WHERE PL2.StoreCard_ID = '+QuotedStr(mComponentCard_ID));
        mBatchMovement_ID:= mOS.SQLSelectFirstAsString(
              ' SELECT DRD.ID FROM IssuedOrders IO '+
              ' JOIN IssuedOrders2 IO2 ON IO2.Parent_ID = IO.ID '+
              ' JOIN DefRollData DRD ON DRD.X_Parent_ID = IO2.ID '+
              ' left join userxlinks u on u.source_id=io.id '+
              ' WHERE drd.x_SK_Batch='''' and IO.Closed = ''N'' '+
              ' AND (DRD.CLSID=''EC2R2HSFK5UOZ5MYVJWJOHUC4S'') '+
              ' AND ((IO2.Quantity - IO2.DeliveredQuantity) >= '+NxFloatToIBStr(mbo.GetFieldValueAsFloat('Quantity'))+')'+    //má být množství na příjemce
              ' AND (IO.DocDate$DATE >= 45566) '+                       //datum dočasně
              ' AND IO2.StoreCard_ID = '+QuotedStr(mProductCard_ID)+' and u.id is null');
              if not(NxIsEmptyOID(mBatchMovement_ID)) then begin
              mBatchMovementBO:= mOS.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S'); //POHYBY ŠARŽÍ NA OV
              try
                mBatchMovementBO.Load(mBatchMovement_ID, nil);
                mBatchMovementBO.SetFieldValueAsString('X_SK_Batch', mbo.GetFieldValueAsString('StoreBatch_ID.Name'));
                mBatchMovementBO.SetFieldValueAsDateTime('X_DateTimeOfLastChange',Now);
                OutputDebugString('Tu '+mBatchMovement_ID+' bych doplnil šarži ze SK do X_Ponožky: '+mbo.GetFieldValueAsString('StoreBatch_ID.Name'));
                mBatchMovementBO.Save;
              finally
                mBatchMovementBO.Free;
              end;
              NxShowSimpleMessage('Šarže zapsána',mSite);
            end
             else begin
              NxShowSimpleMessage('Nepovedlo se dohledat pohyb šarže na nevyřízené objednávce od 15.10.2024 bez vazby na další OV',mSite);
             end;
     end else begin
      NxShowSimpleMessage('Doklad není příjemka s prázdným X_origin_ID.', mSite);

     end;
end;

begin
end.