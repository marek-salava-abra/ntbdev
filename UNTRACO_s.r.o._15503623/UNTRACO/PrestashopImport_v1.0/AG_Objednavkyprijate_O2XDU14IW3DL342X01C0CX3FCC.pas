uses 'PrestashopImport_v1.0.Objednavka_prijata';

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
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import ESHOP';
  mAction.Hint := 'Import objednávek z Prestashopu';
  mAction.Category := 'tabList';
  mAction.OnExecute := @OnExec;
//  mAction.OnUpdate := @SiteIsEdited;;
end;



procedure OnExec(Sender: TComponent);
var
  mSite : TSiteForm;
  OS1: TNxCustomBusinessObject ;
  zadej:string;
  mfilename:string;
  mdir,mfile:string;
begin

  mSite := NxFindSiteForm(Sender);
   if PromptForFileName(mFileName, mfilter, '', 'Soubor ESHOP', mdir, False) then begin
    mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
    mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
    NxShowSimpleMessage(Format('Bude importován soubor %s %s', [mdir,mfile,]),msite);
    ImportFile(mSite.BaseObjectSpace, mfilename, mdir,mfile);
    end
   else begin
   NxShowMessage('Upozornění','Nebyl vybrán žádný soubor',mdWarning,false,mSite);
   end;

end;




begin
end.