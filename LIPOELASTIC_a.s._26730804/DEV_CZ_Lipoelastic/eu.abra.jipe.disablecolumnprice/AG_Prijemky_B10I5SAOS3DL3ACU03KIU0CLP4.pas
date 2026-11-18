{
Vyvolává se po vytvoření instance formuláře.
}
procedure InitSite_Hook(Self: TSiteForm);
var mDBGrid:TMultiGrid;
muser:TNxCustomBusinessObject;
  mPar : TNxParameters;
  mfilter:boolean;
begin
  if not (Self is TDynSiteForm) then exit;
//  mPar := TNxParameters.Create;
    try
      //GetEffectiveFunctionSecurityRights(Self.SiteContext.GetCompanyCache,Self.SiteContext.GetObjectSpace,'PEIGVLCI1HD4FC0BF3GS1JYYIG',
      //      NxGetActualUserID(Self.BaseObjectSpace), mPar);   //vidět nák. ceny PEIGVLCI1HD4FC0BF3GS1JYYIG
      //ShowMessage('  Prava na: ' + mPar.Text);
     // if (NxAt('G1TDNZSKTVCL33N2010DELDFKK:Supervisor=A;',mPar.Text)=0) and   //privilegium supervisor
     //   (NxAt('0K0F4EI24NCO5A3ITC4MUM051K:Vidět nákupní ceny=N;', mPar.Text) > 0) then begin

    mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
        try
          mUser.Load(Self.CompanyCache.GetUserID, nil);

              mfilter:=muser.GetFieldValueAsBoolean('X_Nakupni_ceny');

        finally
           muser.free;
        end;

  {   if (NxGetActualUserID(Self.BaseObjectSpace)='AUTO000000') or //"Automat"	"Automat"	"Ne"	"Auto"	""
        (NxGetActualUserID(Self.BaseObjectSpace)='1H10000101') or //'Butor Ales"	"Butor Aleš"	"Ne"	"BA"	""
        (NxGetActualUserID(Self.BaseObjectSpace)='D000000101') or //'Cabák Jiří"	"Cabák Jiří"	"Ne"	"CJ"	""
        (NxGetActualUserID(Self.BaseObjectSpace)='2F10000101') or	//'dd"	"dd"	"Ne"	"dd"	""
        (NxGetActualUserID(Self.BaseObjectSpace)='2510000101') or	//"Drimal Tomas"	"Dřímal Tomáš"	"Ne"	"TD"	""
        (NxGetActualUserID(Self.BaseObjectSpace)='2S00000101') or	//"Dufková Pavla"	"Dufková Pavla"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='2I00000101') or	//"Datelinkova Erika"	"Erika Ďatelinková"	"Ne"	"ERDA"	""
        (NxGetActualUserID(Self.BaseObjectSpace)='1V00000101') or	//"ESHOP"	"ESHOP"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='1C00000101') or	//"Franková Ilona"	"Franková Ilona"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='1900000101') or	//"Grycová Nela"	"Grycová Nela"	"Ne"	"GRNE"	""
        (NxGetActualUserID(Self.BaseObjectSpace)='1P00000101') or	//"Hrušková Petra"	"Hrušková Petra"	"Ne"	"PH"	""
        (NxGetActualUserID(Self.BaseObjectSpace)='2X00000101') or	//"Jantač Zdeněk"	"Jantač Zdeněk"	"Ne"	"ZJ"	""
        (NxGetActualUserID(Self.BaseObjectSpace)='6000000101') or	//"Karafiátová Lenka"	"Karafiátová Lenka"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='1R10000101') or	//"Klossova Zdenka"	"Klossová Zdenka"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='2K10000101') or	//"Korytarova Pavla"	"Korytářová Pavla"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='2110000101') or	//"Kristian Robert"	"Kristian Robert"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='4S00000101') or	//"Křenková Iveta"	"Křenková Iveta"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='1300000101') or	//"Kubikova Martina"	"Kubíková Martina"	"Ne"	"p"	""
        (NxGetActualUserID(Self.BaseObjectSpace)='1420000101') or	//"LTD"	"LTD"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='1X10000101') or	//"Machyckova Silvie"	"Machýčková Silvie"	"Ne"	"MS"	""
        (NxGetActualUserID(Self.BaseObjectSpace)='1M10000101') or	//"Mesicova Nikola"	"Měsícová Nikola"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='2620000101') or	//"Neuwirthova Lenka"	"Neuwirthová Lenka"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='1020000101') or	//"Novotna Jana"	"Novotná Jana"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='5S00000101') or	//"Opalkova Iva"	"Opálková Ivana"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='3S00000101') or	//"Pečivová Ludmila"	"Pečivová Ludmila"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='5K00000101') or	//"Puschova Eva"	"Puschová Eva"	"Ne"	"PE"	""
        (NxGetActualUserID(Self.BaseObjectSpace)='1Q10000101') or	//"Romankova Martina"	"Románková Martina"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='1E10000101') or	//"Rehakova Renata"	"Řeháková Renata"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='2310000101') or	//"Stavinohova Marketa"	"Stavinohová Markéta"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='1620000101') or	//"Stromsikova Jarka"	"Stromšíková Jarka"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='2G10000101') or	//"Stromsikova Michaela"	"Stromšíková Michaela"	"Ne"	""	""
        (NxGetActualUserID(Self.BaseObjectSpace)='2A10000101') or	//"Svec Dalibor"	"Švec Dalibor"	"Ne"	"DS"	""
//        (NxGetActualUserID(Self.BaseObjectSpace)='2D10000101') or	//"vanurova"	"vanurova"	"Ne"	"DS"	""

        (NxGetActualUserID(Self.BaseObjectSpace)='1120000101') 	//"Trlifajova Ludmila"	"Trlifajová Ludmila"	"Ne"	"LT"	""

        then begin
           mfilter:=true;
        end;
              }

        if not mfilter then begin
         mDBGrid := TMultiGrid(NxFindChildControl(TTabSheet(NxFindChildControl(Self.GetSiteAppForm,'tabDetail')), 'grdRows'));
        if Assigned(mDBGrid) then begin
          mDBGrid.RemoveColumn(mDBGrid.ColumnByName('colUnitPrice'));
          mDBGrid.RemoveColumn(mDBGrid.ColumnByName('colTotalPrice'));
        end;
      end;
    finally
     // mPar.Free;
    end;
end;

begin
end.