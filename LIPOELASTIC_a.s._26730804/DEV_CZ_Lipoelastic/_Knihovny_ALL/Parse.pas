

function ID_from_GS_DecodeDatamatrix(os:TNxCustomObjectSpace;gs01:string;gs10:string;mquantity:double):string;
var
    mr:tstringlist;
    mStoreBatch_ID,mStorecard_ID:string;
begin
//  mStoreBatch_ID:='0000000000';
//  mStorecard_ID:='0000000000';
  mStoreBatch_ID:='';
  mStorecard_ID:='';

           if gs10<>'' then begin
                 mr:=tstringlist.create;
                        try
                              os.SQLSelect('select SB.id,SB.Storecard_ID from StoreBatches SB join StoreCards SC on sc.id=SB.Storecard_ID where SB.Name=' + quotedstr(gs10) + ' and sb.hidden=' + quotedstr('N')
                                           + ' and SC.EAN=' + QuotedStr(gs01),mr);
                              if mr.count>0 then begin
                                  mStoreBatch_ID:=copy(mr.strings[0],1,10);
                                  mStorecard_ID:=copy(mr.strings[0],12,10);
                                  if mQuantity=0 then mQuantity:= 1;
                              end else begin
                                  mQuantity:= 0;
                              end;
                        finally
                            mr.free;
                        end;
           end;


           if ((gs01<>'') and (mStoreBatch_ID='')) then begin
                     mr:=tstringlist.create;
                        try
                              os.SQLSelect('select Sc.id from StoreCards SC where SC.EAN=' + quotedstr(gs01) + ' and sc.hidden=' + quotedstr('N'),mr);
                              if mr.count>0 then begin
                                  mStoreBatch_ID:='';
                                  mStorecard_ID:=mr.strings[0];
                                  mQuantity:= 1;
                              end else begin
                                  mStoreBatch_ID:='';
                                  mStorecard_ID:='';
                                  mQuantity:= 1;
                              end;
                        finally
                            mr.free;
                        end;
           end;


   result:=mStoreBatch_ID+';'+mStorecard_ID+';'+NxFloatToIBStr(mquantity);


end;


















function GS_DecodeDatamatrix(os:TNxCustomObjectSpace;mDatamatrix:string):string;
var
  mStorecard_ID:string;
  mStoreBatch_ID:string;
  mVerze:string;
  mQuantity:string;
  mr,mFieldValue:TStringList;
  mNameBatch:string;
  GS01,GS10,GS17:string;
  mStart,mEnd:integer;
  mHelpString:string;
  msbody:string;
  mbo:TNxCustomBusinessObject;
begin
GS01:='';
GS10:='';
GS17:='';

mStorecard_ID:='';
mStoreBatch_ID:='';
mVerze:='';
mQuantity:='1';


 mdatamatrix:=NxSearchReplace(mdatamatrix,'"','',[srCase,srAll]);


if copy(mdatamatrix,1,1)='*' then begin
      mdatamatrix:=NxSearchReplace(mdatamatrix,'*','',[srCase,srAll]);

end;
mdatamatrix:=NxSearchReplace(mdatamatrix,'(','',[srCase,srAll]);
      mdatamatrix:=NxSearchReplace(mdatamatrix,')','',[srCase,srAll]);

mdatamatrix:=NxSearchReplace(mdatamatrix,'&A','',[srCase,srAll]);
      mdatamatrix:=NxSearchReplace(mdatamatrix,'&B','',[srCase,srAll]);
      mdatamatrix:=NxSearchReplace(mdatamatrix,'&C','',[srCase,srAll]);
      mdatamatrix:=NxSearchReplace(mdatamatrix,'&D','',[srCase,srAll]);
      mdatamatrix:=NxSearchReplace(mdatamatrix,'&E','',[srCase,srAll]);

//mdatamatrix:=NxSearchReplace(mdatamatrix,'(','',[srCase,srAll]);
//mdatamatrix:=NxSearchReplace(mdatamatrix,')','',[srCase,srAll]);


//NxShowSimpleMessage(mdatamatrix,nil);

//Korektní datamatrix GS1 s závormama "()"
  if GS01='' then begin
    if ((Pos('(', mDatamatrix)<>0) and (Pos(')', mDatamatrix)<>0)) then begin
      // *****
      if (Pos('(01)0', mDatamatrix)<>0) then begin
          mHelpString:=copy(mDatamatrix,(Pos('(01)0', mDatamatrix) +5) ,Length(mDatamatrix));
          mEnd:=(Pos('(', mHelpString));
          if mEnd=0 then mEnd:= Length(mHelpString)+1;
          mHelpString:=copy(mHelpString,1,mEnd-1);
          gs01:=mHelpString;
      end;
      // ******
      if (Pos('(10)', mDatamatrix)<>0) then begin
          mHelpString:=copy(mDatamatrix,(Pos('(10)', mDatamatrix) +4) ,Length(mDatamatrix));
          mEnd:=(Pos('(', mHelpString));
          if mEnd=0 then mEnd:= Length(mHelpString)+1;
          mHelpString:=copy(mHelpString,1,mEnd-1);
          gs10:=mHelpString;
      end;
      // *****
      if (Pos('(17)', mDatamatrix)<>0) then begin
          mHelpString:=copy(mDatamatrix,(Pos('(17)', mDatamatrix) +4) ,Length(mDatamatrix));
          mEnd:=(Pos('(', mHelpString));
          if mEnd=0 then mEnd:= Length(mHelpString)+1;
          mHelpString:=copy(mHelpString,1,mEnd-1);
          gs17:=mHelpString;
      end;

    end;
  end;

  // ****    nové čtečky MAC OS
  if GS01='' then begin
    if ((Pos('*', mDatamatrix)<>0) and (Pos('(', mDatamatrix)<>0)) then begin
      // *****
      if (Pos('*01(0', mDatamatrix)<>0) then begin
          mHelpString:=copy(mDatamatrix,(Pos('*01(0', mDatamatrix) +5) ,Length(mDatamatrix));
          mEnd:=(Pos('*', mHelpString));
          if mEnd=0 then mEnd:= Length(mHelpString)+1;
          mHelpString:=copy(mHelpString,1,mEnd-1);
          gs01:=mHelpString;
      end;
      // ******
      if (Pos('*10(', mDatamatrix)<>0) then begin
          mHelpString:=copy(mDatamatrix,(Pos('*10(', mDatamatrix) +4) ,Length(mDatamatrix));
          mEnd:=(Pos('*', mHelpString));
          if mEnd=0 then mEnd:= Length(mHelpString)+1;
          mHelpString:=copy(mHelpString,1,mEnd-1);
          gs10:=mHelpString;
      end;
      // *****
      if (Pos('*17(', mDatamatrix)<>0) then begin
          mHelpString:=copy(mDatamatrix,(Pos('*17(', mDatamatrix) +4) ,Length(mDatamatrix));
          mEnd:=(Pos('*', mHelpString));
          if mEnd=0 then mEnd:= Length(mHelpString)+1;
          mHelpString:=copy(mHelpString,1,mEnd-1);
          gs17:=mHelpString;
      end;

    end;
  end;

  // ****    nové čtečky MAC OS - lipo
  if GS01='' then begin
    if (copy(mDatamatrix,1,4)='LIPO') and (Pos('<', mDatamatrix)<>0) then begin
      // *****



      if (Pos('<', mDatamatrix)<>0) then begin
          mHelpString:=copy(mDatamatrix,(Pos('<', mDatamatrix) +1) ,Length(mDatamatrix));
          mEnd:=(Pos('<', mHelpString));
          if mEnd=0 then mEnd:= Length(mHelpString)+1;
          mHelpString:=copy(mHelpString,1,mEnd-1);
          gs10:=mHelpString;
          //NxShowSimpleMessage(gs10,nil);
          gs01:=os.SQLSelectFirstAsString('select sc.EAN from StoreBatches SB join storecards SC on SC.id=SB.StoreCard_ID where sb.Name=' + quotedstr(gs10));
          //NxShowSimpleMessage(gs01,nil);
      end;


      // *****
      if (Pos('<', mDatamatrix)<>0) then begin
          mHelpString:=copy(mDatamatrix,(Pos('<', mDatamatrix) +1) ,Length(mHelpString));
          mEnd:=(Pos('*', mHelpString));
          if mEnd=0 then mEnd:= Length(mHelpString)+1;
          mHelpString:=copy(mHelpString,1,mEnd-1);
          gs17:=mHelpString;
      end;

    end;
  end;












// ***** odstranění závorek
if GS01='' then begin
    mdatamatrix:=NxSearchReplace(mdatamatrix,'"','',[srCase,srAll]);
    mdatamatrix:=NxSearchReplace(mdatamatrix,'(','',[srCase,srAll]);
    mdatamatrix:=NxSearchReplace(mdatamatrix,')','',[srCase,srAll]);
end;

  // náš qr code - LIPO-PI99V00X-W-3XL;932712206001;20270630;2027-06
  if GS01='' then begin
    if Pos(';', mDatamatrix)<>0 then begin
      if copy(mDatamatrix,1,5)='LIPO-' then begin

          mFieldValue:=TStringList.create;
               try
                    Parsevalue(mDatamatrix,';',mDatamatrix,mFieldValue,3);

                   if mFieldValue.count>1 then begin
                        gs01:=os.SQLSelectFirstAsString('select EAN from StoreCards where Specification2='+ QuotedStr(mfieldValue.strings[0]) + ' and hidden=' +quotedstr('N')) ;
                        gs10:=mfieldValue.strings[1] ;
                        gs17:='';
                   end;
                finally
                end;
      end;
    end;
  end;

   //  nový kód Teoxane - 010764017323110310194625B0~1721113021194625B01433
  if GS01='' then begin
      if (copy(mdatamatrix,1,5)='01076') AND (Pos('17', mDatamatrix)<>0) then begin
                        gs01:=copy(mdatamatrix,4,13) ;
                        gs10:=copy(mdatamatrix,19,8) ;
                        gs17:='';
      end;

  end;


  {Načtený řetězec obsahuje znaky „~17“ a „~11“ a zároveň začíná na "010859184" nebo "010222000" (naše EANy). Jedná se o náš nový DataMatrix kód
01----EAN-------10-LOT na 15 zn.-/V17RRMMDD
010859184620012610020012190300001/_17220520
Specifikum je v tom, že šarže je na 15 znaků doplněna nulami zleva. Systém po načtení kódu nuly ořeže. Když je však výsledná šarže kratší než 12 znaků, nuly doplní, aby šarže měla minimálně 12 znaků.
}


if GS01='' then begin
    if ((copy(mdatamatrix,1,9)='010859184') or (copy(mdatamatrix,1,9)='010222000')) and
       ((copy(mdatamatrix,(Length(mdatamatrix)-7),2)='17') or (copy(mdatamatrix,(Length(mdatamatrix)-8),2)='17'))
    then begin
           gs10:=copy(mdatamatrix,19,15);
           //NxShowSimpleMessage(copy(mdatamatrix,19,15),nil);
           gs10:=Trim(NxFloatToIBStr(NxIBStrToFloat(gs10)));
           if Length(gs10)<12 then begin
                 gs10:='0000000000000' +gs10;
                 gs10:=RightStr(gs10,12);
           end;
           gs01:=copy(mdatamatrix,4,13) ;
    end;
end;


{Načtený řetězec obsahuje znaky „~17“ a nevyhovuje předchozím pravidlům
Jedná se o kód používaný na produktech Teoxane
010060640114707010231582~17230630212315820001
}
 if GS01='' then begin
    if (Pos('~17', mDatamatrix)<>0) then begin
       GS10:=copy(mdatamatrix,24,15);
       gs01:=copy(mdatamatrix,4,13) ;
    end;
end;

{
Načtený kód obsahuje ".-"
Kód používaný u ostatní kosmetiky
801500.-W282G243-147057
}
  if GS01='' then begin
    if (Pos('.-', mDatamatrix)<>0) then begin
        GS10:=copy(mdatamatrix,9,15);
        gs01:=copy(mdatamatrix,4,13) ;
    end;
end;

{Načtený kód obsahuje dvě pomlčky a neobsahuje text „LIPOLINE“
 Jedná se o kódy označující implantáty
 TMM2350-Z090F042-177026 }
 if GS01='' then begin
    if (Pos('-', mDatamatrix)<>0) and (Pos('LIPOLINE', mDatamatrix)=0) then begin
       GS10:=copy(mdatamatrix,9,15);
       gs01:='.'
    end;
end;

{Délka načteného řetězce je větší než 45 znaků a na 44 pozici je „240“ Jedná se o náš starý DataMatrix XX--EAN---------XX---šarže-------XXDat.exp-XXX—Katalogové č.----
0108591846544329100544321906000021723062022240LIPO-MH01C00C-B-XL}
 if GS01='' then begin
    if (Length(mDatamatrix)>45) and (copy(mDatamatrix,44,3)='240') then begin
      gs10:=copy(mdatamatrix,18,15);
      gs01:=copy(mdatamatrix,4,13) ;
    end;
end;

{Načtený kód je na 41 znaků a na 34 pozici je „17“ Jedná se o náš aktuální DataMatrix XX--------------XX---------------XX------   0----EAN------  -LOT na 15 zn.-  RRMMDD
01085918469175431000091754201000117251015}
 if GS01='' then begin
    if (Length(mDatamatrix)=41) and (copy(mDatamatrix,34,2)='17') then begin
        gs10:= NxFloatToIBStr(NxIBStrToFloat(copy(mdatamatrix,19,15)));
        gs01:=copy(mdatamatrix,4,13) ;
    end;
end;

{Načtený kód je na 41 znaků a na 34 pozici je „11“ Jedná se o Náš DataMatrix - Lipoline (má datum produkce, ne expirace)--- XX--------------XX---------------XX------   0----EAN------  -LOT na 15 zn.-  RRMMDD
01085918469175431000091754201000111251015}
 if GS01='' then begin
    if (Length(mDatamatrix)=41) and (copy(mDatamatrix,34,2)='11') then begin
        gs10:= NxFloatToIBStr(NxIBStrToFloat(copy(mdatamatrix,19,15)));
        gs01:=copy(mdatamatrix,4,13) ;
    end;
end;

{Načtený kód je na 44 znaků a na 42 pozici je „37“ Jedná se o náš DataMatrix na výrobním štítku XX--------------XX---------------XX------XX--   0----EAN------10-LOT na 15 zn.-17RRMMDD  Počet kusů
010859184674212110000742122108007172608273730}
 if GS01='' then begin
    if (Length(mDatamatrix)>=44) and (Length(mDatamatrix)<48) and (copy(mDatamatrix,42,2)='37') then begin
        gs10:= NxFloatToIBStr(NxIBStrToFloat(copy(mdatamatrix,19,15)));
        gs01:=copy(mdatamatrix,4,13) ;
    end;
end;

{- Nově přidáno i číslo objednávky a poč.kusů rozšířen n 4 místa 010----EAN------10-LOT na 15 zn.-17RRMMDD37Poč.99-Objednávka--
0108591846924831100009248322070061727080937001099OV2-4120/2022}
  if GS01='' then begin
    if (Length(mDatamatrix)>47) and (copy(mDatamatrix,42,2)='37') then begin
        gs10:= NxFloatToIBStr(NxIBStrToFloat(copy(mdatamatrix,19,15)));
        gs01:=copy(mdatamatrix,4,13) ;
    end;
end;

{Načtený kód je delší než 42 znaků a začíná na „01“  Jedná se o kód na produktech Nagor 01---Ean -------10----šarže -----21—výr.číslo
01037004697171491030015791722123121AA004M1127}
 if GS01='' then begin
    if (Length(mDatamatrix)>42) and (copy(mDatamatrix,1,2)='01') and (copy(mDatamatrix,17,2)='10') and (copy(mDatamatrix,34,2)='21')then begin
          gs10:=trim(copy(mdatamatrix,36,15));
          gs01:=copy(mdatamatrix,4,13) ;
    end;
end;

{ Kód na začátku má „01“ a od čtvrté pozice 6 znaků je „426017“ Jedná se o produkty HumanMed - BodyJet . Mají dvě délky kódů. 01-----EAN------11-Vyr.-17-exp--10-šarže--
011426017088147911220509172509051000934306}
 if GS01='' then begin
    if (copy(mDatamatrix,1,3)='011') and (copy(mDatamatrix,4,6)='426017') then begin
         GS10:=NxFloatToIBStr(NxIBStrToFloat(copy(mdatamatrix,33,8)));
         gs01:=copy(mdatamatrix,3,14) ;
    end;
end;

{Nebo01--------------11------10------
01042601708812361122041210921346}
 if GS01='' then begin
    if (copy(mDatamatrix,1,2)='01') and (copy(mDatamatrix,4,6)='426017') then begin
         GS10:=copy(mdatamatrix,26,6);
         gs01:=copy(mdatamatrix,4,13) ;
    end;
end;


  if GS01='' then begin
    if ((Length(Trim(mdatamatrix))>25) and (Length(Trim(mdatamatrix))<40)) then begin //    01040262754455261728081510EK231016
              if (copy(mdatamatrix,1,3)='010') AND (copy(mdatamatrix,17,2)='17') AND (copy(mdatamatrix,25,2)='10') then begin
                                  GS10:=trim(copy(mdatamatrix,27,50));
                                  gs01:=copy(mdatamatrix,4,13) ;
              end;
    end;
end;


if GS01='' then begin
       if NxCharPos(';',trim(mdatamatrix))>0 then begin
              mFieldValue:=TStringList.create;
              try
                   mFieldValue:= fnParsevalue(mdatamatrix,';');
                   GS10:=mFieldValue.Strings[1];
                   GS01:=mFieldValue.Strings[0];
            finally
                mfieldValue.free;
            end;
       end;
end;


if GS01='' then begin

   if copy(mdatamatrix,1,3)='MAT' then begin
                        mr:=tstringlist.create;
                        try
                                os.SQLSelect('select SC.EAN,sb.Name from StoreBatches sb join Storecards SC on sc.id= sb.StoreCard_ID where sb.Name=' + quotedstr(trim(mDatamatrix)),mr);
                                if mr.count>0 then begin
                                      mFieldValue:=TStringList.create;
                                      try
                                           mFieldValue:= fnParsevalue(mr.Strings[0],';');
                                            GS10:=mFieldValue.Strings[1];
                                            GS01:=mFieldValue.Strings[0];
                                      finally
                                         mFieldValue
                                      end;
                                end;
                        finally
                            mr.free;
                        end;
    end;
end;












  if GS01='' then begin

                   GS10:=(copy(mdatamatrix,19,15));
                   GS10:=NxFloatToIBStr(NxIBStrToFloat(GS10));
                   gs01:=copy(mdatamatrix,4,13) ;

  end;












{Pokud načtený řetězec nevyhovuje ani jedné podmínce, je považován pouze za šarži}
  if GS01='' then begin
         GS10:=NxSearchReplace(mdatamatrix,'"','',[srCase,srAll]);
         GS10:=NxSearchReplace(GS10,';','',[srCase,srAll]);
         GS10:=NxSearchReplace(GS10,' ','',[srCase,srAll]);
         GS10:=trim(GS10);
   end;
     //NxShowSimpleMessage(mStoreBatch_ID + ';' + mStorecard_ID + ';' + mQuantity,nil);


   result:= gs10+ ';' + gs01 + ';' + GS17 + ';' + '1';

end;
















  procedure Parsevalue(const ADescription : string; const ASeparator: string; const AData : string; AHead:TStringList;sloupcu:integer);
// rozdělení hodnot pro import
var
    mStr, mToken : string;
    mPos, i : integer;
begin
    mStr := AData;
    try
        for i := 0 to sloupcu - 1 do begin
            mPos := AnsiPos(ASeparator, mStr);
            if mPos = 0 then mPos := Length(mStr) + 1;
                AHead.Add(NxLeft(mStr, mPos - 1));
                mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);
        end;
        if Length(trim(mStr))>0 then AHead.Add(mstr) ;
   finally
  end;
end;


function DecodeBatches(os:TNxCustomObjectSpace;mBatch:string):string;
var
  mStorecard_ID:string;
  mStoreBatch_ID:string;
  mVerze:string;
  mQuantity:string;
  mr,mFieldValue:TStringList;
  mNameBatch:string;
begin
mStorecard_ID:='';
mStoreBatch_ID:='';
mVerze:='';
mQuantity:='0';

     mFieldValue:=TStringList.create;
        //NxShowSimpleMessage(mDatamatrix,nil);
        try
           Parsevalue(mBatch,';',mBatch,mFieldValue,2);
              if mFieldValue.Count >0 then begin
                  mr:=tstringlist.create;
                  try
                        os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(mfieldValue.strings[0]),mr);
                        //NxShowSimpleMessage(mfieldValue.strings[1],nil);
                        if mr.count>0 then begin
                            mStoreBatch_ID:=copy(mr.strings[0],1,10);
                            mStorecard_ID:=copy(mr.strings[0],12,10);
                            mQuantity:= mfieldValue.strings[1];
                        end else begin
                        //          NxShowSimpleMessage(mfieldValue.strings[1] + ' - ' + mStoreBatch_ID ,nil);
                        end;
                  finally
                      mr.free;
                  end;
              end;
        finally
            mfieldValue.free;
        end;





 if mStorecard_ID='' then begin
        result:='' ;
    end else begin
        result:='0000000000' + ';' +  mStorecard_ID + ';' + mStoreBatch_ID+';' + mQuantity;
    end;

end;



function DatamatrixDecodeBatches(os:TNxCustomObjectSpace;mDatamatrix:string):string;
var
  mStorecard_ID:string;
  mStoreBatch_ID:string;
  mVerze:string;
  mQuantity:string;
  mr,mFieldValue:TStringList;
  mNameBatch:string;
begin
mStorecard_ID:='';
mStoreBatch_ID:='';
mVerze:='';
mQuantity:='0';


mdatamatrix:=NxSearchReplace(mdatamatrix,'"','',[srCase,srAll]);


if copy(mdatamatrix,1,1)='*' then begin
      mdatamatrix:=NxSearchReplace(mdatamatrix,'*','',[srCase,srAll]);
end;

      mdatamatrix:=NxSearchReplace(mdatamatrix,'(','',[srCase,srAll]);
      mdatamatrix:=NxSearchReplace(mdatamatrix,')','',[srCase,srAll]);
      mdatamatrix:=NxSearchReplace(mdatamatrix,')','',[srCase,srAll]);
      mdatamatrix:=NxSearchReplace(mdatamatrix,'&A','',[srCase,srAll]);
      mdatamatrix:=NxSearchReplace(mdatamatrix,'&B','',[srCase,srAll]);
      mdatamatrix:=NxSearchReplace(mdatamatrix,'&C','',[srCase,srAll]);
      mdatamatrix:=NxSearchReplace(mdatamatrix,'&D','',[srCase,srAll]);
      mdatamatrix:=NxSearchReplace(mdatamatrix,'&E','',[srCase,srAll]);


 // NxShowSimpleMessage(mDatamatrix,nil);

{    Popis dekódování QR / DataMatrix kódu

Popis dekódování QR kódu / Datamarixu, který umí systém rozeznat. Dekódování probíhá ve sledu, jak je popsáno.

V načteném řetězci se vyskytují středníky. Identifikováno jako náš QR kód.

Mezi prvním a druhým středníkem se nachází šarže. Pokud jsou v řetězci obsaženy 3 středníky, za třetím je datum expirace. V opačném případě je datum expirace za čtvrtým. Vzor řetězce :

Katalogové číslo --;Šarže ------;Expirace;Rok-měs expirace

LIPO-PI99V00X-W-3XL;932712206001;20270630;2027-06
}
if mStorecard_ID='' then begin
    //if Pos(';', mDatamatrix)<>0 then begin
    if copy(mDatamatrix,1,5)='LIPO-' then begin
        mFieldValue:=TStringList.create;
        //NxShowSimpleMessage(mDatamatrix,nil);
        try
           Parsevalue(mDatamatrix,';',mDatamatrix,mFieldValue,3);
              if mFieldValue.Count >0 then begin
                  mr:=tstringlist.create;
                  try
                        os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(mfieldValue.strings[1]),mr);
                        //NxShowSimpleMessage(mfieldValue.strings[1],nil);
                        if mr.count>0 then begin
                            mStoreBatch_ID:=copy(mr.strings[0],1,10);
                            mStorecard_ID:=copy(mr.strings[0],12,10);
                            mQuantity:= '1';
                        end else begin
                        //          NxShowSimpleMessage(mfieldValue.strings[1] + ' - ' + mStoreBatch_ID ,nil);
                        end;
                  finally
                      mr.free;
                  end;
              end;
        finally
            mfieldValue.free;
        end;
    end;
end;

{Načtený řetězec začíná „01076“ a obsahuje znaky „~17“. Vlnovka je náhrada za speciální řídící znak GS1, který se vkládá do DataMatrix kódu jako oddělovač.

Jedná se o nový kód Teoxane

Originál: 010764017323110310194625B0~1721113021194625B01433

Čtivě:  01 07640173231103 10 194625B0 17 211130 21 194625B01433

}

if mStorecard_ID='' then begin

   if copy(mDatamatrix,1,3)='MAT' then begin
                        mr:=tstringlist.create;
                        try
                                os.SQLSelect('select sb.id,sb.Storecard_ID from StoreBatches sb join Storecards SC on sc.id= sb.StoreCard_ID where sb.Name=' + quotedstr(trim(mDatamatrix)),mr);
                                if mr.count>0 then begin
                                        mStoreBatch_ID:=copy(mr.strings[0],1,10);
                                        mStorecard_ID:=copy(mr.strings[0],12,10);
                                        mQuantity:= '1';
                                    end else begin
                                    //          NxShowSimpleMessage(mfieldValue.strings[1] + ' - ' + mStoreBatch_ID ,nil);
                                    end;
                        finally
                            mr.free;
                        end;
    end;
end;












if mStorecard_ID='' then begin
    if (copy(mdatamatrix,1,5)='01076') AND (Pos('17', mDatamatrix)<>0) then begin
           mr:=tstringlist.create;
                  try
                        mNameBatch:=copy(mdatamatrix,19,8);
                        //NxShowSimpleMessage(mNameBatch,nil);
                        os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(mNameBatch),mr);
                        if mr.count>0 then begin
                            mStoreBatch_ID:=copy(mr.strings[0],1,10);
                            mStorecard_ID:=copy(mr.strings[0],12,10);
                            mQuantity:= '1';
                        end else begin
                            //      NxShowSimpleMessage(mNameBatch + ' - ' + mStoreBatch_ID ,nil);
                        end;
                  finally
                      mr.free;
                  end;
    end;
end;


{Načtený řetězec obsahuje znaky „~17“ a „~11“ a zároveň začíná na "010859184" nebo "010222000" (naše EANy). Jedná se o náš nový DataMatrix kód
01----EAN-------10-LOT na 15 zn.-/V17RRMMDD
010859184620012610020012190300001/_17220520
Specifikum je v tom, že šarže je na 15 znaků doplněna nulami zleva. Systém po načtení kódu nuly ořeže. Když je však výsledná šarže kratší než 12 znaků, nuly doplní, aby šarže měla minimálně 12 znaků.
}

if mStorecard_ID='' then begin
  //NxShowSimpleMessage(copy(mdatamatrix,19,15),nil);
    if not NxIsNumeric(copy(mdatamatrix,19,15)) then begin
                 // NxShowSimpleMessage('AAA  ' + copy(mdatamatrix,19,15),nil);
//              if (copy(mdatamatrix,1,3)='010') AND (copy(mdatamatrix,17,2)='10') AND (copy(mdatamatrix,25,2)='10') then begin
                     mr:=tstringlist.create;
                            try
                                  mNameBatch:=trim(copy(mdatamatrix,19,15));
                                  while copy(mNameBatch,1,1)='0'do  begin
                                       mNameBatch:=copy(mNameBatch,2,15);
                                  end;
                                  //NxShowSimpleMessage(mNameBatch,nil);
                                  if copy(mNameBatch,1,1)='L'then  begin
                                            os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(trim(mNameBatch)),mr);
                                            if mr.count>0 then begin
                                                mStoreBatch_ID:=copy(mr.strings[0],1,10);
                                                mStorecard_ID:=copy(mr.strings[0],12,10);
                                                mQuantity:= '1';
                                            end else begin
                                                //      NxShowSimpleMessage(mNameBatch + ' - ' + mStoreBatch_ID ,nil);
                                            end;
                                  end;
                            finally
                                mr.free;
                            end;
              //end;
    end;
end;



if mStorecard_ID='' then begin
    if ((copy(mdatamatrix,1,9)='010859184') or (copy(mdatamatrix,1,9)='010222000')) and
       ((copy(mdatamatrix,(Length(mdatamatrix)-7),2)='17') or (copy(mdatamatrix,(Length(mdatamatrix)-8),2)='17'))
    then begin
         //(Pos('~17', mDatamatrix)<>0) and (Pos('~11', mDatamatrix)<>0)  then begin

           mNameBatch:=copy(mdatamatrix,19,15);
           //NxShowSimpleMessage(copy(mdatamatrix,19,15),nil);
           mNameBatch:=Trim(NxFloatToIBStr(NxIBStrToFloat(mNameBatch)));
           if Length(mNameBatch)<12 then begin
                 mNameBatch:='0000000000000' +mNameBatch;
                 mNameBatch:=RightStr(mNameBatch,12);
           end;


           if mNameBatch<>'' then begin
                 mr:=tstringlist.create;
                        try
                              os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(mNameBatch),mr);
                              if mr.count>0 then begin
                                  mStoreBatch_ID:=copy(mr.strings[0],1,10);
                                  mStorecard_ID:=copy(mr.strings[0],12,10);
                                  mQuantity:= '1';
                              end else begin
                               //   NxShowSimpleMessage(mNameBatch + ' - ' + mStoreBatch_ID ,nil);
                              end;
                        finally
                            mr.free;
                        end;
           end;

    end;
end;


{Načtený řetězec obsahuje znaky „~17“ a nevyhovuje předchozím pravidlům
Jedná se o kód používaný na produktech Teoxane
010060640114707010231582~17230630212315820001
}

 if mStorecard_ID='' then begin
    if (Pos('~17', mDatamatrix)<>0) then begin
       mNameBatch:=copy(mdatamatrix,24,15);
          //*** error
           //NxShowSimpleMessage(mNameBatch,nil);
           if mNameBatch<>'' then begin
                 mr:=tstringlist.create;
                        try
                              os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(mNameBatch),mr);
                              if mr.count>0 then begin
                                  mStoreBatch_ID:=copy(mr.strings[0],1,10);
                                  mStorecard_ID:=copy(mr.strings[0],12,10);
                                  mQuantity:= '1';
                              end else begin
                                //  NxShowSimpleMessage(mNameBatch + ' - ' + mStoreBatch_ID ,nil);
                              end;
                        finally
                            mr.free;
                        end;
           end;
    end;
end;


{




Načtený kód obsahuje ".-"

Kód používaný u ostatní kosmetiky

801500.-W282G243-147057

}
  if mStorecard_ID='' then begin
    if (Pos('.-', mDatamatrix)<>0) then begin
        mNameBatch:=copy(mdatamatrix,9,15);
           //NxShowSimpleMessage(mNameBatch,nil);
           if mNameBatch<>'' then begin
                 mr:=tstringlist.create;
                        try
                              os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(mNameBatch),mr);
                              if mr.count>0 then begin
                                  mStoreBatch_ID:=copy(mr.strings[0],1,10);
                                  mStorecard_ID:=copy(mr.strings[0],12,10);
                                  mQuantity:= '1';
                              end else begin
                               //   NxShowSimpleMessage(mNameBatch + ' - ' + mStoreBatch_ID ,nil);
                              end;
                        finally
                            mr.free;
                        end;
           end;
    end;
end;

{


Načtený kód obsahuje dvě pomlčky a neobsahuje text „LIPOLINE“

Jedná se o kódy označující implantáty

TMM2350-Z090F042-177026


}
 if mStorecard_ID='' then begin
    if (Pos('-', mDatamatrix)<>0) and (Pos('LIPOLINE', mDatamatrix)=0) then begin
       mNameBatch:=copy(mdatamatrix,9,15);
           if mNameBatch<>'' then begin
                 mr:=tstringlist.create;
                        try
                              os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(mNameBatch),mr);
                              if mr.count>0 then begin
                                  mStoreBatch_ID:=copy(mr.strings[0],1,10);
                                  mStorecard_ID:=copy(mr.strings[0],12,10);
                                  mQuantity:= '1';
                              end else begin
                                //  NxShowSimpleMessage(mNameBatch + ' - ' + mStoreBatch_ID ,nil);
                              end;
                        finally
                            mr.free;
                        end;
           end;


    end;
end;

{


Délka načteného řetězce je větší než 45 znaků a na 44 pozici je „240“

Jedná se o náš starý DataMatrix

XX--EAN---------XX---šarže-------XXDat.exp-XXX—Katalogové č.----

0108591846544329100544321906000021723062022240LIPO-MH01C00C-B-XL


}

 if mStorecard_ID='' then begin
    if (Length(mDatamatrix)>45) and (copy(mDatamatrix,44,3)='240') then begin
      mNameBatch:=copy(mdatamatrix,18,15);
           //NxShowSimpleMessage(mNameBatch,nil);
           // *** error
           if mNameBatch<>'' then begin
                 mr:=tstringlist.create;
                        try
                              os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(mNameBatch),mr);
                              if mr.count>0 then begin
                                  mStoreBatch_ID:=copy(mr.strings[0],1,10);
                                  mStorecard_ID:=copy(mr.strings[0],12,10);
                                  mQuantity:= '1';
                              end else begin
                                //  NxShowSimpleMessage(mNameBatch + ' - ' + mStoreBatch_ID ,nil);
                              end;
                        finally
                            mr.free;
                        end;
           end;





    end;
end;

{

Načtený kód je na 41 znaků a na 34 pozici je „17“

Jedná se o náš aktuální DataMatrix

XX--------------XX---------------XX------

  0----EAN------  -LOT na 15 zn.-  RRMMDD

01085918469175431000091754201000117251015

}

 if mStorecard_ID='' then begin
    if (Length(mDatamatrix)=41) and (copy(mDatamatrix,34,2)='17') then begin
    mNameBatch:= NxFloatToIBStr(NxIBStrToFloat(copy(mdatamatrix,19,15)));
           //NxShowSimpleMessage(mNameBatch,nil);
           if mNameBatch<>'' then begin
                 mr:=tstringlist.create;
                        try
                              os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(mNameBatch),mr);
                              if mr.count>0 then begin
                                  mStoreBatch_ID:=copy(mr.strings[0],1,10);
                                  mStorecard_ID:=copy(mr.strings[0],12,10);
                                  mQuantity:= '1';
                              end else begin
                              //    NxShowSimpleMessage(mNameBatch + ' - ' + mStoreBatch_ID ,nil);
                              end;
                        finally
                            mr.free;
                        end;
           end;





    end;
end;

{

Načtený kód je na 41 znaků a na 34 pozici je „11“

Jedná se o Náš DataMatrix - Lipoline (má datum produkce, ne expirace)---

XX--------------XX---------------XX------

  0----EAN------  -LOT na 15 zn.-  RRMMDD

01085918469175431000091754201000111251015


}


 if mStorecard_ID='' then begin
    if (Length(mDatamatrix)=41) and (copy(mDatamatrix,34,2)='11') then begin
    mNameBatch:= NxFloatToIBStr(NxIBStrToFloat(copy(mdatamatrix,19,15)));
           //NxShowSimpleMessage(mNameBatch,nil);
           if mNameBatch<>'' then begin
                 mr:=tstringlist.create;
                        try
                              os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(mNameBatch),mr);
                              if mr.count>0 then begin
                                  mStoreBatch_ID:=copy(mr.strings[0],1,10);
                                  mStorecard_ID:=copy(mr.strings[0],12,10);
                                  mQuantity:= '1';
                              end else begin
                               //   NxShowSimpleMessage(mNameBatch + ' - ' + mStoreBatch_ID ,nil);
                              end;
                        finally
                            mr.free;
                        end;
           end;





    end;
end;

{




Načtený kód je na 44 znaků a na 42 pozici je „37“

Jedná se o náš DataMatrix na výrobním štítku

XX--------------XX---------------XX------XX--

  0----EAN------10-LOT na 15 zn.-17RRMMDD  Počet kusů

010859184674212110000742122108007172608273730

}

 if mStorecard_ID='' then begin
    if (Length(mDatamatrix)>=44) and (Length(mDatamatrix)<48) and (copy(mDatamatrix,42,2)='37') then begin
    mNameBatch:= NxFloatToIBStr(NxIBStrToFloat(copy(mdatamatrix,19,15)));
           //NxShowSimpleMessage(mNameBatch,nil);
           if mNameBatch<>'' then begin
                 mr:=tstringlist.create;
                        try
                              os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(mNameBatch),mr);
                              if mr.count>0 then begin
                                  mStoreBatch_ID:=copy(mr.strings[0],1,10);
                                  mStorecard_ID:=copy(mr.strings[0],12,10);
                                  mQuantity:= copy(mDatamatrix,44,2);
                              end else begin
                              //    NxShowSimpleMessage(mNameBatch + ' - ' + mStoreBatch_ID ,nil);
                              end;
                        finally
                            mr.free;
                        end;
           end;





    end;
end;

{


- Nově přidáno i číslo objednávky a poč.kusů rozšířen n 4 místa

010----EAN------10-LOT na 15 zn.-17RRMMDD37Poč.99-Objednávka--

0108591846924831100009248322070061727080937001099OV2-4120/2022


}


  if mStorecard_ID='' then begin
    if (Length(mDatamatrix)>47) and (copy(mDatamatrix,42,2)='37') then begin
    mNameBatch:= NxFloatToIBStr(NxIBStrToFloat(copy(mdatamatrix,19,15)));
           //NxShowSimpleMessage(mNameBatch,nil);
           if mNameBatch<>'' then begin
                 mr:=tstringlist.create;
                        try
                              os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(mNameBatch),mr);
                              if mr.count>0 then begin
                                  mStoreBatch_ID:=copy(mr.strings[0],1,10);
                                  mStorecard_ID:=copy(mr.strings[0],12,10);
                                  mQuantity:= copy(mDatamatrix,44,4);
                              end else begin
                              //    NxShowSimpleMessage(mNameBatch + ' - ' + mStoreBatch_ID ,nil);
                              end;
                        finally
                            mr.free;
                        end;
           end;





    end;
end;


{





Načtený kód je delší než 42 znaků a začíná na „01“

Jedná se o kód na produktech Nagor

01---Ean -------10----šarže -----21—výr.číslo

01037004697171491030015791722123121AA004M1127

}

 if mStorecard_ID='' then begin
    if (Length(mDatamatrix)>42) and (copy(mDatamatrix,1,2)='01') and (copy(mDatamatrix,17,2)='10') and (copy(mDatamatrix,34,2)='21')then begin
//          NxShowSimpleMessage(copy(mDatamatrix,17,2),nil);
                 //   NxShowSimpleMessage(copy(mDatamatrix,34,2),nil);

          // *** error
          mNameBatch:=trim(copy(mdatamatrix,36,15));
//              NxShowSimpleMessage('XX' + mNameBatch,nil);
           if mNameBatch<>'' then begin
                 mr:=tstringlist.create;
                        try
                              os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(mNameBatch),mr);
                              if mr.count>0 then begin
                                  mStoreBatch_ID:=copy(mr.strings[0],1,10);
                                  mStorecard_ID:=copy(mr.strings[0],12,10);
                                  mQuantity:= '1';
                              end else begin
                             //     NxShowSimpleMessage(mNameBatch + ' - ' + mStoreBatch_ID ,nil);
                              end;
                        finally
                            mr.free;
                        end;
           end;
    end;
end;

{




Kód na začátku má „01“ a od čtvrté pozice 6 znaků je „426017“

Jedná se o produkty HumanMed - BodyJet . Mají dvě délky kódů.



01-----EAN------11-Vyr.-17-exp--10-šarže--

011426017088147911220509172509051000934306
}
 if mStorecard_ID='' then begin
    if (copy(mDatamatrix,1,3)='011') and (copy(mDatamatrix,4,6)='426017') then begin
         mNameBatch:=NxFloatToIBStr(NxIBStrToFloat(copy(mdatamatrix,33,8)));
//        NxShowSimpleMessage(mNameBatch,nil);
        // **** error
        if mNameBatch<>'' then begin
                 mr:=tstringlist.create;
                        try
                              os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(mNameBatch),mr);
                              if mr.count=1 then begin
                                  mStoreBatch_ID:=copy(mr.strings[0],1,10);
                                  mStorecard_ID:=copy(mr.strings[0],12,10);
                                  mQuantity:= '1';
                              end else begin
                              //    NxShowSimpleMessage(mNameBatch + ' - ' + mStoreBatch_ID ,nil);
                              end;
                        finally
                            mr.free;
                        end;
           end;
    end;
end;






{

Nebo



01--------------11------10------

01042601708812361122041210921346

}

 if mStorecard_ID='' then begin
    if (copy(mDatamatrix,1,2)='01') and (copy(mDatamatrix,4,6)='426017') then begin
         mNameBatch:=copy(mdatamatrix,26,6);

         // **** error
        if mNameBatch<>'' then begin
                 mr:=tstringlist.create;
                        try
                              os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(mNameBatch),mr);
                              if mr.count=1 then begin
                                  mStoreBatch_ID:=copy(mr.strings[0],1,10);
                                  mStorecard_ID:=copy(mr.strings[0],12,10);
                                  mQuantity:='1';
                              end else begin
                             //     NxShowSimpleMessage(mNameBatch + ' - ' + mStoreBatch_ID ,nil);
                              end;
                        finally
                            mr.free;
                        end;
        end;
    end;
end;

{




Pokud načtený řetězec nevyhovuje ani jedné podmínce, je považován pouze za šarži

  }


  if mStorecard_ID='' then begin
    if ((Length(Trim(mdatamatrix))>25) and (Length(Trim(mdatamatrix))<40)) then begin
 //    01040262754455261728081510EK231016


              if (copy(mdatamatrix,1,3)='010') AND (copy(mdatamatrix,17,2)='17') AND (copy(mdatamatrix,25,2)='10') then begin


              // (Pos('17', mDatamatrix)<>0) then begin
                     mr:=tstringlist.create;
                            try
                                  mNameBatch:=trim(copy(mdatamatrix,27,50));
                                  //NxShowSimpleMessage(mNameBatch,nil);
                                  os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(mNameBatch),mr);
                                  if mr.count>0 then begin
                                      mStoreBatch_ID:=copy(mr.strings[0],1,10);
                                      mStorecard_ID:=copy(mr.strings[0],12,10);
                                      mQuantity:= '1';
                                  end else begin
                                      //      NxShowSimpleMessage(mNameBatch + ' - ' + mStoreBatch_ID ,nil);
                                  end;
                            finally
                                mr.free;
                            end;
              end;
    end;
end;

















  if mStorecard_ID='' then begin
       if NxCharPos(';',trim(mdatamatrix))>0 then begin
              mFieldValue:=TStringList.create;
              try
                    mFieldValue:= fnParsevalue(mdatamatrix,';');

                   mNameBatch:=mFieldValue.Strings[1];
                   //NxShowSimpleMessage(mNameBatch,nil);
                   mr:=tstringlist.create;
                  try
                        os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(mNameBatch),mr);
                        //NxShowSimpleMessage(mfieldValue.strings[1],nil);
                        if mr.count>0 then begin
                            mStoreBatch_ID:=copy(mr.strings[0],1,10);
                            mStorecard_ID:=copy(mr.strings[0],12,10);
                            mQuantity:= '1';
                        end else begin
                        //          NxShowSimpleMessage(mfieldValue.strings[1] + ' - ' + mStoreBatch_ID ,nil);
                        end;
                  finally
                      mr.free;
                  end;
            finally
                mfieldValue.free;
            end;
       end;
  end;











  if mStorecard_ID='' then begin

                   mNameBatch:=(copy(mdatamatrix,19,15));
                   mNameBatch:=NxFloatToIBStr(NxIBStrToFloat(mNameBatch));
                   //NxShowSimpleMessage(mNameBatch,nil);
                   mr:=tstringlist.create;
                  try
                        os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(mNameBatch),mr);
                           //  NxShowSimpleMessage(mfieldValue.strings[1] + ' - ' + mStoreBatch_ID ,nil);
                        if mr.count>0 then begin

                            mStoreBatch_ID:=copy(mr.strings[0],1,10);
                            mStorecard_ID:=copy(mr.strings[0],12,10);
                            mQuantity:= '1';
                     //         NxShowSimpleMessage(mStorecard_ID + ' - ' + mStoreBatch_ID ,nil);
                        end else begin
                             //     NxShowSimpleMessage(mfieldValue.strings[1] + ' - ' + mStoreBatch_ID ,nil);
                        end;
                  finally
                      mr.free;
                  end;

  end;










  if mStorecard_ID='' then begin
         mNameBatch:=NxSearchReplace(mdatamatrix,'"','',[srCase,srAll]);
         mNameBatch:=NxSearchReplace(mNameBatch,';','',[srCase,srAll]);
         mNameBatch:=NxSearchReplace(mNameBatch,' ','',[srCase,srAll]);
         mNameBatch:=trim(mNameBatch);
        if mNameBatch<>'' then begin
                 mr:=tstringlist.create;
                        try
                              os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(trim(mNameBatch)),mr);
                              if mr.count>0 then begin
                                  mStoreBatch_ID:=copy(mr.strings[0],1,10);
                                  mStorecard_ID:=copy(mr.strings[0],12,10);
                                  mQuantity:='1';
                              end else begin
                                  mStoreBatch_ID:='';
                                  //NxShowSimpleMessage(' Bez pravidla: - čistě šarže' + mNameBatch + ' - ' + mStoreBatch_ID ,nil);
                              end;
                        finally
                            mr.free;
                        end;
         end;
      end;
     //NxShowSimpleMessage(mStoreBatch_ID + ';' + mStorecard_ID + ';' + mQuantity,nil);









     if mStorecard_ID='' then begin
         mNameBatch:=NxSearchReplace(mdatamatrix,'"','',[srCase,srAll]);
         mNameBatch:=NxSearchReplace(mNameBatch,';','',[srCase,srAll]);
         mNameBatch:=NxSearchReplace(mNameBatch,' ','',[srCase,srAll]);
         mNameBatch:=trim(mNameBatch);
        if mNameBatch<>'' then begin
                 mr:=tstringlist.create;
                        try
                              os.SQLSelect('select id from Storecards where Code=' + quotedstr(mNameBatch),mr);
                              if mr.count>0 then begin
                                  mStoreBatch_ID:='0000000000';
                                  mStorecard_ID:=mr.strings[0];
                                  mQuantity:='1';
                              end else begin
                                  mStoreBatch_ID:='';
                                  //NxShowSimpleMessage(' Bez pravidla: - čistě šarže' + mNameBatch + ' - ' + mStoreBatch_ID ,nil);
                              end;
                        finally
                            mr.free;
                        end;
         end;
      end;
     //NxShowSimpleMessage(mStoreBatch_ID + ';' + mStorecard_ID + ';' + mQuantity,nil);

     if mStorecard_ID='' then begin

           if copy(mdatamatrix,1,3)='MAT' then begin
                                mr:=tstringlist.create;
                                try
                                      os.SQLSelect('select id,Storecard_ID from StoreBatches where Name=' + quotedstr(trim(mDatamatrix)),mr);
                                      if mr.count>0 then begin
                                          mStoreBatch_ID:=copy(mr.strings[0],1,10);
                                          mStorecard_ID:=copy(mr.strings[0],12,10);
                                          mQuantity:='1';
                                      end else begin
                                          mStoreBatch_ID:='';
                                          //NxShowSimpleMessage(' Bez pravidla: - čistě šarže' + mNameBatch + ' - ' + mStoreBatch_ID ,nil);
                                      end;
                              finally
                                  mr.free;
                              end;
            end;
        end;










    if mStorecard_ID='' then begin
        result:='' ;
    end else begin
        result:='0000000000' + ';' +  mStorecard_ID + ';' + mStoreBatch_ID+';' + mQuantity;
    end;
end;



  function xxxParsevalueLight(AData : string; ASeparator: string):TStringList;
// rozdělení hodnot pro import
var
    mStr, mToken : string;
    mPos, i : integer;
    mList:tstringlist;
begin
    mStr := AData;
    mlist:=tstringlist.create;

    try
        while AnsiPos(ASeparator,mStr)>0 do  begin
            mPos := AnsiPos(ASeparator, mStr);
            if mPos = 0 then mPos := Length(mStr) + 1;
                mList.Add(NxLeft(mStr, mPos - 1));
                mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);

        end;
        mList.Add(mStr);
        result:=mlist;
   finally
       mlist.free;
   end;
end;

  procedure ParsevalueRow(const AData : string; ASeparator:string; AHead:TStringList);
// rozdělení hodnot pro import
var
    mStr, mToken : string;
    mPos, i : integer;
begin
    mStr := AData;
    try
        while AnsiPos(ASeparator,mStr)>0 do  begin
            mPos := AnsiPos(ASeparator, mStr);
            if mPos = 0 then mPos := Length(mStr) + 1;
                AHead.Add(NxLeft(mStr, mPos - 1));
                mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);
        end;
        if Length(trim(mStr))>0 then AHead.Add(mstr) ;
     finally
     end;
end;

  function xxxFNParsevalueRow(const AData : string; ASeparator:string):TStringList;
// rozdělení hodnot pro import
var
    mStr, mToken : string;
    mPos, i : integer;
    AHead:TStringList;
begin
    mStr := AData;
    ahead:=TStringList.create;

    try
        while AnsiPos(ASeparator,mStr)>0 do  begin
            mPos := AnsiPos(ASeparator, mStr);
            if mPos = 0 then mPos := Length(mStr) + 1;
                AHead.Add(NxLeft(mStr, mPos - 1));
                mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);
        end;
        if Length(trim(mStr))>0 then AHead.Add(mstr) ;
        result:=AHead;
     finally
     end;


end;

function fnParsevalue(const AData : string; ASeparator:string):TStringList;
// rozdělení hodnot pro import
var
    mStr, mToken : string;
    mPos, i : integer;
    AHead:TStringList;
begin
    mStr := AData;
    ahead:=TStringList.create;

    try
        while AnsiPos(ASeparator,mStr)>0 do  begin
            mPos := AnsiPos(ASeparator, mStr);
            if mPos = 0 then mPos := Length(mStr) + 1;
                AHead.Add(NxLeft(mStr, mPos - 1));
                mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);
        end;
        if Length(trim(mStr))>0 then AHead.Add(mstr) ;
     finally
     end;

     result:=AHead;
end;



begin
end.