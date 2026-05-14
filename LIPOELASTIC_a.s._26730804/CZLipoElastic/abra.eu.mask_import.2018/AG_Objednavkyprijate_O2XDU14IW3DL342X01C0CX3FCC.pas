uses '_Knihovny_ALL.head', '_Knihovny_ALL.Progress','_Knihovny_ALL.Parse',
'abra.eu.mask_import.2018.Objednavka_prijata';

const
    mFilter='*.xml';





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
          mMAction.Hint := 'Import objednávky';
          mMAction.Caption := 'Import objednávky ';
          mMAction.Items.Add('Import objednávky Eshop ');
          mMAction.Items.Add('Hromadný import Eshop ');
          mMAction.Items.Add('Výpis chyb Eshop ');
          mMAction.Items.Add('Import Email');
          mMAction.Items.Add('Import Třebíč');
          if (Self.CompanyCache.GetUserID='1Z10000101')
            or (Self.CompanyCache.GetUserID='1H00000101')
            or (Self.CompanyCache.GetUserID='2W00000101')
            or (Self.CompanyCache.GetUserID='SUPER00000')
            or (Self.CompanyCache.GetUserID='3500000101')
            then begin
            mMAction.Items.Add('Ignorace chyb');
           end;
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;




end;

procedure OnExec(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile:string;
  mFileList:tstringlist;
begin
  //mSite := NxFinddySiteForm(Sender);
  msite:=TComponent(Sender).DynSite;
   if index<>1 then begin
       if PromptForFileName(mFileName, mfilter, '', 'Soubor ESHOP TOP', mdir, False) then begin
          mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
          mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
        end;
   end;
  //ImportFile(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);
  if index=0 then ImportFile2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index,TDynSiteForm(msite).CompanyCache.GetUserID);
  if index=1 then begin
        mFileList:=TStringList.create;
        try
                //mdir:= 'T:\Hromadne';
                mdir:= '\\CZVS0006\Import\Hromadne';
                NxGetFileList(mdir,mfilelist,'TOP*.*',true);
                NxGetFileList(mdir,mfilelist,'ZOP*.*',true);
                NxGetFileList(mdir,mfilelist,'MOP*.*',true);
                NxGetFileList(mdir,mfilelist,'OPE*.*',true);
                NxGetFileList(mdir,mfilelist,'*',true);
                     ProgressInit(msite, 'Načtení souboru ' + '', 100);
                                 //  NxShowSimpleMessage(inttostr(mfilelist.count),nil);
                                for i:=0 to mFileList.count-1 do begin
                                     ProgressSetPos(1+NxFloor(i/(mfilelist.Count-2)*99), inttostr(i) +' z '+inttostr(mfilelist.Count-2));
                                     mFile:=copy(mFileList.Strings[i],1+NxCharPosR('\',mFileList.Strings[i]),Length(mFileList.Strings[i]))+'.xml';
                                     mfilename:=mdir+'\' + mfile;
                                     //NxShowSimpleMessage(mfilename + ' - '+ mdir+' - ' +mfile,nil);
                                     if mFile<>'' then begin
                                         ImportFile2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index,TDynSiteForm(msite).CompanyCache.GetUserID);
                                     end;
                                end;
                     ProgressDispose()   ;
        finally
            mFileList.free;

        end;

    end;




  if index=2 then begin
      ShowMessage(Format('Bude importován soubor %s%s', [mdir,mfile]));
      ImportFile2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,true,index,TDynSiteForm(msite).CompanyCache.GetUserID);

  end;

  if index=4 then begin
      ShowMessage(Format('Bude importován soubor %s%s, chyby budou ignorovány', [mdir,mfile]));
      ImportFile2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,true,index,TDynSiteForm(msite).CompanyCache.GetUserID);

  end;
  if index=5 then begin
      ShowMessage(Format('Bude importován soubor %s%s, chyby budou ignorovány', [mdir,mfile]));
      ImportFile2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,true,index,TDynSiteForm(msite).CompanyCache.GetUserID);

  end;
  TDynSiteForm(mSite).Refreshdata;
end;





begin
end.
