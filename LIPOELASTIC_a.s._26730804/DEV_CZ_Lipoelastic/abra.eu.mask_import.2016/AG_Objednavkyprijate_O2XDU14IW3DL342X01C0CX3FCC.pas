uses 'abra.eu.mask_import.2016.Objednavka_prijata';

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
          mMAction.Hint := 'Import objednávky old 2017';
          mMAction.Caption := 'Import objednávky old 2017 ';
          mMAction.Items.Add('Import objednávky ');
          mMAction.Items.Add('Výpis chyb');
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
begin
  //mSite := NxFinddySiteForm(Sender);
  msite:=TComponent(Sender).DynSite;
   if PromptForFileName(mFileName, mfilter, '', 'Soubor ESHOP TOP', mdir, False) then begin
    mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
    mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
   end;
  //ImportFile(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);
  if index=0 then ImportFile2(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile,msite,true,false,index);
  if index=1 then begin
      ShowMessage(Format('Bude importován soubor %s%s', [mdir,mfile]));
      ImportFile2(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile,msite,true,true,index);

  end;

  if index=2 then begin
      ShowMessage(Format('Bude importován soubor %s%s, chyby budou ignorovány', [mdir,mfile]));
      ImportFile2(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile,msite,true,true,index);

  end;
end;




begin
end.
