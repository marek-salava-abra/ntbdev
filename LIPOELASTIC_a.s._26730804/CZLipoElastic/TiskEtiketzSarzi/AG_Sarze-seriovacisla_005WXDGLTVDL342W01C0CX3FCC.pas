uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse';
const
    mFilter='*.xml';

     Var
mTyp_obchodu:string;
  mXMLHead : TNxScriptingXMLWrapper;
  mSite : TSiteForm;
  mDoklad : string;
  i,ii : integer;
  mres,mres1,mr2: TStringList;
  mID: String;
  aaaaa: string;
  x:integer;
  aa:Double;
  mrResult:string;
  mfirm,mfirm_office: TNxCustomBusinessObject;
  mrow: TNxCustomBusinessObject;
  mbusorder: TNxCustomBusinessObject;
  maddress: TNxCustomBusinessObject;
  mBO_SP: TNxCustomBusinessObject;
  mID_Store,mID_StoreCard,mIDdoklad,mID_odberatel, mID_dodavatel, mID_Docqueue, mID_BusOrder, mID_VatCountry,mID_Country, mID_Currency,mID_Vatrate,mID_Row: string;
  aresult:Boolean;
  mexistuje:string;
  oprava : boolean;
  mMon : TNxCustomBusinessMonikerCollection;
   mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  mEdtIC, mEdtDIC,mEdtName,mEdtStreet,mEdtCity,mEdtPostCode,mEdtCountry : TEdit;
  cbSrcUnits, cbDstUnits, cbStores, cbDivisions : TEdit;
  mP1, mP2, mP3 : TPanel;
  mI_modalresult:integer;
  mS_code:string;
  mList,mRowList:TStringList;
  mtext:string;
  mID_kost_symbol,mID_payment,mID_delivery:string;
  mCountryName:string;
  mtoESL:boolean;
  mBO_Storecard:TNxCustomBusinessObject;
  mMonUnits:TNxCustomBusinessMonikerCollection;




  function Import_Poctu(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TSiteForm;rucne:boolean;chyba:boolean;index:integer) : Boolean;
var
    oprava : boolean;
    mImportFile:TStringList;
    mTargetFile:TStringList;
    mRowList:TStringList;
    mFieldHead,mFieldConst,mFieldLabel,mFieldType,mFieldLenght,mfieldValue,mFieldTable,mFieldCLSID,mFieldField,mFieldCreate,mFieldBo:TStringList;
    mDoc,mDocHead : TNxParameters;
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
    mean,mStoreCard_ID:string;
    mquantity:double;
    mOLEStorecard, mRollStorecard, mOResultStorecard: Variant;
    mOLEBusOrder, mRollBusOrder, mOResultBusOrder: Variant;
   midsStore,midsStorecard:TStringList;
   midsBusOrder:TStringList;
  mGrid: TdbGrid;
  mControl: TControl;
  mDataSource: TDataSource;
  mDataset: TNxRowsObjectDataSet;
  mid_Storecard,mid_BusOrder:string;
  mRows:TNxCustomBusinessMonikerCollection;
  mNewRow:TNxCustomBusinessObject;
  mscname:string;
  mskladnik,mprevzal:string;
  xresult:Boolean;
  mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  mCedAccountingType:TRollComboEdit ;
  mCedAccountingType2:TRollComboEdit ;
  mCedAccountingType3:TRollComboEdit ;
  mCbCc:TComboBevel;
  mCb:TRollComboEdit;
  mLabel1,mLabel2,mLabel3:TLabel;
  mTEdit1,mTEdit2,mTEdit3:TEdit;
  mID_FIRM,mID_person,mID_division:string;
  Mpoz1,mpoz2,mpoz3:string;
  cbPerson: TComboBox;//TRollComboEdit;
  mRow,  mStoreCard,mdocrowbatches ,mbonew: TNxCustomBusinessObject;
  mCnts,mBO_Moniker,mRowsOutput : TNxCustomBusinessMonikerCollection;
  i, j : integer;
  mids_storeunits:TStringList;
  mstorecontainer:TNxCustomBusinessObject;
  mlist,mlist2:TStringList;
  mFirm_ID,mBatch_ID:string;
  mpos:integer;
  mToken:string;
  mChangeBatch:TStringList;
  mShowProgres:Boolean;
  mline:string;
  mPrubezneQuantity,mpomocQuantity:double;
  mImportMan: TNxDocumentImportManager;
  mParams: TNxParameters;
  mParam: TNxParameter;
  mstringline:string;
  mi:integer;
  msSarze,msMnozstvi:string;
  mboolean:boolean;
begin
     mShowProgres:=true;
    mImportFile := TStringList.Create;

    if not FileExists(AFileName) then begin   // soubor nenalezen
      NxShowSimpleMessage('Soubor nedeohledán',nil);
      Result := False;
      exit;
    end;
{    mr:=tstringlist.create;
    try
         msite.BaseObjectSpace.SQLselect('select sum(X_Quantity) from StoreBatches',mr);
         if NxIBStrToFloat(mr.Strings[0])>0 then begin
             mboolean:=InputQuery('Již existují počty na šaržích, načtené šarže se budou přičítat',
             ' můžete import přerušit, počty smazat a importovat znovu','');
             if mboolean then begin
                 NxShowSimpleMessage('Import byl uživatelem přerušen',nil);
                 exit;
             end;
         end;

    finally
        mr.free;
    end;
 }

    try

        mImportFile.LoadFromFile(AFileName);
         ProgressInit(msite, 'Načtení souboru ' + filename, 100);

                 for i:=0 to mImportFile.Count-1 do begin   // načtení souboru
                          ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));

                                  // ****** načtení dat ze souboru
                                  mstringline:= mImportFile.strings[i];
                                  mstringline :=NxSearchReplace(NxSearchReplace(mstringline, '"', '', [srAll]), ';', '";"', [srAll]) +';';
                                  mstringline := NxSearchReplace(mstringline, chr(9), ';', [srAll]);

                                  if trim(mstringline)<>'' then begin

                                          mfieldValue:= TStringList.Create;
                                          try


                                                 Parsevalue(mstringline,';',mstringline,mfieldValue,2);

                                                 if mfieldValue.Count>0 then begin

                                                                 msSarze:= NxSearchReplace(mfieldValue.Strings[0],'"', '', [srAll]) ;
                                                                 if mfieldValue.Count>1 then begin
                                                                      msMnozstvi:= NxSearchReplace(mfieldValue.Strings[1],'"', '', [srAll]) ;
                                                                 end else begin
                                                                      msMnozstvi:='1';
                                                                 end;



                                                                    mid:='';
                                                                  mr:=tstringlist.create;
                                                                  try
                                                                        os.SQLSelect('select id from StoreBatches where (name=' + quotedstr(msSarze) + ') and hidden=' + quotedstr('N'),mr) ;
                                                                        if mr.count>0 then begin
                                                                               mid:=mr.Strings[0] ;
                                                                        end else begin
                                                                            os.SQLSelect('select id from StoreBatches where (name=' + quotedstr('0'+msSarze) + ') and hidden=' + quotedstr('N'),mr) ;
                                                                                  if mr.count>0 then begin
                                                                                     mid:=mr.Strings[0] ;
                                                                                  end else begin
                                                                                      os.SQLSelect('select id from StoreBatches where (name=' + quotedstr('00'+msSarze) + ') and hidden=' + quotedstr('N'),mr) ;
                                                                                          if mr.count>0  then begin
                                                                                              mid:=mr.Strings[0] ;
                                                                                          end else begin
                                                                                              mid:='' ;
                                                                                          end;
                                                                                  end;
                                                                        end;
                                                                  finally
                                                                      mr.free;
                                                                  end;

                                                                   if mid<>'' then begin
                                                                      mi:=msite.BaseObjectSpace.SQLExecute('update StoreBatches set X_Quantity=' + quotedstr(msMnozstvi) + ' where id=' + quotedstr(mid));
                                                                   end else begin
                                                                           mboolean:=InputQuery('Nepodařilo se najít šarži' + msSarze, 'šarže v množství '+ msMnozstvi, msSarze);
                                                                            //NxShowSimpleMessage('Šarži ' + msSarze + ' v počtu ' + quotedstr(msMnozstvi) + ' Se nepodařilo dohledat a zapsat. Opravte ručně', nil )  ;
                                                                   end;
                                                        end;
                                                    finally
                                                        mfieldValue.free;
                                                    end;

                                       end;





                 end;
                 ProgressDispose();
       finally
         mImportFile.free ;
       end;




end;



//procedure _CanSaveNow_Hook(Self: TDynSiteForm; var ACanSaveNow: Boolean);
//begin
//  if (Self.CompanyCache.GetUserID= '1600000101') or (Self.CompanyCache.GetUserID ='6K00000101') or (Self.CompanyCache.GetUserID ='2K00000101') or (Self.CompanyCache.GetUserID ='3K00000101') or (Self.CompanyCache.GetUserID='SUPER00000') then begin
//      ACanSaveNow:=false;
//  end;
//end;






procedure PrintOnExec(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile:string;
  mi:integer;
begin
  mdir:='';
  mfile:='';

 mSite := NxFindSiteForm(TComponent(Sender));
  //  mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
  //  if mTabList = nil then RaiseException('tabList nenalezen');
  //  mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
  //  if mDBGrid = nil then RaiseException('DBGrid nenalezen');


  if (index=0) then begin
      if PromptForFileName(mFileName, '*.csv', '', 'Soubory SP', mdir, False) then begin
          mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
          mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
      end;
 Import_Poctu(msite.baseobjectspace, mfilename, mdir,mfile,msite,true,false,index);
  end ;

  //ImportFile(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);
  if index=1 then begin
         mi:=msite.BaseObjectSpace.SQLExecute('update StoreBatches set X_Quantity=0');
         NxShowSimpleMessage('Počty pro tisk na šaržích smazány',nil);
  end;


 msite.Refresh;

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
  mUser : TNxCustomBusinessObject;
begin

if not Assigned(Self.BaseObjectSpace) then
    exit;
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
  mUser.Load(Self.CompanyCache.GetUserID, nil);
//  if copy(mUser.GetFieldValueAsstring('X_Parametr'),1,1)='1' then begin
           mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'soubor';
          mMAction.Caption := 'Načtení počtu šarží pro tisk';
          mMAction.Items.Add('Plnění z CSV');
          mMAction.Items.Add('Smazání počtu ');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @PrintOnExec;


//  end;




end;





begin
end.
