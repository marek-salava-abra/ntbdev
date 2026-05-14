uses 'abra.eu.MASK.funkce_ctecky2017_vyr.Base_function','abra.eu.MASK.funkce_ctecky2017_vyr.Libs','abra.eu.MASK.funkce_ctecky2017_vyr.Forms';
 {
procedure AfterSiteOpen_Hook(Self: TSiteForm);
var
xsite:tSiteform;
mBResult:boolean;
begin
xSite := self;
    mBresult:=CteckaItem(xsite);
   xsite.Refresh;
end;

   }

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
   {        // if (mUser.GetFieldValueAsBoolean('X_funkce_ctecky')) then begin
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
                   end; }



                  mMAction := Self.GetNewMultiAction;
                  mMAction.ShowControl := True;
                  mMAction.ShowMenuItem := True;
                  mMAction.Caption := 'Ctecka';
                  mMAction.Hint := 'Čtečka';
                  mMAction.Category := 'tabList';
                  mMAction.OnExecuteItem := @StartItem;
                  mMAction.Items.Add('čtečka');
                  mMAction.Items.Add('Vychystavani průvodce');
                  mMAction.Items.Add('Vychystavani ');
                  mMAction.Items.Add('Zajištění výroby');
                  mMAction.Items.Add('Expedice');

  finally
      mUSer.free;
  end;
end;







procedure StartItem(Sender: Tcomponent;index:integer);
var
  xSite : TDynSiteForm;
  mB_result:boolean;
  mS_result:string;
  mIDs_Document:string;

begin
 xSite := TComponent(Sender).DynSite;
      mIDs_Document:=BarCode_document_Agenda (xsite,'');

  if index=1 then mB_result:=Vychystavani_RO(xsite,mIDs_Document);
  if index=2 then mS_result:=BarCodeDialog_prepravka(xSite,'CDMK5QAWZZDL342X01C0CX3FCC',false,
                                                     0,0,360,480,'Zdrojový doklad: ',
                                                     0,0, mIDs_Document,
                                                     'EAN','Storno','','přeskočit',
                                                     'Šarže');
  if index=3 then begin
       mS_result:=Vyroba_orderItem(xSite,mIDs_Document,'4D15000101');  // výroba bandáže  //  var AErrList: TStringList; var ADoc_OID: string;

       //mS_result:=mS_result + ' , ' + Vyroba_orderItem(xSite,mIDs_Document,'3D15000101');  // výroba bandáže  //  var AErrList: TStringList; var ADoc_OID: string;
                 if mS_result<>' , ' then
                 NxShowSimpleMessage('Proběhlo zajišténí výroby doklady: ' + mS_result,nil)
                 else NxShowSimpleMessage('Nebylo možné zajistit výrobu ',nil)
                 ;
  end;
end;

begin
end.
