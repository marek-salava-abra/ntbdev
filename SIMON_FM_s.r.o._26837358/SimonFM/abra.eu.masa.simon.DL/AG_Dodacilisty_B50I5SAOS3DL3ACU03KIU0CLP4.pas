Var
  gModalResult : integer;

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2,mAction3: TBasicAction;
  mUser : TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;
    mAction2 := Self.GetNewAction;
    mAction2.ShowControl := True;
    mAction2.ShowMenuItem := True;
    mAction2.Caption := 'Zobraz označené';
    mAction2.Hint := 'Zobrazí označené DL v samostatném okně';
    mAction2.Category := 'tabList';
    mAction2.OnExecute := @ShowSelected;

    {mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Popis';
    mAction.Hint := 'Doplní Popis';
    mAction.Category := 'tabList';
    mAction.OnExecute := @ImportOnExecute;
    mAction.OnUpdate := @ImportOnUpdate;

    mAction2 := Self.GetNewAction;
    mAction2.ShowControl := True;
    mAction2.ShowMenuItem := True;
    mAction2.Caption := 'Rozvoz';
    mAction2.Hint := 'Nastaví dnešní datum na rozvozové';
    mAction2.Category := 'tabList';
    mAction2.OnExecute := @SetRozvoz;

    mAction3 := Self.GetNewAction;
    mAction3.ShowControl := True;
    mAction3.ShowMenuItem := True;
    mAction3.Caption := 'Doklady vráceny';
    mAction3.Hint := 'Nastaví dnešní datum na vrácení doklad';
    mAction3.Category := 'tabList';
    mAction3.OnExecute := @SetNavrat; }
end;

Procedure ShowSelected(sender:TComponent);
var
 mList,mSelList:tstringlist;
 i,j:integer;
 mBO:TNxCustomBusinessObject;
 mSite:TSiteForm;
begin
 mSite:=TComponent(sender).DynSite;
 mList:=TStringList.create;
 mSelList:=TStringList.Create;
 TDynSiteForm(msite).List.GetSelectedId(mList);
 if mlist.count>0 then begin
      j:=mList.count-1;
      for i:=0 to mlist.count-1 do begin
        mSelList.add(QuotedStr(mList.Strings[i]));
      end;
      mSite.ShowSite(Site_BillOfDeliveries,true,'QueryByUserDynSQLCondition;A.ID in ('+mSelList.delimitedtext+');Omezení za zdrojhový doklad');
 end;
end;


Procedure SetRozvoz(sender:TComponent);
var
 mList:tstringlist;
 i,j:integer;
 mBO:TNxCustomBusinessObject;
 mSite:TSiteForm;
begin
 mSite:=TComponent(sender).DynSite;
 mList:=TStringList.create;
 TDynSiteForm(msite).List.GetSelectedId(mList);
 if mlist.count>0 then begin
   j:=mList.count-1;
   if NxMessageBox('Dotaz', 'Rozvést '+inttostr(mlist.Count)+' dodacích listů?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin
      for i:=0 to mlist.count-1 do begin
        mBO:=msite.BaseObjectSpace.CreateObject(Class_BillOfDelivery);
        mBO.Load(mlist.Strings[i],nil);
        mBO.SetFieldValueAsDateTime('U_rozvoz',Date);
        mBO.Save;
        mBO.free;
      end;
      TDynSiteForm(mSite).RefreshData;
      TDynSiteForm(msite).ActiveDataSet.SeekID(mlist.Strings[j]);
   end;
 end;
end;

Procedure SetNavrat(sender:TComponent);
var
 mList:tstringlist;
 i,j:integer;
 mBO:TNxCustomBusinessObject;
 mSite:TSiteForm;
begin
 mSite:=TComponent(sender).DynSite;
 mList:=TStringList.create;
 TDynSiteForm(msite).List.GetSelectedId(mList);
 if mlist.count>0 then begin
   j:=mList.count-1;
   if NxMessageBox('Dotaz', 'Vrátit '+inttostr(mlist.Count)+' dodacích listů?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin
      for i:=0 to mlist.count-1 do begin
        mBO:=msite.BaseObjectSpace.CreateObject(Class_BillOfDelivery);
        mBO.Load(mlist.Strings[i],nil);
        mBO.SetFieldValueAsDateTime('U_dokladvracen',Date);
        mBO.Save;
        mBO.free;
      end;
      TDynSiteForm(mSite).RefreshData;
      TDynSiteForm(msite).ActiveDataSet.SeekID(mlist.Strings[j]);
   end;
 end;
end;


procedure ImportOnUpdate(Sender: TObject);
begin
  TBasicAction(Sender).Enabled := True;
end;

procedure ImportOnExecute(Sender: TObject);
var
mSite: TSiteForm;
mVydat_poznamka, mRozvoz_poznamka, mDoklady_poznamka, mpoznamka: String;
mvydat, mrozvoz, mdoklady: TDateTime;
mVydano, mRozvezeno: Boolean;
mFV: TNxCustomBusinessObject;
begin
if Sender is TComponent then begin
    mSite := TComponent(Sender).DynSite;
    if Assigned(mSite) and (mSite is TDynSiteForm) then begin
      mfv := TDynSiteForm(mSite).CurrentObject;
      mvydat_Poznamka:=mfv.GetFieldValueAsString('U_vydat_poznamka');
      mRozvoz_Poznamka:=mfv.GetFieldValueAsString('U_rozvoz_poznamka');
      mDoklady_Poznamka:=mfv.GetFieldValueAsString('U_doklad_poznamka');
      mPoznamka:=mfv.GetFieldValueAsString('U_poznamka');
      mvydat:=mfv.GetFieldValueAsDateTime('U_vydat');
      mrozvoz:=mfv.GetFieldValueAsDateTime('U_rozvoz');
      mDoklady:=mfv.GetFieldValueAsDateTime('U_dokladvracen');
      mvydano:=mfv.getfieldvalueasboolean('U_vychystano');
      mRozvezeno:=mfv.getfieldvalueasboolean('U_sfakturou');
                  PPLData(mvydat, mrozvoz, mdoklady, mVydat_poznamka, mRozvoz_poznamka, mDoklady_poznamka, mpoznamka, mvydano, mrozvezeno, mSite);

                mfv.SetFieldValueAsString('U_vydat_poznamka',mvydat_poznamka);
                mfv.SetFieldValueAsString('U_rozvoz_poznamka',mrozvoz_poznamka);
                mfv.SetFieldValueAsString('U_doklad_poznamka',mdoklady_poznamka);
                mfv.SetFieldValueAsString('U_poznamka',mpoznamka);
                mfv.SetFieldValueAsDateTime('U_vydat',mvydat);
                mfv.SetFieldValueAsDateTime('U_rozvoz',mRozvoz);
                mfv.SetFieldValueAsDateTime('U_dokladvracen',mDoklady);
                mfv.setfieldvalueasboolean('U_vychystano',mvydano);
                mfv.setfieldvalueasboolean('U_sfakturou',mrozvezeno);
                mfv.SetFieldValueAsBoolean('U_opravnorozvozem', True);
                mfv.SetFieldValueAsDateTime('U_datumopravy',date);
  mfv.Save;
  mfv.Free;
 end;
end;
end;

Function PPLData(var mvydat:TDateTime; var mrozvoz:TdateTime; var mdoklady:tdatetime; var mvydat_poznamka:string; var mrozvoz_poznamka:string;
var mdoklady_poznamka:string; var mPoznamka: string; var mvydano:boolean; var mrozvezeno:boolean; var asite:TSiteForm):boolean;

 var
  mForm: TForm;
  mLab: TLabel;
  mEd1,mEd3,mEd5, mEd7: TEdit;
  mEd2, mEd4, mEd6: TDateEdit;
  mEd8, med9:TCheckBox;
  mResult: integer;
  mBut: TButton;
begin
  mForm := TForm.Create(Nil);
  try
    mForm.Caption := 'Zadejte popis';
    mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsDialog;
    mForm.Width := 350;
    mForm.Height := 320;
    mForm.Scaled := False;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 5;
    mLab.Caption := 'Vydat';
    mLab.Parent := mForm;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 35;
    mLab.Caption := 'Vydat dne';
    mLab.Parent := mForm;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 75;
    mLab.Caption := 'Rozváží';
    mLab.Parent := mForm;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 105;
    mLab.Caption := 'Rozvoz dne';
    mLab.Parent := mForm;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 135;
    mLab.Caption := 'Doklady';
    mLab.Parent := mForm;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 195;
    mLab.Caption := 'Poznámka';
    mLab.Parent := mForm;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 165;
    mLab.Caption := 'Doklady dne';
    mLab.Parent := mForm;
    mLab := TLabel.Create(mForm);
    mLab.Left := 235;
    mLab.Top := 35;
    mLab.Caption := 'Vychystáno';
    mLab.Parent := mForm;
    mLab := TLabel.Create(mForm);
    mLab.Left := 235;
    mLab.Top := 105;
    mLab.Caption := 'S fakturou';
    mLab.Parent := mForm;
    mEd1 := TEdit.Create(mForm);
    mEd1.Left := 110;
    mEd1.Top := 5;
    mEd1.Width := 200;
    mEd1.Text := mVydat_Poznamka;
    mEd1.Parent := mForm;
    mEd2 := TdateEdit.Create(mForm);
    mEd2.Left := 110;
    mEd2.Top := 35;
    mEd2.Width := 100;
    mEd2.Date:= mVydat;
    mEd2.Parent := mForm;
    mEd3 := TEdit.Create(mForm);
    mEd3.Left := 110;
    mEd3.Top := 75;
    mEd3.Width := 200;
    mEd3.Text := mRozvoz_Poznamka;
    mEd3.Parent := mForm;
    mEd4 := TdateEdit.Create(mForm);
    mEd4.Left := 110;
    mEd4.Top := 105;
    mEd4.Width := 100;
    mEd4.Date:= mrozvoz;
    mEd4.Parent := mForm;
    mEd5 := TEdit.Create(mForm);
    mEd5.Left := 110;
    mEd5.Top := 135;
    mEd5.Width := 200;
    mEd5.Text := mdoklady_poznamka;
    mEd5.Parent := mForm;
    mEd6 := TdateEdit.Create(mForm);
    mEd6.Left := 110;
    mEd6.Top := 165;
    mEd6.Width := 100;
    mEd6.Date:= mdoklady;
    mEd6.Parent := mForm;
    mEd7 := TEdit.Create(mForm);
    mEd7.Left := 110;
    mEd7.Top := 195;
    mEd7.Width := 200;
    mEd7.Text := mpoznamka;
    mEd7.Parent := mForm;
    mEd8 := TCheckBox.Create(mForm);
    mEd8.Left := 220;
    mEd8.Top := 35;
    mEd8.Width := 20;
    mEd8.Checked:= mvydano;
    mEd8.Parent := mForm;
    mEd9 := TCheckBox.Create(mForm);
    mEd9.Left := 220;
    mEd9.Top := 105;
    mEd9.Width := 20;
    mEd9.Checked:= mrozvezeno;
    mEd9.Parent := mForm;
    CreateButton(mForm, mForm, 250, 20, 70, 25, 'Cancel', 2);
    CreateButton(mForm, mForm, 250, 120, 70, 25, 'OK', 1);
    mResult := mForm.Showmodal(asite);
    if mResult = 1 then
      //ShowMessage('Řádně jste zadal:' + Chr(13) + Chr(10) + mEd1.Text + Chr(13) + Chr(10) + mEd2.Text);

      mVydat_poznamka:=mEd1.Text;
      mVydat:=mEd2.date;
      mRozvoz_poznamka:=mEd3.Text;
      mRozvoz:=mEd4.date;
      mdoklady_poznamka:=mEd5.Text;
      mdoklady:=mEd6.date;
      mPoznamka:=mEd7.Text;
      mvydano:=med8.checked;
      mRozvezeno:=med9.checked;

  finally
    mForm.Free;
  end;
end;


function CreateButton(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AWidth, AHeight: integer; ACaption: string; AModalResult: integer): TButton;
begin
  Result := TButton.Create(AOwner);
  Result.Top := ATop;
  Result.Left := ALeft;
  Result.Width := AWidth;
  Result.Height := AHeight;
  Result.Caption := ACaption;
  Result.ModalResult := AModalResult;
  Result.Parent := AParent;
end;

begin
end.