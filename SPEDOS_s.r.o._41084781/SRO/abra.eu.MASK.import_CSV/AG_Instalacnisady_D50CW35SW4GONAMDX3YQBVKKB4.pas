uses 'abra.eu.MASK.import_CSV.lib';
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
    mHeaderBusinessObject : TNxHeaderBusinessObject;
    mRowBusinessObject : TNxCustomBusinessObject;
    mCustomBusinessMonikerCollection : TNxCustomBusinessMonikerCollection;
    mSite: TSiteForm;
    mDBGrid : TDBGrid;
    mTabList: TTabSheet;
    i : integer;
    result:Boolean;
    cHead:string;
    cRow:string ;
    sloupcu:integer;
    mid1,mid2,mid3,mid4:string;

procedure OnExec(Sender: TComponent);       // přidělení objectspace a zadání zdrojového souboru
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
    ImportFile(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);
end;

function ImportFile(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string) : Boolean;
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
begin
  pocet_new:=0;
  pocet_upd:=0;
  pocet_err:=0;
  NxScriptingLog.EnterSection('ImportFile', logNotice);
  mstart:=strtoint(InputBox('Počatek','Zahájit na!','20'));
  aa:=InputBox('Volba převodu','Převadět i definovatelné položky A-N!','A');
  if UpperCase(aa)='A' then mUserFields:=true else mUserFields:=false;

    sloupcu:=0;
    if not FileExists(AFileName) then begin   // soubor nenalezen
      Result := False;
      exit;
    end;
    mImportFile := TStringList.Create;
    mTargetFile := TStringList.Create;
      try
        mRowList := TStringList.Create;
        try
            mImportFile.LoadFromFile(AFileName);
            if mImportFile.Count >13 then begin
                 mFieldHead:= TStringList.Create;
                 mFieldLabel:= TStringList.Create;       // název položky
                 mFieldtype:= TStringList.Create;        // typ položky
                 mFieldlenght:= TStringList.Create;      // délka položky
                 mFieldTable:= TStringList.Create;      // délka položky
                 mFieldCLSID:= TStringList.Create;
                 mFieldField:= TStringList.Create;      // vyhledávací polžka
                 mFieldConst:= TStringList.Create;      // konstatnta při nedohledání
                 mFieldCreate:= TStringList.Create;      // konstatnta při nedohledání
                 mFieldBO:= TStringList.Create;      // konstatnta při nedohledání
                 Parsehead(mDocHead, mImportFile.strings[0], ';',mImportFile.strings[0],mFieldhead );
                 //ShowMessage('CLSID' + mFieldHead.Strings[1]);
                 Parsehead(mDocHead, mImportFile.strings[1], ';',mImportFile.strings[1],mFieldLabel );
                 //ShowMessage('Field' + mFieldLabel.Strings[1]);
                 sloupcu:=mFieldLabel.Count;
                 Parsevalue(mDocHead, mImportFile.Strings[3], ';',mImportFile.Strings[3],mFieldtype,sloupcu );
                 //ShowMessage('type' + mFieldType.Strings[1]);
                 Parsevalue(mDocHead, mImportFile.strings[4], ';',mImportFile.strings[4],mFieldlenght,sloupcu );
                 Parsevalue(mDocHead, mImportFile.strings[8],';',mImportFile.strings[8],mFieldTable,sloupcu);
                 //ShowMessage('Table' + mFieldTable.Strings[1]);
                 Parsevalue(mDocHead, mImportFile.strings[9],';',mImportFile.strings[9],mFieldCLSID,sloupcu);
                 //ShowMessage('CLSID' + mFieldCLSID.Strings[1]);
                 Parsevalue(mDocHead, mImportFile.strings[10],';',mImportFile.strings[10],mFieldField,sloupcu);
                 Parsevalue(mDocHead, mImportFile.strings[11],';',mImportFile.strings[13],mFieldConst,sloupcu);
                 Parsevalue(mDocHead, mImportFile.strings[12],';',mImportFile.strings[10],mFieldCreate,sloupcu);
                 Parsevalue(mDocHead, mImportFile.strings[13],';',mImportFile.strings[10],mFieldBO,sloupcu);
                 //ShowMessage('Hledani' + mFieldField.Strings[1]);
                 i := mstart; // zacinam vzdy od 3.tího řádku
                 while i < mImportFile.Count do begin
                    mfieldValue:= TStringList.Create;
                    //mTargetFile.strings[i]:=mImportFile.strings[i];
                    Parsevalue(mDocHead, mImportFile.strings[i],';',mImportFile.strings[i],mfieldValue,sloupcu);
                    mCustomBusinessObject:= os.CreateObject(mFieldHead.Strings[1]);
                    try
                        zapis:=false;
                        pozice:=1;
                        while pozice < sloupcu do begin
                             if mFieldLabel.Strings[pozice]='ID' then begin          // již existující záznam
                                        mID:=CheckFieldValue(mCustomBusinessObject,'ID',mfieldtable.Strings[pozice],

                                        mfieldfield.Strings[pozice],copy(mfieldValue.Strings[pozice],1,10));
                                        if NxIsBlank(mID) then begin
                                           mExist_ID:='';
                                           NxShowSimpleMessage('Nenalezeno ID',nil);
                                        end else begin
                                           mExist_ID:=mid;
                                           NxShowSimpleMessage('Dohledáno ID',nil);
                                        end;
                             end;

                             if (mExist_ID='') and (pozice=2)  then begin          // již dohledání
                                        if NxIsBlank(mfieldCLSid.Strings[pozice]) then begin
                                            mID:=CheckFieldValue(mCustomBusinessObject,'ID',mfieldtable.Strings[pozice],mfieldfield.Strings[pozice],copy(mfieldValue.Strings[pozice],1,strtoint(mFieldLenght.Strings[pozice])));
                                        end else begin
                                            mID:=CheckFieldUserValue(mCustomBusinessObject,'ID',mFieldTable.Strings[pozice],mFieldField.Strings[pozice],mfieldValue.Strings[pozice],'CLSID',mfieldCLSid.Strings[pozice]);
                                       end;

                                        if NxIsBlank(mID) then begin
                                           mExist_ID:='';
                                           NxShowSimpleMessage('Nenalezeno code',nil);
                                        end else begin
                                           mExist_ID:=mid;
                                           NxShowSimpleMessage('Nalezeno code',nil);
                                        end;
                              end;


                             if (pozice=2) then begin
                                      try
                                            mCustomBusinessObject:= os.CreateObject(mFieldHead.Strings[1]); // ReceivedOrder
                                            if nxisblank(mExist_ID) then begin
                                                mstav:='New';
                                                mCustomBusinessObject.New;
                                                //mCustomBusinessObject.SetFieldValueAsString('Firm_ID','3X23000101');
                                                mCustomBusinessObject.Prefill;
                                             end else begin
                                                    mstav:='Upd';
                                                    mCustomBusinessObject.Load(mExist_ID,nil);
                                           end;
                                            zapis:=true;
                                     finally
                                     end;
                            end;
                                        

                            if (mFieldvalue.Strings[pozice]<>'') and (mFieldvalue.Strings[pozice]<>'0') then begin    // při vyplněné položce
                                    if mUserFields or ((NxLeft(mFieldLabel.Strings[pozice],2) <>'X_') or (NxLeft(mFieldLabel.Strings[pozice],2) <>'U_')) then begin
                                        if NxRight(mFieldLabel.Strings[pozice],3) ='_ID' then begin // kontroluje, zda je ciselnik
                                            mid:='';
                                            if ((NxLeft(mFieldLabel.Strings[pozice],2) <>'X_') or (NxLeft(mFieldLabel.Strings[pozice],2)<>'U_')) then begin

                                                //uživatelské položky
                                                mID:=CheckFieldValue(mCustomBusinessObject,'ID',mFieldTable.Strings[pozice],mFieldField.Strings[pozice],mfieldValue.Strings[pozice]);
                                            end else begin
                                                // systémové položky
                                                mid:='';
                                                if NxIsBlank(mID) then mID:=CheckFieldUserValue(mCustomBusinessObject,'ID',mFieldTable.Strings[pozice],mFieldField.Strings[pozice],mfieldValue.Strings[pozice],'CLSID',mfieldCLSid.Strings[pozice]);
                                            end;
                                            try

                                              if (NxIsBlank(mID)) and (not nxisblank(mFieldCreate.Strings[pozice])) then begin    // založení číselníku


                                              end;
                                              if (NxIsBlank(mID)) and (not nxisblank(mFieldConst.Strings[pozice])) then begin    // naplnění konstantou
                                                  mid:=mFieldConst.Strings[pozice];
                                              end;
                                              if not NxIsBlank(mID) then NxSetFieldString(mCustomBusinessObject,mFieldLabel.Strings[pozice],mid);  // zapsání hodnot




                                            finally
                                            end;
                                        end else begin // nečiselníkové položky
                                            if mFieldType.Strings[pozice]='dtString' then begin
                                                if ((NxLeft(mFieldLabel.Strings[pozice],2) <>'X_') or (NxLeft(mFieldLabel.Strings[pozice],2)<>'U_')) then begin
                                                      if not nxisblank(copy(mfieldValue.Strings[pozice],1,strtoint(mFieldLenght.Strings[pozice]))) then begin
                                                          NxSetFieldString(mCustomBusinessObject,mFieldLabel.Strings[pozice],
                                                                copy(mfieldValue.Strings[pozice],1,strtoint(mFieldLenght.Strings[pozice])));
                                                      end else begin
                                                           if not nxisblank(mFieldConst.Strings[pozice]) then begin
                                                                NxSetFieldString(mCustomBusinessObject,mFieldLabel.Strings[pozice],mFieldConst.Strings[pozice]);  // naplnění konstantou
                                                           end;
                                                      end;;

                                                end;
                                            end;
                                            if mFieldType.Strings[pozice]='dtMemo' then begin
                                               if not nxisblank(mfieldValue.Strings[pozice]) then begin
                                                    NxSetFieldString(mCustomBusinessObject,mFieldLabel.Strings[pozice],copy(mfieldValue.Strings[pozice],1,strtoint(mFieldLenght.Strings[pozice])));
                                                    if ladit then NxShowSimpleMessage(mFieldLabel.Strings[pozice] + ':'+copy(mfieldValue.Strings[pozice],1,strtoint(mFieldLenght.Strings[pozice])),nil);
                                               end else begin
                                                   if not nxisblank(mFieldConst.Strings[pozice]) then begin
                                                      NxSetFieldString(mCustomBusinessObject,mFieldLabel.Strings[pozice],copy(mFieldConst.Strings[pozice],1,strtoint(mFieldLenght.Strings[pozice])));
                                                   end;
                                               end;
                                            end;
                                            if mFieldType.Strings[pozice]='dtBoolean' then begin
                                                if not nxisblank(mfieldValue.Strings[pozice]) then begin
                                                      NxSetFieldBoolean(mCustomBusinessObject,mFieldLabel.Strings[pozice], StrToBool(mfieldValue.Strings[pozice]));
                                                      if ladit then NxShowSimpleMessage(mFieldLabel.Strings[pozice] + ':'+mfieldValue.Strings[pozice],nil);
                                                end else begin
                                                    if not nxisblank(mFieldConst.Strings[pozice]) then begin
                                                        NxSetFieldBoolean(mCustomBusinessObject,mFieldLabel.Strings[pozice], StrToBool(mFieldConst.Strings[pozice]));
                                                    end;

                                                end;

                                            end;
                                            if mFieldType.Strings[pozice]='dtInteger' then begin
                                                 if not nxisblank(mfieldValue.Strings[pozice]) then begin
                                                    NxSetFieldInteger(mCustomBusinessObject,mFieldLabel.Strings[pozice], strtoint(mfieldValue.Strings[pozice]));
                                                    if ladit then NxShowSimpleMessage(mFieldLabel.Strings[pozice] + ':'+mfieldValue.Strings[pozice],nil);
                                                 end else begin
                                                    if not nxisblank(mFieldConst.Strings[pozice]) then begin
                                                       NxSetFieldInteger(mCustomBusinessObject,mFieldLabel.Strings[pozice], strtoint(mFieldConst.Strings[pozice]));
                                                    end;
                                                 end;
                                            end;
                                            if mFieldType.Strings[pozice]='dtFloat' then begin
                                               if not nxisblank(mfieldValue.Strings[pozice]) then begin
                                                    NxSetFieldFloat(mCustomBusinessObject,mFieldLabel.Strings[pozice], strtofloat(mfieldValue.Strings[pozice]));
                                                    if ladit then NxShowSimpleMessage(mFieldLabel.Strings[pozice] + ':'+mfieldValue.Strings[pozice],nil);
                                               end else begin
                                                    if not nxisblank(mFieldConst.Strings[pozice]) then begin
                                                        NxSetFieldFloat(mCustomBusinessObject,mFieldLabel.Strings[pozice], strtofloat(mFieldConst.Strings[pozice]));
                                                    end;
                                               end;
                                            end;
                                            if mFieldType.Strings[pozice]='dtDateTime' then begin
                                               if not nxisblank(mfieldValue.Strings[pozice]) then begin
                                                    NxSetFieldDateTime(mCustomBusinessObject,mFieldLabel.Strings[pozice], StrToDateTime(mfieldValue.Strings[pozice]));
                                                    if ladit then NxShowSimpleMessage(mFieldLabel.Strings[pozice] + ':' + FormatDateTime('DD.MM.YYYY',StrToDateTime(mfieldValue.Strings[pozice])),nil);
                                               end else begin
                                                    if not nxisblank(mFieldConst.Strings[pozice]) then begin
                                                        NxSetFieldDateTime(mCustomBusinessObject,mFieldLabel.Strings[pozice], StrToDateTime(mFieldConst.Strings[pozice]));
                                                    end;
                                               end;
                                            end;
                                       ShowMessage('Polozka ' + mFieldLabel.Strings[pozice]+' : ' + mfieldValue.Strings[pozice]);
                                        end;
                                    end;
                            end;
                                  Inc(pozice, 1);        // testování další položky na řádku
                        end;                             // ukončení řádku importu
                        if zapis then begin

                              mresult:= true;
                              if mresult and (mstav='New') and (not nxisblank(mfieldCreate.Strings[1])) Then begin
                                   mCustomBusinessObject.Save;
                                   mid:=mCustomBusinessObject.OID;
                                   pocet_new:= pocet_new+1;
                              end;
                              if mresult and (mstav='Upd') Then begin
                                   mCustomBusinessObject.Save;
                                   mid:=mCustomBusinessObject.OID;
                                   pocet_upd:= pocet_upd+1;
                              end;

                              if not mresult then begin
                                  mstav:='Err';
                                  pocet_err:= pocet_err+1;
                              end;
                              mImportFile.strings[i]:=mstav + ';'+ mid +  ';'+ copy(mImportFile.strings[i],16,10000) ;

                       end;
                    finally;


                    end;
                    mfieldValue.free;
                    mCustomBusinessObject.free;
                Inc(i, 1);
              end;
           end;
           mImportFile.SaveToFile(AFileName);
           NxShowSimpleMessage('Soubor importovan - Nových:' + IntToStr(pocet_new) + ',  Opravenych: ' + IntToStr(pocet_upd)+ ',  Chybných:' + IntToStr(pocet_err),nil);
        finally
            //mTargetFile.SaveToFile(AFileName+'log');
            mImportFile.Free;
            mFieldHead.free;
                 mFieldLabel.free;       // název položky
                 mFieldtype.free;        // typ položky
                 mFieldlenght.free;      // délka položky
                 mFieldTable.free;      // délka položky
                 mFieldCLSID.free;
                 mFieldField.free;      // vyhledávací polžka
                 mFieldConst.free;      // konstatnta při nedohledání
                 mFieldCreate.free;      // konstatnta při nedohledání
                 mFieldBO.free;

        end;
        {mGRows := TMultiGrid(NxFindChildControl(NxGetSiteAppForm(mSite), 'grdlist'));   // refresh
        if Assigned(mGRows) then begin
            mGRows.DataSource.DataSet.Refresh;
        end;   }
      finally
      end;
{      Result := True;
            if copy(filename,1,1)='T' then begin
               if oprava=false then begin
                   aresult:=nxcopyfile(AFileName,Directory + '\Zpracovane\' + FileName);
                   if Aresult= true then DeleteFile(AFileName);
               end;
                 if oprava=true then begin
                     aresult:=nxcopyfile(AFileName,Directory + '\Zpracovane\' + FileName);
                     if Aresult= true then DeleteFile(AFileName);
                 end;
            end;
    except
      Result := False;
      NxScriptingLog.WriteEvent(logError, ExceptionMessage);
    end;
  finally        }
    NxScriptingLog.LeaveSection('ImportFile', logNotice);
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
          mMAction.Hint := 'Import_BO';
          mMAction.Caption := 'Import_BO';
          mMAction.Items.Add('Import_BO');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;
{        end;}
end;



begin
end.