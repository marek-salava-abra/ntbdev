uses '.DataMatrix', '.lib';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction:= Self.GetNewAction;
  mAction.Name:= 'actTEST';
  mAction.Caption:= 'myTEST';
  mAction.Category:= 'tabList';
  mAction.OnExecute:= @TESTDataMatrixParse;
end;

procedure MyTestProcedure(Sender: TComponent);
begin
  NxShowSimpleMessage(NxTrim(#13#10+' testString '+nxCrLf, ' '+nxCrLf), Sender.Site);
end;


procedure TESTDataMatrixParse(Sender: TComponent);
var
  mTempStr: string;
  mEOID, mStoreCard_ID, mBatch_ID, mDMStr: string;
  mQuantity: Extended;
begin
  mDMStr:= InputBox('','','', Sender.Site);
  mTempStr:= DatamatrixDecodeBatches(Sender.Site.BaseObjectSpace, mDMStr);
  mEOID:= NxTrapStr(mTempStr, ';');
  mStoreCard_ID:= NxTrapStr(mTempStr, ';');
  mBatch_ID:= NxTrapStr(mTempStr, ';');
  mQuantity:= 1;
  mTempStr:= '';
  NxShowSimpleMessage(mBatch_ID+NxCrlf+mDMStr+NxCrlF+DatamatrixDecodeBatches(Sender.Site.BaseObjectSpace, mDMStr), sender.site);
end;



procedure testReturnsDataSet(Sender:Tcomponent);
var
  mSite: TSiteForm;
  mContext: TNxContext;
  mJSON: TJSONSuperObject;
  mTempStr: string;
begin
  mSite:= Sender.Site;
  mContext:= mSite.SiteContext;
  mTempStr:= InputBox('','','', mSite);
  mJSON:= TJSONSuperObject.ParseString('{  "externalOrderNumber": "2026011991", "ticketId": "05f5118a-991b-4b31-b7ff-3716beb005dc", "ticketNumber":"20261407", "email": "majerova.kristyna@emal.cz",  "bankAccount": "",  "changeGoods": 0,  "lines": [{"price":1499,"reason":"4","batches":["01085918460021191000000211260602511260616"],"productCode":"LIPO-FLOW-B-S","productQuantity":1}] ,  "message": ""}', false);
  POST_CreateCN(mContext, mJSON, '');
end;

begin
end.