procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Zobrazí majetek/kartu';
  mAction.Hint := 'Tlačítko ke zobrazení karty majetku / skladové karty';
  mAction.Category := 'tabDetail, tabList';
  mAction.OnExecute := @ShowCard;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '     ';
  mAction.Hint := '    ';
  mAction.Category := 'tabList';
  mAction.OnExecute := @EF;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Vytvořit pronájem ';
  mAction.Hint := 'Tlačítko založení nové aktivity';
  mAction.Category := 'tabList';
  mAction.OnExecute := @NewActivity;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Vytvořit nabídku';
  mAction.Hint := 'Tlačítko vytvoření nové NV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @NewNV;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Vytvořit prodej PZ';
  mAction.Hint := 'Tlačítko vytvoření OP pro prodej';
  mAction.Category := 'tabList';
  mAction.OnExecute := @NewPZ;

end;

Procedure EF (sender:TComponent);
begin
end;


Procedure ShowCard (sender:TComponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
begin
  mSite:=TComponent(sender).BusRollSite;
  mBO:=TBusRollSiteForm(mSite).CurrentObject;
  if Assigned(mbo) then begin
     if not(NxIsEmptyOID(mbo.GetFieldValueAsString('U_assetcard_ID'))) then msite.ShowDynForm('K0CPO0X11NEL314Z00C5PPZRR4', nil, Nil, False, 'DoShowOnly;'+mbo.GetFieldValueAsString('U_assetcard_ID'));
     if not(NxIsEmptyOID(mbo.GetFieldValueAsString('U_Smallassetcard_ID'))) then msite.ShowDynForm('4M4R1JFNBREL31ME00C5PPBIWO', nil, Nil, False, 'DoShowOnly;'+mbo.GetFieldValueAsString('U_Smallassetcard_ID'));
     if not(NxIsEmptyOID(mbo.GetFieldValueAsString('U_StoreCard_ID'))) then msite.ShowDynForm('W31KWYTC5FDL342M01C0CX3FCC', nil, Nil, False, 'DoShowOnly;'+mbo.GetFieldValueAsString('U_StoreCard_ID'));

  end;

end;

Procedure NewActivity (sender:TComponent);
var
 mSite:TSiteForm;
 mParams, mTemplates: TNxParameters;
begin
 mSite:=TComponent(sender).BusRollSite;

            mParams := TNxParameters.Create;
            try
                mTemplates := mParams.NewFromDataType(dtList, 'TemplateParams').AsList;
                mtemplates.NewFromDataType(dtString, 'SolverRole_ID').AsString := '6B00000101';
                mtemplates.NewFromDataType(dtString, 'ResolvedBy_ID').AsString := '1910000101';
                {
                mTemplates.NewFromDataType(dtString, 'Description').AsString := 'Ukazka ...';
                mTemplates.NewFromDataType(dtString, 'Subject').AsString := mStrings[0];
                }
                mSite.ShowDynForm('OYC0P3TDDY1ORIJO2SKTP2KZKG', mParams, Nil, False, 'DoNewOnly');
            finally
                mParams.Free;
            end;

end;

procedure newPZ (sender:TComponent);
var
 mSite:TSiteForm;
 mParams2:TNxParameters;
 mList:TStringList;
 mTemplates: TNxParameters;
 i:integer;
 mString:String;
begin
  mSite:=TComponent(sender).BusRollSite;
  mList:=TStringList.Create;
  mlist.clear;
  mString:='';
  TBusRollSiteForm(mSite).List.GetSelectedId(mList);
  for i:=0 to mlist.Count-1 do begin
     mString:=mString+mList.Strings[i];
  end;
     mParams2 := TNxParameters.Create;
     mTemplates := mParams2.NewFromDataType(dtList, 'TemplateParams').AsList;
     mTemplates.NewFromDataType(dtString, 'U_ListIDS').AsString:=mString;
     mTemplates.NewFromDataType(dtString, 'DocQueue_ID').AsString :='1L00000101';
     mTemplates.NewFromDataType(dtString, 'TransportationType_ID').AsString :='00000P1000';

    msite.ShowDynForm('O2XDU14IW3DL342X01C0CX3FCC', mParams2, Nil, False, 'DoNewOnly');
    mlist.clear;
end;

procedure newNV (sender:TComponent);
var
 mSite:TSiteForm;
 mParams2:TNxParameters;
 mList:TStringList;
 mTemplates: TNxParameters;
 i:integer;
 mString:String;
begin
  mSite:=TComponent(sender).BusRollSite;
  mList:=TStringList.Create;
  mlist.clear;
  mString:='';
  TBusRollSiteForm(mSite).List.GetSelectedId(mList);
  for i:=0 to mlist.Count-1 do begin
     mString:=mString+mList.Strings[i];
  end;
     mParams2 := TNxParameters.Create;
     mTemplates := mParams2.NewFromDataType(dtList, 'TemplateParams').AsList;
     mTemplates.NewFromDataType(dtString, 'U_ListIDS').AsString:=mString;
     mTemplates.NewFromDataType(dtString, 'DocQueue_ID').AsString :='2A10000101';
     mTemplates.NewFromDataType(dtString, 'IssuedOfferType_ID').AsString :='4300000101';
     mTemplates.NewFromDataType(dtString, 'ResponsibleRole_ID').AsString :='6B00000101';
    msite.ShowDynForm('O1C4ERBIVNIOT4WASH5MYY14CK', mParams2, Nil, False, 'DoNewOnly');
  mlist.clear;
end;


begin
end.