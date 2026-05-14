uses 'abra.eu.mask_import.Trebic.Objednavka_prijata',
          '_Knihovny_ALL.head';

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
{if false then begin
  mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Import z LIPA';
          mMAction.Caption := 'Import z Třebíče';
          mMAction.Items.Add('Import z Třebíče');
          //mMAction.Items.Add('Výpis chyb');
          //if (Self.CompanyCache.GetUserID='1Z10000101')
          //  or (Self.CompanyCache.GetUserID='1H00000101')
          //  or (Self.CompanyCache.GetUserID='2W00000101')
          //  or (Self.CompanyCache.GetUserID='SUPER00000')
          //  or (Self.CompanyCache.GetUserID='3500000101')
          //  then begin
          //  mMAction.Items.Add('Ignorace chyb');
          // end;
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;
 end;

 }

end;

procedure OnExec(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile:string;
begin
  //mSite := NxFinddySiteForm(Sender);
  msite:=TComponent(Sender).DynSite;
   mdir:='';
   if PromptForFileName(mFileName, mfilter, '', 'Soubor z Třebíče', '\\CZVS0006\Trebic\OV\', False) then begin
    mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
    mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
   end;
  //ImportFile(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);
  if index=0 then ImportFile2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);

  //TDynSiteForm(mSite).Refreshdata;
  msite.activedataset.RefreshCurrentItem;
  msite.activedataset.RefreshAndRestoreLastSelectedItem;
end;





procedure NewBOUpdate(Sender: TObject);
var
  mSite: TDynSiteForm;
  mObj: TNxCustomBusinessObject;
begin
  //OutputDebugString('Jsem v OnUpdate.');
  //OutputDebugString('Sender je '+Sender.ClassName+'.');
  // Zjistime, zda je Sender typu TComponent
  if Sender is TComponent then begin
    //OutputDebugString('Sender je TComponent.');
    // Vyhledame SiteForm (TSiteForm) na kterem je dana akce
    mSite := TComponent(Sender).DynSite;
    if Assigned(mSite) then begin
      //OutputDebugString('Nalezen nadřízený SiteForm.');

      // akce je k dispozici pouze v pripade, ze je v datasetu nejaky zaznam
      // a v pripade, ze neni zahajena editace
      mObj := mSite.CurrentObject;
      try
        TAction(Sender).Enabled := not mSite.Edit and Assigned(mObj);
      finally
        mObj.Free;
      end;
    end;
  end;
end;





begin
end.
