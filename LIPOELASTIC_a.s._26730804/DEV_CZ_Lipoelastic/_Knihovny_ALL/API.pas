uses '_Knihovny_ALL.Parse';
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


function POST_APISQL_String(AContext: TNxContext; Astring: string; APath: String): string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mstring:string;
  mr:tstringlist;
  i: integer;
  mQuery:string;
  mTyp,mFields,mDotaz,mSeparator:string;
  AInput:TJSONSuperObject;
begin
  try
      AInput:=TJSONSuperObject.create;
      AInput:= TJSONSuperObject.ParseString(astring,true);
       mTyp := AInput.S['Typ'];
       mFields := AInput.S['Fields'];
       mDotaz := AInput.S['Dotaz'];

          mQuery:= '[';
       // mQuery:=mQuery + '{';
      //  mQuery:=mQuery + '[';

   if true then begin
       mr:=tstringlist.create;
       try
          AContext.SQLSelect(mtyp + ' ' + mFields + ' ' + mDotaz,mr);
          if mr.Count>0 then begin
             result:= mr.Strings[0] ;
          end;
       finally
           mr.free;
       end;
    end;
  finally

  end;
end;

function POST_APISQL_Strings(AContext: TNxContext; Astring: string; APath: String): string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mstring:string;
  mr:tstringlist;
  i: integer;
  mQuery:string;
  mTyp,mFields,mDotaz,mSeparator:string;
  AInput:TJSONSuperObject;
begin
  try
      AInput:=TJSONSuperObject.create;
      AInput:= TJSONSuperObject.ParseString(astring,true);
       mTyp := AInput.S['Typ'];
       mFields := AInput.S['Fields'];
       mDotaz := AInput.S['Dotaz'];

   if true then begin
       mr:=tstringlist.create;
       try
          AContext.SQLSelect(mtyp + ' ' + mFields + ' ' + mDotaz,mr);
          if mr.Count>0 then begin
             for i:=0 to mr.count-1 do begin
                 result:= result + NxSearchReplace(mr.Strings[i],'"','',[srAll]) ;
                 if i<>mr.count-1 then result:= result +chr(13)+chr(10)
             end;
          end;
       finally
           mr.free;
       end;
    end;
  finally

  end;
end;


function POST_APISQL_Json(AContext: TNxContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mstring:string;
  mr:tstringlist;
  i,x: integer;
  mQuery:string;
  mTyp,mField,mDotaz,mSeparator:string;
  mFields, mValues: Tstringlist;
begin
        result:=TJSONSuperObject.create;
  try

       mTyp := AInput.S['Typ'];
       mField := AInput.S['Fields'];
       mDotaz := AInput.S['Dotaz'];

       mFields:=tstringlist.create;
       try
         mFields:=fnParsevalue(mField,',');

      //  NxShowSimpleMessage(inttostr(mFields.count),nil);


          mQuery:= '[';
       // mQuery:=mQuery + '{';
      //  mQuery:=mQuery + '[';

   if true then begin
       mr:=tstringlist.create;
       try
          AContext.SQLSelect(mtyp + ' ' + mField + ' ' + mDotaz,mr);
          if mr.Count>0 then begin
              for i:=0 to mr.count-1 do begin
                    mValues:=tstringlist.create;
                         try
                           mValues:=fnParsevalue(mr.Strings[i],';');


                            mQuery:=mQuery + '{';

                                         for x:=0 to mFields.Count-1 do begin
                                            mQuery:=mQuery + '"' + mFields.Strings[x] +'":"' + mValues.Strings[x] +'"' ;
                                            if x<>(mFields.count-1) then mQuery:=mQuery + ',';
                                         end;
                            mQuery:=mQuery + '}';
                            if i<>(mr.count-1) then mQuery:=mQuery + ',';
                        finally
                           mValues.free;
                        end;
              end;
          end;
       finally
           mr.free;
       end;
    end;
            mQuery:=mQuery + ']';

      finally
          mFields.free;
      end;

        result:= TJSONSuperObject.ParseString(mQuery,true);

  finally

  end;
end;



 function POST_API_JSON(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mJSON:TJSONSuperObject;mStatus:Boolean):TJSONSuperObject;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mstring:string;
begin
  AOS := mSO.ObjectSpace;
  try
        result:=TJSONSuperObject.create;
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl );
             // NxShowSimpleMessage(mUrl + ' - ' + mJSON, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic QVBJX1N5bmNocm9uaXphY2U6YzNsdVkyaHliMjVwZW1GalpRPT0=');  //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //'); //mWinHTTP.SetRequestHeader('Accept', 'application/json; charset=UTF-8');
              mWinHTTP.Send(mJson);
               if mStatus then begin
                       if copy(inttostr(mWinHTTP.Status),1,1) ='2'  then begin
                                  result.S['Status']:=  FloatToStr(mWinHTTP.Status)   ;
                                  result.S['ResponseText']:=mWinHTTP.ResponseText;

                       end else begin
                            result.S['Status']:=  FloatToStr(mWinHTTP.Status)   ;
                                  result.S['StatusText']:=  mWinHTTP.StatusText     ;

                       end;
                end else begin
                                  result.S['Status']:=  FloatToStr(mWinHTTP.Status)   ;
                                  result.S['ResponseText']:=mWinHTTP.ResponseText;
               end;
           end;
      finally
      end;

end;




begin
end.