uses 'abra.eu.MASK.import_CSV_mzdy.lib';
Const
    ladit=true;
    mfilter='*.csv';
    mdir='C:\abraG3\';
    const01='2OL0000101';// firm_ID
    const02='';      // serviceobject
    const03='';      // firms
    const04='';      // division
    const05='';
    const06='';
    const07='';
    const08='';
    const09='';



Var
    mCustomBusinessObject: TNxCustomBusinessObject;
    mSite: TSiteForm;
    mDBGrid : TDBGrid;
    mTabList: TTabSheet;
    i : integer;
    result:Boolean;
    cHead:string;
    cRow:string ;
    sloupcu:integer;
    mid1,mid2,mid3,mid4:string;
      mcas:string;

procedure On_dochazka(Sender: TComponent;index:integer;);       // přidělení objectspace a zadání zdrojového souboru
var
    zadej:string;
    mfilename:string;
    mdir,mfile:string;
    mfilter:string;
begin
    mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
//    mCustomBusinessObject:= TBusRollSiteForm(mSite).CurrentObject;
    if PromptForFileName(mFileName, mfilter, '', 'Importovaný soubor', mdir, False) then begin
        mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
        mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
        ShowMessage(Format('Bude importován soubor %s %s', [mdir,mfile,]));
    end;
    if index=0 then Import_dosys(msite, TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);
    if index=1 then Import_stravenek(msite, TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);

end;







function Import_stravenek(msite:tsiteform;OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string) : Boolean;
var
    oprava : boolean;
    mImportFile:TStringList;
    mTargetFile:TStringList;
    mRowList:TStringList;
    mFieldHead,mFieldConst,mFieldLabel,mFieldType,mFieldLenght,mfieldValue,mFieldTable,mFieldCLSID,mFieldField,mFieldCreate,mFieldBo:TStringList;
    mDoc,mDocHead,mRows : TNxParameters;
    mStr : string;
    mSList : TStrings;
    Head: String;
    Rows: TStringDynArray;
    pozice:integer;
    zapis:boolean;
    mid :string;
    mtable:string;
    id1,id2,id3,id4,id5,id6,id7,id8,id9:string;
    mExist_ID:string;
    mUserFields:Boolean;
    aa:string;
    mstart:integer;
    mstav:string;
    mStav_ID:string;
    pocet_new,pocet_upd,pocet_err:integer;
    mresult:Boolean;
    mr:TStringList;
    mbo,mBO_mzdove_listy:TNxCustomBusinessObject;
    mPeriod_id,mWagePeriod_ID, mPerson_ID,mWorkingRelationID:string;
    mPerson_number:string;
    mPerson_stravenky:string;
    mOdprac_doba:Double;
begin

    if not FileExists(AFileName) then begin   // soubor nenalezen
      Result := False;
      exit;
    end;
    mbo:=TDynSiteForm(mSite).CurrentObject;
    mBO_mzdove_listy:=os.CreateObject('W1ZICXOZCBF13JXS00KEZYD5AW');
try
    mImportFile := TStringList.Create;
//                                mCustomBusinessObject:= os.CreateObject('OWHN2TMXL2COJJ3LKNBV4OVSTC');

            mImportFile.LoadFromFile(AFileName);
            if mImportFile.Count >1 then begin
                 i := 2;
                 while i < mImportFile.Count do begin

                              if copy(mImportFile.strings[i],1,1)<>';' then begin
                                         if true then begin
                                          //NxShowSimpleMessage(mImportFile.strings[i],nil);

                                            mfieldValue:= TStringList.Create;
                                            Parsevalue(mImportFile.strings[i],';',mImportFile.strings[i],mfieldValue,5);
                                            //NxShowSimpleMessage(inttostr(mfieldValue.Count),nil);


                                            try
                                            //mTargetFile.strings[i]:=mImportFile.strings[i];

                                            mPerson_number:=mfieldValue.Strings[0];
                                            mPerson_stravenky:=mfieldValue.Strings[4];


                                                          if (mPerson_number<>'') and (mPerson_stravenky<>'0') then begin           // číslo čipu
                                                              mr:=TStringList.create;
                                                              try
                                                                  //NxShowSimpleMessage(format('SELECT A.ID FROM WageListPartial A JOIN WorkingRelations WR ON A.WorkingRelation_ID=WR.ID JOIN Employees EMP ON WR.Employee_ID=EMP.ID left join Persons  P on p.id= emp.person_id WHERE (A.WagePeriod_ID = %s ) and (wr.EmployPattern_ID=%s) and (p.PersonalNumber=%s)',
                                                                  //[QuotedStr(mbo.GetFieldValueAsString('WagePeriod_ID')),quotedstr('1000000000'),quotedstr(mPerson_number)]),nil);

                                                                  os.SQLSelect(format('SELECT A.ID FROM WageListPartial A JOIN WorkingRelations WR ON A.WorkingRelation_ID=WR.ID JOIN Employees EMP ON WR.Employee_ID=EMP.ID left join Persons  P on p.id= emp.person_id WHERE (A.WagePeriod_ID = %s ) and (p.PersonalNumber=%s)',
                                                                  [QuotedStr(mbo.GetFieldValueAsString('WagePeriod_ID')),quotedstr(mPerson_number)]),mr );
                                                                  if mr.count>0 then begin
                                                                      mBO_mzdove_listy.load(mr.Strings[0],nil);
                                                                     // if i=120 then begin
                                                                          // NxShowSimpleMessage(mBO_mzdove_listy.GetFieldValueAsString('Employee_ID.Person_ID.FullName'),nil);
                                                                           //NxShowSimpleMessage(mPerson_number + ' - stravenek - ' + (mPerson_stravenky),nil);
                                                                           mBO_mzdove_listy.SetFieldValueAsString('U_MealTicketCount',mPerson_stravenky);
                                                                           mBO_mzdove_listy.save;
                                                                     // end;
                                                                  end;

                                                              finally
                                                                  mr.free;
                                                              end;
                                                           end;
                                            finally ;

                                                    mfieldValue.free;
                                            end;
                                          end;
                                 end;
                      Inc(i, 1);
                    end;

                end;

           finally
              mImportFile.free;
           end;
end;








function Import_dosys(msite:tsiteform;OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string) : Boolean;
var
    oprava : boolean;
    mImportFile:TStringList;
    mTargetFile:TStringList;
    mRowList:TStringList;
    mFieldHead,mFieldConst,mFieldLabel,mFieldType,mFieldLenght,mfieldValue,mFieldTable,mFieldCLSID,mFieldField,mFieldCreate,mFieldBo:TStringList;
    mDoc,mDocHead,mRows : TNxParameters;
    mStr : string;
    mSList : TStrings;
    Head: String;
    Rows: TStringDynArray;
    pozice:integer;
    zapis:boolean;
    mid :string;
    mtable:string;
    id1,id2,id3,id4,id5,id6,id7,id8,id9:string;
    mExist_ID:string;
    mUserFields:Boolean;
    aa:string;
    mstart:integer;
    mstav:string;
    mStav_ID:string;
    pocet_new,pocet_upd,pocet_err:integer;
    mresult:Boolean;
    mr:TStringList;
    mbo,mBO_mzdove_listy:TNxCustomBusinessObject;
    mPeriod_id,mWagePeriod_ID, mPerson_ID,mWorkingRelationID:string;
    mChip:string;
    mOdprac_doba:Double;
    mSCas:string;
    mFCas, mkorekce:double;
    mprac_doba:double;
begin

    if not FileExists(AFileName) then begin   // soubor nenalezen
      Result := False;
      exit;
    end;
    mbo:=TDynSiteForm(mSite).CurrentObject;
    mBO_mzdove_listy:=TDynSiteForm(mSite).CurrentObject;
try
    mImportFile := TStringList.Create;
//                                mCustomBusinessObject:= os.CreateObject('OWHN2TMXL2COJJ3LKNBV4OVSTC');

            mImportFile.LoadFromFile(AFileName);
            if mImportFile.Count >1 then begin
                 i := 0;
                 while i < mImportFile.Count do begin

                    try
                                mfieldValue:= TStringList.Create;
                                //mTargetFile.strings[i]:=mImportFile.strings[i];
                                Parsevalue(mImportFile.strings[i],';',mImportFile.strings[i],mfieldValue,12);
                      mkorekce:=0;



                                              if mfieldValue.Strings[0]<>'' then begin           // číslo čipu
                                                  mr:=TStringList.create;
                                                  try
                                                      os.SQLSelect(format('SELECT A.ID FROM WageListPartial A JOIN WorkingRelations WR ON A.WorkingRelation_ID=WR.ID JOIN Employees EMP ON WR.Employee_ID=EMP.ID left join Persons  P on p.id= emp.person_id JOIN WagePeriods WP ON A.WagePeriod_ID=WP.ID WHERE (A.WagePeriod_ID = %s ) and (wr.EmployPattern_ID=%s) and (p.PersonalNumber=%s)',
                                                      [QuotedStr(mbo.GetFieldValueAsString('WagePeriod_ID')),quotedstr('1000000000'),quotedstr(mfieldValue.Strings[0])]),mr );
                                                      if mr.count>0 then begin
                                                          mBO_mzdove_listy.load(mr.Strings[0],nil);
                                                          mprac_doba:=0;
                                                          mprac_doba:=(mBO_mzdove_listy.GetFieldValueAsFloat('Calendarduty') / 5);

                                                          //  NxShowSimpleMessage(mBO_mzdove_listy.oid,nil);

                                                                // odpracovaný čas


                                                                  // odpracovaný LE lékař
                                                                  if mfieldValue.Strings[5] <> '00:00:00' then begin
                                                                      mFcas:=0;
                                                                          mScas:= mfieldValue.Strings[5] ;
                                                                           mFcas:=NxIBStrToFloat(copy(mScas, 1, pos(':', mScas) - 1)) + (NxIBStrToFloat(copy(mScas, (pos(':', mScas) + 1),2 )) / 60);

                                                                            mkorekce:=mkorekce+ mFcas;

                                                                            //nxshowsimplemessage('Lékař:' + nxfloattoibstr(mFcas),nil);
                                                                           mBO_mzdove_listy.setfieldvalueasfloat('S_PaidFree',mFcas);
                                                                  end;

                                                                   // odpracovaný JI  jiný
                                                                  if mfieldValue.Strings[6] <> '00:00:00' then begin
                                                                      mFcas:=0;
                                                                          mScas:= mfieldValue.Strings[6] ;
                                                                        mFcas:=NxIBStrToFloat(copy(mScas, 1, pos(':', mScas) - 1)) + (NxIBStrToFloat(copy(mScas, (pos(':', mScas) + 1),2 )) / 60);
                                                                         mBO_mzdove_listy.setfieldvalueasfloat('U_PaidFreeSpedos',mFcas);
                                                                  end;


                                                                  //  odpracovaný DO      dovolená
                                                                  if mfieldValue.Strings[7] <> '00:00:00' then begin
                                                                      mFcas:=0;
                                                                          mScas:= mfieldValue.Strings[7] ;
                                                                       mFcas:=(NxIBStrToFloat(copy(mScas, 1, pos(':', mScas) - 1)) + (NxIBStrToFloat(copy(mScas, (pos(':', mScas) + 1),2 )) / 60))/mprac_doba;
                                                                              mBO_mzdove_listy.setfieldvalueasfloat('S_Holiday',(mFcas));
                                                                            //   mBO_mzdove_listy.setfieldvalueasfloat('S_HolidayDrawHours',mFcas);
                                                                            //  mBO_mzdove_listy.setfieldvalueasfloat('S_HolidayHours',mFcas);

                                                                        //nxshowsimplemessage('Dovolená:' + nxfloattoibstr(mFcas),nil);
                                                                  end;
                                                                      {

                                                                    odpracovaný NE       nemoc
                                                                  if mfieldValue.Strings[8] <> '00:00' then begin
                                                                      mFcas:=0;
                                                                          mScas:= mfieldValue.Strings[8] ;
                                                                          mFcas:=nxstrtoint(copycopy(mScas, 1, pos(':', mScas) - 1)) + (nxstrtoint(copy(mScas, pos(':', mScas) + 1),2 ) / 60) ;
                                                                      mBO_mzdove_listy.setfieldvalueasfloat('S_WorkHours',mFcas);
                                                                  end;


                                                                   // odpracovaný NP             nepřítomnost
                                                                  if mfieldValue.Strings[9] <> '00:00' then begin
                                                                      mFcas:=0;
                                                                          mScas:= mfieldValue.Strings[9] ;
                                                                          mFcas:=nxstrtoint(copycopy(mScas, 1, pos(':', mScas) - 1)) + (nxstrtoint(copy(mScas, pos(':', mScas) + 1),2 ) / 60) ;
                                                                      mBO_mzdove_listy.setfieldvalueasfloat('S_WorkHours',mFcas);
                                                                  end;
                                                                                }
                                                                     //odpracovaný STravne
                                                                  if (mfieldValue.Strings[10] <> '0') and (mfieldValue.Strings[10] <> '')then begin

                                                                          mBO_mzdove_listy.setfieldvalueasfloat('U_MealTicketCount',strtoint(mfieldValue.Strings[10]));
                                                                  end;

                                                                   // odpracovaný so+ne  jiný
                                                                  if mfieldValue.Strings[11] <> '00:00:00' then begin
                                                                      mFcas:=0;
                                                                          mScas:= mfieldValue.Strings[11] ;
                                                                        mFcas:=NxIBStrToFloat(copy(mScas, 1, pos(':', mScas) - 1)) + (NxIBStrToFloat(copy(mScas, (pos(':', mScas) + 1),2 )) / 60);
                                                                         mBO_mzdove_listy.setfieldvalueasfloat('S_WEndHours',mFcas);
                                                                  end;








                                                                 if mfieldValue.Strings[4] <> '00:00' then begin
                                                                          mFcas:=0;
                                                                          mScas:= mfieldValue.Strings[4] ;
                                                                          mFcas:=NxIBStrToFloat(copy(mScas, 1, pos(':', mScas) - 1)) + (NxIBStrToFloat(copy(mScas, (pos(':', mScas) + 1),2 )) / 60);

                                                                       //nxshowsimplemessage(nxfloattoibstr(mFcas),nil);

                                                                  if (mBO_mzdove_listy.GetFieldValueAsString('WorkingRelation_ID.WorkPosition_ID')='0100000101') or
                                                                           (mBO_mzdove_listy.GetFieldValueAsString('WorkingRelation_ID.WorkPosition_ID')='1100000101') then  begin
                                                                           mBO_mzdove_listy.setfieldvalueasfloat('S_MealTicketDemand',strtoint(mfieldValue.Strings[10]));
                                                                  end
                                                                  else
                                                                      mBO_mzdove_listy.setfieldvalueasfloat('S_WorkHours',mFcas-mkorekce)
                                                                  end;




                                                      mBO_mzdove_listy.save;

                                                      end;




                                                  finally
                                                      mr.free;
                                                  end;


                                            end;


                      finally

                    mfieldValue.free;
                      end;

                Inc(i, 1);
              end;

           end;

           finally
              mImportFile.free;
           end;
end;












{
Vyvoláva sa po vykonaní inicializácie agendy/formulára. V tomto okamihu je už na formulári dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter:Boolean;
  mUserFilterTL:string;
begin
    {mUserFilter:=true;
    mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            mUserFilter:= mUser.GetFieldValueAsBoolean('ShortName');
            mUserFilterTL:= copy(mUser.GetFieldValueAsstring('ShortName'),1,1);
    finally
      mUser.Free;
    end;
        if (mUserFilterTL='S') or (mUserFilterTL='L')  then begin  }
          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Docházkový systém';
          mMAction.Caption := 'Docházkový sytém';
          mMAction.Items.Add('Import docházky');
          mMAction.Items.Add('Import Stravní jednotky');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @On_dochazka;
{        end;}
end;



begin
end.