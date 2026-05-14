{ ============================================================================
  Popis skriptu AG
  ============================================================================
  
  Tento skript slouží k získávání aktuálních cen mědi (LME Copper Cash) 
  z webové stránky Westmetall (https://www.westmetall.com/en/markdaten.php).
  
  FUNKCE:
  - GetData: Hlavní procedura, která stahuje data z webu, parsuje HTML 
    odpověď a extrahuje aktuální cenu mědi.
  - API_GET: Pomocná funkce pro provedení HTTP GET požadavku.
  - ConvertToText a ConvertUTF8toString: Funkce pro konverzi kódování textu.
  
  VÝSTUP:
  Skript vrací cenu mědi jako řetězec ve formátu '#cena# pozice index číslo float',
  kde je cena zpracovaná hodnota z webu.
  
  POZNÁMKY:
  - Skript používá WinHttp pro HTTP komunikaci.
  - Parsování HTML je založeno na specifických znacích a pozicích v odpovědi,
    což může být náchylné na změny v struktuře webu.
  ============================================================================ }

procedure GetData(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mMessage:string;
 mNumber:string;
 mIndex, mIndex2:Integer;
 mFloatNumber:Extended;
begin
  mMessage:=API_GET('https://www.westmetall.com/en/markdaten.php');
  mIndex:=NxSearch(mMessage,'/en/markdaten.php?action=diagram&amp;field=LME_Cu_cash',[srAll],0);
  mNumber:=Copy(mMessage,mIndex+173,20);
  mIndex2:=NxSearch(mNumber,'<',[srAll],0);
  mNumber:=Copy(mNumber,0,mIndex2-1);
  mNumber:=NxSearchReplace(NxSearchReplace(NxSearchReplace(NxSearchReplace(NxSearchReplace(mNumber,',','',[srall]),' ','',[srall]),'.',',',[srall]),Chr(13),'',[srAll]),Chr(10),'',[srAll]);
  mFloatNumber:=StrToFloat(mNumber);
  Success := True;
  LogInfoStr := ''+'#'+mNumber+'#'+ ' pozice '+IntToStr(mIndex2)+'   číslo '+FloatToStr(mFloatNumber);
end;

function API_GET(aURL:String): String;
var
  mWinHTTP: Variant;
  mRequest, mLogin: string;
  mJSON:TJSONSuperObject;
  mList:TStringList;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('GET', aURL);
    mWinHTTP.SetRequestHeader('Content-Type', 'text/html');
    //mWinHTTP.SetRequestHeader('Authorization','Basic '+cAuthorization);
    mWinHTTP.Send();
    Result:=ConvertToText(mWinHTTP.Responsebody);
  except

  end;
end;

function ConvertToText(aUnicodeBytes: TBytes): String;
var
  mUnicodeBites: TBytes;
begin
  mUnicodeBites := TEncoding.Convert(aUnicodeBytes,Encoding_cpUTF_8,Encoding_cpUTF_16);
  Result := TEncoding.Unicode.GetString(mUnicodeBites);
end;


function ConvertUTF8toString(aString: String): String;
var
  mUnicodeBites: TBytes;
begin
  mUnicodeBites := TEncoding.UTF8.GetBytes(aString);
  mUnicodeBites := TEncoding.Convert(mUnicodeBites,Encoding_cpUTF_8,Encoding_cpUTF_16);
  Result := TEncoding.Unicode.GetString(mUnicodeBites);
end;

begin
end.