uses
  'abra.cz.servis.fika.FolderSupport.Common';

// Agenda NV interni
procedure Example1(Self: TSiteForm);
var
  MyAction: TAction;
begin
  MyAction:= self.GetNewAction;
  MyAction.ShowControl:= True;
  MyAction.ShowMenuItem:= True;
  MyAction.Caption:= 'Vytvoř folder';
  MyAction.Category:= 'tabList';
  MyAction.OnExecute:= @CallCreateFolder;
end;

procedure CallCreateFolder(Sender: TObject; AIndex :Integer);
var
  mSiteForm: TSiteForm;
  mBO: TNxCustomBusinessObject;
begin
  mSiteForm := TComponent(Sender).Site;
  if mSiteForm is TDynSiteForm then begin
    mBO := TDynSiteForm(mSiteForm).CurrentObject;
  end else begin
    mBO := TBusRollSiteForm(mSiteForm).CurrentObject;
  end;
  CreateFolder('nabidky_vydane\'+mBo.GetFieldValueAsString('DocQueue_ID.Code')+'\'+mBo.GetFieldValueAsString('Period_ID.Code')+'\', mBo.GetFieldValueAsString('DisplayName'), mBo.GetFieldValueAsString('ID'));
end;


// Agenda NV externi
procedure Example2(Self: TSiteForm);
var
  MyAction: TAction;
begin
  MyAction:= self.GetNewAction;
  MyAction.ShowControl:= True;
  MyAction.ShowMenuItem:= True;
  MyAction.Caption:= 'Vytvoř folder';
  MyAction.Category:= 'tabList';
  MyAction.OnExecute:= @CallCreateFolder;
end;

procedure CallCreateFolderByExe(Sender: TObject; AIndex :Integer);
var
  mSiteForm: TSiteForm;
  mBO: TNxCustomBusinessObject;
begin
  mSiteForm := TComponent(Sender).Site;
  if mSiteForm is TDynSiteForm then begin
    mBO := TDynSiteForm(mSiteForm).CurrentObject;
  end else begin
    mBO := TBusRollSiteForm(mSiteForm).CurrentObject;
  end;
  CreateFolderExe('nabidky_vydane\',mBo.GetFieldValueAsString('DocQueue_ID.Code')+'\', mBo.GetFieldValueAsString('Period_ID.Code')+'\', mBo.GetFieldValueAsString('DisplayName'), mBo.GetFieldValueAsString('ID'))
end;

begin
end.