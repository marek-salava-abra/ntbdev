  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
       '_Knihovny_ALL.VisualForms';


function CreateEdita(AName, ACaption: string;
  ALeft, ATop, AWidth: Integer; ALblWidth: Integer; ADefaultValue: string; AParent: TWinControl;
  AEditToNewLine: Boolean = False): TEdit;
var mLbl: TLabel;
begin
  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 5;
  mLbl.Left:= ALeft;
  mLbl.AutoSize:= False;
  if AName <> '' then
    mLbl.Name:= 'lbl_' + AName;
  if ALblWidth > -1 then
  begin
    mLbl.Width:= ALblWidth
  end else
  begin
    mLbl.AutoSize:= True;
    ALblWidth:= mLbl.Width + 10;
  end;
  mLbl.Caption:= ACaption;

  Result:= TEdit.Create(AParent);
  Result.Parent:= AParent;
  if not AEditToNewLine then
  begin
    Result.Top:= ATop;
    Result.Left:= ALeft + ALblWidth;
    Result.Width:= AWidth - ALblWidth;
  end else
  begin
    mLbl.Top:= ATop;
    Result.Top:= ATop + mLbl.Height + 2;
    Result.Width:= AWidth;
    Result.Left:= ALeft;
  end;
  if AName <> '' then
    Result.Name:= 'ed_' + AName;

  Result.Text:= ADefaultValue;
end;




function CreateNxComboEdita(AName, ACaption: string;
                           AParent: TWinControl;
                           ALeft, ATop, AWidth, AHeight,
                           ALblWidth, ABevelWidth: Integer;
                           AClassID, ATextField, AControlField, AID: string;
                           AParam: string = ''; AChange: string =''): TRollComboEdit;
var mLbl, mLbl1,
    mLblChange: TLabel;
begin
  if AID = '' then
    AID:= '0000000000';
  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 5;
  mLbl.Left:= ALeft;
  mLbl.AutoSize:= False;
  if AName <> '' then
    mLbl.Name:= 'lbl_' + AName;
  if ALblWidth > -1 then
  begin
    mLbl.Width:= ALblWidth
  end else
  begin
    mLbl.AutoSize:= True;
    ALblWidth:= mLbl.Width + 10;
  end;
  mLbl.Caption:= ACaption;

  mLbl1:= TLabel.Create(AParent);
  mLbl1.Parent:= AParent;
  mLbl1.Top:= ATop + 5;
  mLbl1.Left:= ALeft +AWidth ;
  mLbl1.AutoSize:= False;
  mLbl1.Caption:= '';
  if AName <> '' then
    mLbl1.Name:= 'lblBev_' + AName;
  mLbl1.Width:= ABevelWidth;
  mLbl1.Visible:= ABevelWidth > 0;

  Result:= TRollComboEdit.Create(AParent);
  Result.Parent:= AParent;
  Result.ClassID:= AClassID;
  Result.ForcedField:= True;
  Result.Prefilling:= pmNone;
  Result.TextField:= ATextField;
  Result.Parameters.Add(AParam);
  Result.Top:= ATop + 3;
  Result.Left:= ALeft + ALblWidth;
  if AControlField <> '' then
  begin
    Result.ConnectedControlField:= AControlField;
    Result.ConnectedControl:= mLbl1;
  end;

  if AName <> '' then
    Result.Name:= 'ced_' + AName;
  Result.DataText:= AID;
  Result.Width:= AWidth - ALblWidth - ABevelWidth;


  if (AChange <> '') and (AName <> '') then
  begin
    mLblChange:= TLabel.Create(AParent);
    mLblChange.Parent:= AParent;
    mLblChange.Top:= 0;
    mLblChange.Left:= 0;
    mLblChange.ViSible:= False;
    mLblChange.Name:= 'lblCh_' + AName;
    mLblChange.Caption:= AChange;
    Result.OnChange:= @NxDBComboEditChange;
  end;


  mLbl1.Left:= mLbl1.Left + 10;
  mLbl1.Width:= mLbl1.Width - 10;
end;



  function CreateFormDialoga(AName, ACaption: String;
                          AParent: TWinControl;
                          AWidth, AHeight: Integer; ): TForm;
var
  mForm: TForm;
begin
  mForm := TForm.Create(AParent);
  mForm.Name := 'fm_'+AName;
  mForm.Caption := ACaption;
  mForm.FormStyle := fsStayOnTop;
  mForm.BorderStyle := bsDialog;
  mForm.Position := poScreenCenter;
  mForm.Width := AWidth;
  mForm.Height := AHeight;
  mForm.Scaled := False;

  Result := mForm;
end;




 procedure Material(Sender: TObject;index:integer);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
  mObj, mObj2: TNxCustomBusinessObject;
  i: integer;
  mOLE, mRoll, mOResult: Variant;
  mid_reportx:tstringlist;
  mr,mr0:tstringlist;
  mBO:TNxCustomBusinessObject;
  mi:integer;
  mBookmark : TBookmarkList;
  mIBookmark:integer;
  mICount:integer;
  mids:string;
  mString:string;
   mform:TForm;
 result:integer;
 mMat1,mMat2,mMat3,mMat4,mMat5,mMat6:TRollComboEdit;
 mPMat1,mPMat2,mPMat3,mPMat4,mPMat5,mPMat6:TEdit;
 mBtn:TButton;
 mSMat1,mSMat2,mSMat3,mSMat4,mSMat5,mSMat6:String;
 mSPMat1,mSPMat2,mSPMat3,mSPMat4,mSPMat5,mSPMat6:string;
begin
  mids:='';
  if Sender is TComponent then mSite := TComponent(Sender).Site;

//  if Sender is TAction then mSite := NxFindSiteForm(Sender);

    if not Assigned(mSite) then begin
         NxMessageBox('Chyba', 'Agenda nebyla dohledána', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
         nxbeep(btfailure);
         exit;
    end else begin
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
            if mTabList = nil then begin
                  RaiseException('tabList nenalezen');
                  NxMessageBox('Chyba', 'abList nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                  nxbeep(btfailure);
                  exit;
            end else begin
            mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
                if mDBGrid = nil then begin
                      RaiseException('DBGrid nenalezen');
                      NxMessageBox('Chyba', 'DBGrid nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                      nxbeep(btfailure);
                      exit;
                end else begin
                      mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                      mIBookmark:=0;




                     if index=0 then begin
                         mform:=CreateFormDialoga('mform', 'Materiálové složení ',mSite, 500, 280);
                         try
                           mSMat1:='';
                           mSMat2:='';
                           mSMat3:='';
                           mSMat4:='';
                           mSMat5:='';
                           mSMat6:='';

                           mSPMat1:='';
                           mSPMat2:='';
                           mSPMat3:='';
                           mSPMat4:='';
                           mSPMat5:='';
                           mSPMat6:='';

                           mMat1:=CreateNxComboEdita('xMat1', 'Material:',mform,  5,  10, 250, 250, 50, 80, 'FVSIYDWGWSBOXFZERLB132TKNS', 'code', 'Name', 'ID', '','');
                           mMat2:=CreateNxComboEdita('xMat2', 'Material:',mform,  5,  40, 250, 250, 50, 80, 'FVSIYDWGWSBOXFZERLB132TKNS', 'code', 'Name', 'ID', '','');
                           mMat3:=CreateNxComboEdita('xMat3', 'Material:',mform,  5,  70, 250, 250, 50, 80, 'FVSIYDWGWSBOXFZERLB132TKNS', 'code', 'Name', 'ID', '','');
                           mMat4:=CreateNxComboEdita('xMat4', 'Material:',mform,  5, 100, 250, 250, 50, 80, 'FVSIYDWGWSBOXFZERLB132TKNS', 'code', 'Name', 'ID', '','');
                           mMat5:=CreateNxComboEdita('xMat5', 'Material:',mform,  5, 130, 250, 250, 50, 80, 'FVSIYDWGWSBOXFZERLB132TKNS', 'code', 'NAme', 'ID', '','');
                           mMat6:=CreateNxComboEdita('xMat6', 'Material:',mform,  5, 160, 250, 250, 50, 80, 'FVSIYDWGWSBOXFZERLB132TKNS', 'code', 'NAme', 'ID', '','');


                           mPMat1:=CreateEdita('mPMat1', '% poměr', 350, 10, 100, 50, '0', mform,false) ;
                           mPMat2:=CreateEdita('mPMat2', '% poměr', 350, 40, 100, 50, '0', mform,false) ;
                           mPMat3:=CreateEdita('mPMat3', '% poměr', 350, 70, 100, 50, '0', mform,false) ;
                           mPMat4:=CreateEdita('mPMat4', '% poměr', 350,100, 100, 50, '0', mform,false) ;
                           mPMat5:=CreateEdita('mPMat5', '% poměr', 350,130, 100, 50, '0', mform,false) ;
                           mPMat5:=CreateEdita('mPMat6', '% poměr', 350,160, 100, 50, '0', mform,false) ;

                            mBtn := TButton.Create(mForm);mBtn.Width := 200 ;mBtn.Height := 40;mBtn.Caption := 'Zápis'; mBtn.ModalResult := 2; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=30;mBtn.Top :=190 ;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                            mBtn := TButton.Create(mForm);mBtn.Width := 200 ;mBtn.Height := 40;mBtn.Caption := 'Storno';mBtn.ModalResult := 99;mBtn.Cancel := False;mBtn.Left := 270;mBtn.Top := 190;mBtn.Name := 'btn99';mForm.InsertControl(mBtn);


                            //  ab:= CreateEdita('slozeni', 'Poměr',mform, 300,30, 30, 50,100, '155455',false,true,true,10, [fsBold],255) ;

                               Result := mForm.ShowModal(mSite);
                               if result= 2 then begin
                                   //NxShowSimpleMessage(mMat1.DataText,nil);
                                   mSMat1:=mMat1.DataText;
                                   mSMat2:=mMat2.DataText;
                                   mSMat3:=mMat3.DataText;
                                   mSMat4:=mMat4.DataText;
                                   mSMat5:=mMat5.DataText;
                                   mSMat5:=mMat6.DataText;

                                   mSPMat1:=mPMat1.Text;
                                   mSPMat2:=mPMat2.Text;
                                   mSPMat3:=mPMat3.Text;
                                   mSPMat4:=mPMat4.Text;
                                   mSPMat5:=mPMat5.Text;
                                   mSPMat5:=mPMat6.Text;
                               end;


                               if result= 99 then begin
                                   NxShowSimpleMessage('Operace byla přerušena uživatelem',nil);
                                   exit;
                               end;
                         finally
                             mform.free;
                         end;
                     end;

                     if mBookmark.count>0 then begin
                           mIBookmark:=mBookmark.count-1;
                           ProgressInit(msite, 'Zpracování dat ' + '', 100);
                      end;


                      // ****** převzetí z jiné šarže
                           if (index=2) then begin
                               if (mIBookmark=0) then begin
                                      NxShowSimpleMessage('Pro práci musí být označen aspoň 1 záznam. ',nil);
                                      exit;
                               end;
                               mobj:=TBusRollSiteForm(msite).CurrentObject;
                               mstring:='Do označených ' + inttostr(mIBookmark) + 'záznamů  bude použito materiálové složení: ' ;
                               if not NxIsEmptyOID(mobj.GetFieldValueAsString('X_mat1')) then  mstring:=mstring + chr(29) + mobj.GetFieldValueAsString('X_mat1.Name') + ' : ' + (mobj.GetFieldValueAsString('X_mat1_proc')) ;
                               if not NxIsEmptyOID(mobj.GetFieldValueAsString('X_mat2')) then  mstring:=mstring + ',' +  chr(29) + mobj.GetFieldValueAsString('X_mat2.Name') + ' : ' + (mobj.GetFieldValueAsString('X_mat2_proc')) ;
                               if not NxIsEmptyOID(mobj.GetFieldValueAsString('X_mat3')) then  mstring:=mstring + ',' + chr(29) + mobj.GetFieldValueAsString('X_mat3.Name') + ' : ' + (mobj.GetFieldValueAsString('X_mat3_proc')) ;
                               if not NxIsEmptyOID(mobj.GetFieldValueAsString('X_mat4')) then  mstring:=mstring + ',' + chr(29) + mobj.GetFieldValueAsString('X_mat4.Name') + ' : ' + (mobj.GetFieldValueAsString('X_mat4_proc')) ;
                               if not NxIsEmptyOID(mobj.GetFieldValueAsString('X_mat5')) then  mstring:=mstring + ',' + chr(29) + mobj.GetFieldValueAsString('X_mat5.Name') + ' : ' + (mobj.GetFieldValueAsString('X_mat5_proc')) ;
                               if not NxIsEmptyOID(mobj.GetFieldValueAsString('X_mat6')) then  mstring:=mstring + ',' + chr(29) + mobj.GetFieldValueAsString('X_mat6.Name') + ' : ' + (mobj.GetFieldValueAsString('X_mat6_proc')) ;
                              // NxShowSimpleMessage(mstring ,nil);
                           end;



                      for mICount:=0 to mIBookmark do begin
                          if mBookmark.count>0 then begin
                               mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));
                               ProgressSetPos(1+NxFloor(mICount/mBookmark.Count*99), inttostr(mICount) +' z '+inttostr(mBookmark.Count));
                          end;

                          if index=0 then begin
                              mbo:=TBusRollSiteForm(msite).CurrentObject;    // načtení objektu
                                if msmat1<>'0000000000' then mbo.SetFieldValueAsString('X_mat1',mSMat1);
                                if msmat2<>'0000000000' then mbo.SetFieldValueAsString('X_mat2',mSMat2);
                                if msmat3<>'0000000000' then mbo.SetFieldValueAsString('X_mat3',mSMat3);
                                if msmat4<>'0000000000' then mbo.SetFieldValueAsString('X_mat4',mSMat4);
                                if msmat5<>'0000000000' then mbo.SetFieldValueAsString('X_mat5',mSMat5);
                                if msmat6<>'0000000000' then mbo.SetFieldValueAsString('X_mat6',mSMat5);

                                mbo.setFieldValueAsString('X_mat1_proc',mSPMat1) ;
                                mbo.setFieldValueAsString('X_mat2_proc',mSPMat2) ;
                                mbo.setFieldValueAsString('X_mat3_proc',mSPMat3) ;
                                mbo.setFieldValueAsString('X_mat4_proc',mSPMat4) ;
                                mbo.setFieldValueAsString('X_mat5_proc',mSPMat5) ;
                                mbo.setFieldValueAsString('X_mat6_proc',mSPMat6) ;
                              mbo.save;
                          end;

                          if index=1 then begin
                             mbo:=TBusRollSiteForm(msite).CurrentObject;




                             mBO.SetFieldValueAsString('X_parent_ID',mbo.GetFieldValueAsString('Storecard_ID.X_parent_ID'));
                             mBO.SetFieldValueAsString('X_Verze',mbo.GetFieldValueAsString('Storecard_ID.X_parent_ID.X_verze'));

                             mbo.SetFieldValueAsString('X_mat1',mbo.GetFieldValueAsString('StoreCard_ID.X_MAT1'));
                             mbo.SetFieldValueAsString('X_mat2',mbo.GetFieldValueAsString('StoreCard_ID.X_MAT2'));
                             mbo.SetFieldValueAsString('X_mat3',mbo.GetFieldValueAsString('StoreCard_ID.X_MAT3'));
                             mbo.SetFieldValueAsString('X_mat4',mbo.GetFieldValueAsString('StoreCard_ID.X_MAT4'));
                             mbo.SetFieldValueAsString('X_mat5',mbo.GetFieldValueAsString('StoreCard_ID.X_MAT5'));
                             mbo.SetFieldValueAsString('X_mat6',mbo.GetFieldValueAsString('StoreCard_ID.X_MAT6'));

                             mbo.setFieldValueAsString('X_mat1_proc',mbo.GetFieldValueAsString('StoreCard_ID.X_mat1_proc')) ;
                             mbo.setFieldValueAsString('X_mat2_proc',mbo.GetFieldValueAsString('StoreCard_ID.X_mat2_proc')) ;
                             mbo.setFieldValueAsString('X_mat3_proc',mbo.GetFieldValueAsString('StoreCard_ID.X_mat3_proc')) ;
                             mbo.setFieldValueAsString('X_mat4_proc',mbo.GetFieldValueAsString('StoreCard_ID.X_mat4_proc')) ;
                             mbo.setFieldValueAsString('X_mat5_proc',mbo.GetFieldValueAsString('StoreCard_ID.X_mat5_proc')) ;
                             mbo.setFieldValueAsString('X_mat6_proc',mbo.GetFieldValueAsString('StoreCard_ID.X_mat6_proc')) ;
                             mbo.save;
                          end;



                          if index=2 then begin
                              mbo:=TBusRollSiteForm(msite).CurrentObject;    // načtení objektu
                                mbo.SetFieldValueAsString('X_mat1',mObj.getFieldValueAsString('X_mat1'));
                                mbo.SetFieldValueAsString('X_mat2',mObj.getFieldValueAsString('X_mat2'));
                                mbo.SetFieldValueAsString('X_mat3',mObj.getFieldValueAsString('X_mat3'));
                                mbo.SetFieldValueAsString('X_mat4',mObj.getFieldValueAsString('X_mat4'));
                                mbo.SetFieldValueAsString('X_mat5',mObj.getFieldValueAsString('X_mat5'));
                                mbo.SetFieldValueAsString('X_mat6',mObj.getFieldValueAsString('X_mat6'));

                                mbo.setFieldValueAsString('X_mat1_proc',mobj.GetFieldValueAsString('X_mat1_proc')) ;
                                mbo.setFieldValueAsString('X_mat2_proc',mobj.GetFieldValueAsString('X_mat2_proc')) ;
                                mbo.setFieldValueAsString('X_mat3_proc',mobj.GetFieldValueAsString('X_mat3_proc')) ;
                                mbo.setFieldValueAsString('X_mat4_proc',mobj.GetFieldValueAsString('X_mat4_proc')) ;
                                mbo.setFieldValueAsString('X_mat5_proc',mobj.GetFieldValueAsString('X_mat5_proc')) ;
                                mbo.setFieldValueAsString('X_mat6_proc',mobj.GetFieldValueAsString('X_mat6_proc')) ;
                              mbo.save;
                          end;


                      end;
                      if mBookmark.count>0 then  ProgressDispose()   ;
                end;
            end;
    end;



end;


procedure ShowSDDocExecuteItem(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 msite:TBusRollSiteForm;
 mr2:TStringList;
 mStrings:string;
 i:integer;
 mOLE, mRoll,mRoll2,mAgenda, mOResult: Variant;
 mSelected ,_ss:Variant;
 mstring:string;
 mFilter:string;
 mB:boolean;
begin
  mSite := TComponent(sender).BusRollSite;
  mbo:=TBusRollSiteForm(mSite).CurrentObject;


              if index=0 then begin
                                          mr2:=TStringList.create;
                                           try
                                               mbo.ObjectSpace.SQLSelect('SELECT distinct a.id as hodnota FROM DefRollData A where A.CLSID=' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                                                ' and a.X_batches='+quotedstr(mbo.GetFieldValueAsString('ID')) ,mr2);
                                                if mr2.count>0 then begin

                                                         mFilter:= '';
                                                         for i:= 0 to mr2.Count - 1 do begin
                                                            mFilter:= mFilter + Format('''%s'',', [mr2[i]]);
                                                            if i = mr2.Count-1  then begin
                                                                mFilter:= copy(mFilter, 1, Length(mFilter) - 1);
                                                            end;
                                                          end;
                                                          msite.ShowSite('FJFZPKZ3TVMOV00YPT2WI34V34',true,'FilterByUserDynSQLCondition;A.ID in (' + mFilter + ') ');
                                                    end else begin
                                                        NxShowSimpleMessage('Pro šarži nebyly vygenerovány pohyby.',nil);
                                                    end;
                                           finally
                                              mr2.free;
                                           end;


              end;

              if index=1 then begin
                                          mr2:=TStringList.create;
                                           try
                                               mbo.ObjectSpace.SQLSelect('SELECT distinct b.id FROM DefRollData B where B.CLSID=' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                                                ' and b.X_parent_ID = (SELECT a.X_parent_ID FROM DefRollData a where a.CLSID=' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                                                ' and a.X_batches='+quotedstr(mbo.GetFieldValueAsString('ID'))+ ')' ,mr2);



                                                if mr2.count>0 then begin

                                                         mFilter:= '';
                                                         for i:= 0 to mr2.Count - 1 do begin
                                                            mFilter:= mFilter + Format('''%s'',', [mr2[i]]);
                                                            if i = mr2.Count-1  then begin
                                                                mFilter:= copy(mFilter, 1, Length(mFilter) - 1);
                                                            end;
                                                          end;
                                                          msite.ShowSite('FJFZPKZ3TVMOV00YPT2WI34V34',true,'FilterByUserDynSQLCondition;A.ID in (' + mFilter + ') ');
                                                    end else begin
                                                        NxShowSimpleMessage('Pro šarži nebyly vygenerovány pohyby.',nil);
                                                    end;
                                           finally
                                              mr2.free;
                                           end;


              end;

end;




procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMAction: TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Materiálové složení';
  mMAction.Hint := 'Práce s materiálovým složení na šarži';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('Upravit materiálové složení');
  mMAction.Items.Add('Převzít MS z skladové karty');
  mMAction.Items.Add('Převzít MS z aktivní šarže');
  mMAction.OnExecuteItem := @Material;


  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Pohyb na OV';
  mMAction.Hint := 'Pohyb na OV';
  mMAction.Category := 'tablist,tabdetail';
  mMAction.OnExecuteItem := @ShowSDDocExecuteItem;

  mMAction.Items.Add('Pohyb šarže na řádku OV');
  mMAction.Items.Add('Pohyby šarží na řádku OV');

end;





begin
end.












