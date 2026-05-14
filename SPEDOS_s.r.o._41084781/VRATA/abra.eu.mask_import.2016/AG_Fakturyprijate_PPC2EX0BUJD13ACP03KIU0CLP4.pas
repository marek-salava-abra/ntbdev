uses 'abra.eu.mask_import.2016.Objednavka_prijata';

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
          mMAction.Hint := 'Import FV ';
          mMAction.Caption := 'Import FV ';
          mMAction.Items.Add('Import FV ');
         // mMAction.Items.Add('Výpis chyb');
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
   if PromptForFileName(mFileName, mfilter, '', 'Soubor importu FV', '\\192.168.0.80\abradata\exchange\Vrata\', False) then begin
    mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
    mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
   end;
  //ImportFile(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);
 ImportFile2(msite.BaseObjectSpace, mfilename, mdir,mfile,msite,true,false);

end;




begin
end.
