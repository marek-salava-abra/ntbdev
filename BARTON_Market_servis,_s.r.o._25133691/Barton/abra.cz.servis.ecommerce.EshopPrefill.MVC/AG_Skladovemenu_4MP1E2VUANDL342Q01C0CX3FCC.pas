uses
  'abra.cz.servis.ecommerce.EshopPrefill.MVC.Common';

procedure InitSite_Hook(Self: TSiteForm);
var
  MyAction: TAction;
begin
  MyAction:= self.GetNewAction;
  MyAction.ShowControl:= True;
  MyAction.ShowMenuItem:= True;
  MyAction.Caption:= 'Eshop folder';
  MyAction.Hint := 'Vytvoří folder (adresář) pro obrázky k menu na Abra Eshopu';
  MyAction.Category:= 'tabList, tabDetail';
  MyAction.OnExecute:= @ClickCreateFolder;
end;

procedure ClickCreateFolder(Sender: TObject; AIndex :Integer);
var
  mSiteForm: TSiteForm;
  mBO, mBOEdit: TNxCustomBusinessObject;
begin
  mSiteForm := TComponent(Sender).Site;
  try
    mBO := TBusRollSiteForm(mSiteForm).CurrentObject;
    if Assigned(mBo) then begin
      if CallCreateSmFolder(mBo, True) then begin
      // Pokud uzivatel vytvari folder tlacitkem, tak se rozvnou zatrhne priznak pro zobrazni obrazku z folderu.
        if mBo.GetFieldValueAsBoolean('X_ShowFolderImage') =  False then begin
          mBOEdit := mSiteForm.BaseObjectSpace.CreateObject('42P1E2VUANDL342Q01C0CX3FCC');
          mBOEdit.Load(mBo.GetFieldValueAsString('ID'), nil);
          mBOEdit.SetFieldValueAsBoolean('X_ShowFolderImage', True);
          mBOEdit.Save;
          TBusRollSiteForm(mSiteForm).RefreshData;
        end;
        NxMessageBox('Informace', 'Úspěšně vytvořen adresář pro obrázky. Adresář otevřete na záložce formuláře v detailu skladové menu.', mdInformation, mdbOk, 2, [mdpSystemModal], False, nil);
      end else begin
        // Chybovou hlasku vrati finalne volana funkce CreateEshopFolder2.
      end;
    end;
  finally
    mBO := nil;
    mBOEdit := nil;
    mSiteForm := nil;
  end;
end;

begin
end.