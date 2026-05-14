uses 'abra.eu.mask.Spedos.Servis.2016.Import.lib';

procedure ZpracujSouborZFronty_SP_V (OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string;msite:TBusRollSiteForm);
begin
  ProcessContinue := Import_SP_V(OS, Directory + '\' + FileName,Directory,filename,msite,False,false);
end;

procedure ZpracujSouborZFronty_SP_OD (OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string;msite:TBusRollSiteForm);
begin
  ProcessContinue := Import_SP_OD(OS, Directory + '\' + FileName,Directory,filename,msite,True,false);

end;


function Import_SP_V(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TSiteForm;rucne:boolean;chyba:boolean) : Boolean;
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
    mr,mr1:TStringList;
    mCustomBusinessObject:TNxCustomBusinessObject;
    mzacatek:boolean;
    moddelovac:string;
    mstartparam:integer;
    mBO_DF,mBO1_DF,mBO_BusOrder:TNxCustomBusinessObject;
    mprobehlo,mpokracuj:Boolean;

begin

    if not FileExists(AFileName) then begin   // soubor nenalezen
      Result := False;
      exit;
    end;
try
    mProbehlo:=true;
    mzacatek:=false;
    mImportFile := TStringList.Create;


            mImportFile.LoadFromFile(AFileName);
            if (mImportFile.Count>0) then begin
                 i := 0;
                 while i < mImportFile.Count-1 do begin

                          if mzacatek=false then begin

                                   mImportFile.strings[i]:= NxSearchReplace(mImportFile.strings[i],'"','',2);
//                                   if copy(mImportFile.strings[i],1,1)='"' then mImportFile.strings[i]:=copy(mImportFile.strings[i],2,Length(mImportFile.strings[i]))   ;

                                    if copy(mImportFile.strings[i],1,3)='ID;' then begin
                                       //NxShowSimpleMessage(mImportFile.strings[i],nil);
                                       //NxShowSimpleMessage('ID střednik',nil);
                                       mfieldhead:= TStringList.Create;
                                       try
                                           moddelovac:=';';
                                           Parsevalue(mDocHead, NxSearchReplace(mImportFile.strings[i],'"','',2),';',NxSearchReplace(mImportFile.strings[i],'"','',2),mFieldHead,NxCharCount(moddelovac,mImportFile.strings[i]));
                                           mzacatek:=true;
                                           i:=i+1;

                                       finally

                                       end;
                                    end;

                          end;


                          if mzacatek and (copy(mImportFile.strings[i],3,1)<>moddelovac)  then begin
                                mfieldValue:= TStringList.Create;
                                        //mTargetFile.strings[i]:=mImportFile.strings[i];
                                        mImportFile.strings[i]:= NxSearchReplace(mImportFile.strings[i],'"','',2);

                                        if copy(mImportFile.strings[i],1,1)='"' then copy(mImportFile.strings[i],2,Length(mImportFile.strings[i]))   ;
                                        //NxShowSimpleMessage(mImportFile.strings[i],nil);
                               Parsevalue(mDocHead, mImportFile.strings[i],moddelovac,mImportFile.strings[i],mfieldValue,NxCharCount(';',mImportFile.strings[i]));
                                try
                                  mExist_ID:='';

                                  //NxShowSimpleMessage(mFieldHead.Strings[0] + ' - ' +mfieldValue.Strings[0],nil);
                                  //NxShowSimpleMessage('select id from ServicedObjects where hidden=' + quotedstr('N') + ' and X_ID_obchodni_dokumentace='+quotedstr(Trim(copy(mFieldvalue.Strings[0],1,20))),nil);
                                  if (mFieldHead.Strings[0]='"ID') or (mFieldHead.Strings[0]='ID') then begin
                                      mr:=TStringList.create;
                                         try
                                             os.SQLSelect('select id from ServicedObjects where hidden=' + quotedstr('N') +
                                             ' and X_ID_Obchodni_dokumentace='+quotedstr(Trim(copy(mFieldvalue.Strings[0],1,8))) +


                                             ,mr);
                                             if mr.count>0 then begin
                                                 mExist_ID:=mr.Strings[0];
                                            end;
                                         finally
                                            mr.free;
                                         end;

                                  end;

                                  if mExist_ID<>'' then begin
                                     mCustomBusinessObject:= os.CreateObject('OWHN2TMXL2COJJ3LKNBV4OVSTC');
                                     try
                                        mCustomBusinessObject.load(mExist_ID,nil);
                                        //NxShowSimpleMessage('SC - ' +Trim(copy(mFieldvalue.Strings[1],1,20)),nil);
                                        mCustomBusinessObject.SetFieldValueAsString('Code',Trim(copy(mFieldvalue.Strings[1],1,20)));
                                        mCustomBusinessObject.Save;
                                        if (not mpokracuj) or (not mprobehlo) then mprobehlo:=False;
                                        mExist_ID:=mCustomBusinessObject.oid;
                                     finally
                                        mCustomBusinessObject.free;
                                     end
                                    // NxShowSimpleMessage('Předmět byl založen',nil);




                                  end else begin
                                     mCustomBusinessObject:= os.CreateObject('OWHN2TMXL2COJJ3LKNBV4OVSTC');
                                     try
                                     mCustomBusinessObject.New;
                                     mCustomBusinessObject.Prefill;
                                     if Length(mFieldvalue.Strings[0])=8 then begin
                                          mCustomBusinessObject.SetFieldValueAsString('X_ID_Obchodni_dokumentace',mFieldvalue.Strings[0]) ;
                                     end else begin
                                          mCustomBusinessObject.SetFieldValueAsString('X_ID_Obchodni_dokumentace',
                                          'S' + nxpadl(Trim(copy(mFieldvalue.Strings[0],1,7)),7,'0'));
                                     end;
                                     mCustomBusinessObject.SetFieldValueAsString('Code',Trim(copy(mFieldvalue.Strings[1],1,20)));
                                     mCustomBusinessObject.SetFieldValueAsString('Name',Trim(copy(mFieldvalue.Strings[1],1,20)));
                                     mCustomBusinessObject.SetFieldValueAsString('Firm_ID','3X23000101');

                                     mCustomBusinessObject.Save;
                                        if (not mpokracuj) or (not mprobehlo) then mprobehlo:=False;
                                     mExist_ID:=mCustomBusinessObject.oid;
                                     finally
                                        mCustomBusinessObject.free;
                                     end
                                    // NxShowSimpleMessage('Předmět byl založen',nil);
                                  end;




                                     if mExist_ID<>'' then begin
                                            mCustomBusinessObject:= os.CreateObject('OWHN2TMXL2COJJ3LKNBV4OVSTC');
                                            try
                                                    mCustomBusinessObject.Load(mExist_ID,nil);

                                                    mCustomBusinessObject.SetFieldValueAsString('Code',Trim(copy(mFieldvalue.Strings[1],1,20)));
                                                  {  if not nxisblank(mFieldvalue.Strings[3]) then mCustomBusinessObject.SetFieldValueAsString('X_par1',trim(mFieldvalue.Strings[3]));

                                                    if mfieldValue.count>=4 then if not nxisblank(mFieldvalue.Strings[4]) then mCustomBusinessObject.SetFieldValueAsString('X_par2',trim(mFieldvalue.Strings[4]));
                                                    if mfieldValue.count>=5 then if not nxisblank(mFieldvalue.Strings[5]) then mCustomBusinessObject.SetFieldValueAsString('X_par3',trim(mFieldvalue.Strings[5]));
                                                    if mfieldValue.count>=6 then if not nxisblank(mFieldvalue.Strings[6]) then mCustomBusinessObject.SetFieldValueAsString('X_par4',trim(mFieldvalue.Strings[6]));
                                                    if mfieldValue.count>=7 then if not nxisblank(mFieldvalue.Strings[7]) then mCustomBusinessObject.SetFieldValueAsString('X_par5',trim(mFieldvalue.Strings[7]));
                                                    if mfieldValue.count>=8 then if not nxisblank(mFieldvalue.Strings[8]) then mCustomBusinessObject.SetFieldValueAsString('X_par6',trim(mFieldvalue.Strings[8]));
                                                    if mfieldValue.count>=9 then if not nxisblank(mFieldvalue.Strings[9]) then mCustomBusinessObject.SetFieldValueAsString('X_par7',trim(mFieldvalue.Strings[9]));
                                                    if mfieldValue.count>=10 then if not nxisblank(mFieldvalue.Strings[10]) then mCustomBusinessObject.SetFieldValueAsString('X_par8',trim(mFieldvalue.Strings[10]));
                                                    if mfieldValue.count>=11 then if not nxisblank(mFieldvalue.Strings[11]) then mCustomBusinessObject.SetFieldValueAsString('X_par9',trim(mFieldvalue.Strings[11]));
                                                    if mfieldValue.count>=12 then if not nxisblank(mFieldvalue.Strings[12]) then mCustomBusinessObject.SetFieldValueAsString('X_par10',trim(mFieldvalue.Strings[12]));
                                                    if mfieldValue.count>=13 then if not nxisblank(mFieldvalue.Strings[13]) then mCustomBusinessObject.SetFieldValueAsString('X_par11',trim(mFieldvalue.Strings[13]));
                                                    if mfieldValue.count>=14 then if not nxisblank(mFieldvalue.Strings[14]) then mCustomBusinessObject.SetFieldValueAsString('X_par12',trim(mFieldvalue.Strings[14]));
                                                    if mfieldValue.count>=15 then if not nxisblank(mFieldvalue.Strings[15]) then mCustomBusinessObject.SetFieldValueAsString('X_par13',trim(mFieldvalue.Strings[15]));
                                                    if mfieldValue.count>=16 then if not nxisblank(mFieldvalue.Strings[16]) then mCustomBusinessObject.SetFieldValueAsString('X_par14',trim(mFieldvalue.Strings[16]));
                                                    if mfieldValue.count>=17 then if not nxisblank(mFieldvalue.Strings[17]) then mCustomBusinessObject.SetFieldValueAsString('X_par15',trim(mFieldvalue.Strings[17]));
                                                    if mfieldValue.count>=18 then if not nxisblank(mFieldvalue.Strings[18]) then mCustomBusinessObject.SetFieldValueAsString('X_par16',trim(mFieldvalue.Strings[18]));
                                                    if mfieldValue.count>=19 then if not nxisblank(mFieldvalue.Strings[19]) then mCustomBusinessObject.SetFieldValueAsString('X_par17',trim(mFieldvalue.Strings[19]));
                                                    if mfieldValue.count>=20 then if not nxisblank(mFieldvalue.Strings[20]) then mCustomBusinessObject.SetFieldValueAsString('X_par18',trim(mFieldvalue.Strings[20]));
                                                    if mfieldValue.count>=21 then if not nxisblank(mFieldvalue.Strings[21]) then mCustomBusinessObject.SetFieldValueAsString('X_par19',trim(mFieldvalue.Strings[21]));
                                                    if mfieldValue.count>=22 then if not nxisblank(mFieldvalue.Strings[22]) then mCustomBusinessObject.SetFieldValueAsString('X_par20',trim(mFieldvalue.Strings[22]));
                                                    if mfieldValue.count>=23 then if not nxisblank(mFieldvalue.Strings[23]) then mCustomBusinessObject.SetFieldValueAsString('X_par21',trim(mFieldvalue.Strings[23]));
                                                    if mfieldValue.count>=24 then if not nxisblank(mFieldvalue.Strings[24]) then mCustomBusinessObject.SetFieldValueAsString('X_par22',trim(mFieldvalue.Strings[24]));
                                                    if mfieldValue.count>=25 then if not nxisblank(mFieldvalue.Strings[25]) then mCustomBusinessObject.SetFieldValueAsString('X_par23',trim(mFieldvalue.Strings[25]));
                                                    if mfieldValue.count>=26 then if not nxisblank(mFieldvalue.Strings[26]) then mCustomBusinessObject.SetFieldValueAsString('X_par24',trim(mFieldvalue.Strings[26]));
                                                    if mfieldValue.count>=29 then if not nxisblank(mFieldvalue.Strings[27]) then mCustomBusinessObject.SetFieldValueAsString('X_par25',trim(mFieldvalue.Strings[27]));
                                                    if mfieldValue.count>=28 then if not nxisblank(mFieldvalue.Strings[28]) then mCustomBusinessObject.SetFieldValueAsString('X_par26',trim(mFieldvalue.Strings[28]));
                                                    if mfieldValue.count>=29 then if not nxisblank(mFieldvalue.Strings[29]) then mCustomBusinessObject.SetFieldValueAsString('X_par27',trim(mFieldvalue.Strings[29]));
                                                    if mfieldValue.count>=30 then if not nxisblank(mFieldvalue.Strings[30]) then mCustomBusinessObject.SetFieldValueAsString('X_par28',trim(mFieldvalue.Strings[30]));
                                                    if mfieldValue.count>=31 then if not nxisblank(mFieldvalue.Strings[31]) then mCustomBusinessObject.SetFieldValueAsString('X_par29',trim(mFieldvalue.Strings[31]));
                                                    if mfieldValue.count>=32 then if not nxisblank(mFieldvalue.Strings[32]) then mCustomBusinessObject.SetFieldValueAsString('X_par30',trim(mFieldvalue.Strings[32]));
                                                    if mfieldValue.count>=33 then if not nxisblank(mFieldvalue.Strings[33]) then mCustomBusinessObject.SetFieldValueAsString('X_par31',trim(mFieldvalue.Strings[33]));
                                                    if mfieldValue.count>=34 then if not nxisblank(mFieldvalue.Strings[34]) then mCustomBusinessObject.SetFieldValueAsString('X_par32',trim(mFieldvalue.Strings[34]));
                                                    if mfieldValue.count>=35 then if not nxisblank(mFieldvalue.Strings[35]) then mCustomBusinessObject.SetFieldValueAsString('X_par33',trim(mFieldvalue.Strings[35]));
                                                    if mfieldValue.count>=36 then if not nxisblank(mFieldvalue.Strings[36]) then mCustomBusinessObject.SetFieldValueAsString('X_par34',trim(mFieldvalue.Strings[36]));
                                                    // if not nxisblank(mFieldvalue.Strings[35]) then mCustomBusinessObject.SetFieldValueAsString('X_par35',mFieldvalue.Strings[35]);
                                                    // if not nxisblank(mFieldvalue.Strings[36]) then mCustomBusinessObject.SetFieldValueAsString('X_par36',mFieldvalue.Strings[36]);
                                                    // if not nxisblank(mFieldvalue.Strings[37]) then mCustomBusinessObject.SetFieldValueAsString('X_par37',mFieldvalue.Strings[37]);}
                                                    result:=setParameter(os,mExist_ID,'V',mFieldHead,mfieldValue);





                                                    for II:=0 to mFieldHead.count-1 do begin

                                                           mstartparam:=ii;
                                                           if (mFieldHead.Strings[ii]='zakázka číslo') then begin

                                                              if not nxisblank(mfieldValue.Strings[ii]) then begin
                                                                      mID:='';
                                                                      mID:=getIDfromfield(os,'ID','BusOrders','Code',mfieldValue.Strings[ii],'Hidden','N');
                                                                      if NxIsEmptyOID(mID) then begin
                                                                          mBO_BusOrder:=os.CreateObject('K2WTYL304VD13ACL03KIU0CLP4');
                                                                          try
                                                                             mBO_BusOrder.new;
                                                                             mBO_BusOrder.Prefill;
                                                                             mBO_BusOrder.SetFieldValueAsString('Code',mfieldValue.Strings[ii]);
                                                                             mBO_BusOrder.SetFieldValueAsString('Name',mfieldValue.Strings[ii]);
                                                                             mBO_BusOrder.save;
                                                                             mid:=mBO_BusOrder.oid;
                                                                          finally
                                                                             mBO_BusOrder.free;
                                                                          end;
                                                                      end;
                                                                      mCustomBusinessObject.setfieldvalueasstring('BusOrder_ID',mID);

                                                              end;
                                                           end;
                                                    end;

                                                mCustomBusinessObject.Save;
                                                    if (not mpokracuj) or (not mprobehlo) then mprobehlo:=False;
                                            finally
                                                mCustomBusinessObject.free;

                                            end ;


                                     end;

                                finally
                                    mfieldValue.free;
                                end;
                          end ;    // mzacatek
                        Inc(i, 1);






                end;   // while
                                      result:=nxcopyfile(AFileName,Directory + '\Zpracovane\' + FileName);
                                                if result then begin
                                                    DeleteFile(AFileName);
                                                    if rucne and result and chyba then begin
                                                          // NxShowSimpleMessage('Soubor ' + afilename + ' byl přesunut do zpracovaných',nil);
                                                    end;
                                                end;

      end;
    finally
    end;
end;






function Import_SP_OD(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TSiteForm;rucne:boolean;chyba:boolean) : Boolean;
var
mID_SP,mID:string;
mUmisteni,mSmlouva,MPlatce:string;
mUmisteniPerson,mSmlouvaPerson,MPlatcePerson:string;
mr:tstringlist;
mBO_DF,mBO1_DF,mBO_BusOrder:TNxCustomBusinessObject;
mdate:double;
mstart:string;
mresult:boolean;
mboNew_SL,mbo_ML:TNxCustomBusinessObject;
mr1,mr2,mr3:TStringList;
mprobehlo,mpokracuj:boolean;
begin
    if (not FileExists(AFileName)) and (copy(AFileName,1,2)<>'SK') then begin
      Result := False;
      exit;
    end;

    try
      mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(AFileName);

  //      NxShowSimpleMessage('Počet SP' + inttostr(mXMLHead.getElementsCountInArray('Vyrobek')) ,nil);
        mstart:='0';
  //      mresult:=InputQuery('ZAdej','Start',mstart);

          for i := strtoint(mstart) to mXMLHead.getElementsCountInArray('Vyrobek') - 1 do begin
                mID_SP:='';
                mUmisteni:='';
                mSmlouva:='';
                mPlatce:='';
                mUmisteniPerson:='';
                mSmlouvaPerson:='';
                mPlatcePerson:='';
                if mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].id')<>'' then

               mr:=TStringList.create;
                                         try
                                             os.SQLSelect('select id from ServicedObjects where hidden=' + quotedstr('N') +
                                             ' and X_ID_Obchodni_dokumentace='+quotedstr(Trim(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].id'),1,8))) +


                                             ,mr);
                                             if mr.count>0 then begin
                                                 mID_SP:=mr.Strings[0];
                                            end else begin
                                               mpokracuj:=false;
                                            end;
                                         finally
                                            mr.free;
                                         end;



                //mID_SP:=getIDfromfield(os,'ID','ServicedObjects','X_ID_Obchodni_dokumentace',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].id'),'Hidden','N');



                if mID_SP='' then begin
                     if mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].vyrobni_cislo')<>'' then mID_SP:=getIDfromfield(os,'ID','ServicedObjects','Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].vyrobni_cislo'),'Hidden','N');
                end;
                try

                      if mID_SP='' then begin
                                // if rucne and chyba then NxShowSimpleMessage('Novy',nil);
                                 mbo_SP:=os.CreateObject('OWHN2TMXL2COJJ3LKNBV4OVSTC');
                                 try
                                            mbo_SP.new;
                                           mbo_sp.prefill;
                                           mbo_sp.setfieldvalueasstring('Code',copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].vyrobni_cislo'),1,20));
                                           mbo_sp.setfieldvalueasstring('Name',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zarizeni'));

                                          if Length(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].ID'))=8 then begin
                                                mbo_sp.SetFieldValueAsString('X_ID_Obchodni_dokumentace',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].ID')) ;
                                          end else begin
                                              mbo_sp.SetFieldValueAsString('X_ID_Obchodni_dokumentace',
                                              'S' + nxpadl(Trim(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].ID'),1,7)),7,'0'));
                                          end;



                                           mbo_sp.setfieldvalueasstring('Firm_ID','3X23000101');
                                           mbo_sp.setfieldvalueasstring('PayerFirm_ID','3X23000101');
                                           if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].pozice_umisteni')) and nxisblank(mbo_sp.getfieldvalueasstring('OutdoorPlaceDescription')) then begin
                                                  mbo_sp.setfieldvalueasstring('OutdoorPlaceDescription',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].pozice_umisteni'));
                                           end;
                                           // zakazka
                                           if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka')) then begin
                                                  mID:='';
                                                  mID:=getIDfromfield(os,'ID','BusOrders','Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka'),'Hidden','N');
                                                  if NxIsEmptyOID(mID) then begin
                                                      mBO_BusOrder:=os.CreateObject('K2WTYL304VD13ACL03KIU0CLP4');
                                                      try
                                                         mBO_BusOrder.new;
                                                         mBO_BusOrder.Prefill;
                                                         mBO_BusOrder.SetFieldValueAsString('Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka'));
                                                         mBO_BusOrder.SetFieldValueAsString('Name', mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.name')+','+
                                                                 mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.mesto'));

                                                         mBO_BusOrder.save;
                                                         mid:=mBO_BusOrder.oid;
                                                      finally
                                                         mBO_BusOrder.free;
                                                      end;
                                                  end;
                                                  mbo_sp.setfieldvalueasstring('BusOrder_ID',mID);
                                           end;
                                            mbo_SP.save;
                                            if (not mpokracuj) or (not mprobehlo) then mprobehlo:=False;
                                            mID_SP:=mbo_SP.oid;
                                  finally
                                      mbo_SP.free;
                                  end;
                      end;



                      if mID_SP<>'' then begin
                               ii:=0;
                                 mbo_sp:=os.CreateObject('OWHN2TMXL2COJJ3LKNBV4OVSTC');
                                 try
                                             mbo_sp.load(mID_SP,nil);
                                             if NxIsEmptyOID(mbo_sp.getfieldvalueasstring('Firm_ID')) then mbo_sp.setfieldvalueasstring('Firm_ID','3X23000101');
                                             if NxIsEmptyOID(mbo_sp.getfieldvalueasstring('PayerFirm_ID')) then mbo_sp.setfieldvalueasstring('PayerFirm_ID','3X23000101');

                                             if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].ID')) and nxisblank(mbo_sp.getfieldvalueasstring('X_ID_Obchodni_dokumentace')) then
                                                    mbo_sp.setfieldvalueasstring('X_ID_Obchodni_dokumentace',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].ID'));

                                             if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].vyrobni_cislo')) and nxisblank(mbo_sp.getfieldvalueasstring('Code')) then
                                                    mbo_sp.setfieldvalueasstring('Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].vyrobni_cislo'));




                                             if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].vyrobni_cislo')) then  begin
                                                    mbo_sp.setfieldvalueasstring('Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].vyrobni_cislo'));
                                             end;
                                             if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zarizeni')) and nxisblank(mbo_sp.getfieldvalueasstring('Name')) then  begin
                                                    mbo_sp.setfieldvalueasstring('Name',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zarizeni'));

                                             end;
                                             if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].pozice_umisteni')) and nxisblank(mbo_sp.getfieldvalueasstring('OutdoorPlaceDescription')) then begin
                                                    mbo_sp.setfieldvalueasstring('OutdoorPlaceDescription',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].pozice_umisteni'));
                                             end;

                                             // zakazka
                                             if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka')) then begin
                                                    mID:='';
                                                    mID:=getIDfromfield(os,'ID','BusOrders','Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka'),'Hidden','N');
                                                    if NxIsEmptyOID(mID) then begin
                                                        mBO_BusOrder:=os.CreateObject('K2WTYL304VD13ACL03KIU0CLP4');
                                                        try
                                                           mBO_BusOrder.new;
                                                           mBO_BusOrder.Prefill;
                                                           mBO_BusOrder.SetFieldValueAsString('Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka'));
                                                           mBO_BusOrder.SetFieldValueAsString('Name',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zarizeni'));
                                                           mBO_BusOrder.save;
                                                           mid:=mBO_BusOrder.oid;
                                                        finally
                                                           mBO_BusOrder.free;
                                                        end;
                                                    end;
                                                    mbo_sp.setfieldvalueasstring('BusOrder_ID',mID);
                                             end;

                                             // zarizeni
                                             if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zarizeni')) then begin
                                                    mID:='';
                                                    mID:=getIDfromfieldDF(os,'ID','DefRollData','Name',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zarizeni'),'Hidden','N','CLSID','PYD4LSZKL3D4VAGRWITAALLUD4');
                                                    if mID<>'' then begin
                                                        mbo_sp.setfieldvalueasstring('X_zarizeni_ID',mID);
                                                    end;
                                             end;
                                             // Výrobce
                                             if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].vyrobce')) then begin
                                                    mID:='';
                                                    mID:=getIDfromfieldDF(os,'ID','DefRollData','Name',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].vyrobce'),'Hidden','N','CLSID','PYD4LSZKL3D4VAGRWITAALLUD4');
                                                    if mID<>'' then begin
                                                       mbo_sp.setfieldvalueasstring('X_Vyrobce_ID',mID);
                                                    end;
                                             end;
                                             // Typ
                                             if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].typ_zarizeni')) then begin
                                                    mID:='';
                                                    mID:=getIDfromfieldDF(os,'ID','DefRollData','Name',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].typ_zarizeni'),'Hidden','N','CLSID','PYD4LSZKL3D4VAGRWITAALLUD4');
                                                    if mID<>'' then begin
                                                       mbo_sp.setfieldvalueasstring('X_typ_zarizeni_ID',mID);
                                                    end;
                                             end;

                                             if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zaruka_pohyb_dily'))  then begin
                                                    mbo_sp.setfieldvalueasstring('X_zaruka_elektro',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zaruka_pohyb_dily'));
                                             end;
                                             if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zaruka_pevne_dily')) then begin
                                                    mbo_sp.setfieldvalueasstring('X_zaruka_pevne_dily',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zaruka_pevne_dily'));
                                             end;


                                              if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].vyrobce')) and nxisblank(mbo_sp.getfieldvalueasstring('X_New_Vyrobce')) then begin
                                                    mbo_sp.setfieldvalueasstring('X_New_Vyrobce',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].vyrobce'));
                                              end;
                                              if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka')) and nxisblank(mbo_sp.getfieldvalueasstring('X_New_BusOrder')) then begin
                                                    mbo_sp.setfieldvalueasstring('X_New_BusOrder',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka'));
                                                   ;
                                              end;
                                              if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].obchodni_pripad')) and nxisblank(mbo_sp.getfieldvalueasstring('X_New_BusTransaction')) then   begin
                                                    mbo_sp.setfieldvalueasstring('X_New_BusTransaction',copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].obchodni_pripad'),1,30));
                                              end;
                                              if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].typ_zarizeni')) and nxisblank(mbo_sp.getfieldvalueasstring('X_NewTyp_zarizeni')) then  begin
                                                    mbo_sp.setfieldvalueasstring('X_NewTyp_zarizeni',copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].typ_zarizeni'),1,30));
                                              end;







                                             if mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].termin_pozice')<>'' then begin
                                                mdate:=0;
                                               if IsValidDate(strtoint(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].termin_pozice'),1,4)),
                                                              strtoint(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].termin_pozice'),6,2)),
                                                              strtoint(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].termin_pozice'),9,2))) then begin
                                                        mdate:= EncodeDate(strtoint(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].termin_pozice'),1,4)),strtoint(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].termin_pozice'),6,2)),strtoint(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].termin_pozice'),9,2)));
                                                        mbo_sp.setfieldvalueasdatetime('X_Datum_montaze',mdate);
                                               end;





                                             end;
                                             if mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].datum_vyroby_pozice')<>'' then begin
                                                //mbo_sp.setfieldvalueasinteger('ProductionYear',StrToInt(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].datum_vyroby_pozice'),1,4)));
                                             end;



                                                    if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.Name')) then begin
                                                        mUmisteni:=mUmisteni+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.ICO');
                                                        mUmisteni:=mUmisteni+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.dic');

                                                        mUmisteni:=mUmisteni+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.name');
                                                        mUmisteni:=mUmisteni+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.ulice');
                                                        mUmisteni:=mUmisteni+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.mesto');
                                                        mUmisteni:=mUmisteni+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.psc');
                                                        mUmisteni:=mUmisteni+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.tel');
                                                        mUmisteni:=mUmisteni+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.email');
                                                        mUmisteni:=mUmisteni+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.mobil');
                                                        mUmisteni:=mUmisteni+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.fax');
                                                        mbo_sp.setfieldvalueasstring('U_Umisteni_OD',copy(mumisteni,1,250));

                                                    end;

                                                    if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.osoba.prijmeni')) then begin
                                                        mUmisteniPerson:=mUmisteniPerson+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.osoba.titul');
                                                        mUmisteniPerson:=mUmisteniPerson+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.osoba.jmeno');

                                                        mUmisteniPerson:=mUmisteniPerson+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.osoba.prijmeni');
                                                        mUmisteniPerson:=mUmisteniPerson+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.osoba.ulice');
                                                        mUmisteniPerson:=mUmisteniPerson+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.osoba.mesto');
                                                        mUmisteniPerson:=mUmisteniPerson+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.osoba.psc');
                                                        mUmisteniPerson:=mUmisteniPerson+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.osoba.tel');
                                                        mUmisteniPerson:=mUmisteniPerson+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.osoba.email');
                                                        mUmisteniPerson:=mUmisteniPerson+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.osoba.mobil');
                                                        mUmisteniPerson:=mUmisteniPerson+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.osoba.fax');
                                                        mbo_sp.setfieldvalueasstring('U_UmisteniPerson_OD',copy(mUmisteniPerson,1,250));
                                                    end;

                                                     if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.firma.Name')) then begin
                                                        mPlatce:=mPlatce+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.firma.ICO');
                                                        mPlatce:=mPlatce+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.firma.dic');

                                                        mPlatce:=mPlatce+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.firma.name');
                                                        mPlatce:=mPlatce+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.firma.ulice');
                                                        mPlatce:=mPlatce+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.firma.mesto');
                                                        mPlatce:=mPlatce+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.firma.psc');
                                                        mPlatce:=mPlatce+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.firma.tel');
                                                        mPlatce:=mPlatce+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.firma.email');
                                                        mPlatce:=mPlatce+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.firma.mobil');
                                                        mPlatce:=mPlatce+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.firma.fax');
                                                        mbo_sp.setfieldvalueasstring('U_Platce_OD',copy(mPlatce,1,250));
                                                    end;

                                                    if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.osoba.prijmeni')) then begin
                                                        mPlatcePerson:=mPlatcePerson+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.osoba.titul');
                                                        mPlatcePerson:=mPlatcePerson+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.osoba.jmeno');

                                                        mPlatcePerson:=mPlatcePerson+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.osoba.prijmeni');
                                                        mPlatcePerson:=mPlatcePerson+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.osoba.ulice');
                                                        mPlatcePerson:=mPlatcePerson+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.osoba.mesto');
                                                        mPlatcePerson:=mPlatcePerson+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.osoba.psc');
                                                        mPlatcePerson:=mPlatcePerson+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.osoba.tel');
                                                        mPlatcePerson:=mPlatcePerson+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.osoba.email');
                                                        mPlatcePerson:=mPlatcePerson+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.osoba.mobil');
                                                        mPlatcePerson:=mPlatcePerson+';'+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Platce.osoba.fax');
                                                        mbo_sp.setfieldvalueasstring('U_PlatcePerson_OD',copy(mPlatcePerson,1,250));
                                                    end;



                                           //  if rucne and chyba then NxShowSimpleMessage(mid_sp,nil);


                                                     // NxShowSimpleMessage('save',nil);


                                                     mbo_sp.save;;
                                            if (not mpokracuj) or (not mprobehlo) then mprobehlo:=False;
                                          finally
                                              // mbo_sp.free;
                                          end;

                                         mr1:=tstringlist.create;
                                         try
                                              os.SQLSelect('Select id from ServiceDocuments where ServicedObject_ID=' + quotedstr(mbo_SP.oid) + ' and Docqueue_ID=' + quotedstr('2E20000101'),mr1) ;



                                              if mr1.count>0 then begin

                                              end else begin

                                              if true then begin
                                                    if mdate>100 then begin
                                                      mboNew_SL:=os.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                                                          try
                                                            mboNew_SL.new;
                                                            mboNew_SL.Prefill;
                                                            mboNew_SL.SetFieldValueAsString('Docqueue_ID', '2E20000101');
                                                            mboNew_SL.SetFieldValueAsDateTime('DocDate$DATE',mdate);
                                                            mboNew_SL.SetFieldValueAsDateTime('X_CreatedDate$DATE',date);
                                                            mboNew_SL.SetFieldValueAsString('ServiceType_ID','3300000101');
                                                            mboNew_SL.SetFieldValueAsDateTime('PromisedDeadLine$DATE', mdate);
                                                            mboNew_SL.SetFieldValueAsstring('ServicedObjectIDCode','');
                                                            mboNew_SL.SetFieldValueAsstring('ServicedObjectText','');
                                                            mboNew_SL.SetFieldValueAsstring('ServicedObject_ID',mbo_sp.oid);
                                                            //mboNew_SL.SetFieldValueAsstring('Firm_id',mboNew_SL.getFieldValueAsstring('ServicedObject_ID.firm_id'));
                                                            //mboNew_SL.SetFieldValueAsstring('PayerFirm_id',mboNew_SL.getFieldValueAsstring('ServicedObject_ID.Payerfirm_id'));
                                                            //mboNew_SL.SetFieldValueAsstring('X_id_zakaznika_id',mboNew_SL.getFieldValueAsstring('ServicedObject_ID.X_id_zakaznika_id'));
                                                            mboNew_SL.SetFieldValueAsString('Division_ID','K000000101');
                                                            mboNew_SL.SetFieldValueAsString('BusOrder_ID', mboNew_SL.GetFieldValueAsString('ServicedObject_ID.BusOrder_ID'));
                                                            mboNew_SL.SetFieldValueAsString('BusTransaction_ID', mboNew_SL.GetFieldValueAsString('ServicedObject_ID.BusTransaction_ID'));
                                                            mboNew_SL.SetFieldValueAsString('BusProject_ID', mboNew_SL.GetFieldValueAsString('ServicedObject_ID.BusProject_ID'));
                                                            mboNew_SL.SetFieldValueAsString('AcceptedByUser_ID', 'P000000101');
                                                            mboNew_SL.SetFieldValueAsDateTime('PromisedDeadLine$DATE', mdate);
                                                            mboNew_SL.SetFieldValueAsstring('ServiceDocState_ID','2000000101');
                                                            mboNew_SL.Save ;


                                                            mr3:=tstringlist.create;
                                                                try
                                                                        os.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + quotedstr(mboNew_SL.oid),mr3);
                                                                        if mr3.count=0 then begin
                                                                                  mBO_ml:=os.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                                  try
                                                                                      mBO_ml.new;
                                                                                      mbo_ml.Prefill;
                                                                                      mBO_ml.SetFieldValueAsString('ServiceDocument_ID',mboNew_SL.oid);
                                                                                      mBO_ml.SetFieldValueAsInteger('OrdNumber',1);
                                                                                      mr2:=TStringList.Create;
                                                                                      try
                                                                                          os.SQLSelect('select id from ServiceWorkSpaces where code=' + QuotedStr(mboNew_SL.GetFieldValueAsString('Division_ID.code')),mr2);
                                                                                          if mr2.count>0 then begin
                                                                                             mBO_ml.SetFieldValueAsString('ServiceWorkSpace_ID',mr2.Strings[0]);
                                                                                          end else begin
                                                                                              mBO_ml.SetFieldValueAsString('ServiceWorkSpace_ID','7500000101');
                                                                                          end;
                                                                                      finally
                                                                                         mr2.free;
                                                                                      end;
                                                                                      mBO_ml.SetFieldValueAsString('ServiceWorkSpace_ID','7500000101');
                                                                                      mBO_ml.SetFieldValueAsinteger('AssemblyState',0);
                                                                                      //mBO_ml.SetFieldValueAsstring('X_State','3XQ1000101');
                                                                                      //mBO_ml.SetFieldValueAsstring('X_id_zakaznika_id',mboNew_SL.GetFieldValueAsString('X_id_zakaznika_id'));
                                                                                      mBO_ml.SetFieldValueAsstring('X_ServicedObject_ID',mid_sp);
                                                                                      mBO_ml.SetFieldValueAsDateTime('StartDate$DATE',mboNew_SL.GetFieldValueAsDateTime('docdate$date'));
                                                                                      mBO_ml.SetFieldValueAsDateTime('EndDate$DATE',mboNew_SL.GetFieldValueAsDateTime('PromisedDeadLine$DATE'));
                                                                                      mBO_ML.SetFieldValueAsstring('X_Docqueue_ID',mboNew_SL.GetFieldValueAsString('Docqueue_ID'));
                                                                                      mBO_ML.SetFieldValueAsInteger('X_Ordnumber',mboNew_SL.GetFieldValueAsInteger('Ordnumber'));
                                                                                      mBO_ML.SetFieldValueAsstring('X_Period_ID',mboNew_SL.GetFieldValueAsString('Period_ID'));
                                                                                      mr2:=TStringList.Create;
                                                                                      try
                                                                                          mboNew_SL.ObjectSpace.SQLSelect('select id from SecurityRoles where ShortName=' + QuotedStr(mboNew_SL.GetFieldValueAsString('Division_ID.code')),mr2);
                                                                                          if mr2.count>0 then begin
                                                                                             mBO_ml.SetFieldValueAsString('ResponsibleRole_ID',mr2.Strings[0]);
                                                                                          end else begin
                                                                                              mBO_ml.SetFieldValueAsString('ResponsibleRole_ID','AU10000101');
                                                                                          end;
                                                                                      finally
                                                                                         mr2.free;
                                                                                      end;
                                                                                      mBO_ml.SetFieldValueAsString('ResponsibleRole_ID','AU10000101');
                                                                                      mBO_ml.save;
                                                                                  finally
                                                                                     mBO_ml.free;
                                                                                  end;
                                                                        end;
                                                                finally
                                                                    mr3.free;
                                                                end;

                                                        finally
                                                              mboNew_SL.free;
                                                        end;

                                                      end;


                                                     end;
                                              end;


                                        finally
                                            mr1.free;
                                         end;



                                                         if (mid_sp<>'') and (mXMLHead.getElementsCountInArray('Vyrobek['+inttostr(i)+'].params.param')>0) then begin
                                                      //NxShowSimpleMessage('počet parametru -' + inttostr(mXMLHead.getElementsCountInArray('Vyrobek['+inttostr(i)+'].params.param')) + ' - '+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].vyrobni_cislo'),nil);
                                                      for ii := 0 to mXMLHead.getElementsCountInArray('Vyrobek['+inttostr(i)+'].params.param')-1 do begin
                                                          try
                                                          //NxShowSimpleMessage(inttostr(ii) + ' - '+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].vyrobni_cislo') + ' - ' + mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].params.param['+inttostr(ii)+'].param_name')+ ' = ' +
                                                          //mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].params.param['+inttostr(ii)+'].param_value')
                                                          //,nil);
                                                          if (not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].params.param['+inttostr(ii)+'].param_name')))
                                                              and (mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].params.param['+inttostr(ii)+'].param_value')<>'')
                                                              and (mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].params.param['+inttostr(ii)+'].param_value')<>'0')
                                                          then begin
                                                                 mid:='';
                                                                 mr:=tstringlist.create;
                                                                 try

                                                                      os.SQLSelect('select id from defrolldata where CLSID=' + quotedstr('WLOHIKYCKUGOX1LFEEIQGD5NX0') + ' and X_field1=' +
                                                                      quotedstr(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].params.param['+inttostr(ii)+'].param_name')),mr) ;

                                                                      if mr.count=0 then begin
                                                                          try
                                                                                //NxShowSimpleMessage('param_zalozen',nil);
                                                                                mBO_DF:=os.CreateObject('WLOHIKYCKUGOX1LFEEIQGD5NX0');  // číselník parametrů
                                                                                mBO_DF.new;
                                                                                // založení nového parametru
                                                                                mBO_DF.SetFieldValueAsString('code',inttostr(ii)); // popis
                                                                                mBO_DF.SetFieldValueAsString('X_PosIndex',inttostr(ii)); // popis
                                                                                mBO_DF.SetFieldValueAsString('Name',copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].params.param['+inttostr(ii)+'].param_name'),1,80));
                                                                                mBO_DF.SetFieldValueAsString('X_field1',copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].params.param['+inttostr(ii)+'].param_name'),1,199));

                                                                                mBO_DF.save;
                                                                                mid:=mbo_df.oid;
                                                                           finally
                                                                                mBO_DF.free;
                                                                           end;

                                                                      end else begin

                                                                          // dohledání parametru
                                                                          //NxShowSimpleMessage('param_dohledan',nil);
                                                                          mid:=mr.Strings[0];
                                                                      end;
                                                                 finally
                                                                      mr.free
                                                                 end ;


                                                                 if mid<>'' then begin
                                                                     mr:=TStringList.create;
                                                                     try
                                                                         os.SQLSelect('SELECT A.ID FROM DefRollData A where CLSID=' + quotedstr('L5NKMYE3ZLSOLEBABM5CCHGOIC') +  ' and X_ServicedObject_ID='+quotedstr(mID_SP) +
                                                                                ' AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000002 AND CLSID=' + quotedstr('L5NKMYE3ZLSOLEBABM5CCHGOIC') +  ' AND ID = A.ID AND (STRINGFIELDVALUE =' + quotedstr(mid)+')))',mr) ;
                                                                         if mr.count=0 then begin
                                                                               try

                                                                                    mBO1_DF:=os.CreateObject('L5NKMYE3ZLSOLEBABM5CCHGOIC');        // založení hodnoty
                                                                                    // založení nového parametru
                                                                                    mBO1_DF.new;
                                                                                    mBO1_DF.SetFieldValueAsString('code',inttostr(ii)); // popis
                                                                                    mBO1_DF.SetFieldValueAsString('X_PosIndex',inttostr(ii)); // popis
                                                                                    mBO1_DF.SetFieldValueAsString('Name',copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].params.param['+inttostr(ii)+'].param_name'),1,80));
                                                                                    mBO1_DF.SetFieldValueAsString('X_ServicedObject_ID',mID_SP); // sp
                                                                                    mBO1_DF.SetFieldValueAsString('U_Parametr_ID',mid);
                                                                                    mBO1_DF.SetFieldValueAsString('X_field2', copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].params.param['+inttostr(ii)+'].param_value'),1,199));   //
                                                                                    mBO1_DF.SetFieldValueAsString('X_field5', 'O');
                                                                                    mBO1_DF.save;

                                                                               finally
                                                                                    mBO1_DF.free;
                                                                               end;
                                                                          end else begin
                                                                               try

                                                                                    mBO1_DF:=os.CreateObject('L5NKMYE3ZLSOLEBABM5CCHGOIC');        // založení hodnoty
                                                                                    // oprava parametru
                                                                                    mBO1_DF.load(mr.Strings[0],nil);
                                                                                    mBO1_DF.SetFieldValueAsString('code',inttostr(ii)); // popis
                //                                                                    mBO1_DF.SetFieldValueAsString('Name',copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].params['+inttostr(ii)+'].param.param_name'),1,80));
                                                                                    mBO1_DF.SetFieldValueAsString('X_field2',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].params.param['+inttostr(ii)+'].param_value'));   //
                                                                                    mBO1_DF.SetFieldValueAsString('X_field5','O');
                                                                                    mBO1_DF.save;

                                                                               finally
                                                                                    mBO1_DF.free;
                                                                               end;
                                                                          end;




                                                                     finally

                                                                     end;



                                                              end; // zápis parametru




                                                          end;// název parametru
                                                          finally
                                                          end;
                                                    end;       //cyklus
                                              end;

                      end;





                finally
                    mbo_sp.free;
                end;

          end;


          result:=nxcopyfile(AFileName,Directory + '\Zpracovane\' + FileName);
          if result then begin
              DeleteFile(AFileName);
     //         if rucne and result and chyba then begin
                     //NxShowSimpleMessage('Soubor ' + afilename + ' byl přesunut do zpracovaných',nil);
     //         end;
          end;


     finally
      mXMLHead.Free;
     end;
    Result := True;


end;

function setParameter(os:TNxCustomObjectSpace;mBO_ID:string;typ:string;Popis:TStringList;Hodnota:TStringList):Boolean;
var
mr:tstringlist;
II:integer;
mBO_DF,mBO1_DF:TNxCustomBusinessObject;
mpocet:integer;
mid:string;
begin
//NxShowSimpleMessage(typ + ' - ' + mbo_ID + popis.Strings[5]+ '-' + hodnota.Strings[5],nil);
if hodnota.count>=popis.count then begin
   mpocet:=popis.count;
end else begin
   mpocet:=hodnota.count;
end;

for ii := 3 to mpocet-1 do begin

               // číselník parametrů
                 mid:='';
                 mr:=tstringlist.create;
                 try

                      os.SQLSelect('select id from defrolldata where CLSID=' + quotedstr('WLOHIKYCKUGOX1LFEEIQGD5NX0') + ' and X_field1=' +
                      quotedstr(popis.Strings[ii]) + ' and X_field5=' + quotedstr(typ),mr) ;

                      if mr.count=0 then begin
                          try
                                //NxShowSimpleMessage('param_zalozen',nil);
                                mBO_DF:=os.CreateObject('WLOHIKYCKUGOX1LFEEIQGD5NX0');  // číselník parametrů
                                mBO_DF.new;
                                // založení nového parametru
                                mBO_DF.SetFieldValueAsString('code',inttostr(ii)); // popis
                                mBO_DF.SetFieldValueAsString('X_PosIndex',inttostr(ii)); // popis
                                mBO_DF.SetFieldValueAsString('Name',copy(popis.Strings[ii],1,50));
                                mBO_DF.SetFieldValueAsString('X_field1',copy(popis.Strings[ii],1,199));
                                mBO_DF.SetFieldValueAsString('X_field5',typ);
                                mBO_DF.save;
                                mid:=mbo_df.oid;
                           finally
                                mBO_DF.free;
                           end;

                     end else begin

                                // dohledání parametru
                                //NxShowSimpleMessage('param_dohledan',nil);
                                mid:=mr.Strings[0];
                     end;
                 finally
                            mr.free
                 end ;


                 if mid<>'' then begin
                      mr:=TStringList.create;
                      try
                          os.SQLSelect('SELECT A.ID FROM DefRollData A where CLSID=' + quotedstr('L5NKMYE3ZLSOLEBABM5CCHGOIC') +  ' and X_ServicedObject_ID='+quotedstr(mBO_ID) + ' and X_field5='+quotedstr(typ) +
                                   ' AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000002 AND CLSID=' + quotedstr('L5NKMYE3ZLSOLEBABM5CCHGOIC') +  ' AND ID = A.ID AND (STRINGFIELDVALUE =' + quotedstr(mid)+')))',mr) ;
                          if mr.count=0 then begin
                                 try

                                      mBO1_DF:=os.CreateObject('L5NKMYE3ZLSOLEBABM5CCHGOIC');        // založení hodnoty
                                      //NxShowSimpleMessage('založení nového parametru',nil);
                                      mBO1_DF.new;
                                      mBO1_DF.SetFieldValueAsString('code',inttostr(ii)); // popis
                                      mBO1_DF.SetFieldValueAsString('X_PosIndex',inttostr(ii)); // popis
                                      mBO1_DF.SetFieldValueAsString('Name',copy(popis.Strings[ii],1,50));
                                      mBO1_DF.SetFieldValueAsString('X_ServicedObject_ID',mBO_ID); // sp
                                      mBO1_DF.SetFieldValueAsString('U_Parametr_ID',mid);
                                      mBO1_DF.SetFieldValueAsString('X_field2', copy(hodnota.Strings[ii],1,199));   //
                                      mBO1_DF.SetFieldValueAsString('X_field5', typ);
                                      mBO1_DF.save;

                                 finally
                                      mBO1_DF.free;
                                 end;
                            end else begin
                                 try

                                      mBO1_DF:=os.CreateObject('L5NKMYE3ZLSOLEBABM5CCHGOIC');        // založení hodnoty
                                      // oprava parametru
                                      mBO1_DF.load(mr.Strings[0],nil);
                                      mBO1_DF.SetFieldValueAsString('code',inttostr(ii)); // popis
//                                                                    mBO1_DF.SetFieldValueAsString('Name',copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].params['+inttostr(ii)+'].param.param_name'),1,80));
                                      mBO1_DF.SetFieldValueAsString('X_field2',copy(hodnota.Strings[ii],1,199));   //
                                      mBO1_DF.SetFieldValueAsString('X_field5',typ);
                                      mBO1_DF.save;

                                 finally
                                      mBO1_DF.free;
                                 end;
                            end;

                      finally
                          mr.free;
                      end;
                 end;


end;

result:=true;
end;

begin
end.