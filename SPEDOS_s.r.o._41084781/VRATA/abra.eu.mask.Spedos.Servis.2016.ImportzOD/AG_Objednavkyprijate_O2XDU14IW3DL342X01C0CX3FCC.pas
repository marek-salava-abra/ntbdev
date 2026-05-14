uses 'abra.eu.mask.Spedos.Servis.2016.ImportzOD.Objednavky_prijate',
     'abra.eu.mask.Spedos.Servis.2016.ImportzOD.fce';



const
    mFilter='*.xml';













    procedure Mserialnumber(Sender: TComponent;index:integer);
var
  mSite: TDynSiteForm;
  mDBGrid: TMultiGrid;
  mControl: TControl;
  mDataSource: TDataSource;
  mDataset: TNxRowsObjectDataSet;
  mForm: TForm;
  mObjectSpace: TNxCustomObjectSpace;
  mr:Tstringlist;
 mBookmark : TNxBookmarkList;
  mActualRow : TBookmark;
  mPars:TNxParameters;
 mPar:TNxParameter;
  mr2:TStringList;
   mfilter:string;
    mtext:string;
     mStrings:string;
     i:integer;
begin
    try
      mSite := TComponent(Sender).DynSite;

       mDBGrid := TMultiGrid(NxFindChildControl(TDynSiteForm(msite).MainPanel, 'grdRows'));
        mBookmark := mDBGrid.SelectedRows;


          mActualRow := mDBGrid.DataSource.DataSet.GetBookmark;


            //  mtext:='Výrobky k pozici ' + mDBGrid.DataSource.DataSet.FieldByName('X_Pozice_OD').AsString ;


                                           mr2:=TStringList.create;
                                           try
                                               msite.BaseObjectSpace.SQLSelect('SELECT distinct a.id as hodnota FROM DefRollData A where CLSID=' + quotedstr('XNAVPBFTCRO4BBYJZ2FN14T51O') +
                                                ' and X_OP_pozice='+quotedstr(mDBGrid.DataSource.DataSet.FieldByName('X_Pozice_OD').AsString),mr2);

                                                if mr2.count>0 then begin

                                                         mFilter:= '';
                                                         for i:= 0 to mr2.Count - 1 do
                                                            mFilter:= mFilter + Format('''%s'',', [mr2[i]]);
                                                          if mFilter <> '' then begin
                                                            mFilter:= copy(mFilter, 1, Length(mFilter) - 1);
                                                  //        NxShowSimpleMessage('AAAA',nil);
                                                          msite.ShowSite('H3DLVNUZC4KOJBA5D2VT00FKWK',true,'FilterByUserDynSQLCondition;A.ID in (' + mFilter + ') ');

                                                        end;




                                               end else begin
                                                  //  NxShowSimpleMessage('Pro spro pozici nejsou žádné sériové čísla.',nil);
                                                end;



                                           finally
                                              mr2.free;
                                           end;




            mDBGrid.DataSource.DataSet.Cancel;
       //   end;
          mDBGrid.DataSource.DataSet.GotoBookmark(mActualRow);
    except
      ShowMessage('V průběhu rozpadu řádků ML došlo k chybě: ' + ExceptionMessage);
    end;

end;


procedure _AfterNewRec_Hook(Self: TDynSiteForm);
begin
      TDynSiteForm(self).CurrentObject.SetFieldValueAsBoolean('IsRowDiscount', True);


end;

procedure _AfterSave_PreHook(Self: TDynSiteForm);
begin
     if (TDynSiteForm(Self).CurrentObject.GetFieldValueAsFloat('LocalAmount')<0) and (TDynSiteForm(Self).CurrentObject.GetFieldValueAsFloat('Amount')>=0) then begin
            TDynSiteForm(self).CurrentObject.SetFieldValueAsFloat('LocalAmount',TDynSiteForm(self).CurrentObject.getFieldValueAsFloat('Amount')*TDynSiteForm(self).CurrentObject.getFieldValueAsFloat('CurrRate')) ;
            TDynSiteForm(self).CurrentObject.SetFieldValueAsFloat('LocalAmountWithoutVAT',TDynSiteForm(self).CurrentObject.getFieldValueAsFloat('AmountWithoutVAT')*TDynSiteForm(self).CurrentObject.getFieldValueAsFloat('CurrRate')) ;
            TDynSiteForm(self).CurrentObject.save;
     end;
end;

    procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol, mMGColJednotka,mMGColVychystano,mMGColDeliveredQuantity: TNxMultiGridColumn;
  mMGColRoll: TNxMultiGridObjectRollColumn;
  b: Boolean;

  procedure iPreparePosition(ALayout, ALine, ARequestPosition: Integer);
  var
    ii: Integer;
  begin
    for ii:=mMG.ColumnCount-1 downto 0 do
      if (mMG.Columns[ii].Layout = ALayout) and (mMG.Columns[ii].Line = ALine) and
        (mMG.Columns[ii].Order >= ARequestPosition) then
        mMG.Columns[ii].Order := mMG.Columns[ii].Order + 1;
  end;

begin



  mMG := TMultiGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdRows'));
  if Assigned(mMG) then begin
    b := True;
    for i:=mMG.ColumnCount-1 downto 0 do
 {     if mMG.Columns[i].FieldName = 'X_Parent_id' then
        b := False;
        if b then begin
          mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_Parent_id', ftWideString, 0, False, 049);
          with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'Výrobek', False) do begin
            ReadOnly:= False;
            FieldName:= 'X_Parent_id';
            FieldKind:= fkData;
          end;
      iPreparePosition(3, 0, 85);
      mMGColRoll:= (TNxMultiGridObjectRollColumn.Create(mMG.Owner));
      mMGColRoll.FieldName := 'X_Parent_id';
      mMGColRoll.Caption := '#Výrobek';
      mMGColRoll.ReadOnly := False;
      mMGColRoll.Kind := ckText;
      mMGColRoll.Elastic := false;
      mMGColRoll.Width := 70;
      mMGColRoll.Layout := 3;
      mMGColRoll.Line := 0;
      mMGColRoll.Order := 85;
      mMGColRoll.Kind := ckUser;
      mMGColRoll.ClassID:=('DG3FQ4KD2QN4LBCOJQT3MRAUYS');
      mMGColRoll.TextField:='Name';
      mMG.AddColumn(mMGColRoll);
    end;   }

    if mMG.Columns[i].FieldName = 'X_Group_macro_id' then
        b := False;
        if b then begin
          mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_Group_macro_id', ftWideString, 0, False, 049);
          with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'Makrokarta', False) do begin
            ReadOnly:= False;
            FieldName:= 'X_Group_macro_id';
            FieldKind:= fkData;
          end;
      iPreparePosition(3, 0, 85);
      mMGColRoll:= (TNxMultiGridObjectRollColumn.Create(mMG.Owner));
      mMGColRoll.FieldName := 'X_Group_macro_id';
      mMGColRoll.Caption := '#Makrokarta';
      mMGColRoll.ReadOnly := False;
      mMGColRoll.Kind := ckText;
      mMGColRoll.Elastic := false;
      mMGColRoll.Width := 70;
      mMGColRoll.Layout := 3;
      mMGColRoll.Line := 0;
      mMGColRoll.Order := 85;
      mMGColRoll.Kind := ckUser;
      mMGColRoll.ClassID:=('S3WZQKDB5FDL342M01C0CX3FCC');
      mMGColRoll.TextField:='Code';
      mMG.AddColumn(mMGColRoll);
    end;

    if mMG.Columns[i].FieldName = 'X_Pozice_OD' then
        b := False;
        if b then begin
          mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_Pozice_OD', ftWideString, 0, False, 049);
          with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'Pozice', False) do begin
            ReadOnly:= False;
            FieldName:= 'X_Pozice_OD';
            FieldKind:= fkData;
          end;
      iPreparePosition(3, 0, 85);
      mMGColRoll:= (TNxMultiGridObjectRollColumn.Create(mMG.Owner));
      mMGColRoll.FieldName := 'X_Pozice_OD';
      mMGColRoll.Caption := '#Pozice';
      mMGColRoll.ReadOnly := False;
      mMGColRoll.Kind := ckText;
      mMGColRoll.Elastic := false;
      mMGColRoll.Width := 70;
      mMGColRoll.Layout := 3;
      mMGColRoll.Line := 0;
      mMGColRoll.Order := 85;
      mMGColRoll.Kind := ckUser;
      mMGColRoll.ClassID:=('5ZUGC4GVLH14T15G4BQKMK1CXK');
      mMGColRoll.TextField:='Name';
      mMG.AddColumn(mMGColRoll);
    end;


 end;
end;









procedure FormCreate_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
  mAction: TBasicAction;
  mAList: TActionList;
  i: integer;
  mAct: TBasicAction;
begin
           mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Import výrobku z OD';
          mMAction.Caption := 'Výroba - rezervace';
          mMAction.Items.Add('Výroba - rezervace');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @ImportVYRzOD;


          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Doplnění výrobku';
          mMAction.Caption := 'Doplnění výrobku ';
          mMAction.Items.Add('Doplnění výrobku');
          mMAction.Category := 'tabDetail';
          mMAction.OnExecuteItem := @ImportVYRzOD_dopl;


           mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Vytvoření OBDV';
          mMAction.Caption := 'Vytvoření OBDV ';
          mMAction.Items.Add('Vytvoření OBDV');
          mMAction.Category := 'tablist';
          mMAction.OnExecuteItem := @ImportVYRzOD_OBDV;


           mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Výrobní čísla';
          mMAction.Caption := 'Výrobní čísla ';
          mMAction.Items.Add('Výrobní čísla');
          mMAction.Category := 'tabdetail';
          mMAction.OnExecuteItem := @mserialnumber;

end;



procedure ImportVYRzOD(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile:string;
  mr:TStringList;
  mpath:string;
  mSite:tsiteform;
begin
      mSite := NxFindSiteForm(TComponent(Sender));
      //if not TDynSiteForm(mSite).Edit then begin
      //  ShowMessage('Akce vytvoření SP je přístupná jen v editaci dokladu.');
      //  Exit;
      //end;
       // mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
   // if mTabList = nil then RaiseException('tabList nenalezen');
   // mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
   // if mDBGrid = nil then RaiseException('DBGrid nenalezen');

      mpath:='';

      mr:=TStringList.Create;
          try
              msite.baseobjectspace.SQLSelect('select Directory from FileQueues where id='+ quotedstr('1100000101'),mr);
              if mr.count=1 then mpath:=mr.Strings[0];
          finally
             mr.free;
          end;

        if PromptForFileName(mFileName, mfilter, '\\192.168.0.80\abradata\exchange\OD\OBDV', 'Soubory SP', mpath, False) then begin
          mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
          mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
          Import_VYR_OD(msite.baseobjectspace, mfilename, mdir,mfile,msite,true,false);
        end;

         TDynSiteForm(msite).CurrentObject.Refresh;
    TDynSiteForm(msite).Refresh;
end;




procedure ImportVYRzOD_dopl(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile:string;
  mr:TStringList;
  mpath:string;
  mSite:tsiteform;
  mDBGrid : TMultiGrid;
  mControl:TControl;
  mDataset:TNxRowsObjectDataSet;
begin
      mSite := TComponent(Sender).Site;
      mControl:= mSite.FindChildControl('tabRows.grdRows');
      mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
      //if not TDynSiteForm(mSite).Edit then begin
      //  ShowMessage('Akce vytvoření SP je přístupná jen v editaci dokladu.');
      //  Exit;
      //end;
       // mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
   // if mTabList = nil then RaiseException('tabList nenalezen');
   // mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
   // if mDBGrid = nil then RaiseException('DBGrid nenalezen');

      mpath:='';

      mr:=TStringList.Create;
          try
              msite.baseobjectspace.SQLSelect('select Directory from FileQueues where id='+ quotedstr('1100000101'),mr);
              if mr.count=1 then mpath:=mr.Strings[0];
          finally
             mr.free;
          end;

        if PromptForFileName(mFileName, mfilter, '', 'Soubory SP', mpath, False) then begin
          mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
          mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
          try
           mDataset.DisableControls;
           Import_VYR_OD_DOPL(msite.baseobjectspace, mfilename, mdir,mfile,msite,true,false,TDynSiteForm(msite).CurrentObject);
          finally
            TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
            mDataset.RefreshAndRestoreLastSelectedItem;
            mDataSet.EnableControls;
          end;
        end;


        mDBGrid := TMultiGrid(NxFindChildControl(TDynSiteForm(NxFindSiteForm(Sender)).MainPanel, 'grdRows'));
//          mActualRow := mDBGrid.DataSource.DataSet.GetBookmark;

  if Assigned(mDBGrid) then mDBGrid.DataSource.DataSet.Refresh;








end;




procedure ImportVYRzOD_OBDV(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile:string;
  mr:TStringList;
  mpath:string;
  msite:tsiteform;
begin
      mSite := NxFindSiteForm(TComponent(Sender));
      //if not TDynSiteForm(mSite).Edit then begin
      //  ShowMessage('Akce vytvoření SP je přístupná jen v editaci dokladu.');
      //  Exit;
      //end;
       // mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
   // if mTabList = nil then RaiseException('tabList nenalezen');
   // mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
   // if mDBGrid = nil then RaiseException('DBGrid nenalezen');

      mpath:='';

      mr:=TStringList.Create;
          try
              msite.baseobjectspace.SQLSelect('select Directory from FileQueues where id='+ quotedstr('1100000101'),mr);
              if mr.count=1 then mpath:=mr.Strings[0];
          finally
             mr.free;
          end;

        if PromptForFileName(mFileName, mfilter, '', 'Soubory SP', mpath, False) then begin
          mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
          mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
          Import_VYR_OD_OBDV(msite.baseobjectspace, mfilename, mdir,mfile,msite,true,false);
        end;

    //TDynSiteForm(msite).CurrentObject.Refresh;
    //TDynSiteForm(msite).Refresh;
end;






begin
end.
