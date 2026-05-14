uses 'abra.eu.MASK.import_CSV_par.lib';
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
    mr:TStringList;
begin

    if not FileExists(AFileName) then begin   // soubor nenalezen
      Result := False;
      exit;
    end;
try
    mImportFile := TStringList.Create;
                                mCustomBusinessObject:= os.CreateObject('OWHN2TMXL2COJJ3LKNBV4OVSTC');

            mImportFile.LoadFromFile(AFileName);
            if mImportFile.Count >1 then begin
                 i := 1;
                 while i < mImportFile.Count do begin
                    try
                                mfieldValue:= TStringList.Create;
                                //mTargetFile.strings[i]:=mImportFile.strings[i];
                                Parsevalue(mDocHead, mImportFile.strings[i],';',mImportFile.strings[i],mfieldValue,36);
                                try
                                  mExist_ID:='';

                                 if mFieldvalue.Strings[0]<>'' then begin

                                  try
                                  mr:=TStringList.create;
                                      mCustomBusinessObject.ObjectSpace.SQLSelect('select id from ServicedObjects where hidden=' + quotedstr('N') + ' and code='+quotedstr(Trim(copy(mFieldvalue.Strings[0],1,20))),mr);
                                      if mr.count>0 then begin
                                         mExist_ID:=mr.Strings[0];
                                      end else begin
                                         mCustomBusinessObject.New;
                                         mCustomBusinessObject.Prefill;
                                         mCustomBusinessObject.SetFieldValueAsString('Code',Trim(copy(mFieldvalue.Strings[0],1,20)));
                                         mCustomBusinessObject.SetFieldValueAsString('Firm_ID','3X23000101');
                                         mCustomBusinessObject.Save;
                                         mExist_ID:=mCustomBusinessObject.oid;
                                      end;
                                  finally
                                      mr.free;
                                  end;
                                         if mExist_ID<>'' then begin
                                                mCustomBusinessObject.Load(mExist_ID,nil);
                                               try
                                                if not nxisblank(mFieldvalue.Strings[1]) then mCustomBusinessObject.SetFieldValueAsString('X_par1',trim(mFieldvalue.Strings[1]));
                                                if not nxisblank(mFieldvalue.Strings[2]) then mCustomBusinessObject.SetFieldValueAsString('X_par2',trim(mFieldvalue.Strings[2]));
                                                if not nxisblank(mFieldvalue.Strings[3]) then mCustomBusinessObject.SetFieldValueAsString('X_par3',trim(mFieldvalue.Strings[3]));
                                                if not nxisblank(mFieldvalue.Strings[4]) then mCustomBusinessObject.SetFieldValueAsString('X_par4',trim(mFieldvalue.Strings[4]));
                                                if not nxisblank(mFieldvalue.Strings[5]) then mCustomBusinessObject.SetFieldValueAsString('X_par5',trim(mFieldvalue.Strings[5]));
                                                if not nxisblank(mFieldvalue.Strings[6]) then mCustomBusinessObject.SetFieldValueAsString('X_par6',trim(mFieldvalue.Strings[6]));
                                                if not nxisblank(mFieldvalue.Strings[7]) then mCustomBusinessObject.SetFieldValueAsString('X_par7',trim(mFieldvalue.Strings[7]));
                                                if not nxisblank(mFieldvalue.Strings[8]) then mCustomBusinessObject.SetFieldValueAsString('X_par8',trim(mFieldvalue.Strings[8]));
                                                if not nxisblank(mFieldvalue.Strings[9]) then mCustomBusinessObject.SetFieldValueAsString('X_par9',trim(mFieldvalue.Strings[9]));
                                                if not nxisblank(mFieldvalue.Strings[10]) then mCustomBusinessObject.SetFieldValueAsString('X_par10',trim(mFieldvalue.Strings[10]));
                                                if not nxisblank(mFieldvalue.Strings[11]) then mCustomBusinessObject.SetFieldValueAsString('X_par11',trim(mFieldvalue.Strings[11]));
                                                if not nxisblank(mFieldvalue.Strings[12]) then mCustomBusinessObject.SetFieldValueAsString('X_par12',trim(mFieldvalue.Strings[12]));
                                                if not nxisblank(mFieldvalue.Strings[13]) then mCustomBusinessObject.SetFieldValueAsString('X_par13',trim(mFieldvalue.Strings[13]));
                                                if not nxisblank(mFieldvalue.Strings[14]) then mCustomBusinessObject.SetFieldValueAsString('X_par14',trim(mFieldvalue.Strings[14]));
                                                if not nxisblank(mFieldvalue.Strings[15]) then mCustomBusinessObject.SetFieldValueAsString('X_par15',trim(mFieldvalue.Strings[15]));
                                                if not nxisblank(mFieldvalue.Strings[16]) then mCustomBusinessObject.SetFieldValueAsString('X_par16',trim(mFieldvalue.Strings[16]));
                                                if not nxisblank(mFieldvalue.Strings[17]) then mCustomBusinessObject.SetFieldValueAsString('X_par17',trim(mFieldvalue.Strings[17]));
                                                if not nxisblank(mFieldvalue.Strings[18]) then mCustomBusinessObject.SetFieldValueAsString('X_par18',trim(mFieldvalue.Strings[18]));
                                                if not nxisblank(mFieldvalue.Strings[19]) then mCustomBusinessObject.SetFieldValueAsString('X_par19',trim(mFieldvalue.Strings[19]));
                                                if not nxisblank(mFieldvalue.Strings[20]) then mCustomBusinessObject.SetFieldValueAsString('X_par20',trim(mFieldvalue.Strings[20]));
                                                if not nxisblank(mFieldvalue.Strings[21]) then mCustomBusinessObject.SetFieldValueAsString('X_par21',trim(mFieldvalue.Strings[21]));
                                                if not nxisblank(mFieldvalue.Strings[22]) then mCustomBusinessObject.SetFieldValueAsString('X_par22',trim(mFieldvalue.Strings[22]));
                                                if not nxisblank(mFieldvalue.Strings[23]) then mCustomBusinessObject.SetFieldValueAsString('X_par23',trim(mFieldvalue.Strings[23]));
                                                if not nxisblank(mFieldvalue.Strings[24]) then mCustomBusinessObject.SetFieldValueAsString('X_par24',trim(mFieldvalue.Strings[24]));
                                                if not nxisblank(mFieldvalue.Strings[25]) then mCustomBusinessObject.SetFieldValueAsString('X_par25',trim(mFieldvalue.Strings[25]));
                                                if not nxisblank(mFieldvalue.Strings[26]) then mCustomBusinessObject.SetFieldValueAsString('X_par26',trim(mFieldvalue.Strings[26]));
                                                if not nxisblank(mFieldvalue.Strings[27]) then mCustomBusinessObject.SetFieldValueAsString('X_par27',trim(mFieldvalue.Strings[27]));
                                                if not nxisblank(mFieldvalue.Strings[28]) then mCustomBusinessObject.SetFieldValueAsString('X_par28',trim(mFieldvalue.Strings[28]));
                                                if not nxisblank(mFieldvalue.Strings[29]) then mCustomBusinessObject.SetFieldValueAsString('X_par29',trim(mFieldvalue.Strings[29]));
                                                if not nxisblank(mFieldvalue.Strings[30]) then mCustomBusinessObject.SetFieldValueAsString('X_par30',trim(mFieldvalue.Strings[30]));
                                                if not nxisblank(mFieldvalue.Strings[31]) then mCustomBusinessObject.SetFieldValueAsString('X_par31',trim(mFieldvalue.Strings[31]));
                                                if not nxisblank(mFieldvalue.Strings[32]) then mCustomBusinessObject.SetFieldValueAsString('X_par32',trim(mFieldvalue.Strings[32]));
                                                if not nxisblank(mFieldvalue.Strings[33]) then mCustomBusinessObject.SetFieldValueAsString('X_par33',trim(mFieldvalue.Strings[33]));
                                                if not nxisblank(mFieldvalue.Strings[34]) then mCustomBusinessObject.SetFieldValueAsString('X_par34',trim(mFieldvalue.Strings[34]));
                                               // if not nxisblank(mFieldvalue.Strings[35]) then mCustomBusinessObject.SetFieldValueAsString('X_par35',mFieldvalue.Strings[35]);
                                               // if not nxisblank(mFieldvalue.Strings[36]) then mCustomBusinessObject.SetFieldValueAsString('X_par36',mFieldvalue.Strings[36]);
                                               // if not nxisblank(mFieldvalue.Strings[37]) then mCustomBusinessObject.SetFieldValueAsString('X_par37',mFieldvalue.Strings[37]);
                                               finally
                                                mCustomBusinessObject.Save;
                                               end;
                                         end ;
                                         mCustomBusinessObject.free;
                                end;
                                     finally
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
          mMAction.Hint := 'Import_BO zakazky';
          mMAction.Caption := 'Import_BO par';
          mMAction.Items.Add('Import_BO parametry');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;
{        end;}
end;



begin
end.