uses 'abra.eu.API.digitalizace.Base_function','abra.eu.API.digitalizace.Libs','abra.eu.API.digitalizace.Forms';

procedure AfterSiteOpen_Hook(Self: TDynSiteForm);
var
xsite:TDynSiteForm;
mBResult:boolean;
begin
//xSite:= self;
//    mBresult:=CteckaItem(xsite);
//   xsite.Refresh;
end;



procedure InitSite_Hook(Self: TSiteForm);
var

  mUser: TNxCustomBusinessObject;
  mAList: TActionList;
  i: integer;
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mC: TControl;
begin
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
           // if (mUser.GetFieldValueAsBoolean('X_funkce_ctecky')) then begin
                 mAList := Self.GetMainActionList;
                  for i := 0 to mAList.ActionCount-1 do begin
                    mAction := mALIst.Actions[i];
                          if (mAction.Name = 'actFind') then begin
                              mAction.Visible := False;
                          end;
                          if (mAction.Name = 'actFindNext') then begin
                              mAction.Visible := False;
                          end;
                          //if (mAction.Name = 'actShowAgenda') then begin
                          //    mAction.Visible := False;
                          //end;
                   end;



                  mMAction := Self.GetNewMultiAction;
                  mMAction.ShowControl := True;
                  mMAction.ShowMenuItem := True;
                  mMAction.Caption := 'Digitalizace - vizuál';
                  mMAction.Hint := 'Digitalizace - vizuál ';
                  mMAction.Category := 'tabList';
                  mMAction.OnExecuteItem := @StartItem;
                  mMAction.Items.Add('Digitalizace - vizuál');



            //end;


  finally
      mUSer.free;
  end;
end;

Procedure StartItem(sender:tcomponent;index:integer);
var
xsite:TDynSiteForm;
mBResult:boolean;
begin
xSite := TComponent(Sender).DynSite;
    mBresult:=CteckaItem(xsite);
    xsite.Refresh;
end;



begin
end.
