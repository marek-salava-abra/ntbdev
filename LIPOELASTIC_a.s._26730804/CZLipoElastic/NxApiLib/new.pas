uses '_Knihovny_ALL.Parse',
'_Knihovny_ALL.Komunikace','_GlobalSettings.Konstanty';

function POST_APIDefroll(AContext: TNxContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
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
                                       mFields:=fnParsevalue(mField,',');
                                             msbody:=msbody + '"Data" : [   ' ;
                                               for i:=0 to mr.count-1 do begin


                                                 msbody:=msbody + ' { ' ;
                                                    //  msbody:=msbody + '"' + 'Value' + '" : "' + mr.strings[0] + '",' ;
                                                           mValues:=TStringList.create;
                                                              try

                                                                 // mValues:=Parsevalue1(mr.strings[i],mSeparator);
                                                                 mValues:=fnParsevalue(mr.strings[i],mSeparator);
                                                                 if mValues.count>0 then begin
                                                                         for ifield:=0 to mFields.count-1 do begin



                                                                              msbody:=msbody + '"' + mFields.strings[ifield] + '" : "' + mValues.strings[ifield] + '"' ;

                                                                                if ifield<mFields.count-1  then msbody:=msbody + ',';
                                                                          end;
                                                                  end;
                                                               finally
                                                                 //   mValues.free;
                                                               end;

                                                 msbody:=msbody + ' } ' ;
                                                 if i<mr.count-1 then msbody:=msbody + ',';


                                               end;

                                             msbody:=msbody + '  ] ' ;
                                       finally
                                        //  mFields.free;
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



function POST_APIPricelist(AContext: TNxContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
	mParams: TNxParameters;
	mApplication: Variant;
	mCond: TNxDynSQLConditionKind;
	mDynSQL, mDataset: Variant;
	mResult: Double;
	mInfoType: String;
  mFirm,mWhere,mDate:string;
  mSMSQL:string;
  mr,mFields,mValues:TStringList;
  msBody:string;
  i, iField,iValue,ax:integer;
  a:string;
  mSeparator:string;
  mString:string;
  mfirm_id:string;
  mBO_firm:TNxCustomBusinessObject;
  mCena:double;
  mStorecard_ID,MQunit, mPricelist_ID,mPrice_ID:string;
begin
  mWhere:='';
  mFirm:='';
  mDate:='';
  mFirm := AInput.S['Firm'];
  mDate := AInput.s['DAte'];
  try
    mWhere:= AInput.S['WHERE'];
  except
    mWhere:=' X_StoreAssortmentGroup_ID=' + quotedstr('4N00000101');
  end;
result:=TJSONSuperObject.create;


  if not NxIsBlank(mFirm) then begin

       mfirm_id:='';
       mPricelist_ID:='';
       mPrice_ID:='';
       mfirm_id:=AContext.SQLSelectFirstAsString('Select id from firms where name =' + quotedstr(mFirm));
       if mfirm_id<>'' then begin
           mBO_firm:=acontext.GetObjectSpace.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
           try
               mBO_firm.load(mfirm_id,nil);


                            mr:=TStringList.create;
                                  try
                                       try
                                             if (trim(mWhere))='' then begin
                                                     AContext.sqlselect('select id,EAN,MainUnitCode from storecards' ,mr);
                                             end else begin
                                                     AContext.sqlselect('select id,EAN,MainUnitCode from storecards where ' + mWhere  ,mr);
                                             end;
                                        except
                                             AContext.sqlselect('select id,EAN,MainUnitCode from storecards' ,mr);
                                        end;

                                      msbody:='[' ;
                                        msbody:=msbody + '{';
                                                         msbody:=msbody + '"_Pocet" : "' + inttostr(mr.count) + '",' ;
                                                         msbody:=msbody + '"_Firma" : "' + mBO_firm.GetFieldValueAsString('Code') + '",' ;
                                                         msbody:=msbody + '"_Cenik" : "' + mBO_firm.GetFieldValueAsString('PriceList_ID.Name') + '",' ;
                                                         msbody:=msbody + '"_Definice_ceny" : "' + mBO_firm.GetFieldValueAsString('Price_ID.Name') + '",' ;
                                                         msbody:=msbody + '"_Měna" : "' + mBO_firm.GetFieldValueAsString('Price_ID.Currency_ID.Code') + '",' ;
                                                         msbody:=msbody + '"_Datum" : "' + mDate + '",' ;
                                                         mPricelist_ID:= mBO_firm.GetFieldValueAsString('PriceList_ID');
                                                         mPrice_ID:= mBO_firm.GetFieldValueAsString('Price_ID');

                                                         mFields:=TStringList.create;
                                                         mFields.Add('ID');
                                                         mFields.Add('EAN');
                                                         mFields.Add('Jednotka');


                                                               try
                                                               msbody:=msbody + '"Data" : [   ' ;


                                                                       for i:=0 to mr.count-1 do begin
                                                                         mStorecard_ID:='';
                                                                         MQunit:='';
                                                   mValues:=TStringList.create;
                                                                         msbody:=msbody + ' { ' ;

                                                                                      try
                                                                                         mValues:=fnParsevalue(mr.strings[i],';');
                                                                                         if mValues.count>0 then begin
                                                                                                 for ifield:=0 to mValues.count-1 do begin
                                                                                                      msbody:=msbody + '"' + mFields.strings[ifield] + '" : "' + mValues.strings[ifield] + '"' ;
                                                                                                         if mFields.strings[ifield]='ID' then mStorecard_ID:= mValues.strings[ifield];
                                                                                                         if mFields.strings[ifield]='Jednotka' then MQunit:= mValues.strings[ifield];


                                                                                                        if ifield<mValues.count-1  then BEGIN
                                                                                                             msbody:=msbody + ',';
                                                                                                        end else begin

                                                                                                           mcena:=0;
                                                                                                           mcena:=NxEvalObjectExprAsFloatDef(mBO_firm,'NxGetStoreCardUnitPriceDef('+Quotedstr(mBO_firm.oid)+', '+Quotedstr('')+', ' + QuotedStr(mStoreCard_ID) + ','+Quotedstr(mPrice_ID)+', '+Quotedstr(MQunit)+',True,'+QuotedStr(mBO_firm.GetFieldValueAsString('Price_ID.Currency_ID'))+','+inttostr(trunc(Date))+')',0);



                                                                                                            msbody:=msbody + ', "' + 'Cena '+ '" : "' + NxFloatToIBStr(mcena) + '"' ;

                                                                                                        end;
                                                                                                  end;
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














           finally
              mBO_firm.free;
           end;
       end;









	end else begin
		RaiseException('Missing param info_type.');
	end;


end;








begin
end.