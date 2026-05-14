procedure  SendData(OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);
var
 mList, mVyrList:TStringList;
 i,j,k:integer;
 mSite:TSiteForm;
 mBO, mRowBO, mVyrBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mOS:TNxCustomObjectSpace;
 mJSON:TJSONSuperObject;
 mWinHTTP, mWinHTTP2: Variant;
begin
  mOS:=OS;
  mList:=TStringList.Create;
  mOS.SQLSelect(format('Select id from receivedorders where docdate$date>%s and docqueue_id=''9200000101'' ',[IntToStr(Trunc(date-30))]),mList);
  for i:=0 to mlist.Count-1 do begin
     mBO:=mOS.CreateObject(Class_ReceivedOrder);
     mBO.Load(mlist.Strings[i],nil);
     mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
     for j:=0 to mrows.count-1 do begin
       mRowBO:=mRows.BusinessObject[j];
       if not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('X_Pozice_OD'))) then begin
          mVyrList:=TStringList.Create;
          mOS.SQLSelect(format('select id from defrolldata where clsid=''XNAVPBFTCRO4BBYJZ2FN14T51O'' and X_OP_Pozice=''%s'' ',[mRowBO.GetFieldValueAsString('X_Pozice_OD')]),mVyrList);
          if mVyrList.count>0 then begin
           for k:=0 to mVyrList.Count-1 do begin
            mVyrBO:=mOS.CreateObject('XNAVPBFTCRO4BBYJZ2FN14T51O');
            mVyrBO.Load(mVyrList.Strings[k],nil);
            mJSON:= TJSONSuperObject.CreateNew;
            mWinHTTP2:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
            mWinHTTP2.Open('POST','https://sod.spedos.cz/api/api.abra-vyrobek.php?ID_montaz_vyrobky=' + mVyrBO.GetFieldValueAsString('Code') +
                                  '&vyrobni_cislo='+ mVyrBO.GetFieldValueAsString('Name')+
                                  '&cis_zak='+ mRowBO.GetFieldValueAsString('BusOrder_ID.CODE')+
                                  '&Rodneico='+ GetICO(mOS)+
                                  '&cis_obj='+ mBO.DisplayName);
            mWinHTTP2.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
            mWinHTTP2.Send();
            mJSON := TJSONSuperObject.ParseString(mWinHTTP2.ResponseText, True);




            mvyrbo.free;
           end;
          end;
       end;
     end;
     mbo.free;

  end;

end;


function GetICO(AOS : TNxCustomObjectSpace) : string;
const
  cSQL = 'SELECT OrgIdentNumber FROM GlobData ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

begin
end.