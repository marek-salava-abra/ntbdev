procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actChangeRowData';
  mAction.Caption := '##Změna střediska##';
  mAction.Hint := 'Změní středisko na označených řádcích';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @ChangeRowData;
  mAction.OnUpdate := @OnUpdate;
end;

procedure ChangeRowData(Sender:TComponent);
var
 mSite:TSiteForm;
 mControl: TControl;
 mDataset: TNxRowsObjectDataSet;
 mOS:TNxCustomObjectSpace;
 mDivision_ID:string;
 i:integer;
 mGRows:TMultiGrid;
 mList:TStringList;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 mDivision_ID:='';
 if GetDivision_ID(mSite, mDivision_ID) then
  begin
   if not(NxIsEmptyOID(mDivision_ID)) then
    begin
     try
       mControl:= mSite.FindChildControl('tabRows.grdRows');
       mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
       mList:=TStringList.create;
       mGRows :=  TMultiGrid(mControl);
       if Assigned(mGRows) then mGRows.FillListFromSelectedRows_1(mList,false);
       if mList.count>0 then begin
          mDataset.First;
          while not(mDataset.Eof) do begin
            if mList.IndexOf(mDataSet.CurrentObject.GetFieldValueAsString('ID')) <> -1 then
             begin
              if not (mDataSet.State in [dsEdit, dsInsert]) then mDataSet.Edit;
              mDataSet.FieldValues['Division_ID'] :=mDivision_ID;
              mDataSet.Post;
             end;
             mDataset.Next;
           end;
         mDataSet.Refresh;
       end;
     except
       NxShowSimpleMessage(ExceptionMessage,mSite);
     end;
    end;
  end;
end;


procedure OnUpdate(Sender: TObject);
var
  mSite: TDynSiteForm;
begin
  mSite := TDynSiteForm(TComponent(Sender).Site);
  TBasicAction(Sender).Enabled := mSite.Edit;
end;


Function GetDivision_ID(var ASite : TSiteform; var aDivision_ID:String):Boolean;
var
    mLabel, mCbCCDivision: TLabel;
    mAllowed:TStringList;
    mButOk, mButCancel : TButton;
    mResult, mCount : integer;
    mForm : TForm;
    mCBDivision:TRollComboEdit;
 begin
 if ASite <> nil then begin
    mAllowed:=TStringList.Create;
    //ASite.BaseObjectSpace.SQLSelect('Select id from defrolldata where clsid='+QuotedStr(Class_BO_EmailTemplates)+' and X_TemplateType='+IntToStr(aType),mAllowed);
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 510;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Změna střediska';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Středisko:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCbCCDivision:= TLabel.Create(mForm);
    mCbCCDivision.Parent:= mForm;
    mCbCCDivision.Left:= 236;
    mCbCCDivision.Top:= (mCount*25)+12;
    mCbCCDivision.Width:= 255;

    mCBDivision:= TRollComboEdit.Create(mForm);
    mCBDivision.Parent:= mForm;
    mCBDivision.ClassID:= Roll_Divisions;
    mCBDivision.Complete:= True;
    mCBDivision.Prefilling:= pmNone;
    mCBDivision.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCBDivision.Top:= (mCount*25)+10;
    mCBDivision.Left:= 140;
    mCBDivision.Width:= 80;
    //mCBDivision.Parameters.Clear;
    //mCBDivision.Parameters.Add('_Allowed='+mAllowed.DelimitedText);
    mCBDivision.ConnectedControl:= mCbCCDivision;
    mCBDivision.ConnectedControlField:= 'Code';



    mCount:= mCount+1;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Default:= true;
    mButOk.Caption := 'OK';
    mButOk.Top := (mCount*25)+20;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := (mCount*25)+20;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    mForm.Height:= (mCount*25)+95;

    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
         aDivision_ID:=mCBDivision.DataText;
         Result:=True;
     end;
    mForm.free;
  end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;

begin
end.