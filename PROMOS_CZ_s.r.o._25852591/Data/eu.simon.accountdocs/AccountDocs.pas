procedure AccountDocs (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);
var
 mlist, mList2:TStringList;
 mSql, mSQL2,mAccPresetDef:String;
begin
  Success := True;
  LogInfoStr := '';
  //Příjemky
  mList:=TStringList.Create;
  mlist2:=TStringList.Create;

  mSql:='SELECT a.ID FROM StoreDocuments A LEFT JOIN SYS$StoreDocuments3 SD3 ON SD3.StoreDocument_ID=A.ID left join DocQueues DQ on DQ.id=a.docqueue_ID where '+
        'A.DocumentType=''20'' AND a.docdate$Date>42370  and '+
        '((0 = (select Count(ID) from Relations where  Rel_Def=19 and LeftSide_ID=A.ID) ) AND (SD3.Closed = ''A'' )) and' +
        '(  DQ.ToAccount = ''A'' and DQ.SummaryAccounted = ''N''  OR  DQ.ToAccount = ''A'' and DQ.SummaryAccounted = ''A'' )';
  OS.SQLSelect(mSQL, mList);
  mSql2:='Select ID from accpresetdefs where Documenttype=''20'' and basic=''A'' ';
  OS.SQLSelect(mSQL2,mList2);
  mAccPresetDef:=mList2.strings[0];
  if (mList.count>0) and not(NxIsEmptyOID(mAccPresetDef))then begin

    CFxAccounting.SummaryAccounting('E03ZNUMDTCC4PDAUIEY1MBTJC0',mlist,0,mAccPresetDef,1,1,1);
  end;
  LogInfoStr := LogInfoStr+' Počet příjemek '+IntToStr(mlist.count);
  mlist.Free;
  mList2.Free;
  mAccPresetDef:='';

  //Dodací listy
  mList:=TStringList.Create;
  mlist2:=TStringList.Create;

  mSql:='SELECT a.ID FROM StoreDocuments A LEFT JOIN SYS$StoreDocuments3 SD3 ON SD3.StoreDocument_ID=A.ID left join DocQueues DQ on DQ.id=a.docqueue_ID where '+
        'A.DocumentType=''21'' AND a.docdate$Date>42370  and '+
        '((0 = (select Count(ID) from Relations where  Rel_Def=20 and LeftSide_ID=A.ID) ) AND (SD3.Closed = ''A'' )) and' +
        '(  DQ.ToAccount = ''A'' and DQ.SummaryAccounted = ''N''  OR  DQ.ToAccount = ''A'' and DQ.SummaryAccounted = ''A'' )';
   OS.SQLSelect(mSQL, mList);
  mSql2:='Select ID from accpresetdefs where Documenttype=''21'' and basic=''A'' ';
  OS.SQLSelect(mSQL2,mList2);
  mAccPresetDef:=mList2.strings[0];
  if (mList.count>0) and not(NxIsEmptyOID(mAccPresetDef))then begin

    CFxAccounting.SummaryAccounting('050I5SAOS3DL3ACU03KIU0CLP4',mlist,0,mAccPresetDef,1,1,1);
  end;
  LogInfoStr := LogInfoStr+' Počet DL '+IntToStr(mlist.count);
  mlist.Free;
  mList2.Free;
  mAccPresetDef:='';

  //Převodky výdej
  mList:=TStringList.Create;
  mlist2:=TStringList.Create;

  mSql:='SELECT a.ID FROM StoreDocuments A LEFT JOIN SYS$StoreDocuments3 SD3 ON SD3.StoreDocument_ID=A.ID left join DocQueues DQ on DQ.id=a.docqueue_ID where '+
        'A.DocumentType=''22'' AND a.docdate$Date>42582  and '+
        '((0 = (select Count(ID) from Relations where  Rel_Def=21 and LeftSide_ID=A.ID) ) AND (SD3.Closed = ''A'' )) and' +
        '(  DQ.ToAccount = ''A'' and DQ.SummaryAccounted = ''N''  OR  DQ.ToAccount = ''A'' and DQ.SummaryAccounted = ''A'' )';
  OS.SQLSelect(mSQL, mList);
  mSql2:='Select ID from accpresetdefs where Documenttype=''22'' and basic=''A'' ';
  OS.SQLSelect(mSQL2,mList2);
  mAccPresetDef:=mList2.strings[0];
  if (mList.count>0) and not(NxIsEmptyOID(mAccPresetDef))then begin

    CFxAccounting.SummaryAccounting('0P0I5SAOS3DL3ACU03KIU0CLP4',mlist,0,mAccPresetDef,1,1,1);
  end;
  LogInfoStr := LogInfoStr+' pocet prv '+IntToStr(mlist.count);
  mlist.Free;
  mList2.Free;
  mAccPresetDef:='';

  //Vratky dodacích listů
  mList:=TStringList.Create;
  mlist2:=TStringList.Create;

  mSql:='SELECT a.ID FROM StoreDocuments A LEFT JOIN SYS$StoreDocuments3 SD3 ON SD3.StoreDocument_ID=A.ID left join DocQueues DQ on DQ.id=a.docqueue_ID where '+
        'A.DocumentType=''23'' AND a.docdate$Date>42582  and '+
        '((0 = (select Count(ID) from Relations where  Rel_Def=22 and LeftSide_ID=A.ID) ) AND (SD3.Closed = ''A'' )) and' +
        '(  DQ.ToAccount = ''A'' and DQ.SummaryAccounted = ''N''  OR  DQ.ToAccount = ''A'' and DQ.SummaryAccounted = ''A'' )';
  OS.SQLSelect(mSQL, mList);
  mSql2:='Select ID from accpresetdefs where Documenttype=''23'' and basic=''A'' ';
  OS.SQLSelect(mSQL2,mList2);
  mAccPresetDef:=mList2.strings[0];
  if (mList.count>0) and not(NxIsEmptyOID(mAccPresetDef))then begin

    CFxAccounting.SummaryAccounting('1T0I5SAOS3DL3ACU03KIU0CLP4',mlist,0,mAccPresetDef,1,1,1);
  end;
  LogInfoStr := LogInfoStr+'pocet VR '+IntToStr(mlist.count);
  mlist.Free;
  mList2.Free;
  mAccPresetDef:='';

  //Převodky příjem
  mList:=TStringList.Create;
  mlist2:=TStringList.Create;

  mSql:='SELECT a.ID FROM StoreDocuments A LEFT JOIN SYS$StoreDocuments3 SD3 ON SD3.StoreDocument_ID=A.ID left join DocQueues DQ on DQ.id=a.docqueue_ID where '+
        'A.DocumentType=''24'' AND a.docdate$Date>42582  and '+
        '((0 = (select Count(ID) from Relations where  Rel_Def=23 and LeftSide_ID=A.ID) ) AND (SD3.Closed = ''A'' )) and' +
        '(  DQ.ToAccount = ''A'' and DQ.SummaryAccounted = ''N''  OR  DQ.ToAccount = ''A'' and DQ.SummaryAccounted = ''A'' )';
  OS.SQLSelect(mSQL, mList);
  mSql2:='Select ID from accpresetdefs where Documenttype=''24'' and basic=''A'' ';
  OS.SQLSelect(mSQL2,mList2);
  mAccPresetDef:=mList2.strings[0];
  if (mList.count>0) and not(NxIsEmptyOID(mAccPresetDef))then begin

    CFxAccounting.SummaryAccounting('1D0I5SAOS3DL3ACU03KIU0CLP4',mlist,0,mAccPresetDef,1,1,1);
  end;
  LogInfoStr := LogInfoStr+'pocet prp '+IntToStr(mlist.count);
  mlist.Free;
  mList2.Free;
  mAccPresetDef:='';



  //Výdej materiálu
  mList:=TStringList.Create;
  mlist2:=TStringList.Create;

  mSql:='SELECT a.ID FROM StoreDocuments A LEFT JOIN SYS$StoreDocuments3 SD3 ON SD3.StoreDocument_ID=A.ID left join DocQueues DQ on DQ.id=a.docqueue_ID where '+
        'A.DocumentType=''27'' AND a.docdate$Date>42582  and '+
        '((0 = (select Count(ID) from Relations where  Rel_Def=39 and LeftSide_ID=A.ID) ) AND (SD3.Closed = ''A'' )) and' +
        '(  DQ.ToAccount = ''A'' and DQ.SummaryAccounted = ''N''  OR  DQ.ToAccount = ''A'' and DQ.SummaryAccounted = ''A'' )';
  OS.SQLSelect(mSQL, mList);
  mSql2:='Select ID from accpresetdefs where Documenttype=''27'' and basic=''A'' ';
  OS.SQLSelect(mSQL2,mList2);
  mAccPresetDef:=mList2.strings[0];
  if (mList.count>0) and not(NxIsEmptyOID(mAccPresetDef))then begin

    CFxAccounting.SummaryAccounting('2MV0SHPYLFJOL3D4WN02HCPX5S',mlist,0,mAccPresetDef,1,1,1);
  end;
  LogInfoStr := LogInfoStr+'pocet VMV '+IntToStr(mlist.count);
  mlist.Free;
  mList2.Free;
  mAccPresetDef:='';

  //Příjem hotových výrobků
  mList:=TStringList.Create;
  mlist2:=TStringList.Create;

  mSql:='SELECT a.ID FROM StoreDocuments A LEFT JOIN SYS$StoreDocuments3 SD3 ON SD3.StoreDocument_ID=A.ID left join DocQueues DQ on DQ.id=a.docqueue_ID where '+
        'A.DocumentType=''28'' AND a.docdate$Date>42582  and '+
        '((0 = (select Count(ID) from Relations where  Rel_Def=38 and LeftSide_ID=A.ID) ) AND (SD3.Closed = ''A'' )) and' +
        '(  DQ.ToAccount = ''A'' and DQ.SummaryAccounted = ''N''  OR  DQ.ToAccount = ''A'' and DQ.SummaryAccounted = ''A'' )';
  OS.SQLSelect(mSQL, mList);
  mSql2:='Select ID from accpresetdefs where Documenttype=''28'' and basic=''A'' ';
  OS.SQLSelect(mSQL2,mList2);
  mAccPresetDef:=mList2.strings[0];
  if (mList.count>0) and not(NxIsEmptyOID(mAccPresetDef))then begin

    CFxAccounting.SummaryAccounting('C3DLAMUSDJNOLDWCDBSBM2GAI0',mlist,0,mAccPresetDef,1,1,1);
  end;
  LogInfoStr := LogInfoStr+'pocet PHV '+IntToStr(mlist.count);
  mlist.Free;
  mList2.Free;
  mAccPresetDef:='';

  //Vrácení materiálu
  mList:=TStringList.Create;
  mlist2:=TStringList.Create;

  mSql:='SELECT a.ID FROM StoreDocuments A LEFT JOIN SYS$StoreDocuments3 SD3 ON SD3.StoreDocument_ID=A.ID left join DocQueues DQ on DQ.id=a.docqueue_ID where '+
        'A.DocumentType=''29'' AND a.docdate$Date>42370  and '+
        '((0 = (select Count(ID) from Relations where  Rel_Def=40 and LeftSide_ID=A.ID) ) AND (SD3.Closed = ''A'' )) and' +
        '(  DQ.ToAccount = ''A'' and DQ.SummaryAccounted = ''N''  OR  DQ.ToAccount = ''A'' and DQ.SummaryAccounted = ''A'' )';
  OS.SQLSelect(mSQL, mList);
  mSql2:='Select ID from accpresetdefs where Documenttype=''29'' and basic=''A'' ';
  OS.SQLSelect(mSQL2,mList2);
  mAccPresetDef:=mList2.strings[0];
  if (mList.count>0) and not(NxIsEmptyOID(mAccPresetDef))then begin

    CFxAccounting.SummaryAccounting('P1BFFDCSUG04JG5LVBL11MPBPS',mlist,0,mAccPresetDef,1,1,1);
  end;
  LogInfoStr := LogInfoStr+'pocet VRM '+IntToStr(mlist.count);
  mlist.Free;
  mList2.Free;
  mAccPresetDef:='';

  //Vratky příjemek
  mList:=TStringList.Create;
  mlist2:=TStringList.Create;

  mSql:='SELECT a.ID FROM StoreDocuments A LEFT JOIN SYS$StoreDocuments3 SD3 ON SD3.StoreDocument_ID=A.ID left join DocQueues DQ on DQ.id=a.docqueue_ID where '+
        'A.DocumentType=''30'' AND a.docdate$Date>42370  and '+
        '((0 = (select Count(ID) from Relations where  Rel_Def=51 and LeftSide_ID=A.ID) ) AND (SD3.Closed = ''A'' )) and' +
        '(  DQ.ToAccount = ''A'' and DQ.SummaryAccounted = ''N''  OR  DQ.ToAccount = ''A'' and DQ.SummaryAccounted = ''A'' )';
  OS.SQLSelect(mSQL, mList);
  mSql2:='Select ID from accpresetdefs where Documenttype=''30'' and basic=''A'' ';
  OS.SQLSelect(mSQL2,mList2);
  mAccPresetDef:=mList2.strings[0];
  if (mList.count>0) and not(NxIsEmptyOID(mAccPresetDef))then begin

    CFxAccounting.SummaryAccounting('3OKSI2XXYK2OB2JRPZ3U4UXTGK',mlist,0,mAccPresetDef,1,1,1);
  end;
  LogInfoStr := LogInfoStr+'pocet vratek příjemek '+IntToStr(mlist.count);
  mlist.Free;
  mList2.Free;
  mAccPresetDef:='';

end;

begin
end.