{procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportSB';
  mAction.Caption := 'Import šarží';
  mAction.Hint := 'Naimportuje data ';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @ImportSB;
end;  }

Procedure ImportSB(Sender:TComponent);
var
 msite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mControl: TControl;
 mDataset: TNxRowsObjectDataSet;
 mOpenRollSite:TOpenRolSite;
 mList:TStringList;
 i:integer;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=msite.BaseObjectSpace;
  if not(TDynSiteForm(mSite).Edit) then begin
    NxShowSimpleMessage('Nejste ve stavu editace, řádky nepůjde vložit.',mSite);
    exit;
  end;
      mList:=TStringList.create;
      mOpenRollSite := TOpenRolSite.Create(mSite.SiteContext, Roll_StoreBatches);
      mOpenRollSite.ParentForm := mSite.GetSiteAppForm;
      mOpenRollSite.MultiChoice := True;
      mOpenRollSite.Detailed := False;
      mOpenRollSite.Open;
      mList:=mOpenRollSite.SelectedList;
      {if mlist.Count>0 then begin
        for i:=0 to mList.count-1 do begin
          NxShowSimpleMessage(mlist.strings[i],msite);
        end;
      end;  }
      mControl:= mSite.FindChildControl('tabRows.grdRows');
      mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
      {if Assigned(mDataset) then begin
        mDataSet.DisableControls;
        WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
        for i:=0 to mList.count-1 do begin
                  mIORowBO:=mDataset.CreateBusinessObject;
                  WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mlist.Count));
                  WaitWin.StepIt;
        end;
       WaitWin.Stop;
       TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
       mDataset.RefreshAndRestoreLastSelectedItem;
       mDataSet.EnableControls;}
end;

begin
end.