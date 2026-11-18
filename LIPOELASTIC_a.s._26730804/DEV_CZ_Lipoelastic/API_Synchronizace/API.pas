//"expr": "NxScript('\''eu.abra.API.Function.Firms.FxFirm_MajorCorrection'\'','\''3UR4000101'\'')"
Const
mManual=true;
mdebug=true;
msource='http://10.5.5.11:82/Lipoelastic/';
mShowError=false;

var
mTargetList:TStringList;






function CallNewValueWithIDNoERR(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mJSON:string):string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
begin
  AOS := mSO.ObjectSpace;
  try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl );
             // NxShowSimpleMessage(mUrl + ' - ' + mJSON, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic VGVzdDoxMjM=');  //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //'); //mWinHTTP.SetRequestHeader('Accept', 'application/json; charset=UTF-8');
              mWinHTTP.Send(mJson);
          if (mWinHTTP.Status <> 204) and (mWinHTTP.Status <> 200) and (mWinHTTP.Status <> 201) then begin     //              NxShowMessage('Response - SC', mWinHTTP.ResponseText, mdInformation, false, nil);
            //if NxGetActualUserID(AOS) <> 'AUTO000000' then begin
              //NxShowMessage('API status ', FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText, mdInformation, false, nil);
            //end;
          end else begin
            // result:= TEncoding.Convert(mWinHTTP.ResponseText, Encoding_cp1250, Encoding_cpUTF_8);
                 ;
               Result := FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText;

          end;
        end;
      finally
      end;

end;


function CallNewValueWithID(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mJSON:string):string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
begin
  AOS := mSO.ObjectSpace;
  try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl );
             // NxShowSimpleMessage(mUrl + ' - ' + mJSON, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic VGVzdDoxMjM=');  //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //'); //mWinHTTP.SetRequestHeader('Accept', 'application/json; charset=UTF-8');
              mWinHTTP.Send(mJson);
          if (mWinHTTP.Status <> 204) and (mWinHTTP.Status <> 200) and (mWinHTTP.Status <> 201) then begin     //              NxShowMessage('Response - SC', mWinHTTP.ResponseText, mdInformation, false, nil);
            //if NxGetActualUserID(AOS) <> 'AUTO000000' then begin
              //if mShowError then NxShowMessage('API status ', FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText, mdInformation, false, nil);
            //end;
          end else begin
            // result:= TEncoding.Convert(mWinHTTP.ResponseText, Encoding_cp1250, Encoding_cpUTF_8);
                 ;
               Result := FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText +  mWinHTTP.ResponseText;

          end;
        end;
      finally
      end;

end;


function CorrectString(mString:string):string;
begin
      mString:=NxSearchReplace(mString,chr(39),'',[srCase,srAll]);      // apostrof
      mString:=NxSearchReplace(mString,chr(34),'',[srCase,srAll]);      // uvozovky
      mString:=NxSearchReplace(mString,chr(132),'',[srCase,srAll]);     // dvojité uvozovky
result:=mString;
end;


function POST_NewValueWithID(AContext: TNxContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
	mParams: TNxParameters;
	mApplication: Variant;
	mCond: TNxDynSQLConditionKind;
	mDynSQL, mDataset: Variant;
	mResult: Double;
	mInfoType: String;
  mSQL:string;
begin
	Result := TJSONSuperObject.Create;
	mInfoType := AInput.S['info_type'];
  mSQL:= AInput.S['mSQL'];
	if not NxIsBlank(mInfoType) then begin

    Result.I['Value'] := acontext.SQLExecute(msql);
    Result.S['mInfoType'] := FloatToStr(mResult);
    Result.S['MSQL'] := mSQL;
	end else begin
		RaiseException('Missing param info_type.');
	end;
end;


 // post dotaz API pmocí JSON



 // post dotaz API pmocí JSON
function CallRestApiNoerr(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mHead: string;mID: string;mRequest:string):string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
begin
  AOS := mSO.ObjectSpace;
  try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl +mHead +mid);      //   NxShowSimpleMessage(mTyp + ' - ' +mUrl +mHead +mid + mRequest, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic VGVzdDoxMjM=');
              //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //');
              mWinHTTP.SetRequestHeader('Accept', '*/*');
              mWinHTTP.SetRequestHeader('Accept-Encoding', 'gzip, deflate, br');
              mWinHTTP.SetRequestHeader('Connection', 'keep-alive');

              mWinHTTP.Send(mRequest);
          if  (mWinHTTP.Status <> 204) and (mWinHTTP.Status <> 200) and (mWinHTTP.Status <> 201) then begin     //              NxShowMessage('Response - SC', mWinHTTP.ResponseText, mdInformation, false, nil);
            //if NxGetActualUserID(AOS) <> 'AUTO000000' then begin
                  if mShowError then   NxShowMessage('API Status ', FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText, mdInformation, false, nil);
                  result:= FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText;
            //end;
          end else begin
             result:= mWinHTTP.ResponseText;
          end;
        end;
      finally
      end;
end;




function CallRestApi1(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mHead: string;mID: string;mRequest:string):string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
begin
  AOS := mSO.ObjectSpace;
  try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl +mHead +mid);      //   NxShowSimpleMessage(mTyp + ' - ' +mUrl +mHead +mid + mRequest, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic VGVzdDoxMjM=');
              //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //');
              mWinHTTP.SetRequestHeader('Accept', '*/*');
              mWinHTTP.SetRequestHeader('Accept-Encoding', 'gzip, deflate, br');
              mWinHTTP.SetRequestHeader('Connection', 'keep-alive');

              mWinHTTP.Send(mRequest);
          if  (mWinHTTP.Status <> 204) and (mWinHTTP.Status <> 200) and (mWinHTTP.Status <> 201) then begin     //              NxShowMessage('Response - SC', mWinHTTP.ResponseText, mdInformation, false, nil);
            //if NxGetActualUserID(AOS) <> 'AUTO000000' then begin
             // if mShowError then NxShowMessage('API Status ', FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText, mdInformation, false, nil);
              result:= FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText + mWinHTTP.ResponseText;
            //end;
          end else begin
             result:= FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText + mWinHTTP.ResponseText;
          end;
        end;
      finally
      end;
end;


// post dotaz API pmocí JSON
function CallRestApi(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mHead: string;mID: string;mRequest:string):string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
begin
  AOS := mSO.ObjectSpace;
  try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl +mHead +mid);      //   NxShowSimpleMessage(mTyp + ' - ' +mUrl +mHead +mid + mRequest, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic VGVzdDoxMjM=');
              //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //');
              mWinHTTP.SetRequestHeader('Accept', '*/*');
              mWinHTTP.SetRequestHeader('Accept-Encoding', 'gzip, deflate, br');
              mWinHTTP.SetRequestHeader('Connection', 'keep-alive');

              mWinHTTP.Send(mRequest);
          if  (mWinHTTP.Status <> 204) and (mWinHTTP.Status <> 200) and (mWinHTTP.Status <> 201) then begin     //              NxShowMessage('Response - SC', mWinHTTP.ResponseText, mdInformation, false, nil);
            //if NxGetActualUserID(AOS) <> 'AUTO000000' then begin
              //if mShowError then NxShowMessage('API Status ', FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText, mdInformation, false, nil);
              result:= FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText + mWinHTTP.ResponseText;
            //end;
          end else begin
             result:= mWinHTTP.ResponseText;
          end;
        end;
      finally
      end;
end;

// otevření API
function GetHTTP(var WinHttpRequest: Variant): Boolean;
begin
  try
    if not VarIsType(WinHttpRequest, varDispatch) then begin
      WinHttpRequest := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    end;
    Result:=True;
  except
    Result := False;
    OutputDebugString(ExceptionMessage);
    WinHttpRequest := nil;
  end;
end;








function POST_APISQL(AContext: TNxContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
	mParams: TNxParameters;
	mApplication: Variant;
	mCond: TNxDynSQLConditionKind;
	mDynSQL, mDataset: Variant;
	mResult: Double;
	mInfoType: String;
  mType,mField,mTable,mWhere,mGroupBy,mOrderBy:string;
  mSMSQL:string;
  mr,mFields,mValues:TStringList;
  msBody:string;
  xxx:string;
  i, iField,iValue,ax:integer;
  a:string;
  mSeparator:string;
  mString:string;
begin
	mType := AInput.S['Type'];
  mField := AInput.S['Field'];
  mTable := AInput.S['Table'];
  mWhere := AInput.S['Where'];
  mGroupBy := AInput.S['Group by'];
  mOrderBy := AInput.S['Order by'];

  result:=TJSONSuperObject.create;
  mSMSQL:='';
  mSBody:='';

  mSeparator:='|';
  xxx:=ReplaceText(mField,',','+' + quotedstr(mSeparator) + '+');

  if not NxIsBlank(mType) then begin
      if mType='SELECT' then begin

          mSMSQL:=mType + ' ' + xxx + ' FROM '  + mTable ;
                if trim(mWhere)<>'' then mSMSQL:=mSMSQL + ' WHERE ' + mWhere;
                if trim(mGroupBy)<>'' then mSMSQL:=mSMSQL + ' GroupBy ' + mGroupBy;
                if trim(mOrderBy)<>'' then mSMSQL:=mSMSQL + ' Order BY ' + mOrderBy;

          mr:=TStringList.create;
          try

                AContext.sqlselect(mSMSQL,mr);

              msbody:='[' ;
                msbody:=msbody + '{';
                MSMSQL:=mType + ' ' + mField + ' FROM '  + mTable ;
                if trim(mWhere)<>'' then mSMSQL:=mSMSQL + ' WHERE ' + mWhere;
                if trim(mGroupBy)<>'' then mSMSQL:=mSMSQL + ' GroupBy ' + mGroupBy;
                if trim(mOrderBy)<>'' then mSMSQL:=mSMSQL + ' Order BY ' + mOrderBy;

                                 msbody:=msbody + '"Pocet" : "' + inttostr(mr.count) + '",' ;
                                 msbody:=msbody + '"Dotaz SQL" : "' + mSMSQL + '", ' ;
                                       mFields:=TStringList.create;
                                       try
                                       mFields:=Parsevalue1(mField,',');
                                             msbody:=msbody + '"Data" : [   ' ;
                                               for i:=0 to mr.count-1 do begin


                                                 msbody:=msbody + ' { ' ;
                                                      //msbody:=msbody + '"' + 'Value' + '" : "' + mr.strings[0] + '",' ;
                                                           mValues:=TStringList.create;
                                                              try
                                                                  mValues:=Parsevalue1(mr.strings[i],mSeparator);

                                                                 for ifield:=0 to mFields.count-1 do begin



                                                                      msbody:=msbody + '"' + mFields.strings[ifield] + '" : "' + mValues.strings[ifield] + '"' ;

                                                                        if ifield<mFields.count-1  then msbody:=msbody + ',';
                                                                  end;
                                                               finally
                                                                    mValues.free;
                                                               end;

                                                 msbody:=msbody + ' } ' ;
                                                 if i<mr.count-1 then msbody:=msbody + ',';


                                               end;

                                             msbody:=msbody + '  ] ' ;
                                       finally
                                          mFields.free;
                                       end;

                msbody:=msbody + '}';
               msbody:=msbody + ']' ;

      result := TJSONSuperObject.ParseString(msbody, True);

          finally
              mr.free;
          end;

      end;

	end else begin
		RaiseException('Missing param info_type.');
	end;


end;








function CreateTargetList():tstringlist;
var
    mStringlist:tstringlist;
begin
   mStringlist:=tstringlist.create;
   try
         mStringlist.Add('http://10.5.5.11:82/Lipoelastic/');
         mStringlist.Add('http://10.5.5.11:82/LipoStocking/');
         mStringlist.Add('http://10.5.5.11:83/SK_lipoelastic/');
         result:=mStringlist;
   finally
       mStringlist.free;
   end;
end;








function GetDocQueryBatch(Self:TNxCustomBusinessObject;mDocType_ID,mDocqueue_ID,mFirm_ID,mFirmOffice_ID,mStore_ID,mDivision_ID:string):string;
var
i,ii:integer;
mQuery,mQueryID:string;
mMonRows,mMonBatch:TNxCustomBusinessMonikerCollection;
mid:string;
mPrice:double;
mxg,mxa:tstringlist;
begin

mMonRows := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
                        mQuery:='{'  ;
                        mQuery:=mQuery +'"ID": "' +                                    Self.OID +'", '                                                            ;
//                          mQuery:=mQuery +'"DocumentType": "' +                         '20' +'", '                  ;
                          mQuery:=mQuery +'"Docqueue_ID": "' +                         mDocqueue_ID +'", '                  ;
                          mQuery:=mQuery +'"tradetype": ' +                            IntToStr(Self.GetFieldValueAsInteger('tradetype')) +', '                  ;
                          mQuery:=mQuery +'"Currency_ID":"' +                         Self.GetFieldValueAsString('Currency_ID') +'", '                  ;
                          mQuery:=mQuery +'"Firm_ID":"'  +                             mFirm_ID +'", '                              ;
                          mQuery:=mQuery +'"Externalnumber":" ' +                      Self.GetFieldValueAsString('DisplayName') +'", '                  ;
                          mQuery:=mQuery +'"Description": "' +                         Self.GetFieldValueAsString('Description') +'", '                  ;
//                          mQuery:=mQuery +'"Country_ID ": "' +                          Self.GetFieldValueAsString('Country_ID') +'", '                  ;
                          //NxShowSimpleMessage(copy(mTargetList.strings[i],21,1),nil);

                          mQuery:=mQuery +'"Rows": [  ';
                        for i := 0 to mMonRows.Count-1 do begin
                                        mQuery:=mQuery +'{ ' ;
//                                        mQuery:=mQuery +'"id":"' +                            		  mMonRows.BusinessObject[i].GetFieldValueAsString('ID')+'", '   ;
                                        mQuery:=mQuery +'"PosIndex": ' +                            IntToStr(mMonRows.BusinessObject[i].GetFieldValueAsInteger('Posindex')) +', '                  ;
                                        mQuery:=mQuery +'"Rowtype": ' +                             IntToStr(mMonRows.BusinessObject[i].GetFieldValueAsInteger('Rowtype')) +', '                  ;
                                        mQuery:=mQuery +'"Text":"' +                            		mMonRows.BusinessObject[i].GetFieldValueAsString('Text')+'", ' ;
                                        mQuery:=mQuery +'"Store_ID":"' +                            mStore_ID+'", '   ;
                                        mQuery:=mQuery +'"Storecard_ID":"' +                        mMonRows.BusinessObject[i].GetFieldValueAsString('Storecard_ID')+'", '   ;

                                        mQuery:=mQuery +'"Quantity": ' +                            NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('Quantity')) +', '                  ;

                                        mQuery:=mQuery +'"Qunit":"' +                               mMonRows.BusinessObject[i].GetFieldValueAsString('Qunit')+'", '   ;



                                  //      mprice:=NxGetStoreCardUnitPriceDef(Self.GetFieldValueAsString('MAIN.Firm_ID'), mMonRows.BusinessObject[i].GetFieldValueAsString('ROWS.Store_ID'), mMonRows.BusinessObject[i].GetFieldValueAsString('ROWS.StoreCard_ID'), Self.GetFieldValueAsString('MAIN.Firm_ID.Price_ID'), mMonRows.BusinessObject[i].GetFieldValueAsString('ROWS.QUnit'), False,Self.GetFieldValueAsString('MAIN.Firm_ID.Price_ID.Currency_ID') ,Self.GetFieldValueAsDateTime('MAIN.DocDate$DATE')
                                  //       )    ;

                                   mprice:=0;
                                        mxa:=tstringlist.create;
                                           // z faktury
                                                 try
                                                     if self.GetFieldValueAsString('DocumentType')='21' then self.ObjectSpace.SQLSelect('select ii2.TAmount/ii2.quantity from issuedinvoices2 ii2 join issuedinvoices ii on ii.id=ii2.parent_ID where Providerow_ID =' + QuotedStr(mMonRows.BusinessObject[i].GetFieldValueAsString('X_Providerow_ID')),mxa);

                                                     if mxa.count>0 then begin
                                                          mprice:=NxIBStrToFloat(mxa.Strings[0]);
                                                     end else begin
                                                     end;
                                                 finally
                                                     mxa.free;
                                                 end;
                                           if mprice=0 then begin
                                                 // z cenníku
                                                      mprice:=NxEvalObjectExprAsFloatDef(self,'NxGetStoreCardUnitPriceDef('+Quotedstr(self.GetFieldValueAsString('Firm_ID'))+', '
                                                                      +Quotedstr(mMonRows.BusinessObject[i].GetFieldValueAsString('Store_ID'))+', '
                                                                      +QuotedStr(mMonRows.BusinessObject[i].GetFieldValueAsString('Storecard_ID')) + ','
                                                                      +Quotedstr(self.GetFieldValueAsString('Firm_ID.Price_ID'))+', '
                                                                      +Quotedstr(mMonRows.BusinessObject[i].GetFieldValueAsString('Qunit'))+',False,'
                                                                      +QuotedStr(self.GetFieldValueAsString('Firm_ID.Price_ID.Currency_ID'))+','
                                                                      +inttostr(trunc(Date))+')',0);
                                           end;



                                   //     mprice:=0;
                                   //                     mxg:=tstringlist.create;
                                    //                            try
                                   //                                 self.ObjectSpace.SQLSelect(format('SELECT a.amount FROM StorePrices2 A JOIN PriceDefinitions PD ON PD.ID=A.Price_ID JOIN StorePrices SP ON SP.ID=A.Parent_ID JOIN StoreCards SC ON SC.ID=SP.StoreCard_ID JOIN PriceLists PL ON PL.ID=SP.PriceList_ID where (pl.id=%s) and (pd.id=%s) and (SP.StoreCard_ID.id=%s)',[quotedstr('6GT0000101'),quotedstr(Self.GetFieldValueAsString('MAIN.Firm_ID.Price_ID')), quotedstr(mMonRows.BusinessObject[i].GetFieldValueAsString('ROWS.StoreCard_ID'))]
                                   //                                 ),mxg);
                                    //                                if mxg.count>0 then begin
                                    //                                    //NxShowSimpleMessage(mxg.Strings[0],Null);
                                    //                                    mprice:=NxIBStrToFloat(mxg.Strings[0]);
                                    //                                end;
                                    //                            finally
                                    //                                mxg.free;
                                    // /                           end;
                                    //
                                    //                            if mprice<>0 then
                                    //
                                    //
                                    //
                                    //

                                        mQuery:=mQuery +'"UnitPrice": ' +                           NxFloatToIBStr(mprice) +', '                  ;




//                                        mQuery:=mQuery +'"TotalPrice": ' +                          NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TotalPrice')) +', '                  ;

//                                        mQuery:=mQuery +'"TAmount": ' +                             NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TAmount')) +', '                  ;
//                                        mQuery:=mQuery +'"TAmountWithoutVAT": ' +                   NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT')) +', '    ;
                                        mQuery:=mQuery +'"Division_ID":"' +                         mDivision_ID+'", '   ;
                                        mQuery:=mQuery +'"BusOrder_ID":"' +                         mMonRows.BusinessObject[i].GetFieldValueAsString('BusOrder_ID')+'", '   ;
                                        mQuery:=mQuery +'"BusTransaction_ID":"' +                   mMonRows.BusinessObject[i].GetFieldValueAsString('BusTransaction_ID')+'", '   ;
                                        //mQuery:=mQuery +'"BusProject_ID":"' +                       mMonRows.BusinessObject[i].GetFieldValueAsString('BusProject_ID')+'", '   ;


                                        mQuery:=mQuery +  ' "docrowbatches": [ ' ;
                                        mMonBatch := mMonRows.BusinessObject[i].GetLoadedCollectionMonikerForFieldCode(mMonRows.BusinessObject[i].GetFieldCode('DocRowBatches'));
                                                  for ii := 0 to mMonBatch.Count-1 do begin
                                                       mQuery:=mQuery +'{ ' ;
                                                           mQuery:=mQuery +'"PosIndex": ' +                               IntToStr(mMonBatch.BusinessObject[ii].GetFieldValueAsInteger('Posindex')) +', '                  ;


                                                           mQueryID:='{'
                                                              + ' "class": "' + 'StoreBatches' +'",'
                                                                  +' "select": ["ID",],'
                                                                  + ' "where": " Name = ' + QuotedStr(mMonBatch.BusinessObject[ii].GetFieldValueAsString('storebatch_id.name'))
                                                                  +' " '
                                                                  +'}';
              //                NxShowSimpleMessage(mQueryID,nil);
                                                          mid:='';
                                                            mID:= copy(CallRestApi(Self,'Post','http://10.5.5.11:83/SK_lipoelastic/','query','',mQueryID),9,10);







                                                          IF mid='' THEN BEGIN
                                                                     mQuery:=mQuery +'"newbatch": ' +                      BoolToStr(True) +', '                  ;
                                                                     mQuery:=mQuery +'"newbatchname":"' +                 mMonBatch.BusinessObject[ii].GetFieldValueAsString('storebatch_id.name')+'", '   ;
                                                                     mQuery:=mQuery +'"newbatchspecification":"' +        mMonBatch.BusinessObject[ii].GetFieldValueAsString('storebatch_id.specification')+'", '   ;
                                                                     mQuery:=mQuery +'"newbatchcomment":"' +              mMonBatch.BusinessObject[ii].GetFieldValueAsString('storebatch_id.comment')+'", '   ;
                                                  //                   mQuery:=mQuery +'"newbatchexpirationdate$date":"' +  mMonBatch.BusinessObject[ii].GetFieldValueAsString('storebatch_id.expirationdate$date')+'", '   ;
                                                           end else begin
                                                                     mQuery:=mQuery +'"storebatch_id":"' +                mid+'", '   ;
                                                                     //mQuery:=mQuery +'"storesubbatch_id":"' +             mMonBatch.BusinessObject[ii].GetFieldValueAsString('storesubbatch_id')+'", '   ;
                                                           end;

                                                           mQuery:=mQuery +'"quantity": ' +                                NxFloatToIBStr(mMonBatch.BusinessObject[ii].GetFieldValueAsFloat('quantity')) +', '                  ;
                                                           mQuery:=mQuery +'"qunit":"' +                                  mMonBatch.BusinessObject[ii].GetFieldValueAsString('qunit')+'", '   ;
                                                           mQuery:=mQuery +' }, ';

                                                  end;
                                                  mQuery:=mQuery +' ], ';

















                                        mQuery:=mQuery +' }, ';

                        end;
                               mQuery:=mQuery +' ] ';

                              mQuery:=mQuery +' } ';


//                      end;


    result:=mQuery;
end;




function Parsevalue1( AData : string; ASeparator: string): tstringlist;
// rozdělení hodnot pro import
var
    mStr, mToken : string;
    mPos, i : integer;
    mList:tstringlist;
begin
    mList:=tstringlist.create;
    mStr := AData;
    try
        for i := 0 to NxCharCount(ASeparator,mStr)  do begin
            mPos := AnsiPos(ASeparator, mStr);
            if mPos = 0 then mPos := Length(mStr) + 1;
                mList.Add(NxLeft(mStr, mPos - 1));
                mStr := copy(mStr, mPos +Length(ASeparator), Length(mStr) - mPos);
         end;
           result:=mlist;
     finally
        mList.free;
     end;
end;


function GetDocQuery(Self:TNxCustomBusinessObject;mDocqueue_ID,mFirm_ID,mFirmOffice_ID,mStore_ID,mDivision_ID:string):string;
var
i:integer;
mQuery:string;
mMonRows:TNxCustomBusinessMonikerCollection;
mprice:double;
begin

mMonRows := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
//          if true then begin // copy(self.GetFieldValueAsString('X_synchronizace_ID'),i+1,1)='1' then begin
                        mQuery:='{'  ;
                        mQuery:=mQuery +'"ID": "' +                                    Self.OID +'", '                                                            ;
                          mQuery:=mQuery +'"Docqueue_ID": "' +                         mDocqueue_ID +'", '                  ;
                          mQuery:=mQuery +'"tradetype": ' +                            IntToStr(2) +', '                  ;
                          mQuery:=mQuery +'"Currency_ID":"' +                         Self.GetFieldValueAsString('Currency_ID') +'", '                  ;
                          mQuery:=mQuery +'"Firm_ID":"'  +                             mFirm_ID +'", '                              ;
                          mQuery:=mQuery +'"Externalnumber":" ' +                      Self.GetFieldValueAsString('Externalnumber') +'", '                  ;
                          //mQuery:=mQuery +'"DocumentDiscount":" ' + NxFloatToIBStr(Self.GetFieldValueAsFloat('DocumentDiscount')) + '", '                  ;

                          mQuery:=mQuery +'"Description": "' +                         Self.GetFieldValueAsString('Description') +'", '                  ;
                          mQuery:=mQuery +'"X_poznamka": "' +                         Self.GetFieldValueAsString('X_poznamka') +'", '                  ;
//                          mQuery:=mQuery +'"Country_ID ": "' +                          Self.GetFieldValueAsString('Country_ID') +'", '                  ;

                          mQuery:=mQuery +'"Country_ID": "00000SK000", '                  ;
                          mQuery:=mQuery +'"IntrastatDeliveryTerm_ID": "1000000101", '                  ;
                          mQuery:=mQuery +'"IntrastatTransactionType_ID": "1001000000", '                  ;
                          mQuery:=mQuery +'"IntrastatTransportationType_ID": "2000000000", '                  ;

                          //NxShowSimpleMessage(copy(mTargetList.strings[i],21,1),nil);

                          mQuery:=mQuery +'"Rows": [  ';
                        for i := 0 to mMonRows.Count-1 do begin
                                        mQuery:=mQuery +'{ ' ;
//                                        mQuery:=mQuery +'"id":"' +                            		  mMonRows.BusinessObject[i].GetFieldValueAsString('ID')+'", '   ;
                                        mQuery:=mQuery +'"PosIndex": ' +                            IntToStr(mMonRows.BusinessObject[i].GetFieldValueAsInteger('Posindex')) +', '                  ;
                                        mQuery:=mQuery +'"Rowtype": ' +                             IntToStr(mMonRows.BusinessObject[i].GetFieldValueAsInteger('Rowtype')) +', '                  ;
                                        mQuery:=mQuery +'"Text":"' +                            		mMonRows.BusinessObject[i].GetFieldValueAsString('Text')+'", ' ;
                                        mQuery:=mQuery +'"Store_ID":"' +                            mStore_ID+'", '   ;
                                        mQuery:=mQuery +'"Storecard_ID":"' +                        mMonRows.BusinessObject[i].GetFieldValueAsString('Storecard_ID')+'", '   ;

                                        mQuery:=mQuery +'"Quantity": ' +                            NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('Quantity')) +', '                  ;

                                        mQuery:=mQuery +'"Qunit":"' +                               mMonRows.BusinessObject[i].GetFieldValueAsString('Qunit')+'", '   ;

//                                        http://10.5.5.11:82/Lipoelastic/qrexpr
//                                      {
//                                            	"expr" : "NxGetStoreCardUnitPriceDef(mfirm_ID,mStore_ID,mMonRows.BusinessObject[i].GetFieldValueAsString('Storecard_ID'),'5100000101',mMonRows.BusinessObject[i].GetFieldValueAsString('Qunit'),False,'0000CZK000',Date)"
//                                        }
                                        // cena z dokladu
                                        mQuery:=mQuery +'"UnitPrice": ' +                           NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('UnitPrice') ) +', '                  ;
                                        mQuery:=mQuery +'"TotalPrice": ' +                          NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TotalPrice')) +', '                  ;

                                        //mQuery:=mQuery +'"TAmount": ' +                             NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT')) +', '                  ;
                                        //mQuery:=mQuery +'"TAmountWithoutVAT": ' +                   NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT')) +', '    ;
                                        mQuery:=mQuery +'"Division_ID":"' +                         mDivision_ID+'", '   ;
                                        mQuery:=mQuery +'"BusOrder_ID":"' +                         mMonRows.BusinessObject[i].GetFieldValueAsString('BusOrder_ID')+'", '   ;
                                        mQuery:=mQuery +'"BusTransaction_ID":"' +                   mMonRows.BusinessObject[i].GetFieldValueAsString('BusTransaction_ID')+'", '   ;
                                        mQuery:=mQuery +'"X_ProvideRow_ID":"' +                   mMonRows.BusinessObject[i].GetFieldValueAsString('X_ProvideRow_ID')+'", '   ;
                                        //mQuery:=mQuery +'"BusProject_ID":"' +                       mMonRows.BusinessObject[i].GetFieldValueAsString('BusProject_ID')+'", '   ;


                                        mQuery:=mQuery +' }, ';

                        end;
                               mQuery:=mQuery +' ] ';

                              mQuery:=mQuery +' } ';


//                      end;


    result:=mQuery;
end;





function GetQuery(Self:TNxCustomBusinessObject):string;
 begin
result:='{'
             +'"id": "' +  Self.OID +'", '
             +'"code":"'  +  Self.GetFieldValueAsString('Code') +'", '
             +'"name":"' +  Self.GetFieldValueAsString('Name') +'", '
             +'"X_synchronizace_ID":"' +  Self.GetFieldValueAsString('X_synchronizace_ID') +'", '
             +'"X_EN_NAZEV":"' +  Self.GetFieldValueAsString('X_EN_NAZEV') +'", '
             +'"X_DE_NAZEV":"' +  Self.GetFieldValueAsString('X_DE_NAZEV') +'", '
             +'"X_MX_NAZEV":"' +  Self.GetFieldValueAsString('X_MX_NAZEV') +'", '
             +'"X_ES_NAZEV":"' +  Self.GetFieldValueAsString('X_ES_NAZEV') +'", '
             +'"X_IT_Nazev":"' +  Self.GetFieldValueAsString('X_IT_Nazev') +'", '
             +'"X_FR_Nazev":"' +  Self.GetFieldValueAsString('X_FR_Nazev') +'", '
             +'"X_NL_Nazev":"' +  Self.GetFieldValueAsString('X_NL_Nazev') +'", '
             +'"X_US_Nazev":"' +  Self.GetFieldValueAsString('X_US_Nazev') +'", '
             +'"X_UK_NAZEV":"' +  Self.GetFieldValueAsString('X_UK_NAZEV') +'", '
             +'"X_amoena":"' +  Self.GetFieldValueAsString('X_amoena') +'", '
             +'"X_MEX_Nazev":"' +  Self.GetFieldValueAsString('X_MEX_Nazev') +'", '
             //+'"X_CZ_Nazev":"' +  Self.GetFieldValueAsString('X_CZ_Nazev') +'", '
//             +'"X_SK_Nazev":"' +  Self.GetFieldValueAsString('X_SK_Nazev') +'"'
             +'}';
end;



begin
end.