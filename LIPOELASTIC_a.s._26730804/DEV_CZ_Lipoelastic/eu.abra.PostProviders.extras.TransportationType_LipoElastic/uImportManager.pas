//Knohovna primárně pro potřeby WMS.
//Provádí automatické zpracování DL a PRV přepnutých do specifického procesního stavu.
//V Případě chyby provede přepnutí do stavu ke kontrole. Jinak vyřízeno. Nebo dle nastavených const.
//Forma nekonečného cyklu začíná prefixem PA_

const cPMState_ForProcessing = '5010000101';  //Fronta vstup
      cBB_LogName = 'BBAUTOIMPORT';

      //Kopie z WMS
      DOC_VYD = '21';                       // Kod vydejky
      DOC_PREV = '22';                      // Kod prevodky vydej
      DOC_VYSKLLIST = 'RL';                 // Vyskladnovaci list
      DOC_EXPLIST = 'EL';                   // Expedicni list
      //Kopie z WMS end;

//Balíkobot - přechod do stavu, kdy byl export v pořádku
// Tvorba štítku/odeslání dat -> Tvorba štítku/odeslání dat
function PRECHOD_BALIKOBOT_SUCCESS(docTyp: string;): string;
begin
  case docTyp of
    DOC_VYD: result :=  'B010000101';
    DOC_PREV: result := 'B010000101';
    DOC_EXPLIST: result := '';//BB - zatím neumíme - ale šlo by to
    DOC_VYSKLLIST: result := '';//BB - zatím neumíme
  end;
end;

//Balíkobot - přechod do stavu, kdy při exportu došlo k chybě
// Tvorba štítku/odeslání dat -> Tvorba štítku/odeslání dat
function PRECHOD_BALIKOBOT_ERROR(docTyp: string;): string;
begin
  case docTyp of
    DOC_VYD: result :=  'C010000101';
    DOC_PREV: result := 'C010000101';
    DOC_EXPLIST: result := '';//BB - zatím neumíme - ale šlo by to
    DOC_VYSKLLIST: result := '';//BB - zatím neumíme
  end;
end;

///////////////////FCE////////////////

//Dodací listy
procedure Auto_ImportManagerStoreDocument_ByPMState(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  cSQL = 'SELECT A.ID FROM StoreDocuments A WHERE A.PMState_ID= '+ QuotedStr(cPMState_ForProcessing) +
        ' and A.DocumentType in ['+QuotedStr(DOC_VYD)+','+QuotedStr(DOC_PREV)+']';
var i: Integer;
    mList,mListTmp,mLogInfoStr:TStringList;
    mBO: TNxCustomBusinessObject;
begin
  Success := True;
  LogInfoStr := '';
  mList := TStringList.Create;
  mLogInfoStr := TStringList.Create;
  mListTmp := TStringList.Create;
  try
    OS.SQLSelect(cSQL, mList);
    for i:= 0 to mList.Count -1 do
    begin
      mBO:= OS.CreateObject(Class_BillOfDelivery);
      try
        try
          mBO.load(mList[i],nil);
          mListTmp.Clear;
          mListTmp.Add(mBO.OID);
          //StartAutoCreatePackageNonVisual(OS,mList,mBO ,Class_BillOfDelivery, PRECHOD_BALIKOBOT_SUCCESS(DOC_VYD) , PRECHOD_BALIKOBOT_ERROR(DOC_VYD),mLogInfoStr );
          CFxScriptingEngine.CallScript('eu.abra.PostProviders.uImportManager.StartAutoCreatePackageNonVisual', [ObjToInt(OS), ObjToInt(mListTmp),ObjToInt(mBO),Class_BillOfDelivery, PRECHOD_BALIKOBOT_SUCCESS(DOC_VYD), PRECHOD_BALIKOBOT_ERROR(DOC_VYD), ObjToInt(mLogInfoStr)]);
        except
          mLogInfoStr.add('[FATAL ERROR] '  + ExceptionMessage);
        end;
      finally
        mBO.free;
      end;
    end;

    LogInfoStr := mLogInfoStr.text;
  finally
    mListTmp.free;
    mList.Free;
    mLogInfoStr.Free;
  end;

end;







begin
end.