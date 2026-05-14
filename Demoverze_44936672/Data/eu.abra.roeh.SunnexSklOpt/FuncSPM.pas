uses 'eu.abra.roeh.Logio.constVar',
     'eu.abra.roeh.Logio.func';

procedure CallSolGoodsMargin(mOS:TNxCustomObjectSpace;mStoreCards:TStringList);
var
  mSeldef,mSql : string;
  mS: String;
  mStr : TStringList;
begin
  mOS.StartTransaction(taReadCommited);
  try
    mSql := 'delete from INV_MARGIN;';
    mOS.SQLExecute(mSQL);
    mSeldef:= Copy(IntToStr(Round(Frac(Now)*100000))+'~INVENTORO',1,10);
    StringsToSelDat(mOS,mSeldef,mStoreCards);
    mS := Trim(GetParamValue(mOS,'MARGINFROM'));
    if mS = '' then mS := '365';
    mSql := ' INSERT INTO INV_MARGIN (PARENT_ID,SELLINGAMOUNT,STOREAMOUNT,QUANTITY) ';
    mSQL := mSql + ' Select B.StoreCard_ID,(Sum(B.RC2_LocalTAmountWithoutVAT)+Sum(B.II2_LocalTAmountWithoutVAT) - Sum(B.ICN2_LocalTAmountWithoutVAT)-Sum(B.RCR2_LocalTAmountWithoutVAT)),';
    mSql := mSql +' Sum(B.SD2_LocalTAmount) - Sum(B.XSD2_LocalTAmount), Sum(B.II2_Quantity) + Sum(B.RC2_Quantity) - Sum(B.ICN2_Quantity) - Sum(B.RCR2_Quantity) from SoldGoods(''A'', '+IntToStr(Round(Now)-StrToInt(mS))+', '+IntToStr(Round(Now))+','''+mSeldef+''', '''', '''', '''',';
    mSql := mSql +' '''', '''', '''', '''', '''','''', '''', '''',''0'', ''0'', ''0'', ''0'',''N'', 0, 0, '''',''N'', 0, 0, ''0'', ''0'',''0'') b group by B.StoreCard_ID';
    mOS.SQLExecute(mSQL);
    ClearSelDat(mOS,mSeldef);
   mOS.Commit;
  except
   mOS.RollBack;
  end;
end;

procedure MarginStoreCard(mOS:TNxCustomObjectSpace);
var
  mStr : TStringList;
begin
  mStr := TStringList.Create;
  try
    mOS.SQLSelect('select id from StoreCards where X_AnalyzedCard = ''A''',mStr);
    CallSolGoodsMargin(mOS,mStr);
  finally
   mStr.Free;
  end;
end;

procedure CreateFirstLevelNorms(mOS:TNxCustomObjectSpace);
var
  mSQL : string;
begin
  mSQL := 'DELETE from INV_NORMS;';
  mOS.SQLExecute(mSQL);
  mSQL := 'insert into  INV_NORMS (PARENT_ID,STORE_ID,StoreCard_id,QUANTITY,SPMNORMS_ID,VYR) select SC.ID,SP2.Store_ID, SC.id,sp2.QUANTITY,Sp2.Parent_Id,''V''' +
    ' from SPMAssemblyLists2 Sp2 inner join storecards SC on SC.ID = SP2.StoreCard_id AND SP2.rowType = 3 where SC.x_analyzedcard = ''A''';
   mOS.SQLExecute(mSQL);
end;


procedure CreateMaterialsFromNorms(mOS:TNxCustomObjectSpace);
var
  mSQL,  mDefaultStrID : string;
  mStr : TStringList;
  N : Integer;
begin
  {pořešit default sklad na materiál - měl by se brát z nastavení kompletace}
  mDefaultStrID := Trim(GetParamValue(mOS,'STOREMAT'));
  CreateFirstLevelNorms(mOS);
  mStr := TStringList.Create;
  try
    repeat
      {Převdeme výrobky na materiál}
      mSQL := ' insert into  INV_NORMS (PARENT_ID,STORE_ID,StoreCard_id,QUANTITY,SPMNORMS_ID,VYR) ';
      mSQL := mSQL  + ' select INV.PARENT_ID,coalesce(SN2.Store_ID,'''+mDefaultStrID+'''),SN2.storecard_id,SN2.Quantity * INV.Quantity,INV.SPMNORMS_ID,''X'' ';
      mSQL := mSQL  + ' from INV_NORMS INV inner join SPMNorms SN on SN.StoreCard_ID = INV.StoreCard_id ';
      mSQL := mSQL  + ' inner join SPMNorms2 SN2 on SN2.parent_id = SN.ID where INV.Vyr = ''V''';
      mOS.SQLExecute(mSQL);

      {Smažeme výrobky/polotovary}
      mSQL := 'delete from  INV_NORMS where  Vyr = ''V''';
      mOS.SQLExecute(mSQL);
      {Převedeme X karty na Výrobky}
      mSQl := 'update inv_norms i set Vyr =''V'' where Vyr =''X'' and exists (select 1 from SPMNorms s where i.StoreCard_Id =s.storecard_id)';
      mOS.SQLExecute(mSQL);
      {Převedeme X karty na Materiál}
      mSQl := 'update inv_norms i set Vyr =''M'' where Vyr =''X''';
      mOS.SQLExecute(mSQL);
     {Zjistíme, zda máme ještě polotovary v tabulce}
      mSQl := 'select count(*) from inv_norms where Vyr =''V''';
      mStr.Clear;
      mOS.SQLSelect(mSQL,mStr);
      N := mStr.Count;
      if N >0 then N := StrToInt(mStr.Strings(0));
    until N = 0;
  finally
    mStr.Free;
  end;
end;


begin
end.