uses 'eu.spedos.senddata.progress';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Odeslat do OD ';
  mAction.Hint := 'Označené záznamy odešle do OD ';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SendOD;
end;

Procedure SendOD(Sender:TComponent);
var
 mSite:TSiteForm;
 mList, mInvoiceList:TStringList;
 i,j,k,l:integer;
 mOS:TNxCustomObjectSpace;
 mBusOrderBO, mInvoiceBO:TNxCustomBusinessObject;
 mStream:TMemoryStream;
 mRows, mDRBRows:TNxCustomBusinessMonikerCollection;
 mRowBO, mBODRow:TNxCustomBusinessObject;
 mList2:TStringList;
 aStream:TMemoryStream;
 mJSON:TJSONSuperObject;
 mWinHTTP, mWinHTTP2: Variant;
begin
  mList:=TStringList.Create;
  mSite:=TComponent(Sender).BusRollSite;
  TBusRollSiteForm(mSite).List.GetSelectedId(mList);
  mOS:=mSite.BaseObjectSpace;
  if mList.Count>0 then begin
    if NxMessageBox('Dotaz','Přejete si odeslat '+IntToStr(mList.Count)+' zakázek do obchodní dokumentace?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
       ProgressInit(mSite, 'Odesílám data...', mlist.Count);
         for i:=0 to mList.count-1 do begin
          mBusOrderBO:=mOS.CreateObject(Class_BusOrder);
          mBusOrderBO.Load(mlist.Strings[i],nil);
          mStream := TMemoryStream.Create;
          try
          if mBusOrderBO.GetFieldValueAsBoolean('X_Closed') then begin
          //CFxInternet.HTTPPostBinary('https://sod.spedos.cz/api/api.abra-zakazka.php?','user=aBra&password=skS8f-sxR&cis_zak=' + mBusOrderBO.GetFieldValueAsString('Code') + '&uzavreno=1',mStream)
                              mJSON:= TJSONSuperObject.CreateNew;
                              mWinHTTP2:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
                              mWinHTTP2.Open('POST','https://sod.spedos.cz/api/api.abra-zakazka.php?cis_zak='+ mBusOrderBO.GetFieldValueAsString('Code')+'&Rodneico='+ GetICO(mos)+'&uzavreno=1');
                              mWinHTTP2.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
                              mWinHTTP2.Send();
                              mJSON := TJSONSuperObject.ParseString(mWinHTTP2.ResponseText, True);
                              //NxShowSimpleMessage(mJSON.AsString,mSite);
          end else begin
          //CFxInternet.HTTPPostBinary('https://sod.spedos.cz/api/api.abra-zakazka.php?','user=aBra&password=skS8f-sxR&cis_zak=' + mBusOrderBO.GetFieldValueAsString('Code') + '&uzavreno=0',mStream);
                              mJSON:= TJSONSuperObject.CreateNew;
                              mWinHTTP2:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
                              mWinHTTP2.Open('POST','https://sod.spedos.cz/api/api.abra-zakazka.php?cis_zak='+ mBusOrderBO.GetFieldValueAsString('Code')+'&Rodneico='+ GetICO(mOS)+'&uzavreno=0');
                              mWinHTTP2.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
                              mWinHTTP2.Send();
                              mJSON := TJSONSuperObject.ParseString(mWinHTTP2.ResponseText, True);
                              //NxShowSimpleMessage(mJSON.AsString,mSite);

          end;
          except
          end;
          mStream.free;
          mInvoiceList:=TStringList.Create;
          mOS.SQLSelect(Format('Select parent_id from issuedinvoices2 where busorder_id=''%s'' group by parent_id ',[mBusOrderBO.OID]),mInvoiceList);
          if mInvoiceList.count>0 then begin
              for j:=0 to mInvoiceList.count-1 do begin
                mInvoiceBO:=mOS.CreateObject(Class_IssuedInvoice);
                mInvoiceBO.Load(mInvoiceList.strings[j],nil);
                    mRows:=mInvoiceBO.GetLoadedCollectionMonikerForFieldCode(mInvoiceBO.GetFieldCode('Rows'));
                    for k:=0 to mRows.count-1 do begin
                       mRowBO:=mRows.BusinessObject[k];
                       if (mRowBO.GetFieldValueAsInteger('RowType')=3) and (mRowBO.GetFieldValueAsInteger('StoreCard_ID.Category')=1) then begin
                          mBODRow:=mOS.CreateObject(Class_BillOfDeliveryRow);
                          mBODRow.Load(mRowBO.GetFieldValueAsString('ProvideRow_ID'),nil);
                          mDRBRows:=mBODRow.GetLoadedCollectionMonikerForFieldCode(mBODRow.GetFieldCode('DocRowBatches'));
                          if mDRBRows.count>0 then begin
                          for l:=0 to mDRBRows.count-1 do begin
                             mList2:=TStringList.create;
                             mOS.SQLSelect(format('select code from defrolldata where name=''%s'' and X_BusOrder_ID=''%s'' and clsid=''XNAVPBFTCRO4BBYJZ2FN14T51O'' and hidden=''N'' ',[mDRBRows.BusinessObject[l].GetFieldValueAsString('StoreBatch_ID.Name'),mRowBO.GetFieldValueAsString('BusOrder_ID')]),mList2);
                             if mlist2.Count>0 then begin
                             aStream:=TMemoryStream.create;
                             try  //
                             {
                             CFxInternet.HTTPPostBinary('https://sod.spedos.cz/api/api.abra-vyrobek.php?',
                                                        'user=aBra&password=skS8f-sxR&ID_montaz_vyrobky=' + mlist2.Strings[0] +'&fakturovano=1',aStream); }
                              mJSON:= TJSONSuperObject.CreateNew;
                              mWinHTTP2:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
                              mWinHTTP2.Open('POST','https://sod.spedos.cz/api/api.abra-vyrobek.php?ID_montaz_vyrobky='+mlist2.Strings[0]+'&datum_fakturovano='+FormatDateTime('YYYY-MM-DD',mInvoiceBO.GetFieldValueAsDateTime('DocDate$DATE')) +'&cis_zak='+ mRowBO.GetFieldValueAsString('BusOrder_ID.Code')+'&Rodneico='+ GetICO(mOS)+'&fakturovano=1');
                              mWinHTTP2.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
                              mWinHTTP2.Send();
                              mJSON := TJSONSuperObject.ParseString(mWinHTTP2.ResponseText, True);
                              //NxShowSimpleMessage(mJSON.AsString,mSite);
                             except
                             end;
                             aStream.free;
                             end;
                             mlist2.free;
                          end;
                          end;
                          mBODRow.free;
                       end;
                    end;
                mInvoiceBO.free;
              end;
          end;
          mBusOrderBO.Free;
          ProgressSetPos(i+1);
         end;
       ProgressDispose();
    end;
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