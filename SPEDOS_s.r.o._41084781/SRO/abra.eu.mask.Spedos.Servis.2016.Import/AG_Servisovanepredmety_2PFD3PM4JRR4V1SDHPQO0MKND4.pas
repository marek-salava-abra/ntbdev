uses 'abra.eu.mask.Spedos.Servis.2016.Import.Servisované předměty';

const
    mFilter='*.xml';

procedure FormCreate_Hook(Self: TSiteForm);
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
          mMAction.Hint := 'Import SP z Výroby';
          mMAction.Caption := 'Import SP ';
          mMAction.Items.Add('Import SP z Výroby');
          mMAction.Items.Add('Výpis chyb importu SP z Výroby');
          mMAction.Items.Add('Import SP z OD');
          mMAction.Items.Add('Výpis chyb importu SP z OD');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


end;



procedure OnExec(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile:string;
begin
 mSite := NxFindSiteForm(TComponent(Sender));
   // mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
   // if mTabList = nil then RaiseException('tabList nenalezen');
   // mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
   // if mDBGrid = nil then RaiseException('DBGrid nenalezen');

   if index=0 then  begin
        if PromptForFileName(mFileName, mfilter, '', 'Soubory SP', '\\g3\abrag3\ImportCZ\servisovane_predmety', False) then begin
          mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
          mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
          Import_SP_V(msite.baseobjectspace, mfilename, mdir,mfile,msite,true,false);
        end;
   end;
   if index=2 then  begin
        if PromptForFileName(mFileName, mfilter, '', 'Soubory SP', '\\192.168.0.36\g3\ImportCZ\Prenos_abra\Obchodni_dokumentace', False) then begin
          mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
          mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
          Import_SP_OD(msite.baseobjectspace, mfilename, mdir,mfile,msite,true,false);
        end;
   end;




  //ImportFile(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);
  //if index=0 then
  //if index=1 then Import_SP_V(msite.baseobjectspace, mfilename, mdir,mfile,msite,true,true);
  //if index=2 then Import_SP_OD(msite.baseobjectspace, mfilename, mdir,mfile,msite,true,false);
  //if index=3 then Import_SP_OD(msite.baseobjectspace, mfilename, mdir,mfile,msite,true,true);
end;












begin
end.
