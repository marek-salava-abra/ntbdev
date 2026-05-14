{procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := False;
  mAction.Caption := 'Přepočet.hm.a obj.';
  mAction.Items.Add('Přepočet.hm.a obj.');
  mAction.Hint := 'Přepočet hmotnosti a objemu u řádků označených k zajištění. (abra.cz.servis.fika.VariantSCMSupport)';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @CallChangeSelectFromButton;
end;


procedure FormShow_Hook(Self: TSiteForm);
var
  I: Integer;
  mPop: TPopupMenu;
begin
  mPop:= TDBGrid(Self.FindComponent('grdList')).PopupMenu;
  for I:= 0 to mPop.Items.Count - 1 do begin
    mPop.Items[I].OnClick:= @CallChangeSelect;
  end;
end;



// Vynulovani labelu je vazano na datasource, protoze
// dataset neni v Init ani v Init Post k dispozici, resp. napojen
// na datasource gridu.
procedure DsChangeState(Sender: TObject);
var
  mLblCapacityValue: TLabel;
  mLblPriceValue: TLabel;
  mLblWeightValue: TLabel;
  mSite: TSiteForm;
begin
  if TDataSource(Sender).Owner is TSiteForm then begin
    mSite := TSiteForm(TDataSource(Sender).Owner);
  end;
end;


//procedure CallChangeSelect(Sender: TMenuItem);
//var
//  mParentGrid: TObject;
//begin
//  mParentGrid := TObject(TComponent(TPopupMenu(TMenuItem(Sender).Owner).Owner).Owner);
//  if (Sender.MenuIndex = 0) then
//    ChangeSelect(mParentGrid, 3);
//  if (Sender.MenuIndex = 1) then
//    ChangeSelect(mParentGrid, 0);
//  if (Sender.MenuIndex = 2) then begin
//    ChangeSelect(mParentGrid, 3);
//  end;
//end;


//procedure CallChangeSelectFromButton(Sender: TObject);
//var
//  mControl: TControl;
//  mSite: TSiteForm;
//begin
//  mSite := NxFindSiteForm(TComponent(Sender));
//  if Assigned(mSite) then begin
//    mControl := NxFindChildControl(mSite.MainPanel, 'grdList');
//    if Assigned(mControl) then begin
//      ChangeSelect(TObject(mControl), 3)
//    end else begin
//      ShowMessage('Nenalezen Grid.');
//    end;
//  end else begin
//    ShowMessage('Nenalezen SiteForm.');
//  end;
//end;

  {
procedure ChangeSelect(Sender: TObject; AAction: Integer);
// Parametry:
// Sender je odkaz na Grid, AAction:
// -1 = do labelu zobrazi "-"
//  0 = vynulovat hmotnost a objem,
//  1 = +/- jeden zaznam do hmotnosti a objemu, lze pouzit pouze po Ins, nikoliv v Shift+sipka,
//  2 = -
//  3 =  prepocitat jiz oznacene zaznamy, oznacit vse, inverze oznaceni
var
  I: Integer;
  mBookmark: TBookmark;
  mBookmarkList: TBookmarklist;
  mControl: TControl;
  mDataSet: TDataSet;
  mGrid: TDBGrid;
  mLblCapacityValue: TLabel;
  mLblPriceValue: TLabel;
  mLblWeightValue: TLabel;
  mSite: TSiteForm;
  mSelRows :TStringList;
  mSumCapacity: Double;
  mSumPrice: Double;
  mSumWeight: Double;
begin
  mSite := NxFindSiteForm(TComponent(Sender));
  mGrid := TDBGrid(Sender);
  mDataSet := mGrid.DataSource.DataSet;
         if mGrid.SelectedRows.CurrentRowSelected = False then begin
          // Neni radek oznacen, tj. oznacuje se nove => (+)

        end else begin

        end;

        mBookmark := mDataset.GetBookmark;
        if mGrid.SelectedRows.Count > 0 then begin                  // označené záznamy
          mBookmarkList := mGrid.SelectedRows;
          for I := 0 to (mBookmarkList.Count - 1) do begin
            mDataSet.GotoBookmark(mBookmarkList.Items(I));
          //  NxShowSimpleMessage(mDataSet.FieldByName('StoreCard_Code').AsString,nil);
          end;
          mDataSet.GotoBookmark(mBookmark);

          end else begin                                      // jaktivní záznam
         // NxShowSimpleMessage(mDataSet.FieldByName('StoreCard_Code').AsString,nil);
        end;


end;  }

begin
end.