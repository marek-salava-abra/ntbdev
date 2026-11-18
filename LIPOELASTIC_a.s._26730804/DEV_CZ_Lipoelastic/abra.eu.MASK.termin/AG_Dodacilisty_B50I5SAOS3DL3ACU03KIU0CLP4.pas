
procedure OnExec(Sender: TAction; Index: integer);
var
  mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i:integer;
//   mForm: TDynSiteForm;
   mi:integer;
   mBookmark : TBookmarkList;
   mdate:Double;
   mForm : TForm;
  mBtn : TButton;
  mlb2 : TLabel;
  mEdtSrc:TDateEdit;

  mlb3 : TLabel;
  mEdtSrc3:TEdit;

  mlb4 : TLabel;
  mEdtSrc4:TEdit;
  mpreprava,mprice:string;
begin
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));

     mdate:=0;
                mpreprava:='';
                mprice:='';
    try
              mForm := TForm.Create(mSite);            // formulář
                mForm.BorderIcons := [biSystemMenu];
                mForm.Width := 350;  // sirka
                mForm.Height := 200; // vyska
                mForm.Caption := 'Zadej datum expedice';
                    mLb2 := TLabel.Create(mForm);         // položka řada
                    mLb2.Caption := 'Datum:';
                    mLb2.Left := 30;
                    mLb2.Top := 10;
                    mLb2.Name := 'lblDoc1';
                    mForm.InsertControl(mLb2);
                        mEdtSrc := TDateEdit.Create(mForm);
                        mEdtSrc.Left := 100;
                        mEdtSrc.Top := 10;
                        mEdtSrc.Width := 100;
                        mEdtSrc.Name := 'edtDate';
                        mEdtSrc.Date:= date;
                        mForm.InsertControl(mEdtSrc);

                  mLb3 := TLabel.Create(mForm);         // položka řada
                    mLb3.Caption := 'Přeprava';
                    mLb3.Left := 30;
                    mLb3.Top := 50;
                    mLb3.Name := 'lblDoc2';
                    mForm.InsertControl(mLb3);
                        mEdtSrc3 := TEdit.Create(mForm);
                        mEdtSrc3.Left := 100;
                        mEdtSrc3.Top := 50;
                        mEdtSrc3.Width := 250;
                        mEdtSrc3.Name := 'Docnumber';
                        mEdtSrc3.Text:= '';
                        mForm.InsertControl(mEdtSrc3);

                  mLb4 := TLabel.Create(mForm);         // položka řada
                    mLb4.Caption := 'Cena';
                    mLb4.Left := 30;
                    mLb4.Top := 90;
                    mLb4.Name := 'lblDoc3';
                    mForm.InsertControl(mLb4);
                        mEdtSrc4 := TEdit.Create(mForm);
                        mEdtSrc4.Left := 100;
                        mEdtSrc4.Top := 90;
                        mEdtSrc4.Width := 100;
                        mEdtSrc4.Name := 'Price';
                        mEdtSrc4.text:= '111';
                        mForm.InsertControl(mEdtSrc4);


                  mBtn := TButton.Create(mForm);            // tlačítko OK
                        mBtn.Width := 75;
                        mBtn.Height := 25;
                        mBtn.Caption := 'OK';
                        mBtn.ModalResult := mrOk;
                        mBtn.Cancel := False;
                        mBtn.Default := True;
                        mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                        mBtn.Top := mForm.Height - mBtn.Height - 40;
                        mBtn.Name := 'btnOK';
                        mForm.InsertControl(mBtn);
                    mBtn := TButton.Create(mForm);          // tlačítko storno
                        mBtn.Width := 75;
                        mBtn.Height := 25;
                        mBtn.Caption := 'Storno';
                        mBtn.ModalResult := mrCancel;
                        mBtn.Cancel := True;
                        mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
                        mBtn.Top := mForm.Height - mBtn.Height - 40;
                        mBtn.Name := 'btnCancel';
                        mForm.InsertControl(mBtn);

           if mForm.ShowModal(mSite) = mrOK then begin
                mdate:=mEdtSrc.Date;
                mpreprava:=mEdtSrc3.Text;
                mprice:=mEdtSrc4.Text;
           end else begin
                mdate:=0;
                mpreprava:='';
                mprice:='';
           end;
        finally;
          mForm.Free;
        end;












    if mdate=0 then begin
        exit
    end else begin
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

  //  TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;

     if mBookmark.count=0 then begin

              if index=0 then begin
                   // mi:=msite.BaseObjectSpace.SQLExecute('update storedocuments set docDate$Date=' + NxFloatToIBStr(mdate) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
                  //TDynsiteForm(msite).CurrentObject.SetFieldValueAsDateTime('X_termin_dodani',mdate) ;
                  TDynsiteForm(msite).CurrentObject.SetFieldValueAsDateTime('Docdate$date',mdate) ;
                  //TDynsiteForm(msite).CurrentObject.SetFieldValueAsString('U_extNo',mpreprava) ;
                  //TDynsiteForm(msite).CurrentObject.SetFieldValueAsString('X_kalkuldoprava',mprice) ;
                  TDynsiteForm(msite).CurrentObject.save;

              end;

        TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;





    end else begin

         for i := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
              if index=0 then begin
                  if i>0 then mprice:='111' ;
                  //NxShowSimpleMessage( NxFloatToIBStr(mdate) +' -  ' + mpreprava + ' -  ' +mprice,nil);
                  TDynsiteForm(msite).CurrentObject.SetFieldValueAsDateTime('Docdate$date',mdate) ;
                  //TDynsiteForm(msite).CurrentObject.SetFieldValueAsDateTime('X_termin_dodani',mdate) ;
                  //TDynsiteForm(msite).CurrentObject.SetFieldValueAsString('U_extNo',mpreprava) ;
                  //TDynsiteForm(msite).CurrentObject.SetFieldValueAsString('X_kalkuldoprava',mprice) ;
                  TDynsiteForm(msite).CurrentObject.save;

                  //  mi:=msite.BaseObjectSpace.SQLExecute('update storedocuments set docDate$Date=' + NxFloatToIBStr(mdate) + ' where id=' + QuotedStr(tdynsiteform(msite).CurrentObject.oid));
              end;

              TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
         end;

    end;


                   end;


end;


{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
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
          mMAction.Hint := 'Hromadné datum';
          mMAction.Caption := 'Hromadné datum';
          mMAction.Items.Add('Hromadné datum');




          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


end;


begin
end.