procedure ExportForPowerBI (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);

var
  mList, mList2 : TStringList;
  mFileName:String;
  mFTP:TFTP;
  i:integer;
  cSQL:string;
  mDateFrom,mDateTo:TDateTime;
begin
  mList := TStringList.create;
  mList2 :=TStringList.create;
  mFileName:=NxGetTempDir+'Prodeje_powerBI.csv';

  //mDateFrom:=NxDateStart(StrToInt(FormatDateTime('YYYY',(NxNow))),StrToInt(FormatDateTime('MM',(NxNow)))-1);
  //mDateTo:=NxDateStop(StrToInt(FormatDateTime('YYYY',(NxNow))),StrToInt(FormatDateTime('MM',(NxNow)))-1);



  //mDateFrom:=Date()-5;
  mDateFrom:=Date()-7;
  mDateTo:=Date() ;

  try

  cSQL:='select r.posindex,replace(z.code,'';'','',''),replace(sc.code,'';'','',''),replace(sc.name,'';'','',''),replace(sc.typ,'';'','',''),replace(sc.druh,'';'','',''),replace(sc.provedeni,'';'','',''),replace(sc.barva,'';'','',''),replace(sc.velikost,'';'','',''), replace(sc.stat_kod,'';'','',''), replace(sc.stat_skupina,'';'','',''), ';
	cSQL:=cSQL +   'replace(sc.kolekce,'';'','',''),replace(sc.customstariffNumber,'';'','','') as Sazebnik,sc.x_pocetksvbal as ksvbal,sc.weight as vaha,r.quantity as mnozst, replace(r.qunit,'';'','',''), ';
	cSQL:=cSQL +   quotedstr('') +' as pocjed,r.tamountwithoutvat,round(r.tamountwithoutvat*h.currrate,2) as nakc, ';
	cSQL:=cSQL +   'dcq.code + ''-'' + TRIM(cast(h.ordnumber as Char(10))) + ''/'' + prd.code as cisfak,h.varsymbol,''F'' as TypDoc,convert(nvarchar(20),h.vatdate$date,106), ';
	cSQL:=cSQL +   'DATEPART (YEAR,h.vatdate$date)  as rok,DATEPART (MONTH,h.vatdate$date) as mesic,replace(fy.code,'';'','','') as kodfy,fy.OrgIdentNumber as ICO,replace(fy.name,'';'','','') as firma,replace(pr.Name,'';'','','') as provoz, ';
	cSQL:=cSQL +   'ad.countrycode,ad.postcode,replace(h.currency_id,''0'','''') as mena,h.currrate as kurs,replace(sc.obch_pripad,'';'','','') as ObchPripad, ';
	cSQL:=cSQL +   'case st.x_typ_skladu when 0 then ''None'' when 1 then ''Třebíč'' when 2 then ''VM'' when 3 then ''Konsignační'' when 4 then ''Expediční'' when 5 then ''Praha'' else ''Ostatní'' end as TypSkl, ';
	cSQL:=cSQL +   'sc.cassiti,sc.Casskut,sc.x_konec_vyroby,replace(h.description,'';'','',''),ct.x_EU_Member as Clen_EU, _objedn.objedn, ';
	cSQL:=cSQL +   'case when (charindex(''%'',h.description)>0 or charindex(''sleva'',h.description)>0) and charindex(''-'',h.description)>0 then rtrim(substring(h.description,1,charindex(''-'',h.description)-1)) else '''' end as Voucher, ';
	cSQL:=cSQL +   'h.x_kalkuldoprava,replace(sc.Skupina,'';'','',''),replace(sc.StoreCardCategory,'';'','',''),replace(sc.dodavatel,'';'','',''), replace(sc.stat_dodv,'';'','',''), replace(sc.sortiment,'';'','',''), h.ID as Head_ID, R.ID as Row_id ,replace(BP.name,'';'','','') as project, replace(Tr.name,'';'','','') as doprava, replace(pa.Name,'';'','','') as Platba ,replace(sc.EAN,'';'','','') as EAN ,r.TAmount,round(r.LocalTAmount,2),replace(XDOD.EMail,'';'','',''),zdok.varsymbol as Zdroj_doklad,replace(ro.externalnumber,'';'','','') as external_number ';

	cSQL:=cSQL +   'from IssuedInvoices2 r ';
  cSQL:=cSQL +   'left outer join IssuedInvoices h on r.parent_id=h.id ';
  cSQL:=cSQL +   'left outer join BusOrders z on r.busorder_id=z.id ';
	cSQL:=cSQL +   'left outer join BusProjects bp on r.busproject_id=bp.id ';
  cSQL:=cSQL +   'left outer join DocQueues dcq on h.Docqueue_id=dcq.id ';
	cSQL:=cSQL +   'left outer join Periods prd on h.Period_id=prd.id ';
	cSQL:=cSQL +   'left outer join Firms fy on h.firm_id=fy.id ';

  cSQL:=cSQL +   'left outer join FirmOffices pr on h.Firmoffice_id=pr.id ';
	cSQL:=cSQL +   'left outer join Addresses ad on fy.residenceaddress_id=ad.id ';
	cSQL:=cSQL +   'left outer join Countries ct on ad.CountryCode=ct.code ';
	cSQL:=cSQL +   'left outer join Stores st on r.store_id=st.id ';

  cSQL:=cSQL +   'left outer join PaymentTypes Pa on pa.id=h.PaymentType_ID ';
	cSQL:=cSQL +   'left outer join TransportationTypes Tr on Tr.id=h.TransportationType_ID ';
	cSQL:=cSQL +   'left outer join storedocuments2 sd2 on r.providerow_id= sd2.id ';
	cSQL:=cSQL +   'left outer join receivedorders RO on sd2.provide_id= RO.id ';
  cSQL:=cSQL +   'left outer join Addresses XDOD on h.X_Delivery_adress_id=XDOD.id ';
  cSQL:=cSQL +   'left outer join Issuedinvoices ZDOK on ''_''=ZDOK.id ';


	cSQL:=cSQL +   'left outer join (select sc.id, sc.ean,sc.code,sc.name,t.code as tkod, t.name as typ, d.id as dkod,d.name as druh, p.id as pkod, p.name as provedeni, ';
	cSQL:=cSQL +   ' b.code as bkod, b.name as barva,v.code as vkod, v.name as velikost,sc.customstariffNumber, sc.x_davka_sici as sici_davka,sc.x_stb_siti as cassiti, ';
	cSQL:=cSQL +   'sc.x_CasVyroby_ks as CasSkut, sc.x_pocetksvbal, su.weight, bt.name as obch_pripad, st.code as stat_kod, st.name as stat_skupina, ';
	cSQL:=cSQL +   'CAST(substring(ud4.StringFieldValue COLLATE Czech_CS_AS,1,10) as Char(10)) as kolekce,sc.x_konec_vyroby,sx.name as Skupina, ';
	cSQL:=cSQL +   ' scc.Name as StoreCardCategory,Dod.Name as dodavatel, dbo.GetTopAssortmentGroup(sc.id,1) ';
	cSQL:=cSQL +   'as sortiment, adr.countryCode as stat_dodv from storecards sc ';
   	 	cSQL:=cSQL +   'left join Suppliers SUPP on SUPP.id=sc.MainSupplier_ID ';
   	 	cSQL:=cSQL +   'left join Firms Dod on Dod.id=SUPP.Firm_ID ';
   	 	cSQL:=cSQL +   'left outer join addresses adr on Dod.ResidenceAddress_ID=adr.id ';
   	 	cSQL:=cSQL +   'left join StoreCardCategories scc on scc.id=sc.StoreCardCategory_ID COLLATE Czech_CS_AS ';
   	 	cSQL:=cSQL +   'left join DefRollData sx on sx.CLSID=''GMSMDDHXELF4DGLK4KVSMLGSZ0'' and sx.id=sc.X_skupina_ID COLLATE Czech_CS_AS ';
   	 	cSQL:=cSQL +   'left join DefRollData t on ''TJDIA05IJCBON5S3EGRD4K5FXC''=t.CLSID and sc.x_typ_produktu=t.ID ';
   	 	cSQL:=cSQL +   'left join USERDATA UD on 2000016=UD.FIELDCODE AND ''C3V5QDVZ5BDL342M01C0CX3FCC''=UD.CLSID AND sc.ID = ud.id ';
   	 	cSQL:=cSQL +   'left join Defrolldata d on UD.StringFieldValue COLLATE Czech_CS_AS=d.id ';
   	 	cSQL:=cSQL +   'left join USERDATA UD1 on 2000015=UD1.FIELDCODE AND ''C3V5QDVZ5BDL342M01C0CX3FCC''=UD1.CLSID AND sc.ID = ud1.id ';
   	 	cSQL:=cSQL +   ' left join Defrolldata p on UD1.StringFieldValue COLLATE Czech_CS_AS=p.id ';
   	 	cSQL:=cSQL +   'left join USERDATA UD2 on 2000024=UD2.FIELDCODE AND ''C3V5QDVZ5BDL342M01C0CX3FCC''=UD2.CLSID AND sc.ID = ud2.id ';
   	 	cSQL:=cSQL +   'left join Defrolldata v on UD2.StringFieldValue COLLATE Czech_CS_AS=v.id ';
   	 	cSQL:=cSQL +   'left join USERDATA UD3 on 2000014=UD3.FIELDCODE AND ''C3V5QDVZ5BDL342M01C0CX3FCC''=UD3.CLSID AND sc.ID = ud3.id ';
   	 	cSQL:=cSQL +   'left join Defrolldata b on UD3.StringFieldValue COLLATE Czech_CS_AS=b.id ';
    	 	cSQL:=cSQL +   'left join DefRollData st on ''3VBS22GA2LH4HCYLOVOGHT0YJG''=st.CLSID and sc.x_statistika COLLATE Czech_CS_AS=st.ID ';
    	 	cSQL:=cSQL +   'left join storeunits su on sc.id=su.parent_id and sc.mainunitcode=su.code ';
    	 	cSQL:=cSQL +   'left join bustransactions bt on sc.x_obchodni_pripad=bt.id ';
   	 	cSQL:=cSQL +   'left join USERDATA UD4 on 2000018=UD4.FIELDCODE AND ''C3V5QDVZ5BDL342M01C0CX3FCC''=UD4.CLSID AND sc.ID = UD4.ID) sc on r.storecard_id=sc.id ';
    	 	cSQL:=cSQL +   'left outer join (select rf.id,op.objedn from issuedinvoices2 rf ';
    	 	cSQL:=cSQL +   'left outer join storedocuments2 sd2 on rf.providerow_id= sd2.id ';
    	 	cSQL:=cSQL +   ' left outer join (select a.id,r.code+''-''+ltrim(str(a.ordnumber))+''/''+p.code as objedn from receivedorders a ';
   	 	cSQL:=cSQL +   'left outer join docqueues r on a.DocQueue_ID=r.id left outer join periods p on a.Period_ID=p.id) op on sd2.provide_id= op.id ';

   	 	cSQL:=cSQL +   ' where rf.RowType = 3) _objedn on r.id=_objedn.id where r.rowtype=3 and h.VATdate$date between  ' + NxFloatToIBStr(mdatefrom)  + ' and ' + NxFloatToIBStr(mdateto) ;







    cSQL:=cSQL +' union all select r.posindex,replace(z.code,'';'','',''),replace(sc.code,'';'','',''),replace(sc.name,'';'','',''),replace(sc.typ,'';'','',''),replace(sc.druh,'';'','',''),replace(sc.provedeni,'';'','',''),replace(sc.barva,'';'','',''),replace(sc.velikost,'';'','',''), replace(sc.stat_kod,'';'','',''), replace(sc.stat_skupina,'';'','',''), ';
	cSQL:=cSQL +   'sc.kolekce,sc.customstariffNumber as Sazebnik,sc.x_pocetksvbal as ksvbal,sc.weight as vaha,r.quantity*(-1) as mnozst, r.qunit, ';
	cSQL:=cSQL +   quotedstr('') +' as pocjed,r.tAmountwithoutvat*(-1),round(r.tAmountwithoutvat*(-1)*h.currrate,2) as nakc, ';
	cSQL:=cSQL +   'dcq.code + ''-'' + TRIM(cast(h.ordnumber as Char(10))) + ''/'' + prd.code as cisfak,h.varsymbol,''D'' as TypDoc,convert(nvarchar(20),h.vatdate$date,106), ';
	cSQL:=cSQL +   'DATEPART (YEAR,h.vatdate$date)  as rok,DATEPART (MONTH,h.vatdate$date) as mesic,replace(fy.code,'';'','','') as kodfy,fy.OrgIdentNumber as ICO,replace(fy.name,'';'','','') as firma,replace(pr.Name,'';'','','') as provoz, ';
	cSQL:=cSQL +   'ad.countrycode,ad.postcode,replace(h.currency_id,''0'','''') as mena,h.currrate as kurs,replace(sc.obch_pripad,'';'','','') as ObchPripad, ';
	cSQL:=cSQL +   'case st.x_typ_skladu when 0 then ''None'' when 1 then ''Třebíč'' when 2 then ''VM'' when 3 then ''Konsignační'' when 4 then ''Expediční'' when 5 then ''Praha'' else ''Ostatní'' end as TypSkl, ';
	cSQL:=cSQL +   'sc.cassiti,sc.Casskut,sc.x_konec_vyroby,h.description,ct.x_EU_Member as Clen_EU, _objedn.objedn, ';
	cSQL:=cSQL +   'case when (charindex(''%'',h.description)>0 or charindex(''sleva'',h.description)>0) and charindex(''-'',h.description)>0 then rtrim(substring(h.description,1,charindex(''-'',h.description)-1)) else '''' end as Voucher, ';
	cSQL:=cSQL +   'cast(0 as Numeric(10,3)) as x_kalkuldoprava,replace(sc.Skupina,'';'','',''),replace(sc.StoreCardCategory,'';'','',''),replace(sc.dodavatel,'';'','',''), replace(sc.stat_dodv,'';'','',''), replace(sc.sortiment,'';'','','')  , h.ID as Head_ID, R.ID as Row_id ,replace(BP.name,'';'','','') as project, replace(Tr.name,'';'','','') as doprava, replace(pa.Name,'';'','','') as Platba ,replace(sc.EAN,'';'','','') as EAN ,r.TAmount,round(r.LocalTAmount,2),replace(XDOD.EMail,'';'','',''),zdok.varsymbol as Zdroj_doklad,replace(ro.externalnumber,'';'','','') as external_number ';

	cSQL:=cSQL +   'from IssuedCreditNotes2 r left outer join BusOrders z on r.busorder_id=z.id ';
	cSQL:=cSQL +   'left outer join BusProjects bp on r.busproject_id=bp.id left outer join IssuedCreditNotes h on r.parent_id=h.id ';
	cSQL:=cSQL +   'left outer join DocQueues dcq on h.Docqueue_id=dcq.id ';
	cSQL:=cSQL +   'left outer join Periods prd on h.Period_id=prd.id ';
	cSQL:=cSQL +   'left outer join Firms fy on h.firm_id=fy.id ';


	cSQL:=cSQL +   'left outer join FirmOffices pr on h.Firmoffice_id=pr.id ';
	cSQL:=cSQL +   'left outer join Addresses ad on fy.residenceaddress_id=ad.id ';
	cSQL:=cSQL +   'left outer join Countries ct on ad.CountryCode=ct.code ';
	cSQL:=cSQL +   'left outer join Stores st on r.store_id=st.id ';

  cSQL:=cSQL +   'left outer join PaymentTypes Pa on pa.id=h.PaymentType_ID ';
	cSQL:=cSQL +   'left outer join TransportationTypes Tr on Tr.id=h.TransportationType_ID ';
	cSQL:=cSQL +   'left outer join storedocuments2 sd2 on r.providerow_id= sd2.id ';
	cSQL:=cSQL +   'left outer join receivedorders RO on sd2.provide_id= RO.id ';
  cSQL:=cSQL +   'left outer join Addresses XDOD on fy.residenceaddress_id=XDOD.id ';
  cSQL:=cSQL +   'left outer join Issuedinvoices ZDOK on H.Source_ID=ZDOK.id ';




	cSQL:=cSQL +   'left outer join (select sc.id, sc.ean,sc.code,sc.name,t.code as tkod, t.name as typ, d.id as dkod,d.name as druh, p.id as pkod, p.name as provedeni, ';
	cSQL:=cSQL +   ' b.code as bkod, b.name as barva,v.code as vkod, v.name as velikost,sc.customstariffNumber, sc.x_davka_sici as sici_davka,sc.x_stb_siti as cassiti, ';
	cSQL:=cSQL +   'sc.x_CasVyroby_ks as CasSkut, sc.x_pocetksvbal, su.weight, bt.name as obch_pripad, st.code as stat_kod, st.name as stat_skupina, ';
	cSQL:=cSQL +   'CAST(substring(ud4.StringFieldValue COLLATE Czech_CS_AS,1,10) as Char(10)) as kolekce,sc.x_konec_vyroby,sx.name as Skupina, ';
	cSQL:=cSQL +   ' scc.Name as StoreCardCategory,Dod.Name as dodavatel, dbo.GetTopAssortmentGroup(sc.id,1) ';
	cSQL:=cSQL +   'as sortiment, adr.countryCode as stat_dodv from storecards sc ';
   	 	cSQL:=cSQL +   'left join Suppliers SUPP on SUPP.id=sc.MainSupplier_ID ';
   	 	cSQL:=cSQL +   'left join Firms Dod on Dod.id=SUPP.Firm_ID ';



   	 	cSQL:=cSQL +   'left outer join addresses adr on Dod.ResidenceAddress_ID=adr.id ';
   	 	cSQL:=cSQL +   'left join StoreCardCategories scc on scc.id=sc.StoreCardCategory_ID COLLATE Czech_CS_AS ';
   	 	cSQL:=cSQL +   'left join DefRollData sx on sx.CLSID=''GMSMDDHXELF4DGLK4KVSMLGSZ0'' and sx.id=sc.X_skupina_ID COLLATE Czech_CS_AS ';
   	 	cSQL:=cSQL +   'left join DefRollData t on ''TJDIA05IJCBON5S3EGRD4K5FXC''=t.CLSID and sc.x_typ_produktu=t.ID ';
   	 	cSQL:=cSQL +   'left join USERDATA UD on 2000016=UD.FIELDCODE AND ''C3V5QDVZ5BDL342M01C0CX3FCC''=UD.CLSID AND sc.ID = ud.id ';
   	 	cSQL:=cSQL +   'left join Defrolldata d on UD.StringFieldValue COLLATE Czech_CS_AS=d.id ';
   	 	cSQL:=cSQL +   'left join USERDATA UD1 on 2000015=UD1.FIELDCODE AND ''C3V5QDVZ5BDL342M01C0CX3FCC''=UD1.CLSID AND sc.ID = ud1.id ';
   	 	cSQL:=cSQL +   ' left join Defrolldata p on UD1.StringFieldValue COLLATE Czech_CS_AS=p.id ';
   	 	cSQL:=cSQL +   'left join USERDATA UD2 on 2000024=UD2.FIELDCODE AND ''C3V5QDVZ5BDL342M01C0CX3FCC''=UD2.CLSID AND sc.ID = ud2.id ';
   	 	cSQL:=cSQL +   'left join Defrolldata v on UD2.StringFieldValue COLLATE Czech_CS_AS=v.id ';
   	 	cSQL:=cSQL +   'left join USERDATA UD3 on 2000014=UD3.FIELDCODE AND ''C3V5QDVZ5BDL342M01C0CX3FCC''=UD3.CLSID AND sc.ID = ud3.id ';
   	 	cSQL:=cSQL +   'left join Defrolldata b on UD3.StringFieldValue COLLATE Czech_CS_AS=b.id ';
    	 	cSQL:=cSQL +   'left join DefRollData st on ''3VBS22GA2LH4HCYLOVOGHT0YJG''=st.CLSID and sc.x_statistika COLLATE Czech_CS_AS=st.ID ';
    	 	cSQL:=cSQL +   'left join storeunits su on sc.id=su.parent_id and sc.mainunitcode=su.code ';
    	 	cSQL:=cSQL +   'left join bustransactions bt on sc.x_obchodni_pripad=bt.id ';
   	 	cSQL:=cSQL +   'left join USERDATA UD4 on 2000018=UD4.FIELDCODE AND ''C3V5QDVZ5BDL342M01C0CX3FCC''=UD4.CLSID AND sc.ID = UD4.ID) sc on r.storecard_id=sc.id ';
    	 	cSQL:=cSQL +   'left outer join (select rf.id,op.objedn from IssuedCreditNotes2 rf ';
    	 	cSQL:=cSQL +   'left outer join storedocuments2 sd2 on rf.providerow_id= sd2.id ';
    	 	cSQL:=cSQL +   ' left outer join (select a.id,r.code+''-''+ltrim(str(a.ordnumber))+''/''+p.code as objedn from receivedorders a ';
   	 	cSQL:=cSQL +   'left outer join docqueues r on a.DocQueue_ID=r.id left outer join periods p on a.Period_ID=p.id) op on sd2.provide_id= op.id ';

   	 	cSQL:=cSQL +   ' where rf.RowType = 3) _objedn on r.id=_objedn.id where r.rowtype=3 and h.VATdate$date between  ' + NxFloatToIBStr(mdatefrom) + ' and ' + NxFloatToIBStr(mdateto) ;




    OS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then begin
//      mList2.Add('Řádek;Zakázka;Karta;Název;Typ;Druh;Provedení;Barva;Velikost;Statistika;Stat.skupina;Kolekce;Sazebník;ks v bal.;Váha;Množství;mj;Poč.jednotek;bez DPH v měně;bez DPH v Kč;Č.faktury;VS;Typ dokl.;Datum;Rok;Měsíc;Kód fy.;IČO;Firma;Provozovna;Země;PSČ;Měna Fa;Kurs Fa;Obch.případ;Sklad;Čas šití(ks);Čas výroby(ks);Výr.ukončena;Popis (z fa);Evropa;Objednávka;Voucher;Kalk.doprava;Skupina;Typ skladové karty;Hl. dodavatel;Stát Hl.dod.;Sortiment;Head_ID;Row_ID;Projekt;Doprava;Platba;EAN; SDPH; sDPHvCZK; Email; Vazba_fa_FV; ID_objednavky;');
mList2.Add('Řádek;Zakázka;Karta;Název;Typ;Druh;Provedení;Barva;Velikost;Statistika;Stat.skupina;Kolekce;Sazebník;ks v bal.;Váha;Množství;mj;Poč.jednotek;bez DPH v měně;bez DPH v Kč;Č.faktury;VS;Typ dokl.;Datum;Rok;Měsíc;Kód fy.;IČO;Firma;Provozovna;Země;PSČ;Měna Fa;Kurs Fa;Obch.případ;Sklad;Čas šití(ks);Čas výroby(ks);Výr.ukončena;Popis (z fa);Evropa;Objednávka;Voucher;Kalk.doprava;Skupina;Typ skladové karty;Hl. dodavatel;Stát Hl.dod.;Sortiment;Head_ID;Row_ID;Projekt;Doprava;Platba;EAN; SDPH; sDPHvCZK; Email; Vazba_fa_FV; ID_objednavky');
      for i:=0 to mList.count-1 do begin
       mList2.add(mList.strings[i]);
      end;
      mlist2.SaveToFile(mFileName);
    end;
  finally
    mList.Free;
  end;
         mFTP:= TFTP.Create;
         mFTP.Host:='www.lipoelastic-medical-products.com.uvirt35.active24.cz';
         //mFTP.Port:=34000;
         mftp.UserName:='lipoelasti20';
         mFTP.Password:='iMO4Jxf9MI';
         mftp.Connect;
         mFTP.Passive:=true;
         mFTP.TransferType:=ftBinary;
         mFTP.ChangeDir('powerBI');
         mftp.Put(mFileName, 'Prodeje_powerBI.csv');
         mFTP.Free;

  Success := True;
  LogInfoStr := ''+NxGetTempDir;
end;




begin
end.