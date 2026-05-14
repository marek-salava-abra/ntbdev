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
  NxShowSimpleMessage(mBatch_ID, sender.site);
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
  mJSON:= TJSONSuperObject.ParseString('{"externalOrderNumber":"2024008728","ticketId":"0d554458-3178-4ceb-b206-6039df9c4dce","ticketNumber":"20240055","email":"kaplanovaadelka@seznam.cz","bankAccount":"81020002/5500","changeGoods":0,"lines":[{"price":349,"reason":"3","batches":["01085918469381281000093812242700217290718","01085918469381281000093812242700217290718"],"productCode":"LIPO-PU03F00C-N-M","productQuantity":2},{"price":349,"reason":"3","batches":["01085918469381351000093813242400317290418","01085918469381351000093813242300217290308","01085918469381351000093813242300217290308"],"productCode":"LIPO-PU03F00C-B-S","productQuantity":3},{"price":349,"reason":"3","batches":["01085918469381421000093814242300117290319","01085918469381421000093814242300117290319"],"productCode":"LIPO-PU03F00C-N-S","productQuantity":2}],"message":""}', false);
  POST_CreateCN(mContext, mJSON, '');
end;

begin
end.