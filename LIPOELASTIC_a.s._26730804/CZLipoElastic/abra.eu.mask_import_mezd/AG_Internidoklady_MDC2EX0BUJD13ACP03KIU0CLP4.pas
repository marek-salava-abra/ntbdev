uses 'abra.eu.mask_import_pay.lib',
      '_Knihovny_ALL.SQL',
      '_Knihovny_ALL.DateTime',
      '_Knihovny_ALL.Parse';

const
    mFilter='*.xml';


function iExtractDate(AString: String): TDateTime;
  begin
    Result := EncodeDate(StrToInt(Copy(AString,7,4)),StrToInt(Copy(AString,4,2)),StrToInt(Copy(AString,1,2)));
  end;

  function iExtractDateeu(AString: String): TDateTime;
  begin
    Result := EncodeDate(StrToInt(Copy(AString,1,4)),StrToInt(Copy(AString,6,2)),StrToInt(Copy(AString,9,2)));
  end;

function ImportMzdy(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
var

    mImportFile:TStringList;
    mFieldHead,mFieldConst,mFieldLabel,mFieldType,mFieldLenght,mfieldValue,mFieldTable,mFieldCLSID,mFieldField,mFieldCreate,mFieldBo:TStringList;
     mr,mList:TStringList;
    mbo,mrow:TNxCustomBusinessObject;
     mhead:TNxCustomBusinessObject;
    mMon:TNxCustomBusinessMonikerCollection;
    mline:string;
    mText:string;
    mdivision,mBusOrder, mBustransaction, mBusproject:string;
    mpocet:double;
    mcastka:double;
    msString:string;
    mBDialog:Boolean;
    ii:integer;
    mvarsymbol:string;
    mID:string;
    mdate:Date;
begin

    if not FileExists(AFileName) then begin   // soubor nenalezen
      Result := False;
      exit;
    end;

try
 mImportFile := TStringList.Create;
mImportFile.LoadFromFile(AFileName);


mHead :=  TDynSiteForm(msite).CurrentObject;
mhead.new;
mhead.Prefill;
mhead.SetFieldValueAsString('DocQueue_ID','M300000101');
mhead.SetFieldValueAsString('Firm_ID','7F26300101');



         mMon := mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('ROWS'));

                                                if mImportFile.Count >1 then begin
                                                                                  ii := 0;
                                                                                   while ii < mImportFile.Count do begin

                                                                                           //     if copy(mImportFile.strings[ii],1,1)<>'' then begin
                                                                                                            mLine := mImportFile.strings[ii];

                                                                                                            //NxTokenToStrings(mLine, ';', mLineCols);


                                                                                                            mLine :=NxSearchReplace(NxSearchReplace(mLine, '"', '', [srAll]), ';', '";"', [srAll]) +';';
                                                                                                              mLine := NxSearchReplace(mLine, chr(9), ';', [srAll]);

                                                                                                              mfieldValue:= TStringList.Create;
                                                                                                              try
                                                                                                                  mfieldValue:=FnParsevalue(mline,';');
                                                                                                                    if ii=0  then begin
                                                                                                                          mdate:= StringDateToDate(( NxSearchReplace(mfieldValue.strings[0], '"', '', [srAll])));
                                                                                                                          mhead.SetFieldValueAsDateTime('DocDate$DATE',mdate);
                                                                                                                    end;
                                                                                                                              mRow := mMon.AddNewObject;
                                                                                                                              mRow.Prefill;
                                                                                                                              mID:= '';
                                                                                                                              mid:=SQLSelectFirstRecosrds(msite.BaseObjectSpace, 'select id from Accounts where code=' + QuotedStr( NxSearchReplace(mfieldValue.strings[1], '"', '', [srAll]))+ ' and hidden='+ QuotedStr('N') );





                                                                                                                              mrow.SetFieldValueAsString('DebitAccount_ID',mid);
                                                                                                                              //NxSearchReplace(NxSearchReplace(mfieldValue.strings[2], '"', '', [srAll]), ';', '";"', [srAll]) ;
                                                                                                                              mID:='';
                                                                                                                              mid:=SQLSelectFirstRecosrds(msite.BaseObjectSpace, 'select id from Accounts where code=' + QuotedStr( NxSearchReplace(mfieldValue.strings[2], '"', '', [srAll]))+ ' and hidden='+ QuotedStr('N') );
                                                                                                                              //NxShowSimpleMessage(mid,nil);
                                                                                                                              mrow.SetFieldValueAsString('CreditAccount_ID',mID);
                                                                                                                              mrow.SetFieldValueAsString('Text',NxSearchReplace(mfieldValue.strings[6], '"', '', [srAll]));
                                                                                                                              mrow.SetFieldValueAsFloat('TAmount',NxIBStrToFloat(NxSearchReplace(mfieldValue.strings[5], '"', '', [srAll])));
                                                                                                                              mrow.SetFieldValueAsFloat('LocalTAmount',NxIBStrToFloat(NxSearchReplace(mfieldValue.strings[5], '"', '', [srAll])));


                                                                                                                              //mrow.SetFieldValueAsFloat('TAmount',50);
                                                                                                                             //mrow.SetFieldValueAsFloat('LocalTAmount',50);


                                                                                                                              //NxShowSimpleMessage(mfieldValue.strings[3],nil);


                                                                                                                              mID:= '';
                                                                                                                              mid:=SQLSelectFirstRecosrds(msite.BaseObjectSpace, 'select id from BusProjects where code=' + QuotedStr( NxSearchReplace(mfieldValue.strings[3], '"', '', [srAll]))+ ' and hidden='+ QuotedStr('N') );
                                                                                                                              if mid= '' then mid:= '1400000101';

                                                                                                                              mrow.SetFieldValueAsString('CreditBusProject_ID',mid);
                                                                                                                              mrow.SetFieldValueAsString('DebitBusProject_ID',mid);


                                                                                                                              mID:= '';
                                                                                                                              mid:=SQLSelectFirstRecosrds(msite.BaseObjectSpace, 'select id from Divisions where code=' + QuotedStr( NxSearchReplace(mfieldValue.strings[3], '"', '', [srAll]))+ ' and hidden='+ QuotedStr('N') );

                                                                                                                              if mid= '' then mid:= '1000000101';


                                                                                                                              mrow.SetFieldValueAsString('DebitDivision_ID',mID);
                                                                                                                              mrow.SetFieldValueAsString('CreditDivision_ID',mID);
                                                                                                                              mrow.SetFieldValueAsString('DebitBusOrder_ID','');
                                                                                                                              mrow.SetFieldValueAsString('CreditBusOrder_ID','');
                                                                                                                              mrow.SetFieldValueAsString('DebitBusTransaction_ID','');
                                                                                                                              mrow.SetFieldValueAsString('CreditBusTransaction_ID','');



                                                                                                                                //       mr:=tstringlist.create;
                                                                                                                                //            try
                                                                                                                                //               msite.BaseObjectSpace.sqlselect('SELECT A.ID FROM IssuedDInvoices A WHERE A.VarSymbol= ' + quotedstr(mvarsymbol),mr);
                                                                                                                                //
                                                                                                                                //                      if mr.count=1 then begin
                                                                                                                                //                          mRow.SetFieldValueAsString('PDocumentType','10');
                                                                                                                                //                          mRow.SetFieldValueAsString('PDocument_ID',mr.Strings[0]);
                                                                                                                                //                          //mRow.SetFieldValueAsFloat('PAmount',mcastka);
                                                                                                                                //                      end;
                                                                                                                                //                finally   ;
                                                                                                                                //                    mr.free;
                                                                                                                                //                end;


                                                                                                              finally
                                                                                                                      mfieldValue.free;
                                                                                                              end;


                                                                                        Inc(ii, 1);
                                                                                      end;         //while

                                                end;















 finally
     mImportFile.free;
 end;






  mhead.ClearValidateErrors;
                                  if Not mhead.Validate() then begin
                                        mList := TStringList.Create;
                                        try
                                           mhead.GetValidateErrors(mList);
                                           mText := mList.Text;
                                           NxToken(mText, '=');
                                           MessageDlg('Automaticky vytvořenou objednávku nelze uložit z těchto důvodů:' + #13#10 + mText,

                                           mtWarning, [mbOK], 0);
                                         finally
                                           mList.Free;
                                         end;
                                         mSite.ShowDynFormWithNewDocument('MDC2EX0BUJD13ACP03KIU0CLP4', mSite.SiteContext, mhead);
                                         //mhead.refresh;
                                        msite.ActiveDataSet.RefreshCurrentItemMode;
                              end else begin
                                        mhead.Save;
                                        mhead.refresh;
                                        msite.ActiveDataSet.RefreshCurrentItemMode;
                                            if rucne then NxShowSimpleMessage('Doklad  ' + mhead.GetFieldValueAsstring('Docqueue_ID.code') + '-' + inttostr(mhead.GetFieldValueAsinteger('Ordnumber')) + '/' +
                                                 mhead.GetFieldValueAsstring('Period_ID.code') + ' byl vytvořena',nil);
                              end;

end;







{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
  mAction: TBasicAction;
  mAList: TActionList;
  i: integer;
  mAct: TBasicAction;
begin
           mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Import mezd';
          mMAction.Caption := 'Import mezd ';
          mMAction.Items.Add('Import mezd');



          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


end;

procedure OnExec(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile:string;
  msite:TDynSiteForm;
begin
  //mSite := NxFinddySiteForm(Sender);

  msite:=TComponent(Sender).DynSite;
   if PromptForFileName(mFileName, mfilter, '', 'Import mezd', mdir, False) then begin
    mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
    mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
   end;
  //ImportFile(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);

      ShowMessage(Format('Bude importován soubor %s%s', [mdir,mfile]));
      ImportMzdy(msite.BaseObjectSpace, mfilename, mdir,mfile,msite,true,true,index);

  msite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
end;




begin
end.
