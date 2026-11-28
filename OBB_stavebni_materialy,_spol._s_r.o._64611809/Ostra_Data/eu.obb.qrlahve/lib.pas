
{GetAkce1}

function GetAkce1(AReportHelper:TNxQRScriptHelper;Invoice_ID:String):Extended;
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mGRows:TMultiGrid;
 i:integer;
 mValue:extended;
 mString:string;
 mPoSplatnosti:Extended;
 mList1, mlist2:TStringList;
 mBM: TNxBusinessMoniker;
begin
 mValue:=0;
 mPoSplatnosti:=0;
 mList1:=tstringlist.Create;
 mList2:=tstringlist.create;
 mBO := AReportHelper.ObjectSpace.CreateObject(Class_IssuedInvoice);
 mBM := nil;
     try

        mBM := mBO.CreateMoniker;
        mBM.Unbind;
      finally
        mbo.Free;
      end;
      mBM.BindToIdentity(Invoice_ID);
      mbo := mBM.BusinessObject;



 //mbo.Load(Invoice_ID,nil);
 mOS:=AReportHelper.ObjectSpace;
 if not(NxIsEmptyOID(mbo.GetFieldValueAsString('Firm_ID'))) then begin
   mos.SQLSelect(format('Select sum(II.localamount-ii.localpaidamount) from issuedinvoices ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) and ii.localpaidamount<ii.localamount and ii.duedate$date<%s ',[mbo.GetFieldValueAsString('Firm_ID'),mbo.GetFieldValueAsString('Firm_ID'),inttostr(trunc(date))]),mlist1);
   mos.SQLSelect(format('Select sum(II.localamount-ii.localpaidamount) from issuedcreditnotes ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s'')))  and ii.localpaidamount<ii.localamount and ii.duedate$date<%s ',[mbo.GetFieldValueAsString('Firm_ID'),mbo.GetFieldValueAsString('Firm_ID'),inttostr(30+trunc(date))]),mlist2);
   mPoSplatnosti:=Max_1((StrToFloat(mlist1.strings[0])-StrToFloat(mlist2.strings[0])),0);
 end;
 mRows:=mbo.GetloadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
 //mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
 for i:=0 to mrows.count-1 do begin

 if mRows.BusinessObject[i].GetFieldValueAsBoolean('StoreCard_ID.U_akce1') then
      mValue:=mValue+mrows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT');
  if mRows.BusinessObject[i].GetFieldValueAsBoolean('StoreCard_ID.U_Akce1spec') then
      mValue:=mValue+(2*mrows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT'));

  end;
  mString:=AnsiRightStr(AnsiLeftStr(mbo.GetFieldValueAsString('Firm_ID.K0'),4),1);
  {if mString=' ' then begin
    Result:=('Akce platí pouze pro realizační firmy. Pro tuto firmu nelze dárky přidávat. ');
    exit;
  end;}

  // je v OP
  {if (mValue>0)and(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO') then Result:=('Aktuální hodnota zboží v akci "dárky" v této OP je: '+FormatFloat('0,',1*mValue)+' Kč. Pokud nebude mít zákazník při fakturaci závazky po splatnosti, může získat dvojnásobek uvedené částky. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.');
    // má hodnotu a nic nedluží
  if (mValue>0) and (mPoSplatnosti=0)and not(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO')then result:=('Aktuální hodnota zboží v akci "dárky" v tomto dokladu je: '+FormatFloat('0,',2*mValue)+' Kč. ZÁKAZNÍK MÁ VŠE UHRAZENO VE SPLATNOSTI a proto BYLA odměna znásobena. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.');
  //má hodnotu a dluží
  if (mValue>0) and (mPoSplatnosti>0)and not(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO')then Result:=('Aktuální hodnota zboží v akci "dárky" v tomto dokladu je: '+FormatFloat('0,',mValue)+' Kč. ZÁKAZNÍK MÁ FAKTURY PO SPLATNOSTI, proto odměna NEBYLA násobena. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.');
  if mValue=0 then result:=('Doklad neobsahuje žádné zboží v akci "dárky".'); }
  Result:=mvalue;
end;

function GetAkce1splatnost(AReportHelper:TNxQRScriptHelper;Invoice_ID:String):Extended;
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mGRows:TMultiGrid;
 i:integer;
 mValue:extended;
 mString:string;
 mPoSplatnosti:Extended;
 mList1, mlist2:TStringList;
 mBM:TNxBusinessMoniker;
begin
 mValue:=0;
 mPoSplatnosti:=0;
 mList1:=tstringlist.Create;
 mList2:=tstringlist.create;
 mBO := AReportHelper.ObjectSpace.CreateObject(Class_IssuedInvoice);

 mBO.Load(Invoice_ID,nil);
 {mBM := nil;
     try

        mBM := mBO.CreateMoniker;
        mBM.Unbind;
      finally
        mbo.Free;
      end;
      mBM.BindToIdentity(Invoice_ID);
      mbo := mBM.BusinessObject;   }
 mOS:=AReportHelper.ObjectSpace;
 if not(NxIsEmptyOID(mbo.GetFieldValueAsString('Firm_ID'))) then begin
   mos.SQLSelect(format('Select sum(II.localamount-ii.localpaidamount) from issuedinvoices ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) and ii.localpaidamount<ii.localamount and ii.duedate$date<%s ',[mbo.GetFieldValueAsString('Firm_ID'),mbo.GetFieldValueAsString('Firm_ID'),inttostr(trunc(date))]),mlist1);
   mos.SQLSelect(format('Select sum(II.localamount-ii.localpaidamount) from issuedcreditnotes ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s'')))  and ii.localpaidamount<ii.localamount and ii.duedate$date<%s ',[mbo.GetFieldValueAsString('Firm_ID'),mbo.GetFieldValueAsString('Firm_ID'),inttostr(30+trunc(date))]),mlist2);
   mPoSplatnosti:=Max_1((StrToFloat(mlist1.strings[0])-StrToFloat(mlist2.strings[0])),0);
 end;
 mRows:=mbo.GetloadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
 //mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
 for i:=0 to mrows.count-1 do begin

 if mRows.BusinessObject[i].GetFieldValueAsBoolean('StoreCard_ID.U_akce1') then
      mValue:=mValue+mrows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT');
  if mRows.BusinessObject[i].GetFieldValueAsBoolean('StoreCard_ID.U_Akce1spec') then
      mValue:=mValue+(2*mrows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT'));

  end;
  mString:=AnsiRightStr(AnsiLeftStr(mbo.GetFieldValueAsString('Firm_ID.K0'),4),1);
  {if mString=' ' then begin
    Result:=('Akce platí pouze pro realizační firmy. Pro tuto firmu nelze dárky přidávat. ');
    exit;
  end;}

  // je v OP
  {if (mValue>0)and(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO') then Result:=('Aktuální hodnota zboží v akci "dárky" v této OP je: '+FormatFloat('0,',1*mValue)+' Kč. Pokud nebude mít zákazník při fakturaci závazky po splatnosti, může získat dvojnásobek uvedené částky. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.');
    // má hodnotu a nic nedluží
  if (mValue>0) and (mPoSplatnosti=0)and not(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO')then result:=('Aktuální hodnota zboží v akci "dárky" v tomto dokladu je: '+FormatFloat('0,',2*mValue)+' Kč. ZÁKAZNÍK MÁ VŠE UHRAZENO VE SPLATNOSTI a proto BYLA odměna znásobena. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.');
  //má hodnotu a dluží
  if (mValue>0) and (mPoSplatnosti>0)and not(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO')then Result:=('Aktuální hodnota zboží v akci "dárky" v tomto dokladu je: '+FormatFloat('0,',mValue)+' Kč. ZÁKAZNÍK MÁ FAKTURY PO SPLATNOSTI, proto odměna NEBYLA násobena. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.');
  if mValue=0 then result:=('Doklad neobsahuje žádné zboží v akci "dárky".'); }
  if mPoSplatnosti=0 then Result:=2*mvalue else
  Result:=mvalue;
  mBO.free;
end;


function GetAkce1splatnostTESTPoSplaFA(AReportHelper:TNxQRScriptHelper;Invoice_ID:String):Extended;
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mGRows:TMultiGrid;
 i:integer;
 mValue:extended;
 mString:string;
 mPoSplatnosti:Extended;
 mList1, mlist2:TStringList;
 mBM:TNxBusinessMoniker;
begin
 mValue:=0;
 mPoSplatnosti:=0;
 mList1:=tstringlist.Create;
 mList2:=tstringlist.create;
 mBO := AReportHelper.ObjectSpace.CreateObject(Class_IssuedInvoice);

 mBO.Load(Invoice_ID,nil);
 {mBM := nil;
     try

        mBM := mBO.CreateMoniker;
        mBM.Unbind;
      finally
        mbo.Free;
      end;
      mBM.BindToIdentity(Invoice_ID);
      mbo := mBM.BusinessObject;   }
 mOS:=AReportHelper.ObjectSpace;
 if not(NxIsEmptyOID(mbo.GetFieldValueAsString('Firm_ID'))) then begin
   mos.SQLSelect(format('Select sum(II.localamount-ii.localpaidamount) from issuedinvoices ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) and ii.localpaidamount<ii.localamount and ii.duedate$date<%s ',[mbo.GetFieldValueAsString('Firm_ID'),mbo.GetFieldValueAsString('Firm_ID'),inttostr(trunc(date))]),mlist1);
   mos.SQLSelect(format('Select sum(II.localamount-ii.localpaidamount) from issuedcreditnotes ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s'')))  and ii.localpaidamount<ii.localamount and ii.duedate$date<%s ',[mbo.GetFieldValueAsString('Firm_ID'),mbo.GetFieldValueAsString('Firm_ID'),inttostr(30+trunc(date))]),mlist2);
   mPoSplatnosti:=Max_1((StrToFloat(mlist1.strings[0])-StrToFloat(mlist2.strings[0])),0);
 end;
 mRows:=mbo.GetloadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
 //mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
 for i:=0 to mrows.count-1 do begin

 if mRows.BusinessObject[i].GetFieldValueAsBoolean('StoreCard_ID.U_akce1') then
      mValue:=mValue+mrows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT');
  if mRows.BusinessObject[i].GetFieldValueAsBoolean('StoreCard_ID.U_Akce1spec') then
      mValue:=mValue+(2*mrows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT'));

  end;
  mString:=AnsiRightStr(AnsiLeftStr(mbo.GetFieldValueAsString('Firm_ID.K0'),4),1);
  {if mString=' ' then begin
    Result:=('Akce platí pouze pro realizační firmy. Pro tuto firmu nelze dárky přidávat. ');
    exit;
  end;}

  // je v OP
  {if (mValue>0)and(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO') then Result:=('Aktuální hodnota zboží v akci "dárky" v této OP je: '+FormatFloat('0,',1*mValue)+' Kč. Pokud nebude mít zákazník při fakturaci závazky po splatnosti, může získat dvojnásobek uvedené částky. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.');
    // má hodnotu a nic nedluží
  if (mValue>0) and (mPoSplatnosti=0)and not(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO')then result:=('Aktuální hodnota zboží v akci "dárky" v tomto dokladu je: '+FormatFloat('0,',2*mValue)+' Kč. ZÁKAZNÍK MÁ VŠE UHRAZENO VE SPLATNOSTI a proto BYLA odměna znásobena. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.');
  //má hodnotu a dluží
  if (mValue>0) and (mPoSplatnosti>0)and not(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO')then Result:=('Aktuální hodnota zboží v akci "dárky" v tomto dokladu je: '+FormatFloat('0,',mValue)+' Kč. ZÁKAZNÍK MÁ FAKTURY PO SPLATNOSTI, proto odměna NEBYLA násobena. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.');
  if mValue=0 then result:=('Doklad neobsahuje žádné zboží v akci "dárky".'); }
  //if mPoSplatnosti=0 then Result:=2*mvalue else
  Result:=StrToFloat(mlist1.strings[0]);
  mBO.free;
end;

function GetAkce1splatnostTESTPoSplaDobro(AReportHelper:TNxQRScriptHelper;Invoice_ID:String):Extended;
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mGRows:TMultiGrid;
 i:integer;
 mValue:extended;
 mString:string;
 mPoSplatnosti:Extended;
 mList1, mlist2:TStringList;
 mBM:TNxBusinessMoniker;
begin
 mValue:=0;
 mPoSplatnosti:=0;
 mList1:=tstringlist.Create;
 mList2:=tstringlist.create;
 mBO := AReportHelper.ObjectSpace.CreateObject(Class_IssuedInvoice);

 mBO.Load(Invoice_ID,nil);
 {mBM := nil;
     try

        mBM := mBO.CreateMoniker;
        mBM.Unbind;
      finally
        mbo.Free;
      end;
      mBM.BindToIdentity(Invoice_ID);
      mbo := mBM.BusinessObject;   }
 mOS:=AReportHelper.ObjectSpace;
 if not(NxIsEmptyOID(mbo.GetFieldValueAsString('Firm_ID'))) then begin
   mos.SQLSelect(format('Select sum(II.localamount-ii.localpaidamount) from issuedinvoices ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) and ii.localpaidamount<ii.localamount and ii.duedate$date<%s ',[mbo.GetFieldValueAsString('Firm_ID'),mbo.GetFieldValueAsString('Firm_ID'),inttostr(trunc(date))]),mlist1);
   mos.SQLSelect(format('Select sum(II.localamount-ii.localpaidamount) from issuedcreditnotes ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s'')))  and ii.localpaidamount<ii.localamount and ii.duedate$date<%s ',[mbo.GetFieldValueAsString('Firm_ID'),mbo.GetFieldValueAsString('Firm_ID'),inttostr(30+trunc(date))]),mlist2);
   mPoSplatnosti:=Max_1((StrToFloat(mlist1.strings[0])-StrToFloat(mlist2.strings[0])),0);
 end;
 mRows:=mbo.GetloadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
 //mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
 for i:=0 to mrows.count-1 do begin

 if mRows.BusinessObject[i].GetFieldValueAsBoolean('StoreCard_ID.U_akce1') then
      mValue:=mValue+mrows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT');
  if mRows.BusinessObject[i].GetFieldValueAsBoolean('StoreCard_ID.U_Akce1spec') then
      mValue:=mValue+(2*mrows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT'));

  end;
  mString:=AnsiRightStr(AnsiLeftStr(mbo.GetFieldValueAsString('Firm_ID.K0'),4),1);
  {if mString=' ' then begin
    Result:=('Akce platí pouze pro realizační firmy. Pro tuto firmu nelze dárky přidávat. ');
    exit;
  end;}

  // je v OP
  {if (mValue>0)and(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO') then Result:=('Aktuální hodnota zboží v akci "dárky" v této OP je: '+FormatFloat('0,',1*mValue)+' Kč. Pokud nebude mít zákazník při fakturaci závazky po splatnosti, může získat dvojnásobek uvedené částky. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.');
    // má hodnotu a nic nedluží
  if (mValue>0) and (mPoSplatnosti=0)and not(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO')then result:=('Aktuální hodnota zboží v akci "dárky" v tomto dokladu je: '+FormatFloat('0,',2*mValue)+' Kč. ZÁKAZNÍK MÁ VŠE UHRAZENO VE SPLATNOSTI a proto BYLA odměna znásobena. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.');
  //má hodnotu a dluží
  if (mValue>0) and (mPoSplatnosti>0)and not(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO')then Result:=('Aktuální hodnota zboží v akci "dárky" v tomto dokladu je: '+FormatFloat('0,',mValue)+' Kč. ZÁKAZNÍK MÁ FAKTURY PO SPLATNOSTI, proto odměna NEBYLA násobena. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.');
  if mValue=0 then result:=('Doklad neobsahuje žádné zboží v akci "dárky".'); }
  //if mPoSplatnosti=0 then Result:=2*mvalue else
  Result:=StrToFloat(mlist2.strings[0]);
  mBO.free;
end;

function GetAkce1splatnostTESTAkce(AReportHelper:TNxQRScriptHelper;Invoice_ID:String):Extended;
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mGRows:TMultiGrid;
 i:integer;
 mValue:extended;
 mString:string;
 mPoSplatnosti:Extended;
 mList1, mlist2:TStringList;
 mBM:TNxBusinessMoniker;
begin
 mValue:=0;
 mPoSplatnosti:=0;
 mList1:=tstringlist.Create;
 mList2:=tstringlist.create;
 mBO := AReportHelper.ObjectSpace.CreateObject(Class_IssuedInvoice);

 mBO.Load(Invoice_ID,nil);
 {mBM := nil;
     try

        mBM := mBO.CreateMoniker;
        mBM.Unbind;
      finally
        mbo.Free;
      end;
      mBM.BindToIdentity(Invoice_ID);
      mbo := mBM.BusinessObject;   }
 mOS:=AReportHelper.ObjectSpace;
 if not(NxIsEmptyOID(mbo.GetFieldValueAsString('Firm_ID'))) then begin
   mos.SQLSelect(format('Select sum(II.localamount-ii.localpaidamount) from issuedinvoices ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) and ii.localpaidamount<ii.localamount and ii.duedate$date<%s ',[mbo.GetFieldValueAsString('Firm_ID'),mbo.GetFieldValueAsString('Firm_ID'),inttostr(trunc(date))]),mlist1);
   mos.SQLSelect(format('Select sum(II.localamount-ii.localpaidamount) from issuedcreditnotes ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s'')))  and ii.localpaidamount<ii.localamount and ii.duedate$date<%s ',[mbo.GetFieldValueAsString('Firm_ID'),mbo.GetFieldValueAsString('Firm_ID'),inttostr(30+trunc(date))]),mlist2);
   mPoSplatnosti:=Max_1((StrToFloat(mlist1.strings[0])-StrToFloat(mlist2.strings[0])),0);
 end;
 mRows:=mbo.GetloadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
 //mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
 for i:=0 to mrows.count-1 do begin

 if mRows.BusinessObject[i].GetFieldValueAsBoolean('StoreCard_ID.U_akce1') then
      mValue:=mValue+mrows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT');
  if mRows.BusinessObject[i].GetFieldValueAsBoolean('StoreCard_ID.U_Akce1spec') then
      mValue:=mValue+(2*mrows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT'));

  end;
  mString:=AnsiRightStr(AnsiLeftStr(mbo.GetFieldValueAsString('Firm_ID.K0'),4),1);
  {if mString=' ' then begin
    Result:=('Akce platí pouze pro realizační firmy. Pro tuto firmu nelze dárky přidávat. ');
    exit;
  end;}

  // je v OP
  {if (mValue>0)and(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO') then Result:=('Aktuální hodnota zboží v akci "dárky" v této OP je: '+FormatFloat('0,',1*mValue)+' Kč. Pokud nebude mít zákazník při fakturaci závazky po splatnosti, může získat dvojnásobek uvedené částky. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.');
    // má hodnotu a nic nedluží
  if (mValue>0) and (mPoSplatnosti=0)and not(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO')then result:=('Aktuální hodnota zboží v akci "dárky" v tomto dokladu je: '+FormatFloat('0,',2*mValue)+' Kč. ZÁKAZNÍK MÁ VŠE UHRAZENO VE SPLATNOSTI a proto BYLA odměna znásobena. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.');
  //má hodnotu a dluží
  if (mValue>0) and (mPoSplatnosti>0)and not(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO')then Result:=('Aktuální hodnota zboží v akci "dárky" v tomto dokladu je: '+FormatFloat('0,',mValue)+' Kč. ZÁKAZNÍK MÁ FAKTURY PO SPLATNOSTI, proto odměna NEBYLA násobena. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.');
  if mValue=0 then result:=('Doklad neobsahuje žádné zboží v akci "dárky".'); }
  //if mPoSplatnosti=0 then Result:=2*mvalue else
  Result:=mValue;
  mBO.free;
end;



function GetPromotionValue(AReportHelper:TNxQRScriptHelper;Invoice_ID:String):Extended;
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mGRows:TMultiGrid;
 i:integer;
 mValue:extended;
 mString:string;
 mPoSplatnosti:Extended;
 mList1, mlist2:TStringList;
 mBM:TNxBusinessMoniker;
begin
 mValue:=0;
 mPoSplatnosti:=0;
 mList1:=tstringlist.Create;
 mList2:=tstringlist.create;
 mBO := AReportHelper.ObjectSpace.CreateObject(Class_IssuedInvoice);

 mBO.Load(Invoice_ID,nil);
 {mBM := nil;
     try

        mBM := mBO.CreateMoniker;
        mBM.Unbind;
      finally
        mbo.Free;
      end;
      mBM.BindToIdentity(Invoice_ID);
      mbo := mBM.BusinessObject;   }
 mOS:=AReportHelper.ObjectSpace;

 mRows:=mbo.GetloadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
 //mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
 for i:=0 to mrows.count-1 do begin
  if mrows.BusinessObject[i].GetFieldValueAsInteger('RowType')=3 then begin
     if mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')='2840000101' then
          mValue:=mValue+(mrows.BusinessObject[i].GetFieldValueAsFloat('Quantity')*mrows.BusinessObject[i].GetFieldValueAsFloat('StoreCard_ID.U_PromotionValue'));
  end;
 end;
  {if mString=' ' then begin
    Result:=('Akce platí pouze pro realizační firmy. Pro tuto firmu nelze dárky přidávat. ');
    exit;
  end;}

  // je v OP
  {if (mValue>0)and(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO') then Result:=('Aktuální hodnota zboží v akci "dárky" v této OP je: '+FormatFloat('0,',1*mValue)+' Kč. Pokud nebude mít zákazník při fakturaci závazky po splatnosti, může získat dvojnásobek uvedené částky. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.');
    // má hodnotu a nic nedluží
  if (mValue>0) and (mPoSplatnosti=0)and not(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO')then result:=('Aktuální hodnota zboží v akci "dárky" v tomto dokladu je: '+FormatFloat('0,',2*mValue)+' Kč. ZÁKAZNÍK MÁ VŠE UHRAZENO VE SPLATNOSTI a proto BYLA odměna znásobena. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.');
  //má hodnotu a dluží
  if (mValue>0) and (mPoSplatnosti>0)and not(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO')then Result:=('Aktuální hodnota zboží v akci "dárky" v tomto dokladu je: '+FormatFloat('0,',mValue)+' Kč. ZÁKAZNÍK MÁ FAKTURY PO SPLATNOSTI, proto odměna NEBYLA násobena. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.');
  if mValue=0 then result:=('Doklad neobsahuje žádné zboží v akci "dárky".'); }
  //if mPoSplatnosti=0 then Result:=2*mvalue else
  Result:=mvalue;
end;

begin
end.