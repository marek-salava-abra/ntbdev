uses 'eu.abra.japl.Feprodukt.Shoptet.ImportOrder.Import';

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
  mAction.Caption := 'Import eshop';
  mAction.Hint := 'Import eshop';
  mAction.Category := 'tabList';
  mAction.OnExecute := @OnExec;
  //mAction.OnUpdate := @SiteIsEdited;
end;

procedure OnExec(Sender: TComponent);
var
  mSite : TSiteForm;
  OS1: TNxCustomBusinessObject ;
  mDynSite: TDynSiteForm;
  zadej:string;
  mfilename:string;
  mdir,mfile:string;
  mDBGrid: TDBGrid;
begin

  mSite := NxFindSiteForm(Sender);
  mDynSite := TDynSiteForm(mSite);
   if PromptForFileName(mFileName, mfilter, '', 'Soubor pro import', mdir, False) then begin
    mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
    mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
    ShowMessage(Format('Bude importován soubor %s %s', [mdir,mfile,]));
    //ImportFile(mSite.BaseObjectSpace, mfilename, mdir,mfile,mSite);
    InsertOrder(mDynSite.BaseObjectSpace, mfilename);
    end
   else begin
   ShowMessage('Nebyl vybrán žádný soubor');
   end;
   mDynSite.RefreshData;


end;




begin
end.
